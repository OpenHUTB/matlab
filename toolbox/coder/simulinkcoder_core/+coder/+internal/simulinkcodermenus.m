function schema=simulinkcodermenus(funcname,cbinfo)





    fnc=str2func(funcname);
    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        fnc(cbinfo);
    end
end



function schema=CodeGenAdvisor(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CodeGenAdvisor';
    schema.label=DAStudio.message('Simulink:tools:CodeGenAdvisor');
    schema.icon=schema.tag;

    cs=getActiveConfigSet(cbinfo.editorModel);
    if isa(cs,'Simulink.ConfigSet')||isa(cs,'Simulink.ConfigSetRef')
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.callback=@loc_showCodeGenAdvisor;
    schema.autoDisableWhen='Never';
end

function loc_showCodeGenAdvisor(cbinfo)
    if checkUseSlcoderOrEcoderFeaturesBasedOnTarget(cbinfo)
        selectedSystem=modeladvisorprivate('systemselector',cbinfo.editorModel.Name);
        if isempty(selectedSystem)
            return;
        end
        coder.advisor.internal.runBuildAdvisor(selectedSystem,true,false);
    end
end

function res=loc_TestSimulinkCoderInstallation
    res=dig.isProductInstalled('Simulink Coder');
end

function res=loc_TestLicense
    res=license('test','Real-Time_Workshop');
end

function res=loc_TestStandaloneReportInstallation
    res=slfeature('RTWStandaloneReport')&&loc_TestSimulinkCoderInstallation&&loc_TestReportGenInstallation;
end

function res=loc_TestReportGenInstallation
    res=~isempty(ver('rptgenext'))&&loc_TestReportGenLicense;
end

function res=loc_TestReportGenLicense
    res=license('test','MATLAB_Report_Gen')||license('test','SIMULINK_Report_Gen');
end

function res=loc_TestRTT


    res=coder.oneclick.Utils.isFeaturedOn&&...
    coder.oneclick.Utils.isRTTInstalled;
end

function state=loc_getSimulinkCoderMenuState(~)
    if loc_TestLicense
        state='Enabled';
    else
        state='Disabled';
    end
end

function schema=SimulinkCoderMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:SimulinkCoderMenu';
    schema.label=DAStudio.message('Simulink:studio:SimulinkCoderMenu');
    schema.state=loc_getSimulinkCoderMenuState(cbinfo);
    schema.generateFcn=@loc_generateSimulinkCoderMenu;
    schema.autoDisableWhen='Busy';
end

function schema=SimulinkCoderMenuSFLib(cbinfo)%#ok<DEFNU>
    schema=SimulinkCoderMenu(cbinfo);
    schema.generateFcn=@loc_generateSimulinkCoderMenuSFLib;
end

function res=loc_isAutosarCompliant(cbinfo)
    cs=getActiveConfigSet(cbinfo.model);
    while isa(cs,'Simulink.ConfigSetRef')
        if~strcmpi(cs.SourceResolved,'on')
            res=false;
            return;
        end
        cs=cs.getRefConfigSet();
    end

    res=strcmp(get_param(cs,'AutosarCompliant'),'on');
end

function res=loc_isErtCompliant(cbinfo)


    cs=getActiveConfigSet(cbinfo.model);
    while isa(cs,'Simulink.ConfigSetRef')
        if~strcmpi(cs.SourceResolved,'on')
            res=false;
            return;
        end
        cs=cs.getRefConfigSet();
    end

    res=strcmp(get_param(cs,'IsERTTarget'),'on');
end


function children=loc_generateSimulinkCoderMenuSFLib(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    children={im.getAction('Simulink:SimulinkCoderOptions')};
end

function children=loc_generateSimulinkCoderMenu(cbinfo)
    if cbinfo.isContextMenu
        blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
        if length(blocks)==1&&SLStudio.Utils.objectIsValidSubsystemBlock(blocks(1))
            children=loc_generateSubsystemCodeMenu(cbinfo);
        else
            children=loc_generateBlockCodeMenu(cbinfo);
        end
    else
        children=loc_generateMainCodeMenu(cbinfo);
    end
end

function children=loc_generateMainCodeMenu(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    if~loc_isAutosarCompliant(cbinfo)
        buildGroup={
        im.getAction('Simulink:RTWBuild'),...
        im.getAction('Simulink:ModelReferenceRTWBuild'),...
        im.getAction('Simulink:BuildSelectedSubsystem'),...
        im.getAction('Simulink:ExportFunctions'),...
        im.getAction('Simulink:GenerateSFunction'),...
        im.getAction('Simulink:ExportTasks'),...
        };
    else
        buildGroup={
        im.getAction('Simulink:RTWBuild'),...
        im.getAction('Simulink:ModelReferenceRTWBuild'),...
        im.getAction('Simulink:GenerateSFunction'),...
        im.getAction('Simulink:ExportTasks'),...
        };
    end
    configGroup={
    im.getAction('Simulink:CodeGenAdvisor'),...
    im.getAction('Simulink:SimulinkCoderOptions'),...
    im.getAction('Simulink:CodeViewMenu'),...
    im.getAction('Simulink:AutosarConfig'),...
    };
    if loc_isConfigureFunctionInterfaceEnabled
        configGroup=[configGroup,...
        {im.getAction('Simulink:ConfigureFunctionInterface')}];
    end
    if loc_isWizardFeatureEnabled
        configGroup=[{im.getAction('Simulink:RTWWizard')},...
        configGroup];
    end

    if loc_TestStandaloneReportInstallation
        reportGroup={
        im.getAction('Simulink:PublishCode'),...
        'separator',...
        im.getAction('Simulink:CodegenReport'),...
        im.getAction('Simulink:HighlightCode'),...
        };
    else
        reportGroup={
        im.getAction('Simulink:HighlightCode'),...
        im.getAction('Simulink:CodegenReport'),...
        };
    end

    if loc_isCoderDataUIFeatureEnabled
        coderDataGroup={
        im.getAction('Simulink:CoderDataDefinitions')};
    else
        coderDataGroup=[];
    end

    if loc_isWizardFeatureEnabled
        children=[
        configGroup,...
        coderDataGroup,...
        'separator',...
        {im.getAction('Simulink:UpdateDiagramForCodegen')},...
        'separator',...
        buildGroup,...
        'separator',...
        reportGroup,...
        ];
    else
        children=[
        {im.getAction('Simulink:UpdateDiagramForCodegen')},...
        'separator',...
        buildGroup,...
        'separator',...
        coderDataGroup,...
        configGroup,...
        'separator',...
        reportGroup,...
        ];
    end
end
function children=loc_generateSubsystemCodeMenuForLib(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    if loc_isConfigureFunctionInterfaceEnabled
        children={im.getAction('Simulink:ConfigureFunctionInterface')};
    else
        children=[];
    end

end

function children=loc_generateSubsystemCodeMenu(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    buildGroup={
    im.getAction('Simulink:BuildSelectedSubsystem'),...
    im.getAction('Simulink:ExportFunctions'),...
    im.getAction('Simulink:GenerateSFunction'),...
    im.getAction('Simulink:ExportTasks'),...
    };


    if loc_isWizardFeatureEnabled&&strcmp(get_param(cbinfo.model.handle,'IsERTTarget'),'on')
        configGroup={@WizardContextMenu,...
        @CodeGenAdvisorContextMenu};
    else
        configGroup={@CodeGenAdvisorContextMenu};
    end
    if loc_isConfigureFunctionInterfaceEnabled
        configGroup=[configGroup,...
        {im.getAction('Simulink:ConfigureFunctionInterface')}];
    end

    if slfeature('RTWStandaloneReport')
        if loc_TestStandaloneReportInstallation
            reportGroup={
            im.getAction('Simulink:PublishSubsystemCode'),...
            'separator',...
            im.getAction('Simulink:CodegenReportOpenSubsystem'),...
            im.getAction('Simulink:HighlightCode'),...
            };
        else
            reportGroup={
            im.getAction('Simulink:CodegenReportOpenSubsystem'),...
            im.getAction('Simulink:HighlightCode'),...
            };
        end
    else
        reportGroup={
        im.getAction('Simulink:HighlightCode'),...
        im.getAction('Simulink:CodegenReportOpenSubsystem'),...
        };
    end
    if loc_isWizardFeatureEnabled
        children=[
        configGroup,...
        'separator',...
        buildGroup,...
        'separator',...
        reportGroup,...
        ];
    else
        children=[
        buildGroup,...
        'separator',...
        configGroup,...
        'separator',...
        reportGroup,...
        ];
    end
end

function loc_launchCGA(callbackInfo)
    if checkUseSlcoderOrEcoderFeaturesBasedOnTarget(callbackInfo)
        sel=loc_getSelected(callbackInfo);
        coder.advisor.internal.runBuildAdvisor(sel.getFullName,true,false);
    end
end

function sel=loc_getSelected(callbackInfo)
    sel=callbackInfo.getSelection;
    if isempty(sel)
        sel=callbackInfo.uiObject;
    end
end

function state=loc_getAdvisorMenuStatus(callbackInfo)
    state='Hidden';
    try
        sel=loc_getSelected(callbackInfo);
        selProp=get_param(sel.Handle,'ObjectParameters');
        if isfield(selProp,'BlockType')&&strcmp(get_param(sel.Handle,'BlockType'),'SubSystem')
            state='Enabled';
        else
            state='Hidden';
        end
    catch e %#ok
    end
end

function schema=CodeGenAdvisorContextMenu(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:tools:CodeGenAdvisorForSubSystem';
    schema.Label=DAStudio.message(schema.tag);
    schema.callback=@loc_launchCGA;
    schema.state=loc_getAdvisorMenuStatus(callbackInfo);
    schema.autoDisableWhen='Busy';
    schema.icon='Simulink:CodeGenAdvisor';
end

function schemas=loc_generateBlockCodeMenu(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    if loc_isConfigureFunctionInterfaceEnabled
        schemas={
        im.getAction('Simulink:ConfigureFunctionInterface'),...
        im.getAction('Simulink:HighlightCode')};
    else
        schemas={
        im.getAction('Simulink:HighlightCode')
        };
    end

end

function state=loc_getConfigureFunctionInterfaceState(cbinfo)
    isFunctioncallerBlock=false;
    isSimulinkFunctionBlock=false;
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    isSubsystem=SLStudio.Utils.objectIsValidSubsystemBlock(block);
    isBlock=SLStudio.Utils.objectIsValidBlock(block);
    state='Hidden';
    if isBlock
        if isSubsystem
            isSimulinkFunctionBlock=strcmp(get_param(block.handle,'SystemType'),'SimulinkFunction');
        elseif strcmp(get_param(block.handle,'BlockType'),'FunctionCaller')
            isFunctioncallerBlock=true;
        end
        isAUTOSARTarget=strcmp(get_param(cbinfo.model.handle,'AutosarCompliant'),'on');

        if~isAUTOSARTarget&&...
            ((isSimulinkFunctionBlock||isFunctioncallerBlock)...
            &&~codermapping.internal.simulinkfunction.suppressConfigureFunctionInterface(block.handle))
            if loc_isERTTarget(cbinfo)
                state='Enabled';
            else
                state='Hidden';
            end
        else
            state='Hidden';
        end
    end
end

function schema=ConfigureFunctionInterfaceDisabled(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ConfigureFunctionInterface';
    if cbinfo.isContextMenu
        schema.label=message('SimulinkCoderApp:slfpc:ConfigureFunctionInterfaceMenu').getString;
    else
        schema.label=message('SimulinkCoderApp:slfpc:ConfigureFunctionInterfaceForSelectedBlockMenu').getString;
    end
    schema.state='Disabled';
    schema.autoDisableWhen='Busy';
end

function schema=ConfigureFunctionInterface(cbinfo)
    schema=ConfigureFunctionInterfaceDisabled(cbinfo);
    schema.state=loc_getConfigureFunctionInterfaceState(cbinfo);
    schema.callback=@ConfigureFunctionInterfaceCB;
end

function ConfigureFunctionInterfaceCB(cbinfo)
    if checkUseEmbeddedCoderFeatures(cbinfo)
        block=SLStudio.Utils.getOneMenuTarget(cbinfo);
        simulinkcoder.internal.slfpc.FunctionControlDialogManager.openDialog(bdroot(block.handle),block.handle);
    end
end

function state=loc_getErtConfigState(cbinfo)


    isErtCompliant=loc_isErtCompliant(cbinfo);

    if isErtCompliant
        state='Enabled';
    else




        state='Hidden';
    end
end

function schema=CodegenReport(cbinfo)%#ok<DEFNU>

    schema=sl_container_schema;
    schema.tag='Simulink:CodegenReport';
    if slfeature('RTWStandaloneReport')
        schema.label=DAStudio.message('Simulink:studio:ViewCode');
    else
        schema.label=DAStudio.message('Simulink:studio:CodeGenerationReport');
    end
    schema.state='Enabled';
    schema.obsoleteTags={};

    schema.childrenFcns={@CodegenReportOpen,...
    @CodegenReportOpenSubsystem,...
    @CodegenReportOptions
    };

    schema.state=loc_getSimulinkCoderItemState(cbinfo);

end

function schema=CodegenReportOpen(callbackInfo)
    schema=sl_action_schema;
    if slfeature('RTWStandaloneReport')
        if callbackInfo.isContextMenu
            schema.label=DAStudio.message('Simulink:studio:ViewModelCode');
        else
            schema.label=DAStudio.message('Simulink:studio:ModelCode');
        end
    else
        schema.label=DAStudio.message('Simulink:studio:OpenCGReport');
    end
    schema.callback=@LaunchCodegenReportCB;
    schema.tag='Simulink:CodegenReportOpenModel';
end

function LaunchCodegenReportCB(callbackInfo)
    if checkUseSlcoderOrEcoderFeaturesBasedOnTarget(callbackInfo)
        rtw.report.launch(callbackInfo.model.handle);
    end
end


function okStatus=checkUseSimulinkCoderFeatures(callbackInfo)
    okStatus=true;
    modelH=callbackInfo.model.handle;
    if strcmp(get_param(modelH,'UseSimulinkCoderFeatures'),'off')
        diag=MSLException([],message('RTW:configSet:UseSimulinkCoderFeaturesOffErrorMsg',get_param(modelH,'name')));
        sldiagviewer.reportError(diag);
        okStatus=false;
    end
end

function okStatus=checkUseEmbeddedCoderFeatures(callbackInfo)

    okStatus=checkUseSimulinkCoderFeatures(callbackInfo);
    if okStatus
        modelH=callbackInfo.model.handle;
        if strcmp(get_param(modelH,'UseEmbeddedCoderFeatures'),'off')
            diag=MSLException([],message('RTW:configSet:UseEmbeddedCoderFeaturesOffErrorMsg',get_param(modelH,'name')));
            sldiagviewer.reportError(diag);
            okStatus=false;
        end
    end
end


function okStatus=checkUseSlcoderOrEcoderFeaturesBasedOnTarget(callbackInfo)
    modelH=callbackInfo.model.handle;
    if strcmp(get_param(modelH,'IsERTTarget'),'on')
        okStatus=checkUseEmbeddedCoderFeatures(callbackInfo);
    else
        okStatus=checkUseSimulinkCoderFeatures(callbackInfo);
    end
end

function schema=CodegenReportOpenSubsystem(callbackInfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CodegenReportOpenSubsystem';
    if slfeature('RTWStandaloneReport')
        if callbackInfo.isContextMenu
            schema.label=DAStudio.message('Simulink:studio:ViewSubsystemCode');
        else
            schema.label=DAStudio.message('Simulink:studio:SubsystemCode');
        end
    else
        schema.label=DAStudio.message('Simulink:studio:OpenCGReportSubsystem');
    end
    schema.obsoleteTags={};

    block=SLStudio.Utils.getOneMenuTarget(callbackInfo);
    schema.state=loc_getSimulinkCoderItemState(callbackInfo);
    if strcmp(schema.state,'Enabled')
        if SLStudio.Utils.objectIsValidSubsystemBlock(block)
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    end
    schema.callback=@OpenCodegenReportSubsystemCB;
end

function OpenCodegenReportSubsystemCB(callbackInfo)
    if checkUseSlcoderOrEcoderFeaturesBasedOnTarget(callbackInfo)
        block=SLStudio.Utils.getOneMenuTarget(callbackInfo);
        if SLStudio.Utils.objectIsValidSubsystemBlock(block)
            rtw.report.launch(block.getFullPathName);
        end
    end
end

function schema=CodegenReportOptions(callbackInfo)%#ok<INUSD>
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:Options');
    schema.callback=@OptionsCodegenReportCB;
    schema.tag='Simulink:CodegenReportOptions';
end

function schema=PublishCode(cbinfo)%#ok<DEFNU>

    schema=sl_container_schema;
    schema.tag='Simulink:PublishCode';
    schema.label=DAStudio.message('Simulink:studio:PublishCode');
    schema.state='Enabled';
    schema.obsoleteTags={};

    schema.childrenFcns={@PublishModelCode,...
    @PublishSubsystemCode,...
    @PublishCodeOptions
    };

    schema.state=loc_getSimulinkCoderItemState(cbinfo);
end

function schema=PublishModelCode(callbackInfo)%#ok<INUSD>
    schema=sl_action_schema;
    schema.label=DAStudio.message('Simulink:studio:ModelCode');
    schema.callback=@PublishModelCodeCB;
    schema.tag='Simulink:PublishModelCode';
end

function PublishModelCodeCB(callbackInfo)
    sys=callbackInfo.model.handle;
    model=bdroot(sys);
    if~ischar(model)
        model=get_param(model,'Name');
    end
    coder.report.internal.slcoderPublishCodeDlg.publish(model);
end

function schema=PublishSubsystemCode(callbackInfo)
    schema=sl_action_schema;
    schema.tag='Simulink:PublishSubsystemCode';
    if callbackInfo.isContextMenu
        schema.label=DAStudio.message('Simulink:studio:PublishSubsystemCode');
    else
        schema.label=DAStudio.message('Simulink:studio:SubsystemCode');
    end
    schema.obsoleteTags={};

    block=SLStudio.Utils.getOneMenuTarget(callbackInfo);
    schema.state=loc_getSimulinkCoderItemState(callbackInfo);
    if strcmp(schema.state,'Enabled')
        if SLStudio.Utils.objectIsValidSubsystemBlock(block)
            schema.state='Enabled';
        else
            schema.state='Disabled';
        end
    end
    schema.callback=@PublishSubsystemCodeCB;
end

function PublishSubsystemCodeCB(callbackInfo)
    block=SLStudio.Utils.getOneMenuTarget(callbackInfo);
    if SLStudio.Utils.objectIsValidSubsystemBlock(block)
        coder.report.internal.slcoderPublishCodeDlg.publish(block.getFullPathName);
    end
end

function schema=PublishCodeOptions(callbackInfo)%#ok<INUSD>
    schema=sl_action_schema;
    schema.tag='Simulink:PublishCodeOptions';
    schema.label=DAStudio.message('Simulink:studio:Options');
    schema.callback=@PublishCodeOptionsCB;
end

function PublishCodeOptionsCB(callbackInfo)
    modelName=callbackInfo.model.Name;
    if~isempty(modelName)
        DAStudio.Dialog(StdRptDlg.RTW(get_param(modelName,'Object')));
    end
end

function OptionsCodegenReportCB(callbackInfo)
    if checkUseSlcoderOrEcoderFeaturesBasedOnTarget(callbackInfo)
        configSet=getActiveConfigSet(callbackInfo.model);
        configset.showParameterGroup(configSet,{'Code Generation','Report'});
    end
end

function schema=CodeViewMenu(cbinfo)%#ok<DEFNU>
    schema=sl_toggle_schema;
    schema.tag='Simulink:CodeViewMenu';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'SimulinkCoderApp:codeperspective:CodePerspectiveMenu');
    schema.callback=@CodeViewMenuCB;


    modelH=cbinfo.model.Handle;
    cp=simulinkcoder.internal.CodePerspective.getInstance;
    if cp.isAvailable(modelH)
        schema.state='Enabled';
    else
        schema.state='Hidden';
    end
    if cp.isInPerspective(modelH)
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
end

function CodeViewMenuCB(cbinfo)
    st=cbinfo.studio;
    simulinkcoder.internal.CodePerspective.getInstance.togglePerspective(st.App.getActiveEditor);
end

function schema=AutosarConfig(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:AutosarPropertiesConfig';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:AutosarPropertiesConfig');
    schema.callback=@AutosarConfigCB;
    schema.state='Hidden';
    isAutosarCompliant=loc_isAutosarCompliant(cbinfo);
    modelMapping=Simulink.CodeMapping.get(cbinfo.model.Handle,'AutosarTarget');
    isSubComponent=false;
    if autosarinstalled()
        if isempty(modelMapping)
            modelMapping=Simulink.CodeMapping.get(cbinfo.model.Handle,'AutosarTargetCPP');
        else
            isSubComponent=modelMapping.IsSubComponent;
        end
        if isAutosarCompliant&&~isempty(modelMapping)&&~isSubComponent
            schema.state='Enabled';
        end
    end
end

function AutosarConfigCB(cbinfo)
    if checkUseEmbeddedCoderFeatures(cbinfo)
        assert(autosarinstalled(),'AUTOSAR Blockset is not installed');
        mdlH=SLStudio.Utils.getDiagramHandle(cbinfo);
        autosar_ui_launch(mdlH);
    end
end

function state=loc_getSimulinkCoderItemState(cbinfo)
    state='Enabled';
    rapidAccelStatus=get_param(cbinfo.model.handle,'RapidAcceleratorSimStatus');
    if~loc_TestLicense||~strcmpi(rapidAccelStatus,'inactive')
        state='Disabled';
    end
end

function state=loc_getSimulinkCoderAndRTTItemState(cbinfo)




    if~coder.internal.getSimulinkCoderBaseLicenseState('test')
        state='Hidden';
    else
        state='Enabled';
        rapidAccelStatus=get_param(cbinfo.model.handle,'RapidAcceleratorSimStatus');
        if(~loc_TestLicense&&~loc_TestRTT)||~strcmpi(rapidAccelStatus,'inactive')
            state='Disabled';
        end
    end
end

function out=loc_isConfigureFunctionInterfaceEnabled
    out=dig.isProductInstalled('Embedded Coder')&&...
    simulinkcoder.internal.app.FeatureChecker.isFunctionPrototypeControlFeatureOn;
end






function out=loc_isCoderDataUIFeatureEnabled
    out=dig.isProductInstalled('Embedded Coder');
end


function out=loc_isCoderDataUIMenuVisble(cbinfo)
    out=loc_isCoderDataUIFeatureEnabled&&loc_isERTTarget(cbinfo)&&~loc_isAutosarCompliant(cbinfo)&&...
    ~strcmp(get_param(cbinfo.model.handle,'TargetLang'),'C++');
end

function schema=CoderDataDefinitions(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:CoderDataDefinitions';
    schema.label=message('SimulinkCoderApp:ui:MenuCoderDataDefinitions').getString;
    schema.state='Enabled';
    if~loc_isCoderDataUIMenuVisble(cbinfo)
        schema.state='Hidden';
    end
    schema.callback=@CoderDataDefinitionsCB;
    schema.autoDisableWhen='Busy';
end

function CoderDataDefinitionsCB(cbinfo)
    if checkUseEmbeddedCoderFeatures(cbinfo)


        studio=cbinfo.studio;
        editor=studio.App.getActiveEditor;
        currentModelH=editor.blockDiagramHandle;
        modelName=get_param(currentModelH,'Name');
        simulinkcoder.internal.util.createMappingAndInitDictIfNecessary(modelName,true);
        simulinkcoder.internal.app.entryPoint(currentModelH);
    end
end


function res=loc_isWizardFeatureEnabled
    res=dig.isProductInstalled('Embedded Coder')&&...
    coder.internal.wizard.Wizard.isFeatureOn;
end

function schema=Wizard(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:RTWWizard';
    schema.label=message('RTW:wizard:QuickStartMenu').getString;
    schema.icon=schema.tag;
    if loc_isWizardFeatureEnabled&&~strcmp(get_param(cbinfo.model.handle,'BlockDiagramType'),'library')
        schema.state=coder.internal.wizard.getWizardMenuState(cbinfo,false);
    else
        schema.state='Hidden';
    end
    schema.callback=@QuickStartWizardCB;
    schema.autoDisableWhen='Busy';
end

function QuickStartWizardCB(cbinfo)
    if checkUseEmbeddedCoderFeatures(cbinfo)
        model=bdroot(cbinfo.model.handle);
        coder.internal.wizard.slcoderWizard(model,'Start');
    end
end

function QuickStartWizardSubsysCB(callbackInfo)
    if checkUseEmbeddedCoderFeatures(callbackInfo)
        sel=loc_getSelected(callbackInfo);
        coder.internal.wizard.slcoderWizard(sel.getFullName,'Start');
    end
end
function schema=WizardContextMenu(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:tools:WizardForSubSystem';
    schema.Label=message('RTW:wizard:QuickStartMenu').getString;
    schema.callback=@QuickStartWizardSubsysCB;
    schema.state=coder.internal.wizard.getWizardMenuState(callbackInfo,true);
    schema.autoDisableWhen='Busy';
    schema.icon='Simulink:RTWWizard';
end

function schema=BuildModel(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:RTWBuild';
    schema.label=loc_getBuildModelOrSubsystemLabel(cbinfo,'model');
    schema.icon=schema.tag;
    schema.state=loc_getSimulinkCoderAndRTTItemState(cbinfo);
    schema.callback=@BuildModelCB;
    schema.userdata=schema.tag;
    schema.autoDisableWhen='Busy';
end

function schema=BuildReferencedModel(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ModelReferenceRTWBuild';
    schema.label=loc_getBuildModelOrSubsystemLabel(cbinfo,'refmodel');
    schema.icon=schema.tag;
    schema.state=loc_getSimulinkCoderAndRTTItemState(cbinfo);
    schema.callback=@BuildModelCB;
    schema.userdata=schema.tag;
    schema.autoDisableWhen='Busy';

    if(strcmp(cbinfo.editorModel.name,cbinfo.model.name))
        schema.state='Hidden';
    end
end

function schema=BuildLibrary(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:RTWBuild';
    schema.label=loc_getBuildModelOrSubsystemLabel(cbinfo,'library');
    schema.icon=schema.tag;
    schema.state=loc_getSimulinkCoderAndRTTItemState(cbinfo);
    schema.callback=@BuildModelCB;
    schema.autoDisableWhen='Busy';
end

function BuildModelCB(cbinfo)
    if(strcmp(cbinfo.userdata,'Simulink:ModelReferenceRTWBuild'))
        modelName=cbinfo.editorModel.Name;
    else
        modelName=cbinfo.model.Name;
    end

    handle=get_param(modelName,'Handle');
    cbinfo.domain.buildModel(handle);
end

function label=loc_getBuildModelOrSubsystemLabel(cbinfo,sysType)


    [~,useDeployTerms]=coder.oneclick.Utils.isOneClickWorkflowEnabled(cbinfo.model.Name,...
    'SuppressExceptions',true);

    switch(sysType)
    case 'model'
        if useDeployTerms
            label=DAStudio.message('Simulink:studio:RTWDeploy');
        else
            label=DAStudio.message('Simulink:studio:RTWBuild');
        end

    case 'refmodel'
        if useDeployTerms
            label=DAStudio.message('Simulink:studio:RefModelRTWDeploy');
        else
            label=DAStudio.message('Simulink:studio:RefModelRTWBuild');
        end

    case 'subsystem'
        if cbinfo.isContextMenu
            if useDeployTerms
                label=DAStudio.message('Simulink:studio:DeployThisSubsystem');
            else
                label=DAStudio.message('Simulink:studio:BuildThisSubsystem');
            end
        else
            if useDeployTerms
                label=DAStudio.message('Simulink:studio:DeploySelectedSubsystem');
            else
                label=DAStudio.message('Simulink:studio:BuildSelectedSubsystem');
            end
        end
    case 'library'
        label=DAStudio.message('Simulink:studio:BuildLibrary');
    otherwise
        assert(false,'Unsupported option "%s".',sysType);
    end
end

function res=loc_isSimulinkCoderSubsystemCodeTargetsEnabled(cbinfo)
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    single_subsystem=SLStudio.Utils.objectIsValidSubsystemBlock(obj);
    res=single_subsystem&&...
    strcmpi(get_param(cbinfo.model.handle,'RapidAcceleratorSimStatus'),'inactive');
end

function state=loc_getBuildSelectedSubsystemState(cbinfo)
    if loc_TestLicense&&loc_isSimulinkCoderSubsystemCodeTargetsEnabled(cbinfo)

        state='Enabled';

        obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if SLStudio.Utils.objectIsValidSubsystemBlock(obj)
            objH=obj.handle;
            if slprivate('isCommentedOut',objH)
                state='Disabled';
            end
        end

    else
        state='Disabled';
    end
end

function schema=BuildSelectedSubsystemDisabled(~)
    schema=sl_action_schema;
    schema.tag='Simulink:BuildSelectedSubsystem';
    schema.label=DAStudio.message('Simulink:studio:BuildSelectedSubsystem');
    schema.icon=schema.tag;
    schema.state='Disabled';
    schema.obsoleteTags={'Simulink:SSGenCode'};
    schema.autoDisableWhen='Busy';
end

function schema=BuildSelectedSubsystem(cbinfo)%#ok<DEFNU>
    schema=BuildSelectedSubsystemDisabled(cbinfo);
    schema.label=loc_getBuildModelOrSubsystemLabel(cbinfo,'subsystem');
    schema.state=loc_getBuildSelectedSubsystemState(cbinfo);
    schema.callback=@BuildSelectedSubsystemCB;
end

function BuildSelectedSubsystemCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidSubsystemBlock(block)
        cbinfo.domain.buildSelectedSubsystem(block);
        coder.internal.toolstrip.callback.launchCodePerspective(cbinfo);
    end
end

function schema=GenerateSFunctionDisabled(~)
    schema=sl_action_schema;
    schema.tag='Simulink:GenerateSFunctions';
    schema.label=DAStudio.message('Simulink:studio:GenerateSFunctions');
    schema.state='Disabled';
    schema.obsoleteTags={'Simulink:SfunTarget'};
    schema.autoDisableWhen='Busy';
end

function schema=GenerateSFunction(cbinfo)%#ok<DEFNU>
    schema=GenerateSFunctionDisabled(cbinfo);
    schema.state=loc_getBuildSelectedSubsystemState(cbinfo);

    schema.callback=@GenerateSFunctionCB;
end

function GenerateSFunctionCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidSubsystemBlock(block)
        cbinfo.domain.generateSFunction(block);
        coder.internal.toolstrip.callback.launchCodePerspective(cbinfo);
    end
end

function res=loc_isERTTarget(cbinfo)
    try
        res=get_param(cbinfo.model.Handle,'IsERTTarget');
        res=strcmpi(res,'on');
    catch %#ok<CTCH>
        res=false;
    end
end

function res=loc_isExportFunctionsFeatureEnabled
    res=license('test','RTW_Embedded_Coder')&&...
    ~(slfeature('SSBuildExportFunctions')<1);
end

function state=loc_getExportFunctionsState(cbinfo)
    state='Enabled';
    if loc_isExportFunctionsFeatureEnabled
        block=SLStudio.Utils.getOneMenuTarget(cbinfo);
        if~loc_isERTTarget(cbinfo)||...
            ~loc_isSimulinkCoderSubsystemCodeTargetsEnabled(cbinfo)||...
            (SLStudio.Utils.objectIsValidSubsystemBlock(block)&&Simulink.harness.internal.isHarnessCUT(block.handle))
            state='Disabled';
        end
    end
end

function schema=ExportFunctionsDisabled(~)
    schema=sl_action_schema;
    schema.tag='Simulink:ExportFunctions';
    schema.label=DAStudio.message('Simulink:studio:ExportFunctions');
    schema.state='Disabled';
    schema.obsoleteTags={'Simulink:SSExportFunctions'};
    schema.autodisableWhen='Busy';
end

function schema=ExportFunctions(cbinfo)%#ok<DEFNU>
    schema=ExportFunctionsDisabled(cbinfo);
    schema.state=loc_getExportFunctionsState(cbinfo);
    schema.callback=@ExportFunctionsCB;
end

function ExportFunctionsCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidSubsystemBlock(block)
        cbinfo.domain.exportFunctions(block);
        coder.internal.toolstrip.callback.launchCodePerspective(cbinfo);
    end
end

function res=loc_isExportTasksFeatureEnabled
    res=license('test','RTW_Embedded_Coder')&&...
    ~(slfeature('SSBuildExportFunctions')<2);
end

function state=loc_getExportTasksState(cbinfo)
    if loc_isExportTasksFeatureEnabled
        if loc_isERTTarget(cbinfo)&&...
            loc_isSimulinkCoderSubsystemCodeTargetsEnabled(cbinfo)
            state='Enabled';
        else
            state='Disabled';
        end
    else
        state='Hidden';
    end
end

function schema=ExportTasksDisabled(~)
    schema=sl_action_schema;
    schema.tag='Simulink:ExportTasks';
    schema.label=DAStudio.message('Simulink:studio:ExportTasks');
    schema.state='Disabled';
    schema.autoDisableWhen='Busy';
end

function schema=ExportTasks(cbinfo)%#ok<DEFNU>
    schema=ExportTasksDisabled(cbinfo);
    schema.state=loc_getExportTasksState(cbinfo);
    schema.callback=@ExportTasksCB;
end

function ExportTasksCB(cbinfo)
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if SLStudio.Utils.objectIsValidSubsystemBlock(block)
        cbinfo.domain.exportTasks(block);
    end
end

function schema=SimulinkCoderOptions(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:SimulinkCoderOptions';
    schema.label=DAStudio.message('Simulink:studio:SimulinkCoderOptions');
    schema.state=loc_getSimulinkCoderMenuState(cbinfo);
    schema.callback=@SimulinkCoderOptionsCB;
    schema.autoDisableWhen='Busy';
end

function SimulinkCoderOptionsCB(cbinfo)
    cs=getActiveConfigSet(cbinfo.model.handle);
    page='Code Generation';
    configset.showParameterGroup(cs,{page});
end

function schema=SimulinkCoderOptionsSF(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:SimulinkCoderOptions';
    schema.label=DAStudio.message('Simulink:studio:SimulinkCoderOptions');
    schema.state=loc_getSimulinkCoderMenuState(cbinfo);
    schema.callback=@SimulinkCoderOptionsSFCB;
    schema.autoDisableWhen='Busy';
end

function SimulinkCoderOptionsSFCB(cbinfo)
    machine=SFStudio.Utils.getMachineId(cbinfo);
    sfprivate('goto_target',machine,'rtw');
end

function state=loc_getNavigateToCodeState(cbinfo)
    state='Disabled';
    if loc_isERTTarget(cbinfo)
        generate_trace=strcmpi(get_param(cbinfo.model.Handle,'GenerateTraceInfo'),'on');
        if generate_trace
            blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
            if~isempty(blockHandles)
                exist_trace=coder.internal.slcoderReport('existTrace',cbinfo.model.name);
                if exist_trace
                    state=loc_getSimulinkCoderMenuState(cbinfo);
                end
            end
        end
    end
end

function schema=NavigateToCodeDisabled(~)
    schema=sl_action_schema;
    schema.tag='Simulink:HighlightCode';
    schema.label=DAStudio.message('Simulink:studio:HighlightCode');
    schema.state='Disabled';
    schema.autoDisableWhen='Busy';
end

function schema=NavigateToCode(cbinfo)%#ok<DEFNU>
    schema=NavigateToCodeDisabled(cbinfo);
    schema.state=loc_getNavigateToCodeState(cbinfo);
    schema.callback=@NavigateToCodeCB;
end

function NavigateToCodeCB(cbinfo)
    if checkUseEmbeddedCoderFeatures(cbinfo)
        blockHandles=SLStudio.Utils.getSelectedBlockHandles(cbinfo);
        if~isempty(blockHandles)
            cbinfo.domain.navigateToCode(blockHandles);
        end
    end
end

function UpdateDiagramForCodegenCB(cbinfo)
    modelName=getfullname(cbinfo.model.Handle);
    my_stage=sldiagviewer.createStage('Update Diagram for code generation','ModelName',modelName);%#ok<NASGU>
    try
        Simulink.output.evalInContext('feval(modelName, [],[],[], ''compileForCodegen'')');
        Simulink.output.evalInContext('feval(modelName, [],[],[], ''term'')');
    catch diag
        sldiagviewer.reportError(diag);
    end
end

function schema=UpdateDiagramForCodegen(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:UpdateDiagramForCodegen';
    schema.label='Update Diagram for code generation';
    schema.icon='Simulink:UpdateDiagram';
    schema.refreshCategories={'interval#8','SimulinkEvent:Debug'};

    if slfeature('UpdateDiagramForCodegen')>1
        if SLM3I.SLDomain.isUpdateDiagramEnabled(cbinfo.model.handle)
            schema.state='enabled';
        else
            schema.state='disabled';
        end
    else
        schema.state='hidden';
    end

    schema.userData=schema.tag;
    schema.callback=@UpdateDiagramForCodegenCB;
    schema.autoDisableWhen='Never';
end

function schema=ExtModeCtrlPanel(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ExtModeCtrlPanel';
    schema.label=DAStudio.message('Simulink:studio:ExtModeCtrlPanel');
    schema.state=loc_getSimulinkCoderAndRTTItemState(cbinfo);
    schema.callback=@ShowExternalModeControlPanelCB;

    schema.autoDisableWhen='Never';
end

function ShowExternalModeControlPanelCB(cbinfo)
    Simulink.ExtMode.CtrlPanel.createExtModeCtrlPanelForModel(cbinfo.model.Handle);
end

function schema=GenProtectedModel(cbinfo)%#ok<DEFNU>
    schema=GenProtectedModelDisabled(cbinfo);
    block=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if cbinfo.isContextMenu&&...
        ~SLStudio.Utils.objectIsValidModelReferenceBlock(block)
        schema.state='Hidden';
    else
        schema.state='Disabled';
    end
    if cbinfo.domain.isBdInEditMode(cbinfo.model.handle)&&...
        SLStudio.Utils.objectIsValidUnprotectedModelReferenceBlock(block)

        if slfeature('ProtectedModelRemoveSimulinkCoderCheck')>0
            schema.state='Enabled';
        else
            hasHDL=slfeature('ProtectedModelWithGeneratedHDLCode')&&...
            dig.isProductInstalled('HDL Coder');
            hasSC=builtin('license','test','Real-Time_Workshop');

            if hasSC||hasHDL
                schema.state='Enabled';
            else
                schema.state='Hidden';
            end
        end
    end
    schema.callback=@GenerateProtectedModelCB;
end

function schema=GenProtectedModelDisabled(cbinfo)
    schema=DAStudio.ActionSchema;
    schema.tag='Simulink:GenProtectedModel';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='referencedModelProtect';
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:editor:ContextMenuItemLabelStr_GenProtectedModel');
    end
    schema.state='Disabled';
end

function GenerateProtectedModelCB(cbinfo)
    if checkUseSimulinkCoderFeatures(cbinfo)
        block=SLStudio.Utils.getOneMenuTarget(cbinfo);
        blockpath=block.getFullPathName;
        pm=Simulink.ModelReference.ProtectedModel.CreatorDialog(blockpath);
        if~isempty(pm)
            Simulink.ModelReference.ProtectedModel.showDialog(pm);
        end
    end
end


function schema=StateflowCodeMenu(~)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Stateflow:Code';
    schema.label=DAStudio.message('Simulink:studio:SimulinkCoderMenu');
    schema.childrenFcns={@NavigateToCodeSF
    };
    schema.autoDisableWhen='Busy';
end

function state=loc_getNavigateToCodeSFState(cbinfo)
    state='Disabled';
    objectId=[SFStudio.Utils.getSelectedStatesAndTransitionIds(cbinfo),...
    SFStudio.Utils.getSelectedTruthTableIds(cbinfo),...
    SFStudio.Utils.getSelectedEMLIds(cbinfo),...
    SFStudio.Utils.getSelectedJunctionIds(cbinfo)];
    if~isempty(objectId)
        showIt=sfprivate('traceabilityManager','rtwHighlightCodeMenuItemEnabled',objectId(1));

        if showIt
            state='Enabled';
        else
            state='Disabled';
        end
    end
end

function schema=NavigateToCodeSF(cbinfo)
    schema=NavigateToCodeDisabled(cbinfo);
    schema.state=loc_getNavigateToCodeSFState(cbinfo);
    schema.obsoleteTags={'Stateflow:HighlightCodeMenuItem'};
    schema.callback=@NavigateToCodeSFCB;
    schema.autoDisableWhen='Busy';
end

function NavigateToCodeSFCB(cbinfo)
    if checkUseEmbeddedCoderFeatures(cbinfo)

        chartId=SFStudio.Utils.getChartId(cbinfo);
        objectId=[SFStudio.Utils.getSelectedStatesAndTransitionIds(cbinfo),...
        SFStudio.Utils.getSelectedTruthTableIds(cbinfo),...
        SFStudio.Utils.getSelectedEMLIds(cbinfo),...
        SFStudio.Utils.getSelectedJunctionIds(cbinfo)];
        sf('Highlight',chartId,objectId);
        sfprivate('traceabilityManager','rtwTraceObject',objectId);
    end
end


function m2mobj=get_mdladv_m2mobj
    m2mobj=[];
    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if~isempty(mdladvObj)&&...
        (isa(mdladvObj.UserData,'slEnginePir.m2m')||...
        isa(mdladvObj.UserData,'slEnginePir.m2m_lut'))
        m2mobj=mdladvObj.UserData;
    end
end

function schema=M2MXformMenu(cbinfo)%#ok
    schema=sl_container_schema;
    schema.tag='Simulink:M2MXformMenu';
    schema.label=DAStudio.message('Simulink:studio:MdlXformer');
    if loc_checkM2MLicense
        schema.state=loc_getSimulinkCoderMenuState(cbinfo);
    else
        schema.state='Hidden';
    end
    schema.generateFcn=@loc_generateM2MXformMenu;
    schema.autoDisableWhen='Never';
end

function res=loc_checkM2MLicense
    res=license('test','SL_Verification_Validation');
end

function children=loc_generateM2MXformMenu(cbinfo)
    if cbinfo.isContextMenu
        SLStudio.Utils.getOneMenuTarget(cbinfo);
    end
    children=loc_generateM2MTraceMenu(cbinfo);
end

function schemas=loc_generateM2MBlockMenu(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schemas={im.getSubmenu('Simulink:M2MTraceabilityMenu')};
end

function schema=M2MTraceabilityMenu(cbinfo)%#ok
    schema=sl_container_schema;
    schema.tag='Simulink:M2MTraceabilityMenu';
    schema.label='Traceability';
    m2mobj=get_mdladv_m2mobj;
    if~isempty(m2mobj)&&~isempty(m2mobj.traceability_map)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.generateFcn=@loc_generateM2MTraceMenu;
    schema.autoDisableWhen='Never';
end

function schemas=loc_generateM2MTraceMenu(cbinfo)
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    m2mobj=get_mdladv_m2mobj;
    if isempty(m2mobj)
        isTraceable=0;
    else
        isTraceable=m2mobj.isTraceableBlk(cbinfo.target.handle);
    end
    if isTraceable==1
        schemas={im.getAction('Simulink:HighlightXformBlock')};
    elseif isTraceable==2
        schemas={im.getAction('Simulink:HighlightOriBlock')};
    else
        schemas={im.getAction('Simulink:HighlightNoBlock')};
    end
end

function schema=NavigateToNoBlock(cbinfo)%#ok
    schema=sl_action_schema;
    schema.tag='Simulink:HighlightNoBlock';
    schema.label=DAStudio.message('Simulink:studio:NotFoundInMap');
    schema.state='Disabled';
end

function schema=NavigateToOriBlock(cbinfo)%#ok
    schema=sl_action_schema;
    schema.tag='Simulink:HighlightOriBlock';
    schema.label=DAStudio.message('Simulink:studio:ToOriginalBlk');
    schema.state='Enabled';
    schema.callback=@NavigateToBlockCB;
    schema.autoDisableWhen='Never';
end

function schema=NavigateToXformBlock(cbinfo)%#ok
    schema=sl_action_schema;
    schema.tag='Simulink:HighlightXformBlock';
    schema.label=DAStudio.message('Simulink:studio:ToXformedBlk');
    schema.state='Enabled';
    schema.callback=@NavigateToBlockCB;
    schema.autoDisableWhen='Never';
end

function NavigateToBlockCB(cbinfo)
    if checkUseEmbeddedCoderFeatures(cbinfo)
        m2mobj=get_mdladv_m2mobj;
        if~isempty(m2mobj)
            m2mobj.trace(cbinfo.target.handle);
        end
    end
end








