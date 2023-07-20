classdef ProfileLinkType<slreq.internal.ProfileTypeBase




    methods(Static)

        function forwardName=getForwardName(dataLink)
            forwardName=slreq.internal.ProfileTypeBase.getMetaAttrValue(dataLink,'ForwardName',true);


            [~,fName,~]=slreq.internal.ProfileLinkType.getProfileStereotype(forwardName);
            if isempty(fName)
                forwardName=dataLink.type;
            end
        end

        function forwardName=getForwardNameWithLinkSetID(linkSetID,linkType)

            reqData=slreq.data.ReqData.getInstance();
            linkset=reqData.getLinkSet(linkSetID);
            isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(linkset,linkType);
            if~isStereotype

                forwardName='';
                return;
            end


            forwardName=slreq.internal.ProfileTypeBase.getMetaAttrValue(linkType,'ForwardName',true);
            [~,fName,~]=slreq.internal.ProfileLinkType.getProfileStereotype(forwardName);
            if isempty(fName)

                forwardName=linkType;
            end
        end

        function backwardName=getBackwardName(dataLink)
            backwardName=slreq.internal.ProfileTypeBase.getMetaAttrValue(dataLink,'BackwardName',true);


            [~,fName,~]=slreq.internal.ProfileLinkType.getProfileStereotype(backwardName);
            if isempty(fName)
                backwardName=dataLink.type;
            end
        end





        function forwardName=getStereotypeForwardName(stereotype)
            prType=stereotype.getImpl();
            forwardName='';

            if slreq.internal.ProfileTypeBase.hasMetaAttribute(stereotype)


                if prType.appliesTo.Size()>=1&&strcmp(prType.appliesTo(1),'Link')
                    forwardName=prType.metaAttributes.at('ForwardName').value;
                end


            end

            if isempty(forwardName)
                forwardName=stereotype.Name;
            else
                forwardName=forwardName(2:end-1);
            end
        end




        function linkType=getTypeByForwardName(dataLink,forwardName)
            linkType=forwardName;
            [prfName,~,~]=slreq.internal.ProfileLinkType.getProfileStereotype(forwardName);
            profiles=dataLink.getLinkSet().getAllProfiles();
            if any(strcmp([prfName,'.xml'],profiles.toArray()))
                prf=systemcomposer.loadProfile(prfName);
                stereotypes=prf.Stereotypes();
                for i=1:length(stereotypes)
                    stType=stereotypes(i);
                    fwdName=[prfName,'.',slreq.internal.ProfileLinkType.getStereotypeForwardName(stType)];
                    if strcmp(fwdName,forwardName)
                        linkType=[prfName,'.',stType.Name];
                        break;
                    end
                end
            end
        end

        function stereotypes=getAllStereotypesForLink(links)
            stereotypes=[];



            profiles={};
            for i=1:length(links)
                dataLink=links(i);
                linkset=dataLink.getLinkSet();
                profiles=[profiles,linkset.getAllProfiles().toArray()];%#ok<AGROW> 
            end

            profiles=unique(profiles);

            for i=1:length(profiles)
                profileName=profiles{i};
                profile=systemcomposer.loadProfile(profileName);
                [~,fName,~]=fileparts(profileName);
                stTypes=slreq.internal.ProfileLinkType.getStereotypesForAppliesto(...
                profile.Stereotypes(),'Link');
                stTypeNames=cellfun(@(x)[fName,'.',x.Name],stTypes,'UniformOutput',false);
                stereotypes=[stereotypes,stTypeNames];%#ok<AGROW> 
            end
        end

        function linktypes=getStereotypesForAppliesto(stereotypes,appliesTo)
            linktypes={};
            for i=1:length(stereotypes)
                stType=stereotypes(i);
                prType=stType.getImpl();
                if slreq.internal.ProfileTypeBase.hasMetaAttribute(stType)



                    if prType.appliesTo.Size>=1&&strcmp(prType.appliesTo(1),appliesTo)
                        linktypes{end+1}=stType;%#ok<AGROW>
                    end
                else



                    linktypes{end+1}=stType;%#ok<AGROW>
                end
            end
        end


        function resolveProfiles(linkSet,profChecker,profNs)

            try
                profiles=profChecker.p_ProfileNamespace.Profiles;
                arrayfun(@(x)...
                loadProfileifNotMissing(linkSet,...
                profChecker.p_ProfileChangeReport.p_MissingProfiles.toArray,x),profiles);
            catch

            end

            if profChecker.isProfileOutdated
                removeProfiles(linkSet,profChecker.p_ProfileChangeReport.p_MissingProfiles.toArray());

                traverseLinkSet(@resolveDeletedPrototypes,linkSet,profChecker,profNs);
                traverseLinkSet(@resolveDeletedProperties,linkSet,profChecker,profNs);
                traverseLinkSet(@resolveRenamedPrototypes,linkSet,profChecker,profNs);
                traverseLinkSet(@resolveRenamedProperties,linkSet,profChecker,profNs);
                traverseLinkSet(@resolveAddedPrototypes,linkSet,profChecker,profNs);
                traverseLinkSet(@resolveAddedProperties,linkSet,profChecker,profNs);
            end

        end
    end
