

function dashboardPanelEditModeCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor();
    if~isempty(SLM3I.SLDomain.getPanelIdsForEditor(editor))
        editor=cbinfo.studio.App.getActiveEditor();
        enabled=SLM3I.SLDomain.getPanelEditModeForEditor(editor);
        if~enabled



            [panelInfo,block]=SLStudio.Utils.getSelectedPanelInfo(cbinfo);
            if~isempty(panelInfo)&&panelInfo.compacted
                panelInfo.compacted=false;
                SLM3I.SLDomain.updateWebPanelInfo(block.handle,jsonencode(panelInfo));
            end
        end
        SLM3I.SLDomain.setPanelEditModeForEditor(editor,~enabled);
    end
end