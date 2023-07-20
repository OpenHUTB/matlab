




function hdlvToolStrip(fcnname,varargin)

    fnc=str2func(fcnname);
    fnc(varargin{:});
end

function toggleHDLVAppCB(userdata,cbinfo)


    contextManager=cbinfo.studio.App.getAppContextManager;
    customContext=contextManager.getCustomContext(userdata);
    isAppPreviouslyOpen=~isempty(customContext);
    if~isAppPreviouslyOpen

        workflowDlgObj=hdlverifier.internal.sltoolstrip.hdlvWorkflowSelectDlg(cbinfo);

        c=dig.Configuration.get();
        app=c.getApp(userdata);
        contextProvider=app.contextProvider;
        customContext=feval(contextProvider,app,cbinfo,workflowDlgObj);














        contextManager.activateApp(customContext);
        hdlverifier.internal.sltoolstrip.showEmbeddedDlg(workflowDlgObj,'Left','Tabbed');
        customContext.setupListeners();

    elseif isempty(cbinfo.EventData)||cbinfo.EventData

        ts=cbinfo.studio.getToolStrip;
        ts.ActiveTab=customContext.DefaultTabName;
    else

        customContext.systemTLCFileListener=[];
        customContext.selectedWorkflowContextListener=[];
        contextManager.deactivateApp(userdata);
        destroyHDLVWorkflowDDGComponent(cbinfo);

    end
end

function destroyHDLVWorkflowDDGComponent(cbinfo)

    [pi,~]=searchForLoadedHDLVWorkflowDDGComponent(cbinfo);
    if~isempty(pi)
        cbinfo.studio.destroyComponent(pi);
    end
end

function[pi,st]=searchForLoadedHDLVWorkflowDDGComponent(cbinfo)

    st=cbinfo.studio;

    pi=st.getComponent('GLUE2:DDG Component',message('EDALink:SLToolstrip:General:HDLVWorkflowDlgTitle').getString);
end

function toggleHDLVWorkflowSidePanelCB(cbinfo)


    [pi,st]=searchForLoadedHDLVWorkflowDDGComponent(cbinfo);

    if isempty(pi)

        hdlverifier.internal.sltoolstrip.showEmbeddedDlg(hdlverifier.internal.sltoolstrip.hdlvWorkflowSelectDlg(cbinfo),'Left','Tabbed');
        return;
    end







    if~pi.isVisible
        st.showComponent(pi);
    end

end




function[path,name,selectedSystem,isPinned]=getSelectedSystem(cbinfo,action)

    pinnedSystem=cbinfo.studio.App.getPinnedSystem(action);
    isPinned=~isempty(pinnedSystem);
    if isPinned
        selectedSystem=pinnedSystem;
    else
        selection=cbinfo.getSelection;

        if size(selection)==1

            if(~isprop(selection,'name')||isempty(selection.name))...
                &&(~isprop(selection,'Name')||isempty(selection.Name))

                selectedSystem=cbinfo.uiObject;
            else
                selectedSystem=selection;
            end
        else

            selectedSystem=cbinfo.uiObject;
        end
    end
    name=selectedSystem.name;
    path=selectedSystem.getFullName;
end

function buildSelectedSystem(cbinfo,actionName)



    [~,~,selectedSystem,~]=getSelectedSystem(cbinfo,actionName);
    bringSLDiagnosticViewerToForeground(cbinfo);
    if isa(selectedSystem,'Simulink.SubSystem')
        subsystemBlock=SLM3I.SLDomain.handle2DiagramElement(selectedSystem.Handle);
        if SLStudio.Utils.objectIsValidSubsystemBlock(subsystemBlock)
            cbinfo.domain.buildSelectedSubsystem(subsystemBlock);
        end
    else

        cbinfo.domain.buildModel(selectedSystem.Handle);
    end
end

function bringSLDiagnosticViewerToForeground(cbinfo)


    aSLMsgViewer=slmsgviewer.Instance(cbinfo.model.Name);
    if~isempty(aSLMsgViewer)
        aSLMsgViewer.show();
        slmsgviewer.selectTab(cbinfo.model.Name);
    end
end

function stage=createSLDiagnosticViewerStage(cbinfo,stageName)



    stage=sldiagviewer.createStage(message(stageName).getString,'ModelName',cbinfo.model.Name);
end

function throwToDiagnosticViewer(msg,type)

    switch type
    case 'error'
        sldiagviewer.reportError(msg);
    case 'warning'
        sldiagviewer.reportWarning(msg);
    case 'info'
        sldiagviewer.reportInfo(msg);
    otherwise


        error('Unable to identify display severity for diagnostic viewer.');
    end
end



