classdef ProfileTypeBase<handle


    methods(Static)







        function tf=isa(dataLink,superType)
            baseBehavior=slreq.internal.ProfileTypeBase.getMetaAttrValue(dataLink,'BaseBehavior');
            tf=strcmp(baseBehavior,superType);
        end

        function tf=isProfileStereotype(reqLinkSet,typeOrTypeName)

            tf=false;
            if isa(typeOrTypeName,'slreq.custom.LinkType')&&isenum(typeOrTypeName)
                typeName=typeOrTypeName.getTypeName();
            else
                typeName=typeOrTypeName;
            end

            [prfName,sTypeName,~]=slreq.internal.ProfileTypeBase.getProfileStereotype(typeName);

            if~isempty(prfName)&&~isempty(sTypeName)
                if isa(reqLinkSet,'slreq.data.RequirementSet')||...
                    isa(reqLinkSet,'slreq.data.LinkSet')
                    tf=slreq.data.ReqData.getInstance.isProfileImported(reqLinkSet,prfName);
                elseif isa(reqLinkSet,'slreq.datamodel.RequirementSet')
                    arr=reqLinkSet.profiles.toArray;

                    if any(strcmp(arr,prfName))
                        tf=true;
                    end
                elseif isempty(reqLinkSet)


                    if exist([prfName,'.xml'],'file')

                        tf=true;
                    end
                end

            end
        end

        function[profile,stereotype,attrName]=getProfileStereotype(typeName)



            profile='';
            stereotype='';
            attrName='';
            tokens=strsplit(typeName,'.');

            numTokens=numel(tokens);

            if numTokens==2||numTokens==3
                profile=tokens{1};
                stereotype=tokens{2};
            end

            if numel(tokens)==3
                attrName=tokens{3};
            end
        end

        function[checker,namesp]=areProfilesOutdated(reqSetFilepath,mfModel)
            fname=reqSetFilepath;
            [~,~,fext]=fileparts(fname);
            if isempty(fext)
                fname=[fname,'.slreqx'];
            end
            [checker,namesp]=...
            slreq.internal.ProfileTypeBase.checkOutdatedProfilesLocal(fname,mfModel);
        end


        function[profileUseChecker,profNs]=checkOutdatedProfilesLocal(slreqxFilePath,mfModel)

            PROFILE_PART_NAME='profileNamespace_model.xml';
            package=slreq.opc.Package(slreqxFilePath);
            try
                modelData=package.readFile(PROFILE_PART_NAME);


                parser=mf.zero.io.XmlParser;

                parser.Model=mfModel;

                mdlEles=parser.parseString(modelData);

                profNs=[];

                for i=1:numel(mdlEles)
                    ele=mdlEles(i);
                    if isa(ele,'systemcomposer.internal.profile.ProfileNamespace')
                        profNs=ele;
                        break;
                    end
                end
                if~isempty(profNs)
                    skipAutoFix=true;
                    profNs.initializePostLoad(skipAutoFix);
                    profileUseChecker=systemcomposer.internal.profile.ProfileUseChecker.analyze(mfModel,profNs);
                else
                    profileUseChecker=[];
                    profNs=[];
                end
            catch ex %#ok<NASGU> 
                profileUseChecker=[];
                profNs=[];
            end
        end

        function tf=hasMetaAttribute(stType)




            prType=stType.getImpl();
            try
                prType.metaAttributes;
                tf=true;
            catch ME
                tf=false;
            end
        end

        function value=getMetaAttrValue(reqLink,attrName,usePrefix)

            if nargin<=2

                usePrefix=false;
            end

            value='';

            if isa(reqLink,'slreq.data.Link')
                dataLink=reqLink;

                [prfName,stTypeName,~]=slreq.internal.ProfileLinkType.getProfileStereotype(dataLink.type);
                profiles=dataLink.getLinkSet().getAllProfiles();
                if~any(strcmp([prfName,'.xml'],profiles.toArray()))
                    return
                end
            else
                reqLinkType=reqLink;
                [prfName,stTypeName,~]=slreq.internal.ProfileLinkType.getProfileStereotype(reqLinkType);
            end


            prf=systemcomposer.loadProfile(prfName);
            stType=prf.getStereotype(stTypeName);

            if slreq.internal.ProfileTypeBase.hasMetaAttribute(stType)
                prType=stType.getImpl();

                value=prType.metaAttributes.at(attrName).value;

                value=value(2:end-1);
                if usePrefix
                    value=[prfName,'.',value];
                end
            end

        end

        function profProps=getAllProperties(stereotypes)
            profProps={};
            for i=1:length(stereotypes)
                profAttrs=slreq.internal.ProfileReqType.getStereotypeAttributes(...
                stereotypes{i});
                profAttrNames=arrayfun(@(a)[stereotypes{i},'.',a.Name],profAttrs,'UniformOutput',false);
                profProps=[profProps,profAttrNames];%#ok<*AGROW> 
            end
        end

    end
end

