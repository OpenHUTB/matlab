function[inLinks,outLinks]=getLinksForNonReqItem(this,objH,linkType)





    if nargin<3

        linkType='';
    end











    if isstruct(objH)
        inSrcInfo=objH;
        outSrcInfo=objH;
    else

        inSrcInfo=slreq.utils.getRmiStruct(objH);
        outSrcInfo=inSrcInfo;

        if strcmpi(inSrcInfo.domain,'linktype_rmi_simulink')&&rmisl.isObjectUnderCUT(objH)

            blockObj=get(objH,'Object');
            ownerInfo=rmisl.harnessToModelRemap(blockObj);
            outObjH=ownerInfo.Handle;
            outSrcInfo=slreq.utils.getRmiStruct(outObjH);
        end
    end


    inLinks=locGetInLinks(this,inSrcInfo,linkType);

    outLinks=locGetOutLinks(this,outSrcInfo,linkType);
end


function inLinks=locGetInLinks(this,srcInfo,linkType)
    defaultDataReqSet=this.wrap(this.getDefaultReqSet());



    inLinks=slreq.data.Link.empty;


    artifactUri=slreq.uri.getShortNameExt(srcInfo.artifact);
    artifactDomain=srcInfo.domain;
    artifactId=srcInfo.id;
    dataReq=this.findExternalRequirementByArtifactUrlId(...
    defaultDataReqSet,artifactDomain,artifactUri,artifactId);

    if~isempty(dataReq)
        assert(isscalar(dataReq),'More than one object should not be found')
        if isempty(linkType)
            inLinks=dataReq.getLinks;
        else
            inLinks=dataReq.getLinks(linkType);
        end
    end
end


function outLinks=locGetOutLinks(this,outSrcInfo,linkType)


    outLinks=slreq.data.Link.empty;
    linkSet=this.getLinkSet(outSrcInfo.artifact);

    if~isempty(linkSet)
        srcItem=linkSet.getLinkedItem(outSrcInfo.id);
        if~isempty(srcItem)
            if isempty(linkType)
                outLinks=srcItem.getLinks();
            else
                outLinks=srcItem.getLinks(linkType);
            end
        end
    end
end
