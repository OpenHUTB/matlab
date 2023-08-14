function saveObj(obj)




    fileName=fullfile(obj.getOutputDir(),obj.saveFileName);
    fullFileName=cvi.ReportUtils.appendFileExtAndPath(fileName,'.cvr');
    outputDir=obj.getOutputDir();
    if~isempty(outputDir)&&~exist(outputDir,'dir')
        return;
    else
        [succ,userWrite]=cvi.ReportUtils.checkUserWrite(outputDir);
        if~succ||~userWrite
            return;

        end
    end
    allKeys=obj.maps.uniqueIdMap.keys;
    var.data=[];
    saveFilter(obj,obj.filterEditor.fileName);

    obj.filterEditor.needSave=false;
    if~isempty(obj.filterExplorer)
        var.filterFileName=obj.filterExplorer.getAllFilterFiles();
    else
        var.filterFileName=obj.filterEditor.fileName;
    end
    if~isempty(allKeys)
        data=obj.maps.uniqueIdMap(allKeys{1});
        allData(1)=data.getSaveData;
        for idx=2:numel(allKeys)
            data=obj.maps.uniqueIdMap(allKeys{idx});
            allData(end+1)=data.getSaveData;%#ok<AGROW>
        end
        var.data=allData;
    end

    allChildren=obj.root.passiveTree.root.children;
    var.nodes=[];
    for idx=1:numel(allChildren)
        node=allChildren{idx};
        snode.dataId=[];
        if~isempty(node.data)
            snode.dataId=node.data.uniqueId;
        end
        snode.childDataIds=[];
        for idxc=1:numel(node.children)
            snode.childDataIds=[snode.childDataIds,{node.children{idxc}.data.uniqueId}];
        end
        if isempty(var.nodes)
            var.nodes=snode;
        else
            var.nodes(end+1)=snode;
        end
    end


    var.chesksumMap=[];
    if~isempty(obj.maps.checksumMap)
        allChk={};
        for idx=1:numel(obj.maps.checksumMap)
            entry=obj.maps.checksumMap(idx);
            allChk{end+1}={entry.key,entry.checksum,entry.modelName,entry.dbVersion};%#ok<AGROW>
        end
        var.chesksumMap=allChk;
    end
    var.version=SlCov.CoverageAPI.getVersion;
    save(fullFileName,'-struct','var');
end


