function plctoolstrip(fncname,cbinfo,action)




    PLCCoder.PLCCGMgr.getInstance.setReportGUIMsg(true);

    fnc=str2func(fncname);
    if(nargin==3)
        fnc(cbinfo,action);
    else
        fnc(cbinfo,[]);
    end

    PLCCoder.PLCCGMgr.getInstance.setReportGUIMsg(false);
end

function obj=plc_callbackinfo_get_selection(cbinfo)
    [~,path,~]=getSystemSelectorInfo(cbinfo);
    if getSimulinkBlockHandle(path)==-1
        obj=[];
    else
        obj=get_param(path,'Object');

        if~isa(obj,'Simulink.SubSystem')
            obj=[];
        end
    end
end

function obj=tracability_callbackinfo_get_selection(cbinfo)
    obj=callbackinfo_get_selection(cbinfo);
    if isempty(obj)
        return;
    end
    if length(obj)>1
        obj=[];
        return;
    end

    if isa(obj,'Simulink.Segment')
        obj=[];
    end
end

function IncludeImport_Refresh(cbinfo,action)
    action.enabled=target_import_enabled(cbinfo);
    if action.enabled
        action.selected=get_toggle_state(cbinfo,'import_ide');
    end
end

function IncludeImport_CB(cbinfo,action)%#ok<INUSD>
    if get_toggle_state(cbinfo,'verify_ide')
        set_toggle_state(cbinfo,'import_ide',true);
    else
        set_toggle_state(cbinfo,'import_ide',cbinfo.EventData);
    end
end

function IncludeVerify_Refresh(cbinfo,action)
    action.enabled=target_import_enabled(cbinfo);
    if action.enabled
        action.selected=get_toggle_state(cbinfo,'verify_ide');
    end
end

function IncludeVerify_CB(cbinfo,action)%#ok<INUSD>    % 
    set_toggle_state(cbinfo,'verify_ide',cbinfo.EventData);
    if get_toggle_state(cbinfo,'verify_ide')
        set_toggle_state(cbinfo,'import_ide',true);
    end
end

function GenerateLadder_Refresh(cbinfo,action)
    action.enabled=target_ladder_enabled(cbinfo)&&sf_ladder_gen_enabled(cbinfo);
    if action.enabled
        action.selected=get_toggle_state(cbinfo,'gen_ladder');
    end
end


function OpenReport_Refresh(cbinfo,action)
    action.enabled=open_report_enabled(cbinfo);
    action.dropDownAlwaysEnabled=true;
end

function OpenReport_CB(cbinfo,action)%#ok<INUSD>
    open_report_callback(cbinfo);
end

function ConfigOption_CB(cbinfo,action)%#ok<INUSD>
    options_callback(cbinfo);
end

function GenerateCode_Refresh(cbinfo,action)
    action.enabled=check_allowed_atomic_subsys(cbinfo);
end

function GenerateCode_CB(cbinfo,action)%#ok<INUSD>
    generate_code_callback(cbinfo);
end

function NavigateCode_Refresh(cbinfo,action)
    action.enabled=highlight_code_enabled(cbinfo);
end

function NavigateCode_CB(cbinfo,action)%#ok<INUSD>
    highlight_code_callback(cbinfo);
end

function ReportOption_CB(cbinfo,action)%#ok<INUSD>
    report_options_callback(cbinfo);
end

function ModelAdvisor_Refresh(cbinfo,action)
    action.enabled=check_empty_subsys(cbinfo);
end

function out=check_empty_subsys(callbackInfo)
    blockObj=plc_callbackinfo_get_selection(callbackInfo);
    if(isempty(blockObj))
        out=false;
    else
        out=true;
    end
end

function ModelAdvisor_CB(cbinfo,action)%#ok<INUSD>
    model_advisor_callback(cbinfo);
end

