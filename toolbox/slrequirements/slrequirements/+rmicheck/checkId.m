function success=checkId(sys,doc,id,refSrc)



    success=true;

    if nargin<4
        refSrc='';
    end


    linkType=rmi.getLinktype(sys,doc);

    if strcmp(linkType.Registration,'linktype_rmi_slreq')
        success=feval(linkType.IsValidIdFcn,doc,id,refSrc);
        return;

    elseif linkType.IsFile

        if rmisl.isDocBlockPath(doc)

            docPath=rmisl.docBlockTempPath(doc,true);
        else
            if ischar(refSrc)&&~isempty(refSrc)&&exist(refSrc,'file')==2
                refSrc=fileparts(refSrc);
            end
            docPath=rmisl.locateFile(doc,refSrc);
        end
        if isempty(docPath)
            error(message('Slvnv:reqmgt:req_check_id:DocumentNotFound'));
        end

    elseif strcmp(linkType.Registration,'linktype_rmi_matlab')
        docPath=rmiml.resolveDoc(doc,refSrc);

    else
        docPath=doc;
    end

    if isempty(docPath)
        error(message('Slvnv:reqmgt:req_check_id:DocumentNotFound'));
    end


    if~isempty(linkType.IsValidIdFcn)
        success=feval(linkType.IsValidIdFcn,docPath,id);
    end
