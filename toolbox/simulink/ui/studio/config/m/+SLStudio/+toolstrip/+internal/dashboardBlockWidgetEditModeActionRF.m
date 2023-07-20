

function dashboardBlockWidgetEditModeActionRF(cbinfo,action)
    action.selected=false;
    action.enabled=false;
    if SLStudio.Utils.isLockedSystem(cbinfo)
        return;
    end
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if~isempty(block)
        blockObj=get_param(block.handle,'Object');
        if isprop(blockObj,'Configuration')
            editor=cbinfo.studio.App.getActiveEditor();
            action.enabled=true;
            action.selected=SLM3I.SLDomain.getWidgetEditModeForEditor(editor);
        end
    end
end
