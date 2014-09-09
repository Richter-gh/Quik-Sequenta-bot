package.path = getScriptPath().."\\Libraries\\?.lua;"
package.cpath=getWorkingFolder().."\\?.dll;"
SysFunc=require("SysFunc")
Graph=require("Graph")
Logging=require('Logging')
QuikTable=require("QuikTable")
Trading=require('Trading')
package.path = getWorkingFolder().."\\?.lua;"
tag='pattern_price'
t2t=QTable:new()
lp,sp={},{}
long,short=0,0
function Monitor()    
    Graph.delLabel(tag)
    local i=0
    while i<500 do
        --берем первую точку и проверяем, идя вправо: есть ли 9 подряд выполняющих условия
        for j=1,9 do
            if Graph.GetC(tag,i+j).close<Graph.GetC(tag,i+j+4).close then
                long=long+1
                lp[j]=i+j
            else
                long=0
                lp={}
                break
            end
        end
        if long>0 then
            i=i+long           
            Graph.addLabel(tag,"",getScriptPath().."\\Img\\down.jpg",Graph.GetC(tag,lp[1]).low,SysFunc.GetCandleDate(tag,lp[1]),SysFunc.GetCandleTime(tag,lp[1]),tostring(lp[1]),"BOTTOM") 
            long=0
            lp={}
        else
            i=i+1
        end
    end
    i=0
    while i<500 do
        --берем первую точку и проверяем, идя вправо: есть ли 9 подряд выполняющих условия
        for j=1,9 do
            if Graph.GetC(tag,i+j).close>Graph.GetC(tag,i+j+4).close then
                short=short+1
                sp[j]=i+j
            else
                short=0
                sp={}
                break
            end
        end
        if short>0 then
            i=i+short         
            Graph.addLabel(tag,"",getScriptPath().."\\Img\\up.jpg",Graph.GetC(tag,sp[1]).high,SysFunc.GetCandleDate(tag,sp[1]),SysFunc.GetCandleTime(tag,sp[1]),tostring(sp[1]),"TOP") 
            short=0
            sp={}
        else
            i=i+1
        end
    end           
        
             
end
                        
function OnStop()  
    is_run = false
    t2t:delete()
end

function OnInit()            
	t2t=QTable:new()
	t2t:AddColumn("время",QTABLE_STRING_TYPE,12)
	t2t:AddColumn("тип",QTABLE_STRING_TYPE,12)
	t2t:SetCaption("sequenta")	
	t2t:Show()
	is_run=true
end

function main()	
	while is_run do	    
	if Graph.GetC(tag,0).close==nil then
	sleep(10000)
	end
            Monitor()
            sleep(5000)
            
	end	
end 