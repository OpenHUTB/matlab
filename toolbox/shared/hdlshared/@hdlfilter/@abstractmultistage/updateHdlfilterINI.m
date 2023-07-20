function updateHdlfilterINI(this)





    hprop=this.HDLParameters;
    updateINI(hprop);

    for n=1:length(this.stage)
        updateHdlfilterINI(this.Stage(n));
    end

