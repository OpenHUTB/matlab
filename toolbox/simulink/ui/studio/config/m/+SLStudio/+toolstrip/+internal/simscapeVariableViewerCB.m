



function simscapeVariableViewerCB(cbinfo,~)
    model=getfullname(cbinfo.model.handle);
    simscape.state.openViewer(model,true);
end
