function result=loadDotReq(artifact,dotReqFilePath)




    type=rmimap.validateReqFile(dotReqFilePath);
    switch type
    case 'mdlGraph'
        oldRoot=readAsGraph(artifact,dotReqFilePath);
        usingCommonGraph=false;
    case 'mdlRoot'

        oldRoot=readAsRoot(artifact,dotReqFilePath);
        usingCommonGraph=true;
    otherwise
        error(message('Slvnv:rmigraph:InvalidReqFile',reqFileName));
    end

    if~isempty(oldRoot)

        if any(strcmp(oldRoot.nodeData.at(1).getValue('source'),...
            {'Simulink','linktype_rmi_simulink'}))





            storageSettings=rmi.settings_mgr('get','storageSettings');
            origStorageMode=storageSettings.external;
            if~origStorageMode
                storageSettings.external=true;
                rmi.settings_mgr('set','storageSettings',storageSettings);
            end
        else
            origStorageMode=true;
        end



        w=slreq.internal.TempFlags.changeFlag('IsMigratingDotReq',true);%#ok<NASGU>




        [countLinks,countTextRanges]=addItems(oldRoot);


        if~origStorageMode
            storageSettings.external=false;
            rmi.settings_mgr('set','storageSettings',storageSettings);
        end


        if usingCommonGraph
            cleanup(oldRoot);
        end

    else
        countLinks=0;
        countTextRanges=0;
    end

    result=(countLinks+countTextRanges>0);

end

function root=readAsGraph(artifact,dotReqFilePath)
    persistent oldGraph
    if nargin<2

        root=localGetRoot(oldGraph,artifact);
    else

        rf=M3I.XmiReaderFactory();
        rdr=rf.createXmiReader();
        graphModel=rmidd.Graph();
        rdr.setInitialModel(graphModel);
        try
            oldGraph=rdr.read(dotReqFilePath);
            delete(rdr);
            root=localGetRoot(oldGraph,artifact);
        catch ex

            if strcmp(ex.identifier,'M3I:Serializer:XmiReader:ReferenceResolutionError')
                [~,aName,aExt]=fileparts(artifact);
                [~,rName,rExt]=fileparts(dotReqFilePath);
                errordlg({...
                getString(message('Slvnv:slreq:ErrorDotReqMsg1',[rName,rExt])),...
                getString(message('Slvnv:slreq:ErrorDotReqMsg2',[aName,aExt]))},...
                getString(message('Slvnv:slreq:ErrorDotReqTitle')));
                root=[];
            else
                rethrow(ex);
            end
        end
    end
end

function root=readAsRoot(artifact,dotReqFilePath)

    rf=M3I.XmiReaderFactory();
    rdr=rf.createXmiReader();
    tmpRepo=rmimap.RMIRepository.getInstance();
    tmpRepo.graph=rdr.read(dotReqFilePath,tmpRepo.graph,tmpRepo.graph,'roots');
    delete(rdr);
    root=localGetRoot(tmpRepo.graph,artifact);
end

