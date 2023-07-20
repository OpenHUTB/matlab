function[quantizedNetFcnHandle,quantizedNetwork]=dlhdlQuantizationWrapper(hFPGAQuantizer,exponents)










    targetPlatform=hFPGAQuantizer.QuantizationContext.ExecutionEnvironmentType;

    if(strcmpi(targetPlatform,'FPGA_MATLAB'))



        hPC=dlhdl.ProcessorConfig();
        hPC.ProcessorDataType='int8';

        hFPGAQuantizer.QuantizationContext.QuantizationOptions.DLProcessorConfig=hPC;


        dlHDLQuantizer=dnnfpga.compiler.DLHDLSimulation(hFPGAQuantizer.DesignEnvironment.NetFile,hFPGAQuantizer.QuantizationContext.QuantizationOptions.DLProcessorConfig,'exponentData',exponents.exponentsData);

        quantizedNetwork=dlHDLQuantizer.DeployableNetwork;
        quantizedNetFcnHandle=dlHDLQuantizer.matlabSimulation();
    elseif(strcmpi(targetPlatform,'FPGA'))


        execParams.Bitstream=hFPGAQuantizer.QuantizationContext.QuantizationOptions.Bitstream;
        execParams.Target=hFPGAQuantizer.QuantizationContext.QuantizationOptions.Target;


        dq=hFPGAQuantizer.QuantizationContext.getDLQuantizer(hFPGAQuantizer.DesignEnvironment.NetFile);



        hwQuantizer=dnnfpga.quantization.FPGAExecution(dq,execParams);

        quantizedNetwork=hwQuantizer.hW;
        quantizedNetFcnHandle=hwQuantizer.hilSim();
    end
end


