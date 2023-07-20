function moved=moveDown(this,justTesting)









    moved=false;

    rightComp=this.right;
    if~isempty(rightComp)
        if~(nargin>1&&justTesting)
            connect(rightComp,this,'right');
            this.updateErrorState;
            rightComp.updateErrorState;
            this.setDirty;

            insertBefore(getParentNode(rightComp.JavaHandle),...
            rightComp.JavaHandle,...
            this.JavaHandle);
        end
        moved=true;
    end

