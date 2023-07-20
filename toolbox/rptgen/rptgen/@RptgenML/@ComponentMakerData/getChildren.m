function c=getChildren(this)




    if isLibrary(this)
        c=[];
    else

        c=this.up.getChildren;
    end

