function refreshCreateStateflowChartBehaviorTool(cbinfo,action)




    enabled=false;
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if isvalid(action)&&SLStudio.Utils.objectIsValidBlock(block)&&license('test','Stateflow')&&dig.isProductInstalled('Stateflow')
        enabled=systemcomposer.internal.validator.ConversionUIValidator.canCreateStateflowBehavior(block.handle);
    end
    action.enabled=enabled;
end
