function varargout=exploreResult(result,varargin)
    import solverprofiler.util.*

    try
        if ischar(result)
            filePath=result;
        else
            filePath=result.file;
        end
        readIn=load(filePath);
        sessionData=readIn.sessionData;
    catch
        id='solverprofiler:failedToLoadData';
        msg=utilDAGetString('notASessionDataForCurrentRelease');
        errmsg=MException(id,msg);
        throw(errmsg);
    end

    try
        mdl=sessionData.getModel();
    catch
        id='failedToLoadData:notASessionData';
        msg=utilDAGetString('notASessionDataForCurrentRelease');
        throw(MException(id,msg));
    end


    try
        load_system(mdl);
    catch exception
        id='Simulink:solverProfiler:UnableToLoadModel';
        msg=utilDAGetString('UnableToLoadModel',mdl,exception.message);
        throw(MException(id,msg));
    end



    try
        SP=solverprofiler.launchSolverProfiler(mdl);
    catch exception
        throw(exception);
    end

    SP.loadSavedSessionData(sessionData);

    if nargout==1&&nargin==2
        if~isempty(varargin)&&strcmp(varargin{1},'test')
            varargout{1}=SP;
        end
    end

end