function addDPISimulatorToPathCB(cbinfo)

    dialogSrc=hdlverifier.internal.sltoolstrip.vendorToolPathDlg.dlgActionMap(cbinfo.model.Name,'open');
    if~isempty(dialogSrc)
        dlgBox=DAStudio.Dialog(dialogSrc);
        dlgBox.show;
        dlgBox.setFocus('vendorToolDlg_editTextField');
    end
end

function runDPISimulatorTBCB(userdata,cbinfo)












    if strcmp(userdata,'runDPITTBAction')
        stage=createSLDiagnosticViewerStage(cbinfo,'EDALink:SLToolstrip:DPIC:dpiTestbenchSimDiagnosticViewerHeading');
    end



    [tbPath,is_exist]=findDPITbDir(cbinfo);




    if~is_exist
        throwToDiagnosticViewer(message('EDALink:SLToolstrip:DPIC:dpiCannotFindTBDir',tbPath).getString,'error');
        return;
    end

    hdlSimulator=get_param(cbinfo.model.Name,'DPITestBenchSimulator');



    if ispc&&(contains(hdlSimulator,'Cadence')||contains(hdlSimulator,'Synopsys'))
        throwToDiagnosticViewer(message('EDALink:SLToolstrip:General:simulatorNotSupportedOnPlatform',hdlSimulator).getString,'error');
        return;
    end


    switch hdlSimulator
    case 'Mentor Graphics Questasim'
        checkHdlToolVerCmd='vsim -version';
    case 'Cadence Xcelium'
        checkHdlToolVerCmd='xrun -version';
    case 'Synopsys VCS'
        checkHdlToolVerCmd='vcs -ID';
    case 'Vivado Simulator'
        checkHdlToolVerCmd='vivado -version';
    otherwise

    end
    [stat,result]=system(checkHdlToolVerCmd);
    if stat
        throwToDiagnosticViewer(message('EDALink:SLToolstrip:General:simulatorNotFound',strtrim(result),hdlSimulator,seeRequirementPage).getString,'error');
        return;
    end


    currentDir=pwd;
    cd(tbPath);
    c=onCleanup(@()cd(currentDir));



    if strcmp(userdata,'runDPITBGuiAction')
        runInGUIMode=true;
    else
        runInGUIMode=false;

        bringSLDiagnosticViewerToForeground(cbinfo);
    end


    origSimulatorModeEnv=getenv('LAUNCH_SIMULATOR_GUI_MODE');
    if runInGUIMode
        setenv('LAUNCH_SIMULATOR_GUI_MODE','1');
    else
        setenv('LAUNCH_SIMULATOR_GUI_MODE');
    end
    c2=onCleanup(@()setenv('LAUNCH_SIMULATOR_GUI_MODE',origSimulatorModeEnv));


    switch hdlSimulator
    case 'Mentor Graphics Questasim'
        if runInGUIMode
            if ispc




                [stat,res]=system('questasim -do run_tb_mq.do');
            else

                [stat,res]=system('vsim -64 -gui -do run_tb_mq.do &');
            end
        else


            [stat,res]=system('vsim -c -do run_tb_mq.do','-echo');
        end
    case 'Cadence Xcelium'
        if runInGUIMode
            [stat,res]=system('./run_tb_xcelium.sh &');
        else
            [stat,res]=system('./run_tb_xcelium.sh','-echo');
        end
    case 'Synopsys VCS'
        if runInGUIMode
            [stat,res]=system('./run_tb_vcs.sh &');
        else
            [stat,res]=system('./run_tb_vcs.sh','-echo');
        end
    case 'Vivado Simulator'
        if runInGUIMode
            if ispc


                [stat,res]=system('run_tb_vivado.bat &');
            else
                [stat,res]=system('./run_tb_vivado.sh &');
            end
        else
            if ispc
                [stat,res]=system('run_tb_vivado.bat','-echo');
            else
                [stat,res]=system('./run_tb_vivado.sh','-echo');
            end
        end
    otherwise

        throwToDiagnosticViewer(message('EDALink:SLToolstrip:DPIC:dpiUnsupportedHDLSimulator').getString,'error');
    end

    if stat
        throwToDiagnosticViewer(res,'error');
    else
        if~runInGUIMode
            throwToDiagnosticViewer(res,'info');
        end
    end
end

function changeDPISimulatorCB(cbinfo)

    model=cbinfo.model.Handle;
    cs=getActiveConfigSet(model);

    configset.highlightParameter(cs,'DPITestBenchSimulator');
end

function setHDLSimulatorTBDescriptionRF(cbinfo,action)

    action.description=message('EDALink:SLToolstrip:DPIC:dpiRunTBActionDescription',get_param(cbinfo.model.Name,'DPITestBenchSimulator'));


    tbCheckbox=strcmp(get_param(cbinfo.model.Handle,'DPIGenerateTestBench'),'on');
    [~,is_exist]=findDPIBuildDir(cbinfo);
    action.enabled=is_exist&&tbCheckbox;
