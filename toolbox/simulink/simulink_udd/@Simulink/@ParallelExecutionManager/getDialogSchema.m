function dlgStruct=getDialogSchema(h,~)

    rootEdit.Type='textbrowser';
    rootEdit.Text='Parallel Execution Manager';
    rootEdit.Tag='RootDescription';




    title='Parallel Execution Manager';
    dlgStruct.DialogTitle=title;
    dlgStruct.Items={rootEdit};
    dlgStruct.Source=h;


