


classdef SyncApi<handle


    properties(SetAccess=private)
modelH
srgSys
reqSys
modIdStr
copyFromSrgToSl
copyFromSlToSrg
purgeSurrogate
purgeSimulink
detailLevel
saveModel
saveSurrogate
    end

    properties
isTesting
    end

    methods


        function syncObj=SyncApi(model,id,reqsysLabels)
            syncObj.modelH=model;
            syncObj.modIdStr=id;
            syncObj.srgSys=reqsysLabels.srgSys;
            syncObj.reqSys=reqsysLabels.reqSys;
            syncObj.copyFromSrgToSl=0;
            syncObj.copyFromSlToSrg=0;
            syncObj.purgeSurrogate=0;
            syncObj.purgeSimulink=0;
            syncObj.detailLevel=1;
            syncObj.saveModel=0;
            syncObj.saveSurrogate=0;
        end


        function setSyncOptions(this,detailLevel,...
            copyFromSlToSrg,copyFromSrgToSl,...
            purgeSurrogate,purgeSimulink,...
            saveModel,saveSurrogate)
            this.copyFromSrgToSl=copyFromSrgToSl;
            this.copyFromSlToSrg=copyFromSlToSrg;
            this.purgeSurrogate=purgeSurrogate;
            this.purgeSimulink=purgeSimulink;
            this.detailLevel=detailLevel;
            this.saveModel=saveModel;
            this.saveSurrogate=saveSurrogate;
        end


        function hasReq=hasSysReq(this,reqStrs)
            cnt=length(reqStrs);
            hasReq=false(cnt,1);
            for i=1:cnt
                if~isempty(reqStrs{i})
                    try
                        reqCell=eval(reqStrs{i});
                        if~isempty(reqCell)
                            isDoors=strcmp(reqCell(:,1),this.reqSys);
                            hasReq(i)=any(isDoors);
                        end
                    catch Mex %#ok
                    end
                end
            end
        end

        function surrReq=makeSrgReq(this,itemId)

            if strcmp(this.srgSys,'doors')
                description=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:DoorsSurrogateItem'));
            else
                description=getString(message('Slvnv:reqmgt:Doors:getDialogSchema:SurrogateItem',upper(this.srgSys)));
            end
            surrReq=rmi.reqstruct(this.modIdStr,num2str(itemId),...
            description,'',false,this.srgSys);
        end

    end

    methods(Static)

    end


    methods(Abstract)
        openSrgModule(this)
        numericIds=idStrToNum(this,strIds)
        markDeleted(this,deletedIds)
        ids=srgIds(this,reqStrings)
        newLinkStr=propagateChanges(this,origReqs,doorsId,doorsLinkInfo)
        firstNewId=updateModule(this,mods,dmDeletedIds)
        reqs=updateSrgLink(this,reqs,doorsId)
        updateSrgLinks(this,surrogateLinkUpdates)
        updateModuleProps(this)
        myReqs=updateDocNames(this,myReqs)
        slReqs=linkinfoToReqs(surrlinksInfo)
    end

end
