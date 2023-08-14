function here=isBlockInSet(this,block)







    tag=hdllegalizefieldname(block);
    tags=this.ImplSet(1:2:end);
    here=~isempty(find(strcmp(tag,tags),1));
end
