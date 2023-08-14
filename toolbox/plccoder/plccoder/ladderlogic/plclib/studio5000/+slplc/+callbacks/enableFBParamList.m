function enableFBParamList(block)




    if slplc.utils.isRunningModelGeneration(block)
        return
    end

    simStatus=get_param(bdroot(block),'SimulationStatus');
    if~strcmpi(simStatus,'stopped')
        return
    end

    maskObj=Simulink.Mask.get(block);
    orderListParam=maskObj.getParameter('PLCFBParamOrderList');

    if strcmpi(get_param(block,'PLCFBParamOrder'),'Use the Order Defined by Parameter Order List')
        orderListParam.ReadOnly='off';
        orderListParam.Enabled='on';
    else
        orderListParam.ReadOnly='on';
        orderListParam.Enabled='off';
    end

end