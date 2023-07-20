function applyProposedScaling(h,blkObj,pathItem,proposedDT)





    pv=h.getSettingStrategies(blkObj,pathItem,proposedDT);


    SimulinkFixedPoint.EntityAutoscalerUtils.setDataType(pv,proposedDT);
end