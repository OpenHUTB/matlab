function tags=getdworkallocatorentries(this)





    tags={};

    for i=1:length(this.parentnode.children)
        if this.parentnode.children(i).allocatesdwork
            tags{end+1}=this.parentnode.children(i).object.EntryTag;%#ok
        end
    end


