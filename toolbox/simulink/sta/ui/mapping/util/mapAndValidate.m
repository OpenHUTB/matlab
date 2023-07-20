function[inputMap,inportProps,dataProps,status,threwError,errMsg,diagnosticstruct]=mapAndValidate(...
    modelName,Signals,allowPartial,strongDatatyping,aInputSpec,compile,throwErrorToCaller,appID,varargin)
















    sigMapper=Simulink.inputmap.util.SignalMapper(modelName,Signals,...
    allowPartial,strongDatatyping,aInputSpec,compile);

    if~isempty(varargin)

        sigMapper.aSimulinkBuildUtility=varargin{1};

        if isfield(Signals,'DatasetID')
            sigMapper.aSimulinkBuildUtility.DatasetID=Signals.DatasetID;
        end

    end


    sigMapper.useWebDiagnostics=true;
    sigMapper.webAppInstanceID=appID;
    sigMapper.forceThrowError=throwErrorToCaller;

    [inputMap,inportProps,dataProps,...
    status,threwError,errMsg,diagnosticstruct]=sigMapper.map();




    for kInputMap=1:length(inputMap)
        inputMap(kInputMap).Status=status(kInputMap);
    end

    specManager=Simulink.sta.InputSpecManager.getInstance();
    addInputSpec(specManager,appID,sigMapper.aInputSpec);


