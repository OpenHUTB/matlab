function retVal=evalInGlobalScopeOfDataDictionary(exprToEval,ddSpec)

    retVal=[];
    if strcmp(ddSpec,'<active>')
        ddSpec='';
    end
    if isempty(ddSpec)
        retVal=evalin('base',exprToEval);
    else
        ddConn=Simulink.dd.open(ddSpec);
        if ddConn.isOpen
            ddObj=Simulink.data.dictionary.open(ddSpec);
            dDataSectObj=ddObj.getSection('Design Data');
            try %#ok<TRYNC>
                retVal=evalin(dDataSectObj,exprToEval);
            end
        end
    end
end
