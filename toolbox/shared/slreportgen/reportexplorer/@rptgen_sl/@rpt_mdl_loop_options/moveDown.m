function moved=moveDown(this,justTesting)









    moved=false;
    rightComp=this.right;

    while~isempty(rightComp)&&~isa(rightComp,class(this))
        rightComp=right(rightComp);
    end

    if~isempty(rightComp)
        if~(nargin>1&&justTesting)
            connect(rightComp,this,'right');
            this.updateErrorState;
            rightComp.updateErrorState;
            this.setDirty;
        end
        moved=true;
        return;
    end

