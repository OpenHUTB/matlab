function dlgstruct=getBaseDialogStruct(~)










    dlgstruct.PreApplyMethod='dialogPreApplyCallback';
    dlgstruct.PreApplyArgs={'%dialog'};
    dlgstruct.PreApplyArgsDT={'handle'};


    dlgstruct.CloseMethod='dialogCloseCallback';
    dlgstruct.CloseMethodArgs={'%dialog'};
    dlgstruct.CloseMethodArgsDT={'handle'};

end
