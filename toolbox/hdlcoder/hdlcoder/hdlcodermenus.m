function schema=hdlcodermenus(fncname,cbinfo)


    fnc=str2func(fncname);
    if strcmp(fncname(end-1:end),'CB')


        fnc(cbinfo);
    else
        schema=fnc(cbinfo);
    end
end


function res=loc_TestLicense
    res=license('test','Simulink_HDL_Coder');
end


function hdlcc=loc_getHDLCC(cbinfo)
    configSet=getActiveConfigSet(cbinfo.model);
    hdlcc=gethdlcconfigset(configSet);
end

function state=loc_getHDLMenuState(~)
    if loc_TestLicense
        state='Enabled';
    else
        state='Hidden';
    end
end

function schema=HDLMenuDisabled(cbinfo)
    schema=sl_container_schema;
    schema.label=DAStudio.message('HDLShared:hdldialog:hdlccHDLCodermenuname');
    schema.tag='Simulink:HDLMenu';

    schema.state=loc_getHDLMenuState(cbinfo);
    if strcmpi(schema.state,'Enabled')


        schema.state='Disabled';
    end

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:HiddenSchema')};
end

function schema=HDLMenu(cbinfo)%#ok<DEFNU>
    schema=HDLMenuDisabled(cbinfo);
    schema.state=loc_getHDLMenuState(cbinfo);

    hdlcc=loc_getHDLCC(cbinfo);
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    if~isempty(hdlcc)

        schema.childrenFcns={im.getAction('Simulink:HDLC_HDLAdvisor'),...
        im.getAction('Simulink:HDLC_Options'),...
        im.getAction('Simulink:HDLC_GenerateHDL'),...
        im.getAction('Simulink:HDLC_GenerateTB'),...
        'separator',...
        im.getAction('Simulink:HDLC_RemoveHDLCoder')
        };
    else

        schema.childrenFcns={im.getAction('Simulink:HDLC_AddHDLCoder')};
    end
end

function schema=HDLC_HDLAdvisorDisabled(~)
    schema=sl_action_schema;
    schema.label=DAStudio.message('HDLShared:hdldialog:menuitemHDLAdvisor');
    schema.tag='Simulink:HDLC_HDLAdvisor';
    schema.state='Disabled';
end

function schema=HDLC_HDLAdvisor(cbinfo)%#ok<DEFNU>
    schema=HDLC_HDLAdvisorDisabled(cbinfo);
    schema.state=loc_getHDLMenuState(cbinfo);
    schema.callback=@HDLC_HDLAdvisorCB;
end

function HDLC_HDLAdvisorCB(cbinfo)
    modelName=cbinfo.model.Name;

    if~isempty(modelName)
        if cbinfo.isContextMenu
            HDLC_HDLAdvisorCB_IMPL(modelName);
        else
            HDLC_HDLAdvisorCB_IMPL(modelName,'SystemSelector');
        end
    end
end

function HDLC_HDLAdvisorCB_IMPL(varargin)
    try
        if nargin==1
            hdladvisor(varargin{1});
        elseif nargin==2
            hdladvisor(varargin{1},varargin{2});
        end
    catch e



        hdl_coder_auto_build_stage=Simulink.output.Stage('HDLCoder','ModelName',gcs(),'UIMode',true);%#ok<NASGU>
        Simulink.output.error(e,'Component','HDLCoder','Category','HDL');
    end
end

function schema=HDLC_OptionsDisabled(~)
    schema=sl_action_schema;
    schema.label=DAStudio.message('HDLShared:hdldialog:menuitemOptions');
    schema.tag='Simulink:HDLC_Options';
    schema.state='Disabled';
end

function schema=HDLC_Options(cbinfo)%#ok<DEFNU>
    schema=HDLC_OptionsDisabled(cbinfo);
    schema.state=loc_getHDLMenuState(cbinfo);
    schema.callback=@HDLC_OptionsCB;

    hdlcc=loc_getHDLCC(cbinfo);
    if isempty(hdlcc)
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
end

function HDLC_OptionsCB(~)
    configset.showParameterGroup(bdroot,{DAStudio.message('HDLShared:hdldialog:hdlccHDLCodername')});
end

function schema=HDLC_GenerateHDLDisabled(~)
    schema=sl_action_schema;
    schema.label=DAStudio.message('HDLShared:hdldialog:menuitemGenerateHDL');
    schema.tag='Simulink:HDLC_GenerateHDL';
    schema.state='Disabled';
end

