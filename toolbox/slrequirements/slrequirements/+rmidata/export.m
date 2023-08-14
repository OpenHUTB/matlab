function[total_linked,total_links,allObjs]=export(model,saveFiles,destPath)




    total_linked=0;
    total_links=0;
    allObjs={};

    if nargin<1
        model=bdroot;
        if isempty(model)
            disp(getString(message('Slvnv:rmidata:export:NoCurrentSimulinkModelExit')));
            return;
        else
            disp(getString(message('Slvnv:rmidata:export:ExportingLinksFrom',model)));
        end
        modelH=get_param(model,'Handle');

    elseif ischar(model)
        model=convertStringsToChars(model);
        load_system(model);
        modelH=get_param(model,'Handle');
    else
        modelH=model(1);
        model=get_param(modelH,'Name');
    end

    if nargin<2
        saveFiles=true;
    end

    if rmidata.isExternal(modelH)


        mdlFilePath=get_param(modelH,'Filename');
        if nargin<3
            destPath=rmimap.StorageMapper.getDefaultStorageName(mdlFilePath);
        elseif isa(destPath,'string')
            destPath=convertStringsToChars(destPath);
        end

        rmidata.save(modelH,destPath);
        rmisl.notify(modelH,'');
        if saveFiles
            save_system(modelH);
        end
        linkSet=slreq.utils.getLinkSet(mdlFilePath,'linktype_rmi_simulink');
        if~isempty(linkSet)
            total_linked=numel(linkSet.getLinkedItems());
            total_links=numel(linkSet.getAllLinks());

        end

    else

        [total_linked,total_links,allObjs]=migrateRmiData(modelH,model,saveFiles);
    end
end

function[total_linked,total_links,allObjs]=migrateRmiData(modelH,model,saveFiles)

    total_linked=0;
    total_links=0;


    if strcmp(get_param(modelH,'hasReqInfo'),'off')
        disp(getString(message('Slvnv:rmidata:export:NoEmbeddedRequirementsLinks',model)));
    else






        storageSettings=rmi.settings_mgr('get','storageSettings');
        origStorageMode=storageSettings.external;
        storageSettings.external=~isempty(get_param(modelH,'Filename'));
        rmi.settings_mgr('set','storageSettings',storageSettings);




        filterSettings=rmi.settings_mgr('get','filterSettings');
        if~isfield(filterSettings,'linkedOnly')
            filterSettings.linkedOnly=true;
        end
        originalFilters=filterSettings;
        filterSettings.enabled=false;
        filterSettings.linkedOnly=false;
        rmi.settings_mgr('set','filterSettings',filterSettings);


        myCleanup(origStorageMode,originalFilters);
        w=onCleanup(@myCleanup);



        activeHarness=Simulink.harness.internal.getActiveHarness(modelH);
        if~isempty(activeHarness)
            error(message('Slvnv:rmidata:export:CantExportWhenHarnessOpen',activeHarness.name));
        end

        harnesses=Simulink.harness.find(modelH);
        hasHarnesses=~isempty(harnesses)&&(slfeature('ReqLinksForExtHarness')||~Simulink.harness.internal.isSavedIndependently(modelH));

        [total_linked,total_links,allObjs,mpCount]=exportRMIData(model,hasHarnesses,total_linked,total_links);


        if hasHarnesses
            for i=1:length(harnesses)
                harnessName=harnesses(i).name;


                ownerPath=harnesses(i).ownerFullPath;
                Simulink.harness.open(ownerPath,harnessName,'CreateOpenContext',true,'ReuseWindow',true);


                [total_linked,total_links,moreObjs,mpMore]=exportRMIData(harnessName,ownerPath,total_linked,total_links);
                mpCount=mpCount+mpMore;
                if~isempty(moreObjs)
                    allObjs=[allObjs,moreObjs];%#ok<AGROW>
                end


                close_system(harnessName,0);
            end
        end




        if saveFiles&&~isempty(allObjs)
            saveRmiData(modelH,allObjs);
        end

        if mpCount
            rmiut.warnNoBacktrace('Slvnv:reqmgt:linktype_rmi_mupad:NMuPADLinksConverted',...
            num2str(mpCount),get_param(modelH,'Name'));
        end

    end

end

function myCleanup(varargin)
    persistent origStorage origFilters
    if nargin>0
        origStorage=varargin{1};
        origFilters=varargin{2};
    else

        if~origStorage
            storageSettings=rmi.settings_mgr('get','storageSettings');
            storageSettings.external=false;
            rmi.settings_mgr('set','storageSettings',storageSettings);
        end



        rmi.settings_mgr('set','filterSettings',origFilters);
    end
