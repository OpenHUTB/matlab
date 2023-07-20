function removeHighlighting(cbinfo,~)
    model=cbinfo.model.handle;
    SLStudio.Utils.RemoveHighlighting(model);
end