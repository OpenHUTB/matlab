


















function utilCreatePerformanceProgress(mdladvObj,cleanup)


    if isfield(mdladvObj.UserData,'Progress')
        if isfield(mdladvObj.UserData.Progress,'sdiEngine')
            utilClearSdi(mdladvObj);
        end
        mdladvObj.UserData=rmfield(mdladvObj.UserData,'Progress');
    end

    if isfield(mdladvObj.UserData,'Results')
        mdladvObj.UserData=rmfield(mdladvObj.UserData,'Results');
    end

    if isfield(mdladvObj.UserData,'Mode')
        mdladvObj.UserData=rmfield(mdladvObj.UserData,'Mode');
    end

    if cleanup
        return;
    end



    mdladvObj.UserData.Mode='Full';




    baseline=utilCreateEmptyBaseline();

    mdladvObj.UserData.Progress.baseLineOverall=baseline;
    mdladvObj.UserData.Progress.initBaseLine=baseline;
    mdladvObj.UserData.Progress.baseLineBefore=baseline;
    mdladvObj.UserData.Progress.baseLineAfter=baseline;

    mdladvObj.UserData.Progress.currCheck=[];




    mdladvObj.UserData.Results.baselines=struct([]);
    mdladvObj.UserData.Results.logLocation=[];
    mdladvObj.UserData.Results.model='';
    mdladvObj.UserData.Results.currentCheckName='';




    mdladvObj.UserData.Progress.sdiEngine=Simulink.sdi.Instance.engine;
    mdladvObj.UserData.Progress.sdiRunIDs=[];
    Simulink.sdi.internal.startConnector();