end


function traverseLinkSet(funcHandle,linkSet,profChecker,prfNs)
    links=linkSet.getAllLinks();
    for i=1:numel(links)
        funcHandle(links(i),profChecker,prfNs);
    end
end

function removeProfiles(linkSet,missingProfiles)
    cellfun(@(x)linkSet.removeProfile(x),missingProfiles);
end

function resolveDeletedPrototypes(link,profUseChecker,~)

    deletedPrototypes=profUseChecker.p_ProfileChangeReport.p_DeletedPrototypes.toArray();
    reqData=slreq.data.ReqData.getInstance();
    for i=1:length(deletedPrototypes)
        if strcmp(link.type,deletedPrototypes{i})

            reqData.deleteStereotypeAttributes(link);

            link.type='Relate';

            break;
        end
    end
end

function resolveDeletedProperties(link,profUseChecker,~)

    deletedProperties=profUseChecker.p_ProfileChangeReport.p_DeletedProperties.toArray();
    for i=1:length(deletedProperties)
        deleted=deletedProperties{i};

        [profName,sTypeName,~]=slreq.internal.ProfileLinkType.getProfileStereotype(deleted);
        if strcmp(link.type,[profName,'.',sTypeName])
            reqData=slreq.data.ReqData.getInstance();
            reqData.deleteStereotypeAttributes(link,deleted);
        end
    end
end

function resolveRenamedPrototypes(link,profUseChecker,ns)

    renamedPrototypes=profUseChecker.p_ProfileChangeReport.p_RenamedPrototypes.toArray();
    reqData=slreq.data.ReqData.getInstance();
    for i=1:length(renamedPrototypes)
        if strcmp(link.type,renamedPrototypes{i})
            prpSet=ns.p_PropertySets.getByKey(link.type);
            keys=prpSet.properties.keys();

            if~isempty(keys)
                firstkey=keys{1};
                prop=prpSet.properties.getByKey(firstkey);
                newAttrName=prop.propertyDef.fullyQualifiedName;
                [profName,protName,~]=slreq.internal.ProfileReqType.getProfileStereotype(newAttrName);
                link.type=[profName,'.',protName];

                attrs=reqData.getStereotypeAttributes(link);
                attrKeys=attrs.keys();
                for j=1:length(attrKeys)
                    key=attrKeys{j};
                    [~,~,attrName]=slreq.internal.ProfileTypeBase.getProfileStereotype(key);
                    newName=[profName,'.',protName,'.',attrName];
                    reqData.renameStereotypeAttribute(link,key,newName);
                end
            end

            break;
        end
    end
end

function resolveRenamedProperties(link,profUseChecker,ns)
    renamedProperties=profUseChecker.p_ProfileChangeReport.p_RenamedProperties.toArray();
    reqData=slreq.data.ReqData.getInstance();
    for i=1:length(renamedProperties)
        renamed=renamedProperties{i};
        [profName,sTypeName,attrName]=slreq.internal.ProfileReqType.getProfileStereotype(renamed);
        proto=ns.p_PropertySets.getByKey([profName,'.',sTypeName]);
        property=proto.properties.getByKey(attrName);
        newName=property.propertyDef.fullyQualifiedName;
        reqData.renameStereotypeAttribute(link,renamed,newName);
    end
end

function resolveAddedPrototypes(~,~,~)

end

function resolveAddedProperties(~,~,~)

end

function loadProfileifNotMissing(linkSet,missingProfiles,prf)
    if~any(strcmp(prf,missingProfiles))

        linkSet.importProfile(profile.filePath);
    end
end