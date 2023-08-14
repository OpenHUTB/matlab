function traceInfo=getTraceInfoObj(obj,varargin)




    traceInfo={};
    currentModel=obj.model;
    topModel=obj.top;
    isRef=~strcmp(topModel,currentModel);
    mdl=currentModel;

    hdlReportPath=hdlcoder.report.ReportInfo.getSavedRptPath(mdl,false);


    if isempty(hdlReportPath)
        return
    end

    [fileFolder,~]=fileparts(hdlReportPath);

    if~isfolder(fileFolder)
        return;
    end

    if isRef
        traceFileName=fullfile(fileFolder,mdl,'html',mdl,'traceInfo.mat');
    else
        traceFileName=fullfile(fileFolder,'html',mdl,'traceInfo.mat');
    end

    if~isfile(traceFileName)
        return;
    end

    load(traceFileName,'infoStruct');
    traceInfo=infoStruct.traceInfo;

end

