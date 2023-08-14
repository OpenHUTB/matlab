




function out=getMaskBlock(blkHandle)

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    out=[];

    if slci.internal.isMasked(blkHandle)
        out=blkHandle;
        return;
    end

    try
        blockObject=get_param(blkHandle,'Object');

        if(strcmpi(blockObject.Type,'block_diagram'))
            return;
        end
        out=slci.internal.getMaskBlock(blockObject.Parent);
    catch



        out=[];
    end
end
