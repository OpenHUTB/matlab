function refStruct=populateLegacyFieldNames(refStruct,srcArtifactPath)




    if~isfield(refStruct,'reqsys')
        refStruct.reqsys=refStruct.domain;
    end
    if~isfield(refStruct,'doc')
        if isfield(refStruct,'artifact')
            refStruct.doc=refStruct.artifact;
        elseif isfield(refStruct,'artifactUri')
            refStruct.doc=refStruct.artifactUri;
        else
            error(message('Slvnv:slreq:StructureMissingRequiredFields','artifact','domain'));
        end
    end



    if slreq.utils.isLocalFile(refStruct)
        resolvedPath=slreq.uri.getPreferredPath(refStruct.doc,srcArtifactPath,refStruct.doc);

        if isempty(resolvedPath)





        else
            refStruct.doc=resolvedPath;
        end
    end


    if~isfield(refStruct,'id')
        if isfield(refStruct,'artifactId')
            refStruct.id=refStruct.artifactId;
        else
            refStruct.id='';
        end
    end


    if~isfield(refStruct,'description')
        switch refStruct.reqsys
        case 'linktype_rmi_slreq'

            refStruct.description='';
        otherwise
            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(refStruct.reqsys);
            if isfield(refStruct,'parent')&&strcmp(adapter.domain,'linktype_rmi_simulink')
                id=slreq.utils.getLongIdFromShortId(refStruct.parent,refStruct.id);
            else
                id=refStruct.id;
            end
            refStruct.description=adapter.getSummary(refStruct.doc,id);
        end
    end


    if~isfield(refStruct,'linked')
        refStruct.linked=true;
    end
    if~isfield(refStruct,'keywords')
        refStruct.keywords='';
    end




    refStruct=slreq.uri.correctDestinationUriAndId(refStruct);
end
