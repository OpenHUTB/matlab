function profileTable=parseProfileLogs(this,rawLogs,fpgaLayerParams,verbose,numImages,displayTable)




    if(ischar(rawLogs))
        rawLogs=load(rawLogs);
        rawLogs=rawLogs.rawLogs;
    end

    cnnp=this.hBitstream.getProcessor;
    hPC=this.hBitstream.getProcessorConfig;

    switch class(cnnp)
    case 'dnnfpga.processorbase.cnn5Processor'

        profileTable=dnnfpga.profiler.parseLogs(rawLogs,cnnp,'hPC',hPC,'fpgaLayerParams',fpgaLayerParams,'Verbose',verbose,'FrameNum',numImages,'Display',displayTable);
    end

end

