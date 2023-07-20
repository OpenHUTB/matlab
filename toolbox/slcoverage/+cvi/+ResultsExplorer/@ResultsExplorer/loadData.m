function res=loadData(obj,selectedFileNames,addToActiveTree)




    obj.incompatibleFiles={};
    res=false;
    if~iscell(selectedFileNames)
        selectedFileNames={selectedFileNames};
    end
    nf=numel(selectedFileNames);
    usedIdMap=containers.Map('KeyType','char','ValueType','any');
    cvdatas={};
    loadedNodes={};
    for idx=1:nf
        fileName=selectedFileNames{idx};
        if obj.isLoaded(fileName)


            if addToActiveTree
                fullFileName=cvi.ResultsExplorer.Data.getFullFileName(fileName);
                data=obj.maps.fileMap(fullFileName);




                if isempty(getNodeByData(obj.root.activeTree,data))
                    passiveNode=getNodeByData(obj.root.passiveTree,data);
                    loadedNodes{end+1}=passiveNode{1};%#ok<AGROW>
                end
            end
        else

            lcvd=[];
            try
                [~,lcvd]=cvload(fileName);
            catch MEx
                if strcmpi(MEx.identifier,'Slvnv:simcoverage:cvload:IncompatibleVersion')
                    res=true;
                    obj.incompatibleFiles=[obj.incompatibleFiles,{fileName}];
                else
                    rethrow(MEx);
                end
            end
            if~isempty(lcvd)
                cvdatas=[cvdatas,{{fileName,lcvd{1}}}];%#ok<AGROW>
            end
        end
    end

    setChecksumFirstTime(obj,cvdatas);

    for idx=1:numel(cvdatas)
        lcvd=cvdatas{idx}{2};
        fileName=cvdatas{idx}{1};
        ncvd=matchChecksum(obj,lcvd);
        if~isempty(ncvd)

            if~obj.isCvdLoaded(ncvd)
                data=addCvData(obj,ncvd,fileName);
                usedIdMap(data.uniqueId)=data;
            end
        else
            res=true;
            obj.incompatibleFiles=[obj.incompatibleFiles,{fileName}];
        end
    end
    addedNodes=obj.initTrees(usedIdMap);

    if(addToActiveTree)
        nodesToActivate=[loadedNodes,addedNodes];
        for idx=1:numel(nodesToActivate)
            node=nodesToActivate{idx};
            obj.acceptDrop(obj.root.activeTree.root,node);
        end
        obj.ed.broadcastEvent('HierarchyChangedEvent',obj.root.interface);
    end
end

function node=getNodeByData(tree,data)

    node=[];
    nodes=tree.root.children;
    if~isempty(nodes)
        dataIds=cellfun(@(node)node.data.uniqueId,nodes,'UniformOutput',false);
        node=nodes(strcmp(dataIds,data.uniqueId));
    end
end

