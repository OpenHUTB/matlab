function removeSymbol(hThisObj,requestName)




    oldList=hThisObj.MPFSymbolDefinition;
    symbols={};
    for i=1:length(oldList)
        symbols{end+1}=oldList{i}.Name;
    end

    [sym,idx]=intersect(symbols,requestName);
    if isempty(sym)
        MSLDiagnostic('Simulink:mpt:MPTMiscRegSymbol',requestName).reportAsWarning;
    else
        try

            newList={};
            for i=1:idx-1
                newList{end+1}=oldList{i};
            end
            for i=(idx+1):length(oldList)
                newList{end+1}=oldList{i};
            end
            hThisObj.MPFSymbolDefinition=newList;
        catch ME
            MSLDiagnostic('Simulink:mpt:MPTSLGenMsg',ME.message).reportAsWarning;
        end
    end
