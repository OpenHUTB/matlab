function stereotypes=getAllStereotypes(this,linkReqSet,bUsePropertyName)




    if nargin<3

        bUsePropertyName=false;
    end

    stereotypes={};
    if isa(linkReqSet,'slreq.data.RequirementSet')||...
        isa(linkReqSet,'slreq.data.LinkSet')
        mflinkReqSet=this.getModelObj(linkReqSet);
    elseif isa(linkReqSet,'slreq.datamodel.RequirementSet')||...
        isa(linkReqSet,'slreq.datamodel.LinkSet')
        mflinkReqSet=linkReqSet;
    else

        return;
    end



    appliesTo='';
    if isa(linkReqSet,'slreq.data.RequirementSet')||...
        isa(linkReqSet,'slreq.datamodel.RequirementSet')
        appliesTo='Requirement';
    elseif isa(linkReqSet,'slreq.data.LinkSet')||...
        isa(linkReqSet,'slreq.datamodel.LinkSet')
        appliesTo='Link';
    end

    profs=mflinkReqSet.profiles.toArray;
    for i=1:numel(profs)
        try
            profile=systemcomposer.loadProfile(profs{i});
            [~,fn,~]=fileparts(profs{i});
            sTypes=profile.Stereotypes;
            for j=1:numel(sTypes)
                if~sTypes(j).Abstract
                    prType=sTypes(j).getImpl();
                    if(prType.appliesTo.Size>=1&&...
                        strcmp(prType.appliesTo(1),appliesTo))||...
                        ~slreq.internal.ProfileTypeBase.hasMetaAttribute(sTypes(j))
                        if strcmp(appliesTo,'Link')&&~bUsePropertyName

                            forwardName=slreq.internal.ProfileLinkType.getStereotypeForwardName(sTypes(j));
                            stereotypes{end+1}=[fn,'.',forwardName];%#ok<AGROW> 
                        else
                            stereotypes{end+1}=[fn,'.',sTypes(j).Name];%#ok<AGROW> 
                        end
                    end
                end
            end
        catch ME %#ok<NASGU> 

        end
    end

end