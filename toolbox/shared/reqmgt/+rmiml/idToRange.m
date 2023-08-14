




function range=idToRange(srcUri,id)

    nodeId='';

    if rmisl.isSidString(srcUri)
        [artifactName,nodeId]=strtok(srcUri,':');
        artifactUri=slreq.resolveArtifactPath(artifactName,'linktype_rmi_simulink');
    elseif rmiut.isCompletePath(srcUri)
        artifactUri=srcUri;
    else
        artifactUri=which(srcUri);
        if isempty(artifactUri)
            rmiut.warnNoBacktrace('Slvnv:rmiml:FileNotFound',srcUri);
            artifactUri=srcUri;
        end
    end

    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactUri);
    if~isempty(linkSet)
        textItem=linkSet.getTextItem(nodeId);
        if~isempty(textItem)
            textRange=textItem.getRange(id);
            if~isempty(textRange)
                range=textRange.getRange();
                return;
            end
        end
    end


    range=[];
end
