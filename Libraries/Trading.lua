module("Trading", package.seeall)

local SysFunc=require("SysFunc")

function SendLimitOrder(ClassCode,SecCode,Operation,Price,Volume,Account,ClientCode,Comment)--[[
ставит в очередь лимитированную заявку по заданной цене
]]	
    if (ClassCode==nil or SecCode==nil or Operation==nil or Price==nil or Volume==nil or Account==nil) then
        return false,0,"qlib.SendLimitOrder(): Can`t send order. Nil parameters."
    end
    
    local transaction={
        ["TRANS_ID"]=tostring(math.random(2000000000)),
        ["ACTION"]="NEW_ORDER",
        ["CLASSCODE"]=ClassCode,
        ["SECCODE"]=SecCode,
        ["OPERATION"]=Operation,
        ["QUANTITY"]=tostring(Volume),
        ["PRICE"]=tostring(SysFunc.toPrice(SecCode,Price)),
        ["ACCOUNT"]=Account,
        ["EXECUTION_CONDITION"] = "PUT_IN_QUEUE"
    }
    if ClientCode==nil then
        transaction.client_code=Account
    else
        transaction.client_code=ClientCode
    end
    if Comment~=nil then
		transaction.client_code=ClientCode.."//"..Comment
	end
    local res=sendTransaction(transaction)
    if res~="" then
    message(res,1)
        return transaction["TRANS_ID"], "qlib.SendLimitOrder():"..res,res
    else
        return transaction["TRANS_ID"], "qlib.SendLimitOrder(): Limit order sent sucesfully. Class="..ClassCode.." Sec="..SecCode.." Dir="..Operation.." Price="..Price.." Vol="..Volume.." Acc="..Account,res
    end

end

function SendMarketOrder(ClassCode,SecCode,Operation,Volume,Account,ClientCode) --работает странно, лучше использовать предыдущую функцию
--[[SendMarketOrder(ClassCode,SecCode,"S",Volume,Account,ClientCode)
посылает рыночную заявку
]]	
	if (ClassCode==nil or SecCode==nil or Operation==nil  or Volume==nil or Account==nil) then
		return nil,"QL.sendMarket(): Can`t send order. Nil parameters."
	end	
	
	local transaction={
		["TRANS_ID"]=tostring(math.random(2000000000)),
		["ACTION"]="NEW_ORDER",
		["CLASSCODE"]=ClassCode,
		["SECCODE"]=SecCode,
		["OPERATION"]=Operation,
		["TYPE"]="M",
		["QUANTITY"]=tostring(Volume),
		["ACCOUNT"]=Account
	}
	
	if ClientCode==nil then
		transaction.client_code=Account
	else
		transaction.client_code=ClientCode
	end
	if string.find("SPBFUT",ClassCode)~=nil then
		if direction=="B" then
			transaction.price=getParamEx(class,security,"PRICEMAX").param_image
		else
			transaction.price=getParamEx(class,security,"PRICEMIN").param_image
		end
	else
		transaction.price="0"
	end
	if Comment~=nil then
		transaction.comment=string_sub(tostring(Comment),0,20)
	else
		transaction.comment='fuck'
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "qlib.sendMarket():"..res
	else
		return transaction["TRANS_ID"], "qlib.sendMarket(): Market order sended sucesfully. Class="..ClassCode.." Sec="..SecCode.." Dir="..Operation.." Vol="..Volume.." Acc="..Account
	end
end

