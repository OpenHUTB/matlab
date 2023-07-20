function out=transform(in)





    instanceData=in.InstanceData;
    blkVersion=get_param(gcb,'LibraryVersion');
    targetVersion=in.ForwardingTableEntry.('__slNewVersion__');
    if(targetVersion=='0.0')
        targetVersion.ModelVersion='inf.inf';
    end

    [newComponentData,newBlockPath]=transformComponentInstanceData(...
    instanceData,blkVersion,targetVersion.ModelVersion,in.ForwardingTableEntry.('__slNewName__'));

    commonBlockData=lApplyCommonSettings(instanceData);
    out.NewInstanceData=[newComponentData,commonBlockData];

    if isempty(newBlockPath)
        out.NewBlockPath=in.ForwardingTableEntry.('__slOldName__');
    else
        out.NewBlockPath=newBlockPath;
    end

end

function blockData=lApplyCommonSettings(oldInstanceData)



    blockData=[];
    allNames={oldInstanceData.Name};
    commonProperties={'LogSimulationData'};
    for idx=1:numel(commonProperties)
        isProp=strcmp(commonProperties{idx},allNames);
        if nnz(isProp)>1
            isProp=find(isProp,1);
        end
        if~isempty(isProp)
            blockData=[blockData,oldInstanceData(isProp)];%#ok<AGROW>
        end
    end

end