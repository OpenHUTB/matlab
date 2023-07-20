


classdef SyncApiDoors<rmisync.SyncApi

    properties

    end

    methods

        function syncObj=SyncApiDoors(model,settings)

            reqsysLabels.reqSys='linktype_rmi_doors';
            reqsysLabels.srgSys='doors';
            syncObj=syncObj@rmisync.SyncApi(model,settings.surrogateId,reqsysLabels);

            syncObj.setSyncOptions(settings.detaillevel,...
            settings.updateLinks*settings.slLinks2Doors,...
            settings.updateLinks*settings.doorsLinks2sl,...
            settings.purgeDoors,settings.purgeSimulink,...
            settings.savemodel,settings.savesurrogate);
        end


        function numericIds=idStrToNum(this,strIds)
            try
                prefix=rmidoors.getModuleAttribute(this.modIdStr,'Prefix');
            catch %#ok<CTCH> % probably doors_test_mode, assume no prefix
                if this.isTesting
                    prefix=rmisync.syncTestPrefix(this.modelH);
                else
                    prefix='';
                end
            end

            if isempty(prefix)
                numericIds=str2double(strIds);
            else
                strippedIds=strrep(strIds,prefix,'');
                numericIds=str2double(strippedIds);
            end
        end

        function openSrgModule(this)
            rmidoors.show(this.modIdStr,-1,true);
        end

        function markDeleted(this,deletedIds)
            for objNum=deletedIds(:)'
                if this.purgeSurrogate
                    rmidoors.removeLinks(this.modIdStr,objNum);
                end
                rmidoors.setObjAttribute(this.modIdStr,objNum,'Block Deleted?','true');
            end
            rmidoors.refreshModule(this.modIdStr);
        end

        function doorsIds=srgIds(this,reqStrs)
            total_strings=length(reqStrs);
            doorsIds=-1*ones(1,total_strings);
            for i=1:total_strings
                reqs=rmi.parsereqs(reqStrs{i});
                if~isempty(reqs)
                    isSurr=strcmp({reqs(:).reqsys},this.srgSys);
                    ids={reqs(isSurr).id};
                    if~isempty(ids)



                        doorsIds(i)=str2double(strtok(ids{1},'#'));
                    end
                end
            end
        end

        function firstNewId=updateModule(this,mods,dmDeletedIds)
            if~this.isTesting
                fileName=tempname;
                hApp=rmidoors.comApp('get');
            else
                fileName=fullfile(pwd,'actual_surrogate_updates.csv');
            end




            if~isempty(mods)&&strcmp(get(0,'Language'),'en_US')
                mods(:,4)=stripExtendedCharacters(mods(:,4));
                mods(:,5)=stripExtendedCharacters(mods(:,5));
            end

            escFileName=strrep(fileName,'\','\\');
            reqmgt('csvWrite',fileName,mods);

            if~this.isTesting
                rmidoors.invoke(hApp,['dmiUpdateModuleFromFile_("',this.modIdStr,'","',escFileName,'")']);
            end


            [capture,dirName]=rmisync.syncTestCapture();
            if capture
                modelName=get_param(this.modelH,'Name');
                newFileName=fullfile(dirName,[modelName,'_surrogate_updates.csv']);
                copyfile(fileName,newFileName);
            end

            if~this.isTesting
                delete(fileName);
            end

            if this.isTesting
                [~,dirName]=rmisync.syncTestMode();
                modelName=get_param(this.modelH,'Name');
                cachedVarFile=fullfile(dirName,[modelName,'_update_data.mat']);
                s=load(cachedVarFile);
                firstNewId=s.firstNewId;
            else
                msg=hApp.Result;
                if~isempty(regexp(msg,'DMI Error:','once'))
                    error(message('Slvnv:reqmgt:DoorsApiError',msg));
                else
                    firstNewId=eval(msg);
                end
                if~isempty(dmDeletedIds)
                    this.markDeleted(dmDeletedIds);
                end
            end

            function objNames=stripExtendedCharacters(objNames)
                for k=1:length(objNames)
                    oneName=objNames{k};
                    isBadChar=(double(oneName)>255);
                    if any(isBadChar)
                        oneName(isBadChar)='?';
                        objNames{k}=oneName;
                    end
                end
            end
        end

        function newLinkStr=propagateChanges(this,origReqs,doorsId,doorsLinkInfo)


            doorsLinkInfo=rmiut.filterChars(doorsLinkInfo,false,true);
            if isempty(doorsLinkInfo)||strncmp(doorsLinkInfo,'{}',2)
                doorsReqs=[];
            else
                doorsReqs=this.linkinfoToReqs(doorsLinkInfo);
            end


            if~isempty(origReqs)
                slIsDoors=strcmp('linktype_rmi_doors',{origReqs.reqsys});
            else
                slIsDoors=[];
            end

            if isempty(slIsDoors)||~any(slIsDoors)


                if this.purgeSurrogate&&~isempty(doorsReqs)
                    rmidoors.removeLinks(this.modIdStr,doorsId);
                    rmidoors.refreshModule(this.modIdStr);
                end
                newLinkStr='';

            else


                if isempty(doorsReqs)
                    if any(slIsDoors)
                        if this.isTesting
                            myReqs=origReqs(slIsDoors);
                        else
                            myReqs=rmidoors.SyncApiDoors.removePrefixFromIds(origReqs(slIsDoors));
                        end
                        newLinkStr=this.protectedReqsToStr(myReqs,doorsId);
                    else
                        newLinkStr='';
                    end

                else


                    docsInSl=strtok({origReqs(slIsDoors).doc});
                    [uniqueModules,~,modIdx]=unique(docsInSl);
                    isThisModuleInSl=false(1,length(origReqs));
                    isSlMatchedInDoors=false(1,length(origReqs));
                    isDoorsMatchedInSl=false(1,length(doorsReqs));
                    isDoorsChecked=false(1,length(doorsReqs));

                    for i=1:length(uniqueModules)
                        thisModule=uniqueModules(i);
                        isThisModuleInSl(slIsDoors)=(modIdx==i);
                        idsInSl={origReqs(isThisModuleInSl).id};

                        isSameModuleInDoors=strcmp(thisModule,{doorsReqs.doc});
                        idsInDoors={doorsReqs(isSameModuleInDoors).id};
                        isDoorsChecked=isDoorsChecked|isSameModuleInDoors;


                        [~,matchedSlIndicesForThisModule,matchedDoorsIndicesForThisModule]=intersect(idsInSl,idsInDoors);
                        matchedForThisModule=false(1,length(idsInSl));
                        matchedForThisModule(matchedSlIndicesForThisModule)=true;
                        isSlMatchedInDoors(find(isThisModuleInSl))=matchedForThisModule;%#ok


                        matchedForThisModule=false(1,length(idsInDoors));
                        matchedForThisModule(matchedDoorsIndicesForThisModule)=true;
                        isDoorsMatchedInSl(find(isSameModuleInDoors))=matchedForThisModule;%#ok
                    end


                    if any(slIsDoors&~isSlMatchedInDoors)
                        if this.isTesting
                            myReqs=origReqs(slIsDoors&~isSlMatchedInDoors);
                        else
                            myReqs=rmidoors.SyncApiDoors.removePrefixFromIds(origReqs(slIsDoors&~isSlMatchedInDoors));
                        end
                        newLinkStr=this.protectedReqsToStr(myReqs,doorsId);
                    else
                        newLinkStr='';
                    end


                    if this.purgeSurrogate

                        isUnmatched=~isDoorsChecked|~isDoorsMatchedInSl;
                        for idx=find(isUnmatched)
                            rmidoors.removeLinks(this.modIdStr,doorsId,doorsReqs(idx).doc,doorsReqs(idx).id);
                        end
                    end
                end
            end

        end
        function linkStr=protectedReqsToStr(this,reqs,surrId)
            try
                linkStr=rmisync.reqsToCsvStr(reqs);
            catch Mex
                winfo=warning('off','backtrace');
                warning([this.modIdStr,':',num2str(surrId),' ',Mex.message]);
                warning(winfo.state,'backtrace');
                linkStr='';
            end
        end

        function reqs=updateSrgLink(this,reqs,doorsId)
            if isempty(reqs)
                reqs=this.makeSrgReq(doorsId);
            else
                isSurr=strcmp(this.srgSys,{reqs.reqsys});
                if any(isSurr)
                    surrLinks=reqs(isSurr);
                    if~strcmp(strtok(surrLinks(1).doc),this.modIdStr)||~strcmp(surrLinks(1).id,num2str(doorsId))
                        reqs(isSurr)=this.makeSrgReq(doorsId);
                    end
                else
                    reqs=[this.makeSrgReq(doorsId);reqs];
                end
            end
        end

        function updateSrgLinks(this,surrogateLinkUpdates)
            if~isempty(surrogateLinkUpdates)
                hApp=rmidoors.comApp('get');
                cmdPrefix=[' dmiObjCreateLinks_("',this.modIdStr,'",'];
                for objIdx=1:size(surrogateLinkUpdates,1)
                    cmdStr=[cmdPrefix,num2str(surrogateLinkUpdates{objIdx,1}),',"',surrogateLinkUpdates{objIdx,2},'")'];
                    rmidoors.invoke(hApp,cmdStr);
                end



                rmidoors.refreshModule(this.modIdStr,hApp);
            end
        end

        function updateModuleProps(this)
            hApp=rmidoors.comApp('get');
            rmidoors.invoke(hApp,['dmiUpdateAttibutes("',this.modIdStr,'")']);

            modelVer=num2str(get_param(this.modelH,'modelVersion'));
            rmidoors.setModuleAttribute(this.modIdStr,'Simulink model version',modelVer);

            d=dir(get_param(this.modelH,'fileName'));
            timeStamp=d.date;
            rmidoors.setModuleAttribute(this.modIdStr,'Simulink file timestamp',timeStamp);

            if this.saveSurrogate
                rmidoors.saveModule(this.modIdStr);
            end
        end

        function myReqs=updateDocNames(this,myReqs)
            for i=1:length(myReqs)
                if strcmp(myReqs(i).reqsys,this.reqSys)
                    doc=strtok(myReqs(i).doc);
                    try
                        module_name=rmidoors.getModuleAttribute(doc,'FullName');
                        myReqs(i).doc=sprintf('%s (%s)',doc,module_name);
                    catch %#ok<CTCH>
                    end
                end
            end
        end

        function reqs=linkinfoToReqs(this,linkInfo)
            rawLinkInfo=eval(linkInfo);
            rawLinkInfo(:,3)=strcat('#',rawLinkInfo(:,3));
            reqs=rmi.reqstruct(rawLinkInfo(:,2),...
            rawLinkInfo(:,3),...
            rawLinkInfo(:,1),...
            {''},...
            {true},...
            {this.reqSys});

            for i=1:length(reqs)
                if~isempty(rmidoors.customLabel())
                    reqs(i).description=rmidoors.customLabel(reqs(i).doc,reqs(i).id(2:end));
                end
                if~this.isTesting
                    prefix=rmidoors.getModulePrefix(reqs(i).doc);
                    if~isempty(prefix)
                        reqs(i).id=['#',prefix,reqs(i).id(2:end)];
                    end
                end
            end
        end

    end

    methods(Static)
        function reqs=removePrefixFromIds(reqs)
            for i=1:length(reqs)
                req=reqs(i);
                try
                    prefix=rmidoors.getModulePrefix(req.doc);
                    if isempty(prefix)
                        continue;
                    else
                        reqs(i).id=strrep(req.id,prefix,'');
                    end
                catch


                    reqs(i).id=regexprep(reqs(i).id,'^#\D+','#');
                end
            end
        end
    end
end




