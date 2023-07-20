function showParameterPropertyPanels(this)







    if strcmp(this.App.ActiveContexts,this.ParameterContext_tag)
        return;
    end



    this.App.ActiveContexts=this.ParameterContext_tag;



    idx=cellfun(@(x)strcmp(x.Tag,this.ParameterContext_tag),this.App.Contexts);
    ctx=this.App.Contexts{idx};
    while~all(arrayfun(@(x)this.App.getPanel(x).Opened,ctx.PanelTags))
        pause(0.01);
    end
end
