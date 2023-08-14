function dlgstruct=getDialogSchema(hView,name)




    switch(name)
    case 'TargetPrefView',
        dlgstruct=hView.getTargetPrefDialogSchema(name);
    case 'Warning',
        dlgstruct=hView.getErrorDialogSchema(name);
    case 'Error',
        dlgstruct=hView.getErrorDialogSchema(name);
    case 'Question',
        dlgstruct=hView.getQuestionDialogSchema(name);
    case 'AddProcessor',
        dlgstruct=hView.getAddProcessorDialogSchema(name);
    case 'FirstWarning',
        dlgstruct=hView.getFirstWarningDialogSchema(name);
    end
