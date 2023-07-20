classdef LinkTypeManager<handle






    methods(Static)
        function displayNames=getAllForwardDisplayNames(dasLinkSet)
            allMFLinkTypes=slreq.data.ReqData.getInstance.getAllLinkTypes();
            displayNames=cell(1,numel(allMFLinkTypes));
            for n=1:length(allMFLinkTypes)
                mfLinkType=allMFLinkTypes(n);
                if mfLinkType.isBuiltin
                    displayNames{n}=getString(message(mfLinkType.forwardName));
                else

                    displayNames{n}=mfLinkType.forwardName;
                end
            end

            if nargin>0
                allStereotypes=dasLinkSet.getAllStereotypes();
                displayNames=[displayNames,allStereotypes];
            end
        end

        function displayName=getForwardName(typeNameOrEnum)




            linkset=[];
            isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(...
            linkset,typeNameOrEnum);
            if isStereotype
                displayName=slreq.internal.ProfileLinkType.getForwardName(typeNameOrEnum);
            else
                mfLinkType=slreq.data.ReqData.getInstance.getLinkType(typeNameOrEnum);
                if mfLinkType.isBuiltin
                    displayName=getString(message(mfLinkType.forwardName));
                else
                    displayName=mfLinkType.forwardName;
                end
            end
        end

        function displayName=getBackwardName(typeNameOrEnum)




            linkset=[];
            isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(...
            linkset,typeNameOrEnum);
            if isStereotype
                displayName=slreq.internal.ProfileLinkType.getBackwardName(typeNameOrEnum);
            else
                mfLinkType=slreq.data.ReqData.getInstance.getLinkType(typeNameOrEnum);
                if mfLinkType.isBuiltin
                    displayName=getString(message(mfLinkType.backwardName));
                else
                    displayName=mfLinkType.backwardName;
                end
            end
        end

        function tf=isa(subTypeNameOrEnum,superTypeNameOrEnum,dataLinkSet)
            if nargin<3
                dataLinkSet=[];
            end

            isStereotype=~isempty(dataLinkSet)&&...
            ~isa(subTypeNameOrEnum,'slreq.custom.LinkType')&&...
            slreq.internal.ProfileLinkType.isProfileStereotype(dataLinkSet,subTypeNameOrEnum);

            if isStereotype
                tf=slreq.internal.ProfileLinkType.isa(subTypeNameOrEnum,superTypeNameOrEnum);
                return;
            end

            reqData=slreq.data.ReqData.getInstance;
            subType=reqData.getLinkType(subTypeNameOrEnum);

            superType=reqData.getLinkType(superTypeNameOrEnum);
            if subType==superType
                tf=true;
            else
                tf=recIsSubTypeObj(subType,superType);
            end
            function tf=recIsSubTypeObj(obj,givenSuperType)
                sprType=obj.superType;
                if sprType==givenSuperType
                    tf=true;
                else
                    if~sprType.isBuiltin


                        tf=recIsSubTypeObj(sprType,givenSuperType);
                    else
                        tf=false;
                    end
                end
            end
        end

        function baseTypeName=getBaseTypeName(typeNameOrEnum)





            reqData=slreq.data.ReqData.getInstance;
            mfLinkType=reqData.getLinkType(typeNameOrEnum);



            while true
                if slreq.app.LinkTypeManager.isUnresolved(mfLinkType)
                    baseTypeName='Unset';
                    return;
                end

                if mfLinkType.isBuiltin
                    break;
                else
                    mfLinkType=mfLinkType.superType;
                end
            end

            baseTypeName=mfLinkType.typeName;
        end

        function tf=isUnresolved(mfLinkType)


            if~isempty(mfLinkType.superType)
                tf=strcmp(mfLinkType.superType.typeName,'Unset')&&~mfLinkType.isBuiltin;
            else

                tf=false;
            end
        end


        function linkList=filterLinksByType(type,isStrict,allLinkList)




            linkList=slreq.data.Link.empty();
            for n=1:length(allLinkList)
                eachLink=allLinkList(n);
                if(isStrict&&strcmp(eachLink.type,type))||...
                    (~isStrict&&slreq.app.LinkTypeManager.isa(eachLink.type,type,eachLink.getLinkSet()))
                    linkList(end+1)=eachLink;%#ok<AGROW>
                end
            end
        end

        function tf=affectImplementationStatus(linkSet,oldType,newType)

            affPreImplement=slreq.app.LinkTypeManager.isa(oldType,slreq.custom.LinkType.Implement,linkSet);
            affCurImplement=slreq.app.LinkTypeManager.isa(newType,slreq.custom.LinkType.Implement,linkSet);
            tf=affCurImplement||affPreImplement;
        end

        function tf=affectVerificationStatus(linkSet,oldType,newType)
            affPreVerification=slreq.app.LinkTypeManager.isa(oldType,slreq.custom.LinkType.Verify,linkSet)||...
            slreq.app.LinkTypeManager.isa(oldType,slreq.custom.LinkType.Confirm,linkSet);

            affCurVerification=slreq.app.LinkTypeManager.isa(newType,slreq.custom.LinkType.Verify,linkSet)||...
            slreq.app.LinkTypeManager.isa(newType,slreq.custom.LinkType.Confirm,linkSet);

            tf=affPreVerification||affCurVerification;
        end
    end
end
