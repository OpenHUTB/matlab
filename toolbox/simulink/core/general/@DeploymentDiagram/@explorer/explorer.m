function h=explorer(varargin)




    if isnumeric(varargin{1})
        modelName=get_param(varargin{1},'Name');
    else

        [~,mdl,~]=fileparts(varargin{1});
        modelName=mdl;

    end


    h=DeploymentDiagram.getexplorer('name',modelName);
    if~isempty(h)&&~isempty(h.getRoot)
        h.show;
        return;
    end

    load_system(modelName);
    modelH=get_param(modelName,'handle');
    modelObj=get_param(modelH,'Object');

    m=get_param(modelName,'MappingManager');
    dtm=m.getActiveMappingFor('DistributedTarget');
    if~isempty(dtm)
        assert(isa(dtm,'Simulink.DistributedTarget.Mapping'));
    end

    h=DeploymentDiagram.explorer(m,'DeploymentDiagramTaskEditor',0);
    expId=num2str(modelH);
    h.explorerID=expId;


    creatui(h);


    h.lastSelectedNodeActions=DeploymentDiagram.getactions(h.imme.getCurrentTreeNode);




    h.listeners{1}=handle.listener(h,'METreeSelectionChanged',...
    {@DeploymentDiagram.cbe_refreshactions});
    h.listeners{end+1}=handle.listener(h,'MEListSelectionChanged',...
    {@DeploymentDiagram.cbe_refreshactions});

    h.listeners{end+1}=handle.listener(h,'ObjectBeingDestroyed',...
    {@(s,e)DeploymentDiagram.deleteTEAndChildren(h)});

    h.listeners{end+1}=handle.listener(h,'MEPostClosed',...
    {@DeploymentDiagram.cbe_postclose});

    addSSAndChildSSListeners([],modelObj,h);


    h.listeners{end+1}=Simulink.listener(modelObj,'EngineSimStatusInitializing',...
    @(s,e,d)simStatusCallback(e,h));
    h.listeners{end+1}=Simulink.listener(modelObj,'EngineSimStatusStopped',...
    @(s,e,d)simStatusCallback(e,h));
    h.listeners{end+1}=Simulink.listener(modelObj,'PostSaveEvent',...
    @(s,e,d)postSaveCallback(e,h));
    h.listeners{end+1}=Simulink.listener(modelObj,'ConcurrentTasksParamChanged',...
    @(s,e,d)concurrentTaskChangedCallback(e,h));
    h.MCOSListeners{1}=addlistener(...
    m,'MappingsBeingDestroyed',@(h,e,a)DeploymentDiagram.refreshME(h,e,expId));

    if~isempty(dtm)
        h.attachMCOSListeners({dtm});
    end

    function concurrentTaskChangedCallback(~,explorer)


        explorer.updateTitle();
        DeploymentDiagram.firePropertyChange(explorer.getRoot);

        function postSaveCallback(~,explorer)


            explorer.updateTitle();

            function simStatusCallback(event,explorer)





                evtType=event.EventName;

                switch(evtType)
                case 'EngineSimStatusInitializing'
                    explorer.setallactions('off');
                case 'EngineSimStatusStopped'
                    explorer.updateactions('off',explorer.lastSelectedNodeActions);

                otherwise

                end
                if~isempty(explorer.getDialog)
                    explorer.getDialog.refresh;
                else
                    DeploymentDiagram.firePropertyChange(explorer.imme.getCurrentTreeNode);
                end



                function blockAddListener(source,event,explorer)

                    if isa(event.Child,'Simulink.SubSystem')
                        addSSAndChildSSListeners(source,event.Child,explorer)
                    end
                    if isa(event.Child,'Simulink.Block')
                        root=explorer.getRoot;
                        DeploymentDiagram.fireHierarchyChange(root);
                    end

                    function blockDeleteListener(source,event,explorer)

                        if isa(event.Child,'Simulink.SubSystem')
                            deleteSSAndChildSSListeners(source,event.Child,explorer);
                        end
                        if isa(event.Child,'Simulink.Block')
                            root=explorer.getRoot;
                            DeploymentDiagram.fireHierarchyChange(root);
                        end

                        function addSSAndChildSSListeners(source,ss,h)

                            h.listeners{end+1}=Simulink.listener(ss,'ObjectChildAdded',...
                            @(s,e,d)blockAddListener(s,e,h));
                            h.listeners{end+1}=Simulink.listener(ss,'ObjectChildRemoved',...
                            @(s,e,d)blockDeleteListener(s,e,h));

                            children=ss.getHierarchicalChildren;
                            for cIdx=1:length(children)
                                if isa(children(cIdx),'Simulink.SubSystem')
                                    addSSAndChildSSListeners(source,children(cIdx),h);
                                end
                            end

                            function deleteSSAndChildSSListeners(source,ss,h)

                                idx=arrayfun(@(c)isequal(c.SourceObject,ss),h.listeners);
                                h.listeners(idx)=[];

                                children=ss.getHierarchicalChildren;
                                for cIdx=1:length(children)
                                    if isa(children(cIdx),'Simulink.SubSystem')
                                        deleteSSAndChildSSListeners(source,children(cIdx),h);
                                    end
                                end

