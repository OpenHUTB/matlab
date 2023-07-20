function matrixentrypropertygroup=getMatrixEntryPropertyDialogSchema(this)




    matrixentrypropertygroup.Name=DAStudio.message('RTW:tfldesigner:MatrixEntryPropertyGroupTitle');
    matrixentrypropertygroup.Type='group';


    arrayLayout=this.getDialogWidget('Tfldesigner_ArrayLayout');
    arrayLayout.RowSpan=[1,1];
    arrayLayout.ColSpan=[1,2];


    allowShapeAgnosticMatch=this.getDialogWidget('Tfldesigner_AllowShapeAgnosticMatch');
    allowShapeAgnosticMatch.RowSpan=[1,1];
    allowShapeAgnosticMatch.ColSpan=[1,2];

    matrixentrypropertygroup.Visible=arrayLayout.Visible;
    if~matrixentrypropertygroup.Visible
        matrixentrypropertygroup.Enabled=false;
        matrixentrypropertygroup.Items={};
        return;
    end

    matrixentrypropertypanel.Type='panel';
    matrixentrypropertypanel.RowSpan=[1,2];
    matrixentrypropertypanel.ColSpan=[1,2];
    matrixentrypropertypanel.Items={arrayLayout,allowShapeAgnosticMatch};

    matrixentrypropertygroup.LayoutGrid=[1,1];
    matrixentrypropertygroup.Items={matrixentrypropertypanel};
