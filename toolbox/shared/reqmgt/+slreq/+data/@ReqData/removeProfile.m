function tf=removeProfile(this,mfReqLinkSet,profile)




    isReqSet=true;

    if isa(mfReqLinkSet,'slreq.datamodel.LinkSet')
        isReqSet=false;
    end

    tf=false;
    [~,fName,~]=fileparts(profile);
    prfName=[fName,'.xml'];

    arr=mfReqLinkSet.profiles.toArray;
    if any(strcmp(arr,prfName))

        mfReqLinkSet.profiles.remove(prfName);
        mfReqLinkSet.dirty=true;


        reqLinkSet=this.wrap(mfReqLinkSet);
        if isReqSet
            items=reqLinkSet.getAllItems();
        else
            items=reqLinkSet.getAllLinks();
        end
        reqData=slreq.data.ReqData.getInstance();

        for i=1:numel(items)
            reqLink=items(i);
            if isReqSet
                type=reqLink.typeName;
            else
                type=reqLink.type;
            end
            [profileName,~,~]=slreq.internal.ProfileReqType.getProfileStereotype(type);
            if strcmp(profileName,fName)
                reqData.deleteStereotypeAttributes(reqLink);
                if isReqSet
                    reqLink.typeName='Functional';
                else
                    reqLink.type='Relate';
                end
            end
        end
        tf=true;
    end
end