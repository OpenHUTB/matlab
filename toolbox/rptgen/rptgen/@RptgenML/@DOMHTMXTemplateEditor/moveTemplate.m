function moveTemplate(this)




    import mlreportgen.dom.*;

    [filename,filepath]=uiputfile({'*.htmtx',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:htmtxFileDesc'))},...
    getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:moveDlgTitle')));

    if filename(1)==0
        msgbox(getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:moveCancelledMsg')),...
        getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:moveCancelledDlgTitle')));
        return
    end

    movePath=fullfile(filepath,filename);

    identifier=rptgen.db2dom.TemplateCache.getTemplateId(this.templatePath);

    [ok,errormsg,~]=movefile(this.TemplatePath,movePath);
    if ok
        cache=rptgen.db2dom.TemplateCache.getTheCache();
        uncacheHTMLTemplateById(cache,identifier);
        this.TemplatePath=movePath;
        cacheHTMLTemplate(cache,this.TemplatePath);
        browser=RptgenML.DB2DOMTemplateBrowser;
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('ListChangedEvent',browser);
        ed.broadcastEvent('PropertyChangedEvent',getCurrentTreeNode(RptgenML.Root));
    else
        errordlg(getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:moveErrorMsg',errormsg)),...
        getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:moveErrorDlgTitle')));
    end