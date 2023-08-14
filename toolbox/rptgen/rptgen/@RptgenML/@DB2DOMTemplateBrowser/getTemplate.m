function t=getTemplate(this,tt,id)










    t=[];
    if isempty(this.TemplateLibrary)
        this.getTemplateLibrary;
    end

    tt=upper(tt(5:end));

    libCat=this.(['Category',tt]);

    libTemplates=find(libCat,...
    '-depth',1,...
    '-isa','RptgenML.DB2DOMTemplateEditor');%#ok<GTARG>

    for i=1:length(libTemplates)
        if strcmp(libTemplates(i).ID,id)
            t=libTemplates(i);
            break;
        end
    end

    return;

end