function out=target_import_enabled(callbackInfo)
    if~ispc
        out=false;
        return
    end

    modelH=callbackInfo.model.Handle;
    modelName=get_param(modelH,'Name');
    plc_configcomp_attach(modelName);
    target_ide=get_param(modelName,'PLC_TargetIDE');
    if(PLCCoder.PLCCGMgr.isCustomTarget(target_ide))
        out=PLCCoder.PLCCGMgr.getFeatureTestCGConfig;
    else
        out=plc_targetide_strings('code2importsupported',target_ide);
    end
end

function out=highlight_code_enabled(callbackInfo)
    out=false;
    blockObj=tracability_callbackinfo_get_selection(callbackInfo);

    if isempty(blockObj)
        return;
    end

    if(~is_sf_obj(blockObj))
        model=bdroot(blockObj.Handle);
    else
        model=bdroot(sfprivate('chart2block',callbackInfo.uiObject.id));
    end

    if mdl_has_trace_info(model)
        out=true;
    end
end

function out=check_allowed_atomic_subsys(callbackInfo)
    out=false;
    blockObj=plc_callbackinfo_get_selection(callbackInfo);
    if(isempty(blockObj))
        return;
    end


    ports=blockObj.Ports;
    if~strcmpi(blockObj.TreatAsAtomicUnit,'on')||ports(3)~=0||ports(4)~=0
        return;
    else
        out=true;
    end
end

function generate_code_callback(cbinfo)

    if get_toggle_state(cbinfo,'verify_ide')&&target_import_enabled(cbinfo)
        generate_and_import_and_execute_code_callback(cbinfo);
        return;
    end

    if get_toggle_state(cbinfo,'import_ide')&&target_import_enabled(cbinfo)
        generate_and_import_code_callback(cbinfo);
        return;
    end

    blockObj=plc_callbackinfo_get_selection(cbinfo);
    assert(~isempty(blockObj));
    plc_builder('generate_plc_code',blockObj.Handle);
end

function model_advisor_callback(cbinfo)

    blockObj=plc_callbackinfo_get_selection(cbinfo);
    assert(~isempty(blockObj));
    plcmodeladvisor(blockObj.Handle);
end

function generate_and_import_code_callback(callbackInfo)
    blockObj=plc_callbackinfo_get_selection(callbackInfo);
    assert(~isempty(blockObj));
    plc_builder('generate_and_import_code',blockObj.Handle);
end

function generate_and_import_and_execute_code_callback(callbackInfo)
    blockObj=plc_callbackinfo_get_selection(callbackInfo);
    assert(~isempty(blockObj));
    blockHandle=blockObj.Handle;
    set_param(bdroot(blockHandle),'PLC_GenerateTestbench','on');
    plc_builder('generate_and_execute',blockHandle);
end

function options_callback(callbackInfo)
    modelH=callbackInfo.model.Handle;
    if(check_allowed_atomic_subsys(callbackInfo))
        blockObj=plc_callbackinfo_get_selection(callbackInfo);
        plc_configcomp_open(modelH,blockObj.Handle);
    else
        plc_configcomp_open(modelH);
    end
end

function report_options_callback(callbackInfo)
    modelH=callbackInfo.model.Handle;
    [plcCoderCC,configSet]=plc_configcomp_get(modelH);
    if isempty(plcCoderCC)
        dirty=get_param(modelH,'Dirty');
        plc_configcomp_attach(modelH);
        set_param(modelH,'Dirty',dirty);
        [~,configSet]=plc_configcomp_get(modelH);
    end
    slCfgPrmDlg(configSet,'Open','PLC Code Generation/Report');
end

function highlight_code_callback(callbackInfo)
    blockObj=tracability_callbackinfo_get_selection(callbackInfo);
    if(isempty(blockObj))
        return;
    end

    if(~is_sf_obj(blockObj))
        rtwtrace(blockObj.Handle,'plc');
        return;
    end


    chartId=SFStudio.Utils.getChartId(callbackInfo);
    obj=SLStudio.Utils.getOneMenuTarget(callbackInfo);
    if~isempty(obj)&&isvalid(obj)
        objectId=double(obj.backendId);
        sf('Highlight',chartId,objectId);
        sfprivate('traceabilityManager','plcTraceObject',objectId);
    end
