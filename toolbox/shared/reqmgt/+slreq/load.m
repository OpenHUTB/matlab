

























































function[linkReqSet,embeddedReqSet]=load(artifact,forceResolveProfile)

    if nargin==1

        forceResolveProfile=false;
    end

    linkReqSet=[];
    embeddedReqSet=[];

    artifact=convertStringsToChars(artifact);



    [fDir,fName,fExt]=fileparts(artifact);
    if isempty(fDir)


        matched=findByShortName(fName,fExt);
        if~isempty(matched)
            linkReqSet=slreq.utils.dataToApiObject(matched);

            if strcmp(fExt,'.slx')
                embeddedReqSet=getLoadedEmbeddedReqSet(fName);
            end
            return;
        else
            if strcmp(fExt,'.slx')
                embeddedReqSet=getLoadedEmbeddedReqSet(fName);
                if~isempty(embeddedReqSet)
                    return;
                end
            end
        end
        loadedChecked=true;
    else
        loadedChecked=false;
    end



    if isempty(fExt)


        onMLPath=which([artifact,'.slreqx']);
        if~isempty(onMLPath)
            artifactPath=onMLPath;
        else
            artifactPath=which(artifact);
        end
    elseif~rmiut.isCompletePath(artifact)

        artifactPath=slreq.uri.ResourcePathHandler.getFullPath(artifact,pwd);
    else
        artifactPath=artifact;
    end


    if isempty(artifactPath)||~isfile(artifactPath)
        error(message('Slvnv:slreq_import:FileNotFound',artifact));
    else
        [~,~,fExt]=fileparts(artifactPath);
    end



    dataObj=[];



    if~loadedChecked
        switch fExt
        case '.slreqx'
            dataObj=findReqSetByFilepath(artifactPath);
        case '.slmx'
            dataObj=findLinkSetByFilepath(artifactPath);
        case '.req'

            dataObj=findLinkSetByName(fName,fExt);
        otherwise
        end
        if~isempty(dataObj)
            linkReqSet=slreq.utils.dataToApiObject(dataObj);
            return;
        end
    end




    if slreq.internal.isSharedSlreqInstalled()
        initLinkSetManagerIfNeeded();
    end



    if strcmpi(fExt,'.slreqx')
        reqProfileChecker=slreq.internal.ReqProfileChecker();
        reqProfileChecker.checkProfiles(artifact);

        if~isempty(reqProfileChecker.prfChecker)&&~isempty(reqProfileChecker.prfNamespace)
            if reqProfileChecker.prfChecker.isProfileOutdated&&~forceResolveProfile


                error(message('Slvnv:slreq:ProfileOutdated'));
            end
        end
    end

    try
        switch fExt
        case '.slreqx'
            dataObj=slreq.data.ReqData.getInstance.loadReqSet(artifactPath,[],...
            true,reqProfileChecker.prfChecker,reqProfileChecker.prfNamespace);
        case '.slmx'
            dataObj=slreq.data.ReqData.getInstance.loadLinkSet([fName,'.slmx'],artifactPath);
            if~isempty(dataObj)&&rmi.isInstalled()
                slreq.internal.delayedLinksetLoader('remove',dataObj.artifact);
            end
        case '.req'



            if slreq.utils.loadDotReq(artifact,artifactPath)
                dataLinkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
                dataObj=dataLinkSets(end);
            end
        otherwise




            if strcmp(fExt,'.slx')



                embeddedReqSet=loadEmbeddedReqSet(artifactPath);
            end

            if slreq.utils.loadLinkSet(artifactPath,true)
                dataObj=slreq.utils.getLinkSet(artifactPath);
            end

            if isempty(embeddedReqSet)&&isempty(dataObj)
                error(message('Slvnv:rmiml:ReqFileNotFound',artifact));
            end

        end
    catch ex
        throw(ex);
    end


    if~isempty(dataObj)
        linkReqSet=slreq.utils.dataToApiObject(dataObj);

        if strcmpi(fExt,'.slreqx')
            if~isempty(reqProfileChecker.prfChecker)&&~isempty(reqProfileChecker.prfNamespace)
                slreq.internal.ProfileReqType.resolveProfiles(dataObj,reqProfileChecker.prfChecker,reqProfileChecker.prfNamespace);
            end
        end
    end
end



function found=findByShortName(fName,fExt)
    found=[];
    if isempty(fExt)||strcmp(fExt,'.slreqx')
        found=findReqSetByName(fName);
    end
    if isempty(found)&&~strcmp(fExt,'.slreqx')
        found=findLinkSetByName(fName,fExt);
    end
end

function found=findReqSetByName(fName)
    found=[];
    dataReqSets=slreq.data.ReqData.getInstance.getLoadedReqSets();
    matched=strcmp({dataReqSets.name},fName);
    if any(matched)
        found=dataReqSets(matched);
    end
end

function found=findLinkSetByName(fName,fExt)
    found=[];
    dataLinkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
    if strcmp(fExt,'.slmx')

        matched=endsWith({dataLinkSets.filepath},[fName,'.slmx']);
    else

        matched=strcmp({dataLinkSets.name},fName);
    end
    if any(matched)
        found=dataLinkSets(matched);
    end
end



function found=findReqSetByFilepath(fPath)
    dataReqSets=slreq.data.ReqData.getInstance.getLoadedReqSets();
    matched=rmiut.cmp_paths({dataReqSets.filepath},fPath);
    if any(matched)
        found=dataReqSets(matched);
    else
        found=[];
    end
end

function found=findLinkSetByFilepath(fPath)
    dataLinkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
    matched=rmiut.cmp_paths({dataLinkSets.filepath},fPath);
    if any(matched)
        found=dataLinkSets(matched);
    else
        found=[];
    end
end



function initLinkSetManagerIfNeeded()







    lsm=slreq.linkmgr.LinkSetManager.getInstance();
    lsm.scanMATLABPathOnSlreqInit(lsm.METADATA_SCAN_INIT_MODE_API);
end


function embeddedReqSet=loadEmbeddedReqSet(artifactPath)
    embeddedReqSet=[];
    [~,mdlName,~]=fileparts(artifactPath);
    isModelLoaded=dig.isProductInstalled('Simulink')&&bdIsLoaded(mdlName);
    modelHandle=load_system(artifactPath);
    reqsetName=slreq.data.ReqData.getInstance.getSfReqSet(modelHandle);
    if~isempty(reqsetName)
        dObj=slreq.data.ReqData.getInstance.getReqSet(reqsetName);
        embeddedReqSet=slreq.utils.dataToApiObject(dObj);
    else

        if~isModelLoaded
            close_system(artifactPath,0);
        end
    end
end

function embeddedReqSet=getLoadedEmbeddedReqSet(fName)

    embeddedReqSet=[];
    if dig.isProductInstalled('Simulink')&&bdIsLoaded(fName)
        mdlHandle=get_param(fName,'Handle');
        reqsetName=slreq.data.ReqData.getInstance.getSfReqSet(mdlHandle);
        if~isempty(reqsetName)
            eReqSet=findByShortName(reqsetName,'.slreqx');
            embeddedReqSet=slreq.utils.dataToApiObject(eReqSet);
        end
    end
end
