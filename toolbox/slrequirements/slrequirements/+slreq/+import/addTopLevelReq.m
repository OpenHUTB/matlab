function[topReq,group]=addTopLevelReq(reqSet,docType,docId,docPath,doProxy,importTime)




    if isstruct(docId)

        artifactUri=docId.parent;
        artifactId=docId.url;
        docId=docId.id;
        shortDocName=docPath;
    else

        shortDocName=slreq.uri.getShortNameExt(docPath);


        [~,subDoc]=slreq.internal.getDocSubDoc(docId);
        if~isempty(subDoc)
            shortDocName=[shortDocName,' (',subDoc,')'];
        end
        artifactUri='';
        artifactId='';
    end


    registeredType=rmi.linktype_mgr('resolveByRegName',docType);

    if isempty(registeredType)
        displayedType=docType;
        isFile=true;


        fileData=dir(docPath);
        if~isempty(fileData)
            docDate=fileData.datenum;
            srcModifiedDateObj=datetime(docDate,'ConvertFrom','datenum','TimeZone','Local');
            srcModifiedOn=slreq.utils.getDateTime(srcModifiedDateObj,'Write');
        else
            srcModifiedOn=importTime;
        end

    else
        displayedType=registeredType.Label;
        isFile=registeredType.isFile;


        if isempty(registeredType.DocDateFcn)
            srcModifiedOn=importTime;
        else
            if isFile
                docDate=registeredType.DocDateFcn(docPath);
            else
                docDate=registeredType.DocDateFcn(docId);
            end


            srcModifiedDateObj=slreq.internal.dateStringToDateTimeObj(docDate);
            srcModifiedOn=slreq.utils.getDateTime(srcModifiedDateObj,'Write');
        end
    end

    if isempty(artifactUri)
        if isFile

            artifactUri=slreq.uri.getPreferredPath(docPath,reqSet.filepath);
        else




            artifactUri=docId;
        end
    end

    docDetails.id=docId;
    docDetails.summary=getString(message('Slvnv:slreq_import:ReferencesTo',shortDocName));
    docDetails.modifiedOn=srcModifiedOn;
    if doProxy
        docDetails.description=getString(message('Slvnv:slreq_import:ReferencesToType',displayedType));
        docDetails.domain=docType;
        docDetails.artifactUri=artifactUri;
        docDetails.artifactId=artifactId;
        docDetails.synchronizedOn=importTime;

        group=slreq.data.ReqData.getInstance.getGroup(artifactUri,docType,reqSet);
        docDetails.group=group;
        docDetails.typeName=slreq.custom.RequirementType.Container.char;
        topReq=reqSet.addExternalRequirement(docDetails);
    else
        docDetails.description=getString(message('Slvnv:slreq_import:ImportedFrom',displayedType));
        docDetails.createdOn=importTime;
        docDetails.typeName=slreq.custom.RequirementType.Container.char;
        topReq=reqSet.addRequirement(docDetails);
        group=[];
    end
end

