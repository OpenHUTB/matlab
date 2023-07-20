function data=NodeAddData(this)

    data=rmidd.NodeData(this.modelM3I);
    this.data=data;

    if(~isempty(this.root))
        this.root.nodeData.append(data);
    else
        this.nodeData.append(data);
    end
end

