function schema=ToolBars(fncname,cbinfo,eventData)





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

    if Stateflow.App.Utils.isStateflowAppViewer(cbinfo)
        schema.state='Disabled';
    end
end


function schemas=ToolBarsImpl(cbinfo)%#ok<*DEFNU> % ( cbinfo )
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schemas={im.getSubmenu('Simulink:SLNewSaveToolBar'),...
    im.getSubmenu('Simulink:SLNewOpenSaveToolBar'),...
    im.getSubmenu('Simulink:SLPrintToolBar'),...
    im.getSubmenu('Simulink:SLCutCopyPasteToolBar'),...
    im.getSubmenu('Simulink:SLUndoRedoToolBar'),...
    im.getSubmenu('Simulink:SLNavigateToolBar'),...
    im.getSubmenu('Simulink:SLLibraryExplorerToolBar'),...
    im.getSubmenu('Simulink:SLInputToolBar'),...
    im.getSubmenu('Simulink:SLSimulationToolBar'),...
    im.getSubmenu('Simulink:SLRefreshBlocksToolBar'),...
    im.getSubmenu('Simulink:SLUpdateDiagramToolBar'),...
    im.getSubmenu('Simulink:SLDebugModelToolBar'),...
    im.getSubmenu('Simulink:SLModelAdvisorToolBar'),...
    im.getSubmenu('Simulink:SLBuildToolBar'),...
    im.getSubmenu('Simulink:SLFindToolBar')
    };
end

function schema=SLNavigateToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLNavigateToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLNavigateToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:NavigateBack'),...
    im.getAction('Simulink:NavigateForward'),...
    im.getAction('Simulink:NavigateUpToParent')
    };
    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Never';
end

function schema=SLNewOpenSaveToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLNewOpenSaveToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLNewOpenSaveToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={@ToolBarNewMenu,...
    @ToolBarOpenMenu,...
    im.getAction('Simulink:Save')
    };
    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Never';
end

function schema=SLNewSaveToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLNewSaveToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLNewSaveToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={@ToolBarNewMenu,...
    im.getAction('Simulink:Save')
    };
    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Never';
end

function schema=SLCutCopyPasteToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLCutCopyPasteToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLCutCopyPasteToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:Cut'),...
    im.getAction('Simulink:Copy'),...
    im.getAction('Simulink:Paste')
    };
    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Never';
end

function schema=SLUndoRedoToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLUndoRedoToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLUndoRedoToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:Undo'),...
    im.getAction('Simulink:Redo')
    };

    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
end

function schema=SLPrintToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLPrintToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLPrintToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:Print')};

    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Never';
end

function schema=SLLibraryExplorerToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLLibraryExplorerToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLLibraryExplorerToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:ShowLibraryBrowser'),...
    im.getAction('Simulink:ToolBarConfigurationMenu'),...
    @ToolBarExplorerMenu
    };
    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Never';
end

function schema=SLUpdateDiagramToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLUpdateDiagramToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLUpdateDiagramToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:UpdateDiagram')};

    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Busy';
end

