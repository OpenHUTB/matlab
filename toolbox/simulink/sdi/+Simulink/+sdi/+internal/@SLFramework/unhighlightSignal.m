function unhighlightSignal(this,sid,bpath,portIdx,metaData)
    Simulink.ID.hilite('');

    [studio,~]=this.getCurrentStudio(gcs);
    if~isempty(studio)
        SLStudio.HighlightSignal.removeHighlighting(studio.App.blockDiagramHandle);
    end



    if isfield(metaData,'cb')&&~isempty(metaData.cb)
        metaData.cb(sid,{bpath},portIdx,metaData,false);
    end
end