end

function out=open_report_enabled(callbackInfo)
    modelH=callbackInfo.model.Handle;
    modelName=get_param(modelH,'Name');
    out=mdl_has_trace_info(modelName);
end

function open_report_callback(callbackInfo)
    modelH=callbackInfo.model.Handle;
    modelName=get_param(modelH,'Name');
    plc_configcomp_attach(modelName);
    try
        reportInfo=PLCCoder.report.ReportInfo(modelName);
        tmpCodeGenDir=get_output_dir(modelH);
        if is_full_path(tmpCodeGenDir)
            reportInfo.setBuildDir(tmpCodeGenDir);
        else
            reportInfo.setBuildDir(fullfile(pwd,tmpCodeGenDir));
        end
        reportInfo.HtmlDir=fullfile(reportInfo.getBuildDir,'html',modelName);
        reportInfo.show;
    catch ME
        Simulink.output.Stage('PLC Coder Open Report','ModelName',modelName,'UIMode',true);
        plc_manage_errors('handleMExceptions',modelH,ME);
        sldvshareprivate('plccgirunsupdialog',modelH,false,[]);
    end
end

function out=is_full_path(d)
    out=false;
    if ispc
        if length(d)>=3
            out=(isletter(d(1))&&d(2)==':'&&d(3)=='\');
        end
    else
        if~isempty(d)
            out=d(1)=='/';
        end
    end
end

function output_dir=get_output_dir(modelH)
    output_dir=get_param(modelH,'PLC_OutputDir');
    output_dir=strtrim(output_dir);
    output_dir=strrep(output_dir,'/',filesep);
    output_dir=strrep(output_dir,'\',filesep);
    if isempty(output_dir)
        filegen=Simulink.fileGenControl('GetConfig');
        output_dir=fullfile(filegen.CodeGenFolder,'plcsrc');
    end
end

function ret=is_sf_obj(obj)
    ret=false;
    if(startsWith(class(obj),'Stateflow.'))
        ret=true;
    end
end

function ret=get_toggle_state(cbinfo,name)
    ret=false;
    st=cbinfo.studio;
    context=st.App.getAppContextManager.getCustomContext('plcCoderApp');
    if isempty(context)
        return;
    end
    switch name
    case 'import_ide'
        ret=context.fIncludeImport;
    case 'verify_ide'
        ret=context.fIncludeVerify;
    end
end

function set_toggle_state(cbinfo,name,state)
    if isempty(state)
        return;
    end
    st=cbinfo.studio;
    context=st.App.getAppContextManager.getCustomContext('plcCoderApp');
    if isempty(context)
        return;
    end
    switch name
    case 'import_ide'
        context.fIncludeImport=state;
    case 'verify_ide'
        context.fIncludeVerify=state;
    end
end

function ret=mdl_has_trace_info(model)
    ret=false;
    traceInfo=PLCCoder.TraceInfo.instance(model);
    if~isempty(traceInfo)&&isa(traceInfo,'PLCCoder.TraceInfo')
        ret=true;
    end
end

function[name,path,isPinned]=getSystemSelectorInfo(cbinfo)
    selection=cbinfo.getSelection();
    pinnedSystem=cbinfo.studio.App.getPinnedSystem('plcSystemSelectorAction');

    if isempty(pinnedSystem)
        isPinned=false;

        if size(selection)==1
            if~isprop(selection,'Name')||isempty(selection.Name)
                obj=cbinfo.uiObject;
            else
                obj=selection;
            end
        else
            obj=cbinfo.uiObject;
        end
    else
        isPinned=true;
        obj=pinnedSystem;
    end

    name=obj.name;
    path=obj.getFullName;
end

