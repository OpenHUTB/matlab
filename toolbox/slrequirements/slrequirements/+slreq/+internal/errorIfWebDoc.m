function errorIfWebDoc(pathToFile)




    if startsWith(pathToFile,'https://')||startsWith(pathToFile,'http://')
        try



            error(message('Slvnv:slreq_import:CantImportFromWebFolder',slreq.uri.getShortNameExt(pathToFile)));
        catch ex
            throwAsCaller(ex);
        end
    end
end
