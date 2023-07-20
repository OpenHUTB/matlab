

classdef SearchActions<handle
    methods(Static,Access=public)
        function[returnDirectly,actionCBVarargout]=preFindSLObjActions(argList)

            import simulink.search.SearchActions;
            import simulink.search.internal.SearchInstanceManager;
            actionCBVarargout{1}=[];
            returnDirectly=false;

            Action=argList{1};
            studioTag=argList{2};


            uri=studioTag;
            if isempty(uri)
                uri='';
            end
            searchManager=SearchInstanceManager.getSearchInstanceManager(uri);
            if isempty(searchManager)
                return;
            end


            switch(Action)
            case 'Create'
                searchManager.createPreAction();
            case 'Find'
                searchManager.findPreAction();
            case 'ResetFind'
                searchManager.resetFindPreAction();
            otherwise
            end
        end


        function[returnDirectly,actionCBVarargout]=postFindSLObjActions(argList)

            import simulink.search.SearchActions;
            import simulink.search.internal.SearchInstanceManager;
            Action=argList{1};
            studioTag=argList{2};

            actionCBVarargout{1}=[];
            returnDirectly=false;


            uri=studioTag;
            if isempty(uri)
                uri='';
            end
            searchManager=SearchInstanceManager.getSearchInstanceManager(uri);
            if isempty(searchManager)
                return;
            end


            switch(Action)
            case 'Find'
                searchManager.findPostAction();
            case 'FindAsyncProgress'
                searchManager.findAsyncProgressPostAction();
            case 'ChangeViewMode'
                searchManager.changeViewModePostAction();
            otherwise
            end
        end


        function createOpenSearchFullViewWindow(cbinfo)
            import simulink.search.SearchActions;
            SearchActions.createOpenSearchWindow(cbinfo,true,false);
        end


        function createOpenReplaceFullViewWindow(cbinfo)
            import simulink.search.SearchActions;
            SearchActions.createOpenSearchWindow(cbinfo,true,true);
        end


        function createOpenSearchWindowBySystemInfo(systemNameOrInfo,studioTag,isFullView,isReplaceOn)
            import simulink.search.SearchActions;
            import simulink.search.internal.model.SearchModel;
            uri=studioTag;
            [searchModel,instanceManager]=SearchModel.createSearchModel(uri);
            if isempty(searchModel)

                return;
            end
            searchSystems=searchModel.searchSystems;
            if isFullView
                searchSystems.viewMode='fullView';
            else
                searchSystems.viewMode='lightView';
            end

            documentListener=searchModel.getDocumentListener();
            debugInfo=SearchModel.getDebugInfo();
            SearchActions.createOpenSearchWindowImpl(...
            systemNameOrInfo,documentListener,instanceManager,studioTag,debugInfo,isReplaceOn...
            );
        end


        function createOpenSearchWindow(cbinfo,isFullView,isReplaceOn)
            import simulink.search.SearchActions;
            systemInfo=SLStudio.Utils.getDiagramFullName(cbinfo);
            studioTag=SearchActions.getActiveStudioTag();
            SearchActions.createOpenSearchWindowBySystemInfo(...
            systemInfo,studioTag,isFullView,isReplaceOn...
            );
        end


        function createOpenSearchWindowImpl(...
            systemInfo,documentListener,instanceManager,currentStudioTag,debugInfo,replaceOn...
            )

            import simulink.search.SearchActions;
            searchModel=instanceManager.getSearchModel();
            searchSystems=searchModel.searchSystems;
            searchSystems.studioTag=currentStudioTag;


            if isempty(searchSystems.viewMode)
                searchSystems.viewMode='lightView';
            end

            searchSystems.columnNames={'Type';'Name';'Parent';'Source';'Destination'};


            [searchSystems.flat,...
            searchSystems.systemName,...
            searchSystems.viewMode,...
            searchSystems.publishMsg.SetFocus]=...
            i_FinderCreate(systemInfo,instanceManager,currentStudioTag,debugInfo,replaceOn);



            [searchSystems.functionList,...
            searchSystems.OBJECT_LIST,...
            searchSystems.PROPERTY_LIST]=i_FinderInitialize();



            if isempty(documentListener.openListener)
                documentListener.openListener=GLUE2.Document.addDocumentOpenedListener(@(doc)addSelectListenerOnDocumentOpened(doc,documentListener));

                docs=GLUE2.Document.getDocuments;
                for i=1:length(docs)
                    document=docs{i};
                    if document.isvalid
                        newIndex=length(documentListener.selectionListener)+1;
                        documentListener.selectionListener(newIndex).document=document;
                        documentListener.selectionListener(newIndex).listener=document.addDocumentSelectionChangedListener(@(doc,old,new)selectionChangeOnCanvasCallback(doc,old,new));
                    end
                end

            end


            documentListener.removeInvalidDocument();
        end



        function finderComp=createFinderComponentUpdateTitles(searchModel)
            dlg=DAStudio.FinderDDG('',false);
            import simulink.search.SearchActions;
            [finderTitle,activeStudio]=SearchActions.getFinderComponentInfoBySearchModel(searchModel);
            finderComp=dlg.createEmbeddedDDG(activeStudio,'Find',finderTitle,'Bottom','Tabbed');
        end




        function modelName=getModelNameFromStudio(studio)
            try
                topLevelDiagram=studio.App.topLevelDiagram;
                modelHandle=topLevelDiagram.handle;
                modelName=get_param(modelHandle,'Name');
            catch
                modelName='';
            end
        end


        function activeStudioTag=getActiveStudioTag()
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

            activeStudio=studios(1,1);
            activeStudioTag=activeStudio.getStudioTag();
        end



        function triggerStatus=selectionTriggerStatus(action,value)
            persistent shouldHandleCallback;
            if isempty(shouldHandleCallback)
                shouldHandleCallback=true;
            end

            if strcmp(action,'GetStatus')
                triggerStatus=shouldHandleCallback;
            elseif strcmp(action,'SetStatus')
                shouldHandleCallback=value;
            end
        end


        function openSystem(varargin)
            import simulink.search.internal.model.SearchModel;
            studioTag=varargin{1};
            if isempty(studioTag)
                studioTag='';
            end
            sm=SearchModel.getSearchModel(studioTag);
            sl_find('OpenObjects',get_param(varargin{2},'handle'),studioTag,sm.searchSystems.searchModelRef.modelsToBlocksMap);
        end


        function currentModelName=getCurrentModelName(studioTag)

            s=DAS.Studio.getStudio(studioTag);

            import simulink.search.SearchActions;
            currentModelName=SearchActions.getModelNameFromStudio(s);
        end

        function finderTitle=getFinderTitleWithDepthInfo(scopeString,studio,activeEditor)
            import simulink.search.SearchActions;


            switch scopeString
            case 'top'

                scopeMessage=message('simulink_ui:search:resources:SearchFromTopModel').getString();
            case 'on'

                scopeMessage=message('simulink_ui:search:resources:ThisLevelOnly').getString();
            case 'off'

                scopeMessage=message('simulink_ui:search:resources:ThisLevelAndBelow').getString();
            otherwise
                return;
            end

            finderTitle=message('simulink_ui:finder:resources:FinderDialogTitle',scopeMessage).getString();
        end


        function[finderTitle,activeStudio]=getFinderComponentInfoBySearchModel(searchModel)

            activeStudio=DAS.Studio.getStudio(searchModel.getStudioTag());
            activeEditor=activeStudio.App.getActiveEditor();


            import simulink.search.SearchActions;
            finderTitle=SearchActions.getFinderTitleWithDepthInfo(...
            searchModel.searchDepth,activeStudio,activeEditor...
            );
        end


        function updateBackendSearchDepth(studioTag,scopeString)
            import simulink.search.SearchActions;


            import simulink.search.internal.SearchInstanceManager;
            uri=studioTag;
            searchManager=SearchInstanceManager.getSearchInstanceManager(uri);
            if isempty(searchManager)
                return;
            end

            searchModel=searchManager.getSearchModel();
            if~isempty(searchModel)
                searchModel.searchDepth=scopeString;
            end




            searchManager.updateFinderTitle();
        end



        function varargout=getSearchDepth(studioTag)
            varargout{1}='top';
            import simulink.search.internal.model.SearchModel;
            uri=studioTag;
            searchModel=SearchModel.getSearchModel(uri);
            if isempty(searchModel)
                return;
            end
            varargout{1}=searchModel.searchDepth;
        end




        function sysName=getSystemNameFromEditor(activeEditor)
            utils.ScopedInstrumentation("find_slobj::getSystemNameFromEditor");
            diag=activeEditor.getDiagram;
            if(isa(diag,'InterfaceEditor.Diagram'))
                model=diag.Model;
                slobj=get_param(model.SLGraphHandle,'Object');
                sysName=slobj.getFullName();
            else
                sysName=activeEditor.getName();
            end
        end



        function updateFinderTitle(s,finderTitle)
            if isempty(s)
                return;
            end


            comp=s.getComponent('GLUE2:Finder Component','Find');
            if~isempty(comp)
                s.setDockComponentTitle(comp,finderTitle);
            end
        end


        function isDefaultParam=isDefaultAdvancedSettings(studioTag)
            import simulink.search.internal.model.SearchModel;
            import simulink.search.SearchActions;
            isDefaultParam=true;
            uri=studioTag;
            searchModel=SearchModel.getSearchModel(uri);
            if isempty(searchModel)
                return;
            end
            advancedParameter=searchModel.advancedParameter;
            if isempty(advancedParameter)
                return;
            end
            isDefaultParam=SearchActions.equalToDefaultAdvancedSettings(advancedParameter{1,1});
        end





        function status=getDefaultSearchScope()
            status.referencedSys=1;
            status.linkedSys=1;
            status.maskedSys=1;
        end




        function isDefault=equalToDefaultAdvancedSettings(newSetting)
            import simulink.search.SearchActions;
            utils.ScopedInstrumentation("find_slobj::isDefaultAdvancedSettings");
            studioTag=newSetting.studioTag;
            objects=cell(14,1);
            objects(:)={'true'};



            systemStatus=SearchActions.getDefaultSearchScope();
            if(systemStatus.maskedSys==1)
                maskedSysStatus='all';
            else
                maskedSysStatus='none';
            end

            if(systemStatus.linkedSys==1)
                linkedSysStatus='on';
            else
                linkedSysStatus='off';
            end

            if(systemStatus.referencedSys==1)
                referencedSysStatus='on';
            else
                referencedSysStatus='off';
            end

            defaultValue=struct(...
            'studioTag',studioTag,...
            'Regexp','0',...
            'CaseSensitive','off',...
            'searchMode','SimpleAndParams',...
            'properties',[],...
            'Objects',{objects},...
            'LookUnderMasks',maskedSysStatus,...
            'FollowLinks',linkedSysStatus,...
            'LookInsideReferencedModels',referencedSysStatus);

            isDefault=isequaln(defaultValue,newSetting);
        end
    end
