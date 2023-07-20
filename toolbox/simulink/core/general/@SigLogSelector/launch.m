function launch(varargin)










    nArgs=length(varargin);
    narginchk(2,4);
    action=varargin{1};
    sys=varargin{2};


    if nArgs<3
        opts={};
    else
        opts=varargin(3:end);
    end


    bTesting=ismember('isTesting',opts);


    switch action
    case{'Close'}
        locCloseDlg(sys,bTesting);
    case{'Create'}
        locOpenDlg(sys,bTesting,opts);
    otherwise
        DAStudio.error(...
        'Simulink:Logging:SigLogDlgInvalidAction',...
        action);
    end

end


function locCloseDlg(sys,bTesting)












    me=SigLogSelector.getExplorer();
    if isempty(me)||~me.getRoot.isValid
        return;
    end


    [system,subsystem]=parseSystem(sys,bTesting,false);
    if~isempty(subsystem)||~strcmp(system,me.getRoot.Name)
        return;
    end


    delete(me);
end


function locOpenDlg(sys,bTesting,opts)



    try


        [system,subsystem]=parseSystem(sys,bTesting,true);


        me=SigLogSelector.explorer(system,opts{:});


        if~isempty(subsystem)
            me.selectNode(subsystem);
        end


        me.show;

    catch dlg_exception
        if bTesting
            rethrow(dlg_exception);
        else
            SigLogSelector.displayWarningDlg(...
            dlg_exception.identifier,...
            dlg_exception.message,...
            '',...
            'error');
        end
    end
end


function[system,subsystem]=parseSystem(sys,bTesting,bOpening)
















    [rootSystem,fullPath]=getPathsFromArg(sys);


    if~strcmp(rootSystem,fullPath)
        subsystem=fullPath;
    else
        subsystem='';
    end


    system=strtok(rootSystem,'.');


    existcode=exist(system);%#ok<EXIST>
    if(existcode~=4&&existcode~=2)
        DAStudio.error('Simulink:Logging:SigLogDlgSysNotFound',system);
    end


    if bOpening&&~strcmpi(get_param(system,'BlockDiagramType'),'model')
        id='Simulink:Logging:SigLogDlgLibOrLockedModel';
        msg=DAStudio.message(id);
        if~bTesting
            SigLogSelector.displayWarningDlg(...
            id,...
            msg,...
            '',...
            'error');
        end
        dlg_exception=MException(id,msg);
        throw(dlg_exception);
    elseif bOpening&&strcmpi(get_param(system,'Lock'),'on')
        id='Simulink:Logging:SigLogDlgLockedModel';
        msg=DAStudio.message(id);
        if~bTesting
            SigLogSelector.displayWarningDlg(...
            id,...
            msg,...
            '',...
            'error');
        end
        dlg_exception=MException(id,msg);
        throw(dlg_exception);
    end

end


function[rootSystem,fullPath]=getPathsFromArg(launchArg)







    if isnumeric(launchArg)
        try
            parentPath=get_param(launchArg,'Parent');
            name=get_param(launchArg,'Name');
        catch get_exc
            id='Simulink:Logging:SigLogDlgSysNotFound';
            err=MException(id,DAStudio.message(id,num2str(launchArg)));
            err=err.addCause(get_exc);
            throw(err);
        end
    elseif ischar(launchArg)
        [t,r]=strtok(fliplr(launchArg),'/');
        parentPath=fliplr(r);
        name=fliplr(t);
    else
        DAStudio.error('Simulink:Logging:SigLogDlgArgNotString');
    end



    name=strrep(name,'/','//');


    if isempty(parentPath)
        rootSystem=name;
    else
        rootSystem=strtok(parentPath,'/');
    end


    if isempty(parentPath)
        fullPath=name;
    elseif strcmp(parentPath(length(parentPath)),'/')
        fullPath=[parentPath,name];
    else
        fullPath=[parentPath,'/',name];
    end

end