end

function setDPISimulatorDescriptionRF(cbinfo,action)

    action.description=message('EDALink:SLToolstrip:DPIC:dpiChangeSimulatorActionDescription',get_param(cbinfo.model.Name,'DPITestBenchSimulator'));



    tbCheckbox=strcmp(get_param(cbinfo.model.Handle,'DPIGenerateTestBench'),'on');
    [~,is_exist]=findDPIBuildDir(cbinfo);
    action.enabled=is_exist&&tbCheckbox;
end

function setHDLSimulatorTBGuiDescriptionRF(cbinfo,action)

    action.description=message('EDALink:SLToolstrip:DPIC:dpiRunTBGuiActionDescription',get_param(cbinfo.model.Name,'DPITestBenchSimulator'));
end

function newStr=l_changingToForwardSlashes(oldStr)

    oldStr(strfind(oldStr,'\'))='/';
    newStr=oldStr;
end

function reqmsg=seeRequirementPage
    link='helpview(fullfile(docroot, ''toolbox'', ''hdlverifier'', ''helptargets.map''), ''ThirdPartyReqs'');';
    reqmsg=['see <a href="matlab:',link,'">supported EDA tools</a>'];
end



function chooseDPITBGenCB(cbinfo)

    if cbinfo.EventData

        set_param(cbinfo.model.name,'DPIGenerateTestBench','on');


    else
        set_param(cbinfo.model.name,'DPIGenerateTestBench','off');
    end
end

function chooseDPITBGenRF(cbinfo,action)

    if strcmp(get_param(cbinfo.model.name,'DPIGenerateTestBench'),'off')
        action.setPropertyValue('selected',false);
    else
        action.setPropertyValue('selected',true);
    end
end


function generateDPIComponentCB(cbinfo)

    buildSelectedSystem(cbinfo,'selectDPIDUTAction');
end


function buildConvertRF_DPI(userdata,cbinfo,action)



    if numel(cbinfo.getSelection)>1

        action.enabled=false;
    else

        SLStudio.toolstrip.internal.buildConvertRF(userdata,cbinfo,action);
    end
end

function launchCCodeConfigParamCB(cbinfo)

    model=cbinfo.model.Handle;
    cs=getActiveConfigSet(model);
    configset.showParameterGroup(cs,{'CodeGeneration'});
end

function launchDPIConfigParamCB(cbinfo)

    model=cbinfo.model.Handle;
    cs=getActiveConfigSet(model);
    configset.showParameterGroup(cs,{'SystemVerilog DPI'});
end

function launchDPIBuildLogCB(cbinfo)

    bringSLDiagnosticViewerToForeground(cbinfo);
end

function launchDPIBuildLogRF(cbinfo,action)



    [~,is_exist]=findDPIBuildDir(cbinfo);
    action.enabled=is_exist;



end

function launchDPIFileExplorerCB(cbinfo)

    [path,~]=findDPIBuildDir(cbinfo);
    if ispc
        winopen(path);
    else


        web(path);
    end
end

function launchDPIFileExplorerRF(cbinfo,action)



    [~,is_exist]=findDPIBuildDir(cbinfo);
    action.enabled=is_exist;
end

function[path,is_exist]=findDPIBuildDir(cbinfo)



    [~,dut,~,~]=getSelectedSystem(cbinfo,'selectDPIDUTAction');


    dutCodeGen=uvmcodegen.getSLC_MdlName(dut);
    cfg=Simulink.fileGenControl('getConfig');
    path=fullfile(cfg.CodeGenFolder,[dutCodeGen,'_build']);
    is_exist=exist(path,'dir');
end

function[tbPath,is_exist]=findDPITbDir(cbinfo)

    [path,~]=findDPIBuildDir(cbinfo);


    tbPath=[path,filesep,'dpi_tb'];
    is_exist=exist(tbPath,'dir');
end



function launchCosimWizardCB(cbinfo)

    selectedSystem=cbinfo.uiObject;
    cosimWizard('','Simulink',selectedSystem.getFullName);
end


function setCosimSimModeCB(cbinfo)

    switch cbinfo.eventData
    case 'a'
        set_param(cbinfo.model.name,'simulationmode','normal');
    case 'b'
        set_param(cbinfo.model.name,'simulationmode','accelerator');
    otherwise


        set_param(cbinfo.model.name,'simulationmode','accelerator');
    end

end






































function insertVCDCB(userData,cbinfo)

    selectedSystem=cbinfo.uiObject;
    private_sl_add_block(userData,selectedSystem.getFullName,0);









end





