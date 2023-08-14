function pv=getSettingStrategies(ea,blkObj,pathItem,~)




    pv=SimulinkFixedPoint.EntityAutoscalerUtils.getSettingStrategies(ea,blkObj.getParent,pathItem,[]);
end