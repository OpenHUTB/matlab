function[result,deferredNotification]=loadLinkSet(artifact,mustExist)



    stopAction=slreq.app.MainManager.startUserAction();%#ok<NASGU> 

    if nargin<2
        mustExist=true;
    end

    result=false;
    deferredNotification={};


    [artPath,artBase,artExt]=fileparts(artifact);
    if isempty(artPath)||isempty(artExt)
        artifact=which(artifact);
        [~,~,artExt]=fileparts(artifact);
    end


    hasSharedSlreq=slreq.internal.isSharedSlreqInstalled();
    reqDataExists=slreq.data.ReqData.exists();


    if reqDataExists
        checkLinkSet=slreq.data.ReqData.getInstance.getLinkSet(artifact);
        if~isempty(checkLinkSet)
            result=true;
            if hasSharedSlreq
                registerArtifactLoadWithLinkSetManager(artifact);
                registerSourceReferenceWithLinkSetManager(checkLinkSet);
            end
            notifyEditorIfOpen();
            return;
        end
    end

    isSimulinkMdl=any(strcmpi(artExt,{'.mdl','.slx'}));

    [linkFilePath,isDefault]=slreq.getLinkFilePath(artifact);

    [lnkPath,lnkName,lnkExt]=fileparts(linkFilePath);

    linkSet=[];

    if strcmp(lnkExt,'.req')



        if exist(linkFilePath,'file')==2
            result=slreq.utils.loadDotReq(artifact,linkFilePath);

            if result&&isSimulinkMdl
                rqFile=[lnkName,lnkExt];
                slmxFile=rmimap.StorageMapper.defaultLinkPath('',lnkName,artExt);
                deferredNotification={message('Slvnv:slreq:DataToSaveInSlmx',rqFile,slmxFile),message('Slvnv:slreq:SaveNow')};
            end
        else

            error(message('Slvnv:slreq:MissingDataFile',linkFilePath));
        end

    else

        if exist(linkFilePath,'file')==2
            r=slreq.data.ReqData.getInstance;
            try
                linkSet=r.loadLinkSet(artifact,linkFilePath);
            catch ex
                warning(ex.identifier,strrep(ex.message,'\','\\'));






            end

            result=~isempty(linkSet);
            if result&&slreq.utils.isEmbeddedLinkSet(linkFilePath)

                linkSet.updateEmbeddedLinksetLocation(linkFilePath);
            end

        elseif~isDefault
            if mustExist
                error(message('Slvnv:slreq:MissingDataFile',linkFilePath));
            else
                rmiut.warnNoBacktrace('Slvnv:slreq:MissingDataFile',linkFilePath);
            end

        else

            dotReqFilePath=rmimap.StorageMapper.legacyReqPath(lnkPath,artBase);
            if exist(dotReqFilePath,'file')==2
                result=slreq.utils.loadDotReq(artifact,dotReqFilePath);

                if isSimulinkMdl
                    rqFile=[artBase,'.req'];
                    slmxFile=rmimap.StorageMapper.defaultLinkPath('',artBase,artExt);
                    deferredNotification={message('Slvnv:slreq:DataToSaveInSlmx',rqFile,slmxFile),message('Slvnv:slreq:SaveNow')};
                end
            end
        end
    end

    if result

        if isempty(linkSet)
            linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifact);
        end

        if any(strcmp(linkSet.domain,{'linktype_rmi_matlab','linktype_rmi_simulink'}))


            if slreq.utils.isArtifactLoaded(linkSet.domain,artifact)
                textItemsIds=linkSet.getTextItemIds();
                for i=1:length(textItemsIds)
                    textItem=linkSet.getTextItem(textItemsIds{i});
                    try
                        slreq.utils.verifyTextRanges(textItem);
                    catch ex
                        if strcmp(ex.identifier,'Simulink:utility:SIDSyntaxError')||...
                            strcmp(ex.identifier,'Simulink:utility:objectDestroyed')
                            [~,aName]=fileparts(artifact);
                            rmiut.warnNoBacktrace('Slvnv:slreq:InvalidSID',textItem.id,aName);


                            slreq.data.ReqData.getInstance.removeTextItem(textItem);
                        else
                            rethrow(ex);
                        end
                    end
                end

            end

        elseif strcmp(linkSet.domain,'linktype_rmi_data')







            if rmi.isInstalled()
                slreq.internal.delayedLinksetLoader('remove',linkSet.artifact);
            end
            rmide.registerCallback();
        end

        if hasSharedSlreq

            registerArtifactLoadWithLinkSetManager(artifact);
        end

    elseif hasSharedSlreq&&reqDataExists

        if~strcmpi(artExt,'.m')



            registerArtifactLoadWithLinkSetManager(artifact);


        end
    end
end

function registerArtifactLoadWithLinkSetManager(artifactFullFilePath)






    lsm=slreq.linkmgr.LinkSetManager.getInstance;
    lsm.onArtifactLoad(artifactFullFilePath);
end

function registerSourceReferenceWithLinkSetManager(dataLinkSet)





    lsm=slreq.linkmgr.LinkSetManager.getInstance;
    lsm.addReference(dataLinkSet,dataLinkSet.artifact);
end

function notifyEditorIfOpen()


    if slreq.app.MainManager.hasEditor()
        appMgr=slreq.app.MainManager.getInstance();
        appMgr.update(false);
    end
end

