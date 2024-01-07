classdef SerdesSystem<handle

    properties
        TxModel=serdes.internal.serdessystem.Transmitter(...
        'Blocks',{},...
        'Name','tx1');
        RxModel=serdes.internal.serdessystem.Receiver(...
        'Blocks',{},...
        'Name','rx1');
Name

        SymbolTime=100e-12;

        SamplesPerSymbol=16;

        Modulation=2;

        Signaling='Differential';

        BERtarget=1e-6;

        ChannelData=serdes.internal.serdessystem.ChannelData;

        JitterAndNoise=serdes.internal.serdessystem.JitterAndNoise;
    end

    properties(Dependent)
dt
    end

    properties(SetAccess=private)
        ImpulseResponse=[zeros(64,1);1;zeros(63,1)];
        ImpulseDelay=1e-12;

Wave
Eye
Metrics
    end
    properties(SetAccess=private,Hidden)
        privChannelDataUpToDate=false;
        privWaveAnalysisUpToDate=false;
        privStatEyeUpToDate=false;
        privEyeMetricsUpToDate=false;
TxJitterPDF
RxJitterPDF
RxNoisePDF
    end

    properties(Hidden)
        BERPlotFloor=1e-20;
    end

    methods

        function obj=SerdesSystem(varargin)

            p=inputParser;
            p.CaseSensitive=false;
            p.addParameter('TxModel',[]);
            p.addParameter('RxModel',[]);
            p.addParameter('Name',[]);
            p.addParameter('Signaling',[]);
            p.addParameter('SamplesPerSymbol',[]);
            p.addParameter('BERtarget',[]);
            p.addParameter('SymbolTime',[]);
            p.addParameter('ChannelData',[]);
            p.addParameter('Modulation',[]);
            p.addParameter('JitterAndNoise',[]);
            p.addParameter('BERPlotFloor',[]);

            p.parse(varargin{:});
            args=p.Results;

            obj.Name=args.Name;
            if~isempty(args.TxModel)



                obj.TxModel=args.TxModel;
            end
            if~isempty(args.RxModel)
                obj.RxModel=args.RxModel;
            end

            if~isempty(args.SymbolTime)
                obj.SymbolTime=args.SymbolTime;
            end

            if~isempty(args.SamplesPerSymbol)
                obj.SamplesPerSymbol=args.SamplesPerSymbol;
            end

            if~isempty(args.BERtarget)
                obj.BERtarget=args.BERtarget;
            end

            if~isempty(args.Signaling)
                obj.Signaling=args.Signaling;
            end
            if~isempty(args.ChannelData)
                obj.ChannelData=args.ChannelData;
            end
            if~isempty(args.Modulation)

                obj.Modulation=args.Modulation;
            end
            if~isempty(args.JitterAndNoise)
                obj.JitterAndNoise=args.JitterAndNoise;
            end
            if~isempty(args.BERPlotFloor)
                obj.BERPlotFloor=args.BERPlotFloor;
            end
        end
    end

    methods
        function set.TxModel(obj,val)
            if isa(val,'serdes.internal.serdessystem.Transmitter')
                oldval=obj.TxModel;
                if~isequal(oldval,val)
                    obj.TxModel=val;
                    channelNotUpToDate(obj);
                end
            else
                coder.internal.error('serdes:serdessystem:TxModelMustBeTypeTransmitter');
            end
            waveNotUpToDate(obj);
            stateyeNotUpToDate(obj);
            metricsNotUpToDate(obj);
        end
        function set.RxModel(obj,val)
            if isa(val,'serdes.internal.serdessystem.Receiver')
                oldval=obj.RxModel;
                if~isequal(oldval,val)
                    obj.RxModel=val;
                    channelNotUpToDate(obj);
                end
            else
                coder.internal.error('serdes:serdessystem:RxModelMustBeTypeReceiver');
            end
            waveNotUpToDate(obj);
            stateyeNotUpToDate(obj);
            metricsNotUpToDate(obj);
        end
        function set.SymbolTime(obj,val)
            validateattributes(val,...
            {'numeric'},...
            {'scalar','positive','finite','<=',10e-9,'>=',5e-12},...
            '','SymbolTime');
            oldval=obj.SymbolTime;
            if~isequal(oldval,val)
                obj.SymbolTime=double(val);
                channelNotUpToDate(obj);
                waveNotUpToDate(obj);
                stateyeNotUpToDate(obj);
                metricsNotUpToDate(obj);
            end
        end
        function set.SamplesPerSymbol(obj,val)
            validateattributes(val,...
            {'numeric'},...
            {'scalar','positive','integer','finite'},...
            '','SamplesPerSymbol');
            mustBeMember(val,[8,16,32,64,128]);
            oldval=obj.SamplesPerSymbol;
            if~isequal(oldval,val)
                obj.SamplesPerSymbol=double(val);
                channelNotUpToDate(obj);
                waveNotUpToDate(obj);
                stateyeNotUpToDate(obj);
                metricsNotUpToDate(obj);
            end
        end
        function set.BERtarget(obj,val)
            validateattributes(val,...
            {'numeric'},...
            {'scalar','positive','finite','<=',1e-3},...
            '','BERtarget');
            oldval=obj.BERtarget;
            if~isequal(oldval,val)
                obj.BERtarget=double(val);
                metricsNotUpToDate(obj);
            end
        end
        function set.Modulation(obj,val)
            validateattributes(val,...
            {'numeric'},...
            {'scalar','positive','integer','finite'},...
            '','Modulation');
            mustBeMember(val,[2:32])
            oldval=obj.Modulation;
            if~isequal(oldval,val)
                obj.Modulation=double(val);
                waveNotUpToDate(obj);
                stateyeNotUpToDate(obj);
                metricsNotUpToDate(obj);
            end
        end
        function set.Signaling(obj,val)
            validateattributes(val,...
            {'char','string'},...
            {},'','Signaling');
            mustBeMember(val,{'Differential','Single-ended'})
            obj.Signaling=val;
        end
        function set.ChannelData(obj,val)
            if isa(val,'serdes.internal.serdessystem.ChannelData')
                oldval=obj.ChannelData;
                if~isequal(oldval,val)
                    obj.ChannelData=val;
                    channelNotUpToDate(obj);
                end
            else
                coder.internal.error('serdes:serdessystem:ChannelDataMustBeTypeChannelData');
            end
            channelNotUpToDate(obj);
            waveNotUpToDate(obj);
            stateyeNotUpToDate(obj);
            metricsNotUpToDate(obj);
        end
        function set.JitterAndNoise(obj,val)
            if isa(val,'serdes.internal.serdessystem.JitterAndNoise')
                oldval=obj.JitterAndNoise;
                if~isequal(oldval,val)
                    obj.JitterAndNoise=val;
                    stateyeNotUpToDate(obj);
                    metricsNotUpToDate(obj);
                end
            else
                coder.internal.error('serdes:serdessystem:JitterAndNoiseMustBeType');
            end
        end
    end

    methods
        function dt=get.dt(obj)
            dt=obj.SymbolTime/obj.SamplesPerSymbol;
        end
        function val=get.ImpulseResponse(obj)

            if~obj.privChannelDataUpToDate
                channel(obj);
            end
            val=obj.ImpulseResponse;
        end
        function val=get.ImpulseDelay(obj)
            if~obj.privChannelDataUpToDate
                channel(obj);
            end
            val=obj.ImpulseDelay;
        end
        function val=get.Eye(obj)
            if~obj.privStatEyeUpToDate
                calcStatEye(obj);
            end
            val=obj.Eye;
        end
        function val=get.Metrics(obj)
            if~obj.privEyeMetricsUpToDate
                calcEyeMetrics(obj);
            end
            val=obj.Metrics;
        end
        function val=get.Wave(obj)
            if~obj.privWaveAnalysisUpToDate
                analysis(obj);
            end
            val=obj.Wave;
        end
        function val=get.TxJitterPDF(obj)
            if~obj.privStatEyeUpToDate
                calcStatEye(obj);
            end
            val=obj.TxJitterPDF;
        end
        function val=get.RxJitterPDF(obj)
            if~obj.privStatEyeUpToDate
                calcStatEye(obj);
            end
            val=obj.RxJitterPDF;
        end
        function val=get.RxNoisePDF(obj)
            if~obj.privStatEyeUpToDate
                calcStatEye(obj);
            end
            val=obj.RxNoisePDF;
        end
    end

    methods(Access=private)
        function channelNotUpToDate(obj)
            obj.privChannelDataUpToDate=false;
        end
        function waveNotUpToDate(obj)
            obj.privWaveAnalysisUpToDate=false;
        end
        function stateyeNotUpToDate(obj)
            obj.privStatEyeUpToDate=false;
        end
        function metricsNotUpToDate(obj)
            obj.privEyeMetricsUpToDate=false;
        end

        function obj=channel(obj)

            switch obj.ChannelData.OptionSel
            case 1

                impulse_in=obj.ChannelData.Impulse;
                dt_in=obj.ChannelData.dt;

                if dt_in~=obj.dt

                    t_in=dt_in*(0:(length(impulse_in)-1))';



                    nsymbols=round(t_in(end)/obj.dt)/obj.SamplesPerSymbol;
                    coder.internal.errorIf(nsymbols>1e6,...
                    'serdes:serdessystem:ImpulseSampleIntervalTooLarge',...
                    sprintf('%g',dt_in),sprintf('%g',obj.dt));
                    t=(0:obj.dt:t_in(end))';

                    if length(t)<obj.SamplesPerSymbol*3
                        t=obj.dt*(0:obj.SamplesPerSymbol*3-1)';
                    end



                    [~,maxNdx]=max(impulse_in(:,1));
                    tmax=t_in(maxNdx);
                    [~,minNdx]=min(abs(t-tmax));
                    tshift=t(minNdx)-tmax;


                    localImpulse=interp1(t_in,impulse_in,t-tshift,'pchip',0);

                    [~,maxIndex]=max(abs(localImpulse(:,1)));
                    obj.ImpulseResponse=localImpulse;
                    obj.ImpulseDelay=(maxIndex-1)*obj.dt;
                else
                    obj.ImpulseResponse=impulse_in;
                    [~,maxIndex]=max(abs(impulse_in(:,1)));
                    obj.ImpulseDelay=(maxIndex-1)*obj.dt;
                end



















            case 3

                if obj.ChannelData.EnableCrosstalk
                    if strcmpi(obj.ChannelData.CrosstalkSpecification,'Custom')
                        chan=serdes.ChannelLoss(...
                        'Loss',obj.ChannelData.ChannelLossdB,...
                        'TxR',obj.TxModel.AnalogModel.R,...
                        'TxC',obj.TxModel.AnalogModel.C,...
                        'RxR',obj.RxModel.AnalogModel.R,...
                        'RxC',obj.RxModel.AnalogModel.C,...
                        'dt',obj.dt,...
                        'Zc',obj.ChannelData.ChannelDifferentialImpedance,...
                        'VoltageSwingIdeal',obj.TxModel.VoltageSwingIdeal,...
                        'RiseTime',obj.TxModel.RiseTime,...
                        'TargetFrequency',obj.ChannelData.ChannelLossFreq,...
                        'EnableCrosstalk',obj.ChannelData.EnableCrosstalk,...
                        'CrosstalkSpecification',obj.ChannelData.CrosstalkSpecification,...
                        'fb',obj.ChannelData.fb,...
                        'FEXTICN',obj.ChannelData.FEXTICN,...
                        'Aft',obj.ChannelData.Aft,...
                        'Tft',obj.ChannelData.Tft,...
                        'NEXTICN',obj.ChannelData.NEXTICN,...
                        'Ant',obj.ChannelData.Ant,...
                        'Tnt',obj.ChannelData.Tnt);
                    else

                        chan=serdes.ChannelLoss(...
                        'Loss',obj.ChannelData.ChannelLossdB,...
                        'TxR',obj.TxModel.AnalogModel.R,...
                        'TxC',obj.TxModel.AnalogModel.C,...
                        'RxR',obj.RxModel.AnalogModel.R,...
                        'RxC',obj.RxModel.AnalogModel.C,...
                        'dt',obj.dt,...
                        'Zc',obj.ChannelData.ChannelDifferentialImpedance,...
                        'VoltageSwingIdeal',obj.TxModel.VoltageSwingIdeal,...
                        'RiseTime',obj.TxModel.RiseTime,...
                        'TargetFrequency',obj.ChannelData.ChannelLossFreq,...
                        'EnableCrosstalk',obj.ChannelData.EnableCrosstalk,...
                        'CrosstalkSpecification',obj.ChannelData.CrosstalkSpecification,...
                        'fb',obj.ChannelData.fb);
                    end
                else
                    chan=serdes.ChannelLoss(...
                    'Loss',obj.ChannelData.ChannelLossdB,...
                    'TxR',obj.TxModel.AnalogModel.R,...
                    'TxC',obj.TxModel.AnalogModel.C,...
                    'RxR',obj.RxModel.AnalogModel.R,...
                    'RxC',obj.RxModel.AnalogModel.C,...
                    'dt',obj.dt,...
                    'Zc',obj.ChannelData.ChannelDifferentialImpedance,...
                    'VoltageSwingIdeal',obj.TxModel.VoltageSwingIdeal,...
                    'RiseTime',obj.TxModel.RiseTime,...
                    'TargetFrequency',obj.ChannelData.ChannelLossFreq);
                end
                obj.ImpulseResponse=chan.impulse;
                [~,maxIndex]=max(abs(chan.impulse(:,1)));
                obj.ImpulseDelay=(maxIndex-1)*obj.dt;

            otherwise

                imp=zeros(128*obj.SamplesPerSymbol,1);
                imp(obj.SamplesPerSymbol*2)=1/obj.dt;
                obj.ImpulseResponse=imp;
                [~,maxIndex]=max(abs(imp));
                obj.ImpulseDelay=(maxIndex-1)*obj.dt;
            end
            obj.privChannelDataUpToDate=true;
        end

        function[TxJitter,RxJitter,RxNoise]=jitter(obj,v,t)







            TxDCD=pmf(obj.JitterAndNoise.Tx_DCD,obj.SymbolTime,t);
            TxDj=pmf(obj.JitterAndNoise.Tx_Dj,obj.SymbolTime,t);
            TxSj=pmf(obj.JitterAndNoise.Tx_Sj,obj.SymbolTime,t);
            TxRj=pmf(obj.JitterAndNoise.Tx_Rj,obj.SymbolTime,t);


            TxJitter=serdes.internal.serdessystem.jitter.normalizedConvolution(...
            TxDCD,TxDj,TxSj,TxRj);


            RxDCD=pmf(obj.JitterAndNoise.Rx_DCD,obj.SymbolTime,t);
            RxDj=pmf(obj.JitterAndNoise.Rx_Dj,obj.SymbolTime,t);
            RxSj=pmf(obj.JitterAndNoise.Rx_Sj,obj.SymbolTime,t);
            RxRj=pmf(obj.JitterAndNoise.Rx_Rj,obj.SymbolTime,t);

            RxClkDCD=pmf(obj.JitterAndNoise.Rx_Clock_Recovery_DCD,obj.SymbolTime,t);
            RxClkDj=pmf(obj.JitterAndNoise.Rx_Clock_Recovery_Dj,obj.SymbolTime,t);
            RxClkSj=pmf(obj.JitterAndNoise.Rx_Clock_Recovery_Sj,obj.SymbolTime,t);
            RxClkRj=pmf(obj.JitterAndNoise.Rx_Clock_Recovery_Rj,obj.SymbolTime,t);


            RxJitter=serdes.internal.serdessystem.jitter.normalizedConvolution(...
            RxDCD,RxDj,RxSj,...
            RxClkDCD,RxClkDj,RxClkSj,...
            RxRj,RxClkRj);


            Rx_GaussianNoise=pmf(obj.JitterAndNoise.Rx_GaussianNoise,1,v);
            Rx_UniformNoise=pmf(obj.JitterAndNoise.Rx_UniformNoise,1,v);

            RxNoise=serdes.internal.serdessystem.jitter.normalizedConvolution(...
            Rx_GaussianNoise,Rx_UniformNoise);
        end
    end

    methods
        function varargout=analysis(obj)























            narginchk(1,1)
            nargoutchk(0,1)


            assert(isa(obj,'serdes.internal.serdessystem.SerdesSystem'))


            UnEQimpulse=obj.ImpulseResponse;


            TxRxSelectFlag=1;
            [EQimpulse,TxParams]=initAnalysis(obj,UnEQimpulse,TxRxSelectFlag);


            TxRxSelectFlag=2;
            [EQimpulse,RxParams]=initAnalysis(obj,EQimpulse,TxRxSelectFlag);

            t1=(0:length(EQimpulse)-1)'*obj.dt;

            samplespersymbol=round(obj.SymbolTime/obj.dt);
            UnEQpulse=impulse2pulse(UnEQimpulse,samplespersymbol,obj.dt);
            EQpulse=impulse2pulse(EQimpulse,samplespersymbol,obj.dt);

            if obj.Modulation==4
                symbolPattern=serdes.utilities.prqsP503;
                symbolCode=[-1/2,-1/6,1/6,1/2];
                dp2=symbolCode(symbolPattern+1);
                dataPattern=dp2(1:127);
            elseif obj.Modulation==3
                M=128;


                ord=7;
                b_seed=zeros(1,ord);
                b_seed(end)=1;

                M1=M+mod(M,2);
                symbolPattern=zeros(1,M1);
                for ii=1:M1/2
                    [b,b_seed]=prbs(ord,3,b_seed);
                    symbolPattern(2*ii-1:2*ii)=SerdesSystem.threebit2ternary(b);
                end

                dataPattern=symbolPattern/2;
            else
                ord=7;
                symbolPattern=prbs(ord,2^ord-1);
                symbolCode=[-1/2,1/2];
                dataPattern=symbolCode(symbolPattern+1);
            end
            UnEQwaveform=pulse2wave(UnEQpulse,dataPattern,samplespersymbol);
            EQwaveform=pulse2wave(EQpulse,dataPattern,samplespersymbol);
            t2=(0:length(EQwaveform)-1)'*obj.dt;

            outparams=[TxParams,RxParams];


            localwave.impulse.eq=EQimpulse;
            localwave.impulse.uneq=UnEQimpulse;
            localwave.impulse.t=t1;
            localwave.pulse.eq=EQpulse;
            localwave.pulse.uneq=UnEQpulse;
            localwave.pulse.t=t1;
            localwave.wave.eq=EQwaveform;
            localwave.wave.uneq=UnEQwaveform;
            localwave.wave.t=t2;
            localwave.outparams=outparams;



            localwave.plot.legend=getWaveLegend(obj);
            [~,prefixstr1,Y1]=serdes.utilities.num2prefix(obj.SymbolTime*127);
            localwave.plot.tprefix=prefixstr1;
            localwave.plot.t1=t1*Y1;
            localwave.plot.t2=t2*Y1;


            obj.Wave=localwave;

            if nargout==1
                localwave2.t1=t1;
                localwave2.impulse=[UnEQimpulse,EQimpulse];
                localwave2.pulse=[UnEQpulse,EQpulse];
                localwave2.t2=t2;
                localwave2.wave=[UnEQwaveform,EQwaveform];
                localwave2.outparams=outparams;
                varargout{1}=localwave2;
            end

            obj.privWaveAnalysisUpToDate=true;
        end

        function validateSerdesSystem(obj)


            coder.internal.errorIf(1/obj.dt<obj.ChannelData.ChannelLossFreq,...
            'serdes:serdessystem:ChannelLossFreqTooLarge',...
            sprintf('%g',obj.ChannelData.ChannelLossFreq),sprintf('%g',1/obj.dt));


            analysis(obj);




            ntxBlocks=length(obj.TxModel.Blocks);
            nrxBlocks=length(obj.RxModel.Blocks);
            txBlockNames=cell(1,ntxBlocks);
            rxBlockNames=cell(1,nrxBlocks);
            for ii=1:ntxBlocks
                txBlockNames{ii}=obj.TxModel.Blocks{ii}.BlockName;
            end
            for ii=1:nrxBlocks
                rxBlockNames{ii}=obj.RxModel.Blocks{ii}.BlockName;
            end


            allBlockNames=[txBlockNames,rxBlockNames];
            allBlockID=[ones(1,ntxBlocks),2*ones(1,nrxBlocks)];


            [uBlockNames,ia]=unique(allBlockNames);
            needNewNameNdx=ones(1,ntxBlocks+nrxBlocks);
            needNewNameNdx(ia)=0;

            for ii=1:ntxBlocks+nrxBlocks
                if needNewNameNdx(ii)==1
                    oldName=allBlockNames{ii};


                    suffixNumStr=regexp(oldName,'\d+$','match','once');
                    baseName=oldName(1:end-length(suffixNumStr));
                    suffixNum=str2double(suffixNumStr);
                    if isnan(suffixNum)
                        suffixNum=0;
                    end


                    nameIsNotUnique=false;
                    while~nameIsNotUnique
                        suffixNum=suffixNum+1;
                        candidateName=sprintf('%s%i',baseName,suffixNum);

                        nameIsNotUnique=~ismember(candidateName,uBlockNames);
                        if nameIsNotUnique

                            uBlockNames=[uBlockNames,candidateName];%#ok<AGROW>


                            if allBlockID(ii)==1


                                coder.internal.warning('serdes:serdessystem:BlockNameRenamed',...
                                'Tx',num2str(ii),oldName,candidateName);

                                release(obj.TxModel.Blocks{ii});
                                obj.TxModel.Blocks{ii}.BlockName=candidateName;
                            elseif allBlockID(ii)==2
                                ndx=ii-ntxBlocks;


                                coder.internal.warning('serdes:serdessystem:BlockNameRenamed',...
                                'Rx',num2str(ndx),oldName,candidateName);
                                release(obj.RxModel.Blocks{ndx});
                                obj.RxModel.Blocks{ndx}.BlockName=candidateName;
                            end
                        end
                    end
                end
            end

        end

        function exporter=exportToSimulink(obj,varargin)

            if nargin==2
                flag=varargin{1};
            else
                flag=false;
            end
            validateattributes(flag,{'logical'},{},'','flag');


            validateSerdesSystem(obj)


            exporter=serdes.internal.apps.serdesdesigner.TestbenchExport(obj);
            exporter.exportSimulink(flag);
        end

        function plotStatEye(obj,varargin)



            localeye=obj.Eye;
            localmetrics=obj.Metrics;


            bathtubs=localmetrics.bathtubs;
            nanbathtubs=isnan(bathtubs);
            plotfloorvalue=log10(obj.BERPlotFloor/10);
            for ii=1:size(bathtubs,2)
                if any(nanbathtubs(:,ii))
                    ndx1=find(nanbathtubs(:,ii),1,'first');
                    if ndx1-1>0&&(bathtubs(ndx1-1,ii)>plotfloorvalue)
                        bathtubs(ndx1,ii)=plotfloorvalue;
                    end
                    ndx2=find(nanbathtubs(:,ii),1,'last');
                    if ndx2+1<=size(bathtubs,1)&&(bathtubs(ndx2+1,ii)>plotfloorvalue)
                        bathtubs(ndx2,ii)=plotfloorvalue;
                    end
                end
            end

            si_eyecmap=serdes.utilities.SignalIntegrityColorMap;
            linecolor=[0.75,0,0.75];



            localClockPDF=localeye.ClockPDF;
            ndx0=localClockPDF==0;
            minNot0=min(localClockPDF(~ndx0));
            localClockPDF(ndx0)=min([obj.BERPlotFloor/10,minNot0]);


            [mincval,maxcval]=serdes.internal.colormapToScale(localeye.Stateye,si_eyecmap,1e-18);


            if nargin==2&&ishandle(varargin{1})&&strcmp(get(varargin{1},'type'),'figure')
                figure(varargin{1})
            end
            cla reset
            title('Statistical Eye')
            yyaxis('right')
            semilogy(localeye.Th2,10.^bathtubs,localeye.Th2,localClockPDF,...
            'color',linecolor,'linewidth',2,'linestyle','-')
            set(gca,'YColor',linecolor)
            ylabel('[Probability]')
            axis([localeye.Th2(1),localeye.Th2(end)+localeye.Th2(2),...
            obj.BERPlotFloor,1])

            yyaxis('left')
            hold('on')
            imagesc(localeye.Th2,localeye.Vh,localeye.Stateye,[mincval,maxcval])
            axis('xy');
            colormap(si_eyecmap)

            plot(localeye.Th2,localmetrics.contours,'m-','linewidth',2)
            xlabel("["+localeye.tprefix+"]")
            ylabel('[V]')

        end

        function plotPulse(obj,varargin)


            if nargin==2&&ishandle(varargin{1})&&strcmp(get(varargin{1},'type'),'figure')
                figure(varargin{1})
            end
            cla reset


            plot(obj.Wave.plot.t1,[obj.Wave.pulse.uneq,obj.Wave.pulse.eq])
            xlabel("["+obj.Wave.plot.tprefix+"]")
            ylabel('[V]')
            grid on
            legend(obj.Wave.plot.legend(:))
            title('Pulse Response')
        end
        function plotImpulse(obj,varargin)


            if nargin==2&&ishandle(varargin{1})&&strcmp(get(varargin{1},'type'),'figure')
                figure(varargin{1})
            end

            cla reset

            plot(obj.Wave.plot.t1,[obj.Wave.impulse.uneq,obj.Wave.impulse.eq])
            xlabel("["+obj.Wave.plot.tprefix+"]")
            ylabel('[V]')
            grid on
            legend(obj.Wave.plot.legend(:))
            title('Impulse Response')
        end
        function plotWavePattern(obj,varargin)


            if nargin==2&&ishandle(varargin{1})&&strcmp(get(varargin{1},'type'),'figure')
                figure(varargin{1})
            end

            cla reset

            plot(obj.Wave.plot.t2,[obj.Wave.wave.uneq,obj.Wave.wave.eq])
            xlabel("["+obj.Wave.plot.tprefix+"]")
            ylabel('[V]')
            grid on
            legend(obj.Wave.plot.legend(:))
            title('PRBS Waveform Response')
        end

        function varargout=analysisReport(obj)

            kk=1;
            reportOut{kk}=sprintf('\nSerdes Analysis Summary Report');


            switch obj.Modulation
            case 4
                eyeLabel={'Lower  ','Center ','Upper  '};
            case 3
                eyeLabel={'Lower ','Upper '};
            otherwise
                eyeLabel={''};
            end
            if obj.Modulation>4
                ehStr=mat2str(flipud(obj.Metrics.summary.EH)',3);
                ehStr(ehStr=='[')=[];
                ehStr(ehStr==']')=[];
                kk=kk+1;
                reportOut{kk}=['Eye Height (V)  ',ehStr];
                ewStr=mat2str(flipud(obj.Metrics.summary.EW)',3);
                ewStr(ewStr=='[')=[];
                ewStr(ewStr==']')=[];
                kk=kk+1;
                reportOut{kk}=['Eye Width (',obj.Metrics.tprefix,')  ',ewStr];
            else
                for ii=length(obj.Metrics.summary.EH):-1:1
                    kk=kk+1;
                    reportOut{kk}=sprintf('Eye Height %s(V)   %g',...
                    eyeLabel{ii},obj.Metrics.summary.EH(ii));
                end
                for ii=length(obj.Metrics.summary.EW):-1:1
                    kk=kk+1;
                    reportOut{kk}=sprintf('Eye Width %s(%s)   %g',...
                    eyeLabel{ii},obj.Metrics.tprefix,obj.Metrics.summary.EW(ii));
                end
            end

            kk=kk+1;
            reportOut{kk}=sprintf('COM				%g',obj.Metrics.summary.COMestimate);
            kk=kk+1;
            reportOut{kk}=sprintf('VEC				%g',obj.Metrics.summary.VEC);
            if obj.Modulation>2
                kk=kk+1;
                reportOut{kk}=sprintf('Eye Linearity	%g',obj.Metrics.summary.eyeLinearity);
            end


            for ii=1:length(obj.Wave.outparams)
                if~isempty(obj.Wave.outparams{ii})
                    sout=serdes.utilities.FlattenStruct(obj.Wave.outparams{ii});
                    for jj=1:size(sout,1)
                        kk=kk+1;
                        reportOut{kk}=sprintf('%s		%s',sout{jj,1:2});
                    end
                end
            end


            if nargout==0
                for kk=1:length(reportOut)
                    fprintf('%s\n',reportOut{kk});
                end
            else
                varargout{1}=reportOut;
            end

        end

    end

    methods(Access=private)
        function calcStatEye(obj)





            [LocalStatEye,localVh,localTh]=pulse2stateye(...
            obj.Wave.pulse.eq,obj.SamplesPerSymbol,obj.Modulation);


            [TxJitter,RxJitter,RxNoise]=jitter(obj,localVh,(localTh-0.5)*obj.SymbolTime);


            if obj.JitterAndNoise.Rx_Clock_Recovery_Mean.Value~=0
                if strcmp(obj.JitterAndNoise.Rx_Clock_Recovery_Mean.Type,'UI')
                    clkMean=obj.JitterAndNoise.Rx_Clock_Recovery_Mean.Value*obj.SymbolTime;
                else
                    clkMean=obj.JitterAndNoise.Rx_Clock_Recovery_Mean.Value;
                end
            else
                clkMean=0;
            end
            clkMeanSamples=round(clkMean/(obj.SymbolTime/length(RxJitter)));




            if sum(TxJitter)~=0









                fshiftTxJitter=fftshift(TxJitter);


                cr=fshiftTxJitter(:)';
                C=toeplitz(cr,[cr(1),fliplr(cr(2:end))]);


                localJitteredEye=LocalStatEye*C;
            else
                localJitteredEye=LocalStatEye;
            end



            if strcmp(obj.JitterAndNoise.RxClockMode,'ideal')

                if sum(RxJitter)~=0
                    localClockPDF=circshift(RxJitter,clkMeanSamples);
                else

                    localClockPDF=zeros(size(RxJitter));
                    localClockPDF(round(length(localClockPDF)/2))=1;
                    localClockPDF=circshift(localClockPDF,clkMeanSamples);
                end
            else

                if sum(RxJitter)~=0


                    fshiftRxJitter=fftshift(RxJitter);


                    cr=fshiftRxJitter(:)';
                    C=toeplitz(cr,[cr(1),fliplr(cr(2:end))]);


                    localJitteredEye=localJitteredEye*C;
                end


                localClockPDF=zeros(size(RxJitter));
                localClockPDF(round(length(localClockPDF)/2))=1;
                localClockPDF=circshift(localClockPDF,clkMeanSamples);
            end


            if sum(RxNoise)~=0
                for ii=1:size(localJitteredEye,2)

                    localJitteredEye(:,ii)=conv(localJitteredEye(:,ii),RxNoise,'same');
                end
            end

            [~,prefixstr2,Y2]=serdes.utilities.num2prefix(obj.SymbolTime);
            th2=localTh*obj.SymbolTime*Y2;


            localeye.Stateye=localJitteredEye;
            localeye.Vh=localVh;
            localeye.Th=localTh;
            localeye.Th2=th2;
            localeye.ClockPDF=localClockPDF;
            localeye.tprefix=prefixstr2;


            obj.Eye=localeye;
            obj.privStatEyeUpToDate=true;

            obj.TxJitterPDF=TxJitter;
            obj.RxJitterPDF=RxJitter;
            obj.RxNoisePDF=RxNoise;
        end

        function calcEyeMetrics(obj)





            localeye=obj.Eye;


            [eyeLinearity,VEC,contours,bathtubs,EH,aHeight,...
            bestEH,bestEyeHeightVoltage,bestEyeHeightTime,...
            bestEyeWidth,bestEyeWidthTime,bestEyeWidthVoltage,...
            EW,vmidThreshold,eyeAreas,eyeAreaMetric,COM]=...
            serdes.utilities.calculatePAMnEye(obj.Modulation,obj.BERtarget,...
            localeye.Th2(1),localeye.Th2(end),localeye.Vh(1),localeye.Vh(end),...
            localeye.Stateye);




            localmetrics.contours=contours;
            localmetrics.bathtubs=bathtubs;
            localmetrics.Th=localeye.Th;
            localmetrics.Th2=localeye.Th2;
            localmetrics.tprefix=localeye.tprefix;
            summary.EH=EH;
            summary.bestEH=bestEH;
            summary.EW=EW;
            summary.VEC=VEC;
            summary.eyeAreas=eyeAreas;
            summary.COMestimate=COM;
            summary.eyeLinearity=eyeLinearity;
            localmetrics.summary=summary;

            obj.Metrics=localmetrics;
            obj.privEyeMetricsUpToDate=true;
        end

        function[impulse,paramsOut]=initAnalysis(obj,impulse,select)











            validateattributes(select,{'numeric'},{'scalar','positive','<=',2},'','select',3)


            if select==1
                blocks=obj.TxModel.Blocks;
            else
                blocks=obj.RxModel.Blocks;
            end

            if isempty(blocks)
                paramsOut=cell(1,length(blocks));
                return
            end



            checkSerdesObj=@(obj1)any(ismember(superclasses(obj1),'serdes.SerdesAbstractSystemObject'));
            isSerDes=cellfun(checkSerdesObj,blocks);

            if any(~isSerDes)
                coder.internal.error('serdes:serdessystem:BlockNotSerDes',...
                class(blocks{find(~isSerDes,1,'first')}));
            end


            blockEnable=true(1,length(blocks));


            SOexclusion={};
            SOclasses=cellfun(@class,blocks,'UniformOutput',false);
            notThisBlockFlag=ismember(SOclasses,SOexclusion);
            blockEnable(notThisBlockFlag)=false;


            if isempty(blocks)
                SOisLinear=1;
            else
                SOisLinear=cellfun(@get,blocks,repmat({'IsLinear'},1,length(blocks)));
            end




            blockEnable(~SOisLinear)=false;





            waveOut=impulse;






























            paramsOut=cell(1,length(blocks));


            for ii=1:length(blocks)
                if blockEnable(ii)




                    blocks{ii}.SymbolTime=obj.SymbolTime;
                    blocks{ii}.SampleInterval=obj.dt;
                    blocks{ii}.Modulation=obj.Modulation;

                    if isprop(blocks{ii},'WaveType')


                        release(blocks{ii})

                        blocks{ii}.WaveType='Impulse';




















                    end


                    outNames=getOutputNames(blocks{ii});
                    numberOfOutputs=length(outNames);


                    rname=blocks{ii}.BlockName;


                    if isa(blocks{ii},'serdes.CDR')

                        [b1,b2,b3]=step(blocks{ii},waveOut);


                        tmpstruct=struct(rname,struct(outNames(1),b1));
                        tmpstruct.(rname).(outNames(2))=b2;
                        tmpstruct.(rname).(outNames(3))=b3;
                        paramsOut{ii}=tmpstruct;

                        continue
                    end

                    switch numberOfOutputs
                    case 2
                        [waveOut,b1]=step(blocks{ii},waveOut);


                        paramsOut{ii}=struct(rname,struct(outNames(2),b1));
                    case 3
                        [waveOut,b1,b2]=step(blocks{ii},waveOut);


                        tmpstruct=struct(rname,struct(outNames(2),b1));
                        tmpstruct.(rname).(outNames(3))=b2;
                        paramsOut{ii}=tmpstruct;
                    case 4
                        [waveOut,b1,b2,b3]=step(blocks{ii},waveOut);


                        tmpstruct=struct(rname,struct(outNames(2),b1));
                        tmpstruct.(rname).(outNames(3))=b2;
                        tmpstruct.(rname).(outNames(4))=b3;
                        paramsOut{ii}=tmpstruct;
                    case 5
                        [waveOut,b1,b2,b3,b4]=step(blocks{ii},waveOut);


                        tmpstruct=struct(rname,struct(outNames(2),b1));
                        tmpstruct.(rname).(outNames(3))=b2;
                        tmpstruct.(rname).(outNames(4))=b3;
                        tmpstruct.(rname).(outNames(5))=b4;
                        paramsOut{ii}=tmpstruct;
                    case 6
                        [waveOut,b1,b2,b3,b4,b5]=step(blocks{ii},waveOut);


                        tmpstruct=struct(rname,struct(outNames(2),b1));
                        tmpstruct.(rname).(outNames(3))=b2;
                        tmpstruct.(rname).(outNames(4))=b3;
                        tmpstruct.(rname).(outNames(5))=b4;
                        tmpstruct.(rname).(outNames(6))=b5;
                        paramsOut{ii}=tmpstruct;
                    otherwise
                        waveOut=step(blocks{ii},waveOut);

                    end
                end
            end


            impulse=waveOut;













        end

        function legendCell=getWaveLegend(obj)
            numberOfWaves=size(obj.ImpulseResponse,2);
            ChannelFlag=obj.ChannelData.OptionSel;

            legendCell=cell(numberOfWaves,2);
            legendCell{1,1}='Unequalized primary';
            legendCell{1,2}='Equalized primary';
            if ChannelFlag==3&&numberOfWaves==3
                legendCell{2,1}='Unequalized FEXT';
                legendCell{2,2}='Equalized FEXT';
                legendCell{3,1}='Unequalized NEXT';
                legendCell{3,2}='Equalized NEXT';
            else
                for ii=2:numberOfWaves
                    legendCell{ii,1}=sprintf('Unequalized agr%i',ii-1);
                    legendCell{ii,2}=sprintf('Equalized agr%i',ii-1);
                end
            end
        end
    end

    methods(Static)
        function ternary=threebit2ternary(bin)



















            narginchk(1,1)
            nargoutchk(0,1)
            validateattributes(bin,{'logical','numeric'},{'numel',3,'binary'},...
            'threebit2ternary','bin',1);



            sgn=[-1,1];
            b1test=(bin(1)==0)+1;
            ternary(1)=-sgn(b1test)*not(bin(3));
            ternary(2)=sgn(b1test)*or(bin(3),and(bin(2),not(bin(3))));
        end
    end
end