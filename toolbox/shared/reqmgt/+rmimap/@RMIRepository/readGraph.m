function currentModel=readGraph(this,reqFileName,modelName)

    rf=M3I.XmiReaderFactory();
    rdr=rf.createXmiReader();
    graphModel=rmidd.Graph();
    rdr.setInitialModel(graphModel);
    oldGraph=rdr.read(reqFileName);

    if oldGraph==this.graph
        currentModel=[];
    elseif oldGraph.roots.size<1
        currentModel=[];
    else
        t1=M3I.Transaction(this.graph);
        t2=M3I.Transaction(oldGraph);
        oldModel=rmimap.RMIRepository.oldModelFromGraph(oldGraph);

        rmimap.RMIRepository.getRoot([],'');

        loadedModelName=oldModel.url;
        if~strcmp(loadedModelName,modelName)
            oldGraph.destroy;
            t1.commit;
            t2.commit;
            delete(rdr);
            error(message('Slvnv:rmigraph:UnmatchedModelName',modelName));
        end

        currentModel=rmidd.Root(this.graph);
        this.graph.roots.append(currentModel);
        currentModel.url=modelName;
        copyOldNodeData(this,currentModel,oldModel);

        sourceLinkData=oldModel.linkData;
        if sourceLinkData.size>0
            populateGraphFromOldLinkData(this,currentModel,sourceLinkData);
        end

        oldGraph.destroy;
        currentModel.setProperty('source','linktype_rmi_simulink');

        t1.commit;
        t2.commit;
    end

    delete(rdr);

    rmimap.RMIRepository.getRoot([],'');
end


function copyOldNodeData(this,currentModel,oldModel)

    for ndi=1:oldModel.nodeData.size
        nd=oldModel.nodeData.at(ndi);
        if~isempty(nd.getValue('groups'))
            newnd=rmidd.NodeData(this.graph);
            currentModel.nodeData.append(newnd);
            for ni=1:nd.names.size
                name=nd.names.at(ni);
                newnd.names.append(name);
            end
            for vi=1:nd.values.size
                value=nd.values.at(vi);
                newnd.values.append(value);
            end
        end
    end

    for ndi=1:currentModel.nodeData.size
        nd=currentModel.nodeData.at(ndi);
        if~isempty(nd.getValue('groups'))
            node=rmidd.Node(this.graph);
            currentModel.nodes.append(node);
            node.data=nd;
            node.id=node.getProperty('id');
        end
    end
end


function populateGraphFromOldLinkData(this,currentModel,oldLinkData)

    ldi=1;
    linkData=oldLinkData.at(ldi);

    while ldi<=oldLinkData.size
        node=oldLinkDataToDependentNode(currentModel,linkData);

        if isempty(node)||isa(node,'rmidd.Root')
            dependentId=oldLinkDataToDependentId(linkData);

            if isempty(node)
                node=this.addNode(currentModel,dependentId);
            end

            while ldi<=oldLinkData.size&&strcmp(node.id,dependentId)
                this.appendLink(currentModel,node,linkData,false);

                ldi=ldi+1;
                if ldi<=oldLinkData.size
                    linkData=oldLinkData.at(ldi);
                    dependentId=oldLinkDataToDependentId(linkData);
                end
            end
        else
            groupString=node.getProperty('groups');
            if~isempty(groupString)

                numbers=textscan(groupString,'%d,');
                groups=numbers{1};

                gidx=1;
                while ldi<=oldLinkData.size&&strcmp(node.id,linkData.getValue('dependentId'))
                    groupId=[node.id,'.',num2str(groups(gidx))];
                    groupNode=rmimap.RMIRepository.getNode(currentModel,groupId);

                    if isempty(groupNode)
                        groupNode=this.addNode(currentModel,groupId);
                    end
                    this.appendLink(currentModel,groupNode,linkData,false);

                    ldi=ldi+1;
                    gidx=gidx+1;

                    if ldi<=oldLinkData.size
                        linkData=oldLinkData.at(ldi);
                    end
                end

                node.data.destroy;
                node.destroy;
            else
                ordinaryNode=rmimap.RMIRepository.getNode(currentModel,node.id);

                if isempty(ordinaryNode)
                    warning('readGraph error: missing node %s%s',currentModel.url,node.id);
                    ordinaryNode=this.addNode(currentModel,node.id);
                end
                this.appendLink(currentModel,ordinaryNode,linkData,false);

                ldi=ldi+1;

                if ldi<=oldLinkData.size
                    linkData=oldLinkData.at(ldi);
                end
            end

        end
    end
end


function node=oldLinkDataToDependentNode(root,linkData)
    dependentId=linkData.getValue('dependentId');
    if strcmp(dependentId,':')
        node=root;
    else
        node=rmimap.RMIRepository.getNode(root,dependentId);
    end
end

function dependentId=oldLinkDataToDependentId(linkData)
    if strcmp(linkData.getValue('dependentId'),':')
        dependentId='';
    else
        dependentId=linkData.getValue('dependentId');
    end
end


