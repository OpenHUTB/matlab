function addTemplateToLibrary(this,templatePath)






    [~,~,ext]=fileparts(templatePath);

    switch ext
    case{'.dotx','.DOTX'}
        formatCat=get(this,'CategoryDOCX');
        te=RptgenML.DOMDOCXTemplateEditor();
    case{'.htmtx','.HTMTX'}
        formatCat=get(this,'CategoryHTMX');
        te=RptgenML.DOMHTMXTemplateEditor();
    case{'.htmt','.HTMT'}
        formatCat=get(this,'CategoryHTMLFile');
        te=RptgenML.DOMHTMLFileTemplateEditor();
    case{'.pdftx','.PDFTX'}
        formatCat=get(this,'CategoryPDF');
        te=RptgenML.DOMPDFTemplateEditor();
    end

    te.TemplatePath=templatePath;
    connect(te,formatCat,'up');
end
