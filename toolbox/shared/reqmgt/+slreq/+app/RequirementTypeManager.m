classdef RequirementTypeManager<handle



    methods(Static)

        function[displayNames,isResolved]=getAllDisplayNames(dasReqSet)
            allMFReqTypes=slreq.data.ReqData.getInstance.getAllRequirementTypes();
            displayNames=cell(1,numel(allMFReqTypes));
            isResolved=true(1,numel(allMFReqTypes));
            for n=1:length(allMFReqTypes)
                mfReqType=allMFReqTypes(n);
                if mfReqType.isBuiltin
                    displayNames{n}=getString(message(['Slvnv:slreq:RequirementType',mfReqType.name]));
                elseif slreq.app.RequirementTypeManager.isUnresolved(mfReqType)
                    displayNames{n}=getString(message('Slvnv:slreq:UnresolvedType',mfReqType.name));
                    isResolved(n)=false;
                else
                    displayNames{n}=mfReqType.name;
                end
            end
            if nargin>0
                allStereotypes=dasReqSet.getAllStereotypes();
                displayNames=[displayNames,allStereotypes];
            end
        end

        function str=getDisplayName(typeNameOrEnum)
            if isa(typeNameOrEnum,'slreq.custom.RequirementType')&&isenum(typeNameOrEnum)

                typeName=typeNameOrEnum.getTypeName;
            elseif ischar(typeNameOrEnum)
                typeName=typeNameOrEnum;
            else
                assert(false,'Invalid input specified')
            end

            reqData=slreq.data.ReqData.getInstance;
            mfReqType=reqData.getRequirementType(typeName);
            if mfReqType.isBuiltin
                str=getString(message(['Slvnv:slreq:RequirementType',mfReqType.name]));
            elseif slreq.app.RequirementTypeManager.isUnresolved(mfReqType)
                str=getString(message('Slvnv:slreq:UnresolvedType',mfReqType.name));
            else
                str=mfReqType.name;
            end
        end

        function id=getIdentifierFromDisplayName(displayName)
            allMFReqTypes=slreq.data.ReqData.getInstance.getAllRequirementTypes();
            for n=1:length(allMFReqTypes)
                mfReqType=allMFReqTypes(n);
                if mfReqType.isBuiltin
                    thisDisplayName=getString(message(['Slvnv:slreq:RequirementType',mfReqType.name]));
                    if strcmp(thisDisplayName,displayName)
                        id=mfReqType.name;
                        return;
                    end
                end
            end
            id=displayName;
        end

        function tf=isa(subTypeNameOrEnum,superTypeNameOrEnum,reqSet)
            if nargin>2
                if slreq.internal.ProfileReqType.isProfileStereotype(reqSet,subTypeNameOrEnum)
                    tf=slreq.internal.ProfileReqType.isa(subTypeNameOrEnum,superTypeNameOrEnum);
                    return
                end
            end

            reqData=slreq.data.ReqData.getInstance;
            if isempty(subTypeNameOrEnum)
                tf=false;
                return;
            end
            subType=reqData.getRequirementType(subTypeNameOrEnum);
            superType=reqData.getRequirementType(superTypeNameOrEnum);
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
            mfReqType=reqData.getRequirementType(typeNameOrEnum);



            while true
                if slreq.app.RequirementTypeManager.isUnresolved(mfReqType)
                    baseTypeName=char(slreq.custom.RequirementType.Unset);
                    return;
                end

                if mfReqType.isBuiltin
                    break;
                else
                    mfReqType=mfReqType.superType;
                end
            end

            baseTypeName=mfReqType.name;
        end

        function tf=isUnresolved(mfReqType)


            if~isempty(mfReqType.superType)
                tf=strcmp(mfReqType.superType.name,'Unset')&&~mfReqType.isBuiltin;
            else

                tf=false;
            end
        end

        function tf=isUnresolvedType(typeNameOrEnum,reqSet)
            if nargin>1
                isStereotype=slreq.internal.ProfileReqType.isProfileStereotype(reqSet,typeNameOrEnum);
                if isStereotype
                    tf=false;
                    return;
                end
            end

            reqData=slreq.data.ReqData.getInstance;
            mfReqType=reqData.getRequirementType(typeNameOrEnum);
            tf=slreq.app.RequirementTypeManager.isUnresolved(mfReqType);
        end

        function checkIfKnownType(typeNameOrEnum)


            reqData=slreq.data.ReqData.getInstance();
            try

                mfReqType=reqData.getRequirementType(typeNameOrEnum);%#ok<NASGU>
            catch ex

                throwAsCaller(ex);
            end
        end

        function showNotificationOnInformationalTypeChange()


            suggestionCount=rmisl.internalConfigVal('InfoTypeSuggestionCount');
            if isempty(suggestionCount)
                suggestionCount=0;
            end

            if suggestionCount<3

                suggestionId='Slvnv:slreq:NotificationOnInformationalType';
                suggestionText=getString(message(suggestionId));
                appmgr=slreq.app.MainManager.getInstance();
                currentView=appmgr.getCurrentView;
                if isa(currentView,'slreq.internal.gui.Editor')
                    appmgr.reqRoot.showSuggestion(suggestionId,suggestionText)
                elseif isa(currentView,'slreq.gui.ReqSpreadSheet')
                    rmisl.notify(currentView.getCurrentModelH,message(suggestionId),message('Slvnv:slreq:NotificationOnInformationalTypeMoreInfo'));
                end
                rmisl.internalConfigVal('InfoTypeSuggestionCount',suggestionCount+1);
            end
        end
    end
end
