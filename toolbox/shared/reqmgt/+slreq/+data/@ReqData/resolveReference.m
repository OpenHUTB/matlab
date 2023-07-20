function changed=resolveReference(this,ref,srcPath,loadReferencedReqsets)






    if nargin<4

        loadReferencedReqsets=true;
    end
    if nargin<3
        srcPath='';
    end


    if isempty(ref.domain)
        error('ReqData.resolveReference() requires non-empty .domain and .artifactUri field values');
    end







    if strcmp(ref.domain,'linktype_rmi_slreq')

        changed=this.resolveReferenceToMwRequirement(ref,srcPath,loadReferencedReqsets);

    elseif~isempty(ref.reqSetUri)


        changed=this.resolveReferenceToExternalRequirement(ref,srcPath,loadReferencedReqsets);

    else




        changed=this.resolveReferenceForDirectLink(ref,srcPath);
    end
end