function[count,trCount]=addItems(myRoot)
    count=0;
    trCount=0;
    mupadCount=0;
    linkSet=[];
    nodeDataCount=myRoot.nodeData.size;


    srcStruct.domain=myRoot.nodeData.at(1).getValue('source');
    if strcmp(srcStruct.domain,'Simulink')
        srcStruct.domain='linktype_rmi_simulink';
    end
    if ispc
        srcStruct.artifact=myRoot.url;
    else

        srcStruct.artifact=strrep(myRoot.url,'\','/');
    end







    slreq.data.DataModelObj.checkLicense(['allow ',srcStruct.artifact]);
    cll=onCleanup(@()slreq.data.DataModelObj.checkLicense('clear'));


    mlNodeData=containers.Map('KeyType','char','ValueType','any');
    sbNodeData=containers.Map('KeyType','char','ValueType','any');
    for i=1:nodeDataCount
        ndData=myRoot.nodeData.at(i);
        if strcmp(srcStruct.domain,'linktype_rmi_matlab')


            srcStruct.id='';
            mlNodeData('')=ndData;
            cache=ndData.getValue('cache');
            textItem=slreq.utils.ensureTextItem(srcStruct,cache);

            trCount=trCount+ensureAllTextRanges(textItem,ndData);
        else

            id=ndData.getValue('id');
            if~isempty(id)
                sourceType=ndData.getValue('source');
                if isempty(sourceType)

                    grpInfoString=ndData.getValue('groups');
                    sbNodeData(id)=sscanf(grpInfoString,'%d,');
                elseif strcmp(sourceType,'linktype_rmi_matlab')

                    mlNodeData(id)=ndData;
                    cache=ndData.getValue('cache');
                    srcStruct.id=id;
                    textItem=slreq.utils.ensureTextItem(srcStruct,cache);

                    trCount=trCount+ensureAllTextRanges(textItem,ndData);
                end



            end
        end
    end



    totalLinkDataItems=myRoot.linkData.size;
    [~,shortName]=fileparts(srcStruct.artifact);
    for i=1:totalLinkDataItems



        if isfield(srcStruct,'parent')
            srcStruct=rmfield(srcStruct,{'parent','range'});
        end


        linkDatum=myRoot.linkData.at(i);


        dependentId=linkDatum.getValue('dependentId');
        dependentUrl=linkDatum.getValue('dependentUrl');

        if strcmp(srcStruct.domain,'linktype_rmi_matlab')


            srcStruct.parent='';
            myNodeData=mlNodeData('');
            srcStruct.range=getRangeFromNodeData(myNodeData,dependentId);
            if isempty(srcStruct.range)

                continue;
            end
            srcStruct.id=dependentId;

        elseif strcmp(srcStruct.domain,'linktype_rmi_simulink')










            if strcmp(srcStruct.domain,'linktype_rmi_simulink')...
                &&~strcmp(dependentUrl,srcStruct.artifact)...
                &&~any(dependentUrl==':')...
                &&~any(dependentUrl=='.')
                dependentUrl=srcStruct.artifact;
            end



            if strcmp(dependentUrl,srcStruct.artifact)

                if isKey(sbNodeData,dependentId)

                    grpIdx=sbNodeData(dependentId);
                    thisIdx=grpIdx(1);
                    srcStruct.id=sprintf('%s.%d',dependentId,thisIdx);
                    shiftedIdx=grpIdx(2:end);
                    if isempty(shiftedIdx)
                        remove(sbNodeData,dependentId);
                    else
                        sbNodeData(dependentId)=shiftedIdx;
                    end
                elseif strcmp(dependentId,':')

                    srcStruct.id='';
                else
                    srcStruct.id=dependentId;
                end
            else





                if dependentUrl(1)~=':'
                    [~,parentId]=strtok(dependentUrl,':');
                else
                    parentId=dependentUrl;
                end

                if rmisl.isHarnessIdString(parentId)




                    srcStruct.id=[parentId,dependentId];
                elseif isKey(mlNodeData,parentId)
                    srcStruct.parent=parentId;
                    myNodeData=mlNodeData(parentId);
                    srcStruct.range=getRangeFromNodeData(myNodeData,dependentId);
                    if isempty(srcStruct.range)



                        continue;
                    end

                    srcStruct.id=slreq.utils.getLongIdFromShortId(parentId,dependentId);
                else
                    error('slreq.loadDotReq(): unrecognized parent ID "%s"',parentId);
                end
            end

        else

            srcStruct.id=dependentId;
        end


        destStruct=rmi.createEmptyReqs(1);

        destStruct.reqsys=linkDatum.getValue('source');
        destStruct.doc=linkDatum.getValue('dependeeUrl');
        destStruct.id=linkDatum.getValue('dependeeId');
        if isempty(destStruct.doc)&&isempty(destStruct.id)&&~strcmp(destStruct.reqsys,'other')


            continue;
        end


        if isempty(destStruct.reqsys)

            if strcmp(destStruct.doc,dependentUrl)



                destStruct.reqsys=srcStruct.domain;
            else
                dependeeRoot=readAsGraph(destStruct.doc);
                destStruct.reqsys=dependeeRoot.getProperty('source');
            end
        end




        destStruct=slreq.uri.correctDestinationUriAndId(destStruct);


        destStruct.description=linkDatum.getValue('description');




        switch destStruct.reqsys
        case 'linktype_rmi_simulink'
            if destStruct.description(1)=='/'

                destStruct.description=[shortName,destStruct.description];
            end
        case 'other'

            [~,~,fExt]=fileparts(destStruct.doc);
            if strcmp(fExt,'.mn')
                mupadCount=mupadCount+1;
                destStruct=rmiut.migrateMupadDestination(destStruct);
            end
        case 'linktype_rmi_mupad'

            mupadCount=mupadCount+1;
            destStruct=rmiut.migrateMupadDestination(destStruct);
        otherwise

        end


        destStruct.keywords=linkDatum.getValue('keywords');
        destStruct.linked=~strcmp(linkDatum.getValue('linked'),'0');


        linkSet=localCatLinks(srcStruct,destStruct);
        count=count+1;
    end

    if count>0||trCount


















        if isempty(linkSet)
            linkSet=textItem.getLinkSet();
        end


        slreq.data.ReqData.getInstance.forceDirtyFlag(linkSet,false);




        if mupadCount
            rmiut.warnNoBacktrace('Slvnv:reqmgt:linktype_rmi_mupad:NMuPADLinksConverted',...
            num2str(mupadCount),slreq.uri.getShortNameExt(linkSet.artifact));
        end
    end
end

function rCount=ensureAllTextRanges(textItem,nodeData)
    rCount=0;
    rangeLabelsString=nodeData.getValue('rangeLabels');
    [~,rangeLabels]=evalc(rangeLabelsString);
    for i=1:length(rangeLabels)
        oneLabel=rangeLabels{i};
        range=getRangeFromNodeData(nodeData,oneLabel);
        if~isempty(range)
            textItem.addTextRange(oneLabel,range);
            rCount=rCount+1;
        end
    end
end

function linkSet=localCatLinks(src,linkInfo)



    r=slreq.data.ReqData.getInstance;
    linkSet=r.getLinkSet(src.artifact);

    if isempty(linkSet)
        linkSet=r.createLinkSet(src.artifact,src.domain);
    end
    if slreq.utils.isLocalFile(linkInfo)



        if~rmiut.isCompletePath(linkInfo.doc)
            linkInfo.doc(linkInfo.doc=='\')='/';
        end
    end
    linkSet.addLink(src,linkInfo);
end

function cleanup(myRoot)
    tmpRepo=rmimap.RMIRepository.getInstance();
    tmpRepo.removeRoot(myRoot.url,true);
    rmimap.RMIRepository.clear();
end

function root=localGetRoot(myGraph,sourceUrl)

    root=[];

    if~ispc
        sourceUrl=strrep(sourceUrl,'\','/');
    end


    [~,srcName]=fileparts(sourceUrl);


    for i=1:myGraph.roots.size
        tryMe=myGraph.roots.at(i);
        if ispc
            storedUrl=tryMe.url;
        else
            storedUrl=strrep(tryMe.url,'\','/');
        end
        if rmiut.cmp_paths(storedUrl,sourceUrl)
            root=tryMe;
            break;
        end
        [~,tryName]=fileparts(storedUrl);
        if rmiut.cmp_paths(tryName,srcName)
            root=tryMe;
            break;
        end
    end
    if~isempty(root)


        updateRootUrl(myGraph,root,sourceUrl);
    end
end

function updateRootUrl(myGraph,myRoot,newUrl)
    tr=M3I.Transaction(myGraph);
    origUrl=myRoot.url;
    if endsWith(newUrl,'.req')





        if isfile(origUrl)
            return;
        end
        [~,origOwner,origExt]=fileparts(origUrl);
        ownerArtifact=which([origOwner,origExt]);
        if~isempty(ownerArtifact)
            myRoot.url=ownerArtifact;
        else
            [~,givenName]=fileparts(newUrl);
            myRoot.url=[givenName,origExt];
        end
    else
        myRoot.url=newUrl;
    end
    [~,newName]=fileparts(newUrl);
    for i=1:myRoot.linkData.size
        myData=myRoot.linkData.at(i);
        dependentUrl=myData.getValue('dependentUrl');
        if strcmp(dependentUrl,origUrl)


            localSetValue(myData,'dependentUrl',newUrl);
        elseif strncmp(dependentUrl,'$ModelName$',length('$ModelName$'))


            dependentUrl=strrep(dependentUrl,'$ModelName$',newName);
            localSetValue(myData,'dependentUrl',dependentUrl);
        end
        dependeeUrl=myData.getValue('dependeeUrl');
        if strcmp(dependeeUrl,origUrl)
            localSetValue(myData,'dependeeUrl',newUrl);
        elseif strncmp(dependeeUrl,'$ModelName$',length('$ModelName$'))
            dependeeUrl=strrep(dependeeUrl,'$ModelName$',newName);
            localSetValue(myData,'dependeeUrl',dependeeUrl);
        end
    end
    tr.commit();

    function localSetValue(data,key,value)

        for n=1:data.names.size
            if strcmp(data.names.at(n),key)
                data.values.erase(n);
                data.values.insert(n,value);
                return;
            end
        end
    end
end

function range=getRangeFromNodeData(ndData,id)
    ids=ndData.getValue('rangeLabels');
    starts=ndData.getValue('rangeStarts');
    ends=ndData.getValue('rangeEnds');

    if isempty(ids)
        range=[];
    else

        if contains(ids,id)
            range=rmiut.RangeUtils.idToRange(starts,ends,ids,id);
        else
            range=[];
        end
    end
end

