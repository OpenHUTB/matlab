function utilHDLAdvisorStart(varargin)










    try
        dut=varargin{1};
        hdlcoderargs(dut);
        hdlwa.hdlwaDriver.modelName(bdroot(dut));

        updateDutName(dut);
    catch me
        rethrow(me);
    end
    autoRestore=false;
    if nargin==1&&isa(varargin{1},'DAStudio.CallbackInfo')
        switch varargin{1}.userdata
        case 'ToolbarMenuEntry'
            scope_o=varargin{1}.uiObject;
        case 'ContextMenuEntry'
            scope_o=get_param(gcb,'object');
        otherwise
            DAStudio.error('HDLShared:hdldialog:HDLWAMSGNotSupportedCaseA',...
            varargin{1}.userdata);
        end
    elseif nargin>=2&&strcmpi(varargin{2},'CommandLineEntry')
        scope_o=get_param(varargin{1},'object');
        if nargin==3&&strcmpi(varargin{3},'AutoRestore')
            autoRestore=true;
        end
    else
        DAStudio.error('HDLShared:hdldialog:HDLWAMSGNotSupportedCase');
    end



    downstream.integration('Model',dut);



    mdlAdv=hdlwa.getHdladvObj(dut,scope_o);

    if~isempty(mdlAdv)&&isempty(mdlAdv.TaskAdvisorRoot)

        workDir=mdlAdv.getWorkDir;
        warning(message('hdlcoder:workflow:removingWorkDir',workDir));

        [~,~,~]=rmdir(workDir,'s');
        mdlAdv=Simulink.ModelAdvisor.getModelAdvisor(scope_o.getFullName,'new','com.mathworks.HDL.WorkflowAdvisor');
    end


    mdlAdv.ShowProgressbar=false;


    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    hdlwaDriver.createTaskObjMap(mdlAdv);


    hdlwa.getWorkflowTaskList('ClearCurrentKey',true);


    isReloaded=utilHandle_HDLAdvisorData('load',scope_o.getFullName,autoRestore);
    if~isReloaded



        utilHandle_HDLAdvisorModelParamLoad(scope_o.getFullName);
    end


    mdlAdv.displayExplorer;
    HDLAName=DAStudio.message('HDLShared:hdldialog:HDLAdvisor');
    MAName=DAStudio.message('Simulink:ModelAdvisor:ModelAdvisorDummyMessage');
    mdlAdv.MAExplorer.title=regexprep(mdlAdv.MAExplorer.title,['^',MAName],HDLAName);

    model=bdroot(scope_o.getFullName);
    hdriver=hdlmodeldriver(model);
    hDI=hdriver.DownstreamIntegrationDriver;

    if hDI.geterrorModelSetting
        slmsgviewer.Instance().show();
        slmsgviewer.selectTab(model);
        hM=message('hdlcommon:workflow:ApplySettingErrorFromModel');
        warndlg(hM.getString,'Warning','modal');
    end



    cs=getActiveConfigSet(model);
    cs.refreshDialog;


    function output=isLibrary(system)
        system=bdroot(system);
        fp=get_param(system,'ObjectParameters');
        if isfield(fp,'BlockDiagramType')
            if strcmpi(get_param(system,'BlockDiagramType'),'library')
                output=1;
            else
                output=0;
            end
        else

            output=1;
        end


        function updateDutName(dut)
            mdlName=bdroot(dut);
            cleanDutName=hdlfixblockname(dut);
            snn=hdlget_param(mdlName,'HDLSubsystem');


            if(~isempty(snn)&&~strcmpi(snn,dut))...
                ||~strcmpi(dut,cleanDutName)
                hdlset_param(mdlName,'HDLSubsystem',dut);
                hdlcc=gethdlcc(mdlName);
                if~isempty(hdlcc)

                    hdlcc.refreshDlg;
                end
            end


