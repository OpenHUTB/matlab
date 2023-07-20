function[count,reqSetFile,topReq]=customDefinedImport(type,doc,reqSetArg,doProxy,importOptions)





    topReq=[];
    matched=regexp(doc,'^(.)+ \((.)+\)$','tokens');
    if~isempty(matched)
        docId=matched{1}{1};
        [~,docName]=fileparts(matched{1}{2});
    elseif type.isFile
        docName=slreq.uri.getShortNameExt(doc);
        docId=doc;
    else

        docName=doc;
        docId=doc;
    end



    if rmiut.progressBarFcn('exists')
        progressName=docName;
    else
        progressName='';
        fprintf(1,'%s\n',getString(message('Slvnv:slreq_import:ImportingFromDocOfType',docName,type.Registration)));
    end


    if isempty(type.ContentsFcn)
        error(message('Slvnv:slreq_import:MethodNotDefined','ContentsFcn()',type.Registration));
    end


    reqSet=slreq.import.getDestinationReqSet(reqSetArg,docId);
    if isempty(reqSet)

        count=-1;
        reqSetFile='';
        return;
    end


    attrForRationale='';
    attrForKeywords='';
    customAttrNames={};
    if isfield(importOptions,'rationale')||isfield(importOptions,'keywords')||...
        isfield(importOptions,'attrNames')||isfield(importOptions,'attributes')
        if isempty(type.GetAttributeFcn)
            error(message('Slvnv:slreq_import:MethodNotDefined','GetAttributeFcn()',type.Registration));
        end
        if isfield(importOptions,'rationale')
            attrForRationale=importOptions.rationale;
        end
        if isfield(importOptions,'keywords')
            attrForKeywords=importOptions.keywords;
        end
        if isfield(importOptions,'attrNames')
            customAttrNames=importOptions.attrNames;
        elseif isfield(importOptions,'attributes')
            customAttrNames=importOptions.attributes;
        end
    end


    if isfield(importOptions,'richText')&&importOptions.richText
        if isempty(type.HtmlViewFcn)
            error(message('Slvnv:slreq_import:MethodNotDefined','HtmlViewFcn()',type.Registration));
        else
            doRichText=true;
        end
    else
        doRichText=false;
    end


    if~isempty(type.BeforeImportFcn)





        type.BeforeImportFcn(struct('importOptions',importOptions));
    end


    if~isempty(customAttrNames)


        cleanedAttrNames=cell(size(customAttrNames));
        for j=1:length(customAttrNames)
            cleanedAttrNames{j}=slreq.import.cleanAttributeName(customAttrNames{j});
        end

        slreq.import.ensureRegisteredAttributes(reqSet,cleanedAttrNames,type.Registration,true);
    end







    if strcmp(type.Registration,'linktype_rmi_doors')
        contentsOptions=struct('isImporting',true,'isUI',~isempty(progressName));
        [labels,depths,locations]=type.ContentsFcn(docId,contentsOptions);
    else
        [labels,depths,locations]=type.ContentsFcn(docId);
    end



    if~isempty(progressName)
        rmiut.progressBarFcn('set',0.05,...
        getString(message('Slvnv:slreq_import:ProcessingContentOf',progressName)));
    end


    items=makeItems(labels,depths,locations,progressName);



    if~isempty(type.SummaryFcn)
        for i=1:length(items)
            items(i).summary=type.SummaryFcn(docId,items(i).id);
        end
    end

    importTime=datetime('now','TimeZone','UTC');
    topReq=slreq.import.addTopLevelReq(reqSet,type.Registration,docId,docName,doProxy,importTime);


    isScratchReqSet=strcmp(reqSet.name,'SCRATCH');

    if~isScratchReqSet
        tempOptFile=slreq.import.impOptFile(reqSet.name,docId);
        save(tempOptFile,'importOptions');
    end


    origNotificationStatus=slreq.import.uiNotificationMgr(false);

    idxToReq=containers.Map('KeyType','uint64','ValueType','any');
    docData=struct('name',docId,'domain',type.Registration);


    count=length(items);
    reqSetFile=reqSet.filepath;


    for i=1:count
        item=items(i);












        if doRichText
            description=strtrim(type.HtmlViewFcn(docId,item.id,false));
            if~isempty(description)&&~slreq.import.html.isEmpty(description)


                docTypeLabel=regNameToLabel(type.Registration);
                [cacheDir,resourceVarPath]=slreq.import.resourceCachePaths(docTypeLabel);
                if strcmp(docTypeLabel,'DOORS')



                    description=strrep(description,['file:///',cacheDir,'/'],'');
                end
                description=slreq.import.html.absPathToImages(description,resourceVarPath,docTypeLabel);


                reqSet.collectImagesFromHTML(description);
            end
        elseif~isempty(type.TextViewFcn)
            description=rmiut.plainToHtml(type.TextViewFcn(docId,item.id));

        else
            description=item.label;
        end

        if~isempty(attrForRationale)
            attrVal=type.GetAttributeFcn(docId,item.id,attrForRationale);
            rationale=rmiut.plainToHtml(attrVal);
        else
            rationale='';
        end

        if~isempty(attrForKeywords)
            item.keywords=type.GetAttributeFcn(docId,item.id,attrForKeywords);
        end

        if~isempty(customAttrNames)
            item.attrNames=cleanedAttrNames;
            item.attrValues=cell(size(customAttrNames));
            for j=1:length(customAttrNames)

                item.attrValues{j}=type.GetAttributeFcn(docId,item.id,customAttrNames{j});
            end
        end

        if item.parent<0
            parentReq=topReq;
        else
            parentReq=idxToReq(item.parent);
        end

        if~isempty(type.ModificationInfoFcn)





            modificationInfo=type.ModificationInfoFcn(docId,item.id);
            if~isempty(modificationInfo)
                if isfield(modificationInfo,'modifiedOn')
                    modifiedOn=slreq.internal.dateStringToDateTimeObj(modificationInfo.modifiedOn);
                    item.modifiedOn=slreq.utils.getDateTime(modifiedOn,'Write');
                end
                if isfield(modificationInfo,'modifiedBy')
                    item.modifiedBy=modificationInfo.modifiedBy;
                end
                if isfield(modificationInfo,'createdOn')
                    createdOn=slreq.internal.dateStringToDateTimeObj(modificationInfo.createdOn);
                    item.createdOn=slreq.utils.getDateTime(createdOn,'Write');
                end
                if isfield(modificationInfo,'createdBy')
                    item.createdBy=modificationInfo.createdBy;
                end
            end
        end


        idxToReq(i)=slreq.import.addRequirementItem(docData,item,parentReq,doProxy,doRichText,description,rationale,importTime);

        if mod(i,25)==0
            if isempty(progressName)
                fprintf(1,'.');
                if mod(i,2000)==0
                    fprintf(1,'\n');
                end
            else
                if rmiut.progressBarFcn('isCanceled')
                    break;
                else
                    rmiut.progressBarFcn('set',double(i)/double(count),...
                    getString(message('Slvnv:slreq_import:ProcessingContentOf',progressName)));
                end
            end
        end
    end


    if(origNotificationStatus)
        slreq.import.uiNotificationMgr(origNotificationStatus);
    end


    if~isScratchReqSet
        slreq.data.ReqData.getInstance.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Pasted',topReq));
    end

    if isempty(progressName)
        fprintf(1,' done.\n');
    end
end

function label=regNameToLabel(regName)

    label=upper(strrep(regName,'linktype_rmi_',''));
    label=regexprep(label,'\W','');
end

function items=makeItems(labels,depths,locations,dispProgress)
    items=itemStruct(strtrim(labels));
    srcCount=length(items);
    depthToParentIdx=-1*ones(1,max(depths)+1);
    for i=1:srcCount
        if~isempty(dispProgress)&&mod(i,25)==0
            if rmiut.progressBarFcn('isCanceled')
                items(i:srcCount)=[];
                return;
            else
                rmiut.progressBarFcn('set',double(i)/double(srcCount),...
                getString(message('Slvnv:slreq_import:ProcessingContentOf',dispProgress)));
            end
        end
        location=locations{i};

        while location(1)=='#'&&length(location)>1
            location=location(2:end);
        end
        items(i).id=location;
        depth=depths(i);
        items(i).parent=depthToParentIdx(depth+1);
        depthToParentIdx(depth+2:end)=i;
    end
end

function myStruct=itemStruct(labels)
    myStruct=struct('type','id','label',labels,...
    'id','','parent',[]);
end

