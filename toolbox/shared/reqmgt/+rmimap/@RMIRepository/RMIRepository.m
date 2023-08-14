classdef RMIRepository<handle















    properties
graph
proxies
    end



    methods(Access='private')



        function this=RMIRepository()

            this.graph=rmidd.Graph;





            t1=M3I.Transaction(this.graph);
            this.graph.uri=fullfile(pwd,'empty.req');
            t1.commit();
            this.proxies=containers.Map('KeyType','char','ValueType','any');
        end

        function srcRoot=loadIfExists(this,srcKey)



            [storageName,usingDefault]=rmimap.StorageMapper.getInstance.getStorageFor(srcKey);
            if exist(storageName,'file')==2
                srcRoot=this.addRoot(srcKey,storageName);
            else

                if~usingDefault
                    warning('Previously used RMI data file missing: %s',storageName);
                end
                srcRoot=[];
            end
        end



        newRoot=readRoot(this,reqFileName,srcName)
        currentModel=readGraph(this,reqFileName,modelName)
        node=addNode(this,model,id)
        node=findOrAddNode(this,rootUrl,nodeId,docKind)
        root=findOrAddRoot(this,rootUrl,docKind)
        merge(this,srcRoot)
        appendLink(this,srcRoot,dependentNode,linkData,reuse)
        clearLinks(this,elt,deleteIncoming)


        root=ensureRoot(this,name)
        updateTextNodeData(this,mdlRoot,textRoot)
        [subRootsArray,textNodeIndex]=extractSubRoots(this,parentRoot)
        dealLinkData(this,parentRoot,childRootsArray)


        updateHarnessNodeData(this,mdlRoot,harnessData)

    end


    methods

        wasRemoved=removeNode(this,rootName,nodeId)
        wasRemoved=removeRoot(this,rootName,force)
        renameRoot(this,currentName,newName,varargin)
        result=addModel(this,modelName,reqFileName)
        saveRoot(this,myRoot,reqFileName)
        destroyChildRoots(this,srcRoot)
        hasLinkData=rootHasLinkData(this,rootName)
        [hasLinks,hasLinkedItems]=rootHasLinks(this,rootName)
        hasLinks=rootHasMatchingLinks(this,srcName,filters)
        [docs,sys,counts]=countDependeeRoots(this,srcKey)
        linkData=getData(this,srcName,elementId)
        setData(this,srcName,elementId,linkData)
        childIds=getChildIds(this,modelName,idPrefix)
        nodeIds=getNodesForRoot(this,rootName,linkedOnly)
        propValue=rootProp(this,rootName,varargin)
        [success,cutObjs,cutReqs]=saveSubrootToFile(this,subrootName,saveAsName,reqFilePath)



        srcRoot=addRoot(this,srcName,reqFileName)
        subrootIds=getSubrootIds(this,mdlName,varargin)
        data=getAll(this,varargin)
        [id,isNew]=rangeToId(this,srcName,selection,shouldCreate)
        newId=newRangeId(this,srcName,range)
        mdlName=updateRanges(this,srcName,newIds,newStarts,newEnds)
        [isModified,lostIds]=verifyTextRanges(this,srcName)
        result=removeId(this,srcName,id)

        function rangeIds=getRangeIds(this,fPath)
            srcRoot=rmimap.RMIRepository.getRoot(this.graph,fPath);
            rangeIdsString=srcRoot.getProperty('rangeLabels');
            if isempty(rangeIdsString)
                rangeIds={};
            else
                rangeIds=sort(eval(rangeIdsString));
            end
        end

        function range=idToRange(this,fPath,id)


            srcRoot=rmimap.RMIRepository.getRoot(this.graph,fPath);
            if isempty(srcRoot)


                error(message('Slvnv:rmigraph:FailedToFindID',id,fPath));
            end
            ids=srcRoot.getProperty('rangeLabels');
            starts=srcRoot.getProperty('rangeStarts');
            ends=srcRoot.getProperty('rangeEnds');

            if isempty(ids)
                range='';
            else
                range=rmiut.RangeUtils.idToRange(starts,ends,ids,id);
            end
        end



        function reset(this)

            t1=M3I.Transaction(this.graph);
            this.graph.destroy();
            t1.commit;

            this.graph=rmidd.Graph;
            t2=M3I.Transaction(this.graph);
            this.graph.uri=fullfile(pwd,'empty.req');
            t2.commit();

            rmimap.RMIRepository.getRoot([],'');
        end

    end



    methods(Static=true)


        function singleObj=getInstance()
            mlock;
            persistent repository;
            if isempty(repository)||~isvalid(repository)


                repository=rmimap.RMIRepository();

            end
            singleObj=repository;
        end


        [docs,items,reqsys]=getLinkedItems(linkSource)
        populateLinkData(link)
        reqStruct=populateReqData(graphLink,reqStruct)
        writeM3I(reqFileName,srcRoot)


        clear();
    end



    methods(Static=true,Access='private')

        function source=getRoot(myGraph,sourceUrl)
            persistent latestFound
            if isempty(latestFound)
                latestFound={'',[]};
            end

            source=[];

            if isempty(myGraph)&&isempty(sourceUrl)
                latestFound={'',[]};
                return;
            elseif~isempty(latestFound{2})&&strcmp(sourceUrl,latestFound{1})

                source=latestFound{2};
                return;
            end


            for r=1:myGraph.roots.size
                root=myGraph.roots.at(r);
                if rmiut.cmp_paths(root.url,sourceUrl)
                    source=root;
                    latestFound={sourceUrl,source};
                    return;
                end
            end
            latestFound={sourceUrl,[]};
        end

        function node=getNode(root,id)
            if isempty(id)

                node=root;
            else
                node=[];

                nodes=root.nodes;
                for n=1:nodes.size
                    trial=nodes.at(n);
                    if strcmp(trial.id,id)
                        node=trial;
                        return;
                    end
                end
            end
        end

        function[links,ids]=getDependentLinks(root)
            links={};
            ids={};
            for i=1:root.nodes.size
                if root.nodes.at(i).dependentLinks.size>0
                    for j=1:root.nodes.at(i).dependentLinks.size
                        links{end+1}=root.nodes.at(i).dependentLinks.at(j);%#ok<AGROW>
                        ids{end+1}=root.nodes.at(i).id;%#ok<AGROW>
                    end
                end
            end

            if root.dependentLinks.size>0
                for j=1:root.dependentLinks.size
                    links{end+1}=root.dependentLinks.at(j);%#ok<AGROW>
                    ids{end+1}='';%#ok<AGROW>
                end
            end
        end


        [source,matched]=findSource(myGraph,sourceName,sourceType,isLoading)
        oldModel=oldModelFromGraph(oldGraph)
        yesno=isSimulinkSubroot(ndData)

    end

end





