function varExists=existsInGlobalScopeOfDataDictionary(varName,ddSpec)





    if isstring(varName)
        varName=convertStringsToChars(varName);
    end
    if strcmp(ddSpec,'<active>')
        ddSpec='';
    end
    if isempty(ddSpec)


        varExists=evalin('base',['exist(''',varName,''', ''var'');']);
    else
        ddConn=Simulink.dd.open(ddSpec);
        if(ddConn.isOpen)


            try
                if ddConn.entryExists(['Global.',varName],true)
                    varExists=1;
                else
                    varExists=0;
                end
            catch E
                if isequal(E.identifier,'SLDD:sldd:InvalidEntryName')
                    varExists=0;
                else
                    rethrow(E);
                end
            end
        end
    end
end