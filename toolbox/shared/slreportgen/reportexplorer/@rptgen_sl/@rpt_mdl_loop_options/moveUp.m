function moved=moveUp(this,justTesting)









    moved=false;
    leftComp=this.left;
    while(~isempty(leftComp)&&~isa(leftComp,class(this)))
        leftComp=left(leftComp);
    end

    if~isempty(leftComp)
        if~((nargin>1)&&justTesting)
            connect(this,leftComp,'right');
            this.updateErrorState;
            leftComp.updateErrorState;
            this.setDirty;
        end
        moved=true;
    end