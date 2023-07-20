function path=getBuiltinDocxTemplate(id)





    path=[];
    appdata=rptgen.appdata_rg;
    templateDir=appdata.DocxTemplateDirectory();
    templateFiles=dir(fullfile(templateDir,'*.dotx'));
    nTemplates=length(templateFiles);
    for iTemplate=1:nTemplates
        templateId=templateFiles(iTemplate).name(1:end-5);
        if strcmp(id,templateId)
            path=fullfile(templateDir,[templateId,'.dotx']);
            break;
        end
    end

end

