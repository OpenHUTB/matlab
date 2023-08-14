function pLogs=parseLogs(varargin)


    p=inputParser;
    addRequired(p,'rawLogs');
    addRequired(p,'cnnp');
    addParameter(p,'hPC',[]);
    addParameter(p,'fpgaLayerParams',[]);
    addParameter(p,'Verbose','');
    addParameter(p,'FrameNum','');
    addParameter(p,'Display','');

    parse(p,varargin{:});
    rawLogs=p.Results.rawLogs;
    cnnp=p.Results.cnnp;
    hPC=p.Results.hPC;
    fpgaLayerParams=p.Results.fpgaLayerParams;
    verbose=p.Results.Verbose;
    numFrames=p.Results.FrameNum;
    displayTable=p.Results.Display;

    switch class(cnnp)
    case 'dnnfpga.processorbase.cnn5Processor'








        supportedEvents=dnnfpga.profiler.profilerUtils.resolveSupportedEventsForDAGNet;
        pLogs=dnnfpga.profiler.ProfileLogsCNN5.getDAGNetPerformanceTable(...
        rawLogs,supportedEvents,cnnp,hPC,verbose,numFrames,fpgaLayerParams,displayTable);
    end

end
