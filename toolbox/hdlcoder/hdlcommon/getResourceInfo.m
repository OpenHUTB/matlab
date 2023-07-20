
function[info,info_EN]=getResourceInfo(p)

    currentDriver=hdlcurrentdriver;

    characHandle=hdlcoder.characterization.create;
    characHandle.doit(p);


    addFilterBom(characHandle,p);
    function str=MSG(key)
        str=message(['hdlcoder:report:',key]).getString();
    end

    info={};
    info_EN={};

    mul_freq=characHandle.getTotalFrequency('mul_comp');
    info{end+1}={MSG('Multipliers'),mul_freq};
    info_EN{end+1}={'Multipliers',mul_freq};

    add_sub_freq=characHandle.getTotalFrequency('add_comp')...
    +characHandle.getTotalFrequency('sub_comp');
    info{end+1}={MSG('Adders_Subtractors'),add_sub_freq};
    info_EN{end+1}={'Adders_Subtractors',add_sub_freq};

    reg_freq=characHandle.getTotalFrequency('reg_comp');
    info{end+1}={MSG('Registers'),reg_freq};
    info_EN{end+1}={('Registers'),reg_freq};

    ff_freq=characHandle.getTotalFlipflops();
    info{end+1}={MSG('Tot1BitRegs'),ff_freq};
    info_EN{end+1}={('Tot1BitRegs'),ff_freq};

    mm_freq=characHandle.getTotalFrequency('mem_comp');
    info{end+1}={MSG('RAMs'),mm_freq};
    info_EN{end+1}={('RAMs'),mm_freq};

    mux_freq=characHandle.getTotalFrequency('mux_comp');
    info{end+1}={MSG('Multiplexers'),mux_freq};
    info_EN{end+1}={('Multiplexers'),mux_freq};

    [total_pin_count,io_data]=slhdlcoder.HDLTraceabilityDriver.calcIOPinsForDut(p);
    info{end+1}={MSG('I_O_Bits'),total_pin_count};
    info_EN{end+1}={('I_O_Bits'),total_pin_count};

    info{end+1}={'I/O Pins_data',io_data};
    info_EN{end+1}={'I/O Pins_data',io_data};


    shiftop_freq=characHandle.getTotalShiftOps();
    info{end+1}={'Shifters',shiftop_freq};
    info_EN{end+1}={('Shifters'),shiftop_freq};

    shiftop_freq=characHandle.getTotalDynamicShiftOps();
    info{end+1}={'DynamicShifters',shiftop_freq};
    info_EN{end+1}={('DynamicShifters'),shiftop_freq};

    shiftop_freq=characHandle.getTotalStaticShiftOps();
    info{end+1}={'StaticShifters',shiftop_freq};
    info_EN{end+1}={('StaticShifters'),shiftop_freq};



    currentDriver.cgInfo.resourceInfo=info_EN;

    hdlcoder.characterization.destroy(characHandle);

end
