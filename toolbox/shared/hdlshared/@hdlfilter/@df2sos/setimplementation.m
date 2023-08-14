function impl=setimplementation(this)





    uff=this.getHDLParameter('userspecified_foldingfactor');
    nummults=this.getHDLParameter('filter_nummultipliers');


    if(uff==1)
        this.implementation='parallel';
    else
        this.implementation='serial';
    end


    if strcmpi(this.implementation,'parallel');
        if(nummults==-1)
            this.implementation='parallel';
        else
            this.implementation='serial';
        end
    end
    impl=this.implementation;

    if strcmpi(impl,'serial')
        ireg=this.getHDLParameter('filter_registered_input');
        oreg=this.getHDLParameter('filter_registered_output');

        if~oreg
            this.setHDLParameter('AddOutputRegister','on');
            this.updateHdlfilterINI;
            warning(message('HDLShared:hdlfilter:serialnotwithoutoutputreg'));
        end
        if~ireg
            this.setHDLParameter('AddInputRegister','on');
            this.updateHdlfilterINI;
            warning(message('HDLShared:hdlfilter:serialnotwithoutinputreg'));
        end

    end
