function h=explorer(varargin)




    persistent pbar;
    mlock;


    mdlname=varargin{1};


    if nargin>1
        opts=varargin(2:end);
    else
        opts={};
    end
    bTesting=ismember('isTesting',opts);


    h=SigLogSelector.getExplorer;
    if(isempty(h))


        str=DAStudio.message('Simulink:Logging:SigLogDlgInitializing');
        if isempty(pbar)
            pbar=SigLogSelector.createProgressBar(str);
        else
            pbar.show;
        end


        h=SigLogSelector.explorer(...
        SigLogSelector.BdNode,...
        'SigLogSelectorDlg',...
        false);
        h.isTesting=bTesting;
        createUI(h);


        root=SigLogSelector.BdNode(mdlname);
        h.setRoot(root);


        assert(~isempty(h.listeners));
        h.listeners{end+1}=...
        handle.listener(h,'ObjectBeingDestroyed',@(s,e)cleanup(h));


        h.listeners{end+1}=...
        handle.listener(h,'METreeSelectionChanged',@(s,e)locTreeSelChange(h,s,e));


        h.listeners{end+1}=...
        handle.listener(h,'MEPostClosed',@(s,e)locPostClosed(mdlname));


        locAddRootListeners(h);
        locRestore(h);
        locSyncStatusWithEngine(h);



        SigLogSelector.getExplorer;


        if~isempty(pbar)
            pbar=[];
        end
    elseif(strcmpi(h.getRoot.daobject.getFullName,mdlname))


        h.isTesting=bTesting;
        locRestore(h);
        locSyncStatusWithEngine(h);

    else


        h.isTesting=bTesting;


        str=DAStudio.message('Simulink:Logging:SigLogDlgInitializing');
        if isempty(pbar)
            pbar=SigLogSelector.createProgressBar(str);
        else
            pbar.show
        end


        locChangeRootUI(h,mdlname);


        if~isempty(pbar)
            pbar=[];
        end
    end


    if~isempty(h)&&~isempty(h.getRoot)


        SigLogSelector.fireSignalLoggingPropertyChange('SignalLogging',h);



        h.getRoot.modelBlockAddedOrRemoved;


        h.displayFullMenus=ismember('displayFullMenus',opts);
    end
end


function locAddRootListeners(h)


    h.listeners{end+1}=Simulink.listener(...
    h.getRoot.daobject,...
    'EngineSimStatusInitializing',...
    @(s,e)locStart(h));
    h.listeners{end+1}=Simulink.listener(...
    h.getRoot.daobject,...
    'EngineSimStatusRunning',...
    @(s,e)locContinue(h));
    h.listeners{end+1}=Simulink.listener(...
    h.getRoot.daobject,...
    'EngineSimStatusPaused',...
    @(s,e)locPause(h));
    h.listeners{end+1}=Simulink.listener(...
    h.getRoot.daobject,...
    'EngineSimStatusStopped',...
    @(s,e)locStop(h));
    h.listeners{end+1}=Simulink.listener(...
    h.getRoot.daobject,...
    'EngineCompFailed',...
    @(s,e)locCompFailed(h));

end


function locSyncStatusWithEngine(h)


    s=h.getRoot.daobject.SimulationStatus;
    switch s
    case 'running'
        locStart(h);
        locContinue(h);
    case{'paused','compiled'}
        locPause(h);
    otherwise
    end

end


function locStart(h)


    if~strcmp('done',h.status)
        return
    end

    try

        h.status='initializing';


        h.setAllActions('off');


        node=h.imme.getCurrentTreeNode;
        if(isa(node,'SigLogSelector.SubSysNode'))
            node.firePropertyChange;
        end

    catch me
        h.status='done';
        SigLogSelector.displayWarningDlg(...
        me.identifier,...
        me.message,...
        '',...
        'error');
    end

end


function locPause(h)


    switch h.status
    case 'running'
        h.status='paused';
    otherwise
    end

end


function locContinue(h)


    switch h.status
    case{'initializing','paused'}
        h.status='running';
    otherwise
    end

end


function locStop(h)


    switch h.status
    case{'initializing','running','paused'}
        locRestore(h);
    case 'comp_failed'
        locRestore(h);
        beep;
    otherwise
    end

end


function locCompFailed(h)


    if~strcmp('running',h.status)
        return;
    end
    h.status='comp_failed';

end


function locRestore(h)


    h.status='done';
    h.restoreActionState;


    node=h.imme.getCurrentTreeNode;
    if(isa(node,'SigLogSelector.SubSysNode'))
        node.firePropertyChange;
    end

end


function cleanup(h)





    if~h.getRoot.isClosing
        h.closeWarningDlgs;
        root=h.getRoot;
        root.isClosing=true;
        root.unpopulate;
        delete(h.imme);
    end

end


function locTreeSelChange(h,~,e)




    if~isempty(h.unloadingModelRefNode)
        if isequal(e.EventData,h.getRoot)
            h.unloadingModelRefNode=[];
        end
    end

end


function locChangeRootUI(h,mdlname)



    oldRoot=h.getRoot;
    for i=1:numel(h.listeners)
        if isa(h.listener{i},'event.listener')
            source=h.listeners{i}.Source{1};
        else
            source=h.listeners{i}.SourceObject;
        end
        if isequal(source,oldRoot.daobject)
            delete(h.listeners{i});
            h.listeners{i}=[];
        end
    end


    h.listeners=h.listeners(~cellfun(@isempty,h.listeners));


    newRoot=SigLogSelector.BdNode(mdlname);
    h.setRoot(newRoot);


    oldRoot.unpopulate;
    delete(oldRoot);


    newRoot.fireHierarchyChanged;
    locAddRootListeners(h);
    locRestore(h);
    locSyncStatusWithEngine(h);

end



function locPostClosed(mdlname)

    SigLogSelector.launch('Close',mdlname);
end
