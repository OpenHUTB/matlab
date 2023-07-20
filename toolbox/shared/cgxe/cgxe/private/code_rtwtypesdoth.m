function code_rtwtypesdoth(modelName,targetDir)





    hardwareImp=rtwhostwordlengths();
    hardwareImpProps=rtw_host_implementation_props();
    fNames=fieldnames(hardwareImpProps);
    for i=1:length(fNames)
        hardwareImp.(fNames{i})=hardwareImpProps.(fNames{i});
    end
    hardwareImp.HWDeviceType='Generic->MATLAB Host Computer';

    hardwareDeploy=[];
    hardwareDeploy.CharNumBits=get_param(modelName,'ProdBitPerChar');
    hardwareDeploy.ShortNumBits=get_param(modelName,'ProdBitPerShort');
    hardwareDeploy.IntNumBits=get_param(modelName,'ProdBitPerInt');
    hardwareDeploy.LongNumBits=get_param(modelName,'ProdBitPerLong');
    hardwareDeploy.LongLongNumBits=get_param(modelName,'ProdBitPerLongLong');
    hardwareDeploy.LongLongMode=int32(strcmp(get_param(modelName,'ProdLongLongMode'),'on'));
    hardwareDeploy.FloatNumBits=hardwareImp.FloatNumBits;
    hardwareDeploy.DoubleNumBits=hardwareImp.DoubleNumBits;
    hardwareDeploy.PointerNumBits=hardwareImp.PointerNumBits;

    configInfo=coder.internal.BasicTypesConfig(...
    targetDir,...
    PurelyIntegerCode=false,...
    SupportComplex=true,...
    MaxMultiwordBits=1024);




    simulinkInfo=coder.internal.getCoderTypesSimulinkInfo...
    ('Style','full','IsERT',false);

    genRTWTYPESDOTH(hardwareImp,hardwareDeploy,configInfo,simulinkInfo);

    if strcmp(get_param(bdroot,'HasImageDataType'),'on')
        genIMAGETYPEDOTH(modelName,configInfo,simulinkInfo);
        genIMAGETYPEDOTC(modelName,configInfo,simulinkInfo);
    end
