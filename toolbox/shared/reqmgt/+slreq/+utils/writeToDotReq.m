function writeToDotReq(origArtifact,destinationName)











    linkSet=slreq.utils.getLinkSet(origArtifact);

    if isempty(linkSet)

        return;
    end

    linkedItems=linkSet.getLinkedItems();

    if isempty(linkedItems)
        return;
    end

    [~,origShortName]=fileparts(origArtifact);
    isSameName=strcmp(origShortName,destinationName);
    isSimulink=strcmp(linkSet.domain,'linktype_rmi_simulink');



    linkedRanges=containers.Map('KeyType','char','ValueType','any');

    m3iRepository=rmimap.RMIRepository.getInstance();




    ensureRootForModel(m3iRepository,destinationName);


    hasLinks=false;
    for i=1:numel(linkedItems)

        linkedItem=linkedItems(i);


        if linkedItem.isTextRange
            textNodeId=linkedItem.getTextNodeId();
            if isempty(textNodeId)


                origTextNodeId=origArtifact;
                newTextNodeId='';
            else


                origTextNodeId=[origShortName,textNodeId];
                newTextNodeId=[destinationName,textNodeId];
            end
            linkedRanges=registerLinkedRange(linkedRanges,origTextNodeId,newTextNodeId,linkedItem.id,m3iRepository);
            srcRoot=newTextNodeId;

        else

            srcRoot=destinationName;
        end

        links=linkedItem.getLinks();

        if~isempty(links)
            linkData=slreq.utils.linkToStruct(links);


            isSelfLink=slreq.uri.isSelfName({linkData.doc},origArtifact);
            if any(isSelfLink)
                for j=find(isSelfLink)




                    linkData(j).doc=destinationName;



                end
            end






            if isSimulink
                isLinkToOwnEML=slreq.uri.isLinkToOwnEML({linkData.reqsys},{linkData.doc},origArtifact);
                if any(isLinkToOwnEML)
                    for j=find(isLinkToOwnEML)
                        origSid=linkData(j).doc;

                        if~isSameName
                            linkData(j).doc=strrep(origSid,origShortName,destinationName);
                        end

                        linkedRanges=registerLinkedRange(linkedRanges,origSid,linkData(j).doc,linkData(j).id,m3iRepository);
                    end
                end
            end


            m3iRepository.setData(srcRoot,linkedItem.id,linkData);
            hasLinks=true;
        end
    end

    if linkedRanges.Count>0

        emlNodesIds=keys(linkedRanges);
        for i=1:length(emlNodesIds)
            oneId=emlNodesIds{i};
            oneNodeData=linkedRanges(oneId);
            allRanges=cell2mat(oneNodeData(:,2));
            rangeStarts=allRanges(:,1);
            rangeEnds=allRanges(:,2);
            idsColumn=oneNodeData(:,1);
            [rangeStartsString,rangeEndsString,idsString]=rmiut.RangeUtils.convert(rangeStarts',rangeEnds',idsColumn');
            m3iRepository.updateRanges(oneId,idsString,rangeStartsString,rangeEndsString);
        end


    end


    if hasLinks
        [destDir,destName,ext]=fileparts(destinationName);
        if dig.isProductInstalled('Simulink')&&bdIsLoaded(destName)

            destMdl=get_param(destName,'FileName');
            assert(~isempty(destMdl),'Destination file name required');
            [destDir,destName]=slfileparts(destMdl);
            ext='.req';
        else

            if isempty(destDir)
                destDir=pwd;
            end
            if isempty(ext)||~strcmpi(ext,'.req')
                ext=[ext,'.req'];
            end
        end
        destReq=fullfile(destDir,[destName,ext]);
        m3iRepository.saveRoot(destinationName,destReq);
    end
end

function ensureRootForModel(m3iRepository,destinationName)



    for i=1:m3iRepository.graph.roots.size
        if strcmp(m3iRepository.graph.roots.at(i),destinationName)
            return;
        end
    end
    t1=M3I.Transaction(m3iRepository.graph);
    rootObj=rmidd.Root(m3iRepository.graph);
    m3iRepository.graph.roots.append(rootObj);
    rootObj.url=destinationName;
    rootObj.setProperty('source','linktype_rmi_simulink');
    t1.commit;
end

function linkedRanges=registerLinkedRange(linkedRanges,origNodeId,textNodeId,rangeId,m3iRepository)
    if rangeId(1)=='@'
        rangeId(1)=[];
    end
    if~isKey(linkedRanges,textNodeId)

        range=slreq.idToRange(origNodeId,rangeId);
        linkedRanges(textNodeId)={rangeId,range};

        m3iRepository.addRoot(textNodeId);
    else

        textNodeData=linkedRanges(textNodeId);
        if~any(strcmp(textNodeData(:,1),rangeId))
            range=slreq.idToRange(origNodeId,rangeId);
            textNodeData=[textNodeData;{rangeId,range}];
        end
        linkedRanges(textNodeId)=textNodeData;
    end
end

