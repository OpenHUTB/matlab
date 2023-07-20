function schema=FileMenu(fncname,cbinfo,eventData)


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

function schema=OpenRecentMenu(~)%#ok<DEFNU> % ( cbinfo )
    schema=sl_container_schema;
    schema.tag='Simulink:OpenRecentMenu';
    schema.label=DAStudio.message('Simulink:studio:OpenRecentMenu');

    schema.generateFcn=@generateOpenRecentChildren;

    schema.autoDisableWhen='Never';
end

function gw=generateOpenSFXPopupList(cbinfo)

    sfxNames=Stateflow.App.Cdr.Runtime.InstanceIndRuntime.getRecentlyOpenSFXModels();
    if~isempty(sfxNames)
        gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);
        header=gw.Widget.addChild('PopupListHeader','recentSFXHeader');
        header.Label='simulink_ui:studio:resources:recentSFXHeaderLabel';


        for index=1:length(sfxNames)
            createRecentItem(gw,sfxNames{index},'SFX',index);
        end
    end
end


function gw=generateOpenRecentModelsPopupList(cbinfo)
    modelNames=slhistory.getMRUList();
    projectNames=slhistory.getMRUList(slhistoryListType.Projects);







    gw=[];
    if~isempty(modelNames)
        gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);
        header=gw.Widget.addChild('PopupListHeader','recentModelsHeader');
        header.Label='simulink_ui:studio:resources:recentModelsHeaderLabel';


        for index=1:length(modelNames)
            createRecentItem(gw,modelNames{index},'Model',index);
        end
    end

    if~isempty(projectNames)
        if isempty(gw)
            gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);
        end
        header=gw.Widget.addChild('PopupListHeader','recentProjectsHeader');
        header.Label='simulink_ui:studio:resources:recentProjectsHeaderLabel';


        for index=1:length(projectNames)
            createRecentItem(gw,projectNames{index},'Project',index);
        end
    end


end

function createRecentItem(gw,filepath,type,index)
    [~,name,ext]=fileparts(filepath);


    actionName=['recent',type,'Action_',num2str(index)];
    action=gw.createAction(actionName);
    action.text=[name,ext];
    action.description=filepath;
    action.enabled=true;
    action.optOutBusy=true;
    action.optOutLocked=true;
    switch(type)
    case 'Model'
        action.setCallbackFromArray(@(m)SLStudio.Utils.openModelWithProjectCheck(filepath),dig.model.FunctionType.Action);
        action.icon='model';
    case 'Project'
        action.setCallbackFromArray(@(p)simulinkproject(filepath),dig.model.FunctionType.Action);
        action.icon='project';
    case 'SFX'
        action.setCallbackFromArray(@(m)edit(filepath),dig.model.FunctionType.Action);
        action.icon='chart';
    end


    itemName=['recent',type,'Item_',num2str(index)];
    item=gw.Widget.addChild('ListItem',itemName);
    item.ActionId=[gw.Namespace,':',actionName];
    switch(type)
    case 'Model'
        item.IconOverride='model_16';
    case 'Project'
        item.IconOverride='project_16';
    case 'SFX'
        item.IconOverride='chart_16';
    end
end


function children=generateOpenRecentChildren(cbinfo)
    if SFStudio.Utils.isStateflowApp(cbinfo)
        children=generateRecentSFXModels();
    else
        models=generateRecentModels();
        projects=generateRecentProjects();
        children=[models;{'separator'};projects];
    end
end

function mruModelActions=generateRecentModels(~)
    mruModelActions=slhistory.getMRUList();
    for i=1:numel(mruModelActions)
        mruModelActions{i}=@(m)getRecentModelAction(mruModelActions{i},i);
    end
end
function mruModelActions=generateRecentSFXModels(~)
    mruModelActions=Stateflow.App.Cdr.Runtime.InstanceIndRuntime.getRecentlyOpenSFXModels();
    for i=1:numel(mruModelActions)
        mruModelActions{i}=@(m)getRecentSFXModelAction(mruModelActions{i},i);
    end
end

function mruProjectActions=generateRecentProjects(~)
    mruProjectActions=slhistory.getMRUList(slhistoryListType.Projects);
    for i=1:numel(mruProjectActions)
        mruProjectActions{i}=@(p)getRecentProjectAction(mruProjectActions{i},i);
    end
end
function schema=getRecentSFXModelAction(model,index)
    schema=getRecentItemAction(model,sprintf('%s_%d','Model',index));
    schema.icon='Simulink:OpenRecentSFXModel';
    schema.callback=@(m)edit(model);
