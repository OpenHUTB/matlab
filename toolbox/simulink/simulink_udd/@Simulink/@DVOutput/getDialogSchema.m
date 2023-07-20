function dlgstruct=getDialogSchema(this,name)



    if isunix
        pf=get(0,'ScreenPixelsPerInch')/72;
    else
        pf=1;
    end

    mdlObj=getParent(this);
    htmlitem.Type='textbrowser';
    htmlitem.Text=this.HTMLText;
    htmlitem.MinimumSize=pf*[400,280];




    dlgstruct.DialogTitle=getString(message('Sldv:SldvresultsSummary:ResultsWindowTitle',mdlObj.name));
    dlgstruct.Items={htmlitem};
    dlgstruct.StandaloneButtonSet={'Ok'};
    dlgstruct.DialogTag='sldv_results_dialog_tag';
    dlgstruct.HelpMethod='helpview(fullfile(docroot,''toolbox'',''sldv'',''sldv.map''),''me_reviewing_analysis_results'')';
end