end




function[flat,systemName,viewMode,SetFocus]=i_FinderCreate(...
    systemInfo,instanceManager,studioTag,debugInfo,replaceOn...
    )
    import simulink.search.SearchActions;



    searchModel=instanceManager.getSearchModel();
    searchSystems=searchModel.searchSystems;
    viewMode=searchSystems.viewMode;


    if ishandle(systemInfo)
        systemInfo=getfullname(systemInfo);
    end
    systemName=systemInfo;
    SetFocus=struct();


    s=DAS.Studio.getStudio(studioTag);

    import simulink.search.SearchActions;
    if~isempty(searchSystems.flat)
        flat=searchSystems.flat;
    else
        flat=SearchActions.getModelNameFromStudio(s);
    end
    rootSystemName=flat;

    editor=s.App.getActiveEditor;

    comp=[];
    if strcmpi(viewMode,'fullView')
        comp=s.getComponent('GLUE2:Finder Component','Find');
        if isempty(comp)
            comp=SearchActions.createFinderComponentUpdateTitles(searchModel);
        end
    end

    if(SLM3I.SLCommonDomain.hasFinderBrowser(editor))
        if strcmpi(viewMode,'lightView')
            SLM3I.SLCommonDomain.showFinderBrowser(editor);
        else
            if isempty(comp)
                comp=s.getComponent('GLUE2:Finder Component','Find');
            end
            if comp.isVisible
                if comp.isMinimized
                    s.showComponent(comp);
                end
            end
            s.focusComponent(comp);
            SLM3I.SLCommonDomain.moveFinderBrowserToComponent(comp,editor);
        end


        setFocusChannel=['/',studioTag,'/finder/focusSearchBox'];
        msg='focus';
        message.publish(setFocusChannel,msg);
        SetFocus=struct('message',msg,'channel',setFocusChannel);

        if slfeature('SimulinkSearchReplace')

            import simulink.search.internal.Util;
            searchReplaceChannel=['/',studioTag,Util.SEARCH_REPLACE_CHANNEL];
            searchReplaceMsg=struct();
            searchReplaceMsg.type='resetView';
            searchReplaceMsg.args={true,replaceOn};
            message.publish(searchReplaceChannel,searchReplaceMsg);
        end

    else
        connector.ensureServiceOn;
        if slfeature('SimulinkSearchReplace')
            pageUrl='/toolbox/simulink/search/web/searchReplace';
            if replaceOn
                replaceStr='true';
            else
                replaceStr='false';
            end
            dlgUrl=connector.getUrl([pageUrl,debugInfo.appendDebugStr,'.html?'...
            ,'studioTag=',studioTag...
            ,'&test=false&viewMode=',viewMode...
            ,'&replaceOn=',replaceStr...
            ,'&modelName=',SearchActions.getCurrentModelName(studioTag)]);
            lightViewWidth=362;
            lightViewHeight=73;
        else
            pageUrl='/toolbox/simulink/ui/finder/core/web/finder/searchResult';
            viewMode='lightView';
            dlgUrl=connector.getUrl([pageUrl,debugInfo.appendDebugStr,'.html?'...
            ,'studioTag=',studioTag,'&test=false']);
            lightViewWidth=290;
            lightViewHeight=30;
        end
        browserDebug=debugInfo.value;




        SLM3I.SLCommonDomain.addFinderBrowser(editor,dlgUrl,lightViewWidth,lightViewHeight,browserDebug);

        if strcmp(viewMode,'fullView')
            s.showComponent(comp);
            s.focusComponent(comp);
            SLM3I.SLCommonDomain.moveFinderBrowserToComponent(comp,editor);

            instanceManager.openSearch();
        end
    end