end
function schema=getRecentModelAction(model,index)
    schema=getRecentItemAction(model,sprintf('%s_%d','Model',index));
    schema.icon='Simulink:OpenRecentModel';
    schema.callback=@(m)SLStudio.Utils.openModelWithProjectCheck(model);
end

function schema=getRecentProjectAction(project,index)
    schema=getRecentItemAction(project,sprintf('%s_%d','Project',index));
    schema.icon='Simulink:OpenRecentProject';
    schema.callback=@(p)simulinkproject(project);
end

function schema=getRecentItemAction(recentItem,tagSuffix)
    schema=sl_action_schema;
    schema.tag=['Simulink:OpenRecent',tagSuffix];


    [~,name,ext]=fileparts(recentItem);
    schema.label=[name,ext];
    schema.tooltip=recentItem;
    schema.statustip=recentItem;
    schema.autoDisableWhen='Busy';
end

function schema=CloseMenu(cbinfo)%#ok<DEFNU> 
    schema=sl_container_schema;
    schema.tag='Simulink:CloseMenu';
    schema.label=DAStudio.message('Simulink:studio:CloseMenu');

    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={
    im.getAction('Simulink:CloseTab'),...
    im.getAction('Simulink:CloseOtherTabs'),...
    'separator',...
    @CloseModel,...
    @CloseModelAndReferences,...
    'separator',...
    im.getAction('Simulink:CloseWindow'),...
    im.getAction('Simulink:CloseAllWindows')
    };

    schema.autoDisableWhen='Never';
end

function schema=CloseTab(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CloseTab';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CloseTab');
    if cbinfo.studio.getTabCount==1
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
    schema.obsoleteTags={'Simulink:Close'};
    schema.callback=@CloseTabCB;

    schema.autoDisableWhen='Never';
end

function schema=CloseTabSF(cbinfo)%#ok<DEFNU>
    schema=CloseTab(cbinfo);
    schema.obsoleteTags={'Stateflow:CloseMenuItem'};
end

function CloseTabCB(cbinfo)
    DAStudio.Callbacks.CloseTab(cbinfo);
end

function schema=CloseOtherTabs(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CloseOtherTabs';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CloseOtherTabs');
    if cbinfo.studio.getTabCount>1
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.obsoleteTags={'Simulink:Close'};
    schema.callback=@CloseOtherTabsCB;

    schema.autoDisableWhen='Never';
end

function schema=CloseOtherTabsSF(cbinfo)%#ok<DEFNU>
    schema=CloseOtherTabs(cbinfo);
    schema.obsoleteTags={'Stateflow:CloseMenuItem'};
end

function CloseOtherTabsCB(cbinfo)
    DAStudio.Callbacks.CloseOtherTabs(cbinfo);
end

function schema=CloseModel(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CloseModel';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CloseModel');
    schema.obsoleteTags={'Simulink:Close'};
    if SLM3I.canCloseBlockDiagram(cbinfo.model.Handle)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.userdata=schema.tag;
    schema.callback=@CloseModelCB;
    schema.autoDisableWhen='Never';
end

function CloseModelCB(cbinfo)
    SLM3I.closeBlockDiagram(cbinfo.model.Handle);
end

function schema=CloseModelAndReferences(~)
    schema=sl_action_schema;
    schema.tag='Simulink:CloseModelAndReferences';
    schema.label=DAStudio.message('Simulink:studio:CloseModelAndReferences');
    schema.obsoleteTags={'Simulink:Close'};
    schema.state='Hidden';
    schema.userdata=schema.tag;
    schema.callback=DAStudio.getDefaultCallback;

    schema.autoDisableWhen='Never';
end

function schema=CloseWindow(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CloseWindow';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CloseWindow');
    schema.accelerator='Ctrl+W';
    schema.obsoleteTags={'Simulink:Close'};
    schema.callback=@CloseWindowCB;

    if SLM3I.SLDomain.canCloseStudio(cbinfo.studio.App.getActiveEditor)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    schema.autoDisableWhen='Never';
end

function schema=CloseWindowSF(cbinfo)%#ok<DEFNU>
    schema=CloseWindow(cbinfo);
    schema.obsoleteTags={'Stateflow:CloseMenuItem'};
end

function CloseWindowCB(cbinfo)

    activeEditor=cbinfo.studio.App.getActiveEditor;
    cbinfo.domain.closeStudio(activeEditor);
