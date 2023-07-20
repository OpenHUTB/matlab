function schema=ViewMenu(fncname,cbinfo,eventData)



    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end


function schema=ProjectManager(~)

    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:project:ProjectMenuEntryPoint');
    schema.tag='Simulink:SimulinkProject';
    schema.icon='Simulink:SimulinkProject';
    schema.callback=@ProjectManagerAction;
    schema.state='enabled';
end

function ProjectManagerAction(~)

    Simulink.ModelManagement.Project.Canvas.Menu.showUI();
end


function schema=SystemDocumentation(callbackInfo)
    schema=sl_toggle_schema;
    studio=callbackInfo.studio;

    if SLStudio.Utils.showInToolStrip(callbackInfo)
        schema.icon='systemDocumentation';
    else
        schema.label=message('simulink_ui:sysdoc:resources:SystemDocumentation').getString();
    end
    schema.tag='Simulink:SystemDocumentation';
    schema.autoDisableWhen='Never';


    if slfeature('SystemDocumentation')<1
        schema.state='Hidden';
    else
        schema.state='Enabled';
    end

    schema.checked='unchecked';

    if simulink.SystemDocumentationApplication.isVisible(studio)
        schema.checked='checked';
    else
        schema.checked='unchecked';
    end

    schema.callback=@SystemDocumentationCallBack;
end

function SystemDocumentationCallBack(callbackInfo,~)
    studio=callbackInfo.studio;
    if simulink.SystemDocumentationApplication.isVisible(studio)
        simulink.SystemDocumentationApplication.hide(studio);
    else
        simulink.SystemDocumentationApplication.show(studio);
    end
end


function schema=PropertyInspector(cbinfo,~)
    schema=sl_toggle_schema;
    schema.label=DAStudio.message('Simulink:studio:ShowPropertyInspector');
    schema.tag='Simulink:ShowPropertyInspector';

    if cbinfo.studio.getComponent('GLUE2:PropertyInspector','Property Inspector').isVisible
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.callback=@PropertyInspectorCB;
    schema.autoDisableWhen='Never';
end

function PropertyInspectorCB(cbinfo,~)
    st=cbinfo.studio;
    pi=st.getComponent('GLUE2:PropertyInspector','Property Inspector');
    if pi.isVisible
        st.hideComponent(pi);
    else
        st.showComponent(pi);
    end
end