function SendTPSLOrder(ClassCode,SecCode,Operation,Price,TP,SL,MaxOffset,DefSpread,Volume,Account,ClientCode)
--[[
посылает ТейкПрофит-СтопЛимит заявку
все параметры должны присутствовать
все значения округляются вниз, если не соответствуют шагу цены
]]
    if (ClassCode==nil or SecCode==nil or Operation==nil or Price==nil or Volume==nil or Account==nil or TP==nil or SL==nil or MaxOffset==nil or DefSpread==nil) then
        return false,0,"qlib.SendTPSLOrder(): Can`t send order. Nil parameters."
    end
    local StopLoss,TakeProfit=0,0

    
    if (Operation=="B") then
        StopLoss = SL
        TakeProfit = TP
        LimitPrice = SL + DefSpread
    end

    if (Operation=="S") then
        StopLoss = SL
        TakeProfit = TP
        LimitPrice = SL - DefSpread
    end
    TakeProfit,StopLoss,LimitPrice = RoundToStep(ClassCode,SecCode,TakeProfit),RoundToStep(ClassCode,SecCode,StopLoss),RoundToStep(ClassCode,SecCode,LimitPrice)
    local transaction={
        ["TRANS_ID"]=tostring(math.random(2000000000)),
        ["ACTION"]="NEW_STOP_ORDER",
        ["STOP_ORDER_KIND"]="TAKE_PROFIT_AND_STOP_LIMIT_ORDER",
        ["STOPPRICE"]=tostring(SysFunc.toPrice(SecCode,TakeProfit)),
        ["OFFSET"]=tostring(SysFunc.toPrice(SecCode,MaxOffset)),
        ["OFFSET_UNITS"]="PRICE_UNITS",
        ["SPREAD"]=tostring(SysFunc.toPrice(SecCode,DefSpread)),
        ["SPREAD_UNITS"]="PRICE_UNITS",
        ["MARKET_STOP_LIMIT"]="YES",
        ["MARKET_TAKE_PROFIT"]="YES",
        ["STOPPRICE2"]=tostring(SysFunc.toPrice(SecCode,StopLoss)),
        ["CLASSCODE"]=ClassCode,
        ["SECCODE"]=SecCode,
        ["OPERATION"]=Operation,
        ["QUANTITY"]=tostring(Volume),
        ["PRICE"]=tostring(SysFunc.toPrice(SecCode,LimitPrice)),
        ["ACCOUNT"]=Account,
        ["EXECUTION_CONDITION"] = "FILL_OR_KILL",
        ["EXPIRY_DATE"]="GTC",
    }
    if ClassCode=='QJSIM' then
    transaction["EXPIRY_DATE"]=tostring(SysFunc.GetDate())
    end
    if ClientCode==nil then
        transaction.client_code=Account
    else
        transaction.client_code=ClientCode
    end
    if Comment~=nil then
		transaction.comment=string_sub(tostring(Comment),0,20)
	else
		transaction.comment='fuck'
	end
    local res=sendTransaction(transaction)
    if res~="" then
    message(res,1)
        return transaction["TRANS_ID"], "qlib.SendTPSLOrder():"..res
    else
        return transaction["TRANS_ID"], "qlib.SendTPSLOrder(): TPSL order sended sucesfully. Class="..ClassCode.." Sec="..SecCode.." Dir="..Operation.." Price="..Price.." TakeProfit="..TakeProfit.." StopLoss="..StopLoss.." MaxOffset="..MaxOffset.." Trans_id="..transaction["TRANS_ID"]
    end

end


function MoveOrder(mode,firstnumber,firstprice,firstquantity)
	local order=SysFunc.GetRowFromTable("orders",'order_num',firstnumber)
    
	if order==nil then
		return nil,"MoveOrder(): Can`t find order number="..firstnumber.." in orders table!"
	end
	if getSecurityInfo("",order.sec_code).class_code=="SPBFUT" then
	    local transaction={}
        if (SysFunc.orderflags2table(order.flags).cancelled==1 or (SysFunc.orderflags2table(order.flags).done==1 and order.balance==0)) then
                return nil,"MoveOrder(): Can`t move cancelled or done order!"
        end                
        transaction["FIRST_ORDER_NUMBER"]=firstnumber
        transaction["FIRST_ORDER_NEW_PRICE"]=SysFunc.toPrice(order.sec_code,firstprice)
        transaction["FIRST_ORDER_NEW_QUANTITY"]="0"
        transaction["MODE"]="0"                          
        transaction["TRANS_ID"]=tostring(math.random(2000000000))
        transaction["CLASSCODE"]=getSecurityInfo("",SecCode).class_code
        transaction["SECCODE"]=order.sec_code
        transaction["ACTION"]="MOVE_ORDERS"
        local res=sendTransaction(transaction)
        if res~="" then
            Logging.DebugLog("","MoveOrder():order",order)
            Logging.DebugLog("","MoveOrder():transaction",transaction)
                return nil, "MoveOrder():"..res
        else
                return transaction["TRANS_ID"], "MoveOrder(): Move order sent sucesfully. Mode="..mode.." Number="..firstnumber.." Price="..firstprice
        end
    else
	    if (SysFunc.orderflags2table(order.flags).cancelled==1 or (SysFunc.orderflags2table(order.flags).done==1 and order.balance==0)) then
    		return nil,"MoveOrder(): Can`t move cancelled or done order!"
    	end	
        KillOrder(firstnumber,order.sec_code,getSecurityInfo("",order.sec_code).class_code)	    
    	a,b,c=SendLimitOrder(getSecurityInfo("",order.sec_code).class_code,order.sec_code,SysFunc.orderflags2table(order.flags).operation,firstprice,order.balance,order.account,order.client_code)	
    	if c~="" then 
	        Logging.DebugLog("","MoveOrder():order",order)
	        Logging.DebugLog("","MoveOrder():transaction",transaction)
		    return nil, "MoveOrder():"..c
	    else
    		return a, "MoveOrder(): Move order sent sucesfully. Mode="..mode.." Number="..firstnumber.." Price="..firstprice
    	end
    end
