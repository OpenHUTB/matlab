function[success,new_description]=checkDesc(req,refSrc)



    success=true;
    new_description='';


    linkType=rmi.getLinktype(req.reqsys,req.doc);

    if strcmp(linkType.Registration,'linktype_rmi_slreq')
        [success,new_description]=feval(linkType.IsValidDescFcn,req.doc,req.id,req.description,refSrc);
        return;

    elseif linkType.isFile

        if rmisl.isDocBlockPath(req.doc)

            docPath=rmisl.docBlockTempPath(req.doc,true);
        else

            if ischar(refSrc)&&exist(refSrc,'file')==2
                refSrc=fileparts(refSrc);
            end
            docPath=rmisl.locateFile(req.doc,refSrc);
        end
        if isempty(docPath)
            error(message('Slvnv:reqmgt:req_check_desc:DocumentNotFound'));
        end

    elseif strcmp(linkType.Registration,'linktype_rmi_matlab')
        docPath=rmiml.resolveDoc(req.doc,refSrc);

    else
        docPath=req.doc;
    end

    if isempty(docPath)
        error(message('Slvnv:reqmgt:req_check_desc:DocumentNotFound'));
    end


    if~isempty(linkType.IsValidDescFcn)
        [success,new_description]=feval(linkType.IsValidDescFcn,docPath,req.id,req.description);
    end

end
