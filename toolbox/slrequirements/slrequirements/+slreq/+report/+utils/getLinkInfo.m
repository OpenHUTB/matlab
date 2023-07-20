function[linkDomain,linkStr,hyperLink]=getLinkInfo(linkSrcDst,linkPropagation,linkObj,reqInfo)



    rptArtifactMap=slreq.report.ReportAppendixPart.ArtifactList;
    rptLinkMap=slreq.report.ReportAppendixPart.LinkList;


    makeHyperlink=rmipref('ReportLinkToObjects');

    switch lower(linkPropagation)
    case 'incoming'

        [adapter,artifact,id]=linkSrcDst.getAdapter();
        linkicon=adapter.getIcon(artifact,id);
        linkStr=adapter.getSummary(artifact,id);
        if makeHyperlink&&adapter.isResolved(artifact,id)
            hyperLinkURL=adapter.getURL(artifact,id);
            if linkObj.destinationChangeStatus.isFail
                linkInfo=slreq.report.ReportChangedLinkData;
                hyperLink=mlreportgen.dom.ExternalLink(hyperLinkURL,linkStr,'SLReqReqLinkItemHyperLinkValueFail');
                linkInfo.ActualInfo=slreq.gui.ChangeInformationPanel.getRevisionInfo(linkObj.currentDestinationRevision,linkObj.currentDestinationTimeStamp);
                linkInfo.StoredInfo=slreq.gui.ChangeInformationPanel.getRevisionInfo(linkObj.linkedDestinationRevision,linkObj.linkedDestinationTimeStamp);
                linkInfo.Uuid=linkObj.getUuid;
                linkInfo.LinkStr=linkStr;

                linkInfo.ChangedTargetType='Destination';
                linkInfo.ChangedTarget=reqInfo;
                rptLinkMap(['d#',linkObj.getUuid])=linkInfo;
            else
                hyperLink=mlreportgen.dom.ExternalLink(hyperLinkURL,linkStr,'SLReqReqLinkItemHyperLinkValue');
            end
        else

            hyperLink=mlreportgen.dom.Text(linkStr,'SLReqReqLinkItemValue');
        end
        addArtifact(rptArtifactMap,linkSrcDst.domain,linkSrcDst.artifactUri);
    case 'outgoing'

        [adapter,artifact,id]=linkObj.getDestAdapter();
        linkicon=adapter.getIcon(artifact,id);
        linkStr=adapter.getSummary(artifact,id);
        if makeHyperlink
            hyperLinkURL=adapter.getURL(artifact,id);
            if linkObj.sourceChangeStatus.isFail
                linkInfo=slreq.report.ReportChangedLinkData;
                hyperLink=mlreportgen.dom.ExternalLink(hyperLinkURL,linkStr,'SLReqReqLinkItemHyperLinkValueFail');
                linkInfo.ActualInfo=slreq.gui.ChangeInformationPanel.getRevisionInfo(linkObj.currentSourceRevision,linkObj.currentSourceTimeStamp);
                linkInfo.StoredInfo=slreq.gui.ChangeInformationPanel.getRevisionInfo(linkObj.linkedSourceRevision,linkObj.linkedSourceTimeStamp);
                linkInfo.LinkStr=linkStr;

                linkInfo.ChangedTargetType='Source';
                linkInfo.ChangedTarget=reqInfo;
                linkInfo.Uuid=linkObj.getUuid;
                rptLinkMap(['s#',linkObj.getUuid])=linkInfo;
            else
                hyperLink=mlreportgen.dom.ExternalLink(hyperLinkURL,linkStr,'SLReqReqLinkItemHyperLinkValue');
            end
        else
            hyperLink=mlreportgen.dom.Text(linkStr,'SLReqReqLinkItemValue');
        end
        reqInfo=linkObj.dest;

        domain=adapter.domain;
        if adapter.isResolved(artifact,id)
            destUri=slreq.report.utils.getLinkArtifact(reqInfo);
        else
            hyperLink=mlreportgen.dom.Text(linkStr,'SLReqReqLinkItemValue');

            domain=linkObj.destDomain;
            destUri=linkObj.destUri;
        end

        addArtifact(rptArtifactMap,domain,destUri)
    otherwise

    end
    linkDomain=mlreportgen.dom.Image(linkicon);
end

function out=getDomainString(domainString)
    if strcmpi(domainString,'linktype_rmi_slreq')
        out='slreq';
    elseif strcmpi(domainString,'linktype_rmi_simulink')
        out='slmodel';
    elseif strcmpi(domainString,'linktype_rmi_testmgr')
        out='sltest';
    elseif strcmpi(domainString,'linktype_rmi_data')
        out='sldata';
    else
        out='other';
    end

end

function addArtifact(rptArtifactMap,domain,artiUri)
    domainString=getDomainString(domain);
    if isKey(rptArtifactMap,domainString)
        allUris=rptArtifactMap(domainString);
        if~ismember(artiUri,allUris)
            rptArtifactMap(domainString)=[allUris,artiUri];
        end
    else
        rptArtifactMap(domainString)={artiUri};
    end
end
