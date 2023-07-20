function[error_string,missing_doc]=errorToHtml(obj,req,Mex,check)




    switch check
    case 'doc'
        error_string=processDocError(obj,req,Mex);
        missing_doc=0;
    case 'id'
        [error_string,missing_doc]=processIdError(obj,req,Mex);
    case 'label'
        [error_string,missing_doc]=processLabelError(obj,req,Mex);
    case 'path'
        error_string=processPathError(obj,req,Mex);
        missing_doc=0;



    otherwise
        error_string='';
        missing_doc=0;
    end
end

function this_error=processDocError(obj,req,Mex)
    if strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_doors:IsValidDocFcn')
        this_error=getString(message('Slvnv:reqmgt:mdlAdvCheck:DOORSIsUnavailableRMI'));
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnregisteredTarget')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnknownFileType')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnregisteredExt')
        this_error=invalidOrMissingDocError(obj,req.doc);
    else
        this_error='';
    end
end

function[this_error,missing_doc]=processIdError(obj,req,Mex)
    missing_doc=0;
    this_error='';
    if strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_doors:IsValidIdFcn')
        this_error=getString(message('Slvnv:reqmgt:mdlAdvCheck:DOORSIsUnavailable'));
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:com_word_check_app')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:com_excel_check_app')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_excel:openExcelDoc')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_word:openWordDoc')
        this_error=Mex.message;
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_word:DocumentNotFound')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_excel:DocumentNotFound')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:req_check_id:DocumentNotFound')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:DoorsObjValidationFailed')
        this_error=getString(message('Slvnv:consistency:errorDocCouldNotBeFound',['<b>',req.doc,'</b>']));
        missing_doc=1;
    elseif strcmp(Mex.identifier,'Simulink:Commands:OpenSystemUnknownSystem')||...
        strcmp(Mex.identifier,'Slvnv:slreq:UnableToLocateReqSet')
        this_error=Mex.message;
        missing_doc=1;
    elseif strcmp(Mex.identifier,'Simulink:utility:objectDestroyed')


        if strcmp(req.reqsys,'linktype_rmi_matlab')
            this_error=[req.doc,req.id,': ',Mex.message];
            missing_doc=1;
        end
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:mdlAdvCheck:UnableToCheckHarnessLink')
        this_error=Mex.message;
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnregisteredTarget')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnknownFileType')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnregisteredExt')

        if~ispc



            [~,~,fExt]=fileparts(req.doc);
            if~isempty(fExt)&&any(strcmpi(fExt,...
                {'.doc','.docx','.rtf','.xls','.xlsx','.pdf'}))
                this_error=unsupportedDocumentType(fExt);
            end
        end
        if isempty(this_error)
            this_error=invalidOrMissingDocError(obj,req.doc);
        end
    end
end

function[this_error,missing_doc]=processLabelError(obj,req,Mex)
    missing_doc=0;
    this_error='';
    if strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_doors:IsValidDescFcn')
        this_error=getString(message('Slvnv:reqmgt:mdlAdvCheck:DOORSIsUnavailable'));
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:com_word_check_app')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:com_excel_check_app')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_excel:openExcelDoc')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_word:openWordDoc')
        this_error=Mex.message;
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_word:DocumentNotFound')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_excel:DocumentNotFound')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:req_check_desc:DocumentNotFound')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:DoorsObjValidationFailed')
        missing_doc=1;
        this_error=getString(message('Slvnv:consistency:errorDocWasNotFound',['<b>',req.doc,'</b>']));
    elseif strcmp(Mex.identifier,'Simulink:Commands:OpenSystemUnknownSystem')||...
        strcmp(Mex.identifier,'Simulink:utility:invalidSID')||...
        strcmp(Mex.identifier,'Slvnv:slreq:UnableToLocateReqSet')
        this_error=Mex.message;
        missing_doc=1;
    elseif strcmp(Mex.identifier,'Simulink:utility:objectDestroyed')
        this_error=[req.doc,req.id,': ',Mex.message];
        missing_doc=1;
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_word:NamedItem')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_excel:NamedItem')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_doors:InvalidId')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:linktype_rmi_excel:FailedToLocateItem')
        missing_doc=1;
        this_error=getString(message('Slvnv:consistency:errorFailedToLocateItem',['<b>',req.id,'</b>'],['<b>',req.doc,'</b>']));
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:mdlAdvCheck:UnableToCheckHarnessLink')
        this_error=Mex.message;
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnregisteredTarget')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnknownFileType')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnregisteredExt')

        if~ispc



            [~,~,fExt]=fileparts(req.doc);
            if~isempty(fExt)&&any(strcmpi(fExt,...
                {'.doc','.docx','.rtf','.xls','.xlsx','.pdf'}))
                this_error=unsupportedDocumentType(fExt);
            end
        end
        if isempty(this_error)
            this_error=invalidOrMissingDocError(obj,req.doc);
        end
    end
end

function this_error=processPathError(obj,req,Mex)
    if strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnregisteredTarget')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnknownFileType')||...
        strcmp(Mex.identifier,'Slvnv:reqmgt:getLinktype:UnregisteredExt')
        this_error=invalidOrMissingDocError(obj,req.doc);
    elseif strcmp(Mex.identifier,'Slvnv:reqmgt:req_check_path:DocumentNotFound')
        this_error=getString(message('Slvnv:consistency:errorUnableToLocateDoc',['<b>',req.doc,'</b>']));
    else
        this_error='';
    end
end

function[this_error,missing_doc]=processBacklinkError(obj,req,Mex)





    [this_error,missing_doc]=processLabelError(obj,req,Mex);
    if~isempty(this_error)
        return;
    end

    if strcmp(Mex.identifier,'Slvnv:reqmgt:DoorsApiError')
        this_error=Mex.message;
    end
    expectedError1=['Module ID ''',strtok(req.doc),''' does not exist'];
    missing_doc=contains(this_error,expectedError1);


end

function sid=highlightError(obj)
    if ischar(obj)
        [srcName,theRest]=strtok(obj,'|');
        sid=theRest(2:end);
        rmicodenavigate(srcName,sid);
    else
        sid=handleToSid(obj);
        Simulink.ID.hilite(sid,'error');
    end
end

function sid=handleToSid(objH)
    if floor(objH)==objH
        sfRoot=Stateflow.Root;
        sid=Simulink.ID.getSID(sfRoot.idToHandle(objH));
    else
        sid=Simulink.ID.getSID(objH);
    end
end

function errorMessage=invalidOrMissingDocError(obj,doc)
    if isempty(strtrim(doc))
        sid=highlightError(obj);
        errorMessage=getString(message('Slvnv:consistency:errorInvalidLinkAtObject',['<b>',sid,'</b>']));
    else
        errorMessage=getString(message('Slvnv:consistency:errorUnableToResolveType',['<b>',doc,'</b>']));
    end
end

function errorMessage=unsupportedDocumentType(fExt)
    switch fExt
    case{'.xls','.xlsx'}
        errorMessage=getString(message('Slvnv:reqmgt:linktype_rmi_excel:ExcelNotSupportedOnUnix'));
    case{'.doc','.docx','.rtf'}
        errorMessage=getString(message('Slvnv:reqmgt:linktype_rmi_word:WordNotSupportedOnUnix'));
    otherwise
        errorMessage=getString(message('Slvnv:rmiref:insertRefs:InvalidDoctype',fExt));
    end
end
