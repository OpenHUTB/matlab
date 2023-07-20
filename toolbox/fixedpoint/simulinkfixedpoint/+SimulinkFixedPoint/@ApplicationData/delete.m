function delete(this)




    repository=fxptds.FPTRepository.getInstance();
    if this.dataset.isvalid
        datasetSourceName=this.dataset.getSource;
        this.dataset.delete;
        repository.removeDatasetForSource(datasetSourceName);
    end

    allKeys=this.subDatasetMap.keys;
    for idx=1:length(allKeys)
        locSubdata=this.subDatasetMap(allKeys{idx});
        if locSubdata.isvalid
            datasetSourceName=locSubdata.getSource;
            locSubdata.delete;
            repository.removeDatasetForSource(datasetSourceName);
        end
        this.subDatasetMap.remove(allKeys{idx});
    end

end