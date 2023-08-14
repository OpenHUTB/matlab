function p=A4MSourceSinkCb(chType,chDims,chFrameSampleTime,burstLength,bufferLength)

    p.ChDimensionsWriterChIf=chDims;
    p.ChTypeWriterChIf=chType;
    p.ChFrameSampleTimeWriterChIf=chFrameSampleTime;
    p.BurstLengthWriterChIf=burstLength;
    p.BufferLengthWriterChIf=bufferLength;

    p.BufferEventIDWriterChIf=0;
    p.InterruptHandlingTimeWriterChIf='NA';
    p.ICClockFrequencyWriter=64;
    p.ICDataWidthWriter=32;
    p.FIFODepthWriter=6;
    p.FIFOAFullDepthWriter=4;
    p.MRNumBuffers=1;
    p.MRBufferSize=getDTypeSize(chType)/8*...
    bufferLength*prod(chDims(1:end));
    p.MRRegionSize=p.MRBufferSize;

    if(burstLength==-1)
        p.ProtocolWriter='AXI4';
    else
        p.ProtocolWriter='AXI4-Stream';
    end
end

function y=getDTypeSize(type,varargin)



    switch class(type)
    case 'char'
        noapostdtype=strrep(type,'''','');
        if(contains(type,'fixdt'))
            noapostdtype=eval(noapostdtype);
            y=8*ceil(noapostdtype.WordLength/8);
        elseif(contains(type,'embedded.fi'))
            y=8*ceil(varargin{1}.WordLength/8);
        else
            switch(noapostdtype)
            case{'uint8','int8'}
                y=8;
            case{'uint16','int16'}
                y=16;
            case{'single','uint32','int32'}
                y=32;
            case{'double','uint64','int64'}
                y=64;
            otherwise
                error('Unknown dtype');
            end
        end
    case 'Simulink.NumericType'
        y=8*ceil(type.WordLength/8);
    otherwise
        error(['hsbtestpackages.HSBUnitTest: Bad data type for channel. '...
        ,'It should be char or Simulink.NumericType']);
    end
end
