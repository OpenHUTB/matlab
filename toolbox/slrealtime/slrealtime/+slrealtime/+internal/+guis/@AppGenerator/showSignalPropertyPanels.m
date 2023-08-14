function showSignalPropertyPanels(this)







    if strcmp(this.App.ActiveContexts,this.SignalContext_tag)
        return;
    end



    this.App.ActiveContexts=this.SignalContext_tag;



    idx=cellfun(@(x)strcmp(x.Tag,this.SignalContext_tag),this.App.Contexts);
    ctx=this.App.Contexts{idx};
    while~all(arrayfun(@(x)this.App.getPanel(x).Opened,ctx.PanelTags))
        pause(0.01);
    end
end
