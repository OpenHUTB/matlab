function setDesignSuiteBdData(modelHandle,designSession,designSuiteDataModel,designSuite)

    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    bdData=Simulink.BlockDiagramAssociatedData.get(modelHandle,dataId);

    designSuiteDataModelSynchronizer=simulink.multisim.internal.DataModelSynchronizer(designSuiteDataModel);
    designSuiteCommandChannelName=designSuiteDataModelSynchronizer.ChannelName+"/command";
    designSuite.CommandChannelName=designSuiteCommandChannelName;
    designSuiteCommandDispatcher=simulink.multisim.internal.CommandDispatcher(designSuiteCommandChannelName,designSuiteDataModel,designSession.ModelHandle);

    designSuiteData=struct("DataModel",designSuiteDataModel,...
    "DesignSuite",designSuite,...
    "DataModelSynchronizer",designSuiteDataModelSynchronizer,...
    "CommandDispatcher",designSuiteCommandDispatcher);

    bdData.DesignSuiteMap(designSuiteDataModel.UUID)=designSuiteData;
    Simulink.BlockDiagramAssociatedData.set(modelHandle,dataId,bdData);
end