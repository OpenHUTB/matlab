function updateHdlfilterINI(this)




    hprop=this.HDLParameters;
    updateINI(hprop);

    updateHdlfilterINI(this.Filters);
    if~isempty(this.NCO)
        updateHdlfilterINI(this.NCO);
    end


