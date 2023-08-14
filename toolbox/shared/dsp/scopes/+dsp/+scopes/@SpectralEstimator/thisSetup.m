function thisSetup(obj,x)









    setupDDC(obj);

    setSpectrumSidedType(obj);
    if strcmp(obj.Method,'Welch')


        setWindow(obj);

        setNFFT(obj);
    else
        if strcmp(obj.FrequencyResolutionMethod,'NumFrequencyBands')

            setNFFT(obj);

            calculateSegmentLength(obj);
        else

            calculateSegmentLength(obj);

            setNFFT(obj);
        end

        setupSegmentBuffer(obj);

        M=obj.pNFFT;

        N=obj.pNumChannels;
        P=obj.NumTapsPerBand;
        Astop=obj.StopbandAttenuation;

        b=designMultirateFIR(1,M,ceil(P/2),Astop);

        polyMtx=cast(reshape(b,M,P),'like',real(x));
        if obj.pIsDownSamplerEnabled&&obj.pIsDownConverterEnabled
            obj.States=complex(zeros(numel(polyMtx),N,'like',x));
            obj.vextra=complex(zeros(1,M,N,'like',x));
        else
            obj.States=zeros(numel(polyMtx),N,'like',x);
            obj.vextra=zeros(1,M,N,'like',x);
        end

        [obj.PolyphaseMatrix,obj.IPPflag]=dsp.Channelizer.pmatrixdecider(x,P,M,polyMtx);

    end
    obj.pActualFstart=getFstart(obj);
    obj.pActualFstop=getFstop(obj);
    computeFrequencyVector(obj);
end
