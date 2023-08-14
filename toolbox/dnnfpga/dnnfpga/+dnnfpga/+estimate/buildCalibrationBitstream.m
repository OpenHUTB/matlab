function BitstreamPath=buildCalibrationBitstream(ProjectPath,ProcessorConfig)










    if isequal(ProcessorConfig.TargetPlatform,'Generic Deep Learning Processor')
        msg=message('dnnfpga:config:InvalidPlatformForCalibration');
        error(msg);
    end


    dnnfpga.disp(message('dnnfpga:dnnfpgadisp:CalibrationBitStart'));

    hRD=ProcessorConfig.getReferenceDesignObject;
    readBaseAddress=hRD.getDeepLearningMemorySpace;

    writeOffset='10000000';
    writeBaseAddress=readBaseAddress+hex2dec(writeOffset);

    modelName='loopback_external_memory';
    load_system(modelName);


    hdlset_param('loopback_external_memory','CriticalPathEstimation','off');
    floatingPointConfig=getfloatingPointConfig(ProcessorConfig.SynthesisTool);
    hdlset_param('loopback_external_memory','FloatingPointTargetConfiguration',floatingPointConfig);


    hdlset_param('loopback_external_memory','HDLSubsystem','loopback_external_memory/DUT');
    hdlset_param('loopback_external_memory','OptimizationReport','off');
    hdlset_param('loopback_external_memory','ReferenceDesign',ProcessorConfig.ReferenceDesign);
    hdlset_param('loopback_external_memory','ResetType','Synchronous');
    hdlset_param('loopback_external_memory','ResourceReport','off');
    hdlset_param('loopback_external_memory','SynthesisTool',ProcessorConfig.SynthesisTool);
    hdlset_param('loopback_external_memory','SynthesisToolChipFamily',ProcessorConfig.SynthesisToolChipFamily);
    hdlset_param('loopback_external_memory','SynthesisToolDeviceName',ProcessorConfig.SynthesisToolDeviceName);
    hdlset_param('loopback_external_memory','SynthesisToolPackageName',ProcessorConfig.SynthesisToolPackageName);
    hdlset_param('loopback_external_memory','SynthesisToolSpeedValue',ProcessorConfig.SynthesisToolSpeedValue);
    hdlset_param('loopback_external_memory','TargetDirectory','hdl_prj\hdlsrc');
    hdlset_param('loopback_external_memory','TargetFrequency',ProcessorConfig.TargetFrequency);
    hdlset_param('loopback_external_memory','TargetPlatform',ProcessorConfig.TargetPlatform);
    hdlset_param('loopback_external_memory','Traceability','off');
    hdlset_param('loopback_external_memory','Workflow','Deep Learning Processor');


    hdlset_param('loopback_external_memory/DUT','AXI4SlaveIDWidth','13');
    hdlset_param('loopback_external_memory/DUT','ProcessorFPGASynchronization','Free running');


    hdlset_param('loopback_external_memory/DUT/burst_len','IOInterface','AXI4');
    hdlset_param('loopback_external_memory/DUT/burst_len','IOInterfaceMapping','x"108"');
    hdlset_param('loopback_external_memory/DUT/burst_len','IOInterfaceOptions',{'RegisterInitialValue','0'});


    hdlset_param('loopback_external_memory/DUT/burst_from_ddr','IOInterface','AXI4');
    hdlset_param('loopback_external_memory/DUT/burst_from_ddr','IOInterfaceMapping','x"10C"');
    hdlset_param('loopback_external_memory/DUT/burst_from_ddr','IOInterfaceOptions',{'RegisterInitialValue','0'});


    hdlset_param('loopback_external_memory/DUT/burst_start','IOInterface','AXI4');
    hdlset_param('loopback_external_memory/DUT/burst_start','IOInterfaceMapping','x"110"');
    hdlset_param('loopback_external_memory/DUT/burst_start','IOInterfaceOptions',{'RegisterInitialValue','0'});


    hdlset_param('loopback_external_memory/DUT/axim_rd_data','IOInterface','AXI4 Master Activation Data Read');
    hdlset_param('loopback_external_memory/DUT/axim_rd_data','IOInterfaceMapping','Data');



    hdlset_param('loopback_external_memory/DUT/axim_rd_s2m','IOInterface','AXI4 Master Activation Data Read');
    hdlset_param('loopback_external_memory/DUT/axim_rd_s2m','IOInterfaceMapping','Read Slave to Master Bus');


    hdlset_param('loopback_external_memory/DUT/axim_wr_s2m','IOInterface','AXI4 Master Activation Data Write');
    hdlset_param('loopback_external_memory/DUT/axim_wr_s2m','IOInterfaceMapping','Write Slave to Master Bus');


    hdlset_param('loopback_external_memory/DUT/axim_debug_dma_rd_s2m','IOInterface','AXI4 Master Debug Read');
    hdlset_param('loopback_external_memory/DUT/axim_debug_dma_rd_s2m','IOInterfaceMapping','Read Slave to Master Bus');


    hdlset_param('loopback_external_memory/DUT/axim_debug_dma_rd_data','IOInterface','AXI4 Master Debug Read');
    hdlset_param('loopback_external_memory/DUT/axim_debug_dma_rd_data','IOInterfaceMapping','Data');



    hdlset_param('loopback_external_memory/DUT/axim_weight_rd_s2m','IOInterface','AXI4 Master Weight Data Read');
    hdlset_param('loopback_external_memory/DUT/axim_weight_rd_s2m','IOInterfaceMapping','Read Slave to Master Bus');


    hdlset_param('loopback_external_memory/DUT/axim_weight_rd_data','IOInterface','AXI4 Master Weight Data Read');
    hdlset_param('loopback_external_memory/DUT/axim_weight_rd_data','IOInterfaceMapping','Data');



    hdlset_param('loopback_external_memory/DUT/ddr_read_done','IOInterface','AXI4');
    hdlset_param('loopback_external_memory/DUT/ddr_read_done','IOInterfaceMapping','x"11C"');


    hdlset_param('loopback_external_memory/DUT/ddr_write_done','IOInterface','AXI4');
    hdlset_param('loopback_external_memory/DUT/ddr_write_done','IOInterfaceMapping','x"120"');


    hdlset_param('loopback_external_memory/DUT/axim_rd_m2s','IOInterface','AXI4 Master Activation Data Read');
    hdlset_param('loopback_external_memory/DUT/axim_rd_m2s','IOInterfaceMapping','Read Master to Slave Bus');


    hdlset_param('loopback_external_memory/DUT/axim_wr_data','IOInterface','AXI4 Master Activation Data Write');
    hdlset_param('loopback_external_memory/DUT/axim_wr_data','IOInterfaceMapping','Data');



    hdlset_param('loopback_external_memory/DUT/axim_wr_m2s','IOInterface','AXI4 Master Activation Data Write');
    hdlset_param('loopback_external_memory/DUT/axim_wr_m2s','IOInterfaceMapping','Write Master to Slave Bus');


    hdlset_param('loopback_external_memory/DUT/axim_debug_dma_rd_m2s','IOInterface','AXI4 Master Debug Read');
    hdlset_param('loopback_external_memory/DUT/axim_debug_dma_rd_m2s','IOInterfaceMapping','Read Master to Slave Bus');


    hdlset_param('loopback_external_memory/DUT/axim_weight_rd_m2s','IOInterface','AXI4 Master Weight Data Read');
    hdlset_param('loopback_external_memory/DUT/axim_weight_rd_m2s','IOInterfaceMapping','Read Master to Slave Bus');


    hdlset_param('loopback_external_memory/DUT/ddr_rd_latency','IOInterface','AXI4');
    hdlset_param('loopback_external_memory/DUT/ddr_rd_latency','IOInterfaceMapping','x"114"');


    hdlset_param('loopback_external_memory/DUT/ddr_wr_latency','IOInterface','AXI4');
    hdlset_param('loopback_external_memory/DUT/ddr_wr_latency','IOInterfaceMapping','x"118"');




    hWC=hdlcoder.WorkflowConfig('SynthesisTool',ProcessorConfig.SynthesisTool,'TargetWorkflow','Deep Learning Processor');


    hWC.ProjectFolder='hdl_prj';




    hWC.RunTaskGenerateRTLCodeAndIPCore=true;
    hWC.RunTaskCreateProject=true;
    hWC.RunTaskBuildFPGABitstream=true;
    hWC.RunTaskEmitDLBitstreamMATFile=false;


    hWC.IPCoreRepository='';
    hWC.GenerateIPCoreReport=true;


    hWC.Objective=hdlcoder.Objective.None;
    hWC.AdditionalProjectCreationTclFiles='';



    hWC.RunExternalBuild=false;
    hWC.EnableDesignCheckpoint=false;
    hWC.TclFileForSynthesisBuild=hdlcoder.BuildOption.Default;
    hWC.DefaultCheckpointFile='Default';
    hWC.ReportTimingFailure=hdlcoder.ReportTiming.Warning;


    hWC.validate;


    hdlcoder.runWorkflow('loopback_external_memory/DUT',hWC);



    if strcmp(ProcessorConfig.SynthesisTool,'Xilinx Vivado')
        BitstreamPath=fullfile(ProjectPath,hWC.ProjectFolder,'vivado_ip_prj','vivado_prj.runs','impl_1','system_top_wrapper.bit');

    else
        BitstreamPath=fullfile(ProjectPath,hWC.ProjectFolder,'quartus_prj','system.sof');
    end


    bdclose(modelName);

end

function fpConfig=getfloatingPointConfig(synthesisTool)
    switch synthesisTool
    case 'Xilinx Vivado'
        fpConfig=hdlcoder.createFloatingPointTargetConfig('NativeFloatingPoint'...
        ,'LatencyStrategy','MIN','MantissaMultiplyStrategy','FullMultiplier');
    case 'Altera QUARTUS II'
        fpConfig=hdlcoder.createFloatingPointTargetConfig('ALTERAFPFUNCTIONS','IPConfig',{});
    otherwise
        fpConfig=[];
    end
end
