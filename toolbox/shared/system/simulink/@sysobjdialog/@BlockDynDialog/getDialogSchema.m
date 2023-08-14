function dlgstruct=getDialogSchema(this,unused)%#ok<INUSD>




    dlgstruct=getBlockDialogSchema(this.DialogManager,this);

    dlgstruct.PreApplyMethod='preApplyCallback';
    dlgstruct.PreApplyArgs={'%dialog'};
    dlgstruct.PreApplyArgsDT={'handle'};

    dlgstruct.CloseMethod='closeCallback';
    dlgstruct.CloseMethodArgs={'%dialog'};
    dlgstruct.CloseMethodArgsDT={'handle'};







