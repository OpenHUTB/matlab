function isMdlRef=isDutModelRef(this)

    snn=this.OrigStartNodeName;
    isMdlRef=isprop(get_param(snn,'Object'),'BlockType')&&...
    strcmp(get_param(snn,'BlockType'),'ModelReference');
end
