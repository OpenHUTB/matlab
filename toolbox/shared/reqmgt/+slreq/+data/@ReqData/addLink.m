function dataLink=addLink(this,linkSet,src,linkInfo,linkType)







    if nargin<5
        linkType='';
    end
    modelLinkSet=this.getModelObj(linkSet);

    dataReq=[];
    isEmbeddedReq=isfield(src,'embeddedReq')&&src.embeddedReq;
    if(isfield(src,'domain')&&strcmpi(src.domain,'linktype_rmi_slreq'))||isEmbeddedReq

        if isfield(src,'sid')&&~isempty(src.sid)
            localId=src.sid;
        else
            localId=src.id;
        end
        artifactToUse=src.artifact;

        if isEmbeddedReq

            [fPath,~,~]=fileparts(artifactToUse);
            artifactToUse=fullfile(fPath,src.reqSet);
        end
        dataReq=slreq.utils.getReqObjFromArtifactID(artifactToUse,localId);
        if dataReq.isJustification...
            &&isstruct(linkInfo)...
            &&~strcmp(linkInfo.reqsys,'linktype_rmi_slreq')


            error(message('Slvnv:slreq:JustificationNonReqLinkError'));
        end
    end


    if(modelLinkSet.lastNumericID==0)
        linkSet.initialChangeNotify();
    end

    [item,isNew]=this.ensureLinkableItem(modelLinkSet,src);


    this.wrap(item);

    if~isNew&&item.outgoingLinks.Size>0&&...
        ~slreq.internal.TempFlags.getInstance.get('IsMigratingDotReq')


        warnIfMatchingLinkExists(item.outgoingLinks,linkInfo);
    end

    if isa(linkInfo,'slreq.data.Requirement')

        mfLink=this.createLinkToRequirement(item,linkInfo,[]);
    elseif strcmp(linkInfo.reqsys,'linktype_rmi_slreq')
        req=[];

        reqId=linkInfo.id;
        if isfield(linkInfo,'sid')
            reqId=linkInfo.sid;
        end
        [refUri,refId]=slreq.internal.LinkUtil.getReqSetUri(linkInfo.doc,reqId);
        reqSet=this.findRequirementSet(refUri);
        if~isempty(reqSet)
            req=this.findRequirement(reqSet,refId);
        end
        if~isempty(req)

            mfLink=this.createLinkToRequirement(item,req,linkInfo);
        else

            mfLink=this.createLink(item,linkInfo);
        end
    else

        mfLink=this.createLink(item,linkInfo);
    end

    if isa(mfLink.dest.requirement,'slreq.datamodel.Justification')

        mfLink.destroy;
        error(message('Slvnv:slreq:IncomingLinkToJustificationError'));
    end



    modelLinkSet.addLink(mfLink);


    dataLink=this.wrap(mfLink);
    if isempty(linkType)
        dataLink.setDefaultLinkType();
    else


        dataLink.type=linkType;
    end


    linkDest=dataLink.dest;
    if~isempty(linkDest)&&isa(linkDest,'slreq.data.Requirement')
        reqSet=linkDest.getReqSet();


        if~isempty(reqSet)&&~contains(reqSet.filepath,'default.slreqx')
            linkSet.addRegisteredRequirementSet(reqSet);
        end
    end



    mfLink.createdOn=mfLink.modifiedOn;


    if~isempty(dataReq)
        isChangeInfoSupported=true;
        mfReq=this.getModelObj(dataReq);
        this.updateLinkedTimeAndVersion(mfLink,mfReq,true);
    else

        isChangeInfoSupported=false;
        mfReq=[];
    end
    this.updateLinkedTimeAndVersion(mfLink,mfReq,isChangeInfoSupported);

    this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('Link Added',dataLink));




end

function warnIfMatchingLinkExists(mfLinks,targetInfo)
    if isa(targetInfo,'slreq.data.Requirement')
        doc=[targetInfo.getReqSet.name,'.slreqx'];
        id=num2str(targetInfo.sid);
        artifactIsFile=true;
        domain='linktype_rmi_slreq';
        linkLabel='';
    else
        doc=targetInfo.doc;
        artifactIsFile=isfile(doc);
        if artifactIsFile
            doc=slreq.uri.getShortNameExt(doc);
        end
        id=targetInfo.id;
        domain=targetInfo.reqsys;
        linkLabel=targetInfo.description;
    end
    for i=1:mfLinks.Size
        mfRef=mfLinks(i).dest;
        if~strcmp(mfRef.domain,domain)
            continue;
        end
        if~isempty(linkLabel)&&~strcmp(linkLabel,mfLinks(i).description)
            continue;
        end
        if~strcmp(mfRef.artifactId,id)
            continue;
        end
        if artifactIsFile
            refArtifact=slreq.uri.getShortNameExt(mfRef.artifactUri);
        else
            refArtifact=mfRef.artifactUri;
        end
        if strcmp(refArtifact,doc)
            rmiut.warnNoBacktrace('Slvnv:oslc:LinkExists',[doc,':',id]);
            return;
        end
    end
end