function schema=HDLC_GenerateHDL(cbinfo)%#ok<DEFNU> % ( cbinfo )
    schema=HDLC_GenerateHDLDisabled(cbinfo);
    schema.state=loc_getHDLMenuState(cbinfo);
    schema.callback=@HDLC_GenerateHDLCB;
end

function schema=HDLC_CheckHDL(cbinfo)%#ok<DEFNU> % ( cbinfo )
    schema=HDLC_GenerateHDLDisabled(cbinfo);
    schema.state=loc_getHDLMenuState(cbinfo);
    schema.callback=@HDLC_CheckHDLCB;
end

function HDLC_OpenHDLCoderOptionsCB(cbinfo)%#ok<DEFNU>
    hdlcc=loc_getHDLCC(cbinfo);
    if~isempty(hdlcc)
        mdlName=hdlcc.getModelName;
        hcc=hdlcc.getHDLCoder;
        if~isempty(hcc)
            hcc.createCLI;
            configset.showParameterGroup(mdlName,{DAStudio.message('HDLShared:hdldialog:hdlccHDLCodername')});
        end
    end
end

function HDLC_hdlsllibCB(~)%#ok<DEFNU>
    hdlsllib;
end

function HDLC_ModelCheckerCB(cbinfo)%#ok<DEFNU>
    hdlcc=loc_getHDLCC(cbinfo);
    if~isempty(hdlcc)
        mdlName=hdlcc.getModelName;
        hdlmodelchecker(mdlName);
    end
end


function HDLC_GenerateHDLCB(cbinfo)
    hdlcc=loc_getHDLCC(cbinfo);

    Simulink.output.Stage('HDLCoder','ModelName',gcs(),'UIMode',true);%#ok<NASGU>
    if~isempty(hdlcc)
        try
            mdlName=hdlcc.getModelName;
            hc=hdlcc.getHDLCoder;
            if~strcmp(mdlName,hc.ModelName)
                hc.ModelName=mdlName;
            end
            hc.makehdl;
        catch e
            hdl_coder_auto_build_stage=Simulink.output.Stage('HDLCoder','ModelName',gcs(),'UIMode',true);%#ok<NASGU>
            Simulink.output.error(e,'Component','HDLCoder','Category','HDL');
        end
    end

end

function HDLC_CheckHDLCB(cbinfo)
    hdlcc=loc_getHDLCC(cbinfo);
    if~isempty(hdlcc)
        try
            mdlName=hdlcc.getModelName;
            hc=hdlcc.getHDLCoder;
            if~strcmp(mdlName,hc.ModelName)
                hc.ModelName=mdlName;
            end
            hc.checkhdl;
        catch e
            hdl_coder_auto_build_stage=Simulink.output.Stage('HDLCoder','ModelName',gcs(),'UIMode',true);%#ok<NASGU>
            Simulink.output.error(e,'Component','HDLCoder','Category','HDL');
        end
    end
end


function schema=HDLC_GenerateTBDisabled(~)
    schema=sl_action_schema;
    schema.label=DAStudio.message('HDLShared:hdldialog:menuitemGenerateTB');
    schema.tag='Simulink:HDLC_GenerateTB';
    schema.state='Disabled';
end

function schema=HDLC_GenerateTB(cbinfo)%#ok<DEFNU>
    schema=HDLC_GenerateTBDisabled(cbinfo);
    schema.state=loc_getHDLMenuState(cbinfo);
    schema.callback=@HDLC_GenerateTBCB;

    hdlcc=loc_getHDLCC(cbinfo);
    if isempty(hdlcc)
        schema.state='Disabled';
        return;
    end

    src=hdlcc.getCLI;
    snn=src.HDLSubsystem;
    if isempty(snn)||strcmpi(snn,bdroot)
        schema.state='Disabled';
        return;
    end

    tbgeneration=strcmpi(src.GenerateHDLTestBench,'on');
    if~tbgeneration&&hdlcoderui.isedasimlinksinstalled
        tbgeneration=strcmpi(src.GenerateCoSimBlock,'on')||~strcmpi(src.GenerateCosimModel,'None');
    end
    hSrc=hdlcc.getSourceObject;
    if tbgeneration&&~isempty(hdlcc.getModel)&&~hSrc.isObjectLocked
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

end

function HDLC_GenerateTBCB(cbinfo)
    hdlcc=loc_getHDLCC(cbinfo);
    if~isempty(hdlcc)
        try
            hc=hdlcc.getHDLCoder;
            hc.makehdltb([{'HDLSubsystem',hc.OrigStartNodeName},cbinfo.userdata]);
        catch e


            hdl_coder_auto_build_stage=Simulink.output.Stage('HDLCoder','ModelName',gcs(),'UIMode',true);%#ok<NASGU>
            Simulink.output.error(e,'Component','HDLCoder','Category','HDL');
        end
    end
