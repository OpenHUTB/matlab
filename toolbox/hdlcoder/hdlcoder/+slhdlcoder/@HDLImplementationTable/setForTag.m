function setForTag(this,slBlockPath,value)





    if isempty(this.Sets)
        this.Sets=containers.Map;
    end

    tag=hdllegalizefieldname(slBlockPath);
    this.Sets(tag)=value;


