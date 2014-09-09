module("Graph", package.seeall)

function addLabel(tag,text,img,value,date,time,hint,al)
    para={TEXT=text,IMAGE_PATH=img,ALIGNMENT=al,YVALUE=value,DATE=tostring(date),TIME=tostring(time),TRANSPARENCY=0,TRANSPARENT_BACKGROUND=0,FONT_FACE_NAME="Arial",FONT_HEIGHT=12,HINT=hint}    
    para.R=0
    para.G=0
    para.B=0
    AddLabel(tag,para)
end
function delLabel(tag)
    DelAllLabels(tag)
end
function GetGraphValueByCandle(tag, candle_num, line)
--[[
tag - тэг графика\индикатора, candle_num - номер запрашиваемой свечи(СПРАВА)
пример: 0 - текущая свеча, 1 - предыдущая итд, line - номер линии графика\индикатора

функция возвращает свечу запрашиваемого номера, то есть таблицу
]]
    local CandleCount = getNumCandles(tag) 	
    local LinesCount = getLinesCount(tag) 	
    local c_num = candle_num
    if ( candle_num == nil or candle_num==0 ) then
        c_num = CandleCount-1
    end
    if (candle_num>0)then
        c_num = CandleCount-1-candle_num
    end    
    if ( line == nil ) then
        line = 0
    end
    if (CandleCount == nil or LinesCount == nil) then
        message("qlib.GetGraphValueByCandle("..tag..","..candle_num..","..line.."): error occured, cannot aqquire candle or line data",3)
        return 0
    end
    if (tag == nil) then
        message("qlib.GetGraphValueByCandle("..tag..","..candle_num..","..line.."): error occured, tag is nil",3)
        return 0
    end   
    t, num, legend = getCandlesByIndex(tag, line, c_num, 1)    
    if ( num == 0 ) then
        message("qlib.GetGraphValueByCandle("..tag..","..candle_num..","..line.."): error occured, no candles aqquired",3)
        return 0
    end
    if t[0].datetime.hour==9 then
        return 0
    end
    return t[0]
end

function GetC(tag, candle_num)
--[[
tag - тэг графика\индикатора, candle_num - номер запрашиваемой свечи(СПРАВА)
пример: 0 - текущая свеча, 1 - предыдущая итд, line - номер линии графика\индикатора

функция возвращает свечу запрашиваемого номера, то есть таблицу
]]
    local CandleCount = getNumCandles(tag) 	
    local LinesCount = getLinesCount(tag) 	
    local c_num = candle_num
    if ( candle_num == nil or candle_num==0 ) then
        c_num = CandleCount-1
    end
    if (candle_num>0)then
        c_num = CandleCount-1-candle_num
    end    
    line=0
    if (CandleCount == nil or LinesCount == nil) then
        message("qlib.GetGraphValueByCandle("..tag..","..candle_num..","..line.."): error occured, cannot aqquire candle or line data",3)
        return 0
    end
    if (tag == nil) then
        message("qlib.GetGraphValueByCandle("..tag..","..candle_num..","..line.."): error occured, tag is nil",3)
        return 0
    end   
    t, num, legend = getCandlesByIndex(tag, line, c_num, 1)    
    if ( num == 0 ) then
        message("qlib.GetGraphValueByCandle("..tag..","..candle_num..","..line.."): error occured, no candles aqquired",3)
        return 0
    end
    
    return t[0]
end
function GetC2(tag, candle_num)
--[[
tag - тэг графика\индикатора, candle_num - номер запрашиваемой свечи(СПРАВА)
пример: 0 - текущая свеча, 1 - предыдущая итд, line - номер линии графика\индикатора

функция возвращает свечу запрашиваемого номера, то есть таблицу
]]
    local CandleCount = getNumCandles(tag) 	
    local LinesCount = getLinesCount(tag) 	
    local c_num = candle_num       
    line=0
    if (CandleCount == nil or LinesCount == nil) then
        message("qlib.GetGraphValueByCandle("..tag..","..candle_num..","..line.."): error occured, cannot aqquire candle or line data",3)
        return 0
    end
    if (tag == nil) then
        message("qlib.GetGraphValueByCandle("..tag..","..candle_num..","..line.."): error occured, tag is nil",3)
        return 0
    end   
    t, num, legend = getCandlesByIndex(tag, line, c_num, 1)    
    if ( num == 0 ) then
        message("qlib.GetGraphValueByCandle("..tag..","..candle_num..","..line.."): error occured, no candles aqquired",3)
        return 0
    end
    
    return t[0]
end

function FindMax(tag,line,num)
    if num then
        local tmp=0
        while tmp~=1 do
            if (GetGraphValueByCandle(tag,num+1,line).close > GetGraphValueByCandle(tag,num,line).close) and
                 (GetGraphValueByCandle(tag,num+2,line).close < GetGraphValueByCandle(tag,num+1,line).close) then
                tmp=1
            else num=num+1
            end
        end
    end
    return num+1 
