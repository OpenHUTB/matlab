function varargout=power_fftscope_pr(varargin)







    if~pmsl_checklicense('Power_System_Blocks')
        error(message('physmod:pm_sli:sl:InvalidLicense',pmsl_getproductname('Power_System_Blocks'),'power_fftscope'));
    end
    if nargin==0&&nargout==0
powerFFT
    elseif nargin==1||nargin==2||nargin==3

        FFTDATA=varargin{1};
        if ischar(FFTDATA)
            if exist(FFTDATA,'file')==4

powerFFT
                if nargout==1
                    varargout{1}=[];
                end
                return
            else
                FFTDATA=evalin('base',FFTDATA);
            end
        end
        switch class(FFTDATA)
        case 'Simulink.SimulationData.Dataset'
            V2.time=FFTDATA.getElement(1).Values.Time;
            V2.blockName=FFTDATA.getElement(1).BlockPath.getBlock(1);
            for i=1:FFTDATA.numElements
                V2.signals(i).values=FFTDATA.getElement(i).Values.Data;
                V2.signals(i).label=FFTDATA.getElement(i).Values.Name;
            end
            FFTDATA=V2;
        end
        if isstruct(FFTDATA)
            if isequal(fieldnames(orderfields(FFTDATA)),{'blockName';'signals';'time'})



                FFTDATA.input=1;
                FFTDATA.signal=1;
                FFTDATA.startTime='last';
                FFTDATA.cycles=1;
                FFTDATA.fundamental=60;
                FFTDATA.maxFrequency=1000;



























                FFTDATA.THDmaxFrequency=inf;
                FFTDATA.THDbase='fund';
                FFTDATA.freqAxis='Hertz';

                FFTDATA.mag=[];
                FFTDATA.phase=[];
                FFTDATA.freq=[];
                FFTDATA.THD=[];
                FFTDATA.samplingTime=[];
                FFTDATA.samplesPerCycle=[];
                FFTDATA.DCcomponent=[];
                FFTDATA.magFundamental=[];
                FFTDATA.MagBase=[];
            end
            ListOfValidFields=struct('MagBase',0,'DCcomponent',0,'THD',0,'THDbase',0,'THDmaxFrequency',0,'blockName',0,'cycles',0,'freq',0,'freqAxis',0,'fundamental',0,'input',0,'mag',0,'magFundamental',0,'maxFrequency',0,'phase',0,'samplesPerCycle',0,'samplingTime',0,'signal',0,'signals',0,'startTime',0,'time',0);
            if all(isfield(ListOfValidFields,fields(FFTDATA)))

                StartTime=FFTDATA.startTime;
                NumberOfCycles=FFTDATA.cycles;
                Fundamental=FFTDATA.fundamental;
                MaxFrequency=FFTDATA.maxFrequency;
                Sd=FFTDATA.signals(FFTDATA.input).values(:,FFTDATA.signal);
                t=FFTDATA.time;

                MSG='CmdLine';
                [ValidFFTWindow,Ywindow,~,~,~,FFTDATA.samplingTime,FFTDATA.samplesPerCycle,npoints]=verifyFFTAnalyzerSettings(t,Sd,MSG,StartTime,NumberOfCycles,Fundamental);
                FFTDATA.samplesPerCycle=round(FFTDATA.samplesPerCycle);
                if ValidFFTWindow==0
                    FFTDATA.mag=[];
                    FFTDATA.phase=[];
                    FFTDATA.freq=[];
                    FFTDATA.THD=[];
                    return
                end
                Y=2*fft(Ywindow)/(npoints);
                FFTDATA.freq=0:Fundamental/NumberOfCycles:1/FFTDATA.samplingTime;

                F_max=1/FFTDATA.samplingTime/2;
                i_F_max=find(FFTDATA.freq<=F_max,1,'last');

                FFTDATA.mag=abs(Y(1:i_F_max));
                FFTDATA.freq=FFTDATA.freq(1:i_F_max);

                FFTDATA.mag(FFTDATA.mag<1e-9)=0;

                FFTDATA.magFundamental=FFTDATA.mag(NumberOfCycles+1);

                DCcomponent=FFTDATA.mag(1)/2;

                i_F_max_THD=find(FFTDATA.freq<=FFTDATA.THDmaxFrequency,1,'last');
                switch FFTDATA.THDbase
                case 'DC'
                    NormalizeWithRespectToDC=1;

                    Harmo=sqrt(sum(FFTDATA.mag(2:i_F_max_THD).^2));
                    FFTDATA.THD=Harmo/DCcomponent*100;
                case 'fund'
                    NormalizeWithRespectToDC=0;

                    Harmo=sqrt(sum(FFTDATA.mag(NumberOfCycles+2:i_F_max_THD).^2));
                    FFTDATA.THD=Harmo/FFTDATA.magFundamental*100;
                end

                i_F_max_user=find(FFTDATA.freq<MaxFrequency,1,'last');

                FFTDATA.freq=FFTDATA.freq(1:i_F_max_user);
                FFTDATA.mag=FFTDATA.mag(1:i_F_max_user);
                FFTDATA.phase=angle(Y(1:i_F_max_user))*180/pi+90;

                FFTDATA.phase(FFTDATA.mag==0)=0;
                FFTDATA.phase(abs(FFTDATA.phase)<1e-9)=0;

                FFTDATA.mag(1)=FFTDATA.mag(1)/2;
                FFTDATA.DCcomponent=FFTDATA.mag(1);
                FFTDATA.freq=FFTDATA.freq';
                switch lower(FFTDATA.freqAxis)
                case 'hertz'
                    FrequencyAxis=1;
                case{'harmonicorder','harmonic order'}
                    FrequencyAxis=2;
                otherwise
                    error(message('physmod:powersys:library:InvalidFFTDATAStructure'));
                end
                if~NormalizeWithRespectToDC&&FFTDATA.magFundamental>0
                    if FFTDATA.mag(1)==max(FFTDATA.mag)

                        MaxAxisValue=max(FFTDATA.mag(2:i_F_max_user))*100/FFTDATA.magFundamental;
                    else
                        MaxAxisValue=(max([FFTDATA.mag(1),max(FFTDATA.mag(NumberOfCycles+2:i_F_max_user))]))*100/FFTDATA.magFundamental;
                    end
                elseif NormalizeWithRespectToDC&&DCcomponent>0
                    MaxAxisValue=max(FFTDATA.mag(2:i_F_max_user))*100/DCcomponent;
                else
                    MaxAxisValue=1;
                end
                if MaxAxisValue==0
                    MaxAxisValue=1;
                end
                if isempty(MaxAxisValue)
                    MaxAxisValue=1;
                end
                if nargin==3
                    UserSpecifiedBase=varargin{3};
                else
                    UserSpecifiedBase=[];
                end
                if~isempty(UserSpecifiedBase)
                    FFTDATA.MagBase=1/UserSpecifiedBase;
                    if FFTDATA.magFundamental>0
                        MaxAxisValue=(MaxAxisValue*FFTDATA.magFundamental/100)*FFTDATA.MagBase;
                    end
                elseif~NormalizeWithRespectToDC&&FFTDATA.magFundamental>0
                    FFTDATA.MagBase=100/FFTDATA.magFundamental;
                elseif NormalizeWithRespectToDC&&DCcomponent>0
                    FFTDATA.MagBase=100/DCcomponent;
                else
                    FFTDATA.MagBase=Inf;
                end
                if nargout==0
                    if nargin==2||nargin==3
                        G=varargin{2};
                    else
                        figure('Name',['Scope block:',FFTDATA.blockName,', Input: ',num2str(FFTDATA.signal),', signal: ',num2str(FFTDATA.input)]);
                        G=gca;
                    end
                    if FrequencyAxis==2
                        bar(G,FFTDATA.freq/Fundamental,FFTDATA.mag*FFTDATA.MagBase,0.5);
                        axis(G,[-(MaxFrequency/Fundamental)/20,MaxFrequency/Fundamental,0,1.1*MaxAxisValue]);
                        xlabel(G,'Harmonic order');
                    else
                        bar(G,FFTDATA.freq,FFTDATA.mag*FFTDATA.MagBase,0.5);
                        if~isinf(FFTDATA.MagBase)
                            axis(G,[-MaxFrequency/20,MaxFrequency,0,1.1*MaxAxisValue]);
                        end
                        xlabel(G,'Frequency (Hz)');
                    end
                    switch FFTDATA.THDbase
                    case 'DC'
                        if isnan(FFTDATA.THD)
                            plotTitle=sprintf('DC = %0.4g , THD= undefined',FFTDATA.DCcomponent);
                        elseif isfinite(FFTDATA.THD)
                            plotTitle=sprintf('DC = %0.4g , THD= %0.2f%%',FFTDATA.DCcomponent,FFTDATA.THD);
                        else
                            plotTitle=sprintf('DC = %0.4g , THD= Inf',FFTDATA.DCcomponent);
                        end
                    otherwise
                        if isnan(FFTDATA.THD)
                            plotTitle=sprintf('Fundamental (%gHz) = %0.4g , THD= undefined',Fundamental,FFTDATA.magFundamental);
                        elseif isfinite(FFTDATA.THD)
                            plotTitle=sprintf('Fundamental (%gHz) = %0.4g , THD= %0.2f%%',Fundamental,FFTDATA.magFundamental,FFTDATA.THD);
                        else
                            plotTitle=sprintf('Fundamental (%gHz) = %0.4g , THD= Inf',Fundamental,FFTDATA.magFundamental);
                        end
                    end
                    if isinf(FFTDATA.MagBase)
                        plotTitle='Magnitude of the fundamental frequency is 0 (no bar displayed)';
                    end
                    title(G,plotTitle);grid(G,'on');grid(G,'minor');
                    switch FFTDATA.THDbase
                    case 'fund'
                        ylabel(G,'Mag (% of Fundamental)');
                    case 'DC'
                        ylabel(G,'Mag (% of DC)');
                    otherwise
                        ylabel(G,'Mag (% of base)');
                    end
                elseif nargout==1
                    varargout{1}=FFTDATA;
                end
            else
                error(message('physmod:powersys:library:InvalidFFTDATAStructure'))
            end
        else
            Erreur.message='First argument must be a struct.';
            Erreur.identifier='SpecializedPowerSystems:Power_fftscope:ParameterError';
            psberror(Erreur)
        end
    end