end

function schema=CloseAllWindows(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:CloseAllWindows';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:CloseAllWindows');
    schema.obsoleteTags={'Simulink:Close'};
    schema.callback=@CloseAllWindowsCB;

    if SLM3I.SLDomain.canCloseStudio(cbinfo.studio.App.getActiveEditor)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end

    schema.autoDisableWhen='Never';
end

function schema=CloseAllWindowsSF(cbinfo)%#ok<DEFNU>
    schema=CloseAllWindows(cbinfo);
    schema.obsoleteTags={'Stateflow:CloseAllChartsMenuItem'};
end

function CloseAllWindowsCB(cbinfo)
    cbinfo.domain.closeAllStudios;
end

function schema=SaveAs(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:SaveAs';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:SaveAs');
    else
        schema.icon='save_as';
    end
    if SLM3I.canSaveBlockDiagramAs(cbinfo.model.Handle)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    if~Simulink.harness.isHarnessBD(cbinfo.model.Handle)&&...
        ~isempty(get_param(cbinfo.model.Handle,'HarnessUUID'))
        schema.state='Disabled';
    end
    schema.callback=@SaveAsCB;

    schema.autoDisableWhen='Busy';
end

function schema=SaveAsSF(cbinfo)%#ok<DEFNU>
    schema=SaveAs(cbinfo);
    schema.obsoleteTags={'Stateflow:SaveModelAsMenuItem'};
end

function SaveAsCB(cbinfo)

    if isa(cbinfo.domain,'StateflowDI.SFDomain')||isa(cbinfo.domain,'SA_M3I.StudioAdapterDomain')
        if SFStudio.Utils.isStateflowApp(cbinfo)
            Stateflow.App.Studio.SaveAs(cbinfo.model.Handle);
            return;

        elseif SFStudio.Utils.isTruthTable(cbinfo)
            subviewerId=SFStudio.Utils.getSubviewerId(cbinfo);
            Stateflow.TruthTable.TruthTableManager.saveModelAs(subviewerId);
            return;
        end
    end

    SLM3I.saveBlockDiagramAs(cbinfo.model.Handle);
end

function schema=SaveAll(cbinfo)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:SaveAll';
    schema.label=DAStudio.message('Simulink:studio:SaveAll');

    if cbinfo.domain.canSave(true)
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.userdata=schema.tag;
    schema.callback=DAStudio.getDefaultCallback;

    schema.autoDisableWhen='Busy';
end

function schema=ExportMenu(cbinfo)%#ok<DEFNU>
    schema=sl_container_schema;
    schema.tag='Simulink:ExportMenu';
    if cbinfo.model.isLibrary
        schema.label=DAStudio.message('Simulink:studio:ExportLibrary');
    else
        schema.label=DAStudio.message('Simulink:studio:ExportModel');
    end
    schema.autoDisableWhen='Busy';
    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');


    if SLStudio.Utils.isBlockDiagramProtected(cbinfo)
        schema.state='Disabled';
    end

    if Simulink.harness.isHarnessBD(SLStudio.Utils.getModelName(cbinfo))||...
        (~Simulink.harness.isHarnessBD(cbinfo.model.Handle)&&...
        ~isempty(get_param(cbinfo.model.Handle,'HarnessUUID')))
        schema.childrenFcns={...
        im.getAction('Stateflow:ExportToHTMLFileMenuItem'),...
        im.getAction('Simulink:ExportToWeb'),...
        };
    else
        schema.childrenFcns={...
        im.getAction('Stateflow:ExportToHTMLFileMenuItem'),...
        im.getAction('Simulink:ExportToWeb'),...
        @ExportToPreviousVersion,...
        };



        if(license('test','Real-Time_Workshop')||license('test','Simulink_HDL_Coder'))&&~cbinfo.model.isLibrary
            schema.childrenFcns=[schema.childrenFcns,...
            {@ExportToProtectedModel}];
        end

        schema.childrenFcns=[schema.childrenFcns,...
        {@ExportToTemplate}];


        if license('test','Simulink_Compiler')
            schema.childrenFcns=[schema.childrenFcns,...
            {@ExportToFMU2CS}];
        end
    end


    if license('test','System_Composer')
        schema.childrenFcns=[schema.childrenFcns,...
        {@ExportToArchitectureModel}];
    end

end

