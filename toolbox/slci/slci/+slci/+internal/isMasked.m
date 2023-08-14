


function out=isMasked(blkHandle)


    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    blockObject=get_param(blkHandle,'Object');

    out=isa(blockObject,'Simulink.Block')&&strcmpi(blockObject.Mask,'on');

end

