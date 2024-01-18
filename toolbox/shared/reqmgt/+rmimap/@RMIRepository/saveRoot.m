function saveRoot(this,myRoot,reqFileName)

    prevFileName='';
    if ischar(myRoot)
        rootName=myRoot;
    else

        rootName=get_param(myRoot,'Name');
        prevFileName=get_param(myRoot,'PreviousFileName');

    end
    isRename=~isempty(prevFileName);
    if isRename
        [~,prevName]=fileparts(prevFileName);
        srcRoot=rmimap.RMIRepository.getRoot(this.graph,prevName);
        isNewName=~strcmp(rootName,prevName);
    else
        srcRoot=rmimap.RMIRepository.getRoot(this.graph,rootName);
        isNewName=false;
        prevName='';
    end

    if isempty(srcRoot)
        error(message('Slvnv:rmigraph:UnmatchedModelName',rootName));
    else
        isSimulinkRoot=strcmp(srcRoot.getProperty('source'),'linktype_rmi_simulink');

        t1=M3I.Transaction(this.graph);

        if isNewName
            srcRoot.url=rootName;
        end

        remappedIDs=[];

        if isSimulinkRoot
            ownLinkDataCount=srcRoot.linkData.size;
            hasAddedLinkData=false;
            nodeDataCount=srcRoot.nodeData.size;
            allChildNames={};
            for i=nodeDataCount:-1:1
                ndData=srcRoot.nodeData.at(i);
                if rmimap.RMIRepository.isSimulinkSubroot(ndData)
                    sourceType=ndData.getValue('source');
                    id=ndData.getValue('id');

                    if isRename

                        if strncmp(id,':urn:uuid:',10)

                            [childId,newId]=rmisl.getUpdatedHarnessId(rootName,id);
                        else
                            childId=[rootName,id];
                            newId='';
                        end
                        prevChildId=[prevName,id];
                        this.renameRoot(prevChildId,childId,sourceType);


                        if isempty(remappedIDs)
                            remappedIDs=containers.Map('KeyType','char','ValueType','char');
                        end
                        remappedIDs(prevChildId)=childId;

                        if~isempty(newId)
                            chNode=this.addNode(srcRoot,newId);
                            nodeData=chNode.addData();
                            nodeData.names.append('source');
                            nodeData.values.append('linktype_rmi_simulink');
                            nodeData.names.append('id');
                            nodeData.values.append(newId);

                            delete(ndData);
                            srcRoot.nodeData.erase(i);
                        end
                    else
                        childId=[rootName,id];
                    end
                    childRoot=rmimap.RMIRepository.getRoot(this.graph,childId);
                    if isempty(childRoot)
                        fprintf(1,'ERROR: failed to locate %s in the Graph.\n',childId);
                    else
                        allChildNames{end+1}=childId;%#ok<AGROW>
                        childLinks=childRoot.links;
                        for j=1:childLinks.size
                            childLink=childLinks.at(j);

                            if(isRename&&~isempty(newId))...
                                ||isempty(childLink.getProperty('dependentUrl'))
                                rmimap.RMIRepository.populateLinkData(childLink);
                            end
                            data=copyLinkData(childLink);
                            srcRoot.linkData.append(data);
                            hasAddedLinkData=true;
                        end
                    end
                end
            end
        end

        for i=1:srcRoot.links.size
            if shouldPopulateLinkData(srcRoot.links.at(i),prevName,remappedIDs)

                rmimap.RMIRepository.populateLinkData(srcRoot.links.at(i));
            end
        end
        if isSimulinkRoot
            [srcTrim,destTrim,descrTrim]=trimSelfName(srcRoot);
        end

        t1.commit();
        rmimap.RMIRepository.writeM3I(reqFileName,srcRoot);

        if isSimulinkRoot
            if hasAddedLinkData||any(srcTrim)||any(destTrim)||any(descrTrim)
                t2=M3I.Transaction(this.graph);
                if hasAddedLinkData
                    trimLinkDataSequence(srcRoot,ownLinkDataCount);
                    srcTrim(ownLinkDataCount+1:end)=[];
                    destTrim(ownLinkDataCount+1:end)=[];
                    descrTrim(ownLinkDataCount+1:end)=[];
                end
                if any(srcTrim)||any(destTrim)||any(descrTrim)
                    untrimSelfName(srcRoot,srcTrim,destTrim,descrTrim);
                end
                t2.commit();
            end
            for i=1:length(allChildNames)
                rmiml.RmiMlData.getInstance.setDirty(allChildNames{i},false);
            end
        end
    end
