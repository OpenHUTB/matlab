function linkExportData=createLinkFromMatrix(srcDomain,srcArtifact,srcArtifactID,dstDomain,dstArtifact,dstArtifactID,linktype)
    srcStruct=slreq.report.rtmx.utils.Misc.getTargetStruct(srcDomain,srcArtifact,srcArtifactID,true);
    dstStruct=slreq.report.rtmx.utils.Misc.getTargetStruct(dstDomain,dstArtifact,dstArtifactID,true);

    if strcmpi(srcStruct.domain,'linktype_rmi_slreq')
        srcStruct.id=strrep(srcStruct.id,'#','');
    end

    if strcmpi(dstStruct.domain,'linktype_rmi_matlab')
        dstStruct.id=['@',dstStruct.id];
    end

    linkInfo=createDataLink(srcStruct,dstStruct,linktype);

    linkExportData=slreq.report.rtmx.utils.LinkData.createLinkDataFromLink(linkInfo);

    linkExportData.IsSourceResolved=true;
    linkExportData.IsDestinationResolved=true;
    linkExportData.SrcArtifact=srcArtifact;

    linkExportData.SrcDomain=linkInfo.source.domain;
    if strcmpi(linkExportData.SrcDomain,'linktype_rmi_matlab')
        range=sscanf(srcArtifactID,'%d-%d')';
        linkID=slreq.getRangeId(srcArtifact,range(1),false);
        linkExportData.SrcID=linkID;
    else
        linkExportData.SrcID=[srcArtifact,'#:#',srcArtifactID];
    end

    linkExportData.DstArtifact=dstArtifact;
    linkExportData.DstDomain=linkInfo.destDomain;
    if strcmpi(linkExportData.DstDomain,'linktype_rmi_matlab')
        range=sscanf(dstArtifactID,'%d-%d')';
        linkID=slreq.getRangeId(dstArtifact,range(1),false);
        linkExportData.DstID=linkID;
    else
        linkExportData.DstID=[dstArtifact,'#:#',dstArtifactID];
    end

end


function dataLink=createDataLink(src,dst,linktype)

    try
        if isStructWithCorrectFields(src)

            srcData=src;
        else

            srcData=slreq.utils.resolveSrc(src);
        end
        if strcmp(srcData.domain,'linktype_rmi_simulink')&&rmiut.isBuiltinNoRmi(srcData.artifact)


            ME=MException(message('Slvnv:reqmgt:BuiltInLibNoRMI'));
            throw(ME);
        end

        dstStruct=dst;






        dstStruct=slreq.utils.populateLegacyFieldNames(dstStruct,srcData.artifact);

        if~slreq.utils.isNativeDomain(srcData.domain)
            srcData=convertToProxyItemStruct(srcData);
        end
        linkSetData=slreq.data.ReqData.getInstance.getLinkSet(srcData.artifact);
        if isempty(linkSetData)
            linkSetData=slreq.data.ReqData.getInstance.createLinkSet(srcData.artifact,srcData.domain);
        end
        dataLink=linkSetData.addLink(srcData,dstStruct,linktype);

        adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(srcData.domain);
        sourceArtifact=srcData.artifact;
        adapter.refreshLinkOwner(sourceArtifact,srcData.id,[],dstStruct);

    catch ex
        if strcmp(ex.identifier,'Slvnv:slreq:SimulinkRequirementsNoLicense')
            rethrow(ex);
        else
            ME=MException(message('Slvnv:slreq:APIFailedToCreateLink'));
            ME=ME.addCause(ex);
            throwAsCaller(ME);
        end
    end
end

function tf=isStructWithCorrectFields(in)
    if isstruct(in)
        tf=isfield(in,'domain')&&isfield(in,'artifact')&&isfield(in,'id');
    else
        tf=false;
    end
end

function refStruct=convertToProxyItemStruct(src)












    if isfield(src,'reqSet')&&~slreq.data.ReqData.getInstance.isReservedReqSetName(src.reqSet)
        refStruct.domain='linktype_rmi_slreq';
        refStruct.artifact=src.reqSet;
        refStruct.id=num2str(src.sid);
    else
        error(message('Slvnv:slreq:EmbedCalledForWrongSource','slreq.createLink'));
    end
end

