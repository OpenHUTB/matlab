function updateLinkDestination(this,dataLink,newDestStruct)






    changedInfo.propName='destination';
    dataReq=dataLink.dest;
    changedInfo.oldValue=dataReq;
    if~isempty(dataReq)&&isfield(newDestStruct,'sid')
        reqSet=dataReq.getReqSet();
        if strcmp(newDestStruct.reqSet,[reqSet.name,'.slreqx'])
            if newDestStruct.sid==dataReq.sid
                return;
            end
        end
    end

    mfRef=slreq.datamodel.Reference(this.model);
    mfRef.artifactUri=newDestStruct.artifact;
    mfRef.artifactId=newDestStruct.id;
    mfRef.domain=newDestStruct.domain;
    isDestSLReq=false;
    if strcmp(newDestStruct.domain,'linktype_rmi_slreq')


        this.populateReqSetUri(mfRef);
        isDestSLReq=true;
    end



    mfLink=this.getModelObj(dataLink);
    origRef=mfLink.dest;
    if~isempty(origRef)
        origReqUri=origRef.reqSetUri;
        origReq=origRef.requirement;
    else
        origReqUri='';
        origReq=[];
    end


    mfLink.dest=mfRef;
    dataLink.setDirty(true);


    srcPath=dataLink.source.artifactUri;
    this.resolveReference(mfRef,srcPath);


    mfDestReq=mfRef.requirement;
    isChangeInfoSupported=isDestSLReq&&~isempty(mfDestReq);
    this.updateLinkedTimeAndVersion(mfRef,mfDestReq,isChangeInfoSupported);

    if~isempty(origReqUri)&&~isempty(origReq)&&~strcmp(mfRef.reqSetUri,origReqUri)


        incomingReferences=origReq.references;
        for i=double(incomingReferences.Size):-1:1
            if isempty(incomingReferences.at(i).link)
                incomingReferences.removeAt(i);
                break;
            end
        end
    end
    changedInfo.newValue=dataLink.dest;
    this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('Set Prop Update',dataLink,changedInfo));
end
