function setImplInfoForBlockLibPath(this,blockLibPath,value)


    tag=hdllegalizefieldname(blockLibPath);
    pos=find(strcmp(tag,this.ImplSet),1);
    if~isempty(pos)
        this.ImplSet{pos+1}=value;
    else
        this.ImplSet=[this.ImplSet,{tag},{value}];
    end
end
