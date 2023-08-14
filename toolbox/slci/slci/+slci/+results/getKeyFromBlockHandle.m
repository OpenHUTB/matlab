



function aKey=getKeyFromBlockHandle(blkH)

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    assert(strcmpi(get_param(blkH,'Type'),'Block'),...
    'Input argument must be a block handle');
    object=get_param(blkH,'Object');
    if object.isSynthesized


        aKey=sprintf('%10.10f',blkH);
    elseif slci.internal.isStateflowBasedBlock(blkH)&&...
        ~slci.internal.isUnsupportedStateflowBlock(blkH)

        chartId=sfprivate('block2chart',blkH);
        chartUDDObj=idToHandle(sfroot,chartId);
        chartSID=Simulink.ID.getStateflowSID(chartUDDObj,blkH);


        aKey=Simulink.ID.getSID(get_param(chartSID,'handle'));
    else


        aKey=Simulink.ID.getSID(blkH);
    end
