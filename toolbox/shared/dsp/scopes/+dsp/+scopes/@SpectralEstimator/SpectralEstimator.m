classdef SpectralEstimator<matlab.System




    properties(Nontunable)
        SampleRate=10000;
    end

    properties
        FrequencySpan='Full';
        Span=10000;
        CenterFrequency=0;
        StartFrequency=-5000;
        StopFrequency=5000;
        FrequencyResolutionMethod='RBW';
        RBWSource='Auto';
        RBW=9.76;
        FFTLengthSource='Auto';
        FFTLength=1024;
        WindowLength=1024;
        Window='Hann';
        CustomWindow='';
        SidelobeAttenuation=60;



        ChannelMode='All';

        ChannelNumber=1;

        Method='Welch';

        NumTapsPerBand=12;
IPPflag

        AveragingMethod='Running';
        ForgettingFactor=0.9;

        SpectralAverages(1,1){mustBePositive,mustBeInteger}=10;

        MaxHoldTrace(1,1)logical=false;
        MinHoldTrace(1,1)logical=false;
        TwoSidedSpectrum(1,1)logical=true;
    end

    properties(Nontunable)
        DigitalDownConvert(1,1)logical=true;
    end

    properties(Constant,Hidden)
        WindowSet=matlab.system.StringSet({...
        'Rectangular',...
        'Blackman-Harris',...
        'Chebyshev',...
        'Flat Top',...
        'Hamming',...
        'Hann',...
        'Kaiser',...
        'Custom'});
        FFTLengthSourceSet=matlab.system.StringSet({'Auto','Property'});
        RBWSourceSet=matlab.system.StringSet({'Auto','Property'});
        FrequencySpanSet=matlab.system.StringSet({'Full','Span and center frequency','Start and stop frequencies'});
        ChannelModeSet=matlab.system.StringSet({'All','Single'});
        FrequencyResolutionMethodSet=matlab.system.StringSet({'RBW','WindowLength','NumFrequencyBands'});
        MethodSet=matlab.system.StringSet({'Welch','Filter bank'})
    end

    properties
        OverlapPercent=0;
        ReduceUpdates=false;
    end

    properties(Hidden)




        DataBuffer;

        MaskTester;
    end

    properties(Access=private)


sSegmentBuffer

sDDCDecimationFactor

        sDDCStage1=[]

sDDCCICNormFactor

        sDDCStage2=[]

        sDDCStage3=[]

sDDCStage3Bypassed

        sDDCOscillator=[]

sDDCOscillatorBypassed

pInputFrameLength

pNumChannels

pSegmentLength

pWindowData

pWindowPower

pNFFT



pInputProcessingFunction

pIsCurrentSpectrumTwoSided

pIsDownSamplerEnabled

pIsDownConverterEnabled



pActualSampleRate




pPeriodogramMatrix



pMaxHoldPSD



pMinHoldPSD



pNumAvgsCounter


pNewPeriodogramIdx



pDDCCoeffs

        pIsLockedFlag=false;

        pDataWrapFlag=false;

pFreqVect

pFreqVectLength


pIdxFreqVect

pActualFstart

pActualFstop

ActualRBW

PolyphaseMatrix
States
vextra

