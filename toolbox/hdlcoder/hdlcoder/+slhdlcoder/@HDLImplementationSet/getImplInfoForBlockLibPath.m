function value=getImplInfoForBlockLibPath(this,blockLibPath)


    tag=hdllegalizefieldname(blockLibPath);
    tags=this.ImplSet;
    pos=find(strcmp(tag,tags),1);
    if~isempty(pos)
        value=tags{pos+1};
    else
        value=[];
    end
end
