function traceInfoCleanupFcn=formatCode(modelName,filesList,targetName)







    ObfuscatorOn=0;






    if(~(isempty(modelName)))
        try
            obfuscateLevel=get_param(modelName,'ObfuscateCode');
            ObfuscatorOn=strcmp(get_param(0,'AcceleratorUseTrueIdentifier'),'off')&&...
            obfuscateLevel~=0;
        catch
        end
    end


    set_param(modelName,'RTWTraceInfo',[]);

    traceInfo=get_param(modelName,'CoderTraceInfo');
    if~isempty(traceInfo)&&slprivate('isInCodeTraceEnabled',modelName)
        traceInfo.buildDir=pwd;
        dbFolder=fullfile(traceInfo.buildDir,'tmwinternal');
        if~exist(dbFolder,'dir')
            mkdir(dbFolder);
        end
        traceInfo.repositoryDir=dbFolder;
        rptInfo=rtw.report.getReportInfo(modelName);
        if~isempty(rptInfo.SourceSubsystem)
            traceInfo.sourceSubsysSID=Simulink.ID.getSID(rptInfo.SourceSubsystem);
        end
    end


    if(~isempty(targetName))
        if(~ObfuscatorOn)
            id='Code Beautification';
        else
            id='Code Obfuscation';
        end

        PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
        id,true);
    end


    if(~ObfuscatorOn)


        cBeautifierWithOptions(filesList,modelName);

    else
        rtwprivate('doObfuscation',modelName,obfuscateLevel-1,true);

    end


    traceInfoCleanupFcn=onCleanup(@()[]);

    if~isempty(traceInfo)&&slprivate('isInCodeTraceEnabled',modelName)

        if strcmp(get_param(modelName,'GenerateReport'),'off')
            clear traceInfo;
            i_cleanupTraceInfo(modelName,rptInfo.SourceSubsystem)
        else

            traceInfoCleanupFcn=onCleanup(@()i_cleanupTraceInfo...
            (modelName,rptInfo.SourceSubsystem));
        end
    end

    if slsvTestingHook('CheckTlcCommentBuffers')>0
        rtwprivate('checkTlcCommentBufferOrder','tlc');
    end

    if(~isempty(targetName))
        PerfTools.Tracer.logSimulinkData('SLbuild',modelName,targetName,...
        id,false);
    end



    function i_cleanupTraceInfo(modelName,sourceSubsystem)
        set_param(modelName,'CoderTraceInfo',[]);
        if~isempty(sourceSubsystem)
            model=strtok(sourceSubsystem,':/');
            set_param(model,'CoderTraceInfo',[]);
        end

