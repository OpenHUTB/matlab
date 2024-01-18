function[totalBookmarks,totalLinks]=duplicateMLFB(srcSID,destSID,isPush)
    [sourceDiagram,srcID]=strtok(srcSID,':');
    [srcRangeData,dataLinks]=getLinkedRanges(sourceDiagram,srcID);
    totalBookmarks=size(srcRangeData,1);
    totalLinks=0;
    if(totalBookmarks==0)

        return;
    end

    [destDiagramName,destID]=strtok(destSID,':');
    destDiagramFile=get_param(destDiagramName,'FileName');
    if isempty(destDiagramFile)

        rmiut.warnNoBacktrace('Slvnv:rmidata:StorageMapper:unsavedModel');
        return;
    end

    if nargin<3
        isPush=isMdlToLib(sourceDiagram,destDiagramName);
    end
    if isPush
        clearLinks(destDiagramName,destID);
        updateRanges(destDiagramName,destID,srcRangeData);
        totalLinks=updateSources(dataLinks,destDiagramName,destID);
    elseif isMdlToLib(sourceDiagram,destDiagramName)

        totalLinks=0;
    elseif isLibToMdl(sourceDiagram,destDiagramName)
        totalLinks=duplicateLinks(dataLinks,destDiagramFile,destID,true);
    else
        totalLinks=duplicateLinks(dataLinks,destDiagramFile,destID,false);
    end
end


function clearLinks(parentDiagram,destID)
    dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(parentDiagram);
    if~isempty(dataLinkSet)
        textItem=dataLinkSet.getTextItem(destID);
        if~isempty(textItem)
            ranges=textItem.getRanges();
            for i=1:numel(ranges)
                range=ranges(i);
                links=range.getLinks();
                for j=numel(links):-1:1
                    links(j).remove();
                end
            end
        end
    end
end


function updateRanges(parentDiagram,destID,rangeData)
    dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(parentDiagram);
    if~isempty(dataLinkSet)
        textItem=dataLinkSet.getTextItem(destID);
        if~isempty(textItem)
            ranges=textItem.getRanges();
            knownRangeIds=rangeData(:,1);
            for i=1:numel(ranges)
                range=ranges(i);
                match=find(strcmp(range.id,knownRangeIds));
                if~isempty(match)
                    range.setRange(rangeData{match,2});
                else
                    range.setRange([0,0]);
                end
            end
        end
    end
end


function count=updateSources(dataLinkBunches,parentDiagram,destID)
    count=0;
    destArtifact=get_param(parentDiagram,'FileName');
    for i=1:numel(dataLinkBunches)
        linksInBunch=dataLinkBunches{i};
        if isempty(linksInBunch)
            continue;
        end
        srcInfoStruct=slreq.utils.resolveSrc(linksInBunch(1));
        srcInfoStruct.artifact=destArtifact;
        srcInfoStruct.parent=destID;
        srcInfoStruct.srcRaname=true;

        for j=1:numel(linksInBunch)
            linksInBunch(j).updateSource(srcInfoStruct);
            count=count+1;
        end
    end
end


function count=duplicateLinks(dataLinkBunches,destArtifactPath,destID,doClone)
    count=0;
    reqData=slreq.data.ReqData.getInstance();
    dataLinkSet=reqData.getLinkSet(destArtifactPath,'linktype_rmi_simulink');
    if isempty(dataLinkSet)
        dataLinkSet=reqData.createLinkSet(destArtifactPath,'linktype_rmi_simulink');
    end

    for i=1:numel(dataLinkBunches)
        linksInBunch=dataLinkBunches{i};
        if isempty(linksInBunch)
            continue;
        end
        srcInfoStruct=slreq.utils.resolveSrc(linksInBunch(1));
        srcInfoStruct.artifact=destArtifactPath;
        srcInfoStruct.parent=destID;
        dataRange=reqData.addLinkableRange(dataLinkSet,srcInfoStruct);

        for j=1:numel(linksInBunch)
            if doClone
                reqData.cloneLink(dataRange,linksInBunch(j));
            else
                dataLinkSet.addLink(srcInfoStruct,linksInBunch(j).dest);
            end
            count=count+1;
        end
    end
end


function tf=isMdlToLib(srcSID,destSID)
    srcType=get_param(strtok(srcSID,':'),'BlockDiagramType');
    destType=get_param(strtok(destSID,':'),'BlockDiagramType');
    tf=strcmp(srcType,'model')&&strcmp(destType,'library');
end


function tf=isLibToMdl(srcSID,destSID)
    srcType=get_param(strtok(srcSID,':'),'BlockDiagramType');
    destType=get_param(strtok(destSID,':'),'BlockDiagramType');
    tf=strcmp(srcType,'library')&&strcmp(destType,'model');
end


function[rangeData,allLinks]=getLinkedRanges(parentDiagram,mlfbID)
    rangeData=cell(0,2);
    allLinks={};
    dataLinkSet=slreq.data.ReqData.getInstance.getLinkSet(parentDiagram);
    if~isempty(dataLinkSet)
        textItem=dataLinkSet.getTextItem(mlfbID);
        if~isempty(textItem)
            ranges=textItem.getRanges();
            rangeData=cell(numel(ranges),2);
            for i=1:numel(ranges)
                range=ranges(i);
                rangeData(i,:)={range.id,[range.startPos,range.endPos]};
                links=range.getLinks();
                allLinks{end+1}=links;%#ok<AGROW> 
            end
        end
    end
end
