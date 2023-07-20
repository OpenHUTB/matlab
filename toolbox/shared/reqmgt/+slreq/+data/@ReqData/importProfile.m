function profile=importProfile(this,dataReqLinkSet,profileName,isExistingFile)




    if~reqmgt('rmiFeature','SupportProfile')
        profile=[];
        return;
    end

    if nargin<4
        isExistingFile=false;
    end


    slreq.utils.assertValid(dataReqLinkSet);

    if~isa(dataReqLinkSet,'slreq.data.RequirementSet')&&...
        ~isa(dataReqLinkSet,'slreq.data.LinkSet')
        error('Invalid argument: expected slreq.data.RequirementSet or slreq.data.LinkSet');
    end

    mfReqLinkSet=this.getModelObj(dataReqLinkSet);


    [~,fName,~]=fileparts(profileName);
    prfName=[fName,'.xml'];

    arr=mfReqLinkSet.profiles.toArray;

    profile=systemcomposer.loadProfile(profileName);

    if~any(strcmp(arr,prfName))



        mfReqLinkSet.profiles.add(prfName);
        if~isExistingFile

            mfReqLinkSet.dirty=true;
        end
    end

end