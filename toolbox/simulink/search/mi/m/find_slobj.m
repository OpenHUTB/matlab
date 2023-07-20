function varargout=find_slobj(varargin)









    utils.ScopedInstrumentation("find_slobj::main");
    varargout{1}=[];



    if nargin<1
        error(message('Simulink:tools:Finder_NotEnoughInputs'));
    end

    if nargin==1&&iscell(varargin{1})
        varargin=varargin{1};
    end

    Action=varargin{1};

    import simulink.search.internal.model.SearchModel;
    debugInfo=SearchModel.getDebugInfo();
    if strcmpi(Action,'setDebugMode')&&length(varargin)>1
        debugValue=varargin{2};
        debugInfo.value=debugValue;
        if debugValue
            debugInfo.appendDebugStr='-debug';
        else
            debugInfo.appendDebugStr='';
        end
        return;
    end

    if strcmpi(Action,'getDebugMode')&&length(varargin)==1
        varargout{1}=debugInfo.value;
        return;
    end

    currentStudioTag=varargin{2};
    uri=currentStudioTag;
    if isempty(currentStudioTag)
        uri='';
    end

    if strcmp(Action,'Create')
        [searchModel,instanceManager]=SearchModel.createSearchModel(uri);
    else
        searchModel=SearchModel.getSearchModel(uri);
    end
    if isempty(searchModel)
        return;
    end
    searchSystems=searchModel.searchSystems;
    documentListener=searchModel.getDocumentListener();

    args=varargin(3:end);

    import simulink.search.SearchActions;
    if slfeature('SimulinkSearchReplace')
        [returnDirectly,varargout]=SearchActions.preFindSLObjActions(varargin);
        if returnDirectly
            return;
        end
    end

    switch(Action)




    case 'Create'
        simulink.FindSystemTask.Testing.startPerfRecordingFor("find_slobj::create");
        if isempty(searchSystems.viewMode)
            searchSystems.viewMode='lightView';
        end
        SearchActions.createOpenSearchWindowImpl(...
        args{:},documentListener,instanceManager,currentStudioTag,debugInfo,false...
        );
        simulink.FindSystemTask.Testing.stopPerfRecordingFor("find_slobj::create");




    case 'CreateAdvancedDialog'


        simulink.FindSystemTask.Testing.startPerfRecordingFor("find_slobj::createAdvancedDialog");
        try
            searchSystems.advancedDialogHandler.show;
        catch
            connector.ensureServiceOn;
            dialogUrl=connector.getUrl(...
            ['/toolbox/simulink/ui/finder/core/web/finder/AdvancedSetting'...
            ,debugInfo.appendDebugStr,'.html?'...
            ,'studioTag=',searchSystems.studioTag...
            ,'&test=false']);
            debug=debugInfo.value;
            searchSystems.advancedDialog=DAStudio.FinderDDG(dialogUrl,debug);
            searchSystems.advancedDialog.Title=...
            message('simulink_ui:finder:resources:AdvancedDialogTitle',...
            searchSystems.flat).getString();
            searchSystems.advancedDialog.Geometry=[600,300,500,500];
            searchSystems.advancedDialogHandler=...
            searchSystems.advancedDialog.createStandaloneDDG();
        end
        simulink.FindSystemTask.Testing.stopPerfRecordingFor("find_slobj::createAdvancedDialog");




    case 'CloseAdvancedDialog'
        try
            searchSystems.advancedDialog.delete;
            searchSystems.advancedDialog='';
            searchSystems.advancedDialogHandler='';
        catch ME
            errordlg(i_exceptionToString(ME));
        end




    case 'Find'



        simulink.FindSystemTask.Testing.startPerfRecordingFor("find_slobj::find");
        if~isempty(searchSystems.findManager)
            findManager=searchSystems.findManager;
            findManager.imStopFind();
        end

        args{1}.containSearchString=simulink.FindSystemTask.Testing.getSearchRegexp(args{1}.containSearchString);
        if isfield(args{1},'isTest')
            searchSystems.isTest=args{1}.isTest;
        else
            searchSystems.isTest=false;
        end

        searchSystems.results=[];
        searchSystems.handleToResultIdx=containers.Map('KeyType','double','ValueType','double');
        searchSystems.parentToHierarchyType=containers.Map('KeyType','char','ValueType','char');
        if isfield(args{1},'searchId')
            searchSystems.searchId=args{1}.searchId;
        else
            searchSystems.searchId='Find';
        end

        searchSystems.finishedSearch=false;

        studioTag=searchSystems.studioTag;
        activeStudio=DAS.Studio.getStudio(studioTag);
        activeEditor=activeStudio.App.getActiveEditor();





        systemPath=SearchActions.getSystemNameFromEditor(activeEditor);
        systemPath=strrep(systemPath,newline,' ');
        if i_isValidSystem(systemPath)
            if(~isempty(searchSystems.systemName)&&~strcmp(searchSystems.systemName,systemPath))
                searchSystems.systemName=systemPath;
                rootSysName=SearchActions.getModelNameFromStudio(activeStudio);
                if~isempty(rootSysName)&&(isempty(searchSystems.flat)||~strcmp(searchSystems.flat,rootSysName))
                    searchSystems.flat=rootSysName;
                end
            end
        end


        highlightedSysList=getLoadedSys(searchSystems);


        if~isempty(searchSystems.markedResult)
            if(searchSystems.markedResult==true)

                markedObjList=searchSystems.markedObjects;
                removeMarker(markedObjList,highlightedSysList,studioTag);

            end
        end
        searchSystems.markedObjects='';
        searchSystems.markedResult=false;


        progressListener=@(resultList,findId)(find_slobj('FindAsyncProgress',studioTag,resultList,findId));
        finishListener=@(findId)(find_slobj('FindAsyncCompletion',studioTag,findId));
        searchId=searchSystems.searchId;
        findManager=FindAsyncManager(progressListener,finishListener,searchId);
        searchSystems.findManager=findManager;

        if isfield(args{1},'cancelTaskNum')
            findManager.cancelFindAfterNumOfTasks(args{1}.cancelTaskNum);
        end


        [searchModelRef,matchCriteria,findArgument]=getFindParameters(searchModel,args,activeStudio);
        searchSystems.searchModelRef=searchModelRef;
        searchSystems.matchCriteria=matchCriteria;
        searchSystems.searchModelRef.findArgument=findArgument;



        allSearchedModels=containers.Map('KeyType','char','ValueType','logical');
        sys=searchSystems.systemName;
        allSearchedModels(sys)=true;


        modelsToSearch=containers.Map('KeyType','char','ValueType','logical');

        searchSystems.searchModelRef.modelsToSearch=modelsToSearch;
        searchSystems.searchModelRef.allSearchedModels=allSearchedModels;
        searchSystems.searchModelRef.currentSearchedSys=sys;
        searchSystems.searchModelRef.modelsToBlocksMap=containers.Map('KeyType','char','ValueType','char');

        searchSystems.referencedSys={};
        searchSystems.highlightedSys={searchSystems.flat};


        updateEditorTextHighlightStyler(searchModel,args);




        if(~isempty(searchSystems.lastSelectionFcn)&&...
            ~isempty(searchSystems.lastSelection)&&...
            ~isempty(searchSystems.editor))
            i_FinderDeselectObjects(searchSystems.lastSelectionFcn,...
            searchSystems.lastSelection,highlightedSysList,'Select',searchSystems.editor,studioTag);

            searchSystems.lastSelection=-1;
            searchSystems.lastSelectionFcn='';
            searchSystems.editor='';
        end

        try
            i_FinderFind(searchSystems.functionList,...
            searchSystems.OBJECT_LIST,...
            searchSystems.findManager,...
            sys,...
            findArgument);
        catch ME
            errordlg(i_exceptionToString(ME));
        end
        simulink.FindSystemTask.Testing.stopPerfRecordingFor("find_slobj::find");




    case 'FindAsyncProgress'
        simulink.FindSystemTask.Testing.startPerfRecordingFor("find_slobj::FindAsyncProgress");
        if isempty(searchSystems.findManager)
            return;
        end

        searchModel.newResultList=args{1};
        searchId=args{2};

        findManager=searchSystems.findManager;
        currentSearchId=searchSystems.searchId;

        if(findManager.imStop||~strcmp(searchId,currentSearchId))
            return;
        end


        if~isempty(searchModel.newResultList)

            studioTag=searchSystems.studioTag;
            activeStudio=DAS.Studio.getStudio(studioTag);



            activeEditor=activeStudio.App.getActiveEditor();

            if~isempty(searchSystems.viewMode)
                viewMode=searchSystems.viewMode;
            else
                viewMode='lightView';
            end


            functionList=searchSystems.functionList;
            matchCriteria=searchSystems.matchCriteria;


            highlightedSysList=getLoadedSys(searchSystems);

            len=length(searchModel.newResultList);
            for i=1:len
                results=searchModel.newResultList(i).results;
                newMarkedObjs=highlightSearchResults(functionList,results,activeEditor,viewMode,highlightedSysList,studioTag,matchCriteria);

                if~isempty(searchSystems.markedObjects)
                    searchSystems.markedObjects.appendData(newMarkedObjs);
                else
                    searchSystems.markedObjects=StructArrayList(newMarkedObjs);
                end
            end

            searchSystems.markedResult=true;


            len=length(searchModel.newResultList);
            for i=1:len
                newResults=searchModel.newResultList(i).results;
                objectType=searchModel.newResultList(i).objectType;
                if slfeature('FindSystemSupportForReturningPropMatches')
                    i_addNewResults2(...
                    searchSystems,newResults,objectType);
                else
                    i_addNewResults(...
                    searchSystems,newResults,objectType);
                end

            end

            findManager=searchSystems.findManager;
            findCancelled=findManager.isFindCancelled&&~findManager.isFinderRunningInTest;
            if~findCancelled
                refreshUI(searchModel);
            end


            if searchSystems.isTest

                find_slobj('FindClientProgressComplete',studioTag,currentSearchId);
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("find_slobj::FindAsyncProgress");
        end




    case 'FindClientProgressComplete'
        if isempty(searchSystems.findManager)
            return;
        end

        searchId=args{1};

        findManager=searchSystems.findManager;
        currentSearchId=searchSystems.searchId;

        if(findManager.imStop||~strcmp(searchId,currentSearchId))
            return;
        end



        findManager.finishUpdatingUI();




    case 'FindAsyncCompletion'
        simulink.FindSystemTask.Testing.startPerfRecordingFor("find_slobj::FindAsyncCompletion");
        if isempty(searchSystems.findManager)
            return;
        end

        searchId=args{1};

        findManager=searchSystems.findManager;
        currentSearchId=searchSystems.searchId;

        if(findManager.imStop||~strcmp(searchId,currentSearchId))
            return;
        end


        searchFailed=searchSystems.findManager.searchFailed;
        if searchFailed
            searchSystems.finishedSearch=true;
            findFailedChannel=['/',searchSystems.studioTag,'/finder/asyncFindFailed'];
            msg=currentSearchId;
            message.publish(findFailedChannel,msg);

            return;
        end


        findCanceled=searchSystems.findManager.isFindCancelled();

        searchModelRef=searchSystems.searchModelRef;


        if searchModelRef.needSearch&&~findCanceled

            try
                currentSearchedSysName=searchModelRef.currentSearchedSys;

                if i_isValidSystem(currentSearchedSysName)
                    systemName=getSimulinkSystem(currentSearchedSysName);


                    [systems,blocks]=find_mdlrefs(systemName,'AllLevels',false,...
                    'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,...
                    'IncludeProtectedModels',false,...
                    'LookUnderMasks',searchModelRef.LookUnderMasksVal,...
                    'FollowLinks',searchModelRef.FollowLinksVal,...
                    'IgnoreVariantErrors',true,...
                    'ReturnTopModelAsLastElement',false);




                    isValid=cellfun(@i_isValidSystem,systems);
                    systems(isValid==0)=[];


                    for i=1:length(blocks)
                        block=blocks{i};


                        if strcmp(get_param(block,'ProtectedModel'),'on')
                            continue;
                        end



                        refSystem=get_param(block,'ModelName');
                        if(~searchModelRef.modelsToBlocksMap.isKey(refSystem))
                            searchModelRef.modelsToBlocksMap(refSystem)=block;
                        end
                    end


                    for i=1:length(systems)
                        nextSys=systems{i};
                        if(~searchModelRef.allSearchedModels.isKey(nextSys))
                            searchModelRef.allSearchedModels(nextSys)=true;
                            searchModelRef.modelsToSearch(nextSys)=true;

                            searchSystems.referencedSys=[searchSystems.referencedSys;systems];
                            searchSystems.highlightedSys=[searchSystems.highlightedSys;systems];
                        end
                    end

                end

            catch ME
                errordlg(i_exceptionToString(ME));
            end


            searchSystems.searchModelRef=searchModelRef;
        end

        seachFinished=isempty(searchModelRef.modelsToSearch.keys());

        if seachFinished||findCanceled
            if searchSystems.isTest
                [searchSystems.results,~]=...
                i_removeEmptyFields(searchSystems.results);
            end


            if~searchSystems.isTest
                returnMsg=struct();
                returnMsg.type='completion';
                returnMsg.searchId=currentSearchId;

                findAsyncChannel=['/',searchSystems.studioTag,'/finder/asyncFindComplete'];
                message.publish(findAsyncChannel,returnMsg);
            end

            searchSystems.finishedSearch=true;




        else

            keys=searchSystems.searchModelRef.modelsToSearch.keys();
            sys=keys{1};
            searchSystems.searchModelRef.modelsToSearch.remove(sys);


            searchSystems.searchModelRef.currentSearchedSys=sys;
            findArgument=searchSystems.searchModelRef.findArgument;

            try
                i_FinderFind(searchSystems.functionList,...
                searchSystems.OBJECT_LIST,...
                searchSystems.findManager,...
                sys,...
                findArgument);
            catch ME
                errordlg(i_exceptionToString(ME));
            end

        end
        simulink.FindSystemTask.Testing.stopPerfRecordingFor("find_slobj::FindAsyncCompletion");




    case 'CancelFind'

        if~isempty(searchSystems.findManager)
            findManager=searchSystems.findManager;
            findManager.cancelFind();
        end





    case 'ResetFind'


        if~isempty(searchSystems.findManager)
            findManager=searchSystems.findManager;
            findManager.imStopFind();
        end


        highlightedSysList=getLoadedSys(searchSystems);

        studioTag=searchSystems.studioTag;


        if~isempty(searchSystems.markedResult)
            if(searchSystems.markedResult==true)

                markedObjList=searchSystems.markedObjects;
                removeMarker(markedObjList,highlightedSysList,studioTag);

            end
        end
        searchSystems.markedObjects='';
        searchSystems.markedResult=false;




        if(~isempty(searchSystems.lastSelectionFcn)&&...
            ~isempty(searchSystems.lastSelection)&&...
            ~isempty(searchSystems.editor))
            i_FinderDeselectObjects(searchSystems.lastSelectionFcn,...
            searchSystems.lastSelection,highlightedSysList,'Select',searchSystems.editor,studioTag);

            i_ResetPropInspector(searchSystems.editor);

            searchSystems.lastSelection=-1;
            searchSystems.lastSelectionFcn='';
            searchSystems.editor='';
        end




    case 'AdvancedSearch'

        try
            if~isempty(searchSystems.advancedDialog)
                searchSystems.advancedDialog.delete;
                searchSystems.advancedDialog='';
            end
        catch ME
            errordlg(i_exceptionToString(ME));
        end


        if(SearchActions.equalToDefaultAdvancedSettings(args{1,1}))
            searchMode='simpleSearch';
            advancedParam=struct();
            searchModel.advancedParameter({});
        else
            searchMode='advancedSearch';
            searchModel.advancedParameter(args);
            advancedParam=args{1,1};
        end

        if~slfeature('SimulinkSearchReplace')

            msg=struct('mode',searchMode,'param',advancedParam);
            findChannel=['/',searchSystems.studioTag,'/finder/Find'];
            message.publish(findChannel,msg);

            searchSystems.publishMsg.Find=struct('message',msg,'channel',findChannel);
        end




    case 'SelectObjects'


        objectData=args{1};
        isDeselect=false;
        if length(args)>1
            isDeselect=args{2};
        end

        if~isDeselect
            if isempty(objectData)...
                ||~isfield(objectData,'handle')...
                ||~isfield(objectData,'functionidx')...
                ||objectData.functionidx>numel(searchSystems.functionList)
                return;
            end
            H=objectData.handle;
            F=searchSystems.functionList{objectData.functionidx};
        else
            H='';
            F='';
        end

        studioTag=searchSystems.studioTag;
        activeStudio=DAS.Studio.getStudio(studioTag);
        activeEditor=activeStudio.App.getActiveEditor();

        viewMode='lightView';
        if~isempty(searchSystems.viewMode)
            viewMode=searchSystems.viewMode;
        end


        highlightedSysList=getLoadedSys(searchSystems);


        if(~isempty(searchSystems.lastSelection))
            if(isDeselect||(H~=searchSystems.lastSelection))
                if(~isempty(searchSystems.lastSelectionFcn)&&...
                    ~isempty(searchSystems.lastSelection)&&...
                    ~isempty(searchSystems.editor))
                    i_FinderDeselectObjects(searchSystems.lastSelectionFcn,...
                    searchSystems.lastSelection,highlightedSysList,'Select',searchSystems.editor,studioTag);
                end
            end
        end

        if~isDeselect

            matchCriteria=searchSystems.matchCriteria;
            i_FinderSelectObjects(F,H,activeEditor,'Select',viewMode,highlightedSysList,studioTag,matchCriteria);
        else

            i_ResetPropInspector(activeEditor);
        end

        searchSystems.lastSelection=H;
        searchSystems.lastSelectionFcn=F;
        searchSystems.editor=activeEditor;




    case 'OpenObjects'
        objectData=args{1};
        if~isempty(objectData)||~isfield(objectData,'handle')||~isfield(objectData,'functionidx')





            SearchActions.selectionTriggerStatus('SetStatus',false);

            H=objectData.handle;
            F=searchSystems.functionList{objectData.functionidx};
            studioTag=searchSystems.studioTag;
            i_FinderOpenObjects(F,H,studioTag,searchSystems.searchModelRef.modelsToBlocksMap);
            activeStudio=DAS.Studio.getStudio(studioTag);
            activeEditor=activeStudio.App.getActiveEditor();

            if~isempty(searchSystems.viewMode)
                viewMode=searchSystems.viewMode;
            else
                viewMode='lightView';
            end

            if~slfeature('SimulinkSearchReplace')


                highlightedSysList=getLoadedSys(searchSystems);


                if(~isempty(searchSystems.lastSelection))
                    if(H~=searchSystems.lastSelection)
                        i_FinderDeselectObjects(searchSystems.lastSelectionFcn,...
                        searchSystems.lastSelection,highlightedSysList,'Select',searchSystems.editor,studioTag);
                    end
                end

                matchCriteria=searchSystems.matchCriteria;
                i_FinderSelectObjects(F,H,activeEditor,'Select',viewMode,highlightedSysList,studioTag,matchCriteria);
                searchSystems.lastSelection=H;
                searchSystems.lastSelectionFcn=F;
            end
            searchSystems.editor=activeEditor;

        end





    case 'ContextMenu'
        type=args{1};
        objectData=args{2};
        if~isempty(objectData)||~isfield(objectData,'handle')||~isfield(objectData,'functionidx')
            H=objectData.handle;
            F=searchSystems.functionList{objectData.functionidx};
            i_FinderExecuteContextMenu(F,H,type);
        end




    case 'ClearAdvancedParam'
        if~isempty(searchModel.advancedParameter)
            searchModel.advancedParameter({});
            studioTag=searchSystems.studioTag;
            resetChannel=['/',studioTag,'/finder/ResetAdvancedSetting'];
            message.publish(resetChannel,studioTag);
            searchSystems.publishMsg.ResetAdvancedSetting=...
            struct('message',studioTag,'channel',resetChannel);
        end




    case 'ResetAdvancedSetting'
        if~isempty(searchModel.advancedParameter)
            if~isempty(searchModel.advancedParameter)
                searchModel.advancedParameter({});
                resetIconChannel=['/',searchSystems.studioTag,'/finder/resetIcons'];
                msg='reset';
                message.publish(resetIconChannel,msg);
                searchSystems.publishMsg.ResetIcons=...
                struct('message',msg,'channel',resetIconChannel);
            end
        end


        varargout{1}=SearchActions.getDefaultSearchScope();
        varargout{1}.systemName=searchSystems.flat;

    case 'GetAdvancedParameters'
        if~isempty(searchModel.advancedParameter)
            varargout{1}=searchModel.advancedParameter;
        else
            varargout{1}=SearchActions.getDefaultSearchScope();
        end

    case 'ChangeViewMode'
        mode=args{1};

        activeStudio=DAS.Studio.getStudio(searchSystems.studioTag);
        activeEditor=activeStudio.App.getActiveEditor();

        finderComp=activeStudio.getComponent('GLUE2:Finder Component','Find');
        if isempty(finderComp)
            finderComp=SearchActions.createFinderComponentUpdateTitles(searchModel);
        end
        if strcmp(mode,'fullView')
            activeStudio.showComponent(finderComp);
            activeStudio.focusComponent(finderComp);
            SLM3I.SLCommonDomain.moveFinderBrowserToComponent(finderComp,activeEditor);

            searchSystems.viewMode='fullView';
        else
            SLM3I.SLCommonDomain.moveFinderBrowserToEditor(finderComp,activeEditor);
            activeStudio.hideComponent(finderComp);
            searchSystems.viewMode='lightView';
        end


        setFocusChannel=['/',searchSystems.studioTag,'/finder/focusSearchBox'];
        msg='focus';
        message.publish(setFocusChannel,msg);
        searchSystems.publishMsg.SetFocus=...
        struct('message',msg,'channel',setFocusChannel);

    case 'CloseFinder'


        if~isempty(searchSystems.findManager)
            findManager=searchSystems.findManager;
            findManager.imStopFind();
        end


        studioTag=searchSystems.studioTag;
        activeStudio=DAS.Studio.getStudio(studioTag);
        activeEditor=activeStudio.App.getActiveEditor();
        assert(...
        ~isempty(activeEditor)...
        &&SLM3I.SLCommonDomain.hasFinderBrowser(activeEditor)...
        &&strcmp(searchSystems.viewMode,'lightView'),...
'Finder light view should be on.'...
        );
        SLM3I.SLCommonDomain.removeFinderBrowser(activeEditor);


        highlightedSysList=getLoadedSys(searchSystems);


        if~isempty(searchSystems.markedResult)
            if(searchSystems.markedResult==true)
                markedObjList=searchSystems.markedObjects;
                removeMarker(markedObjList,highlightedSysList,studioTag);

            end
        end
        searchSystems.markedObjects='';
        searchSystems.markedResult=false;


        if(~isempty(searchSystems.lastSelectionFcn)&&...
            ~isempty(searchSystems.lastSelection)&&...
            ~isempty(searchSystems.editor))
            i_FinderDeselectObjects(searchSystems.lastSelectionFcn,...
            searchSystems.lastSelection,highlightedSysList,'Select',searchSystems.editor,studioTag);

            i_ResetPropInspector(searchSystems.editor);
        end

        searchModel=[];
        import simulink.search.internal.SearchInstanceManager
        instMgr=SearchInstanceManager.getSearchInstanceManager(uri);
        instMgr.closeSearch();



        if~SearchInstanceManager.hasSearchInstanceManager()&&~isempty(documentListener.openListener)
            documentListener.reset();
        end

    case 'ChangeBrowserSize'
        if(~isempty(searchSystems.viewMode))
            if strcmpi(searchSystems.viewMode,'fullView')
                return;
            end
        end
        activeStudio=DAS.Studio.getStudio(searchSystems.studioTag);
        activeEditor=activeStudio.App.getActiveEditor();
        if~isempty(activeEditor)&&isvalid(activeEditor)
            displayMode=args{1};
            if strcmpi(displayMode,'fullSize')
                SLM3I.SLCommonDomain.showFullFinderBrowser(activeEditor);
            else
                SLM3I.SLCommonDomain.showFinderSearchBoxOnly(activeEditor);
            end
        end
    case 'ClearResults'



        highlightedSysList=getLoadedSys(searchSystems);



        studioTag=searchSystems.studioTag;
        s=DAS.Studio.getStudio(studioTag);
        if~isempty(s)
            comp=s.getComponent('GLUE2:Finder Component','Find');
            if~isempty(comp)
                if comp.isVisible()
                    return;
                end
            end
        end


        if~isempty(searchSystems.findManager)
            findManager=searchSystems.findManager;
            findManager.imStopFind();
        end


        if(~isempty(searchSystems.advancedDialog))
            searchSystems.advancedDialog.delete;
            searchSystems.advancedDialog='';
        end

        if~isempty(s)&&~isempty(comp)
            editor=s.App.getActiveEditor;
            if~isempty(editor)&&(SLM3I.SLCommonDomain.hasFinderBrowser(editor))
                SLM3I.SLCommonDomain.removeFinderBrowser(editor,comp);
            end
        end


        if~isempty(searchSystems.markedResult)
            if(searchSystems.markedResult==true)
                markedObjList=searchSystems.markedObjects;
                removeMarker(markedObjList,highlightedSysList,studioTag);

            end
        end


        if(~isempty(searchSystems.lastSelectionFcn)&&...
            ~isempty(searchSystems.lastSelection)&&...
            ~isempty(searchSystems.editor))
            i_FinderDeselectObjects(searchSystems.lastSelectionFcn,...
            searchSystems.lastSelection,highlightedSysList,'Select',searchSystems.editor,studioTag);


            if isempty(args)||~strcmp(args{1},'CloseStudio')
                i_ResetPropInspector(searchSystems.editor);
            end
        end

        import simulink.search.internal.SearchInstanceManager
        instMgr=SearchInstanceManager.getSearchInstanceManager(uri);


        instMgr.closeSearch();



        if~SearchInstanceManager.hasSearchInstanceManager()&&~isempty(documentListener.openListener)
            documentListener.reset();
        end


        varargout={};

    case 'GetNeedHighlightInSpreadsheetStatus'
        shouldHighlight=false;
        if~isempty(searchModel)

            if~isempty(searchSystems.viewMode)&&strcmp(searchSystems.viewMode,'fullView')
                shouldHighlight=true;
            end
        end
        varargout{1,1}=shouldHighlight;




    case 'GetFunctionList'
        varargout{1}=searchSystems.functionList;

    case 'GetObjectList'
        varargout{1}=searchSystems.OBJECT_LIST;

    case 'GetPropertyList'
        varargout{1}=searchSystems.PROPERTY_LIST;

    case 'GetResults'
        varargout{1}=searchSystems.results;

    case 'GetPublishMessage'
        if~isempty(searchSystems.publishMsg)
            varargout{1}=searchSystems.publishMsg;
        else
            varargout{1}=struct([]);
        end

    case 'GetActiveSystem'
        varargout={searchSystems.studioTag,searchSystems.systemName};

    case 'GetLastSelection'
        varargout{1}=searchSystems.lastSelection;

    case 'GetLastSelectionFcn'
        varargout{1}=searchSystems.lastSelectionFcn;

    case 'GetAdvancedDialogHandle'
        varargout{1}=searchSystems.advancedDialogHandler;

    case 'GetSelectedObjectKey'
        selectedObject=args{1,1};
        varargout{1}=getSelectedObjectKey(selectedObject);

    case 'TestFunction'
        functionHandle=str2func(args{1,1});
        params=args{1,2};
        varargout{1}=functionHandle(params{:});

    case 'GetColumnNames'
        if~isempty(searchSystems.results)
            varargout{1}=i_getColumnNames(searchSystems.results);
        else
            varargout{1}=struct([]);
        end

    case 'GetProperty'
        propName=args{1,1};

        if strcmp(propName,'advancedParameter')
            if~isempty(searchModel.advancedParameter)
                varargout{1}=searchModel.advancedParameter;
            else
                varargout{1}=false;
            end
            return;
        end

        if~isempty(searchSystems.(propName))
            varargout{1}=searchSystems.(propName);
        else
            varargout{1}=false;
        end

    end

    if slfeature('SimulinkSearchReplace')
        [returnDirectly,newVarargout]=SearchActions.postFindSLObjActions(varargin);
        if returnDirectly
            return;
        end
        if~isempty(newVarargout{1})
            varargout{1}=newVarargout{1};
        end
    end

