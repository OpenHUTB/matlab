





function groupRemove(this,tobeDeleted)

    [~,tobeDeleted]=groupSignalIndexCheck(this,[],tobeDeleted,'G');

    tobeDeleted=sort(tobeDeleted(:),'ascend')';
    if(isempty(find(tobeDeleted==this.ActiveGroup,1)))
        this.ActiveGroup=this.ActiveGroup-length(find(tobeDeleted<this.ActiveGroup));
    elseif(length(tobeDeleted)==this.NumGroups)
        this.ActiveGroup=1;
    elseif(tobeDeleted(1)==1)
        this.ActiveGroup=1;
    else
        this.ActiveGroup=tobeDeleted(1)-1;
    end
    this.Groups(tobeDeleted)=[];
end