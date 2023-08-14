function[sldvData,sampleTimeInformation]=generateDataForLogging(obj)

    modelBlockH=obj.ModelBlockH;
    obj.deriveRefMdlPortInfo();
    subsystemIO=obj.subsystemIO;
    referencedModelName=get_param(modelBlockH,'ModelName');
    refmodelH=get_param(referencedModelName,'Handle');

    ReferencedModel.Name=referencedModelName;
    ReferencedModel.Version=get_param(refmodelH,'ModelVersion');
    ReferencedModel.Author=get_param(refmodelH,'Creator');
    ReferencedModel.InputPortInfo=subsystemIO.InputPortInfo;
    ReferencedModel.OutputPortInfo=subsystemIO.OutputPortInfo;
    ReferencedModel.SampleTimes=subsystemIO.flatInfo.SampleTimes;
    sampleTimeInformation=subsystemIO.flatInfo.ModelSampleTimesDetails;

    ModelBlock.Path=getfullname(modelBlockH);
    ModelBlock.ReferencedModel=ReferencedModel;

    LoggedTestUnitInfo.ModelBlock=ModelBlock;


    parentModelName=get_param(bdroot(modelBlockH),'Name');
    parentModelHandle=get_param(parentModelName,'Handle');

    defaultTestCase=Sldv.DataUtils.createDefaultTC(...
    parentModelHandle,subsystemIO.flatInfo.InportCompInfo,true);
    sldvData.LoggedTestUnitInfo=LoggedTestUnitInfo;
    sldvData.TestCases=defaultTestCase;
end