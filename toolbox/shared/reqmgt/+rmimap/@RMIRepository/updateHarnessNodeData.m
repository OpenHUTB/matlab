function updateHarnessNodeData(this,mdlRoot,harnessData)

    [~,id]=strtok(harnessData.id,':');

    chNode=rmimap.RMIRepository.getNode(mdlRoot,id);
    if isempty(chNode)
        chNode=this.addNode(mdlRoot,id);
        nodeData=chNode.addData();
        isNewNodeData=true;
    else
        nodeData=chNode.data;
        isNewNodeData=false;
        if isempty(nodeData)
            nodeData=chNode.addData();
        end
    end

    if isNewNodeData
        nodeData.names.append('source');
        nodeData.values.append('linktype_rmi_simulink');
        nodeData.names.append('id');
        nodeData.values.append(id);
    else
        chNode.setProperty('source','linktype_rmi_simulink');
        chNode.setProperty('id',id);
    end

    mdlName=mdlRoot.url;
    if dig.isProductInstalled('Simulink')&&bdIsLoaded(mdlName)
        rmidata.RmiSlData.getInstance.setDirty(mdlName,true);
        if~isempty(harnessData.handle)

            if isNewNodeData
                rmidata.RmiSlData.getInstance.register(harnessData.handle);
            end
            rmidata.RmiSlData.getInstance.setDirty(harnessData.handle,true)
        end
    end
end

