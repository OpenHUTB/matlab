function errMsg=checkWordTemplateOpen(this)







    errMsg='';

    tid=this.getStylesheetID();
    format=this.getFormat();
    templateFormat=char(format.getID);


    if(strcmpi(templateFormat,'dom-pdf'))
        templateFormat='dom-docx';
    end

%#function rptgen.db2dom.TemplateCache
    cache=rptgen.db2dom.TemplateCache.getTheCache();
    switch templateFormat
    case 'dom-docx'
        templatePath=getDOCXTemplate(cache,tid);
    case 'dom-htmx'
        templatePath=getHTMLTemplate(cache,tid);
    case 'dom-html-file'
        templatePath=getHTMLFileTemplate(cache,tid);
    case 'dom-pdf-direct'
        templatePath=getPDFTemplate(cache,tid);
    end





    if isempty(templatePath)
        errMsg=getString(message(...
        'rptgen:rx_db_output:TemplateNotFoundError',tid));
        return;
    end

    if~isdeployed()
        if ispc()&&~rptgen.db2dom.TemplateCache.isTemplateReadable(templatePath)
            hdoc=mlreportgen.utils.word.open(templatePath);



            if isSaved(hdoc)
                errMsg=locCopyTemplateToTempDir(templatePath);
            else
                errMsg=locInvokeSaveAndCopyOrCancelDialog(templatePath);
            end
        end
    else



        if ispc()&&~rptgen.db2dom.TemplateCache.isTemplateReadable(templatePath)
            errMsg=getString(message('rptgen:rx_db_output:TemplateUnusable',templatePath));
        end
    end
end

function errMsg=locInvokeSaveAndCopyOrCancelDialog(templatePath)



    notSavedTemplateMsg=getString(message(...
    'rptgen:rx_db_output:TemplateUnsavedMsg',templatePath));
    notSavedTemplateTitle=getString(message(...
    'rptgen:rx_db_output:TemplateUnsavedTitle'));

    saveAndCopyOpt=getString(message('rptgen:rx_db_output:TemplateSaveAndCopy'));
    cancelOpt=getString(message('rptgen:RptgenML_StylesheetEditor:cancelLabel'));
    response=questdlg(notSavedTemplateMsg,notSavedTemplateTitle,...
    saveAndCopyOpt,...
    cancelOpt,...
    saveAndCopyOpt);
    switch(response)
    case saveAndCopyOpt
        mlreportgen.utils.word.save(templatePath);
        errMsg=locCopyTemplateToTempDir(templatePath);
    case cancelOpt
        errMsg=getString(message('rptgen:rx_db_output:TemplateUnsavedReportCanceledMsg'));
    otherwise
        errMsg='Unknown case';
    end
end


function errMsg=locCopyTemplateToTempDir(templOrigFile)
    errMsg='';
    newDir=tempname;
    mkdir(newDir);

    [~,templOrigFileName,templOrigFileExt]=fileparts(templOrigFile);

    templCopyFile=fullfile(newDir,[templOrigFileName,templOrigFileExt]);
    [copyStatus,copyErrMsg]=copyfile(templOrigFile,templCopyFile);
    if copyStatus&&isempty(copyErrMsg)
        cache=rptgen.db2dom.TemplateCache.getTheCache();
        cacheDOCXTemplateCopy(cache,templCopyFile);
    else
        errMsg=getString(message('rptgen:rx_db_output:destUnwritableMsg',...
        templCopyFile,templOrigFile));
    end
end