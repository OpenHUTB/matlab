function copyTemplate(this)




    import mlreportgen.dom.*;

    [filename,filepath]=uiputfile({'*.dotx',...
    getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:dotxFileDesc'))},...
    getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:copyDlgTitle')));

    if filename(1)==0
        msgbox(getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:copyCancelledMsg')),...
        getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:copyCancelledDlgTitle')));
        return
    end

    copyPath=fullfile(filepath,filename);

    [ok,errormsg,~]=copyfile(this.TemplatePath,copyPath);

    if ok
        [ok,errormsg,~]=fileattrib(copyPath,'+w');
    end

    if ok
        browser=RptgenML.DB2DOMTemplateBrowser;
        formatCat=get(browser,'CategoryDOCX');
        te=RptgenML.DOMDOCXTemplateEditor();
        te.TemplatePath=copyPath;


        cache=rptgen.db2dom.TemplateCache.getTheCache();
        props=mlreportgen.dom.Document.getCoreProperties(te.TemplatePath);
        props.Identifier=getCopiedUniqueId(cache,this.ID);
        mlreportgen.dom.Document.setCoreProperties(te.TemplatePath,props);


        cacheDOCXTemplate(cache,te.TemplatePath);

        te.DisplayName=getString(message(...
        'rptgen:RptgenML_DB2DOMTemplateEditor:copyOfDisplayName',...
        this.DisplayName));
        te.Description=this.Description;
        connect(te,formatCat,'up');

        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('ListChangedEvent',browser);
        ed.broadcastEvent('PropertyChangedEvent',getCurrentTreeNode(RptgenML.Root));
    else
        errordlg(getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:copyErrorMsg',errormsg)),...
        getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:copyErrorDlgTitle')));
    end