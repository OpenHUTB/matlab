function save(this,saveAll)




    if nargin<2
        saveAll=false;
    end

    if this.isModelContext
        save_system(this.contextName);
    else
        if saveAll
            topDDConn=systemcomposer.internal.openSimulinkDataDictionary(this.contextName);
            saveDDAndReferences(topDDConn,{});
        else
            ddConn=systemcomposer.internal.openSimulinkDataDictionary(this.getContextName);
            ddConn.saveChanges();
        end
    end

end

function saveDDAndReferences(topDDConn,visitedDictionaries)
    if ismember(topDDConn.filepath,visitedDictionaries)
        return;
    end
    topDDConn.saveChanges();
    visitedDictionaries=[visitedDictionaries,topDDConn.filepath];
    dataSources=topDDConn.DataSources;
    for i=1:numel(dataSources)
        refDDConn=systemcomposer.internal.openSimulinkDataDictionary(dataSources{i});
        saveDDAndReferences(refDDConn,visitedDictionaries);
    end
end

