function statusNames=getStringsForBuildStatus(Vendor)


    if strcmp(Vendor,'Xilinx')
        statusNames.logName='vivado_build_prj.log';
        statusNames.bitFail='bitstream generation failed';
        statusNames.timeReport='vivado_prj.runs/impl_1/design_1_wrapper_timing_summary_routed.rpt';
    else
        statusNames.logName='quartus_compile.log';
        statusNames.bitFail='write_bitstream failed';
        statusNames.timeReport='quartus_prj.sta.rpt';
    end
    statusNames.synthesis='synthesis was successful';
    statusNames.synthesisFail='synthesis was failed';
    statusNames.implementation='implementation was successful';
    statusNames.implementationFail='implementation was failed';
    statusNames.timingFail='Timing failed';
    statusNames.timingPass='No timing failures';
    statusNames.bitPass='Bitstream generation completed';
end