function ret=isProfileImported(this,reqLinkSet,profileName)

    slreq.utils.assertValid(reqLinkSet);

    if~isa(reqLinkSet,'slreq.data.RequirementSet')&&...
        ~isa(reqLinkSet,'slreq.data.LinkSet')
        error('Invalid argument: expected slreq.data.RequirementSet or slreq.data.LinkSet');
    end

    [~,fname,fext]=fileparts(profileName);
    prfName=[fname,fext];
    if isempty(fext)
        prfName=[fname,'.xml'];
    end
    ret=false;

    mfReqLinkSet=this.getModelObj(reqLinkSet);
    arr=mfReqLinkSet.profiles.toArray;

    if any(strcmp(arr,prfName))
        ret=true;
    end
end