end


function[functions,objects,properties]=i_FinderInitialize



    functions{1}='sl_find';
    if(i_StateflowIsHere)
        functions{2}='sf_find';
    end

    objects=cell(1,length(functions));
    properties=cell(1,length(functions));
    for i=1:length(functions)
        objects{i}=feval(functions{i},'RegisterObjects');
        properties{i}=feval(functions{i},'RegisterProperties');
    end
end


function isHere=i_StateflowIsHere



    [~,mexf]=inmem;
    isHere=any(strcmp(mexf,'sf'));
    if(~isHere)
        if exist(['sf.',mexext],'file')
            isHere=1;
        end
    end
end



function addSelectListenerOnDocumentOpened(docu,documentListener)
    if docu.isvalid
        appendIndex=length(documentListener.selectionListener)+1;
        documentListener.selectionListener(appendIndex).document=docu;
        documentListener.selectionListener(appendIndex).listener=docu.addDocumentSelectionChangedListener(@(doc,old,new)selectionChangeOnCanvasCallback(doc,old,new));
    end
end



function selectionChangeOnCanvasCallback(~,~,newselection)

    selectedObjs=newselection.getElements;
    import simulink.search.SearchActions;
    shouldHandle=SearchActions.selectionTriggerStatus('GetStatus');
    if~shouldHandle&&selectedObjs.size()>0
        SearchActions.selectionTriggerStatus('SetStatus',true);
        return;
    end


    handleList=getSelectedObjectHandle(selectedObjs);

    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

    for idx=1:length(studios)
        studio=studios(idx);
        studioTag=studio.getStudioTag();
        shouldHighlight=find_slobj('GetNeedHighlightInSpreadsheetStatus',studioTag);

        if shouldHighlight


            msg=handleList;
            findChannel=['/',studioTag,'/finder/highlightResultsInSpreadsheet'];
            message.publish(findChannel,msg);
        end
    end
