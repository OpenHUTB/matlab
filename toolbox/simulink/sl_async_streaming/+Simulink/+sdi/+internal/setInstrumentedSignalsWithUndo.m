function setInstrumentedSignalsWithUndo(mdl,sigs,varargin)











    editorPath=mdl;
    bRefreshPorts=true;
    if~isempty(varargin)&&~isempty(varargin{1})
        editorPath=varargin{1};
    end
    if length(varargin)>1
        bRefreshPorts=varargin{2};
    end



    [editor,editorDomain]=locGetEditor(editorPath);
    if isempty(editorDomain)
        locSetParam(mdl,sigs,bRefreshPorts);
    else
        editorDomain.createParamChangesCommand(...
        editor,...
        'Simulink:dialog:SigpropGrpLogging',...
        getString(message('Simulink:dialog:SigpropGrpLogging')),...
        @locSetInstrSignals,{mdl,sigs,bRefreshPorts,editorDomain},...
        false,...
        true,...
        false,...
        false,...
        true);
    end
end


function[editor,editorDomain]=locGetEditor(bpath)


    editorDomain=[];
    editor=[];
    try
        editors=GLUE2.Util.findAllEditors(bpath);
        numEditors=length(editors);
        for idx=1:numEditors
            if editors(idx).isVisible
                domain=editors(idx).getStudio.getActiveDomain();
                if ismethod(domain,'createParamChangesCommand')
                    editor=editors(idx);
                    editorDomain=domain;
                    break;
                end
            end
        end
    catch me %#ok<NASGU>
        editor=[];
        editorDomain=[];
    end
end


function[success,noop]=locSetInstrSignals(mdl,sigs,bRefreshPorts,editorDomain)

    success=false;
    noop=false;
    try
        hBD=get_param(mdl,'Handle');
        editorDomain.paramChangesCommandAddObject(hBD);
        locSetParam(mdl,sigs,bRefreshPorts);
        success=true;
    catch me %#ok
    end
end


function locSetParam(mdl,sigs,bRefreshPorts)


    if bRefreshPorts
        set_param(mdl,'InstrumentedSignals',sigs);
    else
        set_param(mdl,'InstrumentedSignalsNoRefresh',sigs);
    end
end
