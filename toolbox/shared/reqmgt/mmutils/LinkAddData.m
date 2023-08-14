function data=LinkAddData(this)

    data=rmidd.LinkData(this.modelM3I);
    this.data=data;
    this.root.linkData.append(data);

end

