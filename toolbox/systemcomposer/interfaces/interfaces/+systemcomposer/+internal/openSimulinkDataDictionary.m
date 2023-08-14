function ddConn=openSimulinkDataDictionary(dictionaryName)




    persistent p
    if isempty(p)
        p=inputParser;
        addRequired(p,'dictionaryName',@(x)ischar(x)||(isstring(x)&&(numel(x)==1)));
    end
    parse(p,dictionaryName);

    if(ischar(dictionaryName))
        dictionaryName=string(dictionaryName);
    end
    if(~endsWith(dictionaryName,".sldd"))
        dictionaryName=dictionaryName+".sldd";
    end

    ddConn=Simulink.data.dictionary.open(dictionaryName);

end
