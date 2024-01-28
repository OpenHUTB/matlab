function hierarchies=mcosToAPIAdapter(identificationResultsMcos)
    hierarchies=cell(length(identificationResultsMcos),1);
    for hierarchyIndex=1:length(identificationResultsMcos)

        headNodePath=getfullname(identificationResultsMcos{hierarchyIndex}{1});
        hierarchyBlocks=Simulink.ModelTransform.BlockInfo.empty;
        hierarchyBlocks(1,1)=Simulink.ModelTransform.BlockInfo(headNodePath);

        for busBlockIndex=1:length(identificationResultsMcos{hierarchyIndex}{2})
            busBlockPath=getfullname(identificationResultsMcos{hierarchyIndex}{2}{busBlockIndex}{2});
            hierarchyBlocks(busBlockIndex+1,1)=Simulink.ModelTransform.BlockInfo(busBlockPath);
        end
        hierarchies{hierarchyIndex}=hierarchyBlocks;
    end
    hierarchies=hierarchies(~cellfun(@isempty,hierarchies));
end