end


function[idx,newObjList]=i_DetermineSLFinds(f_list,o_list,objSelection)
    utils.ScopedInstrumentation("find_slobj::i_DetermineSLFinds");



    idx=[];
    count=1;
    for i=1:length(f_list)
        currObjList=o_list{i};
        sel=[];
        for j=1:length(currObjList)
            sel(j)=strcmp(objSelection(count),'true');%#ok<AGROW>
            count=count+1;
        end
        if(any(sel))
            idx=[idx,i];%#ok<AGROW>
        end
        newObjList{i}=sel;%#ok<AGROW>
    end
end


function i_FinderFind(f_list,o_list,findAsyncManager,sysName,args)


    utils.ScopedInstrumentation("find_slobj::i_FinderFind");

    sys=sysName;

    if~i_isValidSystem(sys)
        msg=message('Simulink:tools:Finder_SystemNotFound',sys);
        errordlg(msg.getString);
        findAsyncManager.startAsyncFind();
        return;
    end



    [idx,newObjList]=i_DetermineSLFinds(f_list,o_list,args{2});


    for i=1:length(idx)
        fcn=f_list{idx(i)};

        if(any(newObjList{idx(i)}))



            try

                functionIdx=idx(i);
                if strcmpi(fcn,'sl_find')
                    feval(fcn,'FindObjects',functionIdx,findAsyncManager,newObjList,sys,args(4:end));
                else
                    feval(fcn,'FindObjects',functionIdx,findAsyncManager,newObjList{idx(i)},sys,args(4:end));
                end
            catch ME
                if strcmpi(fcn,'sf_find')
                    errordlg(DAStudio.message('Simulink:tools:Finder_FailedForStateflow'))
                elseif strcmpi(fcn,'sl_find')
                    errordlg(DAStudio.message('Simulink:tools:Finder_FailedForSimulink'))
                else
                    errordlg(i_exceptionToString(ME));
                end
            end
        end
    end

    findAsyncManager.startAsyncFind();

