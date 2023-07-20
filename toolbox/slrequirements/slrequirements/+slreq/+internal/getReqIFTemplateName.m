



function[templateFile,templateName,templateLocation]=getReqIFTemplateName()

    templateName='export_template.reqif';
    templateLocation=slreq.opc.getUsrTempDir();
    templateFile=fullfile(templateLocation,templateName);


    if exist(templateFile,'file')==2
        delete(templateFile);
    end
end