end

function schema=HDLC_AddHDLCoderDisabled(~)
    schema=sl_action_schema;
    schema.label=DAStudio.message('HDLShared:hdldialog:menuitemAddHDLCoder');
    schema.tag='Simulink:HDLC_AddHDLCoder';
    schema.state='Disabled';
end

function schema=HDLC_AddHDLCoder(cbinfo)%#ok<DEFNU> % ( cbinfo )
    schema=HDLC_AddHDLCoderDisabled(cbinfo);
    schema.state=loc_getHDLMenuState(cbinfo);
    schema.callback=@HDLC_AddHDLCoderCB;

end

function HDLC_AddHDLCoderCB(cbinfo)
    attachhdlcconfig(cbinfo.model.Name);
end

function schema=HDLC_RemoveHDLCoderDisabled(~)
    schema=sl_action_schema;
    schema.label=DAStudio.message('HDLShared:hdldialog:menuitemRemoveHDLCoder');
    schema.tag='Simulink:HDLC_RemoveHDLCoder';
    schema.state='Disabled';
end

function schema=HDLC_RemoveHDLCoder(cbinfo)%#ok<DEFNU> % ( cbinfo )
    schema=HDLC_RemoveHDLCoderDisabled(cbinfo);
    schema.state=loc_getHDLMenuState(cbinfo);
    schema.callback=@HDLC_RemoveHDLCoderCB;
end

function HDLC_RemoveHDLCoderCB(cbinfo)
    Question=DAStudio.message('HDLShared:hdldialog:menuitemRemoveHDLprompt');
    title=DAStudio.message('HDLShared:hdldialog:menuitemRemoveHDLCoder');
    yes=DAStudio.message('HDLShared:hdldialog:hdlccYes');
    no=DAStudio.message('HDLShared:hdldialog:hdlccNo');
    ButtonName=questdlg(Question,title,yes,no,no);
    switch ButtonName
    case yes
        detachhdlcconfig(cbinfo.model.Name);
    end
end


function schema=HDLMenuSF(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:HDLMenu';
    schema.label=DAStudio.message('HDLShared:hdldialog:hdlccHDLCodermenuname');
    schema.state=loc_getHDLMenuSFState(cbinfo);
    schema.childrenFcns={@HighlightHDLCodeMenuItem
    };
end

function state=loc_getHDLMenuSFState(cbinfo)
    state='Disabled';
    if slreq.utils.selectionHasMarkup(cbinfo)
        return;
    end
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~isempty(obj)&&isvalid(obj)
        showIt=sfprivate('traceabilityManager','showHDLMenu',double(obj.backendId));
        if showIt&&((isa(obj,'StateflowDI.State')&&~obj.isBox)||isa(obj,'StateflowDI.Subviewer')||...
            isa(obj,'StateflowDI.Transition')||isa(obj,'StateflowDI.Junction'))
            state='Enabled';
        end
    end
end

function schema=HighlightHDLCodeMenuItem(cbinfo)
    schema=sl_action_schema;
    schema.tag='Stateflow:HighlightHDLCodeMenuItem';
    schema.label=DAStudio.message('HDLShared:hdldialog:menuitemNavigateToCode');
    schema.state=loc_getHighlightHDLCodeMenuItemState(cbinfo);
    schema.obsoleteTags={'Stateflow:HighlightCodeMenuItem'};
    schema.callback=@HighlightHDLCodeMenuItemCB;
    schema.autoDisableWhen='Never';
end

function state=loc_getHighlightHDLCodeMenuItemState(cbinfo)
    state='Disabled';
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~isempty(obj)&&isvalid(obj)
        if sfprivate('traceabilityManager','hdlHighlightCodeMenuItemEnabled',double(obj.backendId))
            state='Enabled';
        end
    end
end

function HighlightHDLCodeMenuItemCB(cbinfo)

    chartId=SFStudio.Utils.getChartId(cbinfo);
    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    if~isempty(obj)&&isvalid(obj)
        objectId=double(obj.backendId);
        sf('Highlight',chartId,objectId);
        sfprivate('traceabilityManager','hdlTraceObject',objectId);
    end
end

function schema=HDLContextMenu(cbinfo)%#ok<DEFNU>
    schema=hdlContextMenu(cbinfo);
    schema.obsoleteTags={schema.tag};
    schema.tag='Simulink:HDLContextMenu';
end





