function dlgStruct=getDialogSchema(this)


    helpWebWidget.Type='webbrowser';
    helpWebWidget.WebKit=true;
    helpWebWidget.Url=this.getHelpHtml;
    helpWebWidget.Tag='helpWebWidgetTag';
    helpWebWidget.DialogRefresh=false;





    dlgStruct.DialogTitle='';
    dlgStruct.Items={helpWebWidget};
    dlgStruct.StandaloneButtonSet={''};
    dlgStruct.EmbeddedButtonSet={''};
    dlgStruct.LayoutGrid=[2,1];

end