function schema=ExportToProtectedModel(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ExportToProtectedModel';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='referencedModelProtect';
        if Simulink.harness.isHarnessBD(SLStudio.Utils.getModelName(cbinfo))||...
            (~Simulink.harness.isHarnessBD(cbinfo.model.Handle)&&...
            ~isempty(get_param(cbinfo.model.Handle,'HarnessUUID')))||...
            strcmpi(get_param(cbinfo.model.Handle,'SimulinkSubdomain'),'Architecture')
            schema.state='Disabled';
        end
    else
        schema.label=DAStudio.message('Simulink:studio:ExportToProtectedModel');
    end
    schema.callback=@ExportProtectedModel;
    schema.autoDisableWhen='Never';
end

function ExportProtectedModel(cbinfo)
    dlgsrc=Simulink.ModelReference.ProtectedModel.CreatorDialog(SLStudio.Utils.getModelName(cbinfo));
    Simulink.ModelReference.ProtectedModel.showDialog(dlgsrc);
end

function schema=ExportToPreviousVersion(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ExportToPreviousVersion';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='export';
        if Simulink.harness.isHarnessBD(SLStudio.Utils.getModelName(cbinfo))||...
            (~Simulink.harness.isHarnessBD(cbinfo.model.Handle)&&...
            ~isempty(get_param(cbinfo.model.Handle,'HarnessUUID')))
            schema.state='Disabled';
        end
    else
        schema.label=DAStudio.message('Simulink:studio:ExportToPreviousVersion');
        if bdIsSubsystem(cbinfo.model.Handle)
            schema.state='Disabled';
        end
    end
    if Simulink.internal.isArchitectureModel(cbinfo)
        schema.state='Disabled';
    end
    schema.callback=@ExportModel;
    schema.autoDisableWhen='Never';
end

function ExportModel(cbinfo)
    Simulink.ExportModel(SLStudio.Utils.getModelName(cbinfo));
end

function schema=ExportSFXToPreviousVersion(~)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Stateflow:ExportToPreviousVersion';
    schema.callback=@ExportSFXModel;
    schema.autoDisableWhen='Never';
end

function ExportSFXModel(cbinfo)
    Stateflow.App.Studio.ExportModel(SLStudio.Utils.getModelName(cbinfo));
end

function schema=ExportToTemplate(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ExportToTemplate';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='exportModelToTemplate';
        if Simulink.harness.isHarnessBD(SLStudio.Utils.getModelName(cbinfo))||...
            (~Simulink.harness.isHarnessBD(cbinfo.model.Handle)&&...
            ~isempty(get_param(cbinfo.model.Handle,'HarnessUUID')))
            schema.state='Disabled';
        end
    else
        schema.label=DAStudio.message('Simulink:studio:ExportToTemplate');
    end
    schema.callback=@ExportTemplate;
    schema.autoDisableWhen='Never';
end

function ExportTemplate(cbinfo)
    sltemplate.ui.ExportTemplate(SLStudio.Utils.getModelName(cbinfo));
end

function state=ExportToFMU2CSGetState(~)
    status1=license('test','Simulink_Compiler');
    if(status1)
        state='Enabled';
    else
        state='Hidden';
    end
end

function ExportToFMU2CSCB(cbinfo)
    dlgsrc=FMU2ExpCSDialog.CreatorDialog(SLStudio.Utils.getModelName(cbinfo));
    FMU2ExpCSDialog.showDialog(dlgsrc);
end

function schema=ExportToFMU2CS(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ExportToFMU2CS';
    schema.label=DAStudio.message('FMUExport:FMU:ExportToFMU2CS');
    schema.callback=@ExportToFMU2CSCB;
    schema.state=ExportToFMU2CSGetState(cbinfo);
    schema.autoDisableWhen='Busy';
end

function schema=ExportToArchitectureModel(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ExportToArchitectureModel';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='systemArchitecture';
    else
        schema.label=DAStudio.message('Simulink:studio:ExportToArchitectureModel');
    end
    schema.callback=@ExportToArchitectureModelCB;
    schema.autoDisableWhen='Never';


    if~strcmp(get_param(cbinfo.model.Name,'SimulinkSubDomain'),'Simulink')
        schema.state='Hidden';
    end
end

function ExportToArchitectureModelCB(cbinfo)
    mdlName=get_param(cbinfo.studio.App.blockDiagramHandle,'Name');
    systemcomposer.internal.arch.ExportToArchitecture.launch(mdlName);
end

function schema=ModelPropertiesMenu(cbinfo)%#ok<DEFNU> 
    schema=sl_container_schema;
    isModel=true;
    if cbinfo.editorModel.isLibrary
        isModel=false;
        schema.tag='Simulink:LibraryPropertiesMenu';
        schema.label=DAStudio.message('Simulink:studio:LibraryPropertiesMenu');
    else
        schema.tag='Simulink:ModelPropertiesMenu';
        schema.label=DAStudio.message('Simulink:studio:ModelPropertiesMenu');
    end


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    if isModel
        children={@ModelProperties,...
        im.getAction('Simulink:ModelExplorerAssignDictionary'),...
        'separator',...
        im.getAction('Stateflow:ChartPropertiesMenuItem'),...
        im.getAction('Stateflow:MachinePropertiesMenuItem')
        };
    else
        children={@ModelProperties,...
        im.getAction('Stateflow:ChartPropertiesMenuItem'),...
        im.getAction('Stateflow:MachinePropertiesMenuItem')
        };
    end

    schema.childrenFcns=children;

    schema.autoDisableWhen='Never';
end

function schema=ModelProperties(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelProperties';
    schema.icon='Simulink:ModelProperties';

    aBDType=lower(cbinfo.editorModel.BlockDiagramType);
    if cbinfo.isContextMenu
        schema.callback=@RefModelPropertiesCB;

        switch(aBDType)
        case 'library'
            schema.label=DAStudio.message('Simulink:studio:LibraryPropertiesMenu');

        case 'subsystem'
            schema.label=DAStudio.message('Simulink:studio:SubsystemPropertiesMenu');

        otherwise
            currentModel=cbinfo.studio.App.getActiveEditor().blockDiagramHandle;
            topModel=cbinfo.studio.App.blockDiagramHandle;
            isTopModel=isequal(currentModel,topModel);
            if(isTopModel)
                schema.label=DAStudio.message('Simulink:studio:ModelPropertiesMenu');
            else
                schema.label=DAStudio.message('Simulink:studio:ReferencedModelPropertiesMenu');
                schema.icon='Simulink:ReferencedModelProperties';
            end
        end
    else
        schema.callback=@ModelPropertiesCB;

        switch(aBDType)
        case 'library'
            schema.label=DAStudio.message('Simulink:studio:LibraryProperties');

        case 'subsystem'
            schema.label=DAStudio.message('Simulink:studio:SubsystemProperties');

        otherwise
            schema.label=DAStudio.message('Simulink:studio:ModelProperties');
        end
    end


    schema.autoDisableWhen='Never';
end

function ModelPropertiesCB(cbinfo)

    modelName=SLStudio.Utils.getModelName(cbinfo,true);
    SLStudio.internal.openModelProperties(modelName);
end

function RefModelPropertiesCB(cbinfo)

    modelName=SLStudio.Utils.getModelName(cbinfo,false);
    SLStudio.internal.openModelProperties(modelName);
end

function schema=PrintMenuDisabled(~)%#ok<DEFNU> % ( cbinfo )
    schema=sl_container_schema;
    schema.tag='Simulink:PrintMenu';
    schema.label=DAStudio.message('Simulink:studio:PrintMenu');
    schema.state='Disabled';
    schema.childrenFcns={DAStudio.Actions('HiddenSchema')};
    schema.autoDisableWhen='Never';
end


function schema=PrintMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:PrintMenu';
    schema.label=DAStudio.message('Simulink:studio:PrintMenu');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    schema.childrenFcns={im.getAction('Simulink:Print'),...
    im.getSubmenu('Simulink:PrintToFileMenu'),...
    im.getAction('Simulink:PrintDetails'),...
    'separator',...
    im.getAction('Simulink:PrinterSetup'),...
    im.getAction('Simulink:EnableTiledPrinting'),...
    im.getAction('Simulink:ShowPageBoundaries')
    };

    schema.autoDisableWhen='Never';
end

function schema=PrintMenuSF(cbinfo)%#ok<DEFNU>
    schema=PrintMenu(cbinfo);
    if~cbinfo.isContextMenu
        schema.obsoleteTags={'Stateflow:PrintCurrentViewMenu'};
    end
end



function schema=PrintToFileMenu(cbinfo)
    schema=sl_container_schema;
    schema.tag='Simulink:PrintToFileMenu';
    schema.label=DAStudio.message('Simulink:studio:PrintToFileMenu');


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    children={im.getAction('Simulink:PrintToPDF'),...
    im.getAction('Simulink:PrintToJpeg'),...
    im.getAction('Simulink:PrintToPng'),...
    im.getAction('Simulink:PrintToTiff')
    };
    schema.childrenFcns=children;
    schema.state='Disabled';

    schema.autoDisableWhen='Never';
end

function schema=PrintToFileMenuSF(cbinfo)%#ok<DEFNU>
    schema=PrintToFileMenu(cbinfo);

    if SFStudio.Utils.isTruthTable(cbinfo)||SFStudio.Utils.isStateTransitionTable(cbinfo)
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end

    if~cbinfo.isContextMenu
        schema.obsoleteTags={'Stateflow:ToFileMenu'};
    end
end

function schema=PrintToFileMenuIF(cbinfo)%#ok<DEFNU>
    schema=PrintToFileMenu(cbinfo);
    schema.state='Disabled';
end

function schema=PrintToPDF(~)
    schema=sl_action_schema;
    schema.tag='Simulink:PrintToPDF';
    schema.label=DAStudio.message('Simulink:studio:PrintToPDF');
    schema.userdata=schema.tag;
    schema.callback=DAStudio.getDefaultCallback;

    schema.autoDisableWhen='Never';
end

function schema=PrintToPDFSF(cbinfo)%#ok<DEFNU>
    schema=PrintToPDF(cbinfo);
    schema.userdata='pdf';
    schema.callback=@PrintToFileSFCB;
    schema.obsoleteTags={'Stateflow:PostScriptMenuItem'};
end

function schema=PrintToJpeg(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:PrintToJpeg';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:PrintToJpeg');
    end
    schema.userdata=schema.tag;
    schema.callback=DAStudio.getDefaultCallback;

    schema.autoDisableWhen='Never';
end

function schema=PrintToJpegSF(cbinfo)%#ok<DEFNU>
    schema=PrintToJpeg(cbinfo);
    [~,pPosMode]=loc_getPaperPositionModeSF(cbinfo);
    if(strcmpi(pPosMode,'tiled'))
        schema.state='Disabled';
    end
    schema.userdata='jpeg';
    schema.callback=@PrintToFileSFCB;
    schema.obsoleteTags={'Stateflow:JpegMenuItem'};
end

function schema=PrintToPng(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:PrintToPng';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:PrintToPng');
    end
    schema.userdata=schema.tag;
    schema.callback=DAStudio.getDefaultCallback;

    schema.autoDisableWhen='Never';
end

function schema=PrintToPngSF(cbinfo)%#ok<DEFNU>
    schema=PrintToPng(cbinfo);
    [~,pPosMode]=loc_getPaperPositionModeSF(cbinfo);
    if(strcmpi(pPosMode,'tiled'))
        schema.state='Disabled';
    end
    schema.userdata='png';
    schema.callback=@PrintToFileSFCB;
    schema.obsoleteTags={'Stateflow:PngMenuItem'};
end

function schema=PrintToTiff(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:PrintToTiff';
    if~SLStudio.Utils.showInToolStrip(cbinfo)
        schema.label=DAStudio.message('Simulink:studio:PrintToTiff');
    end
    schema.userdata=schema.tag;
    schema.callback=DAStudio.getDefaultCallback;

    schema.autoDisableWhen='Never';
end

function schema=PrintToTiffSF(cbinfo)%#ok<DEFNU>
    schema=PrintToTiff(cbinfo);
    [~,pPosMode]=loc_getPaperPositionModeSF(cbinfo);
    if(strcmpi(pPosMode,'tiled'))
        schema.state='Disabled';
    end
    schema.userdata='tiff';
    schema.callback=@PrintToFileSFCB;
    schema.obsoleteTags={'Stateflow:TiffMenuItem'};
end

function PrintToFileSFCB(cbinfo)
    format=cbinfo.userdata;
    chartId=SFStudio.Utils.getSubviewerId(cbinfo);
    sfprint(chartId,format,'promptForFile',0);
end

function schema=PrintDetails(~)
    schema=sl_action_schema;
    schema.tag='Simulink:PrintDetails';
    schema.label=DAStudio.message('Simulink:studio:PrintDetails');
    schema.callback=@PrintDetailsCB;

    schema.autoDisableWhen='Never';
end

function schema=PrintDetailsSF(cbinfo)%#ok<DEFNU>
    schema=PrintDetails(cbinfo);
    schema.callback=@PrintDetailsSFCB;
    schema.obsoleteTags={'Stateflow:PrintDetailsMenuItem'};
end

function schema=PrintDetailsIF(cbinfo)%#ok<DEFNU>
    schema=PrintDetails(cbinfo);
    schema.state='Disabled';
end

function PrintDetailsCB(cbinfo)
    if isa(cbinfo.domain,'StateflowDI.SFDomain')
        PrintDetailsSFCB(cbinfo);
    else
        modelFullName=SLStudio.Utils.getDiagramFullName(cbinfo);
        rptgen_sl.slbook('-showdialog',modelFullName);
    end
end

function PrintDetailsSFCB(cbinfo)
    chartId=SFStudio.Utils.getSubviewerId(cbinfo);
    rptgen_sl.slbook('-showdialog',chartId);
end

function schema=PrinterSetup(~)
    schema=sl_action_schema;
    schema.tag='Simulink:PrinterSetup';
    schema.label=DAStudio.message('Simulink:studio:PrinterSetup');
    schema.callback=@PrinterSetupCB;

    schema.autoDisableWhen='Never';
end

function schema=PrinterSetupSF(cbinfo)%#ok<DEFNU>
    schema=PrinterSetup(cbinfo);
    schema.callback=@PrinterSetupSFCB;
    schema.obsoleteTags={'Stateflow:PrintSetupMenuItem'};
end

function schema=PrinterSetupIF(cbinfo)%#ok<DEFNU>
    schema=PrinterSetup(cbinfo);
    schema.state='Disabled';
end

function PrinterSetupCB(cbinfo)
    slStudioApp=cbinfo.studio.App;
    slDiagram=slStudioApp.topLevelDiagram;
    diagramName=slDiagram.getFullName;
    diagramHandle=get_param(diagramName,'Handle');
    SLM3I.SLDomain.showPrintSetupDialog(diagramHandle);
end

function PrinterSetupSFCB(cbinfo)
    chartId=SFStudio.Utils.getChartId(cbinfo);
    chartObj=idToHandle(sfroot,chartId);
    subSysHandle=chartObj.up.Handle;
    SLM3I.SLDomain.showPrintSetupDialog(subSysHandle);
end



function schema=TiledPrintingBase(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:EnableTiledPrinting';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:EnableTiledPrinting');

    schema.autoDisableWhen='Never';
end

function schema=TiledPrinting(cbinfo)%#ok<DEFNU>
    schema=TiledPrintingBase(cbinfo);
    [sysName,paperPosMode]=loc_getPaperPositionMode(cbinfo);
    if(strcmpi(paperPosMode,'tiled'))
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.userdata=sysName;
    schema.callback=@ToggleTiledPrintingCB;
end

function schema=TiledPrintingSF(cbinfo)%#ok<DEFNU>
    schema=TiledPrintingBase(cbinfo);
    [chartBlockId,paperPosMode]=loc_getPaperPositionModeSF(cbinfo);
    if(strcmpi(paperPosMode,'tiled'))
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.userdata=chartBlockId;
    schema.callback=@ToggleTiledPrintingSFCB;
    schema.obsoleteTags={'Stateflow:EnableTiledPrinting'};
end

function schema=TiledPrintingIF(cbinfo)%#ok<DEFNU>
    schema=TiledPrintingBase(cbinfo);
    schema.checked='Unchecked';
    schema.state='Disabled';
end

function[sysName,ppMode]=loc_getPaperPositionMode(cbinfo)
    sysName=SLStudio.Utils.getDiagramFullName(cbinfo);
    ppMode=get_param(sysName,'PaperPositionMode');
end

function[chartBlockId,ppMode]=loc_getPaperPositionModeSF(cbinfo)
    chartId=SFStudio.Utils.getSubviewerId(cbinfo);
    if chartId==0
        chartBlockId=0;
        ppMode='';
        return;
    end
    if(sf('get',chartId,'.isa')~=1)
        chartBlockId=sf('get',chartId,'.chart');
    else
        chartBlockId=chartId;
    end
    chartBlockObj=idToHandle(sfroot,chartBlockId);
    ppMode=chartBlockObj.PaperPositionMode;
end

function ToggleTiledPrintingCB(cbinfo,~)
    sysName=cbinfo.userdata;
    if(strcmpi(get_param(sysName,'PaperPositionMode'),'tiled'))
        set_param(sysName,'PaperPositionMode','auto');
    else
        set_param(sysName,'PaperPositionMode','tiled');
    end
end

function ToggleTiledPrintingSFCB(cbinfo,~)
    chartObj=idToHandle(sfroot,cbinfo.userdata);
    subSysHandle=chartObj.up.Handle;
    if(strcmpi(chartObj.PaperPositionMode,'tiled'))
        set_param(subSysHandle,'PaperPositionMode','auto');
    else
        set_param(subSysHandle,'PaperPositionMode','tiled');
    end
end

function schema=PageBoundariesBase(cbinfo)
    schema=sl_toggle_schema;
    schema.tag='Simulink:ShowPageBoundaries';
    schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ShowPageBoundaries');

    schema.autoDisableWhen='Never';
end

function schema=PageBoundaries(cbinfo)%#ok<DEFNU>
    schema=PageBoundariesBase(cbinfo);
    [sysName,spb]=loc_getShowPageBoundaries(cbinfo);
    if(strcmpi(spb,'on'))
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.userdata=sysName;
    schema.callback=@ToggleShowPageBoundariesCB;
end

function schema=PageBoundariesSF(cbinfo)%#ok<DEFNU>
    schema=PageBoundariesBase(cbinfo);
    [chartBlockId,spb]=loc_getShowPageBoundariesSF(cbinfo);
    if chartBlockId==0
        schema.state='Disabled';
    else
        schema.state='Enabled';
    end
    if(strcmpi(spb,'on'))
        schema.checked='Checked';
    else
        schema.checked='Unchecked';
    end
    schema.userdata=chartBlockId;
    schema.callback=@ToggleShowPageBoundariesSFCB;
    schema.obsoleteTags={'Stateflow:ShowPageBoundaries'};
end

function schema=PageBoundariesIF(cbinfo)%#ok<DEFNU>
    schema=PageBoundariesBase(cbinfo);
    schema.checked='Unchecked';
    schema.state='Disabled';
end

function[sysName,spb]=loc_getShowPageBoundaries(cbinfo)
    sysName=SLStudio.Utils.getDiagramFullName(cbinfo);
    spb=get_param(sysName,'ShowPageBoundaries');
end

function[chartBlockId,spb]=loc_getShowPageBoundariesSF(cbinfo)
    chartId=SFStudio.Utils.getSubviewerId(cbinfo);
    if chartId==0
        chartBlockId=0;
        spb='off';
        return;
    end
    if(sf('get',chartId,'.isa')~=1)
        chartBlockId=sf('get',chartId,'.chart');
    else
        chartBlockId=chartId;
    end
    chartBlockObj=idToHandle(sfroot,chartBlockId);
    spb=chartBlockObj.ShowPageBoundaries;
end

function ToggleShowPageBoundariesCB(cbinfo,~)
    sysName=cbinfo.userdata;
    if(strcmpi(get_param(sysName,'ShowPageBoundaries'),'on'))
        set_param(sysName,'ShowPageBoundaries','off');
    else
        set_param(sysName,'ShowPageBoundaries','on');
    end
end

function ToggleShowPageBoundariesSFCB(cbinfo,~)
    chartObj=idToHandle(sfroot,cbinfo.userdata);
    if(strcmpi(chartObj.ShowPageBoundaries,'on'))
        chartObj.ShowPageBoundaries='off';
    else
        chartObj.ShowPageBoundaries='on';
    end
end

function schema=SimulinkPreferences(~)%#ok<DEFNU> % ( cbinfo )
    schema=sl_action_schema;
    schema.tag='Simulink:SimulinkPreferences';
    schema.label=DAStudio.message('Simulink:studio:SimulinkPreferences');
    schema.state='Enabled';
    schema.callback=@SimulinkPreferencesCB;

    schema.autoDisableWhen='Never';
end

function SimulinkPreferencesCB(~)
    try
        feval('slprivate','showprefs');
    catch Err
        Err.getReport;
    end
end

function schema=ExitMatlab(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ExitMatlab';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='exitMatlab';
    else
        schema.label=SLStudio.Utils.getMessage(cbinfo,'Simulink:studio:ExitMatlab');
    end
    schema.accelerator='Ctrl+Q';
    schema.callback=@ExitMatlabCB;

    schema.autoDisableWhen='Never';
end

function schema=ExitMatlabSF(cbinfo)%#ok<DEFNU>
    schema=ExitMatlab(cbinfo);
    schema.obsoleteTags={'Stateflow:ExitMATLABMenuItem'};
end

function ExitMatlabCB(cbinfo)
    cbinfo.domain.exitMATLAB;
end




