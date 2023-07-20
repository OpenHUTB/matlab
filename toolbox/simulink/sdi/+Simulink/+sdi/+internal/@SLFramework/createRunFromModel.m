function[runID,runIndex,varargout]=createRunFromModel(~,~,modelName,varargin)


    obj=Simulink.sdi.Instance.engine;
    runID=[];
    runIndex=[];
    if nargout>2
        varargout{1}=0;
    end


    stepping=false;
    metaData=[];
    if nargin>4
        metaData=varargin{1};
        stepping=varargin{2};
    elseif nargin==4
        stepping=varargin{1};
    end


    try
        [varNames,timeSaveName,fileNames,scopeNames]=...
        Simulink.sdi.internal.SLUtil.getLogVarNamesFromModel(modelName,metaData);
    catch e %#ok<NASGU>
        return;
    end



    if~isempty(varargin)
        try
            val=get_param(modelName,'InspectSignalLogs');
        catch me %#ok<NASGU>
            return;
        end
        isRecording=strcmpi(val,'on')||Simulink.sdi.Instance.record;
        if~isRecording
            return
        end
    end


    mdl=get_param(modelName,'handle');
    currIsUpdate=obj.isUpdate;


    Simulink.sdi.internal.flushStreamingBackend();
    storedRunID=obj.getCurrentStreamingRunID(modelName);
    if~storedRunID
        storedRunID=obj.sigRepository.getRunIDFromModel(mdl);
    end
    if~obj.isValidRunID(storedRunID)
        storedRunID=0;
    end


    updateRunNumber=(storedRunID==0);


    if storedRunID==0

        obj.isUpdate=true;

        if~isempty(obj.runNameModel)
            runName=obj.runNameModel;
            obj.runNameModel='';
        else
            runName=obj.runNameTemplate;
        end


        [runID,runIndex,sigIDs]=...
        obj.createRunFromBaseWorkspace(...
        runName,...
        varNames,...
        modelName,...
        timeSaveName,...
        fileNames,...
        scopeNames);
        if nargout>2
            varargout{1}=sigIDs;
        end


        if~isempty(runID)
            startTime=evalin('base',get_param(modelName,'StartTime'));
            stopTime=evalin('base',get_param(modelName,'StopTime'));
            obj.sigRepository.setRunStartAndStopTime(runID,startTime,stopTime);
        end


        if stepping&&~isempty(runID)
            obj.sigRepository.addPausedModel(mdl,runID);
        end

        obj.isUpdate=currIsUpdate;
    elseif~isempty(storedRunID)

        if stepping
            obj.sigRepository.safeTransaction(...
            @()helperUpdateStoredRun(...
            storedRunID,varNames,modelName,timeSaveName,fileNames,scopeNames,obj));
            if~isempty(obj.getAllSignalIDs(storedRunID,'checked'))
                obj.publishUpdateLabelsNotification('PerformFitToView');
            end
        else
            obj.updateStoredRun(storedRunID,varNames,modelName,timeSaveName,...
            fileNames,scopeNames);
        end

        runID=storedRunID;
        runIndex=obj.getRunCount();
        if nargout>2&&obj.isValidRunID(storedRunID)
            varargout{1}=obj.getAllSignalIDs(storedRunID,'logged');
        end


        if~stepping
            obj.sigRepository.removePausedModel(mdl);
        end
    end



    if~isempty(runID)&&~obj.isValidRunID(runID)
        runID=[];
        storedRunID=[];
    end



    if~stepping&&~isempty(runID)
        notify(obj,'runAddedEvent',Simulink.sdi.internal.SDIEvent('runAddedEvent',runID,modelName));
    end


    if~isempty(storedRunID)
        if~isempty(obj.updatePlotFunctionHandle)
            feval(obj.updatePlotFunctionHandle);
        end
    end


    if~isempty(runID)
        [mdlStartTime,isValid]=...
        Simulink.sdi.WebClient.getModelStartTime(modelName);
        if isValid
            obj.setRunStartTime(runID,mdlStartTime);
        end
    end
end


function helperUpdateStoredRun(...
    storedRunID,varNames,modelName,timeSaveName,fileNames,scopeNames,obj)


    obj.updateStoredRun(...
    storedRunID,...
    varNames,modelName,timeSaveName,...
    fileNames,scopeNames);

end


