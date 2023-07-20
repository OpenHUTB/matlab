
function params=getConfiguration(widgetId,model)
    params=struct;

    params.config='';
    params.metadata='';
    blockDlgSrc='';

    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,bdroot(model))
            blockDlgSrc=dlgSrc;
            break;
        end
    end

    blockHandle=get(blockDlgSrc.blockObj,'handle');
    blockDlgSrc.ConfigurationJSON=get_param(blockHandle,'Configuration');
    blockDlgSrc.metadata=get_param(blockHandle,'dlgMetadata');

    if~isempty(blockDlgSrc.ConfigurationJSON)
        params.config=jsondecode(blockDlgSrc.ConfigurationJSON);
    end

    if~isempty(blockDlgSrc.metadata)
        params.metadata=jsondecode(blockDlgSrc.metadata);
    end

    modelHandle=get_param(model,'Handle');
    editors=SLM3I.SLDomain.getAllEditorsForBlockDiagram(modelHandle);
    if isempty(editors)
        rootModel=bdroot(model);
        rootHandle=get_param(rootModel,'Handle');
        editors=SLM3I.SLDomain.getAllEditorsForBlockDiagram(rootHandle);
    end

    params.status=0;
    for idx=1:length(editors)
        editor=editors(idx);
        if isequal(SLM3I.SLDomain.getWidgetEditModeForEditor(editor),1)
            params.status=1;
        end
    end

    customType=get_param(blockHandle,'CustomType');
    if isequal(customType,'Switch')||isequal(customType,'Lamp')
        params.selectedIndex=get_param(blockHandle,'SelectedStateIndex');
        if isempty(params.selectedIndex)
            params.selectedIndex='0';
        end
    end

    params.customBackgroundColor=jsondecode(get_param(blockHandle,'CustomBackgroundColor'));
    params.blockOrientation=get_param(blockHandle,'Orientation');
    params.isLocked=customwebblocks.utils.isBlockInLockedSystem(blockDlgSrc.blockObj);

    params=jsonencode(params);
end
