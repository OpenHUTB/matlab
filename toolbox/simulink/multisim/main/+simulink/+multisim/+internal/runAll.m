function runAll(modelHandle)




    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    bdData=Simulink.BlockDiagramAssociatedData.get(modelHandle,dataId);
    designSession=bdData.SessionDataModel.topLevelElements;
    designSuiteData=bdData.DesignSuiteMap(designSession.ActiveDesignSuiteUUID);
    activeDesignSuite=designSuiteData.DesignSuite;

    simulink.multisim.internal.utils.Session.refreshNumSims(bdData.SessionDataModel,...
    designSession,modelHandle);

    simulink.multisim.internal.utils.DesignSuite.runAll(modelHandle,activeDesignSuite);
end