function schema=ShowSchedulingEditor(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ShowSchedulingEditor';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='simScheduleEditor';
    else
        schema.icon='Simulink:ShowSchedulingEditor';
        schema.label=DAStudio.message('SimulinkPartitioning:PartitioningEditor:ViewMenu');
    end

    if cbinfo.model.isLibrary

        schema.state='Hidden';
    elseif SLStudio.Utils.isSimulationRunning(cbinfo)||...
        (strcmpi(get_param(cbinfo.model.handle,'ExplicitPartitioning'),'on')...
        &&strcmpi(get_param(cbinfo.model.handle,'ConcurrentTasks'),'on'))


        schema.state='Disabled';
    else
        schema.state='Enabled';
    end

    schema.refreshCategories={'GenericEvent:Never'};
    schema.callback=@ShowSchedulingEditorCB;
    schema.autoDisableWhen='Busy';
end

function ShowSchedulingEditorCB(cbinfo)
    modelHandle=cbinfo.editorModel.Handle;
    editor=sltp.internal.ScheduleEditorManager.getEditor(modelHandle);
    editor.show();
end

function schema=OpenVariantManager(~)

    schema=sl_action_schema;
    schema.tag='Simulink:OpenVariantManager';
    schema.label=DAStudio.message('Simulink:studio:VariantManager');
    schema.icon='Simulink:OpenVariantManager';
    schema.refreshCategories={'GenericEvent:Never'};
    schema.callback=@OpenVariantManagerCB;
    schema.autoDisableWhen='Never';
end

function OpenVariantManagerCB(cbinfo)


    rootModelName=cbinfo.studio.App.topLevelDiagram.getName();
    try

        blockPathObject=Simulink.variant.utils.getBlockPathToEditor(cbinfo.studio.App.getActiveEditor);
    catch
        blockPathObject=[];
    end
    if isempty(blockPathObject)

        Simulink.variant.utils.launchVariantManager('Create',rootModelName);
    else
        Simulink.variant.utils.launchVariantManager('CreateAndNavigate',rootModelName,blockPathObject,true);
    end
end

function schema=ViewModelInterfaceMenu(cbinfo)

    schema=sl_action_schema;
    schema.tag='Simulink:ViewModelInterfaceMenu';
    isInterfaceDomain=isa(cbinfo.domain,'InterfaceEditor.InterfaceEditorDomain');
    schema.label='Interface Inspector';
    if isInterfaceDomain
        schema.state='Disabled';
    end
    schema.icon='Simulink:ViewModelInterfaceMenu';
    schema.refreshCategories={'GenericEvent:Never'};
    schema.callback=@ViewModelInterfaceMenuCB;
    schema.autoDisableWhen='Busy';
    if(slfeature('SlInterfaceViewMenu')<1)
        schema.state='Hidden';
    end
end

function ViewModelInterfaceMenuCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    isInterfaceDomain=isa(cbinfo.domain,'InterfaceEditor.InterfaceEditorDomain');
    if(~isInterfaceDomain)
        SLM3I.SLDomain.toggleInterfaceView(isInterfaceDomain,editor,cbinfo.uiObject.handle);
    end
end

function schema=OpenMessageViewer(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:OpenMessageViewer';
    schema.label=DAStudio.message('Simulink:studio:OpenMessageViewer');
    schema.icon='';
    schema.refreshCategories={'GenericEvent:Never'};
    schema.state=OpenMessageViewerState(cbinfo);
    schema.callback=@OpenMessageViewerCB;
    schema.autoDisableWhen='Never';
end

function[state]=OpenMessageViewerState(~)
    state='enabled';
end

function OpenMessageViewerCB(cbinfo)
    aSLMsgViewer=slmsgviewer.Instance(cbinfo.model.Name);
    if~isempty(aSLMsgViewer)
        for i=1:length(aSLMsgViewer)
            aSLMsgViewer(i).show();
            aSLMsgViewer(i).m_MessageService.publish('selectTab',cbinfo.model.Name);
        end
    end
end

function schema=ModelBrowserMenu(~)
    schema=sl_container_schema;
    schema.tag='Simulink:ModelBrowserMenu';
    schema.label=DAStudio.message('Simulink:studio:ModelBrowserMenu');


    children={@ShowModelBrowser,...
    'separator',...
    @IncludeReferencedModels,...
    @IncludeLibraryLinks,...
    @IncludeMaskedSubsystems
    };

    schema.childrenFcns=children;

    schema.autoDisableWhen='Never';
end

function schema=ViewMarksMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:ViewMarksMenu';
    schema.label=DAStudio.message('Simulink:studio:viewmarks');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    children={im.getAction('Simulink:CreateViewMark'),...
    im.getAction('Simulink:ViewMarkManager'),...
    };

    schema.childrenFcns=children;
    schema.autoDisableWhen='Never';

    if(slfeature('SLSFViewMark')<1)||...
        isa(cbinfo.domain,'InterfaceEditor.InterfaceEditorDomain')||...
        Simulink.harness.isHarnessBD(cbinfo.model.Name)||...
        SLStudio.Utils.isStateTransitionTable(cbinfo)
        schema.state='Hidden';
    end
end

function schema=CreateViewMark(cbinfo)

    schema=sl_action_schema;
    schema.tag='Simulink:CreateViewMark';
    schema.callback=@CreateViewMarkAction;
    schema.accelerator='Ctrl+Shift+D';
    schema.state='enabled';
    schema.autoDisableWhen='Never';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:saveViewmarkLabel';
        schema.tooltip='simulink_ui:studio:resources:ViewmarkThisViewActionDescription';
        schema.icon='viewmarkCreate';
        if((slfeature('SLSFViewMark')<1)||...
            isa(cbinfo.domain,'InterfaceEditor.InterfaceEditorDomain')||...
            Simulink.harness.isHarnessBD(cbinfo.model.Name)||...
            SLStudio.Utils.isStateTransitionTable(cbinfo)||...
            isa(cbinfo.domain,'SA_M3I.StudioAdapterDomain'))
            schema.state='Hidden';
        end
    else
        schema.label=DAStudio.message('Simulink:studio:takeViewmark');
        schema.icon='Simulink:CreateViewMark';
    end
end

function CreateViewMarkAction(~)
    slprivate('slsfviewmark',bdroot,'snap');
end

function schema=ShowModelBrowser(cbinfo)
    if cbinfo.isContextMenu
        schema=sl_action_schema;
        schema.label=DAStudio.message('Simulink:studio:HideModelBrowser');
    else
        schema=sl_toggle_schema;
        if cbinfo.domain.isTreeComponentVisible
            schema.checked='Checked';
        else
            schema.checked='Unchecked';
        end
        if~SLStudio.Utils.showInToolStrip(cbinfo)
            schema.label=DAStudio.message('Simulink:studio:ShowModelBrowser');
        end
    end

    schema.tag='Simulink:ShowModelBrowser';
    schema.callback=@ShowModelBrowserCB;

    schema.autoDisableWhen='Never';
end

function ShowModelBrowserCB(cbinfo,~)
    cbinfo.domain.toggleTreeComponent;
end

function schema=IncludeLibraryLinks(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:ShowLibLinks';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:ShowLibLinksInModelBrowser');
    else
        if~SLStudio.Utils.showInToolStrip(cbinfo)
            schema.label=DAStudio.message('Simulink:studio:ShowLibLinks');
        end
    end

    if cbinfo.studio.App.isShowLinkedEnabled
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.callback=@ShowLibraryLinksCB;

    schema.autoDisableWhen='Never';
end

function ShowLibraryLinksCB(cbinfo)
    cbinfo.studio.App.toggleShowLinked();
end

function schema=IncludeMaskedSubsystems(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:LookUnderMasks';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:LookUnderMasksInModelBrowser');
    else
        if~SLStudio.Utils.showInToolStrip(cbinfo)
            schema.label=DAStudio.message('Simulink:studio:LookUnderMasks');
        end
    end
    if cbinfo.studio.App.isShowMaskedEnabled
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.callback=@ShowMaskedSubsystemsCB;

    schema.autoDisableWhen='Never';
end

function ShowMaskedSubsystemsCB(cbinfo)
    cbinfo.studio.App.toggleShowMasked();
end


function schema=IncludeReferencedModels(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:ShowReferenced';
    if cbinfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:ShowReferencedInModelBrowser');
    else
        if~SLStudio.Utils.showInToolStrip(cbinfo)
            schema.label=DAStudio.message('Simulink:studio:ShowReferenced');
        end
    end
    if cbinfo.studio.App.isShowReferencedEnabled
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    schema.callback=@ShowReferencedModelsCB;

    schema.autoDisableWhen='Never';
end

function ShowReferencedModelsCB(cbinfo)
    cbinfo.studio.App.toggleShowReferenced;
end

function schema=Toolbars(~)
    schema=sl_toggle_schema;
    schema.tag='Simulink:Toolbars';
    schema.label=DAStudio.message('Simulink:studio:Toolbars');
    if(strcmp(get_param(0,'EditorToolbars'),'on'))
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.callback=@ShowToolbarsCB;

    schema.autoDisableWhen='Never';

end

function ShowToolbarsCB(~)
    val=get_param(0,'EditorToolbars');
    if(strcmp(val,'on'))
        set_param(0,'EditorToolbars','off');
    else
        set_param(0,'EditorToolbars','on');
    end
end

function schema=ViewMarkManager(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:ViewMarkManager';
    schema.callback=@ShowViewMarkManager;
    schema.accelerator='Ctrl+Shift+B';
    schema.autoDisableWhen='Never';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:openViewmarksLabel';
        schema.icon='viewmarks';
        if(slfeature('SLSFViewMark')<1)||...
            isa(cbinfo.domain,'InterfaceEditor.InterfaceEditorDomain')||...
            Simulink.harness.isHarnessBD(cbinfo.model.Name)||...
            SLStudio.Utils.isStateTransitionTable(cbinfo)
            schema.state='Hidden';
        end
    else
        schema.label=DAStudio.message('Simulink:studio:showViewmarks');
        schema.icon='Simulink:ViewMarkManager';
    end
end

function ShowViewMarkManager(cbinfo)
    slprivate('slOpenViewMarkDialog');
end


function schema=StatusBar(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:StatusBar';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:StatusBar');
    if(strcmp(get_param(0,'EditorStatusBar'),'on'))
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.callback=@ShowStatusBarCB;

    schema.autoDisableWhen='Never';

end

function ShowStatusBarCB(~,~)
    val=get_param(0,'EditorStatusBar');
    if(strcmp(val,'on'))
        set_param(0,'EditorStatusBar','off');
    else
        set_param(0,'EditorStatusBar','on');
    end
end

function schema=ExplorerBar(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:ExplorerBar';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ExplorerBar');
    if strcmp(get_param(0,'EditorExplorerBar'),'on')
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.callback=@ShowExplorerBarCB;

    schema.autoDisableWhen='Never';
end

function ShowExplorerBarCB(~,~)
    val=get_param(0,'EditorExplorerBar');
    if(strcmp(val,'on'))
        set_param(0,'EditorExplorerBar','off');
    else
        set_param(0,'EditorExplorerBar','on');
    end
end

function schema=ConfigureToolbars(~)
    schema=sl_action_schema;
    schema.tag='Simulink:ConfigureToolbars';
    schema.label=DAStudio.message('Simulink:studio:ConfigureToolbars');

    schema.refreshCategories={'GenericEvent:Never'};

    schema.callback=@ConfigureToolbarsCB;

    schema.autoDisableWhen='Never';
end

function ConfigureToolbarsCB(~)
    try
        feval('slprivate','showprefs');

        rt=DAStudio.Root;

        e=rt.find('-isa','DAStudio.Explorer');

        for i=1:length(e)
            if isa(e.getRoot,'Simulink.Preferences')
                viewer=e(i);
                prefRoot=viewer.getRoot();
                childPrefs=prefRoot.getChildren();
                for j=1:length(childPrefs)
                    if isa(childPrefs(j),'Simulink.EditorPrefs')
                        viewer.view(childPrefs(j));
                    end
                end
            end
        end


    catch Err
        Err.getReport;
    end
end

function schema=NavigateMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:NavigateMenu';
    schema.label=DAStudio.message('Simulink:studio:NavigateMenu');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    children={im.getAction('Simulink:NavigateBack'),...
    im.getAction('Simulink:NavigateForward'),...
    im.getAction('Simulink:NavigateUpToParent'),...
    'separator',...
    @NavigateToPreviousTab,...
    @NavigateToNextTab
    };

    schema.childrenFcns=children;

    schema.autoDisableWhen='Never';
end

function schema=NavigateBack(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:NavigateBack';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:NavigateBack');
    schema.icon=schema.tag;
    schema.obsoleteTags={'Simulink:Back'};
    schema.refreshCategories={'StudioEvent:NavigationChange','StudioEvent:ExplorerBarHistoryChange','NavigationBarEnableChanged'};
    if cbinfo.studio.App.isNavigationBarEnabled&&cbinfo.studio.App.canNavigateBack
        schema.state='enabled';
    else
        schema.state='disabled';
    end
    schema.callback=@NavigateBackCB;

    schema.autoDisableWhen='Never';
end

function schema=NavigateBackSF(cbinfo)
    schema=NavigateBack(cbinfo);
    if cbinfo.isContextMenu
        schema.obsoleteTags={'Stateflow:CtxBackMenuItem'};
    else
        schema.obsoleteTags={'Stateflow:BackMenuItem'};
    end
end

function NavigateBackCB(cbinfo)
    cbinfo.studio.App.navigateBack;
end

function schema=NavigateForward(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:NavigateForward';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:NavigateForward');
    schema.icon=schema.tag;
    schema.obsoleteTags={'Simulink:Forward'};
    schema.refreshCategories={'StudioEvent:NavigationChange','StudioEvent:ExplorerBarHistoryChange','NavigationBarEnableChanged'};
    if cbinfo.studio.App.isNavigationBarEnabled&&cbinfo.studio.App.canNavigateForward
        schema.state='enabled';
    else
        schema.state='disabled';
    end
    schema.callback=@NavigateForwardCB;

    schema.autoDisableWhen='Never';
end

function schema=NavigateForwardSF(cbinfo)
    schema=NavigateForward(cbinfo);
    if cbinfo.isContextMenu
        schema.obsoleteTags={'Stateflow:CtxForwardMenuItem'};
    else
        schema.obsoleteTags={'Stateflow:ForwardMenuItem'};
    end
end

function NavigateForwardCB(cbinfo)
    cbinfo.studio.App.navigateForward;
end

function schema=NavigateUpToParent(cbInfo)
    schema=sl_action_schema;
    schema.tag='Simulink:NavigateUpToParent';
    schema.label=SLStudio.Utils.getMessage(cbInfo,'Simulink:studio:NavigateUpToParent');
    schema.icon=schema.tag;
    schema.obsoleteTags={'Simulink:GotoParent'};
    schema.state=loc_getNavigateUpToParentState(cbInfo);

    if~SFStudio.Utils.isStateflowApp(cbInfo)
        schema.refreshCategories={'StudioEvent:NavigationChange','StudioEvent:ExplorerBarHistoryChange','NavigationBarEnableChanged'};
    else
        schema.refreshCategories={'interval#8'};
    end

    schema.accelerator='Esc';
    schema.callback=@GoToParentCB;

    schema.autoDisableWhen='Never';
end

function schema=NavigateUpToParentSF(cbinfo)
    schema=NavigateUpToParent(cbinfo);
    if cbinfo.isContextMenu
        schema.obsoleteTags={'Stateflow:CtxGotoParentMenuItem'};
    else
        schema.obsoleteTags={'Stateflow:GoToParentMenuItem'};
    end
end

function state=loc_getNavigateUpToParentState(cbInfo)
    state='Disabled';
    slStudioApp=cbInfo.studio.App;
    currentEditor=slStudioApp.getActiveEditor;
    if(isempty(currentEditor))||~slStudioApp.isNavigationBarEnabled
        return;
    end

    if SLStudio.Utils.isInterfaceViewActive(cbInfo)
        if(SLM3I.SLDomain.canNavigateUp(currentEditor))
            state='enabled';
        else
            state='disabled';
        end
    elseif SFStudio.Utils.isStateflowApp(cbInfo)
        chartId=SFStudio.Utils.getChartId(cbInfo);
        currentDiagram=currentEditor.getDiagram;
        state='enabled';
        if isprop(currentDiagram,'backendId')
            if chartId==currentDiagram.backendId
                state='disabled';
            end
        end
    else
        currentDiagram=currentEditor.getDiagram;
        topLevelDiagram=slStudioApp.topLevelDiagram;
        if(isequal(currentDiagram.getFullName,topLevelDiagram.getFullName))
            state='disabled';
        else
            state='enabled';
        end
    end
end

function GoToParentCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    activeSlEditor=slStudioApp.getActiveEditor;
    assert(~isempty(activeSlEditor),'StudioApp does not have active editor');
    activeSlEditor.gotoParent;
end

function schema=NavigateToPreviousTab(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:NavigateToPreviousTab';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:NavigateToPreviousTab');
    schema.accelerator='Ctrl+Shift+Backtab';

    numTabs=cbinfo.studio.getTabCount;
    if numTabs<=1
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
    schema.userdata='prev';
    schema.callback=@NavigateBetweenTabsCB;

    schema.autoDisableWhen='Never';
end

function schema=NavigateToNextTab(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:NavigateToNextTab';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:NavigateToNextTab');
    schema.accelerator='Ctrl+Tab';

    numTabs=cbinfo.studio.getTabCount;
    if numTabs<=1
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
    schema.userdata='next';
    schema.callback=@NavigateBetweenTabsCB;

    schema.autoDisableWhen='Never';
end

function NavigateBetweenTabsCB(cbinfo)
    currentTab=cbinfo.studio.getCurrentTab;
    numTabs=cbinfo.studio.getTabCount;
    direction=cbinfo.userdata;

    if strcmp(direction,'prev')
        currentTab=currentTab-1;
        if currentTab<0
            currentTab=numTabs-1;
        end
    else
        currentTab=currentTab+1;
        if currentTab==numTabs
            currentTab=0;
        end
    end
    cbinfo.studio.focusTab(currentTab);
end



function tf=isCompositionSubDomainActive(cbinfo)
    bdH=cbinfo.studio.App.blockDiagramHandle;
    tf=Simulink.internal.isArchitectureModel(bdH);
end


function schema=ZoomMenu(~)
    schema=sl_container_schema;
    schema.tag='Simulink:ZoomMenu';
    schema.label=DAStudio.message('Simulink:studio:ZoomMenu');


    children={@ZoomIn,...
    @ZoomOut,...
    @ZoomNormalView,...
    @ZoomFitToView,...
    @ZoomFitToWindow
    };

    schema.childrenFcns=children;

    schema.autoDisableWhen='Never';
end

function schema=ZoomIn(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ZoomIn';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ZoomIn');
    schema.icon='noImage';
    schema.callback=@ZoomInCB;
    canvas=cbinfo.studio.App.getActiveEditor.getCanvas;
    if canvas.Scale<(canvas.MaxScaleLimit-.0001)
        schema.state='enabled';
    else
        schema.state='disabled';
    end
    schema.autoDisableWhen='Never';
end

function ZoomInCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    activeSlEditor=slStudioApp.getActiveEditor;
    assert(~isempty(activeSlEditor),'StudioApp does not have active editor');

    if SFStudio.Utils.isStateTransitionTable(cbinfo)&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        SFStudio.Utils.executeActionOnSTTUI(cbinfo,'ZOOM_IN');
    elseif SFStudio.Utils.isTruthTable(cbinfo)&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        SFStudio.Utils.executeActionOnTTUI(cbinfo,'zoom',{'in'});
        activeSlEditor.zoomIn;
    else
        activeSlEditor.zoomIn;
    end
end

function schema=ZoomOut(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ZoomOut';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ZoomOut');
    schema.icon='noImage';
    schema.callback=@ZoomOutCB;
    canvas=cbinfo.studio.App.getActiveEditor.getCanvas;
    if canvas.Scale>(canvas.MinScaleLimit+.0001)
        schema.state='enabled';
    else
        schema.state='disabled';
    end
    schema.autoDisableWhen='Never';
end

function ZoomOutCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    activeSlEditor=slStudioApp.getActiveEditor;
    assert(~isempty(activeSlEditor),'StudioApp does not have active editor');

    if SFStudio.Utils.isStateTransitionTable(cbinfo)&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        SFStudio.Utils.executeActionOnSTTUI(cbinfo,'ZOOM_OUT');
    elseif SFStudio.Utils.isTruthTable(cbinfo)&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        SFStudio.Utils.executeActionOnTTUI(cbinfo,'zoom',{'out'});
        activeSlEditor.zoomOut;
    else
        activeSlEditor.zoomOut;
    end
end

function schema=ZoomFitToView(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ZoomFitToView';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ZoomFitToView');
    schema.icon='noImage';
    schema.accelerator='Space';
    schema.callback=@ZoomFitToViewCB;

    if SFStudio.Utils.isEditorShowingWebContent(cbinfo)&&SFStudio.Utils.isStateTransitionTable(cbinfo)
        schema.state='disabled';
    else
        schema.state='enabled';
    end

    schema.autoDisableWhen='Never';
end

function ZoomFitToViewCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    activeSlEditor=slStudioApp.getActiveEditor;
    assert(~isempty(activeSlEditor),'StudioApp does not have active editor');
    activeSlEditor.getCanvas.zoomToSceneRect;
end

function schema=ZoomFitToWindow(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ZoomFitToWindow';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ZoomFitToWindow');
    schema.callback=@ZoomFitToWindowCB;

    if isCompositionSubDomainActive(cbinfo)
        schema.state='enabled';
    else
        schema.state='Hidden';
    end
end

function ZoomFitToWindowCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    activeSlEditor=slStudioApp.getActiveEditor;
    assert(~isempty(activeSlEditor),'StudioApp does not have active editor');

    if isCompositionSubDomainActive(cbinfo)
        SLM3I.Util.fitSystemBox(activeSlEditor);
    end

end

function schema=ZoomNormalView(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ZoomNormalView';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ZoomNormalView');
    schema.icon='noImage';
    schema.callback=@ZoomToNormalViewCB;

    schema.autoDisableWhen='Never';
end

function ZoomToNormalViewCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    activeSlEditor=slStudioApp.getActiveEditor;
    assert(~isempty(activeSlEditor),'StudioApp does not have active editor');

    if SFStudio.Utils.isStateTransitionTable(cbinfo)&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        SFStudio.Utils.executeActionOnSTTUI(cbinfo,'ZOOM_NORMAL');
    elseif SFStudio.Utils.isTruthTable(cbinfo)&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        SFStudio.Utils.executeActionOnTTUI(cbinfo,'zoom',{'normal'});
        activeSlEditor.zoomToNormal;
    else
        activeSlEditor.zoomToNormal;
    end
end

function schema=SmartGuides(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:ShowHideSmartGuides';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ShowHideSmartGuides');
    if SLStudio.Utils.isInterfaceViewActive(cbinfo)
        schema.state='Disabled';
    else
        schema.state='enabled';
    end
    if(strcmp(get_param(0,'ShowSmartGuides'),'on'))
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.callback=@SmartGuidesCB;

    schema.autoDisableWhen='Never';
end

function SmartGuidesCB(~,~)
    val=get_param(0,'ShowSmartGuides');
    if(strcmp(val,'on'))
        set_param(0,'ShowSmartGuides','off');
    else
        set_param(0,'ShowSmartGuides','on');
    end
end

function schema=MatlabDesktop(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:Desktop';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='matlabDesktop';
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Desktop');
    end
    schema.state='Enabled';
    schema.callback=@MatlabDesktopCB;

    schema.autoDisableWhen='Never';
end

function MatlabDesktopCB(~)
    commandwindow;
end

function schema=ModelDataComponent(cbinfo,~)

    schema=sl_toggle_schema;
    schema.label=DAStudio.message('Simulink:studio:DataViewMenu');
    schema.tag='Simulink:DataViewMenu';
    schema.accelerator='Ctrl+Shift+E';
    schema.callback=@LogicalViewComponentCB;
    schema.autoDisableWhen='Never';

    if cbinfo.studio.App.hasSpotlightView()
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end

    ss=cbinfo.studio.getComponent('GLUE2:SpreadSheet','ModelData');
    if~isempty(ss)&&cbinfo.studio.getComponent('GLUE2:SpreadSheet','ModelData').isVisible
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
end


function schema=CodeMappingsComponent(cbinfo,~)
    schema=sl_toggle_schema;
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CodeViewSS');
    schema.tag='Simulink:CodeMappingsComponent';
    schema.callback=@CodeMappingsComponentCB;
    schema.autoDisableWhen='Never';

    st=cbinfo.studio;
    status=simulinkcoder.internal.util.getCodeMappingPanelStatus(st);
    if status>1
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end

    cmp=st.getComponent('GLUE2:SpreadSheet','CodeProperties');
    if~isempty(cmp)&&cmp.isVisible
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    modelH=cbinfo.model.Handle;
    if Simulink.CodeMapping.isAutosarCompliant(modelH)

        schema.tooltip='autosarstandard:toolstrip:CodeMappingTooltip';
    end
end

function CodeMappingsComponentCB(cbinfo,~)
    st=cbinfo.studio;
    cmp=st.getComponent('GLUE2:SpreadSheet','CodeProperties');
    ed=cbinfo.EventData;
    if ed

        editor=st.App.getActiveEditor;
        bdh=editor.blockDiagramHandle;
        simulinkcoder.internal.util.openCodeMappingSS(st,bdh);
    else

        if~isempty(cmp)
            st.hideComponent(cmp);
        end
    end
end

function schema=CodePerspectiveHelpComponent(cbinfo,~)
    schema=sl_toggle_schema;
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CodePerspectiveHelpMenuItem');
    schema.tag='Simulink:CodePerspectiveHelpComponent';
    schema.callback=@CodePerspectiveHelpComponentCB;
    schema.autoDisableWhen='Never';

    modelH=cbinfo.model.Handle;
    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if cp.isInPerspective(modelH)&&~Simulink.CodeMapping.isMappedToAutosarSubComponent(modelH)
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end
    st=cbinfo.studio;
    cmp=st.getComponent('GLUE2:DDG Component','CodePerspective');
    if~isempty(cmp)&&cmp.isVisible
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    if Simulink.CodeMapping.isAutosarCompliant(modelH)

        schema.tooltip='autosarstandard:toolstrip:CodePerspectiveQuickHelpDescription';
    end

end

function CodePerspectiveHelpComponentCB(cbinfo,~)
    studio=cbinfo.studio;
    cp=simulinkcoder.internal.CodePerspective.getInstance;
    help=cp.getTask('CodePerspectiveHelp');
    status=help.getStatus(studio);
    if status
        help.turnOff(studio);
    else
        help.launchHelp(studio);
    end
end

function schema=CodeViewPanel(cbinfo)
    schema=sl_toggle_schema;
    schema.label=DAStudio.message('Simulink:studio:CodeViewMenuItem');
    schema.tag='Simulink:CodeViewPanel';
    schema.callback=@CodeViewPanelCB;
    schema.autoDisableWhen='Never';

    modelH=cbinfo.model.Handle;

    if loc_isEmbeddedCoder
        cp=simulinkcoder.internal.CodePerspective.getInstance;
        if cp.isInPerspective(modelH)
            schema.state='Enabled';
        else
            schema.state='Hidden';
        end
    else
        schema.state='Hidden';
    end

    studio=cbinfo.studio;
    cmp=studio.getComponent('GLUE2:DDG Component','CodeView');
    if~isempty(cmp)&&cmp.isVisible
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end

    function ret=loc_isEmbeddedCoder
        ret=dig.isProductInstalled('MATLAB Coder')&&...
        dig.isProductInstalled('Simulink Coder')&&...
        dig.isProductInstalled('Embedded Coder');
    end
end

function CodeViewPanelCB(cbinfo)
    studio=cbinfo.studio;
    cmp=studio.getComponent('GLUE2:DDG Component','CodeView');
    status=~isempty(cmp)&&cmp.isVisible;

    cp=simulinkcoder.internal.CodePerspective.getInstance;
    code=cp.getTask('CodeReport');
    if status
        code.turnOff(studio);
    else
        code.turnOn(studio);
    end
end


function schema=CustomCodeLibraryConfig(cbinfo)

    schema=sl_container_schema;
    schema.label=DAStudio.message('Simulink:studio:LibCustomCode');
    schema.tag='Simulink:CustomCodeSettings';

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={...
    im.getAction('Simulink:LibSimCustomCode'),...
    im.getAction('Simulink:LibRTWCustomCode'),...
    };

    schema.autoDisableWhen='Never';
    if~cbinfo.model.isLibrary
        schema.state='Hidden';
    end

end



function schema=LibSimCustomCode(~)%#ok<DEFNU>

    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:LibSimCustomCode');
    schema.tag='Simulink:CustomCodeSettings';
    schema.callback=@LibSimCustomConfig;
    schema.state='enabled';
    schema.autoDisableWhen='Never';
end

function LibSimCustomConfig(~)
    slCfgPrmDlg(get_param(bdroot,'Handle'),'OpenLibSim');
end

function schema=LibRTWCustomCode(~)%#ok<DEFNU>

    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:LibRTWCustomCode');
    schema.tag='Simulink:CustomCodeSettings';
    schema.callback=@LibRTWCustomConfig;
    schema.state='enabled';
    schema.autoDisableWhen='Never';
end

function LibRTWCustomConfig(~)
    slCfgPrmDlg(get_param(bdroot,'Handle'),'OpenLibRTW');
end

function LogicalViewComponentCB(cbinfo,~)
    DataView.createSpreadSheetComponent(cbinfo.studio,true,false);
end

function tabName=GetViewTab(cbinfo,ssComp)
    tab=ssComp.getCurrentTab;
    views=getViews(cbinfo.model,ssComp.getName());
    if tab<length(views)
        tabName=views{tab+1};
    else
        tabName='';
    end
end

function tabIdx=GetViewTabIdx(cbinfo,ssComp,tabName)
    views=getViews(cbinfo.model,ssComp.getName());
    tabIdx=0;
    for item=views
        if~isequal(item{1},tabName)
            tabIdx=tabIdx+1;
        else
            break;
        end
    end
end