pAveragingMethod
        pPreviousExpAvgSpectrum;
        pPreviousWeight=0;
    end


    properties(Access=private)
        pFrequencySpanOld='Full';
        pSpanOld=10e3;
        pCenterFrequencyOld=0;
        pStartFrequencyOld=-5e3;
        pStopFrequencyOld=5e3;
        pRBWSourceOld='Auto';
        pRBWOld=9.76;
        pWindowOld='Hamming';
        pCustomWindowOld='';
        pSidelobeAttenuationOld=60;
        pSpectralAveragesOld=10;
        pFFTLengthSourceOld='Auto';
        pFFTLengthOld=1024;
        pMaxHoldTraceOld=false;
        pMinHoldTraceOld=false;
        pOverlapPercentOld=80;
        pChannelModeOld='All';
        pChannelNumberOld=1;
        pWindowLengthOld=1024;
        pFrequencyResolutionMethodOld='RBW';
        pMethodOld='Welch';
        pNumTapsPerBandOld=12;
        pAveragingMethodOld='Running';

    end

    properties(Access=private,Nontunable)

        StopbandAttenuation=140;
    end

    methods
        function obj=SpectralEstimator(varargin)
            setProperties(obj,nargin,varargin{:});

            obj.sSegmentBuffer=scopesutil.SpectrumBuffer(1,80,true,1);




            loadedStruct=load('SpectrumAnalyzerDDCCoefficients.mat');
            obj.pDDCCoeffs=loadedStruct.ddcCoeffs;
        end
    end

    methods(Access=protected)
        num=getNumInputsImpl(obj)
        num=getNumOutputsImpl(obj)
        flag=isInputComplexityMutableImpl(~,~)
        validateInputsImpl(~,x)
        setupImpl(obj,x)
        thisSetup(obj,x)
        processTunedPropertiesImpl(obj)
        [PSD,PSDMaxHold,PSDMinHold,F]=stepImpl(obj,x)
        resetImpl(obj)
        releaseImpl(obj)
    end

    methods(Access=private)
        calculateSegmentLength(obj)
        setWindow(obj)
        [ENBW,winFcn,winParam]=getENBW(obj,L,Win,sideLobeAttn)
        setupSegmentBuffer(obj)
        setupDDC(obj)
        setNFFT(obj)
        setSpectrumSidedType(obj)
        computeFrequencyVector(obj)
        [PSD,PSDMaxHold,PSDMinHold,Fout]=computePSD(obj,x)
        [PSD,PSDMaxHold,PSDMinHold,Fout]=computePSDReducedRate(obj,x)
        [PSD,PSDMaxHold,PSDMinHold,Fout]=computePSDNormalRate(obj,x)
        [PSD,PSDMaxHold,PSDMinHold,Fout]=computeFilterBankPSDReducedRate(obj,x)
        [PSD,PSDMaxHold,PSDMinHold,Fout]=computeFilterBankPSDNormalRate(obj,x)
        P=computePeriodogram(obj,x)
        Pos=computeOneSidedSpectrum(obj,P)
        P=convertAndScale(obj,P)
        P=computeExponentialAveraging(obj,P);
        updatePeriodogramMatrix(obj,Pall,varargin);
        P=getPeriodogramMatrixAverage(obj)
        Pdc=centerDC(~,P)
        flag=checkChangedProp(obj,prop)
        syncOldProperties(obj)
        resetMaxMinHoldStates(obj,type)
        xout=wrapData(obj,xin)
        coeffs=getCICFIRCoefficients(~,N,Fac)
        resetDDC(obj)
        releaseDDC(obj)
    end

    methods(Hidden)
        RBW=getActualRBW(obj)
        Fs=getActualSampleRate(obj);
    end

    methods(Static,Hidden)
        [dataOut,isDataReady]=noAction(~,dataIn)
        [dataOut,isDataReady]=DDCAndBuffer(obj,dataIn)

        function w=hann(n)



            if~(isempty(n)||n==floor(n))
                n=round(n);
            end

            if isempty(n)||n==0
                w=zeros(0,1);
            elseif n==1
                w=1;
            else
                if rem(n,2)

                    m=(n+1)/2;
                    x=(0:m-1)'/n;
                    w=0.5-0.5*cos(2*pi*x);
                    w=[w;w(end:-1:1)];
                else

                    m=n/2;
                    x=(0:m)'/n;
                    w=0.5-0.5*cos(2*pi*x);
                    w=[w;w(end-1:-1:1)];
                end
                w(end)=[];
            end
        end

        function w=rectwin(n)



            if~(isempty(n)||n==floor(n))
                n=round(n);
            end

            if isempty(n)||n==0
                w=zeros(0,1);
            else
                w=ones(n,1);
            end
        end
    end
end