end
function KillOrder(orderkey,security,class)
	-- функция отмены лимитированной заявки по номеру
	-- принимает минимум 1 парамер
	-- ВАЖНО! Данная функция не гарантирует снятие заявки
	-- Возвращает сообщение сервера в случае ошибки выявленной сервером Квик либо строку с информацией о транзакции
	if orderkey==nil or tonumber(orderkey)==0 then
		return nil,"KillOrder(): Can`t kill order. OrderKey nil or zero"
	end

	
	local transaction={
		["TRANS_ID"]=tostring(math.random(2000000000)),
		["ACTION"]="KILL_ORDER",
		["ORDER_KEY"]=tostring(orderkey)
	}
	if security then
		transaction.seccode=security
		transaction.classcode=class or getSecurityInfo("",security).class_code
	else
		local order=SysFunc.GetRowFromTable("orders",'order_num',orderkey)
		if order==nil then return nil,"KillOrder(): Can`t kill order. No such order in Orders table." end
		transaction.classcode=order.class_code
		transaction.seccode=order.sec_code
	end
	--toLog("ko.txt",transaction)
	local res=sendTransaction(transaction)
	if res~="" then
		return nil,"KillOrder(): "..res
	else
		return transaction["TRANS_ID"],"KillOrder(): Limit order kill sended. Class="..transaction.classcode.." Sec="..transaction.seccode.." Key="..orderkey.." Trans_id="..transaction["TRANS_ID"]
	end
end
function KillStopOrder(orderkey,security,class)
	-- функция отмены стоп-заявки по номеру
	-- принимает минимум 1 парамер
	-- ВАЖНО! Данная функция не гарантирует снятие заявки
	-- Возвращает сообщение сервера в случае ошибки выявленной сервером Квик либо строку с информацией о транзакции
	if orderkey==nil or tonumber(orderkey)==0 then
		return nil,"KillStopOrder(): Can`t kill order. OrderKey nil or zero"
	end

	
	local transaction={
		["TRANS_ID"]=tostring(math.random(2000000000)),
		["ACTION"]="KILL_STOP_ORDER",
		["STOP_ORDER_KEY"]=tostring(orderkey)
	}
	if security==nil or class==nil then
		local order=SysFunc.GetRowFromTable("stop_orders",'order_num',orderkey)
		if order==nil then return nil,"KillStopOrder(): Can`t kill order. No such order in StopOrders table." end
		transaction.classcode=order.class_code
		transaction.seccode=order.sec_code
	else
		transaction.seccode=security
		transaction.classcode=class
	end
	--toLog("ko.txt",transaction)
	local res=sendTransaction(transaction)
	if res~="" then
		return nil,"KillStopOrder(): "..res
	else
		return transaction["TRANS_ID"],"KillStopOrder(): Stop-order kill sended. Class="..transaction.classcode.." Sec="..transaction.seccode.." Key="..orderkey.." Trans_id="..transaction["TRANS_ID"]
	end
end