end
function FindMin(tag,line,num)
    if num then
        local tmp=0
        while tmp~=1 do
            if (GetGraphValueByCandle(tag,num+1,line).close < GetGraphValueByCandle(tag,num,line).close) and
                 (GetGraphValueByCandle(tag,num+2,line).close > GetGraphValueByCandle(tag,num+1,line).close) then
                tmp=1
            else num=num+1
            end
        end
    end
    return num+1  
end
function GraphTurnDown(tag,line)
    if (GetGraphValueByCandle(tag,1,line).close > GetGraphValueByCandle(tag,0,line).close) and
        (GetGraphValueByCandle(tag,2,line).close < GetGraphValueByCandle(tag,1,line).close) then
        return true
    else 
        return false
    end
end

function GraphTurnUp(tag,line)
    if (GetGraphValueByCandle(tag,1,line).close < GetGraphValueByCandle(tag,0,line).close) and
        (GetGraphValueByCandle(tag,2,line).close > GetGraphValueByCandle(tag,1,line).close) then
        return true
    else 
        return false
    end
end

function GraphGrow(tag,line,num)
    if num then
        local tmp=0
        for i=0,num-1 do
            if GetGraphValueByCandle(tag,i+1,line).close < GetGraphValueByCandle(tag,i,line).close then
                tmp=1
            else return false
            end
        end
        if tmp==1 then
            return true
        end
    else
        if GetGraphValueByCandle(tag,0,line).close > GetGraphValueByCandle(tag,1,line).close then
            return true
        end
    end
    return false        
end

function GraphReduce(tag,line,num)
    if num then
        local tmp=0
        for i=0,num-1 do
            if GetGraphValueByCandle(tag,i+1,line).close > GetGraphValueByCandle(tag,i,line).close then
                tmp=1
            else return false
            end
        end
        if tmp==1 then
            return true
        end
    else
        if GetGraphValueByCandle(tag,0,line).close < GetGraphValueByCandle(tag,1,line).close then       
            return true
        end
    end
    return false
end

function ZigZag(tag,line,num)
    if num then
        local tmp=0
        for i=0,num-1 do
            if (GetGraphValueByCandle(tag,i,line).close < GetGraphValueByCandle(tag,i+1,line).close and GetGraphValueByCandle(tag,i+1,line).close > GetGraphValueByCandle(tag,i+2,line).close) or 
            (GetGraphValueByCandle(tag,i,line).close > GetGraphValueByCandle(tag,i+1,line).close and GetGraphValueByCandle(tag,i+1,line).close < GetGraphValueByCandle(tag,i+2,line).close) then       
                tmp=1
            else return false
            end
        end
        if tmp==1 then
            return true
        end
    else
        if (GetGraphValueByCandle(tag,0,line).close < GetGraphValueByCandle(tag,1,line).close and GetGraphValueByCandle(tag,1,line).close > GetGraphValueByCandle(tag,2,line).close) or 
            (GetGraphValueByCandle(tag,0,line).close > GetGraphValueByCandle(tag,1,line).close and GetGraphValueByCandle(tag,1,line).close < GetGraphValueByCandle(tag,2,line).close) then       
            return true
        end
    end
    return false
end

function Flat(tag,line,num)
    if num then
        local tmp=0
        for i=0,num-1 do
            if GetGraphValueByCandle(tag,i+1,line).close == GetGraphValueByCandle(tag,i,line).close then
                tmp=1
            else return false
            end
        end
        if tmp==1 then
            return true
        end
    else
        if GetGraphValueByCandle(tag,0,line).close == GetGraphValueByCandle(tag,1,line).close then       
            return true
        end
    end
    return false
end

function GraphOver(tag1,line1,frame1,tag2,line2,frame2)
    if (GetGraphValueByCandle(tag1,frame1,line1).close > GetGraphValueByCandle(tag2,frame2,line2).close) then
        return true
    else 
        return false
    end
end
function GraphUnder(tag1,line1,frame1,tag2,line2,frame2)
    if (GetGraphValueByCandle(tag1,frame1,line1).close < GetGraphValueByCandle(tag2,frame2,line2).close) then
        return true
    else 
        return false
    end
end

function GraphCrossUp(tag1,line1,tag2,line2)
    if (GetGraphValueByCandle(tag1,0,line1).close > GetGraphValueByCandle(tag2,0,line2).close) and
        (GetGraphValueByCandle(tag1,1,line1).close <= GetGraphValueByCandle(tag2,1,line2).close) then
        return true
    else 
        return false
    end
end

function GraphCrossDown(tag1,line1,tag2,line2)
    if (GetGraphValueByCandle(tag1,0,line1).close < GetGraphValueByCandle(tag2,0,line2).close) and
        (GetGraphValueByCandle(tag1,1,line1).close >= GetGraphValueByCandle(tag2,1,line2).close) then
        return true
    else 
        return false
    end
end
