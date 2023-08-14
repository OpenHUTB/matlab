classdef RequirementLinkCopyHandler<handle





    methods(Static)
        function copyRequirements(srcUUID,targetUUID,srcModelName,tgtModelName)


            loadedSystems=find_system('Type','block_diagram');
            if~ismember(loadedSystems,srcModelName)

                return;
            end
            obj=sysarch.RequirementLinkCopyHandler;
            obj.doCopyRequirements(srcUUID,targetUUID,srcModelName,tgtModelName);
        end

        function copyPortRequriementsOnModelBlock(uuidStruct,srcModelName,tgtModelName)


            loadedSystems=find_system('Type','block_diagram');
            if~ismember(loadedSystems,srcModelName)

                return;
            end
            obj=sysarch.RequirementLinkCopyHandler;
            for m=1:numel(uuidStruct)
                targetUUID=uuidStruct(m).targetID;
                srcUUID=uuidStruct(m).srcID;
                obj.doCopyRequirements(srcUUID,targetUUID,srcModelName,tgtModelName);
            end
        end
    end

    methods(Access=private)
        function doCopyRequirements(~,srcUUID,targetUUID,srcModelName,tgtModelName)
            zcTgtMFModel=get_param(tgtModelName,'SystemComposerMF0Model');
            tgtElem=zcTgtMFModel.findElement(targetUUID);
            reqData=slreq.data.ReqData.getInstance;
            src.id=['ZC:',srcUUID];
            src.artifact=get_param(srcModelName,'FileName');
            reqLinks=reqData.getOutgoingLinks(src);
            tgtElem=sysarch.getLinkableCompositionPort(tgtElem);
            for i=1:numel(reqLinks)
                slreq.createLink(tgtElem,reqLinks(i).destStruct);
            end
        end
    end
end
