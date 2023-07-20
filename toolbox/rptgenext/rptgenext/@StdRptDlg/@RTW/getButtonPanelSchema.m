function schema=getButtonPanelSchema(dlgsrc,~)






    tag_prefix='rtw_';


    btnSave.Type='pushbutton';
    btnSave.Name=dlgsrc.bxlate('RTWButtonLblOK');
    btnSave.ColSpan=[2,2];
    btnSave.ObjectMethod='saveOptions';
    btnSave.Tag=[tag_prefix,'saveButton'];


    btnRun.Type='pushbutton';
    btnRun.Name=dlgsrc.bxlate('RTWButtonLblPublish');
    btnRun.ColSpan=[3,3];
    btnRun.ObjectMethod='runReport';
    btnRun.Tag=[tag_prefix,'RunButton'];


    btnCancel.Type='pushbutton';
    btnCancel.Name=dlgsrc.bxlate('BaseButtonLblCancel');
    btnCancel.ColSpan=[4,4];
    btnCancel.ObjectMethod='cancelReport';
    btnCancel.Tag=[tag_prefix,'CancelButton'];


    btnHelp.Type='pushbutton';
    btnHelp.Name=dlgsrc.bxlate('BaseButtonLblHelp');
    btnHelp.ColSpan=[5,5];
    btnHelp.ObjectMethod='helpCallback';
    btnHelp.Tag=[tag_prefix,'HelpButton'];


    pnlSpacer.Type='panel';

    pnlButton.Type='panel';


    pnlButton.LayoutGrid=[1,5];
    pnlButton.ColStretch=[1,0,0,0,0];
    pnlButton.Items={pnlSpacer,btnSave,btnRun,btnCancel,btnHelp};

    pnlButton.Tag=[tag_prefix,'ButtonPanel'];

    schema=pnlButton;

end


