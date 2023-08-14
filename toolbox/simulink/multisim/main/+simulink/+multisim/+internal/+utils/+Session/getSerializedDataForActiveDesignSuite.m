function serializedData=getSerializedDataForActiveDesignSuite(modelHandle,designSession)
    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
    bdData=Simulink.BlockDiagramAssociatedData.get(modelHandle,dataId);
    designSuite=bdData.DesignSuiteMap(designSession.ActiveDesignSuiteUUID);
    xmlSerializer=mf.zero.io.XmlSerializer();
    xmlString=xmlSerializer.serializeToString(designSuite.DataModel);

    partData=simulink.simmanager.PartData(xmlString);
    partData.ContentType='application/vnd.mathworks.matlab.data-export+xml';
    partData.PartExtension='.xml';

    modelName=get_param(modelHandle,"Name");
    modelNamePartData=simulink.simmanager.PartData(modelName);

    serializedData=struct("DesignSuite",partData,...
    "ModelName",modelNamePartData);
end