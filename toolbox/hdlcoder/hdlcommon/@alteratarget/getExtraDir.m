


function extraDir=getExtraDir(cmd,deviceFamily)
    extraDir='';
    synthTool=hdlgetparameter('SynthesisTool');
    if strcmpi(synthTool,'Intel Quartus Pro')
        extraDir='synth';
    elseif(alteratarget.isFamilyArria10OrLater(deviceFamily))

        fileSet=regexp(cmd,'--file-set=([\w|_]+)\s','tokens','once');
        switch(upper(fileSet{:}))
        case{'QUARTUS_SYNTH'}
            extraDir='synth';
        case{'SIM_VHDL','SIM_VERILOG'}
            extraDir='sim';
        otherwise
            assert(0);
        end
    end
end
