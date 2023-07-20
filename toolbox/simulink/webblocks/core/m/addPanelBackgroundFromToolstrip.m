

function addPanelBackgroundFromToolstrip(editor,panelId)
    dataUrl=getUserImageAsDataUrl();
    if~isempty(dataUrl)
        SLM3I.SLDomain.updatePanelBackground(editor,panelId,dataUrl);
    end
end