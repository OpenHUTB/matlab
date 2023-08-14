function[count,reqSetPath,topReq]=xlsDocToReqSet(docPath,destinationReqSet,doProxy,optionsStruct)




    count=0;
    reqSetPath='';
    topReq=[];


    slreq.internal.errorIfWebDoc(docPath);


    docObj=rmidotnet.docUtilObj(docPath);

    if isfield(optionsStruct,'mapping')
        mapping=optionsStruct.mapping;



        importOptions=rmfield(optionsStruct,'mapping');
    else
        importOptions=optionsStruct;
        mapping=[];
    end


    if isempty(destinationReqSet)
        [~,fName]=fileparts(docPath);
        destinationReqSet=fName;
    end




    if isfield(importOptions,'subDoc')
        subDoc=importOptions.subDoc;
    else
        subDoc=docObj.sSheets{docObj.iSheet};
    end


    [reqSet,isNewReqSet]=slreq.import.validateReqSetArg(destinationReqSet,doProxy,docPath,subDoc);
    if isempty(reqSet)

        if~isNewReqSet
            count=-1;

        end
        return;
    end
    reqSetPath=reqSet.filepath;

    isScratchReqSet=strcmp(reqSet.name,'SCRATCH');
    isLoadedOptions=isScratchReqSet;


    try
        if importOptions.richText
            slreq.import.cleanupCachedContent(docObj.htmlFileDir,docObj.sName);
        end
    catch ex %#ok<NASGU>

    end


    if isfield(importOptions,'subDoc')

        docObj.setActiveSheet(importOptions.subDoc);


    elseif docObj.iSheet>0

        sheetNames=docObj.getSheetNames();
        importOptions.subDoc=sheetNames{docObj.iSheet};
    else

        [~,importOptions.subDoc]=docObj.getActiveSheetInWorkbook(docObj.hDoc);
    end
    if~isfield(importOptions,'subDocPrefix')
        importOptions.subDocPrefix=false;
    end

    if isfield(importOptions,'columns')




        if length(importOptions.columns)==2
            importOptions.columns=ensureFullListOfColumns(importOptions);
        end
    elseif~(isfield(importOptions,'match')||isfield(importOptions,'usdm'))


        totalCols=rmidotnet.MSExcel.countColsInSheet(docObj.hDoc,docObj.iSheet);
        importOptions.columns=1:totalCols;
    end



    if isfield(importOptions,'rows')
        if isLoadedOptions
            importOptions=verifyLastRowNumber(docObj,importOptions);
        end
    end










    importOptions=slreq.import.convertAttributesToHeaders(importOptions);


    if~isfield(importOptions,'usdm')
        importOptions.usdm=false;
    end



    if isfield(importOptions,'attributeColumn')&&~isempty(importOptions.attributeColumn)
        for i=1:length(importOptions.attributeColumn)
            idx=find(importOptions.columns==importOptions.attributeColumn(i));
            importOptions.headers{idx}=slreq.import.cleanAttributeName(importOptions.headers{idx});
        end
    end




    itemsToImport=docObj.getItems(importOptions);
    if isempty(itemsToImport)
        error(message('Slvnv:slreq:NothingToImport',docPath));
    end

    showProgress=rmiut.progressBarFcn('exists');

    getRichContent=isfield(importOptions,'richText')&&importOptions.richText;



    lastItem=itemsToImport(end);
    lastRow=lastItem.address(1)+lastItem.range(1)-1;
    docObj.cacheTextContents(1,lastRow,showProgress);


    if isfield(importOptions,'attributeColumn')&&~isempty(importOptions.attributeColumn)
        attributeNames=importOptions.headers(ismember(importOptions.columns,importOptions.attributeColumn));
        slreq.import.ensureRegisteredAttributes(reqSet,attributeNames,'Excel',doProxy);
    end





    [~,docName]=fileparts(docPath);
    topLevelNodeName=[docName,'!',subDoc];

    if isScratchReqSet
        slreq.uri.getPreferredPath(false);
        clp=onCleanup(@()slreq.uri.getPreferredPath(true));
    end

    inputDomain='linktype_rmi_excel';
    importTime=datetime('now','TimeZone','UTC');
    [topReq,group]=slreq.import.addTopLevelReq(reqSet,inputDomain,topLevelNodeName,docPath,doProxy,importTime);

    if~isempty(mapping)

        mapping.name=topReq.customId;
        slreq.data.ReqData.getInstance.addMapping(reqSet,mapping);
    end

    srcModifiedOn=topReq.modifiedOn;

    if doProxy&&~isScratchReqSet


        tempOptFile=slreq.import.impOptFile(reqSet.name,docName,subDoc);

        importOptions=rmfield(importOptions,'ReqSet');
        save(tempOptFile,'importOptions');
    end



    idPrefix='';
    if isfield(importOptions,'subDocPrefix')&&importOptions.subDocPrefix
        idPrefix=[subDoc,'!'];
    end






    origNotificationStatus=slreq.import.uiNotificationMgr(false);


    existingReqs=containers.Map('KeyType','double','ValueType','any');
    totalItems=length(itemsToImport);
    if totalItems>100
        slreq.data.ReqData.getInstance.doNotify(false);
    end

    isMatching=isfield(importOptions,'match')&&~isempty(importOptions.match);

    for i=1:totalItems
        item=itemsToImport(i);
        if isfield(item,'address')
            vOrder=item.address(1);
        else
            vOrder=item.parags(1);
        end
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

        label=item.label;


        if strcmp(item.type,'row')
            address=docObj.makeAddress(item);
            if isempty(idPrefix)
                [~,address]=strtok(address,'!');%#ok<STTOK>
            end
            item.id=address(2:end);

        elseif isfield(item,'id')&&~isempty(idPrefix)

            item.id=[idPrefix,item.id];
        end



        if~isfield(item,'summary')||isempty(item.summary)
            summary=docObj.makeSummary(item);
        else
            summary=item.summary;
        end

        if isMatching




            tempItem=item;
            if isfield(item,'drange')&&~isempty(item.drange)
                if isstruct(item.drange)
                    tempItem.address=item.drange.address;
                    tempItem.range=item.drange.range;
                    cols=tempItem.address(2):tempItem.address(2)+tempItem.range(2)-1;
                else
                    cols=item.drange(1):item.drange(end);
                end
                all=false;
            else
                cols=item.address(2):item.address(2)+item.range(2)-1;
                all=true;
            end
            if getRichContent
                if all
                    hRange=docObj.itemToRange(tempItem);
                else
                    hRange=docObj.itemToRange(tempItem,cols);
                end
                myHtml=docObj.rangeToHtml(label,hRange,getRichContent);
            else
                rows=tempItem.address(1):tempItem.address(1)+tempItem.range(1)-1;
                myHtml=docObj.cellsToHtml(rows,cols);
            end

        else


            if isfield(item,'drange')&&~isempty(item.drange)

                if getRichContent
                    hRange=docObj.itemToRange(item,item.drange);
                    rangeLabel=[label,sprintf('-%d',item.drange)];
                    myHtml=docObj.rangeToHtml(rangeLabel,hRange,true);
                else
                    myHtml=docObj.cellsToHtml(item.address(1),item.drange(1):item.drange(end));
                end
            else
                myHtml='';
            end
        end


        if isfield(item,'rrange')&&~isempty(item.rrange)
            if importOptions.usdm



                tempItem.type='match';
                tempItem.address=item.rrange.address;
                tempItem.range=item.rrange.range;
                if getRichContent
                    hRange=docObj.itemToRange(tempItem,'all');
                    rangeLabel=[label,sprintf('-%d',tempItem.address)];
                    raHtml=docObj.rangeToHtml(rangeLabel,hRange,true);
                else
                    rowRange=tempItem.address(1):tempItem.address(1)+tempItem.range(1)-1;
                    colRange=tempItem.address(2):tempItem.address(2)+tempItem.range(2)-1;
                    raHtml=docObj.cellsToHtml(rowRange,colRange);
                end
            else



                if getRichContent
                    hRange=docObj.itemToRange(item,item.rrange);
                    rangeLabel=[label,sprintf('-%d',item.rrange)];
                    raHtml=docObj.rangeToHtml(rangeLabel,hRange,true);
                else
                    raHtml=docObj.cellsToHtml(item.address(1),item.rrange(1):item.rrange(end));
                end
            end
        else
            raHtml='';
        end


        item.group=group;


        item.modifiedOn=srcModifiedOn;


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


    if(origNotificationStatus)
        slreq.import.uiNotificationMgr(origNotificationStatus);
    end


    if~isScratchReqSet
        slreq.data.ReqData.getInstance.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Pasted',topReq));
    end


    rmidotnet.cleanupScratchFile(docObj);
