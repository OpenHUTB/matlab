function showSignalWithLinePropertyPanels(this)







    if strcmp(this.App.ActiveContexts,this.SignalWithLineContext_tag)
        return;
    end



    this.App.ActiveContexts=this.SignalWithLineContext_tag;



    idx=cellfun(@(x)strcmp(x.Tag,this.SignalWithLineContext_tag),this.App.Contexts);
    ctx=this.App.Contexts{idx};
    while~all(arrayfun(@(x)this.App.getPanel(x).Opened,ctx.PanelTags))
        pause(0.01);
    end
end