end




function sourceObjHandles=getSelectedObjectHandle(selectedObjs)
    objNum=selectedObjs.size();
    sourceObjHandles=zeros(1,objNum);
    for i=1:objNum
        sourceObject=selectedObjs.at(i);

        if strncmpi(class(sourceObject),'StateflowDI',11)
            sourceObjHandles(i)=sourceObject.backendId;
        elseif(~isempty(sourceObject.findprop('handle')))

            sourceObjHandle=sourceObject.handle;
            sourceUddObject=get_param(sourceObjHandle,'Object');
            sourceObjClass=class(sourceUddObject);


            if strcmpi(sourceObjClass,'Simulink.SubSystem')
                chartId=sfprivate('block2chart',sourceObjHandle);
                if chartId>0
                    chartUddH=sf('IdToHandle',chartId);
                    if~isempty(chartUddH)&&isa(chartUddH,'Stateflow.Chart')
                        sourceObjHandles(i)=chartId;
                    else
                        sourceObjHandles(i)=sourceObjHandle;
                    end
                else
                    sourceObjHandles(i)=sourceObjHandle;
                end
            elseif strcmpi(sourceObjClass,'Simulink.Line')||strcmpi(sourceObjClass,'Simulink.Segment')


                sourcePort=sourceUddObject.getSourcePort();
                if~isempty(sourcePort)
                    portHandle=sourcePort.Handle;
                    sourceObjHandles(i)=portHandle;
                end
            else
                sourceObjHandles(i)=sourceObjHandle;
            end
        end
    end


    sourceObjHandles=unique(sourceObjHandles);
end
