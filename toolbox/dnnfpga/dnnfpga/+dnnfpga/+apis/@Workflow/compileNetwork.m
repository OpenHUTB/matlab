function deployableNW=compileNetwork(this,...
    inputFrameNumberLimit,uniqueActivations,hardwareNormalization,outputTileWidthX,outputTileWidthY,outputTileWidthZ,...
    verbose,activationLayer,tileActivation)











    options.target.VendorName=this.hBitstream.getVendorName;
    options.target.IPBaseAddr=this.hBitstream.getDLProcessorAddressSpace;
    [options.target.DDRBaseAddr,externalMemorySize]=this.hBitstream.getDLMemoryAddressSpace;
    options.verbose=verbose;



    if~isempty(outputTileWidthX)&&~isempty(outputTileWidthY)
        bcc=this.hBitstream.getProcessor.getBCC();
        bcc.convp.conv.outputTileWidthX=outputTileWidthX;
        bcc.convp.conv.outputTileWidthY=outputTileWidthY;
        bcc.convp.conv.outputTileWidthZ=outputTileWidthZ;
        this.hBitstream.getProcessor.setBCC(bcc);
    end

    procDataType=dnnfpga.compiler.processorKernelType(this.hBitstream.getProcessor);


    if(~isempty(this.hDLQuantizer))
        if(~isempty(this.hDLQuantizer.CalibrationStatistics))
            dataAdapter=dlinstrumentation.DataAdapter("ExponentScheme",this.hDLQuantizer.ExponentScheme);
            exponentData=dataAdapter.computeExponents(this.hDLQuantizer.CalibrationStatistics,8);
            exponentData=exponentData.exponentsData;
        else
            error(message('dnnfpga:quantization:CalibStatEmpty','dlquantizer'));
        end
        if(numel(this.hDLQuantizer.NetworkObject.OutputNames)>1||numel(this.hDLQuantizer.NetworkObject.InputNames)>1)
            error(message('dnnfpga:quantization:MIMONotSupportedForQuantization'));
        end
        if(~strcmpi(procDataType.dataTypeConv,'int8')||~strcmpi(procDataType.dataTypeFC,'int8'))
            warning(message('dnnfpga:quantization:BitstreamMismatch','dlquantizer',string(procDataType.dataTypeConv),string(procDataType.dataTypeFC)));
        end
    else
        exponentData=[];
    end


    deployableNW=dnnfpga.compiler.codegenfpga(this.Network,this.hBitstream.getProcessor,...
    'ProcessorConfig',this.hBitstream.getProcessorConfig,...
    'InputFrameNumberLimit',inputFrameNumberLimit,...
    'UniqueActivations',uniqueActivations,...
    'HardwareNormalization',hardwareNormalization,...
    'ExternalMemorySize',externalMemorySize,...
    'verbose',options.verbose,'target',options.target,...
    'ActivationLayer',activationLayer,'exponentData',exponentData,'ActivationTile',tileActivation);







    deployableNW.compileParameter.inputFrameNumberLimit=inputFrameNumberLimit;
    deployableNW.compileParameter.uniqueActivations=uniqueActivations;
    deployableNW.compileParameter.outputTileWidthX=outputTileWidthX;
    deployableNW.compileParameter.outputTileWidthY=outputTileWidthY;
    deployableNW.compileParameter.outputTileWidthZ=outputTileWidthZ;
    deployableNW.compileParameter.hardwareNormalization=hardwareNormalization;
    deployableNW.compileParameter.verbose=verbose;
end
