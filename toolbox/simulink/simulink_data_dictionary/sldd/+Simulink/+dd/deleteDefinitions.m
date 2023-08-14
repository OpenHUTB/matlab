function deleteDefinitions(dataSources,entryIds,entryName)








    assert(iscell(dataSources));
    assert(isnumeric(entryIds));
    assert(length(dataSources)==length(entryIds));
    assert(ischar(entryName));

    for i=1:length(dataSources)
        if(strcmp(dataSources{i},'base workspace'))
            if evalin('base',['exist(''',entryName,''')'])
                evalin('base',['clear ',entryName,';']);
            end
        else
            if loc_isVarInDD(dataSources{i},entryIds(i))
                ddConnect=Simulink.dd.open(dataSources{i});
                ddConnect.deleteEntry(entryIds(i));
                ddConnect.close;
            end
        end
    end

end


function isInDD=loc_isVarInDD(ddSpec,entryId)
    isInDD=false;
    try
        ddConnect=Simulink.dd.open(ddSpec);
        ddConnect.getEntryInfo(entryId);
        ddConnect.close();

        isInDD=true;
    catch err
        if strcmp(err.identifier,'SLDD:sldd:EntryNotFound')
            isInDD=false;
        else
            error(err.message);
        end
    end
end
