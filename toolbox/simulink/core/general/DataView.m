classdef DataView<handle





    properties
        m_Source;
        m_Views;
        m_TabVisibility;
        m_Perspectives;
        m_TabsWithTreeExpansion;
        m_currentPerspective;
        m_ssComponent;
        m_Scope;
        m_CurrentTab;
        m_ViewSort;
        m_IndividualMappingListeners;
        m_paramTunabilityListener;
        m_MappingCreationListeners;
        m_GRTCEventList;
        m_ERTCEventList;
        m_AutosarEventList;
        m_AutosarCppEventList;
        m_CppEventList;
        m_HDLEventList;
        m_SimStatusListener;
        m_GroupDetails;
        m_SelectionFilter;
        m_ShowReferences;

        m_EditorChangeListenerID=[];
        m_CurrentMappingType;
        m_pendingSelection;
        m_pendingSelectionTabName;
    end
    methods(Static,Access=public)
        function refreshSpreadSheet(bdHandle,id)
            editors=GLUE2.Util.findAllEditors(get_param(bdHandle,'Name'));
            for ii=1:numel(editors)
                studio=editors(ii).getStudio;
                comp=studio.getComponent('GLUE2:SpreadSheet',id);
                if~isempty(comp)
                    myDlg=comp.getTitleView();
                    myDlg.refresh;
                end
            end
        end

        function onStatusChanged(thisObj)
            removeReferencedData(thisObj.m_Source,thisObj.m_ssComponent.getName());

            if~isempty(thisObj.m_ssComponent)&&thisObj.m_ssComponent.isvalid
                thisObj.m_ssComponent.setTitleViewSource(thisObj);
            end
        end
        function onSimStatusChanged(thisObj,~)
            if~isempty(thisObj.m_ssComponent)&&thisObj.m_ssComponent.isvalid
                thisObj.m_ssComponent.update(true);
            end
        end
        function onReadonlyChanged(thisObj,~)
            if~isempty(thisObj.m_ssComponent)&&thisObj.m_ssComponent.isvalid
                thisObj.m_ssComponent.update(true);
            end
        end
        function onPropertyChanged(thisObj,obj)
            if~isempty(thisObj.m_ssComponent)&&thisObj.m_ssComponent.isvalid
                if~isempty(obj.Source)
                    if obj.Source==thisObj.m_Source
                        if strcmp(obj.String,'BlockDiagramName')
                            thisObj.m_ssComponent.update(true);
                        else
                            thisObj.m_ssComponent.update(obj.Source);
                        end
                    else
                        thisObj.m_ssComponent.update(obj.Source);
                    end
                else
                    thisObj.m_ssComponent.update(true);
                end
            end
        end

        function refreshSpreadSheetTitle(ssComponent,modelHandle)
            title=Simulink.CodeMapping.getTitle(modelHandle);
            ssComponent.setMinimizeTabTitle(title);
            ssComponent.setTitle(title);
        end

        function handleCanvasChanged(ssComponent,currentSystem,thisObj)
            tabsToRemove=[];
            lastVisibleTab=0;

            if~isempty(currentSystem)
                for tabId=1:length(thisObj.m_Views)

                    if thisObj.isTabVisible(thisObj.m_Views{tabId},currentSystem)
                        if~thisObj.m_TabVisibility{tabId}
                            thisObj.m_TabVisibility{tabId}=true;
                            ssComponent.insertTab(lastVisibleTab,thisObj.m_Views{tabId,2},...
                            thisObj.m_Views{tabId,1},...
                            thisObj.m_Views{tabId,2});
                        end
                        lastVisibleTab=lastVisibleTab+1;


                    else
                        if thisObj.m_TabVisibility{tabId}

                            lastVisibleTab=lastVisibleTab+1;
                            tabsToRemove{end+1}=thisObj.m_Views{tabId,1};
                            thisObj.m_TabVisibility{tabId}=false;
                        end
                    end
                end
                for idx=1:length(tabsToRemove)
                    tabName=tabsToRemove{idx};
                    ssComponent.removeNamedTab(tabName);
                end
            end

            ssComponent.setTitleViewSource(thisObj);
        end

        function retVal=handleItemsDblClicked(ssComponent,item,thisObj)
            selection=item{1};
            retVal=selection.handleDblClick;
        end

        function retVal=handleItemContextMenu(ssComponent,item,thisObj)
            retVal=[];
            propSch=item.getPropertySchema;
            if isa(propSch,'Simulink.InterfaceDataPropertySchema')
                retVal=propSch.getContextMenu(ssComponent,item);
            end
        end

        function handleGroupChanged(ssComponent,groupCol,thisObj)
            thisObj.setGroupDetails(thisObj.m_CurrentTab,groupCol);
        end

        function handleSortChanged(ssComponent,col,order,thisObj)
            oldSort=thisObj.getSortDetails(thisObj.m_CurrentTab);
            thisObj.setSortDetails(thisObj.m_CurrentTab,col,order);
            if(~isequal(col,oldSort{1}))
                ssComponent.update();
            end
        end

        function handleTabChanged(ssComponent,tabName,thisObj)

            thisObj.m_CurrentTab=tabName;
            thisObj.fillPerspectives(tabName);

            oldScope=thisObj.m_Scope;

            ssComponent.setTitleViewSource(thisObj);

            dlg=DAStudio.ToolRoot.getOpenDialogs(thisObj);
            found=false;
            for i=1:length(thisObj.m_Perspectives)
                if isequal(thisObj.m_currentPerspective,thisObj.m_Perspectives{i})
                    dlg.setWidgetValue('dataview_perspective',i-1);
                    found=true;
                    break;
                end
            end

            if~found
                thisObj.m_currentPerspective=thisObj.m_Perspectives{1};
                dlg.setWidgetValue('dataview_perspective',0)
            end

            groupColumn=getGroupDetails(thisObj,tabName);
            if(useHierarchicalSpreadsheet(thisObj,tabName))
                ssComponent.enableHierarchicalView(true);
            else
                ssComponent.enableHierarchicalView(false);
            end
            columns=getViewColumns(thisObj,tabName,thisObj.m_currentPerspective);
            sortDetails=thisObj.getSortDetails(thisObj.m_CurrentTab);
            ssComponent.setColumns(columns,sortDetails{1},groupColumn,sortDetails{2});
            expandTreesIfNeeded(thisObj);

            if~isequal(oldScope,thisObj.m_Scope)
                ssComponent.setScope(thisObj.m_Scope);
            else
                ssComponent.update();
            end

        end

        function handleHelpClicked(~,obj)
            schName=getViewSchema(obj.m_Source,obj.m_ssComponent.getName(),obj.m_CurrentTab);
            propSch=eval([schName,'(obj)']);

            propSch.handleHelp(obj.m_currentPerspective);
        end

        function handleLoadingComplete(ssComponent,tabName,thisObj)
            if~isempty(thisObj.m_pendingSelection)&&isequal(tabName,thisObj.m_pendingSelectionTabName)
                ssComponent.view(thisObj.m_pendingSelection);
                thisObj.m_pendingSelection=[];
                thisObj.m_pendingSelectionTabName=[];
            end
        end


        function createSpreadSheetComponent(studio,forceshow,...
            userDataorShowMinimized)


            comp=studio.getComponent('GLUE2:SpreadSheet','ModelData');
            if isempty(comp)

                comp=GLUE2.SpreadSheetComponent(studio,'ModelData');
                studio.registerComponent(comp);
                compTitle=DAStudio.message('Simulink:studio:DataViewMenu');
                comp.ExplicitShow=~forceshow;
                comp.ShowMinimized=false;
                if islogical(userDataorShowMinimized)
                    comp.ShowMinimized=userDataorShowMinimized;
                end
                bdHandle=studio.App.blockDiagramHandle;
                obj=DataView(get_param(bdHandle,'Object'),comp);
                comp.PersistState=true;
                studio.moveComponentToDock(comp,compTitle,'Bottom','Tabbed');
                comp.CreateCallback='DataView.createSpreadSheetComponent';
                comp.setTitleViewSource(obj);
                comp.setCurrentTab(0);
            else
                comp.ShowMinimized=false;
                if islogical(userDataorShowMinimized)
                    comp.ShowMinimized=userDataorShowMinimized;
                end
                if~comp.isVisible
                    studio.showComponent(comp);
                    if~comp.ShowMinimized
                        studio.focusComponent(comp);
                    end
                else
                    studio.hideComponent(comp);
                end
            end
            comp.ShowMinimized=false;
        end
        function showModelData(studio,componentName,tab,view)
            comp=studio.getComponent('GLUE2:SpreadSheet',componentName);
            if isempty(comp)
                DataView.createSpreadSheetComponent(studio,true,false);
                comp=studio.getComponent('GLUE2:SpreadSheet',componentName);
            end

            myDlg=comp.getTitleView();
            thisObj=myDlg.getDialogSource;
            thisObj.m_currentPerspective=view;

            newTab=0;
            src=get_param(studio.App.blockDiagramHandle,'Object');
            if~isempty(tab)
                for idx=1:length(thisObj.m_Views)
                    if thisObj.isTabVisible(thisObj.m_Views{idx},src)
                        if contains(thisObj.m_Views{idx},tab)
                            break;
                        end
                        newTab=newTab+1;
                    end
                end
            end
            if~isequal(newTab,comp.getCurrentTab())
                comp.setCurrentTab(newTab);
            else
                for i=1:length(thisObj.m_Perspectives)
                    if isequal(view,thisObj.m_Perspectives{i})
                        myDlg.setWidgetValue('dataview_perspective',i-1);
                        thisObj.handlePerspective(myDlg);
                        break;
                    end
                end
            end

            if~comp.isVisible
                studio.showComponent(comp);
                studio.focusComponent(comp);
            end
        end
    end
    methods
        function this=DataView(src,ss)
            this.DataView_initProperties(src,ss);
            this.DataView_initListeners(src,ss);
        end

        function DataView_initProperties(obj,src,ss)
            slModelDataEditor;
            obj.m_TabVisibility={};
            obj.m_Source=src;

            ssName=ss.getName();
            if strcmp(ssName,'HDLCodeProperties')
                obj.m_CurrentMappingType='HDLTarget';
                obj.m_Views=getViews(obj.m_Source,ssName,obj.m_CurrentMappingType);
            elseif any(strcmp(ssName,{'CodeProperties','DefaultsProperties'}))
                modelName=get_param(bdroot(src.Handle),'Name');
                [~,obj.m_CurrentMappingType]=Simulink.CodeMapping.getCurrentMapping(modelName);
                obj.m_Views=getViews(obj.m_Source,ssName,obj.m_CurrentMappingType);
            else
                obj.m_Views=getViews(obj.m_Source,ssName,'');
            end
            obj.m_ssComponent=ss;
            numTabs=size(obj.m_Views,1);
            for idx=1:numTabs
                obj.m_GroupDetails{idx}=getDefaultGroup(obj,obj.m_Views{idx});
            end
            for tabId=1:numTabs
                if obj.isTabVisible(obj.m_Views{tabId},src)||contains(obj.m_Views{tabId},'HDL')
                    if isempty(obj.m_CurrentTab)

                        obj.m_CurrentTab=obj.m_Views{tabId};
                    end
                    ss.addTab(obj.m_Views{tabId,2},obj.m_Views{tabId,1},obj.m_Views{tabId,2});
                    obj.m_TabVisibility{end+1}=true;




                else
                    obj.m_TabVisibility{end+1}=false;
                end
            end
            if isempty(obj.m_CurrentTab)
                obj.m_CurrentTab=obj.m_Views{1};
                assert(true,'No tabs are visible');
            end
            obj.fillPerspectives(obj.m_CurrentTab);
            obj.m_currentPerspective=obj.m_Perspectives{1};
            obj.m_Scope=0;
            obj.m_SelectionFilter=0;
            for idx=1:numTabs
                obj.m_ViewSort{idx}=getDefaultSort(obj,obj.m_Views{idx});
            end
            obj.m_pendingSelection=[];
            obj.m_pendingSelectionTabName=[];
            obj.m_ShowReferences=true;
            obj.m_ssComponent.setComponentUserData(obj.m_ShowReferences);
            obj.m_ssComponent.onHelpClicked=@(ss_src)DataView.handleHelpClicked(ss_src,obj);
            obj.m_GRTCEventList={'InportMappingEntityAdded','InportMappingEntityDeleted',...
            'OutportMappingEntityAdded','OutportMappingEntityDeleted',...
            'DataStoreMappingEntityAdded','DataStoreMappingEntityDeleted',...
            'ParameterMappingEntityAdded','ParameterMappingEntityDeleted',...
            'SignalMappingEntityAdded','SignalMappingEntityDeleted',...
            'StateMappingEntityAdded','StateMappingEntityDeleted',...
            'DeploymentTypeUpdated'};
            obj.m_ERTCEventList={'InportMappingEntityAdded','InportMappingEntityDeleted',...
            'OutportMappingEntityAdded','OutportMappingEntityDeleted',...
            'EPFMappingEntityAdded','EPFMappingEntityDeleted',...
            'DataStoreMappingEntityAdded','DataStoreMappingEntityDeleted',...
            'ParameterMappingEntityAdded','ParameterMappingEntityDeleted',...
            'SignalMappingEntityAdded','SignalMappingEntityDeleted',...
            'StateMappingEntityAdded','StateMappingEntityDeleted',...
            'DeploymentTypeUpdated'};
            obj.m_AutosarEventList={'InportMappingEntityAdded','InportMappingEntityDeleted',...
            'OutportMappingEntityAdded','OutportMappingEntityDeleted',...
            'EPFMappingEntityAdded','EPFMappingEntityDeleted',...
            'DataStoreMappingEntityAdded','DataStoreMappingEntityDeleted',...
            'ParameterMappingEntityAdded','ParameterMappingEntityDeleted',...
            'SignalMappingEntityAdded','SignalMappingEntityDeleted',...
            'StateMappingEntityAdded','StateMappingEntityDeleted'};
            obj.m_AutosarCppEventList={'InportMappingEntityAdded','InportMappingEntityDeleted',...
            'OutportMappingEntityAdded','OutportMappingEntityDeleted',...
            'ClientPortMappingEntityAdded','ClientPortMappingEntityDeleted',...
            'ServerPortMappingEntityAdded','ServerPortMappingEntityDeleted',...
            'EPFMappingEntityAdded','EPFMappingEntityDeleted',...
            'DataStoreMappingEntityAdded','DataStoreMappingEntityDeleted'};
            obj.m_CppEventList={'DeploymentTypeUpdated',...
            'EPFMappingEntityAdded','EPFMappingEntityDeleted',...
            'InportMappingEntityAdded','InportMappingEntityDeleted',...
            'OutportMappingEntityAdded','OutportMappingEntityDeleted'};
            obj.m_HDLEventList={'InportMappingEntityAdded','InportMappingEntityDeleted',...
            'OutportMappingEntityAdded','OutportMappingEntityDeleted'...
            ,'SignalMappingEntityAdded','SignalMappingEntityDeleted'};

        end

        function DataView_initListeners(obj,~,ss)
            ssName=ss.getName();
            if any(strcmp(ssName,{'CodeProperties','HDLCodeProperties'}))
                obj.updateIndividualMappingListeners();

                obj.registerEditorChangeListener();
            end
            hFcnCompiled=@(blkDiagObj,listenerObj)DataView.onStatusChanged(obj);
            obj.m_SimStatusListener{1}=Simulink.listener(obj.m_Source.Handle,'EngineCompPassed',hFcnCompiled);
            obj.m_SimStatusListener{2}=Simulink.listener(obj.m_Source.Handle,'EngineCompFailed',hFcnCompiled);
            hFcnSimStatusChanged=@(obj,e)DataView.onSimStatusChanged(obj,e);
            dispatcher=DAStudio.EventDispatcher;
            obj.m_SimStatusListener{3}=handle.listener(dispatcher,'SimStatusChangedEvent',@(s,e)hFcnSimStatusChanged(obj,e));
            hFcnReadonlyChanged=@(obj,e)DataView.onReadonlyChanged(obj,e);
            obj.m_SimStatusListener{4}=handle.listener(dispatcher,'ReadonlyChangedEvent',@(s,e)hFcnReadonlyChanged(obj,e));
            hFcnPropertyChanged=@(obj,e)DataView.onPropertyChanged(obj,e);
            obj.m_SimStatusListener{5}=handle.listener(dispatcher,'PropertyChangedEvent',@(s,e)hFcnPropertyChanged(obj,e));
        end


        function registerIndividualMappingListners(obj,mapping,eventList)
            obj.m_IndividualMappingListeners={};
            for i=1:length(eventList)
                obj.m_IndividualMappingListeners{i}=event.listener(mapping,eventList{i},...
                @obj.RefreshCodeMappings);
            end
        end



        function updateIndividualMappingListeners(obj)
            modelHandle=bdroot(obj.m_Source.Handle);
            modelName=get_param(modelHandle,'Name');
            [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelName);
            if strcmp(obj.m_ssComponent.getName,'HDLCodeProperties')
                mmgr=get_param(modelHandle,'MappingManager');
                hdlMapping=mmgr.getActiveMappingFor('HDLTarget');
                if~isempty(hdlMapping)
                    obj.registerIndividualMappingListners(hdlMapping,obj.m_HDLEventList);
                end
            elseif strcmp(mappingType,'AutosarTargetCPP')

                obj.registerIndividualMappingListners(mapping,obj.m_AutosarCppEventList);
            elseif strcmp(mappingType,'AutosarTarget')
                obj.registerIndividualMappingListners(mapping,obj.m_AutosarEventList);

            elseif strcmp(mappingType,'CppModelMapping')
                obj.registerIndividualMappingListners(mapping,obj.m_CppEventList);
            elseif strcmp(mappingType,'SimulinkCoderCTarget')
                obj.registerIndividualMappingListners(mapping,obj.m_GRTCEventList);
                obj.m_paramTunabilityListener=configset.ParamListener(modelHandle,'DefaultParameterBehavior',@obj.RefreshDataDefaults);
            else
                obj.registerIndividualMappingListners(mapping,obj.m_ERTCEventList);
                obj.m_paramTunabilityListener=configset.ParamListener(modelHandle,'DefaultParameterBehavior',@obj.RefreshDataDefaults);
            end
        end

        function RefreshCodeMappings(obj,~,eventData)
            if~isvalid(obj.m_ssComponent)||~obj.m_ssComponent.isVisible
                return
            end
            if eventData.EventName=="DeploymentTypeUpdated"
                DataView.handleCanvasChanged(obj.m_ssComponent,obj.m_Source,obj);



                columns=getViewColumns(obj,obj.m_CurrentTab,obj.m_currentPerspective);
                sortDetails=obj.getSortDetails(obj.m_CurrentTab);


                if isempty(sortDetails)
                    return;
                end
                groupColumn=getGroupDetails(obj,obj.m_CurrentTab);
                obj.m_ssComponent.setColumns(columns,sortDetails{1},groupColumn,sortDetails{2});
                obj.m_ssComponent.update();

                DataView.refreshSpreadSheetTitle(obj.m_ssComponent,obj.m_Source.handle)
                return;
            end
            schName=getViewSchema(obj.m_Source,obj.m_ssComponent.getName(),obj.m_CurrentTab);
            propSch=eval([schName,'(obj)']);
            if(propSch.needsRefresh(eventData))
                obj.m_ssComponent.update();
            end
        end

        function RefreshDataDefaults(obj,~,~,~)
            if~isvalid(obj.m_ssComponent)||~obj.m_ssComponent.isVisible
                return
            end
            if contains(obj.m_CurrentTab,'DataDefaults')
                obj.m_ssComponent.update();
            end
        end


        function registerEditorChangeListener(obj)
            if isempty(obj.m_ssComponent)

            else
                studio=obj.m_ssComponent.getStudio;
                c=studio.getService('GLUE2:ActiveEditorChanged');
                unRegisterEditorChangeListener(obj);
                obj.m_EditorChangeListenerID=c.registerServiceCallback(@obj.handleEditorChanged);
            end
        end


        function unRegisterEditorChangeListener(obj)
            if isempty(obj.m_ssComponent)

            else
                studio=obj.m_ssComponent.getStudio;
                c=studio.getService('GLUE2:ActiveEditorChanged');
                if~isempty(obj.m_EditorChangeListenerID)

                    c.unRegisterServiceCallback(obj.m_EditorChangeListenerID);
                    obj.m_EditorChangeListenerID=[];
                end
            end
        end



        function handleEditorChanged(obj,~)
            oldModelHdl=obj.m_Source.Handle;
            [oldMapping,oldMappingType]=Simulink.CodeMapping.getCurrentMapping(oldModelHdl);

            studio=obj.m_ssComponent.getStudio;
            editor=studio.App.getActiveEditor;
            newModelHdl=editor.blockDiagramHandle;
            newModelObj=get_param(newModelHdl,'Object');
            [newMapping,newMappingType]=Simulink.CodeMapping.getCurrentMapping(newModelHdl);

            if(oldModelHdl==newModelHdl)

                return
            end


            obj.m_Source=newModelObj;



            if~isempty(newMapping)&&strcmp(oldMappingType,newMappingType)
                expandTreesIfNeeded(obj);


                obj.updateIndividualMappingListeners();


                title=Simulink.CodeMapping.getTitle(newModelHdl);
                obj.m_ssComponent.setTitle(title);



                if strcmp(newMappingType,'AutosarTarget')||...
                    (strcmp(newMappingType,'CoderDictionary')...
                    &&(newMapping.isFunctionPlatform~=oldMapping.isFunctionPlatform...
                    ||~isequal(newMapping.DeploymentType,oldMapping.DeploymentType)))

                    schName=getViewSchema(obj.m_Source,obj.m_ssComponent.getName(),obj.m_CurrentTab);
                    propSch=eval([schName,'(obj)']);

                    DataView.handleCanvasChanged(obj.m_ssComponent,newModelObj,obj);


                    obj.m_ssComponent.setCurrentTab(0);
                    needsRefresh=propSch.needsRefreshForMappingChange(obj.m_currentPerspective);
                    if needsRefresh
                        if~isempty(obj.m_Source)
                            columns=getViewColumns(obj,obj.m_CurrentTab,obj.m_currentPerspective);
                        else
                            columns={' ','Name'};
                        end
                        sortDetails=obj.getSortDetails(obj.m_CurrentTab);
                        groupName=obj.getGroupDetails(obj.m_CurrentTab);
                        obj.m_ssComponent.setColumns(columns,sortDetails{1},groupName,sortDetails{2});
                        obj.m_ssComponent.update();
                    end
                end
            end
        end


        function dlgStruct=getDialogSchema(obj,~)
            obj.m_ssComponent.onTabChange=@(src,id)DataView.handleTabChanged(src,id,obj);
            obj.m_ssComponent.onSortChange=@(src,col,order)DataView.handleSortChanged(src,col,order,obj);
            obj.m_ssComponent.onGroupChange=@(src,grp)DataView.handleGroupChanged(src,grp,obj);
            obj.m_ssComponent.onItemAdded=@(src,sys)DataView.handleCanvasChanged(src,sys,obj);
            obj.m_ssComponent.onItemsDblClicked=@(src,item)DataView.handleItemsDblClicked(src,item,obj);
            obj.m_ssComponent.onContextMenuRequest=@(src,item)DataView.handleItemContextMenu(src,item,obj);
            obj.m_ssComponent.onLoadingComplete=@(src,tabName)DataView.handleLoadingComplete(src,tabName,obj);
            if strcmp(obj.m_ssComponent.getName,'ModelData')
                setRefreshListeners(obj);

                workspaceButton.Type='pushbutton';
                workspaceButton.Tag='dataview_mws_button';
                workspaceButton.ToolTip=DAStudio.message('Simulink:studio:DataView_mws_tooltip');
                workspaceButton.FilePath=fullfile(matlabroot,'toolbox',...
                'shared','dastudio','resources','glue','Toolbars',...
                '16px','DictionaryModelIcon_16.png');
                workspaceButton.RowSpan=[1,1];
                workspaceButton.ColSpan=[2,2];
                workspaceButton.PreferredSize=[28,24];
                workspaceButton.ObjectMethod='handleMWS';
                workspaceButton.MethodArgs={'%dialog'};
                workspaceButton.ArgDataTypes={'handle'};
                workspaceButton.Enabled=~(obj.m_Source.isLibrary);

                scopeButton.Type='togglebutton';
                scopeButton.Tag='dataview_scope_button';
                scopeButton.ToolTip=DAStudio.message('Simulink:studio:DataView_scope_tooltip');
                scopeButton.FilePath=fullfile(matlabroot,'toolbox',...
                'shared','dastudio','resources','currentsystem.png');
                scopeButton.RowSpan=[1,1];
                scopeButton.ColSpan=[4,4];
                scopeButton.PreferredSize=[28,24];
                scopeButton.ObjectMethod='handleScopeOption';
                scopeButton.MethodArgs={'%dialog','%value'};
                scopeButton.ArgDataTypes={'handle','mxArray'};
                scopeButton.Graphical=true;
                scopeButton.Enabled=isCSBAllowed(obj,obj.m_CurrentTab);
                if~scopeButton.Enabled
                    obj.m_Scope=0;
                end
                scopeButton.Value=obj.m_Scope;


                aBDHdl=obj.m_Source.Handle;
                maskEditorButton.Type='pushbutton';
                maskEditorButton.Tag='maskeditor_button';

                bIsModelAlreadyMasked=slInternal('isModelAlreadyMasked',aBDHdl);
                if(bIsModelAlreadyMasked)
                    maskEditorButton.ToolTip=DAStudio.message('Simulink:dialog:DataViewEditModelMaskToolTip');
                else
                    maskEditorButton.ToolTip=DAStudio.message('Simulink:dialog:DataViewCreateModelMaskToolTip');
                end
                maskEditorButton.Enabled=slInternal('isCreateOrEditModelMaskEnabled',aBDHdl);
                maskEditorButton.Visible=slfeature('BlockParameterConfiguration')>0;
                maskEditorButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','MaskedSubsystemIcon.gif');
                maskEditorButton.RowSpan=[1,1];
                maskEditorButton.ColSpan=[4,4];
                maskEditorButton.PreferredSize=[28,24];
                maskEditorButton.ObjectMethod='handleOpenMaskEditor';
                maskEditorButton.MethodArgs={'%dialog'};
                maskEditorButton.ArgDataTypes={'handle'};

                perspectiveChoice.Type='combobox';
                perspectiveChoice.Tag='dataview_perspective';
                perspectiveChoice.ToolTip=DAStudio.message('Simulink:studio:DataView_perspective_tooltip');
                perspectiveChoice.RowSpan=[1,1];
                perspectiveChoice.ColSpan=[1,1];
                perspectiveChoice.Entries=obj.m_Perspectives;
                perspectiveChoice.ObjectMethod='handlePerspective';
                perspectiveChoice.MethodArgs={'%dialog'};
                perspectiveChoice.ArgDataTypes={'handle'};
                perspectiveChoice.Graphical=true;
                for i=1:length(obj.m_Perspectives)
                    if isequal(obj.m_currentPerspective,obj.m_Perspectives{i})
                        perspectiveChoice.Value=i-1;
                        break;
                    end
                end

                refreshButton.Type='pushbutton';
                refreshButton.Tag='dataview_refresh_button';
                refreshButton.ToolTip=DAStudio.message('Simulink:studio:DataView_Refresh_Tooltip');
                if obj.needRefresh()
                    refreshButton.FilePath=fullfile(matlabroot,'toolbox',...
                    'shared','dastudio','resources','UpdateDiagramWarn_16.png');
                else
                    refreshButton.FilePath=fullfile(matlabroot,'toolbox',...
                    'shared','dastudio','resources','glue','Toolbars',...
                    '16px','UpdateDiagram_16.png');
                end
                refreshButton.RowSpan=[1,1];
                refreshButton.ColSpan=[2,2];
                refreshButton.PreferredSize=[28,24];
                refreshButton.ObjectMethod='handleRefresh';
                refreshButton.MethodArgs={'%dialog'};
                refreshButton.ArgDataTypes={'handle'};
                refreshButton.Visible=obj.m_ShowReferences&&~(obj.m_Source.isLibrary);
                refreshButton.Enabled=obj.m_ShowReferences&&~(obj.m_Source.isLibrary);
                refreshButton.Graphical=true;

                filterButton.Type='togglebutton';
                filterButton.Tag='dataview_autofilter_button';
                filterButton.ToolTip=DAStudio.message('Simulink:studio:DataView_FilterSelection_Tooltip');
                filterButton.FilePath=fullfile(matlabroot,'toolbox',...
                'shared','dastudio','resources','FilterSelection.png');
                filterButton.RowSpan=[1,1];
                filterButton.ColSpan=[1,1];
                filterButton.PreferredSize=[28,24];
                filterButton.ObjectMethod='handleAutoFilter';
                filterButton.MethodArgs={'%dialog','%value'};
                filterButton.ArgDataTypes={'handle','mxArray'};
                filterButton.Graphical=true;
                filterButton.Visible=true;

                filterButton.Value=obj.m_SelectionFilter;
                filterButton.Enabled=true;

                spacerWidget.Type='panel';
                spacerWidget.RowSpan=[1,1];
                spacerWidget.ColSpan=[5,5];

                filterWidget.Type='spreadsheetfilter';
                filterWidget.Tag='dataviewspreadsheetfilter';
                filterWidget.PlaceholderText=DAStudio.message('Simulink:studio:DataView_default_filter');
                filterWidget.Clearable=true;
                filterWidget.RowSpan=[1,1];
                filterWidget.ColSpan=[2,2];

                standardPanel.Type='panel';
                standardPanel.Items={perspectiveChoice,scopeButton,...
                };
                standardPanel.LayoutGrid=[1,3];
                standardPanel.RowSpan=[1,1];
                standardPanel.ColSpan=[1,1];

                referencePanel.Type='panel';
                referencePanel.Spacing=0;
                referencePanel.ContentsMargins=[0,0,0,0];
                referencePanel.Items={refreshButton};
                referencePanel.LayoutGrid=[1,2];
                referencePanel.RowSpan=[1,1];
                referencePanel.ColSpan=[2,2];

                filterPanel.Type='panel';
                filterPanel.Spacing=0;
                filterPanel.ContentsMargins=[0,0,0,0];
                filterPanel.Items={filterButton,filterWidget};
                filterPanel.LayoutGrid=[1,2];
                filterPanel.RowSpan=[1,1];
                filterPanel.ColSpan=[4,4];

                obj.m_ssComponent.setMultiFilter(true);

                titlePanel.Type='panel';
                titlePanel.Items={standardPanel,...
                referencePanel,...
                spacerWidget,filterPanel};
                titlePanel.LayoutGrid=[1,4];
                titlePanel.ColStretch=[0,0,1,0];
                dlgStruct.Spacing=0;
                dlgStruct.ContentsMargins=[0,0,0,0];
                dlgStruct.DialogTag='dataview_dlg';
            elseif any(strcmp(obj.m_ssComponent.getName,{'CodeProperties','HDLCodeProperties','DefaultsProperties'}))
                maxItemsInPanel=12;
                codePropBtnNdx=1;


                spacerWidget.Type='panel';
                spacerWidget.RowSpan=[1,1];
                spacerWidget.ColSpan=[5,5];


                filterWidget.Type='spreadsheetfilter';
                filterWidget.Tag='dataviewspreadsheetfilter';
                filterWidget.PlaceholderText=DAStudio.message('Simulink:studio:DataView_default_filter');
                filterWidget.Clearable=true;
                filterWidget.RowSpan=[1,1];
                filterWidget.ColSpan=[2,2];
                filterWidget.ColSpan=[maxItemsInPanel,maxItemsInPanel];

                titlePanel.Type='panel';
                titlePanel.Items={};

                codePropBtnNdx=codePropBtnNdx+1;

                studio=obj.m_ssComponent.getStudio;
                editor=studio.App.getActiveEditor;
                model=editor.blockDiagramHandle;
                mmgr=get_param(model,'MappingManager');
                mappingType=mmgr.getCurrentMapping();

                isAutosarClassicType=strcmp(mappingType,'AutosarTarget');
                isAutosarAdaptiveType=strcmp(mappingType,'AutosarTargetCPP');
                isAutosarType=isAutosarClassicType||isAutosarAdaptiveType;
                isMappedToSubComponent=Simulink.CodeMapping.isMappedToAutosarSubComponent(model);
                if slfeature('SwitchMappingUI')>0
                    toggleMappingBtn.Type='pushbutton';
                    toggleMappingBtn.Tag='toggleModelMapping';
                    toggleMappingBtn.ToolTip='Create or Switch mapping.';
                    toggleMappingBtn.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','Toggle_16.png');
                    toggleMappingBtn.RowSpan=[1,1];
                    toggleMappingBtn.PreferredSize=[28,24];
                    toggleMappingBtn.ObjectMethod='toggleModelMapping';
                    toggleMappingBtn.MethodArgs={'%dialog',model};
                    toggleMappingBtn.ArgDataTypes={'handle','handle'};
                    toggleMappingBtn.Visible=slfeature('SwitchMappingUI')>0;
                    toggleMappingBtn.Enabled=1;

                    toggleMappingBtn.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    codePropBtnNdx=codePropBtnNdx+1;
                    titlePanel.Items{end+1}=toggleMappingBtn;
                end

                isVisible=isAutosarType&&~isMappedToSubComponent;
                if isVisible
                    showArDictionaryBtn.Type='pushbutton';
                    showArDictionaryBtn.Tag='showArDictionaryBtn';
                    showArDictionaryBtn.ToolTip=DAStudio.message('Simulink:studio:AutosarPropertiesBtnTooltip');
                    showArDictionaryBtn.Visible=isVisible;
                    showArDictionaryBtn.FilePath=fullfile(matlabroot,'toolbox','coder','simulinkcoder_app',...
                    'code_perspective','icons','autosarCode_16.png');
                    showArDictionaryBtn.RowSpan=[1,1];
                    showArDictionaryBtn.PreferredSize=[28,24];
                    showArDictionaryBtn.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    showArDictionaryBtn.ObjectMethod='handleLaunchAutosarDictionaryUI';
                    showArDictionaryBtn.MethodArgs={'%dialog'};
                    showArDictionaryBtn.ArgDataTypes={'handle'};

                    codePropBtnNdx=codePropBtnNdx+1;
                    titlePanel.Items{end+1}=showArDictionaryBtn;
                end

                isVisible=(isAutosarType&&~isMappedToSubComponent)||...
                strcmp(obj.m_ssComponent.getName,'HDLCodeProperties');
                if isVisible
                    mappingValidateBtn.Type='pushbutton';
                    mappingValidateBtn.Tag='mappingValidateBtn';
                    mappingValidateBtn.ToolTip=DAStudio.message('coderdictionary:mapping:ValidateMapping_Tooltip');
                    mappingValidateBtn.Visible=isVisible;
                    mappingValidateBtn.FilePath=fullfile(matlabroot,'toolbox','shared',...
                    'dastudio','resources','Validate_16.png');
                    mappingValidateBtn.RowSpan=[1,1];
                    mappingValidateBtn.Enabled=true;
                    mappingValidateBtn.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    mappingValidateBtn.PreferredSize=[28,24];
                    mappingValidateBtn.ObjectMethod='handleMappingValidation';
                    mappingValidateBtn.MethodArgs={'%dialog'};
                    mappingValidateBtn.ArgDataTypes={'handle'};

                    codePropBtnNdx=codePropBtnNdx+1;
                    titlePanel.Items{end+1}=mappingValidateBtn;
                end

                if isAutosarClassicType
                    isVisible=~isMappedToSubComponent&&~contains(obj.m_CurrentTab,{'Inports','Outports'});
                elseif isAutosarAdaptiveType
                    isVisible=~contains(obj.m_CurrentTab,{'Inports','Outports','Functions','FunctionCallers'});
                else
                    isVisible=(contains(obj.m_CurrentTab,'Functions')&&~contains(obj.m_CurrentTab,'FunctionsDefaults'))||...
                    strcmp(obj.m_ssComponent.getName,'HDLCodeProperties')||...
                    contains(obj.m_CurrentTab,'DataTransfers');
                end
                if isVisible
                    mappingSyncBtn.Type='pushbutton';
                    mappingSyncBtn.Tag='mappingSyncBtn';

                    mappingSyncBtn.ToolTip=DAStudio.message('coderdictionary:mapping:CodeProperties_Refresh_Tooltip');
                    mappingSyncBtn.FilePath=fullfile(matlabroot,'toolbox',...
                    'shared','dastudio','resources','glue','Toolbars',...
                    '16px','UpdateDiagram_16.png');
                    mappingSyncBtn.RowSpan=[1,1];
                    mappingSyncBtn.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    mappingSyncBtn.PreferredSize=[28,24];
                    mappingSyncBtn.ObjectMethod='handleMappingSync';
                    mappingSyncBtn.MethodArgs={'%dialog'};
                    mappingSyncBtn.ArgDataTypes={'handle'};
                    mappingSyncBtn.Visible=isVisible;
                    mappingSyncBtn.Enabled=true;
                    mappingSyncBtn.Graphical=true;

                    codePropBtnNdx=codePropBtnNdx+1;
                    titlePanel.Items{end+1}=mappingSyncBtn;
                end

                isVisible=false;
                if isVisible
                    scopeButton.Type='togglebutton';
                    scopeButton.Tag='dataview_scope_button';
                    scopeButton.ToolTip=DAStudio.message('Simulink:studio:DataView_scope_tooltip');
                    scopeButton.FilePath=fullfile(matlabroot,'toolbox',...
                    'shared','dastudio','resources','currentsystem.png');
                    scopeButton.RowSpan=[1,1];
                    scopeButton.PreferredSize=[28,24];
                    scopeButton.ObjectMethod='handleScopeOption';
                    scopeButton.MethodArgs={'%dialog','%value'};
                    scopeButton.ArgDataTypes={'handle','mxArray'};
                    scopeButton.Graphical=true;
                    scopeButton.Enabled=isCSBAllowed(obj,obj.m_CurrentTab);
                    if~scopeButton.Enabled
                        obj.m_Scope=0;
                    end
                    scopeButton.Value=obj.m_Scope;

                    scopeButton.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    codePropBtnNdx=codePropBtnNdx+1;
                    titlePanel.Items{end+1}=scopeButton;
                end

                isVisible=contains(obj.m_CurrentTab,'Signals/States')...
                ||strcmp(obj.m_CurrentTab,'Signals_HDL');
                if isVisible
                    addSigBtn.Type='pushbutton';
                    addSigBtn.Tag='addSignal';

                    addSigBtn.ToolTip=DAStudio.message('coderdictionary:mapping:CodeMapping_AddSignal_Tooltip');
                    addSigBtn.FilePath=fullfile(matlabroot,'toolbox',...
                    'shared','dastudio','resources','indicators','add_signal_16.svg');

                    addSigBtn.RowSpan=[1,1];
                    addSigBtn.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    addSigBtn.PreferredSize=[28,24];
                    addSigBtn.ObjectMethod='addSignalToMapping';
                    addSigBtn.MethodArgs={'%dialog'};
                    addSigBtn.ArgDataTypes={'handle'};
                    addSigBtn.Visible=isVisible;
                    addSigBtn.Enabled=true;
                    addSigBtn.Graphical=true;

                    codePropBtnNdx=codePropBtnNdx+1;
                    titlePanel.Items{end+1}=addSigBtn;

                    removeSigBtn.Type='pushbutton';
                    removeSigBtn.Tag='removeSignal';

                    removeSigBtn.ToolTip=DAStudio.message('coderdictionary:mapping:CodeMapping_RemoveSignal_Tooltip');
                    removeSigBtn.FilePath=fullfile(matlabroot,'toolbox',...
                    'shared','dastudio','resources','indicators','remove_signal_16.svg');

                    removeSigBtn.RowSpan=[1,1];
                    removeSigBtn.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    removeSigBtn.PreferredSize=[28,24];
                    removeSigBtn.ObjectMethod='removeSignalFromMapping';
                    removeSigBtn.MethodArgs={'%dialog'};
                    removeSigBtn.ArgDataTypes={'handle'};
                    removeSigBtn.Visible=isVisible;
                    removeSigBtn.Enabled=true;
                    removeSigBtn.Graphical=true;

                    codePropBtnNdx=codePropBtnNdx+1;
                    titlePanel.Items{end+1}=removeSigBtn;
                end

                isVisible=strcmp(obj.m_CurrentTab,'Parameters_ERT')&&slfeature('BlockParameterConfiguration')>4;
                if isVisible
                    addBlockParamBtn.Type='pushbutton';
                    addBlockParamBtn.Tag='addBlockParameter';

                    addBlockParamBtn.ToolTip=DAStudio.message('coderdictionary:mapping:CodeMapping_AddBlockParameter_Tooltip');
                    addBlockParamBtn.FilePath=fullfile(matlabroot,'toolbox',...
                    'shared','dastudio','resources','indicators','addBlockParameter.png');

                    addBlockParamBtn.RowSpan=[1,1];
                    addBlockParamBtn.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    addBlockParamBtn.PreferredSize=[28,24];
                    addBlockParamBtn.ObjectMethod='addBlockParameterToMapping';
                    addBlockParamBtn.MethodArgs={'%dialog'};
                    addBlockParamBtn.ArgDataTypes={'handle'};
                    addBlockParamBtn.Visible=isVisible;
                    addBlockParamBtn.Enabled=true;
                    addBlockParamBtn.Graphical=true;

                    codePropBtnNdx=codePropBtnNdx+1;
                    titlePanel.Items{end+1}=addBlockParamBtn;

                    removeBlockParamBtn.Type='pushbutton';
                    removeBlockParamBtn.Tag='removeBlockParameter';

                    removeBlockParamBtn.ToolTip=DAStudio.message('coderdictionary:mapping:CodeMapping_RemoveBlockParameter_Tooltip');
                    removeBlockParamBtn.FilePath=fullfile(matlabroot,'toolbox',...
                    'shared','dastudio','resources','indicators','removeBlockParameter.png');

                    removeBlockParamBtn.RowSpan=[1,1];
                    removeBlockParamBtn.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    removeBlockParamBtn.PreferredSize=[28,24];
                    removeBlockParamBtn.ObjectMethod='removeBlockParameterFromMapping';
                    removeBlockParamBtn.MethodArgs={'%dialog'};
                    removeBlockParamBtn.ArgDataTypes={'handle'};
                    removeBlockParamBtn.Visible=isVisible;
                    removeBlockParamBtn.Enabled=true;
                    removeBlockParamBtn.Graphical=true;

                    codePropBtnNdx=codePropBtnNdx+1;
                    titlePanel.Items{end+1}=removeBlockParamBtn;
                end

                isVisible=false;
                if isVisible
                    syncNamedSigBtn.Type='pushbutton';
                    syncNamedSigBtn.Tag='syncSignal';

                    syncNamedSigBtn.ToolTip=DAStudio.message('coderdictionary:mapping:CodeMapping_SyncNamedSignals_Tooltip');
                    syncNamedSigBtn.FilePath=fullfile(matlabroot,'toolbox',...
                    'shared','dastudio','resources','indicators','LineIcon3.png');

                    syncNamedSigBtn.RowSpan=[1,1];
                    syncNamedSigBtn.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    syncNamedSigBtn.PreferredSize=[28,24];
                    syncNamedSigBtn.ObjectMethod='syncNamedSignalsInModel';
                    syncNamedSigBtn.MethodArgs={'%dialog'};
                    syncNamedSigBtn.ArgDataTypes={'handle'};
                    syncNamedSigBtn.Visible=isVisible;
                    syncNamedSigBtn.Enabled=true;
                    syncNamedSigBtn.Graphical=true;

                    codePropBtnNdx=codePropBtnNdx+1;
                    titlePanel.Items{end+1}=syncNamedSigBtn;
                end

                for ii=codePropBtnNdx:maxItemsInPanel-1
                    spacerWidget.ColSpan=[codePropBtnNdx,codePropBtnNdx];
                    titlePanel.Items{end+1}=spacerWidget;
                end
                titlePanel.Items{end+1}=filterWidget;
                titlePanel.LayoutGrid=[1,maxItemsInPanel];
                titlePanel.ColStretch=[0,0,0,0,0,0,0,0,0,0,1,0];
                dlgStruct.DialogTag='codeproperties_dlg';
            end
            titlePanel.RowSpan=[1,1];
            titlePanel.ColSpan=[1,1];

            dlgStruct.LayoutGrid=[1,1];
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={titlePanel};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end

        function columns=getDefaultColumns(obj)
            columns=getViewColumns(obj,obj.m_CurrentTab,obj.m_Perspectives{1});
        end

        function handleScopeOption(obj,dlg,value)
            obj.m_Scope=value;

            columns=getViewColumns(obj,obj.m_CurrentTab,obj.m_currentPerspective);
            sortDetails=obj.getSortDetails(obj.m_CurrentTab);
            obj.m_ssComponent.setColumns(columns,sortDetails{1},obj.getGroupDetails(obj.m_CurrentTab),sortDetails{2});
            obj.m_ssComponent.setScope(value);
        end
        function handleReferences(obj,dlg,value)
            obj.m_ShowReferences=value;
            obj.m_ssComponent.setComponentUserData(value);
            dlg.setVisible('dataview_refresh_button',value);
            obj.m_ssComponent.update();
        end

        function handleRefresh(obj,dlg)
            setRefreshListeners(obj);
            st=obj.m_ssComponent.getStudio();
            st.App.updateDiagram(st.App.getActiveEditor.blockDiagramHandle);
        end

        function handleAutoFilter(obj,dlg,value)
            obj.m_SelectionFilter=value;
            if(value)
                obj.m_ssComponent.setEmptyListMessage(DAStudio.message('Simulink:studio:DataView_NoDataForSelection'));
            else
                obj.m_ssComponent.setEmptyListMessage(DAStudio.message('dastudio:studio:NoDataToDisplay'));
            end
            obj.m_ssComponent.showItemsForSourceSelection(value);
            obj.m_ssComponent.update();
        end

        function handleClose(obj,~)
            st=obj.m_ssComponent.getStudio();
            st.hideComponent(obj.m_ssComponent);
        end

        function handleMWS(obj,~)
            slprivate('exploreListNode',obj.m_Source.Name,'model','');
        end
        function setRefreshListeners(obj)
            st=obj.m_ssComponent.getStudio();
            hFcnCompiled=@(blkDiagObj,listenerObj)DataView.onStatusChanged(obj);
            obj.m_SimStatusListener{1}=Simulink.listener(st.App.getActiveEditor.blockDiagramHandle,'EngineCompPassed',hFcnCompiled);
            obj.m_SimStatusListener{2}=Simulink.listener(st.App.getActiveEditor.blockDiagramHandle,'EngineCompFailed',hFcnCompiled);
            hFcnSimStatusChanged=@(obj,e)DataView.onSimStatusChanged(obj,e);
            dispatcher=DAStudio.EventDispatcher;
            obj.m_SimStatusListener{3}=handle.listener(dispatcher,'SimStatusChangedEvent',@(s,e)hFcnSimStatusChanged(obj,e));
            hFcnReadonlyChanged=@(obj,e)DataView.onReadonlyChanged(obj,e);
            obj.m_SimStatusListener{4}=handle.listener(dispatcher,'ReadonlyChangedEvent',@(s,e)hFcnReadonlyChanged(obj,e));
            hFcnPropertyChanged=@(obj,e)DataView.onPropertyChanged(obj,e);
            obj.m_SimStatusListener{5}=handle.listener(dispatcher,'PropertyChangedEvent',@(s,e)hFcnPropertyChanged(obj,e));
        end

        function handleMappingValidation(obj,~)


            st=obj.m_ssComponent.getStudio();
            currentModelInView=st.App.getActiveEditor.blockDiagramHandle;
            modelName=get_param(currentModelInView,'Name');
            mmgr=get_param(currentModelInView,'MappingManager');

            if strcmp(obj.m_ssComponent.getName,'HDLCodeProperties')
                obj.handleRefresh();
                mappingManager=get_param(modelName,'MappingManager');
                mapping=mappingManager.getActiveMappingFor('HDLTarget');
                isMappedToHDL=isa(mapping,'Simulink.HDLTarget.HDLModelMapping');
                if isMappedToHDL
                    hdlcoder.mapping.internal.MappingValidator.validateAllMappings(obj.m_Source.Handle,"userAction");
                end
            elseif any(strcmp(mmgr.getCurrentMapping(),{'AutosarTarget','AutosarTargetCPP'}))
                validate_stage=Simulink.output.Stage(message('RTW:autosar:validateStage').getString(),...
                'ModelName',modelName,'UIMode',true);
                autosar.mm.util.validate(modelName,'interactive');
                validate_stage.delete;
            else
                errordlg(DAStudio.message('coderdictionary:mapping:MappingNotFound_AUTOSAR',modelName));
            end
        end

        function handleMappingSync(obj,~)


            coder.mapping.internal.refreshCodeMapping(obj.m_ssComponent);
        end

        function addSignalToMapping(obj,~)
            st=obj.m_ssComponent.getStudio();
            currentModelInView=st.App.getActiveEditor.blockDiagramHandle;
            modelH=get_param(currentModelInView,'Handle');

            validSrcPortsHdls=simulinkcoder.internal.util.CanvasElementSelection.getValidSrcPortHandles(modelH);
            if strcmp(obj.m_ssComponent.getName,'HDLCodeProperties')
                if length(validSrcPortsHdls)==1

                    simulinkcoder.internal.util.CanvasElementSelection.addSignal(modelH,validSrcPortsHdls(1),'HDLTarget');
                elseif length(validSrcPortsHdls)>1

                    simulinkcoder.internal.util.CanvasElementSelection.addSelectedSignals(modelH,'HDLTarget');
                end
            else
                if length(validSrcPortsHdls)==1

                    simulinkcoder.internal.util.CanvasElementSelection.addSignal(modelH,validSrcPortsHdls(1));
                elseif length(validSrcPortsHdls)>1

                    simulinkcoder.internal.util.CanvasElementSelection.addSelectedSignals(modelH);
                end
            end
        end

        function addBlockParameterToMapping(obj,~)
            st=obj.m_ssComponent.getStudio();
            currentModelInView=st.App.getActiveEditor.blockDiagramHandle;
            modelH=get_param(currentModelInView,'Handle');

            countAdded=0;

            validBlockHdls=simulinkcoder.internal.util.CanvasElementSelection.getValidBlockHandles(modelH);
            for blockH=validBlockHdls'
                countForBlock=simulinkcoder.internal.util.CanvasElementSelection.addBlockParameter(modelH,blockH);
                countAdded=countAdded+countForBlock;
            end

            if countAdded==0
                myStage=sldiagviewer.createStage('Code Mappings for Block Parameters',...
                'ModelName',get_param(modelH,'Name'));%#ok<NASGU>
                msg=message('coderdictionary:mapping:invalidSelectionForAddingBlockParameters');
                sldiagviewer.reportWarning(MSLException(msg));
            end
        end

        function removeBlockParameterFromMapping(obj,~)
            st=obj.m_ssComponent.getStudio();
            currentModelInView=st.App.getActiveEditor.blockDiagramHandle;
            modelH=get_param(currentModelInView,'Handle');

            validBlockHdls=simulinkcoder.internal.util.CanvasElementSelection.getValidBlockHandles(modelH);
            for blockH=validBlockHdls'
                simulinkcoder.internal.util.CanvasElementSelection.removeBlockParameter(modelH,blockH);
            end


            selected=obj.m_ssComponent.imSpreadSheetComponent.getSelection;
            if isempty(selected)
                return;
            end
            for i=1:length(selected)
                item=selected{i};
                propSch=item.getPropertySchema;
                propSch.handleRemoveBtnClick();
            end
        end

        function removeSignalFromMapping(obj,~)
            st=obj.m_ssComponent.getStudio();
            currentModelInView=st.App.getActiveEditor.blockDiagramHandle;
            modelH=get_param(currentModelInView,'Handle');
            validSrcPortsHdls=simulinkcoder.internal.util.CanvasElementSelection.getValidSrcPortHandles(modelH);
            if strcmp(obj.m_ssComponent.getName,'HDLCodeProperties')
                if length(validSrcPortsHdls)==1

                    simulinkcoder.internal.util.CanvasElementSelection.removeSignal(modelH,validSrcPortsHdls(1),'HDLTarget');
                elseif length(validSrcPortsHdls)>1

                    simulinkcoder.internal.util.CanvasElementSelection.removeSelectedSignals(modelH,'HDLTarget');
                end
            else
                if length(validSrcPortsHdls)==1

                    simulinkcoder.internal.util.CanvasElementSelection.removeSignal(modelH,validSrcPortsHdls(1));
                elseif length(validSrcPortsHdls)>1

                    simulinkcoder.internal.util.CanvasElementSelection.removeSelectedSignals(modelH);
                end
            end


            selected=obj.m_ssComponent.imSpreadSheetComponent.getSelection;
            if isempty(selected)
                return;
            end
            for i=1:length(selected)
                item=selected{i};
                propSch=item.getPropertySchema;
                propSch.handleRemoveBtnClick();
            end
        end

        function syncNamedSignalsInModel(obj,~)
            st=obj.m_ssComponent.getStudio();
            currentModelInView=st.App.getActiveEditor.blockDiagramHandle;
            modelH=get_param(currentModelInView,'Handle');
            simulinkcoder.internal.util.CanvasElementSelection.syncNamedSignals(modelH);
        end

        function toggleModelMapping(obj,~,model)
            modelName=get_param(model,'Name');
            mmgr=get_param(model,'MappingManager');
            cdMapping=mmgr.getActiveMappingFor('CoderDictionary');
            arMapping=mmgr.getActiveMappingFor('AutosarTarget');
            if~isempty(cdMapping)&&~isempty(arMapping)
                obj.m_ssComponent.setTitleViewSource(obj);
            elseif isempty(cdMapping)&&~isempty(arMapping)
                Simulink.CodeMapping.doMigrationFromGUI(modelName,false);
                obj.m_ssComponent.setTitleViewSource(obj);
            elseif~isempty(cdMapping)&&isempty(arMapping)
                pb=Simulink.internal.ScopedProgressBar(...
                DAStudio.message('RTW:autosar:createDefaultProgressBar'));
                Simulink.CodeMapping.create(modelName,'default','AutosarTarget');
                delete(pb);
                obj.m_ssComponent.setTitleViewSource(obj);
            else
                assert(true,'Control should never come here.');
            end
        end

        function handleLaunchAutosarDictionaryUI(obj,~)




            st=obj.m_ssComponent.getStudio();
            currentModelInView=st.App.getActiveEditor.blockDiagramHandle;
            modelName=get_param(currentModelInView,'Name');
            mmgr=get_param(currentModelInView,'MappingManager');
            mappingType=mmgr.getCurrentMapping();
            if any(strcmp(mappingType,{'AutosarTarget','AutosarTargetCPP'}))
                autosar_ui_launch(currentModelInView);
                root=DAStudio.Root;
                arExplorer=find(root,'-isa','AUTOSAR.Explorer');
                explorer=[];
                for i=1:length(arExplorer)
                    if~isempty(arExplorer(i).closeListener)
                        source=arExplorer(i).closeListener.Source;
                        if iscell(source)
                            source=source{1};
                        end
                        if source.handle==currentModelInView
                            explorer=arExplorer(i);
                        end
                        break;
                    end
                end
                if~isempty(explorer)
                    if strcmp(mappingType,'AutosarTarget')
                        componentsNode='AtomicComponents';
                        tabToNode={'Inports','ReceiverPorts';
                        'Outports','SenderPorts';
                        'EntryPointFunctions','Runnables';
                        'DataTransfers','IRV';
                        'FunctionCallers','ClientPorts';
                        'LookupTables','ParameterReceiverPorts';
                        'Parameters','Parameters'};
                    elseif strcmp(mappingType,'AutosarTargetCPP')
                        componentsNode='AdaptiveApplications';
                        tabToNode={'Inports','ReceiverPorts';
                        'Outports','SenderPorts';
                        'EntryPointFunctions','SenderPorts';
                        'FunctionCallers','ReceiverPorts'};
                    else
                        assert(false,'Unexpected mapping type');
                    end

                    for i=1:size(tabToNode,1)
                        if contains(obj.m_CurrentTab,tabToNode{i,1})
                            autosar.ui.utils.selectTargetTreeElement(explorer.TraversedRoot,componentsNode);
                            node=tabToNode{i,2};
                            autosar.ui.utils.selectTargetTreeElement(explorer.TraversedRoot,node);
                            break
                        end
                    end
                end
            else
                errordlg(DAStudio.message('coderdictionary:mapping:MappingNotFound_AUTOSAR',modelName));
            end
        end

        function handleLaunchCoderDictUI(obj,~)
            st=obj.m_ssComponent.getStudio();
            currentModelInView=st.App.getActiveEditor.blockDiagramHandle;
            modelName=get_param(currentModelInView,'Name');
            mmgr=get_param(currentModelInView,'MappingManager');

            if strcmp(mmgr.getCurrentMapping(),'CoderDictionary')
                simulinkcoder.internal.util.createMappingAndInitDictIfNecessary(modelName,true);
                simulinkcoder.internal.app.entryPoint(currentModelInView);
            else
                errordlg(DAStudio.message('coderdictionary:mapping:MappingNotFound_C',modelName));
            end
        end

        function handleHelpPanel(obj,~)
            st=obj.m_ssComponent.getStudio();
            cp=simulinkcoder.internal.CodePerspective.getInstance;
            help=cp.getTask('CodePerspectiveHelp');
            help.turnOn(st);
        end

        function handlePerspective(obj,dlg)
            obj.m_currentPerspective=dlg.getComboBoxText('dataview_perspective');
            if~isempty(obj.m_Source)
                columns=getViewColumns(obj,obj.m_CurrentTab,obj.m_currentPerspective);
            else
                columns={' ','Name'};
            end
            sortDetails=obj.getSortDetails(obj.m_CurrentTab);
            groupDetails=obj.getGroupDetails(obj.m_CurrentTab);
            if~ismember(groupDetails,columns)
                groupDetails='';
            end
            obj.m_ssComponent.setColumns(columns,sortDetails{1},groupDetails,sortDetails{2});
            obj.m_ssComponent.update();
        end

        function handleOpenMaskEditor(obj,~)
            slInternal('createOrEditModelMask',obj.m_Source.Handle);
        end

        function columns=getViewColumns(obj,tabName,perspective)
            schName=getViewSchema(obj.m_Source,obj.m_ssComponent.getName(),tabName);
            propSch=eval([schName,'(obj)']);

            columns=propSch.getColumnHeaders(perspective,obj.m_Scope);
            if(~useHierarchicalSpreadsheet(obj,tabName))
                columns=[' ',columns];
            end
        end

        function fillPerspectives(thisObj,tabName)
            schName=getViewSchema(thisObj.m_Source,thisObj.m_ssComponent.getName(),tabName);
            propSch=eval([schName,'(thisObj)']);

            thisObj.m_Perspectives={};
            perspectives=propSch.getPerspectives('spreadsheet');
            for item=perspectives
                thisObj.m_Perspectives{end+1}=DAStudio.message(item{1});
            end
        end

        function allowed=isCSBAllowed(obj,tabName)
            schName=getViewSchema(obj.m_Source,obj.m_ssComponent.getName(),tabName);
            propSch=eval([schName,'(obj)']);

            allowed=propSch.isCSBAllowed();
        end

        function defaultSort=getDefaultSort(obj,tabName)
            schName=getViewSchema(obj.m_Source,obj.m_ssComponent.getName(),tabName);
            propSch=eval([schName,'(obj)']);

            defaultSort=propSch.getDefaultSort();
        end

        function use=useHierarchicalSpreadsheet(obj,tabName)
            schName=getViewSchema(obj.m_Source,obj.m_ssComponent.getName(),tabName);
            propSch=eval([schName,'(obj)']);

            use=propSch.useHierarchicalSpreadsheet();
        end

        function expandTreesIfNeeded(thisObj)
            tabName=thisObj.m_CurrentTab;
            modelName=get_param(thisObj.m_Source.Handle,'Name');
            tabAndModelName=[tabName,'_',modelName];
            ss=thisObj.m_ssComponent;



            if strcmp(ss.getName(),'CodeProperties')
                isHierarchical=thisObj.useHierarchicalSpreadsheet(tabName);
                alreadyHandled=any(strcmp(thisObj.m_TabsWithTreeExpansion,tabAndModelName));
                if(isHierarchical&&~alreadyHandled)
                    ss.setConfig('{"expandall":true}');


                    thisObj.m_TabsWithTreeExpansion{end+1}=tabAndModelName;
                end

                ss.setConfig('{"columns":{"name":"...","minsize":22, "maxsize":22}}');
            end
        end

        function defaultGroup=getDefaultGroup(obj,tabName)
            defaultGroup='';
        end

        function isValid=isTabVisible(obj,tabName,currentSystem)
            schName=getViewSchema(obj.m_Source,obj.m_ssComponent.getName(),tabName);
            propSch=eval([schName,'(obj)']);

            isValid=propSch.isTabVisible(currentSystem);
        end

        function isValid=isTabEnabled(obj,tabName,currentSystem)
            schName=getViewSchema(obj.m_Source,obj.m_ssComponent.getName(),tabName);
            propSch=eval([schName,'(obj)']);

            isValid=propSch.isTabEnabled(currentSystem);
        end


        function sortDetails=getSortDetails(obj,tabName)
            sortDetails={};
            for tabId=1:length(obj.m_Views)
                if isequal(tabName,obj.m_Views{tabId})
                    sortDetails=obj.m_ViewSort{tabId};
                    break;
                end
            end
        end

        function setSortDetails(obj,tabName,col,order)
            for tabId=1:length(obj.m_Views)
                if isequal(tabName,obj.m_Views{tabId})
                    obj.m_ViewSort{tabId}={col,order};
                    break;
                end
            end
        end

        function groupDetails=getGroupDetails(obj,tabName)
            groupDetails={};
            for tabId=1:length(obj.m_Views)
                if isequal(tabName,obj.m_Views{tabId})
                    groupDetails=obj.m_GroupDetails{tabId};
                    break;
                end
            end
        end

        function refresh=needRefresh(obj)
            st=obj.m_ssComponent.getStudio();
            isCompiled=get_param(st.App.getActiveEditor.blockDiagramHandle,'CompiledSinceLastChange');
            if strcmpi(isCompiled,'off')
                refresh=true;
            else
                refresh=false;
            end
        end

        function setGroupDetails(obj,tabName,group)

            for tabId=1:length(obj.m_Views)
                if isequal(tabName,obj.m_Views{tabId})
                    obj.m_GroupDetails{tabId}=group;
                    break;
                end
            end
        end

        function selectItemsOnTab(thisObj,selection,tabName)
            currentTab=thisObj.m_ssComponent.getCurrentTab;
            internalTabIndex=find(strcmp(thisObj.m_Views(:,1),tabName));

            spreadsheetTabIndex=sum([thisObj.m_TabVisibility{1:internalTabIndex}])-1;
            if~isequal(currentTab,spreadsheetTabIndex)
                thisObj.m_pendingSelection=selection;
                thisObj.m_pendingSelectionTabName=tabName;
                thisObj.m_ssComponent.setCurrentTab(spreadsheetTabIndex);
            else
                thisObj.m_ssComponent.view(selection);
            end
        end

        function queueItemSelection(thisObj,selection,tabName)

            thisObj.m_pendingSelection=selection;
            thisObj.m_pendingSelectionTabName=tabName;


            tabIdx=find(strcmp(thisObj.m_Views(:,1),tabName));
            tabIdx=tabIdx-1;
            thisObj.m_ssComponent.setCurrentTab(tabIdx);
        end

        function clearAllListeners(obj)
            unRegisterEditorChangeListener(obj);
            obj.m_IndividualMappingListeners=[];
            obj.m_paramTunabilityListener.Enabled=0;
            obj.m_MappingCreationListeners=[];
            obj.m_SimStatusListener=[];
        end

        function removeAllTabs(obj)
            tabCount=obj.m_ssComponent.getTabCount;
            for i=1:tabCount
                obj.m_ssComponent.removeTab(0)
            end
        end
    end
end





