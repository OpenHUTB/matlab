function c=getChildren(this)




    if isLibrary(this)
        c=[];
    else
        c=getChildren(this.up);
    end

