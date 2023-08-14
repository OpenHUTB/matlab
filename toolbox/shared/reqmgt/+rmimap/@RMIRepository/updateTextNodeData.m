function updateTextNodeData(this,mdlRoot,textRoot)






    sid=textRoot.url;
    [txtName,id]=strtok(sid,':');
    mdlName=mdlRoot.url;
    assert(strcmp(txtName,mdlName));

    mfNode=rmimap.RMIRepository.getNode(mdlRoot,id);
    if isempty(mfNode)
        mfNode=this.addNode(mdlRoot,id);
        nodeData=mfNode.addData();
        isNewNodeData=true;
    else
        nodeData=mfNode.data;
        isNewNodeData=false;
        if isempty(nodeData)
            nodeData=mfNode.addData();
        end
    end

    textRootDataLength=textRoot.data.names.size;
    for i=1:textRootDataLength
        name=textRoot.data.names.at(i);
        value=textRoot.data.values.at(i);
        if isNewNodeData
            nodeData.names.append(name);
            nodeData.values.append(value);
        else
            mfNode.setProperty(name,value);
        end
    end
    rmidata.RmiSlData.getInstance.setDirty(mdlName,true);
end



