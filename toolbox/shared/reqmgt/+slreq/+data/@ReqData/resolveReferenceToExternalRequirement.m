function changed=resolveReferenceToExternalRequirement(this,ref,srcPath,loadReferencedReqsets)






    if nargin<4

        loadReferencedReqsets=true;
    end

    changed=false;



    [reqSetName,sid]=strtok(ref.reqSetUri,':');



    if strcmp(reqSetName,'_SELF')
        [~,reqSetName]=fileparts(srcPath);
        ref.reqSetUri=strrep(ref.reqSetUri,'_SELF',reqSetName);
    end




    dataReqSet=this.locateRequirementSet([reqSetName,'.slreqx'],srcPath,loadReferencedReqsets);

    if isempty(dataReqSet)


        return;
    end

    mfReq=this.findRequirement(dataReqSet,sid(2:end));



    if~isequal(ref.requirement,mfReq)
        ref.requirement=mfReq;
        changed=true;
    end

end

