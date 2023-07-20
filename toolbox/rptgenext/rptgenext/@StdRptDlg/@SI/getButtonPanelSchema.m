function schema=getButtonPanelSchema(dlgsrc,~)






    tag_prefix='rtw_';


    btnRun.Type='pushbutton';
    btnRun.Name=dlgsrc.bxlate('RTWButtonLblPublish');
    btnRun.ColSpan=[2,2];
    btnRun.ObjectMethod='runReport';
    btnRun.Tag=[tag_prefix,'RunButton'];


    btnCancel.Type='pushbutton';
    btnCancel.Name=dlgsrc.bxlate('BaseButtonLblCancel');
    btnCancel.ColSpan=[3,3];
    btnCancel.ObjectMethod='cancelReport';
    btnCancel.Tag=[tag_prefix,'CancelButton'];


    btnHelp.Type='pushbutton';
    btnHelp.Name=dlgsrc.bxlate('BaseButtonLblHelp');
    btnHelp.ColSpan=[4,4];
    btnHelp.ObjectMethod='helpCallback';
    btnHelp.Tag=[tag_prefix,'HelpButton'];


    pnlSpacer.Type='panel';

    pnlButton.Type='panel';


    pnlButton.LayoutGrid=[1,4];
    pnlButton.ColStretch=[1,0,0,0];
    pnlButton.Items={pnlSpacer,btnRun,btnCancel,btnHelp};

    pnlButton.Tag=[tag_prefix,'ButtonPanel'];

    schema=pnlButton;

end


