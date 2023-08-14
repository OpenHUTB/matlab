function CloseCallback(hSrc,~)





    model=hSrc.ParentHSrc.getModel;
    set_param(model,'RTWCodeCoverage',[]);

    cs=hSrc.ParentHSrc.getConfigSet;
    set_param(cs.getConfigSetSource,'CoverageDialogOpen','off');

    cs.refreshDialog;
end
