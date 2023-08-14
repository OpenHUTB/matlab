function reqSetName=ensureExtension(reqSetName)




    [~,~,fExt]=fileparts(reqSetName);
    if~strcmp(fExt,'.slreqx')
        if strcmpi(fExt,'.slreqx')

            error(message('Slvnv:slreq:InvalidReqSetNameExt',slreq.uri.getShortNameExt(reqSetName)));
        else


            reqSetName=[reqSetName,'.slreqx'];
        end
    end
end