end

function[total_linked,total_links,myObjs,mpCount]=exportRMIData(diagramName,harnessOwner,total_linked,total_links)


    if islogical(harnessOwner)
        allObjs=rmisl.getObjWithReqs(diagramName);
    else
        [slReq,sfReq]=rmisl.getHarnessObjectsWithReqs(diagramName);
        allObjs=[slReq;sfReq];
    end
    linked_obj_count=length(allObjs);
    total_linked=total_linked+linked_obj_count;


    isInLib=false(linked_obj_count,1);




    mpCount=0;
    for i=1:linked_obj_count
        objH=allObjs(i);
        if rmisl.inLibrary(objH)||rmisl.inSubsystemReference(objH)
            isInLib(i)=true;
            continue;
        end
        reqs=rmi.getReqs(objH);
        if~isempty(reqs)
            total_links=total_links+length(reqs);


            for j=1:numel(reqs)
                reqs(j)=slreq.uri.correctDestinationUriAndId(reqs(j));
            end
        end

        if rmisl.is_signal_builder_block(objH)

            blkInfo=rmisl.sigb_get_info(objH);
            groups=rmidata.convertSigbGrpInfo(blkInfo,length(reqs));
            if isempty(groups)


                groups=ones(length(reqs),1);
            end
            groupsWithReqs=unique(groups);
            for j=1:length(groupsWithReqs)
                thisGroup=groupsWithReqs(j);
                thisGroupReqs=reqs(groups==thisGroup);
                mpCount=mpCount+setExternalReqsForObject(objH,thisGroupReqs,thisGroup);
            end
        else

            mpCount=mpCount+setExternalReqsForObject(objH,reqs);
        end

    end


    localObjs=allObjs(~isInLib);
    if isempty(localObjs)
        myObjs={};
    elseif islogical(harnessOwner)

        if~harnessOwner


            myObjs={localObjs};
        else



            myObjs={[diagramName;{''};numericHandlesToSIDs(localObjs)]};
        end
    else



        myObjs={[diagramName;harnessOwner;numericHandlesToSIDs(localObjs)]};
    end
end

function mpCount=setExternalReqsForObject(varargin)
    obj=varargin{1};


    [reqs,mpCount]=rmiut.migrateMupadDestination(varargin{2});



    reqs=fixDestinationsInHarnessDiagrams(reqs);


    reqs=slreq.uri.correctDestinationUriAndId(reqs);





    slreq.internal.catLinks(obj,reqs,varargin{3:end});
end

function targets=fixDestinationsInHarnessDiagrams(targets)
    for i=1:length(targets)
        storedDoc=targets(i).doc;
        if rmisl.isHarnessIdString(storedDoc)
            [targets(i).doc,harnessId]=strtok(storedDoc,':');
            targets(i).id=[harnessId,targets(i).id];
        end
    end
end

function sids=numericHandlesToSIDs(handles)
    isSf=(ceil(handles)==handles);
    if any(isSf)
        sfr=sfroot;
    end
    sids=cell(size(handles));
    for i=1:length(handles)
        obj=handles(i);
        if isSf(i)
            obj=sfr.idToHandle(obj);
        end
        sids{i}=Simulink.ID.getSID(obj);
    end
end

function saveRmiData(modelH,cleanupObjs)

    modelURI=get_param(modelH,'FileName');
    rdata=slreq.data.ReqData.getInstance();
    linkSet=rdata.getLinkSet(modelURI);
    linkSet.save();


    storageName=rmimap.StorageMapper.getInstance.getStorageFor(modelH);
    if exist(storageName,'file')~=2

        warning(message('Slvnv:rmidata:export:ExportLinksFailed',storageName));
        return;
    end






    if strcmpi(get_param(modelH,'BlockDiagramType'),'library')

        wasLocked=strcmp(get_param(modelH,'lock'),'on');
        if wasLocked
            set_param(modelH,'lock','off');
        end
    else
        wasLocked=false;
    end


    rmidata.cleanEmbeddedLinks(cleanupObjs);


    set_param(modelH,'hasReqInfo','off');
    rmidata.storageModeCache('set',modelH,true);


    if wasLocked
        set_param(modelH,'lock','on');
    end


    try
        save_system(modelH);
    catch Mex %#ok<NASGU>



        wState=warning('query','backtrace');
        warning('off','backtrace');
        warning(message('Slvnv:rmidata:export:PostExportSaveFailed',get_param(modelH,'Name')));
        warning(wState);
    end
end

