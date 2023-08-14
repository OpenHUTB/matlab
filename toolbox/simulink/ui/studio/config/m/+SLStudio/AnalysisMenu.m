function schema=AnalysisMenu(fncname,cbinfo)



    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        fnc(cbinfo);
    end
end

function schema=ModelAdvisorMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:ModelAdvisorMenu';
    schema.label=DAStudio.message('Simulink:studio:ModelAdvisor');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    AdvisorMenuItems=[schema.childrenFcns;{im.getAction('Simulink:ModelAdvisor'),...
    im.getAction('Simulink:ModelAdvisorLite'),...
    'separator',...
    im.getAction('Simulink:AdvisorEditTimeCheckingConfigure'),...
    im.getAction('Simulink:ModelAdvisorOptions'),...
    'separator',...
    im.getAction('Simulink:UpgradeAdvisor'),...
    }];

    edittimeMenuItem={};
    if slfeature('EditTimeChecking')
        edittimeMenuItem={im.getAction('Simulink:AdvisorEditTimeCheckingForAnalysisMenu')};
    end
    schema.childrenFcns=[edittimeMenuItem,AdvisorMenuItems];
    schema.autoDisableWhen='Busy';

end


function schema=RefactorModelMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:RefactorModelMenu';
    schema.label=DAStudio.message('Simulink:studio:RefactorModelMenu');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    AdvisorMenuItems=[schema.childrenFcns;{im.getAction('Simulink:CloneDetectionUI'),...
    'separator',...
    im.getAction('Simulink:ModelTransformerUI'),...
    'separator',...
    im.getAction('Simulink:CloneDetectionApp'),...
    }];

    schema.childrenFcns=AdvisorMenuItems;
    schema.autoDisableWhen='Busy';

    if license('test','SL_Verification_Validation')
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end

end