end


function yesno=shouldPopulateLinkData(link,prevName,remappedIDs)
    dependentUrl=link.getProperty('dependentUrl');
    if isempty(dependentUrl)
        yesno=true;
    elseif isempty(prevName)||isempty(remappedIDs)
        yesno=false;
    else
        dependentUrl=strrep(dependentUrl,'$ModelName$',prevName);
        dependeeUrl=strrep(link.getProperty('dependeeUrl'),'$ModelName$',prevName);

        yesno=any(strcmp(dependentUrl,keys(remappedIDs)))||...
        any(strcmp(dependeeUrl,keys(remappedIDs)));
    end
end


function data=copyLinkData(link)
    data=rmidd.LinkData(link.modelM3I);
    for i=1:link.data.names.size
        data.names.append(link.data.names.at(i));
        data.values.append(link.data.values.at(i));
    end
end


function trimLinkDataSequence(root,keepCount)
    last=root.linkData.size;
    while last>keepCount
        root.linkData.erase(last);
        last=last-1;
    end
end


function[srcTrim,destTrim,descrTrim]=trimSelfName(root)
    selfName=root.url;
    [isEml,mdlName]=rmisl.isSidString(selfName);
    if isEml
        selfName=mdlName;
    end
    dataSize=root.linkData.size;
    srcTrim=false(1,dataSize);
    destTrim=false(1,dataSize);
    descrTrim=false(1,dataSize);
    for i=1:dataSize
        linkDatum=root.linkData.at(i);
        for j=1:linkDatum.names.size
            switch linkDatum.names.at(j)
            case 'dependeeUrl'
                destTrim(i)=macroNamePrefix(selfName,linkDatum,j);
            case 'dependentUrl'
                srcTrim(i)=macroNamePrefix(selfName,linkDatum,j);
            case 'description'
                original=linkDatum.values.at(j);
                if strncmp(original,[selfName,'/'],length(selfName)+1)
                    linkDatum.values.erase(j);
                    linkDatum.values.insert(j,original(length(selfName)+1:end));
                    descrTrim(i)=true;
                end
            otherwise
            end
        end
    end
end


function wasModified=macroNamePrefix(selfName,linkDatum,j)
    original=linkDatum.values.at(j);
    [prefix,theRest]=strtok(original,':');
    if strcmp(prefix,selfName)
        linkDatum.values.erase(j);
        linkDatum.values.insert(j,['$ModelName$',theRest]);
        wasModified=true;
    else
        wasModified=false;
    end
end


function untrimSelfName(root,srcTrim,destTrim,descrTrim)
    selfName=root.url;
    [isEml,mdlName]=rmisl.isSidString(selfName);
    if isEml
        selfName=mdlName;
    end
    for i=find(srcTrim|destTrim|descrTrim)
        linkDatum=root.linkData.at(i);
        for j=1:linkDatum.names.size
            switch linkDatum.names.at(j)
            case 'dependeeUrl'
                if destTrim(i)
                    unmacroNamePrefix(selfName,linkDatum,j);
                end
            case 'dependentUrl'
                if srcTrim(i)
                    unmacroNamePrefix(selfName,linkDatum,j);
                end
            case 'description'
                if descrTrim(i)
                    trimmed=linkDatum.values.at(j);
                    linkDatum.values.erase(j);
                    linkDatum.values.insert(j,[selfName,trimmed]);
                end
            otherwise
            end
        end
    end
end


function unmacroNamePrefix(selfName,linkDatum,j)
    trimmed=linkDatum.values.at(j);
    linkDatum.values.erase(j);
    linkDatum.values.insert(j,strrep(trimmed,'$ModelName$',selfName));
end


