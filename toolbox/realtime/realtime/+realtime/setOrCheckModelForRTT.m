function ret=setOrCheckModelForRTT(cs,action)





    ret=true;

    modelName=cs.getModel;
    targetExtensionPlatform=get_param(cs,'TargetExtensionPlatform');
    dataFile=realtime.getDataFileName('targetInfo',targetExtensionPlatform);
    targetInfo=realtime.TargetInfo(dataFile,targetExtensionPlatform,modelName);
    rttparams=i_getDefaultRTTParams;
    rttparams=i_updateRTTParamsForTarget(rttparams,targetInfo);


    if strcmp(action,'check')&&strcmp(get_param(cs,'ExtMode'),'off')&&...
        isfield(rttparams,'ExtModeTransport')
        rttparams=rmfield(rttparams,'ExtModeTransport');
    end



    if isequal(action,'check')&&~isequal(get_param(cs,'SolverType'),'Variable-step')...
        &&isequal(get_param(cs,'SampleTimeConstraint'),'STIndependent')...
        &&isfield(rttparams,'SolverMode')
        rttparams=rmfield(rttparams,'SolverMode');
    end


    fnames=fieldnames(rttparams);
    if isequal(action,'set')
        for i=1:length(fnames)
            paramName=fnames{i};
            set_param(cs,paramName,rttparams.(paramName).defaultValue);
        end
        a=get_param(cs.getModel,'CodeCoverageSettings');
        if~isempty(a)
            a.CoverageTool='None';
            set_param(cs.getModel,'CodeCoverageSettings',a);
        end
        set_param(cs,'SolverPrmCheckMsg','none');
        set_param(cs,'ProdHWDeviceType',targetInfo.ProdHWDeviceType);
    else
        ret=isequal(get_param(cs,'SystemTargetFile'),'realtime.tlc');
        for i=1:length(fnames)
            if~ret,break,end
            paramName=fnames{i};
            modelParamVal=get_param(cs,paramName);





            if~iscell(rttparams.(paramName).allowedValues)
                ret=ret&&isequal(modelParamVal,rttparams.(paramName).defaultValue);
            else
                if ischar(modelParamVal)
                    ret=ret&&ismember(modelParamVal,rttparams.(paramName).allowedValues);
                else



                    found=zeros(1,length(rttparams.(paramName).allowedValues));
                    for i=1:length(rttparams.(paramName).allowedValues)%#ok
                        found(1,i)=ismember(modelParamVal,rttparams.(paramName).allowedValues{i});
                    end
                    ret=ret&&any(found);
                end

            end
        end
        a=get_param(cs.getModel,'CodeCoverageSettings');
        if~isempty(a)
            ret=ret&&isequal(a.CoverageTool,'None');
        end
        hwDevice=get_param(cs,'ProdHWDeviceType');
        ret=ret&&isequal(hwDevice,targetInfo.ProdHWDeviceType);
    end
end


function rttparams=i_updateRTTParamsForTarget(rttparams,targetInfo)

    if ismember('RTTParams',properties(targetInfo))
        targetRTTParams=targetInfo.RTTParams;
        for i=1:size(targetRTTParams,1)
            rttparams.(targetRTTParams{i,1}).defaultValue=targetRTTParams{i,2};
            rttparams.(targetRTTParams{i,1}).allowedValues=targetRTTParams{i,3};
        end
    end
end


function params=i_getDefaultRTTParams


    rttparams=...
    {
    'SolverType','Fixed-step','Fixed-step';
    'Solver','ode3',{'ode1','ode2','ode3','ode4','ode5','ode8','ode14x','FixedStepDiscrete'};
    'SolverMode','SingleTasking','SingleTasking';
    'TargetLang','C','C';
    'RTWVerbose','off','off';
    'PurelyIntegerCode','off','off';
    'SupportNonFinite','on','on';
    'SupportComplex','on','on';
    'SupportAbsoluteTime','on','on';
    'SupportContinuousTime','on','on';
    'SupportNonInlinedSFcns','off','off';
    'SupportVariableSizeSignals','on','on';
    'CombineOutputUpdateFcns','off','off';
    'IncludeMdlTerminateFcn','on','on';
    'MatFileLogging','off','off';
    'GenerateASAP2','off','off';
    'RTWCAPIParams','off','off';
    'RTWCAPISignals','off','off';
    'RTWCAPIRootIO','off','off';
    'RTWCAPIStates','off','off';
    'CreateSILPILBlock','None','None';

    'CodeExecutionProfiling','off','off';
    'CodeProfilingInstrumentation','off','off';

    'ERTSrcFileBannerTemplate','realtime_code_template.cgt','realtime_code_template.cgt';
    'ERTHdrFileBannerTemplate','realtime_code_template.cgt','realtime_code_template.cgt';
    'ERTDataSrcFileTemplate','realtime_code_template.cgt','realtime_code_template.cgt';
    'ERTDataHdrFileTemplate','realtime_code_template.cgt','realtime_code_template.cgt';
    'ERTCustomFileTemplate','realtime_file_process.tlc','realtime_file_process.tlc';
    'GenerateSampleERTMain','on','on';
    'TargetOS','BareBoardExample','BareBoardExample';
    'EnableUserReplacementTypes','off','off';
    'GlobalDataDefinition','Auto','Auto';
    'GlobalDataReference','Auto','Auto';
    'IncludeFileDelimiter','Auto','Auto';
    'EnableDataOwnership','off','off';
    'ERTFilePackagingFormat','Modular','Modular';
    'ProdEqTarget','on','on';
    'TargetLibSuffix','.a','.a';
    'GenerateMakefile','off','off';
    'GenerateReport','off','off';
    'IgnoreCustomStorageClasses','on','on';
    'ExtModeStaticAlloc','off','off';
    'StrictBusMsg','ErrorLevel1',{'ErrorLevel1','Warning','None'};
    };
    params=[];
    for i=1:length(rttparams)
        params.(rttparams{i,1})=[];
        params.(rttparams{i,1}).defaultValue=rttparams{i,2};
        params.(rttparams{i,1}).allowedValues=rttparams{i,3};
    end


    isSCLicensed=license('test','Real-Time_Workshop');
    isECLicensed=license('test','RTW_Embedded_Coder');
    if isSCLicensed&&isECLicensed
        params.('IgnoreCustomStorageClasses').allowedValues={'on','off'};
    end
end


