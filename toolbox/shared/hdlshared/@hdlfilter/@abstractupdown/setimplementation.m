function impl=setimplementation(this)




    ireg=this.getHDLParameter('filter_registered_input');
    oreg=this.getHDLParameter('filter_registered_output');

    if~oreg
        this.setHDLParameter('AddOutputRegister','on');
        this.updateHdlfilterINI;
        warning(message('HDLShared:hdlfilter:ddcducnotwithoutoutputreg'));
    end
    if~ireg
        this.setHDLParameter('AddInputRegister','on');
        this.updateHdlfilterINI;
        warning(message('HDLShared:hdlfilter:ddcducnotwithoutinputreg'));
    end


    impl=setimplementation(this.Filters);
    this.Implementation=impl;