function KillAllStops(ClassCode,SecCode)
--[[ 
данная функция отправит транзакции на отмену АКТИВНЫХ СТОПзаявок соответствующим
ClassCode и SecCode
]]
    local ord = "stop_orders"
    for i=0,getNumberOf(ord) do
        local t=getItem(ord, i)
		if t ~= nil and type(t) == "table" then
            if( t.seccode == SecCode and SysFunc.SysFunc.orderflags2table(t.flags).active == 1) then
                local transaction={
		            ["TRANS_ID"]=tostring(math.random(2000000000)),
		            ["ACTION"]="KILL_STOP_ORDER",
		            ["CLASSCODE"]=ClassCode,
		            ["SECCODE"]=SecCode,
		            ["STOP_ORDER_KEY"]=tostring(t.ordernum),
	            }
                local res=sendTransaction(transaction)
	            if res~="" then
		            return nil, "qlib.KillAllStops():"..res
	            else
		            return trans_id, res
	            end    
            end
        end
    end	
   
end

function KillAllOrders(ClassCode,SecCode)
--[[ 
данная функция отправит транзакции на отмену АКТИВНЫХ заявок соответствующим
ClassCode и SecCode
]]
    local ord = "orders"
    for i=0,getNumberOf(ord) do
        local t=getItem(ord, i)
		if t ~= nil and type(t) == "table" then
            if( t.seccode == SecCode and SysFunc.SysFunc.orderflags2table(t.flags).active == 1) then
                local transaction={
		            ["TRANS_ID"]=tostring(math.random(2000000000)),
		            ["ACTION"]="KILL_ORDER",
		            ["CLASSCODE"]=ClassCode,
		            ["SECCODE"]=SecCode,
		            ["ORDER_KEY"]=tostring(t.ordernum),
	            }
                local res=sendTransaction(transaction)	            
            end
        end
    end	
end

function GetLastOrder(SecCode) --в принципе не нужна
    local ord = "trades"
    for i=getNumberOf(ord),0,-1 do
        local t=getItem(ord, i)
		if t ~= nil and type(t) == "table" then
            if( t.seccode == SecCode) then
                return t
            end
        end
    end	
    return 0
end

function RoundToStep(ClassCode,SecCode,val)
--[[ 
округляет значение val до шага цены SecCode инструмента
округляет вниз
]]  
    if (ClassCode == nil or SecCode == nil or val == nil) then
        message("qlib.RoundToStep(): error occured, one of parameters is nil",3)
        return 0
    end
    local t = getParamEx(ClassCode,SecCode,"SEC_PRICE_STEP")
    local st=t.param_value
    if st==0 then
        message("qlib.RoundToStep(): step=0",3)
    end
    if st~=0 then
        return math.floor(val / st)*st
    end

end

function GetBoughtCount(SecCode)
--[[
возвращает текущую чистую позицию по SecCode бумаге
]]
    local ClassCode=getSecurityInfo("",SecCode).class_code
    if ClassCode=="SPBFUT" then
        local fch = "futures_client_holding"
        for i=0,getNumberOf(fch) do
            local t=getItem(fch, i)
		    if t ~= nil and type(t) == "table" then
                if( t.seccode == SecCode) then
                    if t.totalnet==nil then 
                        return 0 
                    else
                        return t.totalnet
                    end
                end
            end
        end
    else
        for i=0,getNumberOf("depo_limits") do
			local row=getItem("depo_limits",i)
			--toLog(log,row)
			if row~=nil and row['sec_code']==SecCode then
				if row.currentbal==nil then
					return 0
				else
					return tonumber(row.currentbal)
				end
			end
		end
	end
    return 0
end

function GetMargin(SecCode)
--[[
возвращает маржу по SecCode бумаге
значение берется из клиентской таблицы, потому что мне лень считать.
в настройках квика можно поставить обновление этой таблицы каждую секунду
]] 
    local fch = "futures_client_holding"    
    for i=0,getNumberOf(fch) do
        local t=getItem(fch, i)
		if t ~= nil and type(t) == "table" then
            if( t.seccode == SecCode) then
                if t.varmargin==nil then 
                    return 0 
                else
                    return t.varmargin
                end
            end
        end
    end
    return 0 
end 

function GetStopCount(SecCode)
--[[
возвращает количество стоп-заявок по SecCode бумаге
]]
    local count=0
    local fch = "stop_orders"
    for i=0,getNumberOf(fch) do
        local t=getItem(fch, i)
		if t ~= nil and type(t) == "table" then
            if( SysFunc.SysFunc.orderflags2table(t.flags).active == 1) then
                count=count+1
            end
        end
    end
    return count    
end
