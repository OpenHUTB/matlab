function[count,reqSetPath,topReq]=wordDocToReqSet(docPath,destinationReqSet,doProxy,optionsStruct)




    count=0;
    reqSetPath='';
    topReq=[];



    slreq.internal.errorIfWebDoc(docPath);


    docObj=rmidotnet.docUtilObj(docPath,false,true);


    importOptions=optionsStruct;

    if isempty(destinationReqSet)
        [~,fName]=fileparts(docPath);
        destinationReqSet=fName;
    end


    [reqSet,isNewReqSet]=slreq.import.validateReqSetArg(destinationReqSet,doProxy,docPath);
    if isempty(reqSet)

        if~isNewReqSet
            count=-1;

        end
        return;
    end
    reqSetPath=reqSet.filepath;
    isScratchReqSet=strcmp(reqSet.name,'SCRATCH');



    try
        if importOptions.richText
            slreq.import.cleanupCachedContent(docObj.htmlFileDir,docObj.sName);
        end
    catch ex %#ok<NASGU>

    end




    itemsToImport=docObj.getItems(importOptions);
    if isempty(itemsToImport)
        error(message('Slvnv:slreq:NothingToImport',docPath));
    end

    getRichContent=isfield(importOptions,'richText')&&importOptions.richText;
    ignoreOutlineNumbers=isfield(importOptions,'ignoreOutlineNumbers')&&importOptions.ignoreOutlineNumbers;

    showProgress=rmiut.progressBarFcn('exists');



    docObj.updateScratchCopy();


    inputDomain=rmidotnet.resolveDomainType(docObj);
    importTime=datetime('now','TimeZone','UTC');
    [~,docName]=fileparts(docPath);

    if isScratchReqSet
        slreq.uri.getPreferredPath(false);
        clp=onCleanup(@()slreq.uri.getPreferredPath(true));
    end
    [topReq,group]=slreq.import.addTopLevelReq(reqSet,inputDomain,docName,docPath,doProxy,importTime);
    srcModifiedOn=topReq.modifiedOn;

    if doProxy&&~isScratchReqSet
        tempOptFile=slreq.import.impOptFile(reqSet.name,docName);

        importOptions=rmfield(importOptions,'ReqSet');
        save(tempOptFile,'importOptions');

    end






    origNotificationStatus=slreq.import.uiNotificationMgr(false);


    existingReqs=containers.Map('KeyType','double','ValueType','any');
    totalItems=length(itemsToImport);
    if totalItems>100
        slreq.data.ReqData.getInstance.doNotify(false);
    end

    for i=1:totalItems
        item=itemsToImport(i);
        vOrder=item.parags(1);
        if length(docObj.iParents)>=vOrder
            parentVOrder=docObj.iParents(vOrder);
        else
            parentVOrder=0;
        end
        if parentVOrder>0&&isKey(existingReqs,parentVOrder)
            parentReq=existingReqs(parentVOrder);
        else
            parentReq=topReq;
        end

        raHtml='';

        if strcmp(item.type,'parag')

            if docObj.iEnds(item.parags(end))-docObj.iStarts(item.parags(1))<10
                continue;
            end
        end


        item.group=group;


        item.modifiedOn=srcModifiedOn;


        [myHtml,summary]=docObj.paragsToHtml(item.label,item.parags(1),item.parags(end),getRichContent,ignoreOutlineNumbers);


        item.summary=summary;


        if getRichContent
            reqSet.collectImagesFromHTML(myHtml);
        end

        existingReqs(vOrder)=slreq.import.addRequirementItem(docObj,item,parentReq,doProxy,getRichContent,myHtml,raHtml,importTime);

        count=count+1;


        if showProgress&&mod(i,5)==0
            if rmiut.progressBarFcn('isCanceled')
                break;
            end
            rmiut.progressBarFcn('set',i/totalItems,getString(message('Slvnv:slreq_import:CountItemsImported',num2str(count))));
        end

    end

    if totalItems>100
        slreq.data.ReqData.getInstance.doNotify(true);
    end

    docObj.discardScratchCopy();


    if(origNotificationStatus)
        slreq.import.uiNotificationMgr(origNotificationStatus);
    end


    if~isScratchReqSet
        slreq.data.ReqData.getInstance.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Pasted',topReq));
    end


    docObj.setMinimized(false);


    rmidotnet.cleanupScratchFile(docObj);
end










