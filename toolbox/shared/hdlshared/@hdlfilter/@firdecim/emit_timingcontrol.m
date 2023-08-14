function[hdl_arch,ce,phasece,counter_out,accumAndCeout]=emit_timingcontrol(this,ce)






    arch=this.implementation;

    accumAndCeout=0;

    switch arch
    case 'parallel'
        [hdl_arch,ce,phasece,counter_out,tcinfo]=emit_ringcounter(this,ce);
    case 'serial'
        [hdl_arch,ce,phasece,counter_out,tcinfo,accumAndCeout]=emit_serial_timingcontrol(this,ce);

    case 'distributedarithmetic'
        [hdl_arch,ce,phasece,counter_out,tcinfo]=emit_da_timingcontrol(this,ce);


    end

    setLocalTimingInfo(this,tcinfo);

