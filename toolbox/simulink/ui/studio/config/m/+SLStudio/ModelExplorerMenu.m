function schema=ModelExplorerMenu(fncname,cbinfo)
    fcn=str2func(fncname);
    if nargout(fcn)
        schema=fcn(cbinfo);
    else
        schema=[];
        fcn(cbinfo);
    end
end

function schema=ModelExplorerMenuImpl(cbinfo)%#ok<*DEFNU> % ( cbinfo )
    schema=sl_container_schema;
    schema.label=DAStudio.message('Simulink:studio:ModelExplorer');

    menu=cbinfo.userdata;
    schema.tag=['Simulink:',menu,'_ModelExplorer'];


    im=DAStudio.InterfaceManagerHelper(cbinfo.studio,'Simulink');
    children={{im.getAction('Simulink:ModelExplorer'),menu}...
    ,'separator',...
    @ModelExplorerBaseWorkspace,...
    @ModelExplorerDataDictionary,...
    @ModelExplorerModelWorkspace,...
    };

    schema.childrenFcns=children;

    schema.autoDisableWhen='Never';
end

function schema=ModelExplorerBaseWorkspace(~)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelExplorerBaseWorkspace';
    schema.icon='Simulink:ModelExplorerBaseWorkspace';
    schema.label=DAStudio.message('Simulink:studio:ModelExplorerBaseWorkspace');
    schema.callback=@ModelExplorerBaseWorkspaceCB;

    schema.autoDisableWhen='Never';
end

function ModelExplorerBaseWorkspaceCB(~)
    me=daexplr;
    root=me.getRoot;
    if ismethod(root,'getMixedHierarchicalChildren')
        subnodes=root.getMixedHierarchicalChildren;
    else
        subnodes=num2cell(root.getHierarchicalChildren);
    end
    for i=1:length(subnodes)
        if isequal(subnodes{i}.getFullName,'Base Workspace')
            daexplr('view',subnodes{i});
            break;
        end
    end
end

function schema=ModelExplorerModelWorkspace(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelExplorerModelWorkspace';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='workspaceModel';
        schema.label='simulink_ui:studio:resources:modelWorkspaceActionLabel';
    else
        schema.icon='Simulink:ModelExplorerModelWorkspace';
        schema.label=DAStudio.message('Simulink:studio:ModelExplorerModelWorkspace');
    end
    schema.callback=@ModelExplorerModelWorkspaceCB;
    modelName=SLStudio.Utils.getModelName(cbinfo,false);
    bdType=get_param(modelName,'BlockDiagramType');
    if(strcmpi(bdType,'Model'))
        schema.state='enabled';
    else
        schema.state='disabled';
    end

    schema.autoDisableWhen='Never';
end

function ModelExplorerModelWorkspaceCB(cbinfo)

    modelName=SLStudio.Utils.getModelName(cbinfo,false);

    slprivate('exploreListNode',modelName,'model','');
end

function schema=ModelExplorerDataDictionary(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelExplorerDataDictionary';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='dataDictionaryBaseWorkspace';
        schema.label='simulink_ui:studio:resources:dataDictionaryActionLabel';
        schema.tooltip='simulink_ui:studio:resources:dataDictionaryActionDescription';
    else
        schema.icon='Simulink:ModelExplorerDataDictionary';
        schema.label=DAStudio.message('Simulink:studio:ModelExplorerDataDictionary');
    end
    schema.callback=@ModelExplorerDataDictionaryCB;

    if cbinfo.model.isLibrary
        schema.state='Hidden';
    elseif isempty(cbinfo.model.DataDictionary)
        schema.state='disabled';
    else
        schema.state='enabled';
    end

    schema.autoDisableWhen='Never';
end

function ModelExplorerDataDictionaryCB(cbinfo)
    if~isempty(cbinfo.model.DataDictionary)
        opensldd(cbinfo.model.DataDictionary);
    end

end

function schema=ModelExplorerAssignDictionary(cbinfo)
    schema=sl_action_schema;
    schema.tag='Simulink:ModelExplorerAssignDictionary';
    if SLStudio.Utils.showInToolStrip(cbinfo)
        schema.icon='dataDictionaryLink';
    else
        schema.label=DAStudio.message('Simulink:studio:ModelExplorerAssignDictionary');
    end
    schema.callback=@ModelExplorerAssignDictionaryCB;
    if cbinfo.model.isLibrary
        schema.state='Hidden';
    else
        schema.state='enabled';
    end

    schema.autoDisableWhen='Never';
end

function ModelExplorerAssignDictionaryCB(cbinfo)

    modelName=SLStudio.Utils.getModelName(cbinfo,false);

    if~isempty(modelName)
        obj=get_param(modelName,'Object');
        tag=['_DDG_MP_',modelName,'_TAG_'];

        tr=DAStudio.ToolRoot;
        openDlgs=tr.getOpenDialogs;
        dlgs=openDlgs.find('DialogTag',tag);
        dlgProps='';
        for i=1:length(dlgs)
            if dlgs(i).isStandAlone
                dlgProps=dlgs(i);
                break;
            end
        end

        if isempty(dlgProps)
            dlgProps=DAStudio.Dialog(obj,tag,'DLG_STANDALONE');
        end

        imd=DAStudio.imDialog.getIMWidgets(dlgProps);
        tabbar=imd.find('tag','Tabcont');
        tabs=tabbar.find('-isa','DAStudio.imTab');
        if slfeature('ShowExternalDataNode')>0
            tabName=DAStudio.message('Simulink:dialog:ModelDataTabName_External');
        else
            tabName=DAStudio.message('Simulink:dialog:ModelDataTabName');
        end

        for i=1:length(tabs)
            if isequal(tabs(i).getName,tabName)
                dlgProps.setActiveTab('Tabcont',i-1);
                break;
            end
        end

        dlgProps.show;
    end
end


