function removeSLDVPassthroughBlocks(obj,sliceTransformer,sldvHandles)




    for idx=1:length(sldvHandles)
        ph=get(sldvHandles(idx),'PortHandles');
        if(get(ph.Outport,'Line')==-1)
            Transform.removeDisabledSys(sliceTransformer,...
            sldvHandles(idx));
        end
    end
end
