function schemas=menus_rmi_tools(callbackInfo)

    modelH=callbackInfo.model.Handle;

    [installed,licensed]=rmi.isInstalled();
    licensed=installed&&licensed;

    if licensed&&rmisl.menus_UpdateDataBeforeUse(modelH)
        schemas={@rmisl.menus_UpdateDataBeforeUse};
        return;
    end

    if rmiut.isBuiltinNoRmi(modelH)
        schemas={@rmisl.menus_BuildInLib};
        return
    end
    isHarness=rmisl.isComponentHarness(modelH);
    isHarnessOpen=~isHarness&&hasActiveHarness(modelH);
    function yesno=hasActiveHarness(modelH)
        yesno=strcmp(get_param(modelH,'lock'),'on')&&Simulink.harness.internal.hasActiveHarness(modelH);
    end
    if isHarnessOpen
        im=DAStudio.InterfaceManagerHelper(callbackInfo.studio,'Simulink');
        schemas=[{im.getSubmenu('Simulink:SysRequirementsMenu')}...
        ,'SEPARATOR',{@RmiSettingsMenu}];
        return;
    end

    schemas={};

    if licensed
        schemas=[schemas,{@SwitchReqPerspective},{@OpenStandaloneEditor},'SEPARATOR'];
    end

    if licensed
        reports_schema={@Reports,{modelH,isHarness}};
        schemas=[schemas,{@HighlightMenu},{reports_schema},'SEPARATOR'];
    else
        schemas=[schemas,{@HighlightMenu},'SEPARATOR'];
    end

    if licensed&&~isHarness...
        &&ispc&&rmi.settings_mgr('get','isDoorsSetup')...
        &&~SLStudio.Utils.isLockedSystem(callbackInfo)
        schemas=[schemas,{@SyncMenu},'SEPARATOR'];
    end
    if~slreq.utils.selectionHasMarkup(callbackInfo)
        im=DAStudio.InterfaceManagerHelper(callbackInfo.studio,'Simulink');
        schemas=[schemas,{im.getSubmenu('Simulink:SysRequirementsMenu')}];
        selectedObj=callbackInfo.getSelection;
        if length(selectedObj)==1&&selectedObj.rmiIsSupported()
            schemas=[schemas,{im.getSubmenu('Simulink:BlockRequirementsMenu')}];
        end
        schemas=[schemas,'SEPARATOR'];
    end

    if~isHarness&&rmidata.isExternal(modelH)
        storage_schema={@Storage,{modelH,licensed}};
        schemas=[schemas,{storage_schema},'SEPARATOR'];
    end

    schemas=[schemas,{@RmiSettingsMenu}];

end


