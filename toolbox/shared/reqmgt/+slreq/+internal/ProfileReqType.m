classdef ProfileReqType<slreq.internal.ProfileTypeBase




    methods(Static)

        function attrs=getStereotypeAttributes(stereotype)
            attrs=[];
            [profileName,stereotypeName,~]=slreq.internal.ProfileReqType.getProfileStereotype(stereotype);
            if~isempty(profileName)&&~isempty(stereotypeName)
                try
                    profile=systemcomposer.loadProfile(profileName);
                    stereotype=profile.getStereotype(stereotypeName);
                    attrs=stereotype.Properties;
                catch ME
                    error(message("Slvnv:slreq:NoSuchProfileAttribute"));
                end
            end
        end

        function type=getStereotypeAttrType(attributeName)






            type='';
            [profileName,stereotypeName,attName]=slreq.internal.ProfileReqType.getProfileStereotype(attributeName);

            try
                profile=systemcomposer.loadProfile(profileName);
                stereotype=profile.getStereotype(stereotypeName);
                props=stereotype.Properties;

                for i=1:numel(props)
                    property=props(i);
                    if strcmp(property.Name,attName)

                        type=property.Type;
                        break;
                    end
                end
            catch ME
                error(message("Slvnv:slreq:NoSuchProfileAttribute"));
            end
        end

        function value=getStereotypeDefaultValue(propName)



            [prfName,stName,attrName]=slreq.internal.ProfileReqType.getProfileStereotype(propName);

            if~isempty(prfName)&&~isempty(stName)&&~isempty(attrName)
                profile=systemcomposer.loadProfile(prfName);
                if~isempty(profile)
                    sType=profile.getStereotype(stName);
                    if~isempty(sType)
                        prop=sType.findProperty(attrName);
                        if~isempty(prop)

                            enumValues=enumeration(prop.Type);
                            if isempty(enumValues)
                                if slreq.internal.ProfileReqType.isNumTypeAttribute(prop.Type)
                                    value=str2double(prop.DefaultValue);
                                elseif strcmp(prop.Type,'boolean')
                                    value=strcmp(prop.DefaultValue,'true');
                                elseif strcmp(prop.Type,'string')



                                    if isempty(prop.DefaultValue)
                                        value='';
                                    else
                                        value=prop.DefaultValue(2:end-1);
                                    end
                                else
                                    value=prop.DefaultValue;
                                end
                            else
                                charDefault=char(prop.DefaultValue);

                                charDefault=charDefault(2:end-1);
                                charEnumValues=arrayfun(@(x)char(x),enumValues,'UniformOutput',false);
                                index=find(strcmp(charEnumValues,charDefault));
                                value=[];
                                if~isempty(index)
                                    value=enumValues(index);
                                end
                            end
                        end
                    end
                end
            end
        end

        function[profileUseChecker,profNs]=checkOutdatedProfiles(reqSet,mfModel)
            [profileUseChecker,profNs]=...
            slreq.internal.ProfileTypeBase.checkOutdatedProfilesLocal(reqSet.filepath,mfModel);
        end

        function resolveProfiles(reqSet,profUseChecker,profNs)

            try
                profiles=profUseChecker.p_ProfileNamespace.Profiles;
                for i=1:numel(profiles)
                    profile=profiles(i);
                    if~any(strcmp(profUseChecker.p_ProfileChangeReport.p_MissingProfiles,profile))
                        isExistingProfile=true;
                        reqSet.importProfile(profile.filePath,isExistingProfile);
                    end
                end
            catch ME %#ok<NASGU> 

            end
            if profUseChecker.isProfileOutdated

                traverseFunc=@slreq.internal.ProfileReqType.traverseReqSet;

                traverseFunc(@slreq.internal.ProfileReqType.resolveMissingProfiles,reqSet,profUseChecker,profNs);
                traverseFunc(@slreq.internal.ProfileReqType.resolveDeletedPrototypes,reqSet,profUseChecker,profNs);
                traverseFunc(@slreq.internal.ProfileReqType.resolveDeletedProperties,reqSet,profUseChecker,profNs);
                traverseFunc(@slreq.internal.ProfileReqType.resolveAddedPrototypes,reqSet,profUseChecker,profNs);
                traverseFunc(@slreq.internal.ProfileReqType.resolveAddedProperties,reqSet,profUseChecker,profNs);
                traverseFunc(@slreq.internal.ProfileReqType.resolveRenamedProperties,reqSet,profUseChecker,profNs);
                traverseFunc(@slreq.internal.ProfileReqType.resolveRenamedPrototypes,reqSet,profUseChecker,profNs);



                reqSet.setDirty(true);
            end


        end

        function traverseReqSet(funcHandle,reqSet,profUseChecker,ns)
            reqs=reqSet.getAllItems();
            for i=1:numel(reqs)
                funcHandle(reqs(i),profUseChecker,ns);
            end
        end

        function resolveDeletedPrototypes(req,profUseChecker,~)

            deletedPrototypes=profUseChecker.p_ProfileChangeReport.p_DeletedPrototypes.toArray();
            reqData=slreq.data.ReqData.getInstance();
            for i=1:length(deletedPrototypes)
                if strcmp(req.typeName,deletedPrototypes{i})

                    reqData.deleteStereotypeAttributes(req);

                    req.typeName='Functional';

                    break;
                end
            end
        end

        function resolveMissingProfiles(req,profUseChecker,~)
            missingProfiles=profUseChecker.p_ProfileChangeReport.p_MissingProfiles.toArray();
            reqData=slreq.data.ReqData.getInstance();
            [profName,~,~]=slreq.internal.ProfileReqType.getProfileStereotype(req.typeName);
            for i=1:length(missingProfiles)
                missing=missingProfiles{i};
                if strcmp(profName,missing)

                    reqData.deleteStereotypeAttributes(req);
                end
            end
        end

        function resolveDeletedProperties(req,profUseChecker,~)

            deletedProperties=profUseChecker.p_ProfileChangeReport.p_DeletedProperties.toArray();
            for i=1:length(deletedProperties)
                deleted=deletedProperties{i};

                [profName,sTypeName,~]=slreq.internal.ProfileReqType.getProfileStereotype(deleted);
                if strcmp(req.typeName,[profName,'.',sTypeName])
                    reqData=slreq.data.ReqData.getInstance();
                    reqData.deleteStereotypeAttributes(req,deleted);
                end
            end
        end

        function resolveAddedPrototypes(req,profUseChecker,ns)%#ok<INUSD> 







        end

        function resolveAddedProperties(req,profUseChecker,ns)%#ok<INUSD> 







        end

        function resolveRenamedPrototypes(req,profUseChecker,ns)

            renamedPrototypes=profUseChecker.p_ProfileChangeReport.p_RenamedPrototypes.toArray();
            reqData=slreq.data.ReqData.getInstance();
            for i=1:length(renamedPrototypes)
                if strcmp(req.typeName,renamedPrototypes{i})
                    prpSet=ns.p_PropertySets.getByKey(req.typeName);
                    keys=prpSet.properties.keys();

                    if~isempty(keys)
                        firstkey=keys{1};
                        prop=prpSet.properties.getByKey(firstkey);
                        newAttrName=prop.propertyDef.fullyQualifiedName;
                        [profName,protName,~]=slreq.internal.ProfileReqType.getProfileStereotype(newAttrName);





                        req.typeName=[profName,'.',protName];
                    end

                    break;
                end
            end
        end

        function resolveRenamedProperties(req,profUseChecker,ns)
            renamedProperties=profUseChecker.p_ProfileChangeReport.p_RenamedProperties.toArray();
            reqData=slreq.data.ReqData.getInstance();
            for i=1:length(renamedProperties)
                renamed=renamedProperties{i};
                [profName,sTypeName,attrName]=slreq.internal.ProfileReqType.getProfileStereotype(renamed);
                proto=ns.p_PropertySets.getByKey([profName,'.',sTypeName]);
                property=proto.properties.getByKey(attrName);
                newName=property.propertyDef.fullyQualifiedName;
                reqData.renameStereotypeAttribute(req,renamed,newName);
            end
        end

        function resolvePrototypeParentChanged(req,profUseChecker,ns)%#ok<INUSD> 

        end

        function ret=isNumTypeAttribute(typeName)
            ALL_NUM_TYPES={'double','int16','int32','int64','int8','uint16','uint32','uint64','uint8','single'};
            ret=any(strcmp(ALL_NUM_TYPES,typeName));
        end
    end
end