function schema=SLRefreshBlocks(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLRefreshBlocksToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLRefreshBlocksToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:RefreshBlocks')};

    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Busy';
end

function schema=SLInputBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLInputToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLInputToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:SimulationInput')};


    schema.state='Hidden';

    schema.autoDisableWhen='Busy';
end

function schema=SLSimulationToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLSimulationToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLSimulationToolBar');


    if SFStudio.Utils.isStateflowApp(cbinfo)
        schema.minimumVisibleItems=0;
    else
        schema.minimumVisibleItems=15;
    end




    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={...
    im.getAction('Simulink:ConnectToTarget'),...
    im.getAction('Simulink:SimulationInteractiveMultiRunToolBar'),...
    im.getAction('Simulink:SimulationRollBack'),...
    im.getAction('Simulink:StartPauseContinue'),...
    im.getAction('Simulink:SimulationForwardToolBar'),...
    im.getAction('Simulink:DebuggerStepOver'),...
    im.getAction('Simulink:DebuggerStepIn'),...
    im.getAction('Simulink:DebuggerStepOut'),...
    im.getAction('Simulink:SlDebuggerAdvancedDebugging'),...
    im.getAction('Simulink:SlDebuggerStepOver'),...
    im.getAction('Simulink:SlDebuggerStepIn'),...
    im.getAction('Simulink:SlDebuggerStepOut'),...
    im.getAction('Simulink:Stop'),...
    im.getAction('Simulink:SimulationPacingToolBar'),...
    'separator',...
    @ToolBarRecordMenu,...
    @ToolBarSimulationStopTime,...
    @ToolBarSimulationMode
    };
    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Never';
end

function schema=SLModelAdvisorToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLModelAdvisorToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLModelAdvisorToolBar');

    schema.childrenFcns={@ToolBarAdvisorToolsMenu};
    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Busy';
end

function schema=SLDebugModelBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLDebugModelToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLDebugModelToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:ToolBarDebugMenu')};
    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Never';
end

function state=loc_getSLBuildToolBarState(cbinfo)

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    slLicenseState=coder.internal.getSimulinkCoderBaseLicenseState('test');
    wizard=im.isActionInstalled('Simulink:RTWWizard')&&slLicenseState;
    build=im.isActionInstalled('Simulink:RTWBuild')&&slLicenseState;
    build_subsystem=im.isActionInstalled('Simulink:BuildSelectedSubsystem');
    if wizard||build||build_subsystem
        state='Enabled';
    else
        state='Hidden';
    end
end

function schema=SLBuildToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLBuildToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLBuildToolBar');

    schema.childrenFcns={@ToolBarBuildMenu};
    if cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state=loc_getSLBuildToolBarState(cbinfo);
    else
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Busy';
end

function schema=SLFindToolBar(cbinfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:SLFindToolBar';
    schema.label=DAStudio.message('Simulink:studio:SLFindToolBar');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:Find')};
    if~cbinfo.studio.isToolBarVisible(schema.tag)
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Never';
end



function schema=ToolBarNewMenu(cbinfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.tag='Simulink:ToolBarNew';
    schema.label=DAStudio.message('Simulink:studio:ToolBarNew');


    schema.childrenFcns=SLStudio.NewMenu('GetNewMenuChildren',cbinfo);
    if SFStudio.Utils.isStateflowApp(cbinfo)
        schema.defaultActionFcn=schema.childrenFcns{4};
    else

        schema.defaultActionFcn=schema.childrenFcns{1};
    end


    schema.refreshCategories={'SimulinkEvent:Simulation'};

    schema.autoDisableWhen='Never';
end

function schema=ToolBarOpenMenu(cbinfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.tag='Simulink:ToolBarOpen';
    schema.label=DAStudio.message('Simulink:studio:Open');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    schema.childrenFcns=[...
    {im.getAction('Simulink:Open')};...
    {'separator'};...
    SLStudio.FileMenu('generateOpenRecentChildren',cbinfo)
    ];

    schema.defaultActionFcn=schema.childrenFcns{1};
end

function schema=ToolBarSaveMenu(cbinfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.tag='Simulink:ToolBarSave';
    schema.label=DAStudio.message('Simulink:studio:ToolBarSaveMenu');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    children={im.getAction('Simulink:Save'),...
    im.getAction('Simulink:SaveModelReference')
    };
    schema.childrenFcns=children;
    schema.refreshCategories={'SelectionChanged','SimulinkEvent:UndoRedo','interval#24'};
    if isempty(cbinfo.referencedModel)
        schema.defaultActionFcn=im.getAction('Simulink:Save');
    else
        schema.defaultActionFcn=im.getAction('Simulink:SaveModelReference');
    end
end

function schema=ToolBarConfigurationMenu(cbinfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.tag='Simulink:ToolBarConfigurationMenu';
    schema.label=DAStudio.message('Simulink:studio:ConfigurationParameters');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    children={im.getAction('Simulink:ConfigurationParameters')};
    children=[children,{im.getAction('Simulink:ModelReferenceConfigurationParameters')}];
    children=[children,{im.getAction('Simulink:ShowSimulationTarget')}];
    children=[children,{im.getAction('Simulink:ModelProperties')}];

    schema.childrenFcns=children;
    schema.defaultActionFcn=im.getAction('Simulink:ConfigurationParameters');








    schema.refreshCategories={'SelectionChanged'};

    schema.autoDisableWhen='Never';
end

function schema=ToolBarExplorerMenu(cbinfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.tag='Simulink:ToolBarExplorerMenu';
    schema.label=DAStudio.message('Simulink:studio:ModelExplorer');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    children={im.getAction('Simulink:ModelExplorer'),...
    'separator',...
    im.getAction('Simulink:ModelExplorerBaseWorkspace'),...
    im.getAction('Simulink:ModelExplorerDataDictionary'),...
    im.getAction('Simulink:ModelExplorerModelWorkspace'),...
    'separator',...
    im.getAction('Simulink:VariablesUsed'),...
    im.getAction('Simulink:ModelExplorerAssignDictionary'),...
    };

    schema.childrenFcns=children;
    schema.defaultActionFcn=im.getAction('Simulink:ModelExplorer');

    schema.autoDisableWhen='Never';
end

function schema=ToolBarRecordMenu(cbinfo)
    if SFStudio.Utils.isStateflowApp(cbinfo)
        schema=DAStudio.ActionSchema;
        schema.tag='Simulink:ToolBarRecord';
    else
        schema=Simulink.sdi.internal.SLMenus.sdiToolbarMenu(cbinfo);
    end
end

function schema=ToolBarUpdateDiagramMenu(cbinfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.tag='Simulink:ToolBarUpdateDiagramMenu';
    schema.label=DAStudio.message('Simulink:studio:UpdateDiagram');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    children={im.getAction('Simulink:UpdateDiagram'),...
    im.getAction('Simulink:UpdateModelReferenceDiagram')
    };

    schema.childrenFcns=children;
    if isempty(cbinfo.referencedModel)
        schema.defaultActionFcn=im.getAction('Simulink:UpdateDiagram');
    else
        schema.defaultActionFcn=im.getAction('Simulink:UpdateModelReferenceDiagram');
    end

    schema.refreshCategories={'SelectionChanged'};
end

function schema=ToolBarSimulationStopTime(cbinfo)
    schema=DAStudio.EditSchema;
    schema.tooltip=DAStudio.message('Simulink:studio:StopTimeToolTip');
    schema.tag='Simulink:StopTime';

    schema.refreshCategories={'SimulinkEvent:Property:StopTime','interval#24','SimulinkEvent:Simulation'};
    schema.label=DAStudio.message('Simulink:studio:StopTime');
    modelname=cbinfo.model.Name;
    if~isempty(modelname)
        schema.value=get_param(modelname,'StopTime');
    else
        schema.value='';
    end
    schema.callback=@ToolBarSimulationStopTimeCB;
    schema.sizeHint=12;
    schema.minimumSizeHint=6;
    schema.autoDisableWhen='Never';




    cs=getActiveConfigSet(cbinfo.model);
    if isa(cs,'Simulink.ConfigSetRef')||...
        strcmpi(cbinfo.model.SimulationStatus,'external')
        schema.state='Disabled';
    end
end

function ToolBarSimulationStopTimeCB(cbinfo,newTime)
    modelName=SLStudio.Utils.getModelName(cbinfo);
    if~isempty(modelName)
        set_param(modelName,'StopTime',newTime);
    end
end

function schema=ToolBarSimulationMode(cbinfo)
    schema=DAStudio.ChoiceSchema;
    schema.tooltip=DAStudio.message('Simulink:studio:SimulationModeToolTip');
    schema.tag='Simulink:SimulationMode';

    schema.refreshCategories={'SimulinkEvent:Property:SimulationMode','interval#24','SimulinkEvent:Simulation'};
    schema.label=DAStudio.message('Simulink:studio:SimulationMode');
    if SLStudio.Utils.isSimulationRunning(cbinfo)
        schema.state='Disabled';
    end
    schema.current=SLStudio.Utils.getCurrentSimMode(cbinfo);
    schema.entries=SLStudio.Utils.getSimModeEntries(cbinfo);
    schema.callback=@ToolBarSimulationModeCB;


    if length(schema.entries)<2
        schema.state='Hidden';
    end

    schema.autoDisableWhen='Busy';
end

function ToolBarSimulationModeCB(cbinfo,newSelection)

    switch(newSelection)
    case DAStudio.message('Simulink:studio:SimModeAutoToolBar')
        newSelection='Simulink:SimModeAuto';
    case DAStudio.message('Simulink:studio:SimModeNormalToolBar')
        newSelection='Simulink:SimModeNormal';
    case DAStudio.message('Simulink:studio:SimModeAcceleratedToolBar')
        newSelection='Simulink:SimModeAccelerated';
    case DAStudio.message('Simulink:studio:SimModeRapidAcceleratorToolBar')
        newSelection='Simulink:SimModeRapidAccelerator';
    case DAStudio.message('Simulink:studio:SimModeSILToolBar')
        newSelection='Simulink:SimModeSIL';
    case DAStudio.message('Simulink:studio:SimModePILToolBar')
        newSelection='Simulink:SimModePIL';
    case DAStudio.message('Simulink:studio:SimModeExternalToolBar')
        newSelection='Simulink:SimModeExternal';
    end

    SLStudio.Utils.setSimulationMode(cbinfo,newSelection);
end

function schema=ToolBarDebugMenu(cbinfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.tag='Simulink:ToolBarDebugMenu';
    schema.label=DAStudio.message('Simulink:studio:ToolBarDebugMenu');
    schema.refreshCategories={'GenericEvent:Never'};


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    children={im.getAction('Simulink:Debugger'),...
    im.getAction('Stateflow:DebugMenuItem')
    };

    schema.childrenFcns=children;
    schema.defaultActionFcn=@getDefaultDebugAction;

    schema.autoDisableWhen='Busy';
end

function schema=getDefaultDebugAction(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    if isa(cbinfo.domain,'SLM3I.SLDomain')||isa(cbinfo.domain,'InterfaceEditorDomain')
        fcn=im.getAction('Simulink:Debugger');
    else
        fcn=im.getAction('Stateflow:DebugMenuItem');
    end
    schema=dasprivate('dig_get_schema',fcn,cbinfo);
end

function schema=ToolBarBuildMenu(cbinfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.tag='Simulink:ToolBarBuildMenu';
    schema.label=DAStudio.message('Simulink:studio:SLBuildToolBar');
    schema.refreshCategories={'interval#12','SelectionChanged','SimulinkEvent:Simulation'};


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');


    children={im.getAction('Simulink:RTWBuild')};


    children=[children,{im.getAction('Simulink:ModelReferenceRTWBuild')}];

    children=[children,{im.getAction('Simulink:BuildSelectedSubsystem')}];

    children=[children,{im.getAction('Simulink:RTWWizard')}];

    schema.childrenFcns=children;
    schema.defaultActionFcn=im.getAction('Simulink:RTWBuild');
    schema.autoDisableWhen='Busy';
end

function schema=ToolBarAdvisorToolsMenu(cbinfo)
    schema=DAStudio.ActionChoiceSchema;
    schema.tag='Simulink:ToolBarAdvisorToolsMenu';
    schema.label=DAStudio.message('Simulink:studio:SLAdvisorToolsToolBar');
    schema.refreshCategories={'interval#4','SelectionChanged'};


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');

    children={im.getAction('Simulink:ModelAdvisor'),...
    im.getAction('Simulink:UpgradeAdvisor')};

    if slfeature('EditTimeChecking')
        children=[{im.getAction('Simulink:AdvisorEditTimeCheckingForAnalysisMenu'),...
        'separator'},children];
    end
    children{end+1}=im.getAction('Simulink:PerformanceAdvisor');
    children{end+1}=im.getAction('Simulink:CodeGenAdvisor');
    schema.childrenFcns=children;
    schema.defaultActionFcn=im.getAction('Simulink:ModelAdvisorDefault');

    schema.autoDisableWhen='Busy';
end



function schema=Open(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:Open';

    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:Open');
    else
        schema.label='simulink_ui:studio:resources:openModelActionLabel';
    end

    schema.icon=schema.tag;
    schema.accelerator='Ctrl+O';
    schema.callback=@OpenCB;
    schema.refreshCategories={'GenericEvent:Never'};

    schema.autoDisableWhen='Never';
end

function schema=OpenSF(cbinfo)
    schema=Open(cbinfo);
    schema.obsoleteTags={'Stateflow:OpenModelMenuItem'};
end

function OpenCB(cbinfo)
    if SFStudio.Utils.isStateflowApp(cbinfo)
        uiopen('*.sfx');
    else
        uiopen('simulink');
    end
end

function dirtyRefs=getDirtyRefModels(cbinfo)
    dirtyRefs={};
    handles=cbinfo.studio.App.getBlockDiagramHandles;
    for i=1:numel(handles)
        h=handles(i);
        if(h~=cbinfo.model.Handle&&strcmp(get_param(h,'dirty'),'on'))
            dirtyRefs=[dirtyRefs;get_param(h,'name')];%#ok<AGROW>
        end
    end
end

function result=haveDirtyRefModels(cbinfo)
    result=false;
    handles=cbinfo.studio.App.getBlockDiagramHandles;
    for i=1:numel(handles)
        h=handles(i);
        if(h~=cbinfo.model.Handle&&strcmp(get_param(h,'dirty'),'on'))
            result=true;
            return;
        end
    end
end

function schema=Save(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:Save';

    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:Save');
    else
        schema.label='simulink_ui:studio:resources:saveModelLabel';
    end

    schema.icon='Simulink:Save';

    schema.refreshCategories={'interval#8'};

    if isempty(cbinfo.referencedModel)
        schema.accelerator='Ctrl+S';
    end

    if SLM3I.canSaveBlockDiagram(cbinfo.model.Handle)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.userdata=schema.tag;
    schema.callback=@SaveCB;

    schema.autoDisableWhen='Busy';

    if(haveDirtyRefModels(cbinfo))
        schema.label='simulink_ui:studio:resources:saveAllModelLabel';
    end
    schema.accelerator='Ctrl+S';
end

function schema=SaveSF(cbinfo)
    schema=Save(cbinfo);
    schema.obsoleteTags={'Stateflow:SaveModelMenuItem'};
end

function schema=SaveModelReference(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:SaveModelReference';
    schema.label=DAStudio.message('Simulink:studio:SaveModelReference');
    schema.icon='Simulink:SaveModelReference';

    if isempty(cbinfo.referencedModel)
        schema.state='Hidden';
    else
        schema.accelerator='Ctrl+S';
        if SLM3I.canSaveBlockDiagram(cbinfo.referencedModel.Handle)
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    end

    schema.userdata=schema.tag;
    schema.callback=@SaveCB;

    schema.autoDisableWhen='Busy';
end

function SaveCB(cbinfo)
    if strcmp(cbinfo.userdata,'Simulink:Save')

        if isa(cbinfo.domain,'StateflowDI.SFDomain')

            chartId=SFStudio.Utils.getChartId(cbinfo);

            if chartId&&Stateflow.App.IsStateflowApp(chartId)
                Stateflow.App.Studio.ToolBars('SaveCB',cbinfo,chartId);
                return
            end
        end

        SLM3I.saveBlockDiagramAndDirtyRefModels(cbinfo.model.Handle);
    elseif strcmp(cbinfo.userdata,'Simulink:SaveModelReference')
        SLM3I.saveBlockDiagram(cbinfo.referencedModel.Handle);
    end
end

function schema=Print(~)
    schema=sl_action_schema;
    schema.tag='Simulink:Print';
    schema.label=DAStudio.message('Simulink:studio:Print');
    schema.icon=schema.tag;
    schema.accelerator='Ctrl+P';
    schema.callback=@PrintCB;
    schema.refreshCategories={'GenericEvent:Never'};

    schema.autoDisableWhen='Never';
end

function schema=PrintSF(cbinfo)
    schema=Print(cbinfo);
    schema.callback=@PrintSFCB;
    schema.obsoleteTags={'Stateflow:PrintMenuItem'};
end

function schema=PrintIF(cbinfo)
    schema=Print(cbinfo);
    schema.callback=@PrintIFCB;
end

function PrintCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    slActiveEditor=slStudioApp.getActiveEditor;
    slDiagram=slActiveEditor.getDiagram;
    diagramName=slDiagram.getFullName;
    diagramHandle=get_param(diagramName,'Handle');
    SLM3I.SLDomain.showPrintDialog(diagramHandle);
end

function PrintSFCB(cbinfo)
    subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);

    if Stateflow.STT.StateEventTableMan.isStateTransitionTable(subviewerId)&&...
        SFStudio.Utils.isEditorShowingWebContent(cbinfo)

        SFStudio.Utils.executeActionOnSTTUI(cbinfo,'PRINT');

    elseif SFStudio.Utils.isTruthTable(cbinfo)

        Stateflow.TruthTable.TruthTableManager.print(subviewerId);

    else

        subSys=idToHandle(sfroot,subviewerId);
        while subSys~=0&&~isa(subSys,'Simulink.root')&&~isa(subSys,'Simulink.SubSystem')
            subSys=subSys.up;
        end

        slStudioApp=cbinfo.studio.App;
        slDiagram=slStudioApp.topLevelDiagram;
        diagramName=slDiagram.getFullName;
        diagramHandle=get_param(diagramName,'Handle');
        SFStudio.Utils.showPrintDialog(diagramHandle,subviewerId,subSys.Handle);
    end
end

function PrintIFCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    simPrintInterfaceView(slStudioApp);
end



function ret=canUndoInInterfaceView(cbInfo)
    isFeatON=(slfeature('SlInterfacePort')>0);
    ret=isFeatON&&SLStudio.Utils.isInterfaceViewActive(cbInfo);
end

function schema=Undo(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:Undo';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon=schema.tag;
    else
        schema.icon='undo';
    end
    schema.callback=@UndoCB;
    schema.refreshCategories={'SimulinkEvent:UndoRedo','StudioEvent:ExplorerBarHistoryChange'};

    [isSTT,sttId]=SLStudio.Utils.isStateTransitionTable(cbinfo);
    if isSTT

        if~SLStudio.Utils.isLockedSystem(cbinfo)&&...
            Stateflow.STT.StateEventTableMan.canUndo(sttId)

            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Undo','');
            schema.autoDisableWhen='Never';
        else
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CantUndo');
            schema.state='Disabled';
        end

    elseif SFStudio.Utils.isTruthTable(cbinfo)
        subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
        editor=cbinfo.studio.App.getActiveEditor;
        modelH=editor.getStudio.App.blockDiagramHandle;
        modelSimulationStatus=get_param(modelH,'SimulationStatus');
        if~SLStudio.Utils.isLockedSystem(cbinfo)&&strcmp(modelSimulationStatus,'stopped')...
            &&Stateflow.TruthTable.TruthTableManager.canUndo(subviewerId)

            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Undo','');
            schema.autoDisableWhen='Never';
        else
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CantUndo');
            schema.state='Disabled';
        end
    elseif SFStudio.Utils.isRequirementTableChart(cbinfo)
        chartId=SFStudio.Utils.getChartId(cbinfo);
        editor=cbinfo.studio.App.getActiveEditor;
        modelH=editor.getStudio.App.blockDiagramHandle;
        modelSimulationStatus=get_param(modelH,'SimulationStatus');
        if~SLStudio.Utils.isLockedSystem(cbinfo)&&strcmp(modelSimulationStatus,'stopped')...
            &&Stateflow.ReqTable.internal.TableManager.canUndo(chartId)
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Undo','');
            schema.autoDisableWhen='Never';
        else
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CantUndo');
            schema.state='Disabled';
        end
    elseif SLStudio.Utils.isWebBlockInPanel(cbinfo)
        editor=cbinfo.studio.App.getActiveEditor();
        if SLM3I.SLDomain.canUndoInActivePanel(editor)
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Undo','');
        else
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CantUndo');
            schema.state='Disabled';
        end
    elseif(canUndoInInterfaceView(cbinfo)||...
        cbinfo.domain.canUndo(cbinfo.isContextMenu))
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Undo',cbinfo.domain.undoDescription(cbinfo.isContextMenu));
        if SLStudio.Utils.isLockedSystem(cbinfo)
            schema.state='Disabled';
        end
    else
        schema.label=DAStudio.message('Simulink:studio:CantUndo');
        schema.state='Disabled';
    end
end

function schema=UndoSF(cbinfo)
    schema=Undo(cbinfo);
    schema.obsoleteTags={'Stateflow:UndoMenuItem'};
end

function UndoCB(cbinfo)

    [isSTT,sttId]=SLStudio.Utils.isStateTransitionTable(cbinfo);
    if isSTT
        Stateflow.STT.StateEventTableMan.dispatchRequest(sttId,'undo');
    elseif SFStudio.Utils.isTruthTable(cbinfo)
        subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
        Stateflow.TruthTable.TruthTableManager.dispatchRequest(subviewerId,'undo');
    elseif SFStudio.Utils.isRequirementTableChart(cbinfo)
        chartId=SFStudio.Utils.getChartId(cbinfo);
        Stateflow.ReqTable.internal.TableManager.undoReqTable(chartId);
    elseif SLStudio.Utils.isWebBlockInPanel(cbinfo)
        editor=cbinfo.studio.App.getActiveEditor;
        SLM3I.SLDomain.performUndoInActivePanel(editor);
    else
        cbinfo.domain.undo(cbinfo.isContextMenu);
    end
end

function schema=Redo(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:Redo';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon=schema.tag;
    else
        schema.icon='redo';
    end
    schema.callback=@RedoCB;
    schema.refreshCategories={'SimulinkEvent:UndoRedo','StudioEvent:ExplorerBarHistoryChange'};

    [isSTT,sttId]=SLStudio.Utils.isStateTransitionTable(cbinfo);

    if isSTT

        if~SLStudio.Utils.isLockedSystem(cbinfo)&&...
            Stateflow.STT.StateEventTableMan.canRedo(sttId)

            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Redo','');
            schema.autoDisableWhen='Never';
        else
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CantRedo');
            schema.state='Disabled';
        end

    elseif SFStudio.Utils.isTruthTable(cbinfo)
        subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
        editor=cbinfo.studio.App.getActiveEditor;
        modelH=editor.getStudio.App.blockDiagramHandle;
        modelSimulationStatus=get_param(modelH,'SimulationStatus');
        if~SLStudio.Utils.isLockedSystem(cbinfo)&&strcmp(modelSimulationStatus,'stopped')...
            &&Stateflow.TruthTable.TruthTableManager.canRedo(subviewerId)

            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Redo','');
            schema.autoDisableWhen='Never';
        else
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CantRedo');
            schema.state='Disabled';
        end
    elseif SFStudio.Utils.isRequirementTableChart(cbinfo)
        chartId=SFStudio.Utils.getChartId(cbinfo);
        editor=cbinfo.studio.App.getActiveEditor;
        modelH=editor.getStudio.App.blockDiagramHandle;
        modelSimulationStatus=get_param(modelH,'SimulationStatus');
        if~SLStudio.Utils.isLockedSystem(cbinfo)&&strcmp(modelSimulationStatus,'stopped')...
            &&Stateflow.ReqTable.internal.TableManager.canRedo(chartId)
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Redo','');
            schema.autoDisableWhen='Never';
        else
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CantRedo');
            schema.state='Disabled';
        end
    elseif SLStudio.Utils.isWebBlockInPanel(cbinfo)
        editor=cbinfo.studio.App.getActiveEditor();
        if SLM3I.SLDomain.canRedoInActivePanel(editor)
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Redo','');
        else
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CantRedo');
            schema.state='Disabled';
        end
    elseif(cbinfo.domain.canRedo(cbinfo.isContextMenu))

        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Redo',cbinfo.domain.redoDescription(cbinfo.isContextMenu));
        if SLStudio.Utils.isLockedSystem(cbinfo)
            schema.state='Disabled';
        end
        return;

    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CantRedo');
        schema.state='Disabled';
    end
end

function schema=RedoSF(cbinfo)
    schema=Redo(cbinfo);
    schema.obsoleteTags={'Stateflow:RedoMenuItem'};
end

function RedoCB(cbinfo)
    [isSTT,sttId]=SLStudio.Utils.isStateTransitionTable(cbinfo);

    if isSTT
        Stateflow.STT.StateEventTableMan.dispatchRequest(sttId,'redo');
    elseif SFStudio.Utils.isTruthTable(cbinfo)
        subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
        Stateflow.TruthTable.TruthTableManager.dispatchRequest(subviewerId,'redo');
    elseif SFStudio.Utils.isRequirementTableChart(cbinfo)
        chartId=SFStudio.Utils.getChartId(cbinfo);
        Stateflow.ReqTable.internal.TableManager.redoReqTable(chartId);
    elseif SLStudio.Utils.isWebBlockInPanel(cbinfo)
        editor=cbinfo.studio.App.getActiveEditor;
        SLM3I.SLDomain.performRedoInActivePanel(editor);
    else
        cbinfo.domain.redo(cbinfo.isContextMenu);
    end
end

function schema=Cut(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:Cut';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Cut');
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon=schema.tag;
    else
        schema.icon='cut';
    end
    schema.accelerator='Ctrl+X';
    schema.callback=@CutCB;

    schema.refreshCategories={'interval#12','GenericEvent:Clipboard','GenericEvent:Select','SelectionChanged'};

    isSTT=SLStudio.Utils.isStateTransitionTable(cbinfo);

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';

    elseif isSTT&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        schema.state='Enabled';
        schema.autoDisableWhen='Never';

    elseif SFStudio.Utils.isTruthTable(cbinfo)
        schema.state='Enabled';
        schema.autoDisableWhen='Busy';
        schema.autoDisableWhen='Locked';
    elseif~cbinfo.domain.canCut(cbinfo.isContextMenu)
        schema.state='Disabled';
    end
end

function schema=CutSF(cbinfo)
    schema=Cut(cbinfo);
    schema.obsoleteTags={'Stateflow:CutMenuItem'};
    isSTT=SLStudio.Utils.isStateTransitionTable(cbinfo);
    if isSTT&&~SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        schema.state='Disabled';
    end
end

function CutCB(cbinfo)
    isSTT=SLStudio.Utils.isStateTransitionTable(cbinfo);

    if isSTT&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        SFStudio.Utils.executeActionOnSTTUI(cbinfo,'CUT_ACTION');
    elseif SFStudio.Utils.isTruthTable(cbinfo)
        subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
        Stateflow.TruthTable.TruthTableManager.cut(subviewerId);
    else
        cbinfo.domain.doCut(cbinfo.isContextMenu);
    end

end

function schema=Copy(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:Copy';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon=schema.tag;
    else
        schema.icon='copy';
    end
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Copy');
    schema.accelerator='Ctrl+C';
    schema.callback=@CopyCB;
    schema.refreshCategories={'interval#12','GenericEvent:Clipboard','GenericEvent:Select','SelectionChanged'};


    isSTT=SLStudio.Utils.isStateTransitionTable(cbinfo);

    if(isSTT&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)&&...
        ~SLStudio.Utils.isLockedSystem(cbinfo))
        schema.state='Enabled';

    elseif SFStudio.Utils.isTruthTable(cbinfo)&&...
        ~SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Enabled';

    elseif cbinfo.domain.canCopy(cbinfo.isContextMenu)
        schema.state='Enabled';

    else
        schema.state='Disabled';
    end

    schema.autoDisableWhen='Never';
end

function schema=CopySF(cbinfo)
    schema=Copy(cbinfo);
    schema.obsoleteTags={'Stateflow:CopyMenuItem'};
end

function CopyCB(cbinfo)
    isSTT=SLStudio.Utils.isStateTransitionTable(cbinfo);

    if isSTT&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        SFStudio.Utils.executeActionOnSTTUI(cbinfo,'COPY_ACTION');
    elseif SFStudio.Utils.isTruthTable(cbinfo)
        subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
        Stateflow.TruthTable.TruthTableManager.copy(subviewerId);
    else
        cbinfo.domain.doCopy(cbinfo.isContextMenu);
    end
end

function schema=Paste(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:Paste';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Paste');
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon=schema.tag;
    else
        schema.icon='paste';
    end
    schema.accelerator='Ctrl+V';
    schema.callback=@PasteCB;
    schema.refreshCategories={'GenericEvent:Clipboard'};

    isSTT=SLStudio.Utils.isStateTransitionTable(cbinfo);

    if SLStudio.Utils.isLockedSystem(cbinfo)
        schema.state='Disabled';

    elseif isSTT&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        schema.state='Enabled';
        schema.autoDisableWhen='Never';

    elseif SFStudio.Utils.isTruthTable(cbinfo)
        schema.state='Enabled';
        schema.autoDisableWhen='Busy';
        schema.autoDisableWhen='Locked';
    elseif~cbinfo.domain.canPaste(cbinfo.isContextMenu)
        schema.state='Disabled';
    end
end

function schema=PasteSF(cbinfo)
    schema=Paste(cbinfo);
    schema.obsoleteTags={'Stateflow:PasteMenuItem'};
    isSTT=SLStudio.Utils.isStateTransitionTable(cbinfo);
    if isSTT&&~SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        schema.state='Disabled';
    end
end

function PasteCB(cbinfo)
    isSTT=SLStudio.Utils.isStateTransitionTable(cbinfo);

    if isSTT&&SFStudio.Utils.isEditorShowingWebContent(cbinfo)
        SFStudio.Utils.executeActionOnSTTUI(cbinfo,'PASTE_ACTION');
    elseif SFStudio.Utils.isTruthTable(cbinfo)
        subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
        Stateflow.TruthTable.TruthTableManager.paste(subviewerId);
    elseif~SFStudio.Utils.isRequirementTableChart(cbinfo)
        cbinfo.domain.doPaste(cbinfo.isContextMenu);
    end

end


function schema=LibraryBrowser(cbinfo)
    schema=sl_action_schema;
    if~isempty(cbinfo.userdata)
        schema.tag=['Simulink:',cbinfo.userdata,'ShowLibraryBrowser'];
    else
        schema.tag='Simulink:ShowLibraryBrowser';
    end
    schema.label=DAStudio.message('Simulink:studio:ShowLibraryBrowser');
    schema.refreshCategories={'GenericEvent:Never'};
    schema.icon='Simulink:ShowLibraryBrowser';
    schema.callback=@LibraryBrowserCB;

    schema.autoDisableWhen='Never';
end

function LibraryBrowserCB(~)
    slLibraryBrowser;
end

function EmbeddedLibraryBrowserCB(cbinfo)
    slEmbeddedLB(cbinfo.studio);
end

function LibraryBrowserRF(cbinfo,action)
    modelname=cbinfo.model.Name;
    studio=cbinfo.studio;
    lbcomp=studio.getComponent('LibraryBrowser2 LibraryBrowserStudioComponent',modelname);

    if~isempty(lbcomp)&&studio.isComponentVisible(lbcomp)
        action.selected=true;
        action.description=DAStudio.message('simulink_ui:studio:resources:ShowLibraryBrowserActionELBCloseDescription');
    else
        action.selected=false;
        action.description=DAStudio.message('simulink_ui:studio:resources:ShowLibraryBrowserActionDescription');
    end
end

function standaloneLibraryBrowserCB(~)
    slLibraryBrowser;
end

function closeLibraryBrowserCB(~)
    studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;

    if isempty(studios)
        return;
    end

    studio=studios(1);
    ts=studio.getToolStrip();
    as=ts.getActionService;
    as.executeAction('showLibraryBrowserAction');
end

function schema=ModelExplorer(cbinfo)
    schema=sl_action_schema;
    menu=cbinfo.userdata;
    if~isempty(menu)&&~isequal(menu,'View')
        schema.tag=['Simulink:',menu,'ModelExplorer'];
    else
        schema.tag='Simulink:ModelExplorer';
    end
    schema.label=DAStudio.message('Simulink:studio:ModelExplorer');
    schema.tooltip=DAStudio.message('Simulink:studio:ModelExplorerToolTip');
    schema.icon='Simulink:ModelExplorer';
    schema.refreshCategories={'GenericEvent:Never'};
    schema.callback=@ModelExplorerCB;
    if ismac
        schema.accelerator='Meta+H';
    else
        schema.accelerator='Ctrl+H';
    end
    schema.autoDisableWhen='Never';

end

function ModelExplorerCB(cbinfo)
    daexplr('view',cbinfo.uiObject.handle);
end

function schema=ModelExplorerSF(cbinfo)
    schema=ModelExplorer(cbinfo);
    schema.obsoleteTags={'Stateflow:ModelExplorerMenuItem'};
    schema.callback=@ModelExplorerSFCB;
end

function ModelExplorerSFCB(cbinfo)
    id=SFStudio.Utils.getMenuTargetOrSubviewerId(cbinfo);
    sfexplr('view',id);
end

function state=loc_getModelAdvisorState(cbinfo)
    if cbinfo.isContextMenu


        block=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if SLStudio.Utils.objectIsValidBlock(block)
            if SLStudio.Utils.objectIsValidSubsystemBlock(block)||...
                SLStudio.Utils.isBlockMaskOpenable(block)
                state='Enabled';
            else
                state='Disabled';
            end
        else
            state='Hidden';
        end
    else

        rapidAccelInactive=strcmpi(get_param(cbinfo.model.handle,'RapidAcceleratorSimStatus'),'inactive');
        if rapidAccelInactive
            state='Enabled';
        else
            state='Disabled';
        end
    end
end

function schema=ModelAdvisor(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelAdvisor';
    schema.label=DAStudio.message('Simulink:studio:ModelAdvisorUI');
    schema.icon=schema.tag;
    schema.refreshCategories={'GenericEvent:Never'};
    schema.state=loc_getModelAdvisorState(cbinfo);
    schema.userdata='MAStandardUI';
    schema.callback=@ShowModelAdvisorCB;

    schema.autoDisableWhen='Busy';
end

function schema=ModelAdvisorDefault(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelAdvisor';
    schema.label=DAStudio.message('Simulink:studio:ModelAdvisorUI');
    schema.icon=schema.tag;
    schema.refreshCategories={'GenericEvent:Never'};
    schema.state=loc_getModelAdvisorState(cbinfo);
    schema.userdata='default';
    schema.callback=@ShowModelAdvisorCB;
    schema.autoDisableWhen='Busy';
end

function ShowModelAdvisorConfigurationEditorCB(~)
    Simulink.ModelAdvisor.openConfigUI;
end

function ShowModelAdvisorCB(cbinfo)
    MAType=cbinfo.userdata;
    if cbinfo.isContextMenu
        block=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if SLStudio.Utils.objectIsValidSubsystemBlock(block)
            DelayedShowModelAdvisorCB(block.handle);
        end
    else
        if(isa(cbinfo.uiObject,'Stateflow.Object'))
            if(isa(cbinfo.uiObject,'Stateflow.Chart')||...
                isa(cbinfo.uiObject,'Stateflow.StateTransitionTableChart'))||isa(cbinfo.uiObject,'Stateflow.EMChart')
                chart=cbinfo.uiObject;
            else
                chart=cbinfo.uiObject.Chart;
            end
            slpath=chart.path;
            handle=get_param(slpath,'Handle');
        else
            handle=cbinfo.uiObject.handle;
        end

        DelayedShowModelAdvisorCB(handle,'SystemSelector',MAType);
    end
end




function DelayedShowModelAdvisorCB(varargin)
    msg=message('Simulink:studio:ModelAdvisorStartup');
    SLStudio.internal.ScopedStudioBlocker(msg.getString);
    if nargin==1
        modeladvisor(varargin{1});
    else
        modeladvisor(varargin{1},varargin{2},varargin{3});
    end
end

function schema=UpgradeAdvisor(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:UpgradeAdvisor';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:UpgradeAdvisor');
        schema.icon='Simulink:UpgradeAdvisor';
    else
        schema.icon='upgradeAdvisor';
    end
    schema.refreshCategories={'GenericEvent:Never'};
    schema.state=loc_getModelAdvisorState(cbinfo);
    schema.callback=@ShowUpgradeAdvisorCB;
    schema.autoDisableWhen='Busy';
end

function ShowUpgradeAdvisorCB(cbinfo)
    if cbinfo.isContextMenu
        block=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if SLStudio.Utils.objectIsValidSubsystemBlock(block)
            upgradeadvisor(block.handle);
        end
    else
        if(isa(cbinfo.uiObject,'Stateflow.Object'))
            if(isa(cbinfo.uiObject,'Stateflow.Chart')||...
                isa(cbinfo.uiObject,'Stateflow.StateTransitionTableChart'))
                chart=cbinfo.uiObject;
            else
                chart=cbinfo.uiObject.Chart;
            end
            slpath=chart.path;
            handle=get_param(slpath,'Handle');
        else
            handle=cbinfo.uiObject.handle;
        end

        msg=message('Simulink:studio:UpgradeAdvisorStartup');
        SLStudio.internal.ScopedStudioBlocker(msg.getString);
        upgradeadvisor(handle);
    end
end

function schema=ConfigurationParameters(cbinfo)
    schema=sl_action_schema;

    currentModel=cbinfo.studio.App.getActiveEditor().blockDiagramHandle;
    topModel=cbinfo.studio.App.blockDiagramHandle;
    isTopModel=isequal(currentModel,topModel);
    if(isTopModel)
        schema.tag='Simulink:ConfigurationParameters';
        schema.label=DAStudio.message('Simulink:studio:ConfigurationParameters');
        schema.icon='Simulink:ConfigurationParameters';
    else
        schema.tag='Simulink:ContextMenuConfigurationParameters';
        schema.label=DAStudio.message('Simulink:studio:ReferencedConfigurationParametersMenu');
        schema.icon='Simulink:ModelReferenceConfigurationParameters';
    end

    schema.refreshCategories={'GenericEvent:Never'};

    schema.userdata=schema.icon;
    schema.callback=@ConfigurationParametersCB;

    schema.autoDisableWhen='Never';
end

function schema=ConfigurationParametersSF(cbinfo)
    schema=ConfigurationParameters(cbinfo);
    schema.obsoleteTags={'Stateflow:ConfigurationParametersMenuItem'};
end

function ConfigurationParametersCB(cbinfo)
    if strcmp(cbinfo.userdata,'Simulink:ModelReferenceConfigurationParameters')
        modelName=cbinfo.editorModel.Name;
    else
        modelName=cbinfo.model.Name;
    end

    configSet=getActiveConfigSet(modelName);
    openDialog(configSet);
end

function schema=ModelReferenceConfigurationParameters(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelReferenceConfigurationParameters';
    schema.label=DAStudio.message('Simulink:studio:ModelReferenceConfigurationParameters');
    schema.icon='Simulink:ConfigurationParameters';
    schema.refreshCategories={'GenericEvent:Never'};
    if(strcmp(cbinfo.editorModel.name,cbinfo.model.name))
        schema.state='Hidden';
    end

    schema.userdata=schema.tag;
    schema.callback=@ConfigurationParametersCB;

    schema.autoDisableWhen='Never';
end

function schema=UpdateDiagram(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:UpdateDiagram';
    schema.label=DAStudio.message('Simulink:studio:UpdateDiagram');
    schema.icon=schema.tag;
    schema.refreshCategories={'interval#8','SimulinkEvent:Debug'};

    if SLM3I.SLDomain.isUpdateDiagramEnabled(cbinfo.model.handle)
        schema.state='enabled';
    else
        schema.state='disabled';
    end

    schema.userData=schema.tag;
    schema.callback=@UpdateDiagramCB;
    schema.autoDisableWhen='Never';
end

function UpdateDiagramCB(cbinfo)
    if strcmp(cbinfo.userdata,'Simulink:UpdateDiagram')
        SLM3I.SLDomain.updateDiagram(cbinfo.model.Handle);
    elseif strcmp(cbinfo.userdata,'Simulink:UpdateModelReferenceDiagram')
        SLM3I.SLDomain.updateDiagram(cbinfo.referencedModel.Handle);
    end
end

function schema=UpdateModelReferenceDiagram(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:UpdateModelReferenceDiagram';
    schema.label=DAStudio.message('Simulink:studio:UpdateModelReferenceDiagram');
    schema.icon='Simulink:UpdateModelReferenceDiagram';

    schema.refreshCategories={'interval#8','SimulinkEvent:Debug'};

    if isempty(cbinfo.referencedModel)
        schema.state='Hidden';
    else
        schema.accelerator='Ctrl+D';
        if cbinfo.domain.isUpdateDiagramEnabled
            schema.state='enabled';
        else
            schema.state='disabled';
        end
    end
    schema.userData=schema.tag;

    schema.callback=@UpdateDiagramCB;

    schema.autoDisableWhen='Busy';
end

function state=loc_getRefreshBlocksState(cbinfo)




    if~SLStudio.Utils.showInToolStrip(cbinfo)&&SLStudio.Utils.isStateTransitionTable(cbinfo)
        state='Hidden';
    elseif SLM3I.SLCommonDomain.isBdInEditMode(cbinfo.model.handle)
        state='Enabled';
    else
        state='Disabled';
    end
end

function schema=RefreshBlocks(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:RefreshBlocks';
    schema.label=DAStudio.message('Simulink:studio:RefreshBlocks');
    schema.icon=schema.tag;
    schema.state=loc_getRefreshBlocksState(cbinfo);
    schema.callback=@RefreshBlocksCB;
    schema.refreshCategories={'interval#8'};
    schema.autoDisableWhen='Busy';
end

function RefreshBlocksCB(cbinfo)
    try
        cbinfo.model.refreshModelBlocks;
    catch me

        stageName=message('Simulink:studio:RefreshBlocksStageName').getString();
        modelName=SLStudio.Utils.getModelName(cbinfo);
        stage=sldiagviewer.createStage(stageName,'ModelName',modelName);
        oc=onCleanup(@()stage.delete());
        sldiagviewer.reportError(me);
    end
end
function schema=Connect(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ConnectToTarget';
    modelH=cbinfo.model.Handle;

    if strcmp(get_param(modelH,'SimulationMode'),'external')&&...
        strcmp(get_param(modelH,'RapidAcceleratorSimStatus'),'inactive')
        if~cbinfo.queryMenuAttribute('Simulink:SimModeExternal','connected',modelH)
            schema.label=DAStudio.message('Simulink:studio:ConnectToTarget');
            schema.icon='Simulink:TargetDisconnected';
        else
            schema.label=DAStudio.message('Simulink:studio:DisconnectFromTarget');
            schema.icon='Simulink:TargetConnected';
        end


        if strcmp(SLStudio.Utils.getOnTargetOneClickParam(cbinfo),'on')
            schema.state='Hidden';
        end
    else
        schema.state='Hidden';
    end

    schema.refreshCategories={'SimulinkEvent:Property:SimulationMode','SimulinkEvent:ExtModeConnect','SimulinkEvent:ExtModeDisconnect'};

    schema.callback=@ConnectCB;

    schema.autoDisableWhen='Never';
end

function ConnectCB(cbinfo)
    if~isempty(cbinfo.model)
        if cbinfo.queryMenuAttribute('Simulink:SimModeExternal','connected',cbinfo.model.Handle)
            set_param(cbinfo.model.Handle,'SimulationCommand','disconnect');
        else
            set_param(cbinfo.model.Handle,'SimulationCommand','connect');
        end
    end
end

function schema=SimulationInteractiveMultiRun(cbinfo,isToolBar)
    schema=sl_toggle_schema;
    schema.state='Disabled';

    if~isempty(cbinfo.model)
        if(~loc_isSimulationSteppingAvailableForThisMode(cbinfo))
            if isToolBar
                schema.state='Hidden';
            else
                schema.state='Disabled';
            end
        elseif(~loc_isSimulationSteppingEnabled(cbinfo))
            schema.state='Disabled';
        else
            if(isequal(SLStudio.Utils.getSimStatus(cbinfo),'stopped')||...
                strcmpi(get_param(cbinfo.model.Handle,...
                'SimulationStatus'),'compiled'))
                schema.state='Enabled';
            else
                schema.state='Disabled';
            end
            if(isToolBar&&...
                strcmpi(get_param(0,'FastRestartButtonVisible'),'off'))
                schema.state='Hidden';
            end
        end
    end

    initializedStr=get_param(cbinfo.model.Handle,'InitializeInteractiveRuns');
    initialized=strcmpi(initializedStr,'on');
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='Simulink:studio:SimulationInteractiveMultiRun';
    else
        if strcmp(schema.state,'Disabled')
            if initialized
                schema.label=DAStudio.message('Simulink:studio:SimulationInteractiveMultiRunEnabled');
            else
                schema.label=DAStudio.message('Simulink:studio:SimulationInteractiveMultiRunDisabled');
            end
        else
            if initialized
                schema.label=DAStudio.message('Simulink:studio:SimulationDisableInteractiveMultiRun');
            else
                schema.label=DAStudio.message('Simulink:studio:SimulationEnableInteractiveMultiRun');
            end

        end
    end

    schema.refreshCategories={'SimulinkEvent:Simulation','interval#4'};
    schema.icon='Simulink:SimulationInteractiveMultiRun';

    if slfeature('FastRestartAutoNotify')>0
        if~initialized&&...
            strcmp(get_param(cbinfo.model.Handle,'SimulationStatus'),'stopped')&&...
            strcmp(get_param(cbinfo.model.Handle,'FastRestartCompliance'),'compliant')
            schema.icon='fastRestartGlow';
        end
    elseif slfeature('AutoOnFastRestart')>0
        if initialized
            schema.icon='fastRestartGlow';
        end
    end

    schema.callback=@SimulationInteractiveMultiRunCB;

    if initialized
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.autoDisableWhen='Never';
end

function schema=SimulationInteractiveMultiRunToolBar(cbinfo)
    schema=SimulationInteractiveMultiRun(cbinfo,true);
    schema.tag='Simulink:SimulationInteractiveMultiRunToolBar';
end

function schema=SimulationInteractiveMultiRunMenuBar(cbinfo)
    schema=SimulationInteractiveMultiRun(cbinfo,false);
    schema.tag='Simulink:SimulationInteractiveMultiRunMenuBar';
end

function SimulationInteractiveMultiRunCB(cbinfo,~)
    initialized=get_param(cbinfo.model.Handle,'InitializeInteractiveRuns');
    if strcmpi(initialized,'on')
        set_param(cbinfo.model.Handle,'InitializeInteractiveRuns','off');
    else
        set_param(cbinfo.model.Handle,'InitializeInteractiveRuns','on');
    end
end


function schema=SimulationPacingConfiguration(cbinfo,isToolBar)
    schema=sl_action_schema;
    schema.tag='Simulink:SimulationPacingConfiguration';
    schema.label=DAStudio.message('Simulink:studio:SimulationPacingConfiguration');
    schema.icon='Simulink:SimulationPacingConfiguration';
    schema.autoDisableWhen='Never';
    schema.callback=@SimulationPacingConfigurationCB;
    featureVal=slfeature('SimulationPacing');
    if~isempty(cbinfo.model)&&(featureVal>=3||...
        ~isToolBar&&featureVal>=2)
        if~loc_isSimulationSteppingAvailableForThisMode(cbinfo)
            if isToolBar
                schema.state='Hidden';
            else
                schema.state='Disabled';
            end
        else
            if~loc_isSimulationSteppingEnabled(cbinfo)
                schema.state='Disabled';
            else
                schema.state='Enabled';
            end
        end
        modelH=cbinfo.model.handle;
        if~cbinfo.domain.areSimulinkControlItemsVisible(modelH)
            schema.state='Hidden';
        end
    else
        schema.state='Hidden';
    end
end


function SimulationPacingConfigurationCB(cbinfo)

    modelName=SLStudio.Utils.getModelName(cbinfo);
    if strcmp(get_param(modelName,'BlockDiagramType'),'model')

        tabHandle=SLStudio.GetSimulationPacingDialog(get_param(modelName,'handle'));
        tabHandle.showPacingDialog();
    end
end

function schema=SimulationPacingToolBar(cbinfo)
    schema=SimulationPacingConfiguration(cbinfo,true);
end

function schema=SimulationPacingMenuBar(cbinfo)
    schema=SimulationPacingConfiguration(cbinfo,false);
end




function schema=SimulationStepperConfiguration(cbinfo,isToolBar)
    schema=sl_action_schema;
    schema.tag='Simulink:SimulationStepperConfiguration';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:SimulationStepperConfiguration');
        schema.icon='Simulink:SimulationStepperConfiguration';
    else
        schema.icon='simStepBackConfig';
    end
    schema.callback=@SimulationStepperConfigurationCB;
    schema.autoDisableWhen='Never';

    if~isempty(cbinfo.model)
        if~loc_isSimulationSteppingAvailableForThisMode(cbinfo)
            if isToolBar
                schema.state='Hidden';
            else
                schema.state='Disabled';
            end
        else
            if~loc_isSimulationSteppingEnabled(cbinfo)
                schema.state='Disabled';
            else
                schema.state='Enabled';
            end
        end
        simState=cbinfo.model.SimulationStatus;
        modelH=cbinfo.model.handle;





        if~SLM3I.SLCommonDomain.areSimulinkControlItemsVisible(modelH)
            schema.state='Hidden';
        elseif(strcmpi(simState,'running'))
            schema.state='Disabled';
        end
    else
        schema.state='Disabled';
    end
end

function schema=SimulationStepperConfigurationToolBar(cbinfo)
    schema=SimulationStepperConfiguration(cbinfo,true);
end

function schema=SimulationStepperConfigurationMenuBar(cbinfo)
    schema=SimulationStepperConfiguration(cbinfo,false);
end

function SimulationStepperConfigurationCB(cbinfo)

    if strcmp(get_param(cbinfo.model.handle,'BlockDiagramType'),'model')
        sd=SLStudio.GetSimulationStepperDialog(cbinfo.model.handle);
        sd.showStepperDialog();
    end
end

function res=loc_isSimulationSteppingAvailableForThisMode(cbinfo)
    modelH=cbinfo.model.handle;
    sim_mode=SLStudio.Utils.getSimulationModeForToolstrip(modelH);
    switch sim_mode
    case{'normal','accelerator'}
        res=~loc_isLiveSimEnabled(cbinfo);
    otherwise
        res=false;
    end

    if isprop(cbinfo,"studio")
        dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();
        multiSimDockedComponent=cbinfo.studio.getComponent("GLUE2:DDG Component",dataId);
        if~isempty(multiSimDockedComponent)&&((multiSimDockedComponent.isVisible&&...
            simulink.multisim.internal.isRunAllActive(modelH))||...
            simulink.multisim.internal.isRunAllJobRunning(modelH))
            res=false;
        end
    end
end

function res=loc_isLiveSimEnabled(cbinfo)
    modelH=cbinfo.model.handle;
    liveSimEnabled=get_param(modelH,'LiveSimulationEnabled');
    liveSimFeature=slfeature('LiveSimulation')>0;
    switch liveSimEnabled
    case 'on'
        res=liveSimFeature;
    otherwise
        res=false;
    end
end

function res=loc_isPacingEnabled(cbinfo)
    modelH=cbinfo.model.handle;
    sim_mode=SLStudio.Utils.getSimulationModeForToolstrip(modelH);
    pacingEnabled=get_param(modelH,'EnablePacing');
    switch sim_mode
    case{'normal','accelerator'}
        switch pacingEnabled
        case 'on'
            res=true;
        otherwise
            res=false;
        end
    otherwise
        res=false;
    end
end

function res=loc_isCovEnabled(cbinfo)
    modelH=cbinfo.model.handle;
    try
        covEnabled=get_param(modelH,'CovEnable');
    catch
        res=false;
        return;
    end

    switch covEnabled
    case 'on'
        res=true;
    case 'off'
        res=false;
    end
    res=res&&~get_param(modelH,'ModelSlicerActive');
end

function res=loc_isSimulationSteppingEnabled(cbinfo)
    modelH=cbinfo.model.handle;
    res=SLM3I.SLDomain.isSimulationStartPauseContinueEnabled(modelH);
end

function schema=SimulationRollBackOnly(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:SimulationRollBack');
    schema.tag='Simulink:SimulationRollBack';
    schema.refreshCategories={'SimulinkEvent:Simulation','SimulinkEvent:Property:SimulationMode','interval#3'};
    schema.autoDisableWhen='Never';

    if~isempty(cbinfo.model)
        if~loc_isSimulationSteppingAvailableForThisMode(cbinfo)
            schema.state='Disabled';
        elseif~loc_isSimulationSteppingEnabled(cbinfo)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end

        simState=cbinfo.model.SimulationStatus;
        modelH=cbinfo.model.handle;



        if~SLM3I.SLDomain.areSimulinkControlItemsVisible(modelH)
            schema.state='Hidden';
        else
            enabled=get_param(modelH,'EnableRollback');
            compliance=get_param(modelH,'SimulationRollbackCompliance');
            schema.callback=@SimulationRollBackCB;
            schema.icon='Simulink:SimulationRollBack';
            if(isequal(compliance,'noncompliant-fatal'))
                schema.state='Disabled';
                schema.label=DAStudio.message(...
                'Simulink:studio:SimulationStepperNoncompliantRollBack');
            elseif isequal(enabled,'off')
                schema.state='Disabled';
                schema.label=DAStudio.message(...
                'Simulink:studio:SimulationStepperUninitializedRollBack');
            else
                stepper=Simulink.SimulationStepper(cbinfo.model.handle);
                numsteps=get_param(modelH,'NumberOfSteps');
                validity=stepper.validNumberOfStepsToRollback(numsteps);
                switch(validity)
                case-1
                    schema.state='Disabled';
                    schema.label=DAStudio.message(...
                    'Simulink:studio:SimulationRollBack');
                case 0
                    schema.state='Disabled';
                    schema.label=DAStudio.message(...
                    'Simulink:studio:SimulationRollBackEnd');
                case 1
                    schema.state='Enabled';
                    schema.label=DAStudio.message(...
                    'Simulink:studio:SimulationRollBack');
                end
            end
            if strcmpi(simState,'running')...
                ||SLM3I.SLDomain.isSimulationRunningCallback(modelH)
                schema.state='Disabled';
            end
        end
    else
        schema.state='Disabled';
    end

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:stepBackOnlyActionLabel';
        schema.icon='simStepBack';
    end
end

function schema=SimulationRollBack(cbinfo)
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:SimulationRollBack');
    schema.tag='Simulink:SimulationRollBack';
    schema.refreshCategories={'SimulinkEvent:Simulation','SimulinkEvent:Property:SimulationMode','interval#2'};

    if~isempty(cbinfo.model)
        if~loc_isSimulationSteppingAvailableForThisMode(cbinfo)
            schema.state='Hidden';
        elseif~loc_isSimulationSteppingEnabled(cbinfo)
            schema.state='Disabled';
        else
            schema.state='Enabled';
        end

        simState=cbinfo.model.SimulationStatus;
        modelH=cbinfo.model.handle;

        if~SLM3I.SLDomain.areSimulinkControlItemsVisible(modelH)
            schema.state='Hidden';
        else
            enabled=get_param(modelH,'EnableRollback');
            compliance=get_param(modelH,'SimulationRollbackCompliance');
            if(isequal(compliance,'noncompliant-fatal'))
                schema.callback=@SimulationStepperConfigurationCB;
                schema.icon='Simulink:SimulationRollBackConfiguration';
                schema.label=DAStudio.message(...
                'Simulink:studio:SimulationStepperNoncompliantConfiguration');
            elseif(isequal(enabled,'off')||...
                isequal(compliance,'uninitialized'))
                schema.callback=@SimulationStepperConfigurationCB;
                schema.icon='Simulink:SimulationRollBackConfiguration';
                schema.label=DAStudio.message(...
                'Simulink:studio:SimulationStepperConfiguration');
            else
                stepper=Simulink.SimulationStepper(cbinfo.model.handle);
                numsteps=get_param(modelH,'NumberOfSteps');
                validity=stepper.validNumberOfStepsToRollback(numsteps);
                switch(validity)
                case-1
                    schema.callback=@SimulationStepperConfigurationCB;
                    schema.icon='Simulink:SimulationRollBackConfiguration';
                    schema.label=DAStudio.message(...
                    'Simulink:studio:SimulationStepperConfiguration');
                case 0
                    schema.callback=@SimulationRollBackCB;
                    schema.icon='Simulink:SimulationRollBack';
                    schema.state='Disabled';
                    schema.label=DAStudio.message(...
                    'Simulink:studio:SimulationRollBackEnd');
                case 1
                    schema.callback=@SimulationRollBackCB;
                    schema.icon='Simulink:SimulationRollBack';
                    schema.label=DAStudio.message(...
                    'Simulink:studio:SimulationRollBack');
                end
            end
            isDebuggerEnabled=slInternal('sldebug',cbinfo.model.name,'IsDebuggerEnabled');
            if(strcmpi(simState,'running')...
                ||SLM3I.SLDomain.isSimulationRunningCallback(modelH))&&...
                ~isDebuggerEnabled
                schema.state='Disabled';
            elseif(isDebuggerEnabled)
                schema.state='Enabled';
            end
        end
    else
        schema.state='Disabled';
    end

    schema.autoDisableWhen='Never';

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label='simulink_ui:studio:resources:stepBackSplitButtonActionLabel';
        if strcmpi(schema.icon,'Simulink:SimulationRollBack')
            schema.icon='simStepBack';
            schema.tooltip='simulink_ui:studio:resources:stepBackOnlyActionDescription';
        else
            schema.icon='simStepBackConfig';
            schema.tooltip='simulink_ui:studio:resources:stepBackConfigurationActionDescription';
        end
    end
end

function SimulationCannotRollBackCB(~)
    SLStudio.ShowSimulationCannotRollbackDialog;
end

function SimulationRollBackCB(cbinfo)
    modelHandle=cbinfo.model.handle;
    stepper=Simulink.SimulationStepper(modelHandle);


    isPausedInDebugLoop=slInternal('sldebug',cbinfo.model.name,'SldbgIsPausedInDebugLoop');
    isDebuggerActive=slInternal('sldebug',cbinfo.model.name,'IsDebuggerEnabled');
    if isPausedInDebugLoop
        SimulinkDebugger.utils.Stepper.rollback(cbinfo.model.name);
        return;
    elseif isDebuggerActive


        slInternal('sldebug',cbinfo.model.name,'setIsRollingBack',true);
    end

    if(SLM3I.SLCommonDomain.isStateflowLoaded())
        SFStudio.Utils.stateflowSimulationRollbackCB(modelHandle,stepper)
    else
        stepper.rollback();
    end

    if isDebuggerActive

        slInternal('sldebug',cbinfo.model.name,'setIsRollingBack',false);
    end
end

function schema=SimulationForward(cbinfo,isToolBar)
    schema=sl_action_schema;

    schema.refreshCategories={'SimulinkEvent:Simulation',...
    'SimulinkEvent:Property:SimulationMode','interval#2'};
    schema.icon='Simulink:SimulationForward';
    schema.callback=@SimulationForwardCB;
    schema.autoDisableWhen='Never';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:SimulationForward');
    end

    if~isempty(cbinfo.model)
        if~loc_isSimulationSteppingAvailableForThisMode(cbinfo)
            if isToolBar
                schema.state='Hidden';
            else
                schema.state='Disabled';
            end
        else
            if loc_isSimulationSteppingEnabled(cbinfo)
                schema.state='Enabled';
            else
                schema.state='Disabled';
            end
        end

        simState=cbinfo.model.SimulationStatus;
        modelH=cbinfo.model.handle;



        if SLM3I.SLDomain.areSimulinkControlItemsVisible(modelH)
            isDebuggerActive=slInternal('sldebug',cbinfo.model.name,'IsDebuggerEnabled');
            if((strcmpi(simState,'running')||...
                SLM3I.SLDomain.isSimulationRunningCallback(modelH)))&&...
                ~isDebuggerActive
                schema.state='Disabled';
            elseif(strcmpi(simState,'paused')&&...
                Simulink.SimulationStepper(modelH).finishedFinalStep()==1)
                schema.state='Disabled';

                schema.label=DAStudio.message('Simulink:studio:SimulationForwardToStop');
            end
        else
            schema.state='Hidden';
        end
    else
        schema.state='Disabled';
    end
end

function schema=SlDebuggerAdvancedDebugging(cbinfo)
    schema=sl_action_schema;

    schema.refreshCategories={'SimulinkEvent:Simulation',...
    'SimulinkEvent:Property:SimulationMode'};
    schema.callback=@SimulationAdvancedDebuggingCB;
    schema.autoDisableWhen='Never';
    schema.icon='sldebugBlockLevelDebug';
    schema.state='Enabled';
    if~loc_isSimulationSteppingAvailableForThisMode(cbinfo)

        schema.state='Disabled';
    else
        if~slInternal('sldebug',cbinfo.model.name,'IsDebuggerEnabled')
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    end
end

function SimulationAdvancedDebuggingCB(cbinfo)
    modelHandle=cbinfo.model.handle;
    SLM3I.SLCommonDomain.simulationStartDebugging(modelHandle);
    if slfeature('slDebuggerShowOutputWindow')>0

        SimulinkDebugger.DebugSessionAccessor.getDebugSession(cbinfo.model.handle);
    end
end

function schema=SlDebuggerStepOver(cbinfo)
    schema=sl_action_schema;

    schema.refreshCategories={'SimulinkEvent:Simulation',...
    'SimulinkEvent:Property:SimulationMode'};
    schema.callback=@SimulationStepOverCB;
    schema.autoDisableWhen='Never';
    schema.icon='sldebugStepOver';
    schema.state='Enabled';
    if~loc_isSimulationSteppingAvailableForThisMode(cbinfo)

        schema.state='Disabled';
    else
        if slInternal('sldebug',cbinfo.model.name,'IsDebuggerEnabled')
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    end
end

function SimulationStepOverCB(cbinfo)
    modelHandle=cbinfo.model.handle;
    SLM3I.SLCommonDomain.simulationDebugStep(modelHandle,'step over');
end


function schema=SlDebuggerStepIn(cbinfo)
    schema=sl_action_schema;

    schema.refreshCategories={'SimulinkEvent:Simulation',...
    'SimulinkEvent:Property:SimulationMode'};
    schema.callback=@SimulationStepInCB;
    schema.autoDisableWhen='Never';
    schema.icon='sldebugStepIn';
    schema.state='Enabled';
    if~loc_isSimulationSteppingAvailableForThisMode(cbinfo)

        schema.state='Disabled';
    else
        if slInternal('sldebug',cbinfo.model.name,'IsDebuggerEnabled')
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    end
end

function SimulationStepInCB(cbinfo)
    modelHandle=cbinfo.model.handle;
    SLM3I.SLCommonDomain.simulationDebugStep(modelHandle,'step in');
end

function schema=SlDebuggerStepOut(cbinfo)
    schema=sl_action_schema;

    schema.refreshCategories={'SimulinkEvent:Simulation',...
    'SimulinkEvent:Property:SimulationMode'};
    schema.callback=@SimulationStepOutCB;
    schema.autoDisableWhen='Never';
    schema.icon='sldebugStepOut';
    schema.state='Enabled';
    if~loc_isSimulationSteppingAvailableForThisMode(cbinfo)

        schema.state='Disabled';
    else
        if slInternal('sldebug',cbinfo.model.name,'IsDebuggerEnabled')
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    end
end

function SimulationStepOutCB(cbinfo)
    modelHandle=cbinfo.model.handle;
    SLM3I.SLCommonDomain.simulationDebugStep(modelHandle,'step out');
end

function schema=ForwardToolStrip(cbinfo)
    schema=sl_action_schema;

    chartId=SFStudio.Utils.getChartId(cbinfo);
    chartH=sf('IdToHandle',chartId);

    if SFStudio.Utils.isStateflowApp(cbinfo)
        instH=Stateflow.App.Cdr.Runtime.InstanceIndRuntime.instance;
        schema.state='Disabled';


        objExists=~isempty(Stateflow.App.Cdr.Runtime.InstanceIndRuntime.instance.unitTestingInstance);
        if chartH.Locked==true&&objExists&&isequal(instH.currentChartIdInUnitTesting,chartH.Id)&&~Stateflow.App.Cdr.Runtime.InstanceIndRuntime.isStateflowAppInDebugMode()
            schema.state='Enabled';
        end
    end
    schema.callback=@StepForwardOnceAppCB;
    schema.autoDisableWhen='Never';
    schema.tag='Simulink:SimulationForwardToolBar';
    schema.icon='Simulink:SimulationForward';



end
function schema=SimulationForwardToolBar(cbinfo)

    if SFStudio.Utils.isStateflowApp(cbinfo)
        if SLStudio.Utils.showInToolStrip(cbinfo)
            schema=sl_action_schema;
        else
            schema=DAStudio.ActionChoiceSchema;
        end
        chartId=SFStudio.Utils.getChartId(cbinfo);
        chartH=sf('IdToHandle',chartId);
        instH=Stateflow.App.Cdr.Runtime.InstanceIndRuntime.instance;
        if Stateflow.App.Cdr.Runtime.InstanceIndRuntime.isStateflowAppInDebugMode()||~chartH.Locked
            if SLStudio.Utils.showInToolStrip(cbinfo)
                schema.state='Disabled';
            else
                schema.state='Hidden';
            end
        else
            schema.state='Enabled';
        end
        if~SLStudio.Utils.showInToolStrip(cbinfo)
            schema.childrenFcns=generateChildrenSchemaFcns(cbinfo);
            schema.refreshCategories={'interval#2'};
            schema.defaultActionFcn=schema.childrenFcns{1};
        else
            schema.callback=@StepForwardOnceAppCB;
        end
        schema.icon='Simulink:SimulationForward';
        schema.autoDisableWhen='Never';
        schema.refreshCategories={'interval#2'};

    else
        schema=SimulationForward(cbinfo,true);
    end

    schema.tag='Simulink:SimulationForwardToolBar';


    function childSchemas=generateChildrenSchemaFcns(cbinfo)
        chartId=SFStudio.Utils.getChartId(cbinfo);
        chartH=sf('IdToHandle',chartId);
        inputEvents=chartH.find('-isa','Stateflow.Event','Scope','Input');

        isHidden=~chartH.Locked||Stateflow.App.Cdr.Runtime.InstanceIndRuntime.isStateflowAppInDebugMode();

        if~isempty(inputEvents)
            childSchemas=cell(1,2+length(inputEvents));

            childSchemas{1}={@DoStep,{isHidden,1,isHidden}};

            childSchemas{2}='separator';

            for i=1:length(inputEvents)
                eventName=inputEvents(i).Name;
                childSchemas{i+2}={@CallEvent,{eventName,i,isHidden}};
            end
        else
            childSchemas={{@DoStep,{isHidden}}};
        end
    end

    function stepSchema=DoStep(cbinfo)
        stepSchema=sl_action_schema;

        isHidden=cbinfo.userdata{1};
        instH=Stateflow.App.Cdr.Runtime.InstanceIndRuntime.instance;
        if isHidden
            stepSchema.state='Hidden';
        else
            stepSchema.state='Enabled';
        end

        stepSchema.callback=@StepForwardOnceAppCB;
        stepSchema.tag='Stateflow:stepforwardonce';
        if loc_isPacingEnabled(cbinfo)
            stepSchema.icon='Simulink:SimulationStartPacingEnabled';
        else
            stepSchema.icon='Simulink:SimulationStart';
        end
        stepSchema.autoDisableWhen='Never';
        stepSchema.label='Run';

    end

    function eventSchema=CallEvent(cbinfo)
        eventName=cbinfo.userdata{1};
        eventNumber=cbinfo.userdata{2};
        isHidden=cbinfo.userdata{3};

        eventSchema=sl_action_schema;

        if isHidden
            eventSchema.state='Hidden';
        else
            eventSchema.state='Enabled';
        end

        eventSchema.label=[eventName,'()'];
        eventSchema.icon='Stateflow:CallEventFunctionMenuItem';
        eventSchema.callback=@(cbinfo)InvokeEventFunctionAppCB(cbinfo,eventName);
        eventSchema.tag=['Stateflow:calleventfunction_',num2str(eventNumber)];
        eventSchema.autoDisableWhen='Never';
    end
end

function schema=SimulationForwardMenuBar(cbinfo)
    schema=SimulationForward(cbinfo,false);
    schema.tag='Simulink:SimulationForwardMenuBar';
end

function SimulationForwardCB(cbinfo)
    model=cbinfo.model.handle;
    if strcmp('stopped',get_param(model,'SimulationStatus'))
        simTabMode=get_param(model,'SimTabSimulationMode');
        if~strcmp(get_param(model,'SimulationMode'),simTabMode)&&...
            strcmp('off',get_param(model,'UseTemporaryMenuSimulationMode'))
            set_param(model,'UseTemporaryMenuSimulationMode','on');
            set_param(model,'TemporaryMenuSimulationMode',simTabMode);
        end
    end

    if isequal(slfeature('slDebuggerSimStepperIntegration'),0)
        stepper=Simulink.SimulationStepper(model);
        stepper.forward();
        return;
    else
        SLStudio.SimulationForwardInDebuggerCB(cbinfo.model.name,model);
    end
end

function result=isStateflowLoadedIntoMemory
    [~,mexFiles]=inmem;

    result=any(strcmp(mexFiles,'sf'));
end

function state=getDebuggerButtonState(cbinfo)
    persistent inDebugSession;
    if SFStudio.Utils.isStateflowApp(cbinfo)
        state='Disabled';
        chartId=SFStudio.Utils.getChartId(cbinfo);
        chartH=sf('IdToHandle',chartId);
        if chartH.Locked==true&&Stateflow.App.Cdr.Runtime.InstanceIndRuntime.isStateflowAppInDebugMode()
            state='Enabled';
        end
        return;
    end

    state='Hidden';

    if~isStateflowLoadedIntoMemory
        return;
    end

    if isempty(inDebugSession)
        inDebugSession=false;
    end

    if~isempty(cbinfo.model)
        switch cbinfo.model.SimulationStatus
        case 'paused-in-debugger'
            state='Enabled';
            inDebugSession=true;

        case 'running'
            if(inDebugSession)
                state='Disabled';
            end

        case{'stopped','paused','compiled'}

            inDebugSession=false;
        end
    end
end

function schema=setupDebuggerButtonSchema(cbinfo,callbackFcnHandle,label,tag)
    schema=sl_action_schema;
    schema.label=label;
    schema.tag=tag;




    schema.refreshCategories={'Simulink:DebuggerSimulationPause','interval#2'};
    schema.icon=schema.tag;

    schema.state=getDebuggerButtonState(cbinfo);
    schema.callback=callbackFcnHandle;
    schema.autoDisableWhen='Never';
    if SFStudio.Utils.isStateflowApp(cbinfo)
        schema.refreshCategories={'interval#2'};
    end
end

function schema=DebuggerStepIn(cbinfo)
    schema=setupDebuggerButtonSchema(cbinfo,@DebuggerStepInCB,...
    SLStudio.Utils.getMessage(cbinfo,'Stateflow:sfprivate:StepIn'),'Simulink:DebuggerStepIn');
    schema.accelerator='F11';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='stepIn';
    end
end

function DebuggerStepInCB(cbinfo)
    chartInstancePath=Stateflow.Debug.SFBreakpoint.getCurrentChartInstancePath();
    if SFStudio.Utils.isStateflowApp(cbinfo)
        Stateflow.App.Cdr.Runtime.InstanceIndRuntime.dbstepin;
    elseif Stateflow.Debug.DebugRuntimeManager.isJitDebuggerOn()&&~isempty(chartInstancePath)
        Stateflow.internal.Debugger.stepIn();
        Stateflow.Debug.DebugRuntimeManager.exitDebugLoop();
    else
        sfprivate('sfdebug','gui','step');
    end
end

function schema=DebuggerStepOver(cbinfo)
    schema=setupDebuggerButtonSchema(cbinfo,@DebuggerStepOverCB,...
    SLStudio.Utils.getMessage(cbinfo,'Stateflow:sfprivate:StepOver'),'Simulink:DebuggerStepOver');
    schema.accelerator='F10';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='stepOver';
    end
end

function DebuggerStepOverCB(cbinfo)
    chartInstancePath=Stateflow.Debug.SFBreakpoint.getCurrentChartInstancePath();
    if SFStudio.Utils.isStateflowApp(cbinfo)
        Stateflow.App.Cdr.Runtime.InstanceIndRuntime.dbstepover;
    elseif Stateflow.Debug.DebugRuntimeManager.isJitDebuggerOn()&&~isempty(chartInstancePath)
        Stateflow.internal.Debugger.stepOver();
        Stateflow.Debug.DebugRuntimeManager.exitDebugLoop();
    else
        sfprivate('sfdebug','gui','step_over');
    end
end

function schema=DebuggerStepOut(cbinfo)
    schema=setupDebuggerButtonSchema(cbinfo,@DebuggerStepOutCB,...
    SLStudio.Utils.getMessage(cbinfo,'Stateflow:sfprivate:StepOut'),'Simulink:DebuggerStepOut');
    schema.accelerator='Shift+F11';

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='stepOut';
    end
end

function DebuggerStepOutCB(cbinfo)
    chartInstancePath=Stateflow.Debug.SFBreakpoint.getCurrentChartInstancePath();
    if SFStudio.Utils.isStateflowApp(cbinfo)
        Stateflow.App.Cdr.Runtime.InstanceIndRuntime.dbstepout;
    elseif Stateflow.Debug.DebugRuntimeManager.isJitDebuggerOn()&&~isempty(chartInstancePath)
        Stateflow.internal.Debugger.stepOut();
        Stateflow.Debug.DebugRuntimeManager.exitDebugLoop();
    else
        sfprivate('sfdebug','gui','step_out');
    end
end

function schema=StartPauseContinue(cbinfo)
    schema=sl_action_schema;
    simState='stopped';
    if~isempty(cbinfo.model)
        modelH=cbinfo.model.handle;
        simState=cbinfo.model.SimulationStatus;
        if SLM3I.SLDomain.shouldSimulationStartItemHaveAccelerator(modelH)
            schema.accelerator='Ctrl+T';
        end
        if~SLM3I.SLDomain.areSimulinkControlItemsVisible(modelH)
            schema.state='Hidden';
        elseif~SLM3I.SLDomain.isSimulationStartPauseContinueEnabled(modelH)||SLM3I.SLDomain.isSimulationRunningCallback(modelH)
            schema.state='Disabled';
        end
    end


    isPausedInDebugLoop=false;
    if slfeature('slDebuggerSimStepperIntegration')>0
        isPausedInDebugLoop=slInternal('sldebug',cbinfo.model.name,'SldbgIsPausedInDebugLoop');
    end

    if strcmpi(simState,'running')

        if isPausedInDebugLoop
            schema.label=SLStudio.Utils.getMessage(cbinfo,'simulink_ui:studio:resources:simulationContinueLabel');
            schema.icon='continue';
        else
            schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:StartPauseContinuePause');
            if~loc_isLiveSimEnabled(cbinfo)
                isPacingEnabled=loc_isPacingEnabled(cbinfo);
                if~isPacingEnabled
                    schema.icon='Simulink:SimulationPause';
                else
                    schema.icon='simPauseCustomPaced';
                end
                schema.tooltip='simulink_ui:studio:resources:simulationPauseDescription';
            else
                schema.icon='simLivePause';
                schema.state='Disabled';
            end
        end
    else
        isPacingEnabled=loc_isPacingEnabled(cbinfo);

        if SLStudio.Utils.showInToolStrip(cbinfo)
            isCovEnabled=loc_isCovEnabled(cbinfo);

            if(strcmpi(simState,'paused')||...
                strcmpi(simState,'paused-in-debugger'))
                if isPacingEnabled
                    schema.label=SLStudio.Utils.getMessage(cbinfo,'simulink_ui:studio:resources:simulationContinuePacedLabel');
                    schema.icon='simContinueCustomPaced';
                    schema.tooltip='simulink_ui:studio:resources:simulationContinuePacedLabel';
                else
                    schema.label=SLStudio.Utils.getMessage(cbinfo,'simulink_ui:studio:resources:simulationContinueLabel');
                    schema.icon='continue';
                    schema.tooltip='simulink_ui:studio:resources:simulationContinueLabel';
                end
            else
                if isPacingEnabled
                    if isCovEnabled
                        schema.label='simulink_ui:studio:resources:simulationActionPacedLabel';
                        schema.tooltip='simulink_ui:studio:resources:simulationPacedAndCovEnableActionDescription';
                        schema.icon='simPlayCustomCoverage';
                    else
                        schema.label='simulink_ui:studio:resources:simulationActionLabel';
                        schema.tooltip='simulink_ui:studio:resources:simulationPacedActionDescription';
                        schema.icon='simPlayCustomPaced';
                    end
                elseif isPausedInDebugLoop
                    schema.icon='continue';
                elseif isCovEnabled
                    schema.label='simulink_ui:studio:resources:simulationCovEnableActionLabel';
                    schema.tooltip='simulink_ui:studio:resources:simulationCovEnableActionDescription';
                    schema.icon='simPlayCustomCoverage';
                else
                    if~loc_isLiveSimEnabled(cbinfo)
                        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:StartPauseContinueStart');
                        schema.tooltip='simulink_ui:studio:resources:simulationActionDescription';
                        schema.icon='Simulink:SimulationStart';
                    else
                        schema.icon='simLivePlay';
                        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:StartPauseContinueStart');
                        schema.tooltip='simulink_ui:studio:resources:simulationPacedActionDescription';
                    end
                end
            end
        else
            if(strcmpi(simState,'paused')||...
                strcmpi(simState,'paused-in-debugger'))
                schema.label=DAStudio.message('Simulink:studio:StartPauseContinueContinuePacingEnabled');
                schema.icon='Simulink:SimulationStart';
            else
                if isPacingEnabled
                    schema.label=DAStudio.message('Simulink:studio:StartPauseContinueStartPacingEnabled');
                    schema.icon='Simulink:SimulationStartPacingEnabled';
                else
                    schema.label=DAStudio.message('Simulink:studio:StartPauseContinueStart');
                    schema.icon='Simulink:SimulationStart';
                end
            end
        end
    end

    schema.tag='Simulink:StartPauseContinue';
    schema.refreshCategories={'SimulinkEvent:Simulation','interval#2'};
    schema.callback=@StartPauseContinueCB;
    schema.autoDisableWhen='Never';
end

function StartPauseContinueCB(cbinfo)
    modelName=cbinfo.model.name;
    modelHandle=cbinfo.model.handle;
    SLStudio.StartPauseContinue(modelName,modelHandle);
end

function schema=RunAll(cbinfo)
    schema=sl_action_schema;
    schema.state='Disabled';
    dataId=simulink.multisim.internal.blockDiagramAssociatedDataId();

    if~isempty(cbinfo.model)
        modelHandle=cbinfo.model.handle;
        multiSimDockedComponent=cbinfo.studio.getComponent("GLUE2:DDG Component",dataId);

        if~isempty(multiSimDockedComponent)&&...
            simulink.multisim.internal.isRunAllActive(modelHandle)&&...
            ~simulink.multisim.internal.isRunAllJobRunning(modelHandle)
            schema.state='Enabled';
        end
    end

    if loc_isCovEnabled(cbinfo)
        schema.label='simulink_ui:studio:resources:runAllCovEnableActionLabel';
        schema.tooltip='simulink_ui:studio:resources:runAllCovEnableActionDescription';
        schema.icon='simPlayCustomCoverage';
    else
        schema.label='simulink_ui:studio:resources:runAllActionLabel';
        schema.tooltip='simulink_ui:studio:resources:runAllActionDescription';
        if loc_isPacingEnabled(cbinfo)
            schema.icon='simPlayCustomPaced';
        else
            schema.icon='Simulink:SimulationStart';
        end
    end
    schema.autoDisableWhen='Never';
    schema.callback=@RunAllCB;
    schema.autoDisableWhen='Never';
end

function schema=StartPauseContinueSF(cbinfo)

    if SFStudio.Utils.isStateflowApp(cbinfo)
        schema=DAStudio.ActionSchema;
        schema.tag='Simulink:StartPauseContinue';
        instH=Stateflow.App.Cdr.Runtime.InstanceIndRuntime.instance;
        chartId=SFStudio.Utils.getChartId(cbinfo);
        if Stateflow.App.Cdr.Runtime.InstanceIndRuntime.isStateflowAppInDebugMode()
            chartH=sf('IdToHandle',chartId);
            schema.label='Continue';
            schema.icon='Simulink:SimulationStart';
            schema.callback=@StartPauseContinueSFAppCBinDebugMode;
            schema.refreshCategories={'interval#2'};

            schema.state='Disabled';
            if chartH.Locked==true&&Stateflow.App.Cdr.Runtime.InstanceIndRuntime.isStateflowAppInDebugMode()&&(isequal(instH.currentChartIdInUnitTesting,chartH.Id)||isequal(instH.debugStopFileName,chartH.Name))
                schema.state='Enabled';
            end

        else
            schema.label=DAStudio.message('Simulink:studio:StartPauseContinueStart');
            schema.icon='Simulink:SimulationStart';
            schema.callback=@StartPauseContinueSFAppCB;
            chartId=SFStudio.Utils.getChartId(cbinfo);
            chartH=sf('IdToHandle',chartId);
            if chartH.Locked
                if SLStudio.Utils.showInToolStrip(cbinfo)
                    schema.state='Disabled';
                else
                    schema.state='Hidden';
                end
            else
                schema.state='Enabled';
            end
        end
    else
        schema=StartPauseContinue(cbinfo);
        if strcmpi(cbinfo.model.SimulationStatus,'running')
            schema.obsoleteTags={'Stateflow:PauseMenuItem'};
        else
            schema.obsoleteTags={'Stateflow:StartMenuItem'};
        end
    end
    schema.autoDisableWhen='Never';

end


function InvokeEventFunctionAppCB(cbinfo,eventName)
    Stateflow.App.Studio.ToolBars('InvokeEventFunctionAppCB',cbinfo,eventName);
end
function StepForwardOnceAppCB(cbinfo)
    Stateflow.App.Studio.ToolBars('StepForwardOnceAppCB',cbinfo);
end
function StartPauseContinueSFAppCBinDebugMode(~)
    Stateflow.App.Studio.ToolBars('StartPauseContinueSFAppCBinDebugMode');
end
function StartPauseContinueSFAppCB(cbinfo)
    Stateflow.App.Studio.ToolBars('StartPauseContinueSFAppCB',cbinfo);
end
function StopSFAppCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;
    chartId=SFStudio.Utils.getChartId(cbinfo);
    studioTag=cbinfo.studio.getStudioTag;
    Stateflow.App.Studio.ToolBars('StopSFAppCB',editor,chartId,studioTag);
end


function schema=StopDebugging(cbinfo)
    schema=Stop(cbinfo);
    schema.label=SLStudio.Utils.getMessage(cbinfo,'stateflow_ui:studio:resources:stopDebugging');
end

function schema=Stop(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:Stop';
    schema.refreshCategories={'SimulinkEvent:Simulation','interval#4'};
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:Stop');
    schema.icon='Simulink:SimulationStop';
    schema.callback=@SimulationStopCB;
    if~isempty(cbinfo.model)
        modelH=cbinfo.model.handle;
        if~SLM3I.SLDomain.shouldSimulationStartItemHaveAccelerator(modelH)
            schema.accelerator='Ctrl+T';
        end
        if~SLM3I.SLDomain.areSimulinkControlItemsVisible(modelH)
            schema.state='Hidden';
        elseif SLM3I.SLDomain.isRapidAcceleratorRunning(modelH)
            if~strcmp(get_param(cbinfo.model.Name,'SimulationMode'),'external')
                schema.state='Disabled';
            end
        elseif~SLM3I.SLDomain.isSimulationStopEnabled(modelH)
            schema.state='Disabled';
        end

        if simulink.multisim.internal.isRunAllJobRunning(modelH)
            schema.callback=@RunAllStopCB;
            schema.state='Enabled';
        end
    else
        schema.state='Disabled';
    end

    schema.autoDisableWhen='Never';
end

function schema=StopSF(cbinfo)
    if SFStudio.Utils.isStateflowApp(cbinfo)
        schema=sl_action_schema;
        schema.tag='Simulink:Stop';
        schema.refreshCategories={'interval#4'};
        schema.label=DAStudio.message('Simulink:studio:Stop');
        schema.icon='Simulink:SimulationStop';

        schema.state='Disabled';
        instH=Stateflow.App.Cdr.Runtime.InstanceIndRuntime.instance;
        chartId=SFStudio.Utils.getChartId(cbinfo);
        chartH=sf('IdToHandle',chartId);
        if chartH.Locked==true
            if isequal(instH.currentChartIdInUnitTesting,chartH.Id)||...
                (Stateflow.App.Cdr.Runtime.InstanceIndRuntime.isStateflowAppInDebugMode()&&isequal(instH.debugStopFileName,chartH.Name))
                schema.state='Enabled';
            end
        end

        schema.callback=@StopSFAppCB;
        schema.refreshCategories={'interval#2'};
        schema.autoDisableWhen='Never';
    else
        schema=Stop(cbinfo);
    end
    schema.obsoleteTags={'Stateflow:StopMenuItem'};
end
function SimulationStopCB(cbinfo)
    isPausedInDebugLoop=false;
    if slfeature('slDebuggerSimStepperIntegration')>0

        isPausedInDebugLoop=slInternal('sldebug',cbinfo.model.name,'SldbgIsPausedInDebugLoop');
    end

    if~isempty(cbinfo.model)
        modelH=cbinfo.model.handle;
        if isPausedInDebugLoop

            SLM3I.SLDomain.simulationStopDebuggingAndTerminate(modelH);
        else
            SLM3I.SLDomain.simulationStop(modelH);
        end
    end
end

function state=loc_getDebugModelState(cbinfo)
    sim_mode=SLStudio.Utils.getSimulationModeForToolstrip(cbinfo.model.handle);
    sim_mode_checked=strcmpi(sim_mode,'rapid-accelerator');
    fast_restart_disabled=strcmpi(get_param(cbinfo.model.Handle,...
    'InitializeInteractiveRuns'),'off');


    enabled=strcmpi(get_param(0,'SlDebugEnable'),'on');

    if enabled&&~sim_mode_checked&&...
        ~SLStudio.Utils.isBlockDiagramCompiled(cbinfo)&&...
fast_restart_disabled
        state='Enabled';
    else
        state='Disabled';
    end
end

function schema=DebugModelDisabled(~)
    schema=sl_container_schema;
    schema.tag='Simulink:Debugger';
    schema.state='Disabled';
    schema.label=DAStudio.message('Simulink:studio:Debugger');
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function schema=DebugModel(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:Debugger';
    schema.label=DAStudio.message('Simulink:studio:Debugger');
    schema.icon=schema.tag;
    schema.state=loc_getDebugModelState(cbinfo);
    schema.userdata='model';
    schema.callback=@DebugModelCB;

    schema.autoDisableWhen='Busy';
end

function DebugModelCB(cbinfo)
    sldebugui('Create',cbinfo.model.Name);
end

function RunAllCB(cbinfo)
    if~isempty(cbinfo.model)
        modelHandle=cbinfo.model.handle;
        simulink.multisim.internal.runAllMVM(modelHandle)
    end
end

function RunAllStopCB(cbinfo)
    if~isempty(cbinfo.model)
        modelHandle=cbinfo.model.handle;
        simulink.multisim.internal.stopRunAll(modelHandle);
    end
end





