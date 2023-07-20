function errmsg=validateChanges(this)








    errmsg='';
    if~isempty(this.ExtraOp)
        errmsg=this.ExtraOp.validateChanges;
    end

    if~isempty(errmsg)
        return;
    end

    if~isempty(this.DataTypeRows)
        for dtrInd=1:length(this.DataTypeRows)
            errmsg=this.DataTypeRows(dtrInd).validateChanges;
            if~isempty(errmsg)
                return;
            end
        end
    end

