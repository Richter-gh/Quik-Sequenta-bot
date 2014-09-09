module("SysFunc", package.seeall)

function toPrice(SecCode,value)
--[[
преобразует число к формату инструмента
    
]]	local i=0
    while getSecurityInfo(getSecurityClass(SecCode),SecCode)==nil do
        sleep(1000)
        i=i+1
        if i>3 then
            message(SecCode,1)
            message('problem',1)
        end
    end
	local scale=getSecurityInfo(getSecurityClass(SecCode),SecCode).scale
	return tonumber(string.format("%."..string.format("%d",scale).."f",value))
end
function getSecurityClass(sec_code)
    classes_list=getClassesList()   
    for class_code in string.gmatch(classes_list,"%a+") do
        if getSecurityInfo(class_code,sec_code) then return class_code end
    end
    return nil
end
-- Возвратит таймфрейм графика с идентификатором ident в секундах. 
-- nil при ошибке
function GetTf(ident)
    local candles = getCandlesByIndex(ident,0,0,getNumCandles(ident)-1)
    if candles then
        for i = 1,#candles do
            candles[i] = os.time(candles[i].datetime)
        end
        for i = 2,#candles do
            candles[i-1] = candles[i] - candles[i-1]
        end
    --    table.remove(candles,#candles)
        return math.min(unpack(candles))/60
    end
end
function GetDate() 
--[[ 
возвращает текущую дату в формате "ГГГГММДД"
]]   
	local month,day,year = tonumber(string.sub(os.date("%x"), 1, 2)),tonumber(string.sub(os.date("%x"), 4, 5)),tonumber(string.sub(os.date("%x"), 7, 8))
	if month<10 then
		month = "0"..tostring(month)
    end
    if day<10 then
		day = "0"..tostring(day)
	end
    return tostring(2000+year)..tostring(month)..tostring(day)
end

function GetTime()
    return tonumber(os.date("%H%M%S")) 
end
function GetTime2()
    return tostring(os.date("%H:%M:%S")) 
end
function GetCandleTime(tag,num)
    local CandleCount = getNumCandles(tag) 	
    local LinesCount = getLinesCount(tag) 	
    local c_num = num
    if ( num == nil or num==0 ) then
        c_num = CandleCount-1
    end
    if (num>0)then
        c_num = CandleCount-1-num
    end
    t, num, legend = getCandlesByIndex(tag, 0, c_num, 1)
    h=tostring(t[0].datetime.hour)
    m=tostring(t[0].datetime.min)
    s='00'
    if string.len(h)==1 then
        h='0'..h
    end
    if string.len(m)==1 then
        m='0'..m
    end    
    return h..m..s
end
function GetCandleDate(tag,num)
    local CandleCount = getNumCandles(tag) 	
    local LinesCount = getLinesCount(tag) 	
    local c_num = num
    if ( num == nil or num==0 ) then
        c_num = CandleCount-1
    end
    if (num>0)then
        c_num = CandleCount-1-num
    end
    t, num, legend = getCandlesByIndex(tag, 0, c_num, 1)
    y=tostring(t[0].datetime.year)
    m=tostring(t[0].datetime.month)
    d=tostring(t[0].datetime.day)
    if string.len(m)==1 then
        m='0'..m
    end
    if string.len(d)==1 then
        d='0'..d
    end    
    return y..m..d
end
   --[[ local t = ""
    local a = tostring(getInfoParam("SERVERTIME"))
        for s in a:gmatch('%d+') do
        t=t..s
    end
	local hour,min,sec = tonumber(string.sub(t, 1, 2)),tonumber(string.sub(t, 3, 4)),tonumber(string.sub(t, 5, 6))
    
    local result = hour*10000 + min*100 + sec
    return result
end]]

function orderflags2table(flags)
	local t={}
	if bit_set(flags, 0) then
		t.active=1
	else
		t.active = 0
	end
	if bit_set(flags,1) then
		t.cancelled=1
	elseif t.active==1 then
		t.done=1
		t.cancelled=0
	else
		t.done=0
		t.cancelled=0
	end
	if bit_set(flags, 2) then
		t.operation = "S"
	else
		t.operation = "B"
	end
	if bit_set(flags, 3) then
		t.limit=1
	else
		t.limit = 0
	end
	if t.cancelled==1 and t.done==1 then
		message("Erorr in orderflags2table order cancelled and done!",2)
	end
	return t
end

function bit_set( flags, index )	
    if (math.floor(flags/2^index)%2 == 1) then
        return true
    else 
        return false
    end

end

function CheckTime() --заготовка для роботов,    
    local Time=GetTime("cur")
    if (Time < 100100) or (Time >= 235100) or (Time > 135950 and Time < 140310) then
        return "N" 
    else
        if (Time >= 233000 and Time<235000) or (Time > 183900 and Time < 191000) then
            return "S"
        end
        if Time >= 100100 and Time < 233000 then
            return "T"
        end        
        return "N"        
    end
end

function val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table2string( v ) or
      tostring( v )
  end
end

function key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. val_to_str( k ) .. "]"
  end
end

function table2string( tbl )
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        key_to_str( k ) .. "=" .. val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

function existsFile(path) --проверка существует ли файл    
    local st, f = pcall(io.open, path)
    if st and f then
        f:close()
        return true
    else
	    return false
    end 
end

function SaveSettings() --сохраняет настройки в указанный файл
    
    local s = xml.new("Settings")
 
    s:append("Account")[1] = 0    
    s:append("ClientCode")[1] = 0       
    s:append("FirmId")[1] = 0      
    s:append("SecCode")[1] = 0    
    s:append("ClassCode")[1] = 0    
    s:append("TPOffset")[1] = 0         
    s:append("MaxOffset")[1] = 0 
    s:append("DefSpread")[1] = 0 
    s:append("Volume")[1] = 0  
    s:append("Mode")[1] = 0 
      
    message(botmessage.."saving settings",1)      
    xml.save(s, getScriptPath().."\\settings.xml")    	
end

function AnIndexOf(t,val) --возвращает индекс элемента из массива
    for k,v in ipairs(t) do 
        if v == val then return k end
    end
end

function LoadSettings(seccode)--грузит настройки из файла
    local xfile = xml.load(getScriptPath().."\\settings.xml")
    message(botmessage.."loading settings",1)
    local sec = xfile:find("Settings")
    local xscene = sec:find("Account")
    if xscene ~= nil then         
        Account=xscene[1]
    end
    xscene = sec:find("ClientCode")
    if xscene ~= nil then         
        ClientCode=xscene[1]
    end
    xscene = sec:find("FirmId")
    if xscene ~= nil then         
        FirmId=xscene[1]
    end
    xscene = sec:find("SecCode")
    if xscene ~= nil then         
        SecCode=xscene[1]
    end
    xscene = sec:find("ClassCode")
    if xscene ~= nil then         
        ClassCode=xscene[1]
    end    
    xscene = sec:find("TPOffset")
    if xscene ~= nil then         
        TPOffset=xscene[1]
    end
    xscene = sec:find("MaxOffset")
    if xscene ~= nil then         
        MaxOffset=xscene[1]
    end
    xscene = sec:find("DefSpread")
    if xscene ~= nil then         
        DefSpread=xscene[1]
    end 
    xscene = sec:find("Volume")
    if xscene ~= nil then         
        Volume=xscene[1]
    end
    xscene = sec:find("Mode")
    if xscene ~= nil then         
        Mode=tonumber(xscene[1])
    end 
    return Account,ClientCode,FirmId,SecCode,ClassCode,TPOffset,MaxOffset,DefSpread,Volume,Mode      	     
end

function GetRowFromTable(table_name,key,value)
	local i
	for i=getNumberOf(table_name)-1,0,-1 do
		if getItem(table_name,i)[key]==value then
			return getItem(table_name,i)
		end
	end
	return nil
end