function schema=CloneDetectionApp(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:CloneDetectionApp';
    schema.label='Clone Detection App';

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    AdvisorMenuItems=[schema.childrenFcns;{im.getAction('Simulink:OpenCloneDetectionApp'),...
    'separator',...
    im.getAction('Simulink:DefaultCloneDetectionApp'),...
    }];
    schema.childrenFcns=AdvisorMenuItems;
    schema.autoDisableWhen='Busy';

    if license('test','SL_Verification_Validation')
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end

end

function schema=OpenCloneDetectionApp(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:OpenCloneDetectionApp';
    schema.label='Open Clone Detection App';
    schema.callback=@CloneDetectionUICB;

    if~Advisor.Utils.license('test','SL_Verification_Validation')
        schema.state='hidden';
    else
        schema.state='Enabled';
    end
    schema.autoDisableWhen='Never';
end

function schema=DefaultCloneDetectionApp(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:DefaultCloneDetectionApp';
    schema.label='Restore Default View';
    schema.callback=@DefaultCloneDetectionAppCB;

    if~Advisor.Utils.license('test','SL_Verification_Validation')
        schema.state='hidden';
    else
        schema.state='Enabled';
    end

    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    obj=get_param(sysHandle,'CloneDetectionUIObj');
    if isempty(obj)
        schema.state='Disabled';
    end
end

function DefaultCloneDetectionAppCB(cbinfo)
    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    obj=get_param(sysHandle,'CloneDetectionUIObj');

    CloneDetectionUI.internal.util.showEmbedded(obj.ddgRight,'Right','Tabbed');
    CloneDetectionUI.internal.util.showEmbedded(obj.ddgBottom,'Bottom','Tabbed');
    CloneDetectionUI.internal.util.showEmbedded(obj.ddgHelp,'Left','Tabbed');



    obj.exitHiliteMode;
end

function CloneDetectionUICB(cbinfo)
    sysHandle=SLStudio.Utils.getModelName(cbinfo);

    if~license('test','SL_Verification_Validation')
        DAStudio.error('sl_pir_cpp:creator:CloneDetectionLicenseFail');
    end

    if builtin('_license_checkout','SL_Verification_Validation','quiet')>0
        DAStudio.error('sl_pir_cpp:creator:CloneDetectionLicenseCheckOutFail');
    end
    if~exist(['m2m_',get_param(sysHandle,'Name')],'dir')
        obj=CloneDetectionUI.CloneDetectionUI(sysHandle);
    else
        modelDir=dir(['m2m_',sysHandle,'/*.mat']);
        dates=[modelDir.datenum];
        if isempty(dates)
            obj=CloneDetectionUI.CloneDetectionUI(sysHandle);
        else
            [~,newestIndex]=max(dates);
            latestBackUpFile=modelDir(newestIndex);
            loadedObject=load(['m2m_',sysHandle,'/',latestBackUpFile.name]);
            obj=loadedObject.updatedObj;

            if~isempty(obj.m2mObj.refModels)
                CloneDetectionUI.internal.util.loadAllModelRefs(obj.m2mObj.refModels);
            end
            CloneDetectionUI.internal.util.hiliteAllClones(obj.refactorButtonEnable,...
            obj.blockPathCategoryMap,obj.colorCodes);
        end
    end
    CloneDetectionUI.internal.util.showEmbedded(obj.ddgHelp,'Left','Tabbed');
    CloneDetectionUI.internal.util.showEmbedded(obj.ddgRight,'Right','Tabbed');
    CloneDetectionUI.internal.util.showEmbedded(obj.ddgBottom,'Bottom','Tabbed');
    set_param(sysHandle,'CloneDetectionUIObj',obj);
end


function schema=AdvisorEditTimeCheckingConfigure(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:AdvisorEditTimeCheckingConfigure';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ConfigureAdvisorEditTimeChecks');
    else
        schema.icon='modelAdvisorCustomize';
    end
    schema.callback=@configureEditTimeAdvisorChecks;

    if~Advisor.Utils.license('test','SL_Verification_Validation')
        schema.state='hidden';
    else
        schema.state='Enabled';
    end
    schema.autoDisableWhen='Never';
end

function configureEditTimeAdvisorChecks(~)
    Simulink.ModelAdvisor.openConfigUI('edittimeview');
end


function schema=ModelAdvisorOptions(~)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelAdvisorOptions';
    schema.label=[DAStudio.message('Simulink:studio:ModelAdvisorPreferences'),'...'];
    schema.callback=@MAOptions;

    schema.autoDisableWhen='Busy';
end

function MAOptions(cbinfo)
    if(isa(cbinfo.uiObject,'Stateflow.Object'))
        if isa(cbinfo.uiObject,'Stateflow.Chart')||isa(cbinfo.uiObject,'Stateflow.StateTransitionTableChart')
            chart=cbinfo.uiObject;
        else
            chart=cbinfo.uiObject.Chart;
        end
        slpath=chart.path;
        handle=get_param(slpath,'Handle');
    else
        handle=cbinfo.uiObject.handle;
    end
    maOpt=ModelAdvisor.MAOptions(bdroot(getfullname(handle)));
    maOpt.show;
end

function schema=MetricsDashboard(cbinfo)


    schema=sl_action_schema;
    schema.tag='Simulink:MetricsDashboard';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:MetricsDashboard');
    else
        schema.icon='modelMetricsDashboardApp';
    end
    schema.callback=@MetricsDashboardCB;

    if~Advisor.Utils.license('test','SL_Verification_Validation')
        schema.state='hidden';
    else
        schema.state='Enabled';
    end

    schema.autoDisableWhen='Busy';
end


function MetricsDashboardCB(cbinfo)
    if(cbinfo.isContextMenu||(strcmp(cbinfo.menuType,'MenuBar')==1))
        if Advisor.component.isValidAnalysisRoot(cbinfo.getSelection)&&...
            ~isempty(cbinfo.getSelection)
            metricsdashboard(cbinfo.getSelection.getFullName);
        else

            metricsdashboard(cbinfo.uiObject.getFullName);
        end

    else
        metricsdashboard(cbinfo.editorModel.name);
    end
end

function state=loc_getPerformanceAdvisorState(cbinfo)
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

function schema=PerformanceAdvisor(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:PerformanceAdvisor';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:PerformanceAdvisor');
        schema.icon='Simulink:PerformanceAdvisor';
    else
        schema.icon='performanceAdvisor';
    end
    schema.refreshCategories={'GenericEvent:Never'};
    schema.state=loc_getPerformanceAdvisorState(cbinfo);
    schema.callback=@ShowPerformanceAdvisorCB;

    schema.autoDisableWhen='Busy';
end

function ShowPerformanceAdvisorCB(cbinfo)
    if cbinfo.isContextMenu
        block=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if SLStudio.Utils.objectIsValidSubsystemBlock(block)
            performanceadvisor(block.handle);
        end
    else
        if(isa(cbinfo.uiObject,'Stateflow.Object'))
            if(isa(cbinfo.uiObject,'Stateflow.Chart')||...
                isa(cbinfo.uiObject,'Stateflow.StateTransitionTableChart')||...
                isa(cbinfo.uiObject,'Stateflow.TruthTableChart'))
                chart=cbinfo.uiObject;
            else
                chart=cbinfo.uiObject.Chart;
            end
            slpath=chart.path;
            handle=get_param(slpath,'Handle');
        else
            handle=cbinfo.uiObject.handle;
        end

        performanceadvisor(handle);
    end
end

function schema=PerformanceToolsMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:PerformanceToolsMenu';
    schema.label=DAStudio.message('Simulink:studio:PerformanceToolsMenu');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:SimulinkProfiler'),...
    im.getAction('Simulink:PerformanceAdvisor'),...
    im.getAction('Simulink:SolverProfiler')
    };

    schema.autoDisableWhen='Busy';
end

function schema=DataDependencyToolsMenu(~)
    schema=sl_container_schema;
    schema.tag='Simulink:DataDependencyToolsMenu';
    schema.label='Data Dependency';
    schema.childrenFcns={@DataDependencyAction};
    schema.autoDisableWhen='Busy';
end

function schema=DataDependencyAction(~)
    schema=sl_action_schema;
    schema.tag='Simulink:DataDependencyAction';
    schema.label='Data Dependency Analysis';
    schema.refreshCategories={'GenericEvent:Never'};
    schema.state='Enabled';
    schema.callback=@ShowDataDependency;
    schema.autoDisableWhen='Busy';
end

function ShowDataDependency(cbinfo)
    mdl=bdroot(get(SLStudio.Utils.getDiagramHandle(cbinfo),'Name'));
    sldvcompat(mdl);
    se=evalin('base','se');
    dlg=createSEViewer(se,bdroot);%#ok<NASGU>
end

function schema=ModelDependenciesMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:ModelDependenciesMenu';
    schema.label=DAStudio.message('Simulink:studio:ModelDependenciesMenu');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getSubmenu('Simulink:Analysis_DependencyViewerMenu'),...
    'separator',...
    im.getAction('Simulink:ManifestGenerate'),...
    im.getAction('Simulink:ManifestEdit'),...
    im.getAction('Simulink:ManifestCompare'),...
    im.getAction('Simulink:ManifestExport')
    };

    schema.autoDisableWhen='Busy';

    if Simulink.harness.isHarnessBD(SLStudio.Utils.getModelName(cbinfo))
        schema.state='Disabled';
    end
end

function schema=ManifestGenerate(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ManifestGenerate';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ManifestGenerate');
    schema.userdata='generate';
    schema.callback=@ShowManifestCB;

    schema.autoDisableWhen='Busy';
end

function schema=ManifestEdit(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ManifestEdit';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:ManifestEdit');
    end
    schema.userdata='additionalfiles';
    schema.callback=@ShowManifestCB;

    schema.autoDisableWhen='Busy';
end

function schema=ManifestCompare(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ManifestCompare';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ManifestCompare');
    schema.userdata='compare';
    schema.callback=@ShowManifestCB;

    schema.autoDisableWhen='Busy';
end

function schema=ManifestExport(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ManifestExport';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ManifestExport');
    schema.userdata='export';
    schema.callback=@ShowManifestCB;

    schema.autoDisableWhen='Busy';
end

function ShowManifestCB(cbinfo)
    action=cbinfo.userdata;
    modelName=SLStudio.Utils.getModelName(cbinfo);
    dependencies.manifestcallback(action,modelName);
end

function state=loc_getSimulinkProfilerState(cbinfo)
    mode=get_param(cbinfo.model.handle,'SimulationMode');
    wrong_mode=strcmpi(mode,'rapid-accelerator')||strcmpi(mode,'external');
    isBdCompiled=SLM3I.SLDomain.isBdContainingGraphCompiled(cbinfo.model.handle);
    if(isBdCompiled&&wrong_mode)
        state='Disabled';
    else
        state='Enabled';
    end
end

function noop(~,~)
end

function schema=SimulinkProfilerLegacyCallback(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:SimulinkProfiler';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:SimulinkProfiler');
    end
    current=get_param(cbinfo.model.handle,'Profile');

    schema.state=loc_getSimulinkProfilerState(cbinfo);

    if strcmpi(current,'on')
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.callback=@ShowProfilerReportCB;
end

function ShowProfilerReportCB(cbinfo,~)
    if slfeature('SimulinkProfilerV2')<3

        current=get_param(cbinfo.model.handle,'Profile');
        if strcmpi(current,'on')
            set_param(cbinfo.model.handle,'Profile','off');
        else
            set_param(cbinfo.model.handle,'Profile','on');
        end
    else

        cbinfo.EventData=char.empty;
        SimulinkProfiler.AppController.toggleApp('simulinkProfilerApp',cbinfo);
    end
end



function schema=DataTypeDesignMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:DataTypeDesignMenu';
    schema.label=DAStudio.message('Simulink:studio:DataTypeDesignMenu');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:FixedPointInterface'),...
    im.getAction('Simulink:SingleConversionTool'),...
    im.getAction('Simulink:LookupTableOptimizer')...
    };

    schema.autoDisableWhen='Busy';
