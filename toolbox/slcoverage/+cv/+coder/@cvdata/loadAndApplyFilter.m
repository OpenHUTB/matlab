



function res=loadAndApplyFilter(this)

    if this.valid()
        this.applyFilter();
        res=true;
    else
        res=false;
    end
