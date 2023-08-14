function dlg=launchWebWindow(cs,cfg)





    custom=configset.internal.util.getDialogCustomization(cs);
    if~isempty(custom)
        if~isstruct(cfg)
            cfg=[];
        end
        cfg.custom=custom;
    end


    viewObj=configset.internal.util.getHTMLView(cs);
    if isempty(viewObj)

        viewObj=configset.internal.util.createHTMLView(cs);
        viewObj.cfg=cfg;
        viewObj.view();
        dlg=viewObj.Dlg;
    else

        viewObj.cfg=cfg;
        viewObj.refresh();
        dlg=viewObj.Dlg;
        dlg.show;
    end





    if~isa(dlg,'DAStudio.Dialog')
        dlg=[];
    end


