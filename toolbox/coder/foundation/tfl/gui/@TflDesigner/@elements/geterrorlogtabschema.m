function tabcontent=geterrorlogtabschema(this)





    textLbl.Name=DAStudio.message('RTW:tfldesigner:ErrorLogText');
    textLbl.Type='text';
    textLbl.RowSpan=[1,1];
    textLbl.ColSpan=[1,2];
    textLbl.Tag='Tfldesigner_ErrorlogLbl';

    errorString.Text=this.errLog;
    errorString.Type='textbrowser';
    errorString.RowSpan=[1,3];
    errorString.ColSpan=[1,2];
    errorString.Tag='Tfldesigner_ErrorlogLbl';


    propgroup.Type='panel';
    propgroup.LayoutGrid=[3,12];
    propgroup.RowSpan=[2,4];
    propgroup.ColSpan=[1,3];
    propgroup.RowStretch=ones(1,3);
    propgroup.ColStretch=ones(1,3);
    propgroup.Items={errorString};

    tabcontent.Type='panel';
    tabcontent.Name=DAStudio.message('RTW:tfldesigner:PropertiesText');
    tabcontent.LayoutGrid=[20,3];
    tabcontent.RowStretch=ones(1,10);
    tabcontent.ColStretch=ones(1,3);
    tabcontent.Items={textLbl,propgroup};


