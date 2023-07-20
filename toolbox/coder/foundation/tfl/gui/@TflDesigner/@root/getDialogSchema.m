function dlgstruct=getDialogSchema(this,name)%#ok<INUSD>




    Inst.Text=DAStudio.message('RTW:tfldesigner:RootInstrucText');
    Inst.Type='textbrowser';
    Inst.RowSpan=[2,4];
    Inst.ColSpan=[1,5];

    dlgstruct.DialogTitle=DAStudio.message('RTW:tfldesigner:RootDialogTitleText');
    dlgstruct.LayoutGrid=[4,6];
    dlgstruct.EmbeddedButtonSet={'Help','Apply'};
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/toolbox/ecoder/helptargets.map'],'tfl_base'};
    dlgstruct.Items={Inst};