function schema=Reports(callbackInfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:ReqReports';
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:Reports'));
    schema.userdata=callbackInfo.userdata;
    schema.generateFcn=@ReportMenus;
    schema.autoDisableWhen='Busy';
end


function schemas=ReportMenus(callbackInfo)
    schemas={@MdlAdvMenu,@ReportMenu};
    isHarness=callbackInfo.userdata{2};
    if~isHarness&&~isempty(which('slwebview_req'))
        schemas=[schemas,{@WebViewMenu}];
    end
end


function schema=Storage(callbackInfo)
    schema=DAStudio.ContainerSchema;
    schema.tag='Simulink:ReqStorage';
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:LinksFile'));
    schema.userdata=callbackInfo.userdata;
    schema.generateFcn=@StorageMenus;
    schema.state=getStorageMenuState(callbackInfo.userdata);
    schema.autoDisableWhen='Busy';
end


function schemas=StorageMenus(callbackInfo)
    studioHelper=slreq.utils.DAStudioHelper.createHelper(callbackInfo.studio);
    modelH=studioHelper.ActiveModelHandle;

    licensed=callbackInfo.userdata{2};
    isLocked=strcmp(get_param(modelH,'Lock'),'on');
    if isLinkSetEmbedded(modelH)

        if licensed&&~isLocked
            schemas={@MoveToFile_schema};
        else
            schemas={};
        end
    elseif licensed
        schemas={@LoadFromFile_schema,@Save_schema,@SaveAs_schema};
        if~isLocked
            schemas=[schemas,{@CopyToModel_schema}];
        end
    else

        schemas={@LoadFromFile_schema};
    end
end


function tf=isLinkSetEmbedded(modelH)
    modelPath=get_param(modelH,'Filename');
    if isempty(modelPath)
        tf=false;
    else
        linkSet=slreq.utils.getLinkSet(modelPath);
        if isempty(linkSet)
            tf=false;
        else
            tf=slreq.utils.isEmbeddedLinkSet(linkSet.filepath);
        end
    end
end


function schema=MoveToFile_schema(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:MoveToFile'));
    schema.tag='Simulink:ReqMoveToFile';
    schema.callback=@MoveToFile_callback;
    schema.autoDisableWhen='Busy';
end


function MoveToFile_callback(callbackInfo)
    studioHelper=slreq.utils.DAStudioHelper.createHelper(callbackInfo.studio);
    modelH=studioHelper.ActiveModelHandle;
    destinationPath=rmimap.StorageMapper.getInstance.promptForReqFile(modelH,false);
    if~isempty(destinationPath)
        rmidata.export(modelH,true,destinationPath);
    end
end


function state=getStorageMenuState(userdata)
    modelH=userdata{1};
    if isLinkSetEmbedded(modelH)
        isLicensed=userdata{2};
        isLocked=strcmp(get_param(modelH,'Lock'),'on');
        if isLicensed&&~isLocked
            state='Enabled';
        else
            state='Disabled';
        end
    else
        state='Enabled';
    end
end


function schema=LoadFromFile_schema(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:LoadLinks'));
    schema.tag='Simulink:ReqLoadFromFile';
    schema.callback=@LoadFromFile_callback;
    schema.autoDisableWhen='Busy';
end
function LoadFromFile_callback(callbackInfo)
    studioHelper=slreq.utils.DAStudioHelper.createHelper(callbackInfo.studio);
    modelH=studioHelper.ActiveModelHandle;
    rmidata.loadFromFile(modelH);
end


function schema=Save_schema(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:SaveLinks'));
    schema.tag='Simulink:ReqSave';
    schema.callback=@Save_callback;
    modelH=callbackInfo.model.Handle;
    if~slreq.hasChanges(modelH)
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end


function Save_callback(callbackInfo)
    studioHelper=slreq.utils.DAStudioHelper.createHelper(callbackInfo.studio);
    modelH=studioHelper.ActiveModelHandle;
    rmidata.save(modelH);
    rmisl.notify(modelH,'');
end


function schema=SaveAs_schema(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:SaveLinksAs'));
    schema.tag='Simulink:ReqSaveAs';
    schema.callback=@SaveAs_callback;
    modelH=callbackInfo.model.Handle;
    if~rmidata.bdHasExternalData(modelH,true)
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end


function SaveAs_callback(callbackInfo)
    studioHelper=slreq.utils.DAStudioHelper.createHelper(callbackInfo.studio);
    modelH=studioHelper.ActiveModelHandle;
    destinationPath=rmimap.StorageMapper.getInstance.promptForReqFile(modelH,false);
    if~isempty(destinationPath)
        rmidata.save(modelH,destinationPath);
        rmisl.notify(modelH,'');
    end
end


function schema=CopyToModel_schema(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:CopyToModel'));
    schema.tag='Simulink:ReqCopyToMdl';
    schema.callback=@CopyToModel_callback;
    studioHelper=slreq.utils.DAStudioHelper.createHelper(callbackInfo.studio);
    modelH=studioHelper.ActiveModelHandle;    if~rmidata.bdHasExternalData(modelH,false)
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end
function CopyToModel_callback(callbackInfo)
    studioHelper=slreq.utils.DAStudioHelper.createHelper(callbackInfo.studio);
    modelH=studioHelper.ActiveModelHandle;
    rmidata.embed(modelH);
end


function schema=RmiSettingsMenu(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:Settings'));
    schema.tag='Simulink:LinkSettings';
    schema.callback=@RmiSettingsMenu_callback;
    schema.autoDisableWhen='Busy';
end


function RmiSettingsMenu_callback(callbackInfo)
    rmi_settings_dlg;
end


function schema=HighlightMenu(callbackInfo)
    schema=DAStudio.ActionSchema;

    modelH=callbackInfo.model.Handle;
    if Simulink.harness.isHarnessBD(modelH)&&~Simulink.harness.internal.isReqLinkingSupportedForExtHarness(modelH)
        schema.state='Disabled';
        schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:HighlightModel'));
        schema.tag='Simulink:ReqHighlightModel';
    end
    isHighlight=get_param(modelH,'ReqHilite');
    if strcmp(isHighlight,'off')
        schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:HighlightModel'));
        schema.tag='Simulink:ReqHighlightModel';
        schema.callback=@HighlightMenu_highlight_callback;
    else
        schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:UnhighlightModel'));
        schema.tag='Simulink:ReqUnhighlightModel';
        schema.callback=@HighlightMenu_unhighlight_callback;
    end
    schema.autoDisableWhen='Busy';
end


function HighlightMenu_highlight_callback(callbackInfo)
    modelH=callbackInfo.model.Handle;
    if~strcmp(get_param(modelH,'ReqHilite'),'on')
        SLStudio.Utils.RemoveHighlighting(modelH);

        set_param(modelH,'ReqHilite','on');
        [installed,licensed]=rmi.isInstalled();
        if installed&&licensed&&...
            rmipref('ShowDetailsWhenHighlighted')&&...
            ~rmisl.isComponentHarness(modelH)
            [~,~,~,hasLinkedBlocks]=rmisl.modelHasReqLinks(modelH);
            if hasLinkedBlocks
                rmi.Informer.display(get_param(modelH,'Name'));
            end
        end
    end
end


function HighlightMenu_unhighlight_callback(callbackInfo)
    modelH=callbackInfo.model.Handle;
    SLStudio.Utils.RemoveHighlighting(modelH);
end


function schema=ReportMenu(callbackInfo)%#ok<*INUSD>
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:GenerateReport'));
    schema.tag='Simulink:ReqReportGen';
    schema.callback=@ReportMenu_callback;
    schema.autoDisableWhen='Busy';
end


function ReportMenu_callback(callbackInfo)

    modelH=callbackInfo.model.Handle;
    rmi('report',modelH,true);
end


function schema=WebViewMenu(callbackInfo)%#ok<*INUSD>
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:GenerateWebView'));
    schema.tag='Simulink:ReqWebViewGen';
    schema.callback=@WebViewMenu_callback;
    schema.autoDisableWhen='Busy';
end


function WebViewMenu_callback(callbackInfo)

    modelH=callbackInfo.model.Handle;
    slwebview_req(modelH);
end


function schema=MdlAdvMenu(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:ConsistencyChecking'));
    schema.tag='Simulink:MdlAdvMenu';
    schema.callback=@MdlAdvMenu_callback;
    schema.autoDisableWhen='Busy';
end


function MdlAdvMenu_callback(callbackInfo)
    modelH=callbackInfo.model.Handle;
    rmi('check',modelH,'modeladvisor');
end


function schema=SyncMenu(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:rmisl:menus_rmi_tools:SynchronizeWithDOORS'));
    schema.tag='Simulink:ReqSyncDoors';
    schema.callback=@SyncMenu_callback;
    schema.autoDisableWhen='Busy';
end


function SyncMenu_callback(callbackInfo)
    modelH=callbackInfo.model.Handle;
    diaH=rmidoors.sync_dlg_mgr('add',modelH);
    if~isempty(diaH)
        diaH.show();
    end
end


function schema=OpenStandaloneEditor(callbackInfo)
    schema=DAStudio.ActionSchema;
    schema.label=getString(message('Slvnv:slreq:RequirementsEditor'));
    schema.tag='Simulink:OpenSLReqEditor';
    schema.callback=@OpenStandaloneEditor_callback;
    schema.autoDisableWhen='Busy';
end


function OpenStandaloneEditor_callback(callbackInfo)
    slreq.app.MainManager.getInstance.openRequirementsEditor();
end


function schema=SwitchReqPerspective(callbackInfo)
    schema=DAStudio.ToggleSchema;
    mdlH=callbackInfo.model.Handle;

    studioHelper=slreq.utils.DAStudioHelper.createHelper(callbackInfo.studio);
    canvasModelH=studioHelper.ActiveModelHandle;
    schema.label=getString(message('Slvnv:slreq:RequirementsPerspective'));
    schema.tag='Simulink:OpenSLReqPerspective';
    schema.callback=@SwitchReqPerspective_callback;
    schema.autoDisableWhen='Busy';

    if isempty(get_param(canvasModelH,'FileName'))
        schema.state='Disabled';
    elseif slreq.utils.isInPerspective(mdlH,false)

        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
end


function SwitchReqPerspective_callback(callbackInfo)
    mMgr=slreq.app.MainManager.getInstance;
    mMgr.togglePerspective(callbackInfo.studio);
end