end


function schema=SolverProfiler(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:SolverProfiler';

    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='solverProfiler';
        schema.label='Simulink:studio:SolverProfiler';
    else
        schema.icon='Simulink:SolverProfiler';
        schema.label=DAStudio.message('Simulink:studio:SolverProfiler');
    end
    schema.callback=@solverprofiler.launchSolverProfiler;
    schema.state=loc_getSolverProfilerState(cbinfo);
    schema.autoDisableWhen='Never';
end

function state=loc_getSolverProfilerState(cbinfo)

    isFastRestartOn=strcmp(get_param(cbinfo.model.handle,'FastRestart'),'on');
    isSteadyStateSim=strcmp(get_param(cbinfo.model.handle,'EnableSteadyStateSolver'),'on');
    if isFastRestartOn||isSteadyStateSim
        state='Disabled';
    else
        state='Enabled';
    end
end

function schema=ModelTransformerUI(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelTransformerUI';
    schema.label=DAStudio.message('Simulink:studio:MdlXformer');
    schema.callback=@MdlXformerCB;

    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    if license('test','SL_Verification_Validation')&&...
        ~strcmp(get_param(sysHandle,'BlockDiagramType'),'library')
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Busy';
end

function MdlXformerCB(cbinfo)
    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    mdltransformer(sysHandle);
end


function schema=CloneDetectionUI_(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CloneDetectionUI';
    schema.label=DAStudio.message('Simulink:studio:CloneDetectionMenu');
    schema.callback=@CloneDetectionCB;
    if license('test','SL_Verification_Validation')
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end
    schema.autoDisableWhen='Busy';
end

function CloneDetectionCB(cbinfo)
    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    clonedetection(sysHandle);
end

function schema=FixedPointInterface(~)


    schema=sl_action_schema;
    schema.tag='Simulink:FixedPointInterface';
    schema.label=DAStudio.message('Simulink:studio:FixedPointInterface');
    schema.callback=@FixedPointToolCB;

    schema.autoDisableWhen='Busy';
end

function FixedPointToolCB(cbinfo)
    sysHandle=SLStudio.Utils.getSLHandleForSelectedHierarchicalBlock(cbinfo);
    fixptopt(sysHandle);
end

function schema=SingleConversionTool(cbinfo)


    schema=sl_action_schema;
    schema.tag='Simulink:SingleConversionTool';
    schema.label=DAStudio.message('Simulink:studio:SingleConversionTool');
    schema.callback=@SingleConversionToolCB;

    schema.autoDisableWhen='Busy';
end

function SingleConversionToolCB(cbinfo)
    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    DoubleToSingleConverter.launch(sysHandle);
end

function schema=LookupTableOptimizer(cbinfo)


    schema=sl_action_schema;
    schema.tag='Simulink:LookupTableOptimizer';
    schema.label=DAStudio.message('Simulink:studio:LookupTableOptimizer');
    schema.callback=@LookupTableOptimizerCB;

    schema.autoDisableWhen='Busy';
end

function LookupTableOptimizerCB(cbinfo)
    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    FunctionApproximation.internal.ui.Wizard.launch(sysHandle);
end
function schema=CoverageMenuDisabled(~)
    schema=sl_container_schema;
    schema.state='Disabled';
    schema.tag='Simulink:CoverageContextMenu';
    schema.label=DAStudio.message('Slvnv:simcoverage:covMenusCoverage');
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
end

function schema=CoverageMenu(cbinfo)
    schema=SlCov.CovMenus.contextMenu(cbinfo);

    schema.autoDisableWhen='Busy';
end

function CollectCoverageCB(cbinfo)
    CoverageAnalysisCB(cbinfo,true);
end

function CoverageAnalysisCB(cbinfo,changeCoverageSetting)
    if nargin==1
        changeCoverageSetting=false;
    end

    cs=getActiveConfigSet(cbinfo.studio.App.blockDiagramHandle);

    if~isempty(cs)
        if changeCoverageSetting
            if cbinfo.EventData
                covEnable='on';
            else
                covEnable='off';
            end
            cs.set_param('CovEnable',covEnable)
        end
        configset.showParameterGroup(cs,{'Coverage'});
    end
end



