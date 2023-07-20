
function newExc=ss2mdlErrorExit(origModel,newModel,errorCode,exc,thisHdl,...
    varargin)






    pushNags=thisHdl.pushNags;
    wstate=thisHdl.wstate;

    clear slBus;
    clear global gSlGetBusStruc;
    try
        origMdlName=get_param(origModel,'Name');
        if isequal(get_param(origMdlName,'SimulationStatus'),'paused')
            feval(origMdlName,[],[],[],'term');
        end
        if ishandle(newModel)
            close_system(newModel,0);
        end
    catch err %#ok<NASGU>
    end


    [errTextId,errText]=coder.internal.localRetrieveErrorText(errorCode,varargin{:});

    if pushNags

        if~isempty(errorCode)
            newExc=MException(errTextId,errText);
            if~isempty(exc)

                newExc=newExc.addCause(exc);
            end
        else
            newExc=exc;
        end

        slprivate('pushExceptionOnNagController',newExc,...
        DAStudio.message('Simulink:modelReferenceAdvisor:Category'),origModel,true);
    end


    if~isempty(errorCode)
        newExc=MException(['RTW:SS2MDL:',errorCode],errText);
        if~isempty(exc)
            newExc=newExc.addCause(exc);
        end
    else
        newExc=exc;
    end


    warning(wstate.state,'backtrace');
