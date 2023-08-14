function varargout=coderTypeEditor(varargin)















    if any(~cellfun(@coder.internal.isScalarText,varargin))
        error(message('coderApp:uicommon:invalidCoderTypeEditorArgument'));
    end



    args=string(varargin);
    flagSelector=startsWith(args,'-');
    promoteAll=false;
    for flag=lower(extractAfter(args(flagSelector),1))
        switch flag
        case 'all'
            promoteAll=true;
        case 'close'
            typeEditor=getSingleton(false);
            if~isempty(typeEditor)
                typeEditor.delete();
            end
            return
        otherwise
            error(message('coderApp:uicommon:invalidCoderTypeEditorArgument'));
        end
    end



    if promoteAll
        vars=evalin('caller','who');
    else
        vars=unique(args(~flagSelector),'stable');
    end
    typeEditor=getSingleton(true);
    typeEditor.show();
    if isvalid(typeEditor)&&~isempty(vars)
        promise=promoteVariables(typeEditor,vars,~promoteAll);


        promise.then(@(typeRoots)selectFirstVariableInTypeView(typeEditor,typeRoots));
    end

    if nargout~=0&&coder.internal.gui.debugmode
        varargout{1}=typeEditor;
    else
        varargout={};
    end
end


function instance=getSingleton(instantiate)
    persistent singleton lifecycleBinder;
    if instantiate&&(isempty(singleton)||~isvalid(singleton))
        if isempty(lifecycleBinder)
            lifecycleBinder=onCleanup(@()coderTypeEditor('-close'));
        end
        singleton=codergui.ReportServices.TypeEditorFactory.run();
        singleton.addlistener('ObjectBeingDestroyed',@(~,~)munlock);
        coder.internal.ddux.logger.logCoderEventData("typeEditorOpen");
        mlock;
    end
    instance=singleton;
end


function promotePromise=promoteVariables(typeEditor,vars,warn)
    promotePromise=typeEditor.Model.updateWorkspace().then(@(~)doPromoteVariables());

    function promise=doPromoteVariables()
        promise=typeEditor.Model.promoteFromWorkspace(vars);
        if warn
            promise.caught(@warnOnReject);
        end
    end
end


function warnOnReject(e)
    oldBacktrace=warning('off','backtrace');
    warning(e.message);
    warning(oldBacktrace.state,'backtrace');
end


function result=selectFirstVariableInTypeView(typeEditor,typeRoots)
    typeEditor.selectTypeRoot(typeRoots(1));
    result=true;
end