end




















function columns=ensureFullListOfColumns(options)
    if isMissing('idColumn')||isMissing('summaryColumn')||isMissing('keywordsColumn')...
        ||isMissing('descriptionColumn')||isMissing('rationaleColumn')||isMissing('attributeColumn')...
        ||isMissing('createdByColumn')||isMissing('modifiedByColumn')
        columns=options.columns(1):options.columns(end);
    else
        columns=options.columns;
    end

    function tf=isMissing(fieldName)
        tf=isfield(options,fieldName)&&~isempty(setdiff(options.(fieldName),options.columns));
    end
end

function options=verifyLastRowNumber(docObj,options)



    if isfield(options,'rows')
        oldRows=options.rows;
        iSheet=docObj.iSheet;
        if iSheet==0
            iSheet=docObj.getActiveSheet();
        end
        totalRows=rmidotnet.MSExcel.countRowsInSheet(docObj.hDoc,iSheet);
        if totalRows<oldRows(2)
            options.rows(2)=totalRows;
        elseif totalRows>oldRows(2)



            addedRowsRange=[oldRows(2)+1,totalRows];
            addedRowsText=rmidotnet.MSExcel.getTextFromRange(docObj,addedRowsRange,options.columns);
            if isfield(options,'idColumn')
                idColumn=options.idColumn;
            else
                idColumn=[];
            end
            for i=1:size(addedRowsText,1)
                thisRowCountNonEmpty=sum(~cellfun(@isempty,addedRowsText(i,:)));
                if~isempty(idColumn)


                    if thisRowCountNonEmpty>1&&~isempty(addedRowsText{i,idColumn})
                        options.rows(2)=oldRows(2)+i;
                    end
                else


                    if thisRowCountNonEmpty>=3
                        options.rows(2)=oldRows(2)+i;
                    end
                end







            end
        end
    end
end

