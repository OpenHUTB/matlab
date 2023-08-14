function varargout=launchSolverProfiler(varargin)
    import solverprofiler.internal.SolverProfilerClass;
    import solverprofiler.util.*


    varargout{1}=[];
    needReturn=false;

    try
        if nargin==1&&ischar(varargin{1})
            if strcmp(varargin,'test')


                studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                if isempty(studios)
                    return;
                end
                mdl=get_param(studios(1).App.blockDiagramHandle,'name');
                needReturn=true;
            else
                mdl=varargin{1};
                needReturn=true;
            end
        else







            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if isempty(studios)
                return;
            end
            mdl=get_param(studios(1).App.blockDiagramHandle,'name');
        end
    catch
        mdl=bdroot;
    end




    mode=get_param(mdl,'simulationMode');
    if~strcmp(mode,'normal')&&~strcmp(mode,'accelerator')
        errordlg(utilDAGetString('modeSupport'),utilDAGetString('failedToLaunchSP'));
        return
    end



    if(strcmp(get_param(mdl,'EnableSteadyStateSolver'),'on'))
        id='Simulink:solverProfiler:DoesNotSupportSteadyState';
        msg=utilDAGetString('DoesNotSupportSteadyState');
        throw(MException(id,msg));
    end

    SP=SolverProfilerClass(mdl);

    if needReturn
        varargout{1}=SP;
    end

end
