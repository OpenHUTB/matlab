function setDirty(this,isDirty)






    if(nargin<2)
        this.Dirty=true;
    else
        this.Dirty=isDirty;
    end


    if this.Dirty


        ssEditor=this;
        while~isempty(ssEditor)&&~isa(ssEditor,'RptgenML.StylesheetEditor')
            ssEditor=ssEditor.getParent;
        end

        if~isempty(ssEditor)
            ssEditor.setDirty(true);
        end
    end
