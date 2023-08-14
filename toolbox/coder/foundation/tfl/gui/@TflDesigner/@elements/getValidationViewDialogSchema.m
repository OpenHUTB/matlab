function containgroups=getValidationViewDialogSchema(this)






    validatestatus=this.getDialogWidget('Tfldesigner_ValidateStatus');
    validatestatus.Tag='Tfldesigner_ValidateStatus';
    validatestatus.Alignment=7;
    validatestatus.RowSpan=[1,1];
    validatestatus.ColSpan=[1,1];

    hyperlinkdesc=this.getDialogWidget('Tfldesigner_errorLogHyperlink');
    hyperlinkdesc.RowSpan=[1,1];
    hyperlinkdesc.ColSpan=[2,2];
    hyperlinkdesc.Alignment=7;
    hyperlinkdesc.Mode=1;

    notvalidatestatusdesc=this.getDialogWidget('Tfldesigner_ValidateStatusDesc');
    notvalidatestatusdesc.Italic=1;
    notvalidatestatusdesc.RowSpan=[1,1];
    notvalidatestatusdesc.ColSpan=[2,2];
    notvalidatestatusdesc.Alignment=5;


    invalidstatusdesc=this.getDialogWidget('Tfldesigner_InvalidStatusDesc');
    invalidstatusdesc.ForegroundColor=[255,0,0];
    invalidstatusdesc.Italic=1;
    invalidstatusdesc.RowSpan=[1,1];
    invalidstatusdesc.ColSpan=[2,2];
    invalidstatusdesc.Alignment=5;

    validstatusdesc=this.getDialogWidget('Tfldesigner_ValidStatusDesc');
    validstatusdesc.ForegroundColor=[28,148,51];
    validstatusdesc.Italic=1;
    validstatusdesc.RowSpan=[1,1];
    validstatusdesc.ColSpan=[2,2];
    validstatusdesc.Alignment=5;

    warningstatusdesc=this.getDialogWidget('Tfldesigner_WarningStatusDesc');
    warningstatusdesc.ForegroundColor=[255,165,0];
    warningstatusdesc.Italic=1;
    warningstatusdesc.RowSpan=[1,1];
    warningstatusdesc.ColSpan=[2,2];
    warningstatusdesc.Alignment=5;

    validatebutton=this.getDialogWidget('Tfldesigner_Validatepushbutton');
    validatebutton.Alignment=5;
    validatebutton.RowSpan=[1,1];
    validatebutton.ColSpan=[1,1];


    validationgroup.Name=DAStudio.message('RTW:tfldesigner:ValidationGroup');
    validationgroup.Type='group';
    validationgroup.LayoutGrid=[1,2];
    validationgroup.RowSpan=[1,1];
    validationgroup.ColSpan=[1,2];
    validationgroup.Items={validatestatus,notvalidatestatusdesc,...
    invalidstatusdesc,validstatusdesc,warningstatusdesc,validatebutton,hyperlinkdesc};

    containgroups.Type='panel';
    containgroups.LayoutGrid=[1,2];
    containgroups.Items={validationgroup};

