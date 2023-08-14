function traceInfo=getTraceInfoByReportInfo(rptInfo)



    traceInfo=[];
    if isempty(rptInfo)
        return;
    end

    model=[];
    if isValidSlObject(slroot,rptInfo.ModelName)
        model=rptInfo.ModelName;
    elseif~isempty(rptInfo.SourceSubsystem)
        [model,~]=strtok(rptInfo.SourceSubsystem,':/');
    end

    if isempty(model)||~slprivate('isInCodeTraceEnabled',model)
        return;
    else
        traceInfo=get_param(model,'CoderTraceInfo');
    end

    if(isempty(traceInfo)||~strcmp(traceInfo.model,rptInfo.ModelName)||...
        ~strcmp(traceInfo.buildDir,rptInfo.BuildDirectory))
        dbFolder=fullfile(rptInfo.BuildDirectory,'tmwinternal');
        if exist(dbFolder,'dir')==7
            traceInfo=coder.trace.TraceInfoBuilder(rptInfo.ModelName);
            traceInfo.buildDir=rptInfo.BuildDirectory;
            traceInfo.repositoryDir=dbFolder;
            traceDataFile=fullfile(dbFolder,'tr');
            if exist(traceDataFile,'file')==2
                if~traceInfo.load()
                    traceInfo=[];
                else
                    traceInfo.buildDir=rptInfo.BuildDirectory;
                    traceInfo.repositoryDir=dbFolder;
                end
            end
        end
        if~isempty(traceInfo)
            if isValidSlObject(slroot,rptInfo.ModelName)
                set_param(rptInfo.ModelName,'CoderTraceInfo',traceInfo);
            end
            if~isempty(rptInfo.SourceSubsystem)
                set_param(model,'CoderTraceInfo',traceInfo);
            end
        end
    end
end


