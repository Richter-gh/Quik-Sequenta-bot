module("Logging", package.seeall)

local SysFunc=require("SysFunc")
local filelog,filedebug
function Log(file,...)
	-- запись в лог параметра value
	-- value может быть числом, строкой или таблицей 
	-- file_path  -  путь к файлу
	-- файл открывается на дозапись и закрывается после записи строки
	if file~="" then filelog=file end
    lf=io.open(filelog,"a+")
    lf:write(SysFunc.GetTime()..": ")	
	if filelog~=nil then
		 for i,v in ipairs(arg) do		    
		    if lf~=nil then
			    if type(v)=="string" or type(v)=="number" then
				    if io.type(lf)~="file" then	lf=io.open(filelog,"a+") end
    				lf:write(v.." ")
			    elseif type(v)=='boolean' then
				    if io.type(lf)~="file" then	lf=io.open(filelog,"a+") end
    				lf:write(tostring(v).." ")
			    elseif type(v)=="table" then
				    if io.type(lf)~="file" then	lf=io.open(filelog,"a+") end
                    lf:write(SysFunc.table2string(v).." ")                                   
			    end			    			    
		    end
		end
	end
	lf:write("\n")
	lf:flush()
    if io.type(lf)=="file" then	lf:close() end
end
function TradeLog(file,...)
	-- запись в лог параметра value
	-- value может быть числом, строкой или таблицей 
	-- file_path  -  путь к файлу
	-- файл открывается на дозапись и закрывается после записи строки
	if file~="" then filelog=file end
    lf=io.open(filelog,"a+")	
	if filelog~=nil then
		 for i,v in ipairs(arg) do		    
		    if lf~=nil then
			    if type(v)=="string" or type(v)=="number" then
				    if io.type(lf)~="file" then	lf=io.open(filelog,"a+") end
    				lf:write(v)                                   
			    end			    			    
		    end
		end
	end
	lf:write("\n")
	lf:flush()
    if io.type(lf)=="file" then	lf:close() end
end
function GudLog(file,...)
	-- запись в лог параметра value
	-- value может быть числом, строкой или таблицей 
	-- file_path  -  путь к файлу
	-- файл открывается на дозапись и закрывается после записи строки
	if file~="" then filelog=file end
    lf=io.open(filelog,"w+")	
	if filelog~=nil then
		 for i,v in ipairs(arg) do		    
		    if lf~=nil then
			    if type(v)=="string" or type(v)=="number" then
				    if io.type(lf)~="file" then	lf=io.open(filelog,"w+") end
    				lf:write(v)                                   
			    end			    			    
		    end
		end
	end
	lf:write("\n")
	lf:flush()
    if io.type(lf)=="file" then	lf:close() end
end
function DebugLog(file,...)
	-- запись в лог параметра value
	-- value может быть числом, строкой или таблицей 
	-- file_path  -  путь к файлу
	-- файл открывается на дозапись и закрывается после записи строки
	if file~="" then filedebug=file end
    lf=io.open(filedebug,"a+")
    lf:write(SysFunc.GetTime()..": ")	
	if filedebug~=nil then
		 for i,v in ipairs(arg) do		    
		    if lf~=nil then
			    if type(v)=="string" or type(v)=="number" then
				    if io.type(lf)~="file" then	lf=io.open(filedebug,"a+") end
    				lf:write(v.." ")
			    elseif type(v)=='boolean' then
				    if io.type(lf)~="file" then	lf=io.open(filedebug,"a+") end
    				lf:write(tostring(v).." ")
			    elseif type(v)=="table" then
				    if io.type(lf)~="file" then	lf=io.open(filedebug,"a+") end
                    lf:write(SysFunc.table2string(v).." ")                                   
			    end			    			    
		    end
		end
	end
	lf:write("\n")
	lf:flush()
    if io.type(lf)=="file" then	lf:close() end
end
