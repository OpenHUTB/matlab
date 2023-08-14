function lCompileProfileFcn=getCompileProfileFcn(lBuildVariant,lBuildName,lBuildInfo)





    [~,argErtSfcn]=findBuildArg(lBuildInfo,'GENERATE_ERT_S_FUNCTION');
    isERTSFcn=strcmp(argErtSfcn,'1');




    lModelReferenceTargetType=i_getModelRefTargetType...
    (lBuildVariant,isERTSFcn);

    if PerfTools.Tracer.enable('All Simulink Compile')
        switch lModelReferenceTargetType
        case 'SIM'
            targetName='mdlref-AccelSim';
        case 'RTW'
            targetName='mdlref-RTW';
        otherwise

            targetName=slprivate('perf_logger_target_resolution',...
            lModelReferenceTargetType,lBuildName,false,false);
        end
    else
        targetName=lModelReferenceTargetType;
    end

    lCompileProfileFcn=@(argOnOrOff)PerfTools.Tracer.logSimulinkData...
    ('SLbuild',lBuildName,targetName,'Code Compilation',argOnOrOff);



    function tgtType=i_getModelRefTargetType(lBuildVariant,isERTSFcn)

        if isERTSFcn


            tgtType='RTW';
        else
            switch lBuildVariant
            case{'STANDALONE_EXECUTABLE','RAPID_ACCELERATOR',...
                'SHARED_LIBRARY_TARGET','SHARED_LIBRARY'}
                tgtType='NONE';
            case 'MODEL_REFERENCE_CODER'
                tgtType='RTW';
            case 'MEX_FILE'
                tgtType='SIM';
            otherwise
                tgtType='';
            end

        end
