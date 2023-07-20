function dlgstruct=getDialogSchema(this,~)




    dlgTag='cvi.DockedReport.';

    covDetails.Type='webbrowser';
    if~isempty(this.url)
        covDetails.Url=this.url;
    else
        covDetails.HTML=this.html;
    end
    covDetails.WebKit=true;
    covDetails.DisableContextMenu=true;
    covDetails.Tag=[dlgTag,'webbrowser'];
    covDetails.WidgetId=[dlgTag,'webbrowser'];
    dlgstruct.Items={covDetails};

    dlgstruct.DialogTag=[dlgTag,this.hStudio.getStudioTag,'_',this.covMode];
    dlgstruct.DialogMode='Slim';
    dlgstruct.DialogTitle='';

    dlgstruct.EmbeddedButtonSet={''};
    dlgstruct.StandaloneButtonSet={''};
end