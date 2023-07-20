function loadFromBlock(h)













    h.outputStreamsPopup=h.Block.outputStreams;
    h.inputFilename=h.Block.inputFilename;
    h.audioFrameSize=h.Block.audioFrameSize;
    h.readRange=h.block.readRange;
    loopingOnInBlock=logical(strcmp(h.Block.loop,'on'));
    h.loop=true;
    if loopingOnInBlock
        h.numPlays=h.Block.numPlays;
    else
        h.numPlays='1';
    end
    h.colorVideoFormat=h.Block.colorVideoFormat;
    h.videoDataType=h.Block.videoDataType;
    h.audioDataType=h.Block.audioDataType;
    h.inheritSampleTime=strcmp(h.Block.inheritSampleTime,'on')==1;
    h.outputFormat=h.Block.fourcc;
    h.userDefinedSampleTime=h.Block.userDefinedSampleTime;
    h.outputEOF=logical(strcmp(h.Block.outputEOF,'on'));
    h.outSamplingMode=h.Block.outSamplingMode;


