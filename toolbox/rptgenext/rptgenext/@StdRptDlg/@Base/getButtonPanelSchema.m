function schema=getButtonPanelSchema(dlgsrc,~)






    tag_prefix='sdd_';


    btnRun.Type='pushbutton';
    btnRun.Name=dlgsrc.bxlate('BaseButtonLblGenerate');
    btnRun.ColSpan=[2,2];
    btnRun.ObjectMethod='runReport';
    btnRun.Tag=[tag_prefix,'RunButton'];
    btnRun.ToolTip=dlgsrc.bxlate('BaseButtonTipGenerate');


    btnCustomize.Type='pushbutton';
    btnCustomize.Name=dlgsrc.bxlate('BaseButtonLblCustomizeContent');
    btnCustomize.ColSpan=[3,3];
    btnCustomize.ObjectMethod='customizeReport';
    btnCustomize.Tag=[tag_prefix,'CustomizeButton'];
    btnCustomize.ToolTip=dlgsrc.bxlate('BaseButtonTipCustomizeContent');


    btnCancel.Type='pushbutton';
    btnCancel.Name=dlgsrc.bxlate('BaseButtonLblCancel');
    btnCancel.ColSpan=[4,4];
    btnCancel.ObjectMethod='cancelReport';
    btnCancel.Tag=[tag_prefix,'CancelButton'];


    btnHelp.Type='pushbutton';
    btnHelp.Name=dlgsrc.bxlate('BaseButtonLblHelp');
    btnHelp.ColSpan=[5,5];
    btnHelp.ObjectMethod='help';
    btnHelp.Tag=[tag_prefix,'HelpButton'];


    pnlSpacer.Type='panel';

    pnlButton.Type='panel';


    pnlButton.LayoutGrid=[1,5];
    pnlButton.ColStretch=[1,0,0,0,0,];
    pnlButton.Items={pnlSpacer,btnRun,btnCustomize,btnCancel,btnHelp};


    pnlButton.Tag=[tag_prefix,'ButtonPanel'];

    schema=pnlButton;

end
