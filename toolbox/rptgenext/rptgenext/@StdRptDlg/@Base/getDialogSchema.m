function schema=getDialogSchema(dlgsrc,name)






    tag_prefix='sdd_';

    pnlTitlePageOptions=dlgsrc.getTitlePageOptionsSchema(name);
    pnlContentOptions=dlgsrc.getContentOptionsSchema(name);
    pnlOutputOptions=dlgsrc.getReportOutputOptionsSchema(name);

    pnlMain.Type='panel';
    pnlMain.Tag=[tag_prefix,'MainPanel'];
    pnlMain.Items={pnlTitlePageOptions,pnlContentOptions,pnlOutputOptions};

    pnlButton=dlgsrc.getButtonPanelSchema(name);

    schema.DialogTitle=dlgsrc.getDialogTitle();
    schema.DialogTag=[tag_prefix,'dialog'];
    schema.StandaloneButtonSet=pnlButton;
    schema.IsScrollable=false;
    schema.Items={pnlMain};

end


