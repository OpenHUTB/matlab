function reqSetName=makeReqSetNameForSrcDoc(srcDomain,srcName)





    switch srcDomain

    case 'linktype_rmi_doors'


        moduleId=strtok(srcName);
        reqSetName=rmidoors.getModuleAttribute(moduleId,'Name');

    otherwise


        [~,reqSetName]=fileparts(srcName);
    end



    reqSetName=slreq.uri.sanitizeForFilename(reqSetName);

end
