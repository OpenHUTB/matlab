function varargout=getTemplateLibrary(this,libAction)








    root=RptgenML.Root;
    tLib=this.TemplateLibrary;
    if isempty(tLib)
        if nargin>1&&strcmpi(libAction,'-asynchronous')&&~isempty(root.Editor)

            tLib=RptgenML.Message(getString(message('rptgen:RptgenML_DB2DOMTemplateBrowser:searchingLabel')),...
            getString(message('rptgen:RptgenML_DB2DOMTemplateBrowser:buildingTemplateLibraryLabel')));

            mlreportgen.utils.internal.defer(@()this.getTemplateLibrary('-deferred'));

            if nargout>0
                varargout={tLib};
            end
            return;
        end

        tLib=RptgenML.Library;
        this.TemplateLibrary=tLib;

        r=RptgenML.Root;
        setEditorEnabled(r,'off');

        origShowProgressBar=rptgen.db2dom.TemplateCache.setgetShowProgressBar;
        rptgen.db2dom.TemplateCache.setgetShowProgressBar(true);

        cache=rptgen.db2dom.TemplateCache.getTheCache();
        setEditorEnabled(r,'on');
        rptgen.db2dom.TemplateCache.setgetShowProgressBar(origShowProgressBar);

        templates=getDOCXTemplates(cache);
        for i=1:length(templates)
            addTemplateToLibrary(this,templates{i});
        end

        templates=getHTMLTemplates(cache);
        for i=1:length(templates)
            addTemplateToLibrary(this,templates{i});
        end

        templates=getHTMLFileTemplates(cache);
        for i=1:length(templates)
            addTemplateToLibrary(this,templates{i});
        end

        templates=getPDFTemplates(cache);
        for i=1:length(templates)
            addTemplateToLibrary(this,templates{i});
        end


        if nargin>1&&strcmpi(libAction,'-deferred')&&~isempty(root.Editor)


            refreshWhenReady(root);
        end

    elseif nargin>1&&strcmpi(libAction,'-clear')
        tLib=[];
        this.TemplateLibrary=tLib;
        this.CategoryNEW=[];
    end

    if nargout>0
        varargout={tLib};
    end