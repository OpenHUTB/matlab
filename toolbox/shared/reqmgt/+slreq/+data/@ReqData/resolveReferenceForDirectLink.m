function changed=resolveReferenceForDirectLink(this,ref,srcPath)






    changed=false;



    if isempty(ref.artifactUri)

        error('ReqData.resolveReference() requires non-empty .domain and .artifactUri field values');

    elseif strcmp(ref.domain,'other')





        isUnderMatlabroot=contains(srcPath,matlabroot);
        fixMigratedReference(ref,isUnderMatlabroot);

    elseif~isempty(srcPath)
        this.unmaskSelfReference(ref,srcPath);
    end

    if strcmp(ref.domain,'linktype_rmi_simulink')




        referencedUri=slreq.uri.getShortNameExt(ref.artifactUri);
        ref.artifactUri=referencedUri;
        isLocalFile=false;
    else
        referencedUri=ref.artifactUri;
        isLocalFile=slreq.utils.isLocalFile(referencedUri,ref.domain);
    end


    group=this.findGroup(referencedUri,ref.domain);


    if isempty(group)
        defaultReqSet=this.getDefaultReqSet();
        group=this.findGroupInReqSet(defaultReqSet,referencedUri,ref.domain);
    end

    if isempty(group)

        reqSet=this.getDefaultReqSet();
        isPersistentReqSet=false;




        if isLocalFile&&~rmiut.isCompletePath(referencedUri)
            referencedUri(referencedUri=='\')='/';
        end
        group=this.addGroup(reqSet,referencedUri,ref.domain);
    else





        reqSet=group.requirementSet;
        isPersistentReqSet=~any(strcmp(reqSet.name,{'default','clipboard'}));
    end


    req=this.findExternalReq(group,ref);










    if isempty(req)
        if isPersistentReqSet








            importedId='';
            if isLocalFile
                domainType=rmi.getLinktype(ref.domain,referencedUri);
                if~isempty(domainType.LinkedIdToImportedIdFcn)

                    reqSetLocation=fileparts(reqSet.filepath);
                    pathToDoc=rmiut.full_path(group.artifactUri,reqSetLocation);
                    importedId=domainType.LinkedIdToImportedIdFcn(pathToDoc,ref.artifactId);
                end
                if~isempty(importedId)&&~strcmp(importedId,ref.artifactId)

                    req=this.findExternalReq(group,importedId);





                end
            end
        else

            reqInfo.artifactUri=group.artifactUri;
            reqInfo.artifactId=ref.artifactId;
            reqInfo.id=ref.artifactId;

            if isLocalFile
                [~,aName,aExt]=fileparts(referencedUri);
                shorterName=[aName,aExt];
            elseif length(referencedUri)>33
                shorterName=[referencedUri(1:15),'..',referencedUri(end-15:end)];
            else
                shorterName=referencedUri;
            end
            reqInfo.summary=this.makeSummary(shorterName,ref.artifactId);
            reqInfo.description='';



            if isempty(reqInfo.artifactId)
                req=this.addExternalReq(group,reqInfo);
            else
                if group.items.Size==0

                    rootInfo=reqInfo;
                    rootInfo.artifactId='';
                    rootInfo.id='';
                    [~,rootInfo.summary]=fileparts(group.artifactUri);
                    parentReq=this.addExternalReq(group,rootInfo);
                    reqSet.addItem(parentReq);


                    reqSet.rootItems.add(parentReq);
                else







                    parentReq=[];
                    parentReqs=group.items{''};
                    if~isempty(parentReqs)
                        parentReq=parentReqs(1);
                    end
                end

                req=this.addExternalReq(group,reqInfo);
                req.parent=parentReq;
            end

            reqSet.addItem(req);
        end
    end

    if isempty(req)







        if~(ref.artifactId(1)=='@'&&strcmp(group.domain,'linktype_rmi_excel'))
            if isImportedGroup(group)
                docShortName=slreq.uri.getShortNameExt(referencedUri);
                rmiut.warnNoBacktrace('Slvnv:slreq:IdNotFoundInImportedContents',...
                docShortName,ref.artifactId);
            else
                rmiut.warnNoBacktrace('Slvnv:slreq:IdNotFoundInExistingGroup',...
                ref.artifactId,group.artifactUri,group.requirementSet.name);
            end




        end




    elseif~isequal(ref.requirement,req)

        ref.requirement=req;
        if isPersistentReqSet
            ref.reqSetUri=sprintf('%s:%d',reqSet.name,req.sid);



            changed=true;
        end
    end

end



function fixMigratedReference(ref,isSrcUnderMatlabroot)


    linkType=resolveMigratedLinkType(ref.domain,ref.artifactUri,true);
    if~isempty(linkType)
        ref.domain=linkType.Registration;
    else




        if~isSrcUnderMatlabroot
            rmiut.warnNoBacktrace('Slvnv:slreq:InvalidDestinationOrUnregisteredType',ref.artifactUri,ref.domain);
        end
    end
end

function linkType=resolveMigratedLinkType(docType,doc,silent)
    if nargin<3
        silent=false;
    end
    if isempty(docType)
        docType='other';
    end
    if strcmp(docType,'other')
        linkType=rmi.linktype_mgr('resolveByFileExt',doc);
    else
        if any(strcmpi(docType,{'word','excel','doors','simulink'}))
            docType=['linktype_rmi_',lower(docType)];
        end
        linkType=rmi.linktype_mgr('resolveByRegName',docType);
    end
    if isempty(linkType)&&~silent
        rmiut.warnNoBacktrace('Slvnv:reqmgt:checkDoc:DocType',doc);
    end
end

function tf=isImportedGroup(group)


    reqSet=group.requirementSet;
    reqSetName=reqSet.name;



    rootItem=findMatchingRootItem(reqSet,group);
    if~isempty(rootItem)
        [docName,subDoc]=slreq.internal.getDocSubDoc(rootItem.customId);
        possibleOptionsFile=slreq.import.impOptFile(reqSetName,docName,subDoc);
        tf=(exist(possibleOptionsFile,'file')==2);






    else
        tf=false;
    end
end

function mfMatchingItem=findMatchingRootItem(reqSet,group)
    mfMatchingItem=[];

    rootItems=reqSet.rootItems.toArray();
    for i=1:length(rootItems)
        mfRootItem=rootItems(i);

        if isa(mfRootItem,'slreq.datamodel.ExternalRequirement')&&mfRootItem.group==group
            mfMatchingItem=mfRootItem;
            break;
        end
    end
end


