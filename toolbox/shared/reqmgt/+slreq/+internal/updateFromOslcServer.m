function updateFromOslcServer(server,projectName,moduleUriOrQueryBase,queryString,dataTopNode)









    [serverCatalog,serverLoginInfo]=slreq.gui.getCatalogFromServer(server);
    if isempty(serverCatalog)
        error(message('Slvnv:oslc:FailedLogin'));
    end


    matchIdx=find(strcmp(serverCatalog.projectNames,projectName),1);
    if isempty(matchIdx)
        error(message('Slvnv:reqmgt:NotFoundIn',projectName,server));
    end
    projUri=serverCatalog.projectURIs{matchIdx};


    slreq.data.ReqData.getInstance.updateOSLCRequirements(serverLoginInfo,projUri,moduleUriOrQueryBase,queryString,dataTopNode);
end
