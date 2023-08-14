function moved=moveUp(this,justTesting)








    moved=false;

    leftComp=this.left;

    if~isempty(leftComp)
        if~(nargin>1&&justTesting)
            connect(this,leftComp,'right');
            this.updateErrorState;
            leftComp.updateErrorState;
            this.setDirty;
            insertBefore(getParentNode(this.JavaHandle),...
            this.JavaHandle,...
            leftComp.JavaHandle);

        end
        moved=true;
        return;
    end

