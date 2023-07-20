function[tf,isLegacyImport]=isImportedReqIF(domainLabel)





    isLegacyImport=false;

    if strcmp(domainLabel,'REQIF')

        tf=true;
        isLegacyImport=true;

    elseif strcmp(domainLabel,'ReqIF')

        tf=true;

    else

        tf=slreq.data.Requirement.isExternallySourcedReqIF(domainLabel);
    end
end