end



function simulinkSys=getSimulinkSystem(systemName)
    utils.ScopedInstrumentation("find_slobj::getSimulinkSystem");
    isStateflow=true;
    simulinkSys=systemName;
    while isStateflow
        if~isempty(systemName)
            try
                get_param(simulinkSys,'Handle');
                isStateflow=false;
            catch
                objNames=strsplit(simulinkSys,'/');
                systemName=objNames{end};
                simulinkSys=simulinkSys(1:(length(simulinkSys)-length(systemName)-1));
                isStateflow=true;
            end
        else
            simulinkSys='';
            isStateflow=false;
        end
    end
end

function[searchModelRef,matchCriteria,findParameter]=getFindParameters(searchModel,input,activeStudio)
    utils.ScopedInstrumentation("find_slobj::getFindParameters");
    import simulink.search.SearchActions;
    findParameter={};
    searchModelRef=struct();
    matchCriteria=struct();
    input=input{1,1};
    searchSystems=searchModel.searchSystems;


    if strcmp(input.currentSystem,'top')

        searchSystems.systemName=SearchActions.getModelNameFromStudio(activeStudio);
    end
    if(~isempty(searchModel.advancedParameter))


        advancedParameter=searchModel.advancedParameter{1,1};
        findParameter{end+1}='Objects';
        findParameter{end+1}=advancedParameter.Objects;
        findParameter{end+1}=searchSystems.systemName;

        findParameter{end+1}='LookUnderMasks';
        findParameter{end+1}=advancedParameter.LookUnderMasks;
        findParameter{end+1}='FollowLinks';
        findParameter{end+1}=advancedParameter.FollowLinks;


        if(strcmp(advancedParameter.Regexp,'0'))
            regexpTag='on';
            searchStrInfo=parseSearchString(input.containSearchString,advancedParameter.Regexp);
        elseif(strcmp(advancedParameter.Regexp,'1'))
            regexpTag='on';
            searchStrInfo=parseSearchString(input.containSearchString,advancedParameter.Regexp);
            searchStrInfo.searchString=['^\s*',searchStrInfo.searchString,'\s*$'];
        else
            regexpTag='on';
            searchStrInfo=parseSearchString(input.searchString,advancedParameter.Regexp);
        end

        findParameter{end+1}='Regexp';
        findParameter{end+1}=regexpTag;
        findParameter{end+1}='CaseSensitive';
        findParameter{end+1}=advancedParameter.CaseSensitive;

        if(strcmp(input.currentSystem,'on'))
            findParameter{end+1}='SearchDepth';
            findParameter{end+1}=1;
            findParameter{end+1}=advancedParameter.searchMode;
            findParameter{end+1}=searchStrInfo;



            searchModelRef.needSearch=false;
        else
            findParameter{end+1}=advancedParameter.searchMode;
            findParameter{end+1}=searchStrInfo;


            searchModelRef.needSearch=strcmp('on',advancedParameter.LookInsideReferencedModels);
        end


        searchModelRef.LookUnderMasksVal=advancedParameter.LookUnderMasks;
        searchModelRef.FollowLinksVal=advancedParameter.FollowLinks;

        properties=advancedParameter.properties;
        if(~(isempty(properties)))
            propPairs=floor(length(properties)/2);
            for idx=1:propPairs
                value=properties{2*idx};
                properties{2*idx}=getCorrespondingRegexp(advancedParameter.Regexp,value);
            end
            findParameter=[findParameter,properties'];
        end


        matchCriteria.regexp=searchStrInfo.searchString;
        if strcmpi(advancedParameter.CaseSensitive,'on')
            matchCriteria.isCaseSensitive=true;
        else
            matchCriteria.isCaseSensitive=false;
        end
    else

        findParameter{end+1}='Objects';
        findParameter{end+1}={'true','true','true','true','true','true',...
        'true','true','true','true','true','true','true','true'};
        findParameter{end+1}=searchSystems.systemName;



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

        findParameter{end+1}='LookUnderMasks';
        findParameter{end+1}=maskedSysStatus;
        findParameter{end+1}='FollowLinks';
        findParameter{end+1}=linkedSysStatus;

        findParameter{end+1}='Regexp';
        findParameter{end+1}='on';
        findParameter{end+1}='CaseSensitive';
        findParameter{end+1}='off';


        containSearchStrMode='0';

        if(strcmp(input.currentSystem,'on'))
            findParameter{end+1}='SearchDepth';
            findParameter{end+1}=1;



            searchModelRef.needSearch=false;
        else

            searchModelRef.needSearch=strcmp('on',referencedSysStatus);
        end

        findParameter{end+1}='SimpleAndParams';
        searchStrInfo=parseSearchString(input.containSearchString,containSearchStrMode);
        findParameter{end+1}=searchStrInfo;


        searchModelRef.LookUnderMasksVal=maskedSysStatus;
        searchModelRef.FollowLinksVal=linkedSysStatus;


        matchCriteria.regexp=searchStrInfo.searchString;
        matchCriteria.isCaseSensitive=false;

    end
end



function searchInfo=parseSearchString(searchString,searchMode)
    utils.ScopedInstrumentation("find_slobj::parseSearchString");
    searchInfo=struct();



    modifierString=regexp(searchString,['^[^''":','].*(?<!\\):.*[^''"]$'],'match');

    if isempty(modifierString)

        searchInfo.hasModifier=false;





        quotedStr=regexp(searchString,['^[''"','].*(?<!\\):.*[''"]$'],'match');
        if~isempty(quotedStr)
            searchStr=searchString(2:end-1);
        else
            searchStr=regexprep(searchString,'\\:',':');
        end

        searchInfo.searchString=searchStr;
    else

        searchInfo.hasModifier=true;

        [modifier,remain]=strtok(modifierString{1},':');
        modifierValue=remain(2:end);
        searchInfo.searchString=modifierValue;

        searchInfo.modifier=modifier;
    end



    searchExp=searchInfo.searchString;
    if~strcmp(searchMode,'2')




        searchExp=strrep(searchExp,'\-','-');
        searchExp=strrep(searchExp,'\+','+');
    end


    strNumber=str2double(searchExp);

    if~isnan(strNumber)
        searchInfo.searchNumber={strNumber};
    else
        searchInfo.searchNumber={};
    end

end



function message=i_exceptionToString(ME)
    message=ME.message;
    cr=newline;

    causes=ME.cause;
    for i=1:length(causes)
        message=[message,cr,cr,i_exceptionToString(causes{i})];%#ok<AGROW>
    end
end




function validSystem=i_isValidSystem(sys)
    utils.ScopedInstrumentation("find_slobj::i_isValidSystem");

    validSystem=true;
    try
        get_param(sys,'Handle');
    catch me %#ok<NASGU>
        rootMDL=strtok(sys,'/');
        try
            load_system(rootMDL);
            get_param(sys,'Handle');
        catch me %#ok<NASGU>
            validSystem=false;
        end
    end

    if~validSystem

        try

            sfObj=getSfObjectFromFullPath(sys);
            if isempty(sfObj)
                validSystem=false;
            else
                validSystem=true;
            end
        catch
            validSystem=false;
        end
    end

end


function i_FinderSelectObjects(F,H,editor,highlightType,viewMode,highlightedSysList,studioTag,matchCriteria)
    utils.ScopedInstrumentation("find_slobj::i_FinderSelectObjects");

    try %#ok<TRYNC>
        otherParam=struct();
        otherParam.editor=editor;
        otherParam.viewMode=viewMode;
        otherParam.highlightedSystems=highlightedSysList;
        otherParam.studioTag=studioTag;
        otherParam.matchCriteria=matchCriteria;
        otherParam.highlightType=highlightType;

        feval(F,'SelectObjects',H,otherParam);
    end
end



function i_FinderDeselectObjects(F,H,systemList,Type,editor,studioTag)

    try %#ok<TRYNC>
        utils.ScopedInstrumentation("find_slobj::i_FinderDeselectObjects");
        feval(F,'DeselectObjects',H,systemList,Type,editor,studioTag);
    end
end


function i_FinderOpenObjects(F,H,studioTag,modelsToBlocksMap)
    utils.ScopedInstrumentation("find_slobj::i_FinderOpenObjects");

    import simulink.search.SearchActions;
    try
        feval(F,'OpenObjects',H,studioTag,modelsToBlocksMap);
    catch %#ok<CTCH>
        SearchActions.selectionTriggerStatus('SetStatus',true);
        msg=message('Simulink:tools:Finder_HandleNotFound');
        dlgName=getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle'));
        errordlg(msg.getString,dlgName,'modal');
    end
end


function i_FinderExecuteContextMenu(F,H,type)
    utils.ScopedInstrumentation("find_slobj::i_FinderExecuteContextMenu");

    try
        feval(F,'ContextMenu',H,type);
    catch %#ok<CTCH>
        msg=message('Simulink:tools:Finder_HandleNotFound');
        dlgName=getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle'));
        errordlg(msg.getString,dlgName,'modal');
    end
end


function i_ResetPropInspector(editor)
    utils.ScopedInstrumentation("find_slobj::i_ResetPropInspector");

    if editor.isvalid()
        diagram=editor.getDiagram();
        className=diagram.MetaClass().qualifiedName;
        if strcmpi(className,'StateflowDI.Subviewer')
            func='sf_find';
        else
            func='sl_find';
        end

        try
            feval(func,'UpdatePropertyInspector',editor);
        catch

        end
    end
end


function fieldExist=isfieldExist(structure,fieldName)
    fieldExist=false;
    if isfield(structure,fieldName)&&~isempty(structure.(fieldName))
        fieldExist=true;
    end
end





function regexpStr=getCorrespondingRegexp(matchCriteria,searchString)
    utils.ScopedInstrumentation("find_slobj::getCorrespondingRegexp");
    switch matchCriteria
    case '0'



        escapedString=regexptranslate('escape',searchString);
        regexpStr=regexprep(escapedString,{'(?<!\\)\\\?','(?<!\\)\\\*','\\\\\\\?','\\\\\\\*'},{'.','.*','\\\?','\\\*'});
    case '1'

        escapedString=regexptranslate('escape',searchString);
        regexpStr=regexprep(escapedString,{'(?<!\\)\\\?','(?<!\\)\\\*','\\\\\\\?','\\\\\\\*'},{'.','.*','\\\?','\\\*'});
        regexpStr=['^\s*',regexpStr,'\s*$'];
    otherwise
        regexpStr=searchString;
    end
end


function highlightedSysList=getLoadedSys(searchSystems)
    utils.ScopedInstrumentation("find_slobj::getLoadedSys");

    if~isempty(searchSystems.highlightedSys)
        highlightedSysList=searchSystems.highlightedSys;
    elseif~isempty(searchSystems.flat)
        highlightedSysList={searchSystems.flat};
    else
        highlightedSysList=[];
        return;
    end


    validIndex=bdIsLoaded(highlightedSysList);
    highlightedSysList=highlightedSysList(validIndex);

end


function highlightedObj=highlightSearchResults(functionList,results,editor,viewMode,highlightedSysList,studioTag,matchCriteria)
    utils.ScopedInstrumentation("find_slobj::highlightSearchResults");

    resultFunc=[results.FunctionIdx];
    handles=[results.Handle];

    otherParam=struct();
    otherParam.editor=editor;
    otherParam.viewMode=viewMode;
    otherParam.highlightedSystems=highlightedSysList;
    otherParam.studioTag=studioTag;
    otherParam.matchCriteria=matchCriteria;
    otherParam.highlightType='markObject';

    for idx=1:length(functionList)
        selectionFcn=functionList{idx};
        validIndex=(resultFunc==idx);
        validHandles=handles(validIndex);
        highlightedObj.(selectionFcn)=feval(selectionFcn,'SelectObjects',...
        validHandles,otherParam);
    end

end




function removeMarker(markedObj,systemList,studioTag)
    utils.ScopedInstrumentation("find_slobj::removeMarker");
    markedObjList=markedObj.getData();
    try

        if isfield(markedObjList,'sl_find')
            markedSlObj=[markedObjList.sl_find];
            feval('sl_find','RemoveResultsMarkedStyle',markedSlObj,studioTag);
        end


        if isfield(markedObjList,'sf_find')
            markedSfObj=[markedObjList.sf_find];
            feval('sf_find','RemoveResultsMarkedStyle',markedSfObj,systemList,studioTag);
        end

    catch ME

        errordlg(i_exceptionToString(ME));
    end

end




function updateEditorTextHighlightStyler(searchModel,input)
    utils.ScopedInstrumentation("find_slobj::updateEditorTextHighlightStyler");


    searchSystems=searchModel.searchSystems;
    if(~isempty(searchSystems.studioTag))
        studioTag=searchSystems.studioTag;
        input=input{1,1};



        searchExpr=input.containSearchString;
        caseSensitive=false;
        isMatchWholeString=false;
        searchMode='0';
        if(~isempty(searchModel.advancedParameter))

            advancedParameter=searchModel.advancedParameter{1,1};


            searchMode=advancedParameter.Regexp;


            if(strcmp(advancedParameter.Regexp,'0'))
                searchExpr=input.containSearchString;
            elseif(strcmp(advancedParameter.Regexp,'1'))
                searchExpr=input.containSearchString;
                isMatchWholeString=true;
            else
                searchExpr=input.searchString;
            end

            if strcmp(advancedParameter.CaseSensitive,'on')
                caseSensitive=true;
            else
                caseSensitive=false;
            end
        end


        searchInfo=parseSearchString(searchExpr,searchMode);
        if searchInfo.hasModifier&&~strcmpi(searchInfo.modifier,'name')
            searchExpr='';
        else
            searchExpr=searchInfo.searchString;
            if isMatchWholeString
                searchExpr=['^\s*',searchExpr,'\s*$'];
            end
        end


        styleName=MG2.TextSearchHighlightStyleName;
        textSearchHighlightStyler=diagram.style.getStyler(styleName);
        if isempty(textSearchHighlightStyler)
            diagram.style.createStyler(styleName);
            textSearchHighlightStyler=diagram.style.getStyler(styleName);
        end




        otherMatchItemHighlight=MG2.TextSearchHighlight(searchExpr,...
        caseSensitive,...
        [0,0,0,1],...
        [1,0.933,0,0.35]);
        otherMatchItemStyle=diagram.style.Style;
        otherMatchItemStyle.set(styleName,otherMatchItemHighlight);
        textSearchHighlightStyler.addRule(otherMatchItemStyle,...
        diagram.style.ClassSelector(['SimulinkFind.otherResults.',studioTag]));


        currentItemHighlight=MG2.TextSearchHighlight(searchExpr,...
        caseSensitive,...
        [0,0,0,1],...
        [1,0.933,0,1]);...

        currentItemStyle=diagram.style.Style;
        currentItemStyle.set(styleName,currentItemHighlight);
        textSearchHighlightStyler.addRule(currentItemStyle,...
        diagram.style.ClassSelector(['SimulinkFind.currentSelected.',studioTag]));

    end
end





function i_addNewResults(searchSystems,resultsToBeAppend,objectType)


    utils.ScopedInstrumentation("find_slobj::i_addNewResults");
    if~isempty(searchSystems.results)&&~isempty(resultsToBeAppend)
        if objectType==FindAsyncManager.matlabFunctionType



            updatedScript=false;
            for i=1:length(resultsToBeAppend)
                newResult=resultsToBeAppend(i);
                newResultH=newResult.Handle;
                duplicateResultIdx=find([searchSystems.results.Handle]==newResultH);
                if~isempty(duplicateResultIdx)
                    [searchSystems.results(duplicateResultIdx).Script]=deal(newResult.Script);
                    resultsToBeAppend(i)=[];

                    updatedScript=true;
                end
            end


            if updatedScript
                emptyIdx=cellfun(@isempty,{searchSystems.results.Script});
                [searchSystems.results(emptyIdx).Script]=deal('');
            end

        elseif objectType==FindAsyncManager.blockDlgParamType

            newHandles=sort([resultsToBeAppend.Handle]);
            len=numel(newHandles);
            val=newHandles(1);
            tarPos=2;
            for i=2:len
                if(newHandles(i)~=val)
                    val=newHandles(i);
                    newHandles(tarPos)=newHandles(i);
                    tarPos=tarPos+1;
                end
            end
            newHandles(tarPos:len)=[];




            updatedScript=false;
            for i=1:length(newHandles)
                newResultH=newHandles(i);
                duplicateResultIdx=find([searchSystems.results.Handle]==newResultH,1);
                if~isempty(duplicateResultIdx)
                    duplicateResult=searchSystems.results(duplicateResultIdx);
                    if isfieldExist(duplicateResult,'Script')
                        [resultsToBeAppend([resultsToBeAppend.Handle]==newResultH).Script]=deal(duplicateResult.Script);
                        updatedScript=true;
                    end



                    firstNewResult=resultsToBeAppend(1);
                    resultsToBeAppend(1)=[];

                    if~isfield(searchSystems.results,'PropertyName')
                        [searchSystems.results.PropertyName]=deal('');
                        [searchSystems.results.PropertyValue]=deal('');
                        searchSystems.existFieldNames=union(searchSystems.existFieldNames,{'PropertyName','PropertyValue'});
                    end

                    searchSystems.results(duplicateResultIdx).PropertyName=firstNewResult.PropertyName;
                    searchSystems.results(duplicateResultIdx).PropertyValue=firstNewResult.PropertyValue;

                end
            end


            if updatedScript
                emptyIdx=cellfun(@isempty,{resultsToBeAppend.Script});
                [resultsToBeAppend(emptyIdx).Script]=deal('');
            end

        end
    end

    if slfeature('SimulinkSearchReplace')
        searchSystems.appendArrayWithoutFieldOrder(resultsToBeAppend);
    else
        i_appendStructArray(searchSystems,resultsToBeAppend);
    end
end

function i_addNewResults2(searchSystems,resultsToBeAppend,objectType)


    utils.ScopedInstrumentation("find_slobj::i_addNewResults");
    if slfeature('FindSystemSupportForReturningPropMatches')==0||slfeature('SimulinkSearchReplace')==0
        return;
    end
    if~isempty(searchSystems.results)&&~isempty(resultsToBeAppend)
        if objectType==FindAsyncManager.matlabFunctionType



            numResultsToBeAppend=length(resultsToBeAppend);
            for i=1:numResultsToBeAppend
                newResult=resultsToBeAppend(i);
                newResultH=newResult.Handle;
                if isKey(searchSystems.handleToResultIdx,newResultH)
                    duplicateResultIdx=searchSystems.handleToResultIdx(newResultH);
                    [searchSystems.results(duplicateResultIdx).Script]=deal(newResult.Script);
                    resultsToBeAppend(i)=[];
                end
            end

        elseif objectType==FindAsyncManager.blockDlgParamType

            newHandles=sort([resultsToBeAppend.Handle]);
            len=numel(newHandles);
            val=newHandles(1);
            tarPos=2;
            for i=2:len
                if(newHandles(i)~=val)
                    val=newHandles(i);
                    newHandles(tarPos)=newHandles(i);
                    tarPos=tarPos+1;
                end
            end
            newHandles(tarPos:len)=[];




            updatedScript=false;
            numOfNewHandles=length(newHandles);
            for i=1:numOfNewHandles
                newResultH=newHandles(i);
                if isKey(searchSystems.handleToResultIdx,newResultH)
                    duplicateResultIdx=searchSystems.handleToResultIdx(newResultH);
                    duplicateResult=searchSystems.results(duplicateResultIdx);
                    if isfieldExist(duplicateResult,'Script')
                        [resultsToBeAppend([resultsToBeAppend.Handle]==newResultH).Script]=deal(duplicateResult.Script);
                        updatedScript=true;
                    end



                    firstNewResult=resultsToBeAppend(1);
                    resultsToBeAppend(1)=[];

                    if~isfield(searchSystems.results,'PropertyName')
                        [searchSystems.results.PropertyName]=deal('');
                        [searchSystems.results.PropertyValue]=deal('');
                        searchSystems.existFieldNames=union(searchSystems.existFieldNames,{'PropertyName','PropertyValue'});
                    end

                    searchSystems.results(duplicateResultIdx).PropertyName=firstNewResult.PropertyName;
                    searchSystems.results(duplicateResultIdx).PropertyValue=firstNewResult.PropertyValue;
                end
            end


            if updatedScript
                emptyIdx=cellfun(@isempty,{resultsToBeAppend.Script});
                [resultsToBeAppend(emptyIdx).Script]=deal('');
            end

        end
    end
    searchSystems.appendArrayWithoutFieldOrder2(resultsToBeAppend);

end


function i_appendStructArray(searchSystems,newStructArray)


    utils.ScopedInstrumentation("find_slobj::i_appendStructArray");
    if(~isempty(newStructArray))&&(~isempty(searchSystems.results))
        existFieldNames=fieldnames(searchSystems.results);
        newFieldNames=fieldnames(newStructArray);

        existFieldNames=sort(existFieldNames);
        newFieldNames=sort(newFieldNames);

        if~isequal(existFieldNames,newFieldNames)



            diffFields1=setdiff(existFieldNames,newFieldNames);
            for i=1:length(diffFields1)
                fieldName=diffFields1{i};


                newArrayLength=length(newStructArray);
                defaultValue=cell(1,newArrayLength);
                defaultValue(:)={''};

                [newStructArray.(fieldName)]=defaultValue{:};
            end



            diffFields2=setdiff(newFieldNames,existFieldNames);
            for i=1:length(diffFields2)
                fieldName=diffFields2{i};


                existArrayLength=length(searchSystems.results);
                defaultValue=cell(1,existArrayLength);
                defaultValue(:)={''};

                [searchSystems.results.(fieldName)]=defaultValue{:};
            end
        end


        searchSystems.results=[searchSystems.results,newStructArray];

    elseif(~isempty(newStructArray))&&isempty(searchSystems.results)
        searchSystems.results=newStructArray;
    end


    if~isempty(searchSystems.results)
        allFieldsName=fieldnames(searchSystems.results);
        fixedFields={'Handle';'Type';'Name';'Parent';'Source';'Destination';'FunctionIdx'};
        otherFields=setdiff(allFieldsName,fixedFields);
        newFieldsOrder=[fixedFields(1:4);otherFields;fixedFields(5:7)];
        if~isequal(allFieldsName,newFieldsOrder)
            searchSystems.results=orderfields(searchSystems.results,newFieldsOrder);
        end
    end
end



function columnNameList=i_getColumnNames(result)
    utils.ScopedInstrumentation("find_slobj::i_getColumnNames");
    totalResults=length(result);
    if totalResults>0
        allFieldNames=fieldnames(result);



        columnNameList=setdiff(allFieldNames,{'FunctionIdx','Handle'},'stable');
    else
        columnNameList={'Type';'Name';'Parent';'Source';'Destination'};
    end


    columnNameList=deblank(columnNameList(:));


    columnNameList=regexprep(columnNameList(:),'\0',' ');

end



function[results,removedField]=i_removeEmptyFields(structArray)
    utils.ScopedInstrumentation("find_slobj::i_removeEmptyFields");
    results=structArray;
    removedField=false;
    if~isempty(results)
        allFields=fieldnames(results);


        for i=1:length(allFields)
            fieldName=allFields{i};
            fixedFields={'Type';'Name';'Parent';'Source';'Destination'};
            if~ismember(fieldName,fixedFields)&&isempty([results.(fieldName)])
                results=rmfield(results,fieldName);
                removedField=true;
            end
        end
    end
end


function refreshUI(searchModel)
    utils.ScopedInstrumentation("find_slobj::refreshUI");
    searchResult=struct();
    if slfeature('SimulinkSearchReplace')
        if slfeature('FindSystemSupportForReturningPropMatches')==0
            searchModel.addPropertyInfo();
        else
            searchModel.addPropertyInfo2();
        end
        searchResult.existFieldNames=searchModel.searchSystems.existFieldNames;
    end

    searchResult.type='progress';
    searchResult.searchId=searchModel.searchSystems.searchId;
    searchResult.newResults=searchModel.newResultList;



    if searchModel.searchSystems.firstAsyncCall
        blockH=searchResult.newResults(1).results(1).Handle;
        try

            bdHandle=bdroot(blockH);
        catch

            chartId=sfprivate('getChartOf',blockH);
            sfChartObject=idToHandle(sfroot,chartId);
            if(isempty(sfChartObject))
                sfObject=idToHandle(sfroot,blockH);
                fullPath=sfObject.Path;
            else
                fullPath=sfChartObject.Path;
            end
            bdHandle=bdroot(fullPath);
        end
        searchResult.modelType=get_param(bdHandle,'BlockDiagramType');
        searchResult.modelType(1)=upper(searchResult.modelType(1));
        searchModel.searchSystems.firstAsyncCall=false;
    end

    if slfeature('SimulinkSearchReplace')
        simulink.FindSystemTask.Testing.startPerfRecordingFor("find_slobj::convertSearchResultToStruct");
        for i=1:length(searchResult.newResults)
            for j=1:length(searchResult.newResults(i).results)
                if isfield(searchResult.newResults(i).results(j),'propertycollection')



                    propCollectionStruct=struct();
                    propCollectionStruct.props=cell(length(searchResult.newResults(i).results(j).propertycollection.props),1);
                    propCollectionStruct.isDeltaUpdate=searchResult.newResults(i).results(j).propertycollection.isDeltaUpdate;
                    noOfPropsProcessed=0;


                    for k=keys(searchResult.newResults(i).results(j).propertycollection.props)

                        noOfPropsProcessed=noOfPropsProcessed+1;



                        replaceDataFound=searchResult.newResults(i).results(j).propertycollection.props(k{1});
                        newReplaceData=struct();

                        newReplaceData.propertyname=replaceDataFound.propertyname;
                        newReplaceData.id=replaceDataFound.id;
                        newReplaceData.isReadOnly=replaceDataFound.isReadOnly;
                        newReplaceData.readOnlyMessage=replaceDataFound.readOnlyMessage;


                        newReplaceData.highlighting=struct();
                        newReplaceData.highlighting.originalvalue=replaceDataFound.highlighting.originalvalue;
                        newReplaceData.highlighting.splitNonMatch=replaceDataFound.highlighting.splitNonMatch;
                        newReplaceData.highlighting.hitsubstrings=replaceDataFound.highlighting.hitsubstrings;
                        newReplaceData.highlighting.replacesubstrings=replaceDataFound.highlighting.replacesubstrings;
                        newReplaceData.highlighting.substringsReplaced=replaceDataFound.highlighting.substringsReplaced;

                        propCollectionStruct.props{noOfPropsProcessed}=newReplaceData;
                    end
                    searchResult.newResults(i).results(j).propertycollection=propCollectionStruct;
                end
            end
        end
        simulink.FindSystemTask.Testing.stopPerfRecordingFor("find_slobj::convertSearchResultToStruct");
    end
    findAsyncChannel=['/',searchModel.searchSystems.studioTag,'/finder/asyncFindProgress'];
    simulink.FindSystemTask.Testing.startPerfRecordingFor("find_slobj::publishResultsOnChannel");
    message.publish(findAsyncChannel,searchResult);
    simulink.FindSystemTask.Testing.stopPerfRecordingFor("find_slobj::publishResultsOnChannel");
end
