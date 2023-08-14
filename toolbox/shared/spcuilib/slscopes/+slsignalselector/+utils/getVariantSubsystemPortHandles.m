function variantSSPortHandles=getVariantSubsystemPortHandles(selectionHandles)








    variantSSPortHandles=selectionHandles;


    blockHandles=selectionHandles(arrayfun(@(x)strcmp(get_param(x,'Type'),'block'),selectionHandles));

    if isempty(blockHandles)
        return
    end

    parents=get_param(blockHandles,'Parent');
    if~iscell(parents)
        parents={parents};
    end


    variantSSIndex=cellfun(@(blockParent)~isempty(blockParent)&&...
    strcmp(get_param(blockParent,'Type'),'block')&&...
    strcmp(get_param(blockParent,'BlockType'),'SubSystem')&&...
    strcmp(get_param(blockParent,'Variant'),'on'),parents);

    variantBlocks=blockHandles(variantSSIndex);


    if~isempty(variantBlocks)
        blockHasPorts=arrayfun(@(x)isfield(get_param(x,'ObjectParameters'),'PortHandles'),variantBlocks);
        variantBlocks=variantBlocks(blockHasPorts);

        blockPorts=arrayfun(@(x)get_param(x,'PortHandles'),variantBlocks);
        outportHandles=arrayfun(@(x)x.Outport,blockPorts,'UniformOutput',false);
        outportHandles=[outportHandles{:}];
        variantSSPortHandles=union(selectionHandles,outportHandles);
    end

end