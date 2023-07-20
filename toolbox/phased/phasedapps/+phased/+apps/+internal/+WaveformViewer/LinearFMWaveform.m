classdef LinearFMWaveform<phased.apps.internal.WaveformViewer.WaveformElements



    properties(SetObservable)
SweepBandwidth
SweepDirection
SweepInterval
Envelope
PulseWidth
    end

    properties(Access=private,Constant)
        DefaultSweepBandwidth=100000;
        DefaultSweepDirection=getString(message('phased:apps:waveformapp:up'))
        DefaultSweepInterval=getString(message('phased:apps:waveformapp:positive'))
        DefaultEnvelope=getString(message('phased:apps:waveformapp:RectangularEnv'))
        DefaultPulseWidth=5e-5;
    end

    methods(Access=protected,Hidden)
        function p=makeInputParser(self)
            p=makeInputParser@phased.apps.internal.WaveformViewer.WaveformElements(self);
            addParameter(p,'SweepBandwidth',self.DefaultSweepBandwidth);
            addParameter(p,'SweepDirection',self.DefaultSweepDirection);
            addParameter(p,'SweepInterval',self.DefaultSweepInterval);
            addParameter(p,'Envelope',self.DefaultEnvelope);
            addParameter(p,'PulseWidth',self.DefaultPulseWidth);
        end

        function setParsedProperties(self,p)
            setParsedProperties@phased.apps.internal.WaveformViewer.WaveformElements(self,p);
            self.SweepBandwidth=p.Results.SweepBandwidth;
            self.SweepDirection=p.Results.SweepDirection;
            self.SweepInterval=p.Results.SweepInterval;
            self.Envelope=p.Results.Envelope;
            self.PulseWidth=p.Results.PulseWidth;
        end
    end

    methods
        function self=LinearFMWaveform(varargin)
            narginchk(0,20)
            p=makeInputParser(self);
            parse(p,varargin{:});
            setParsedProperties(self,p);
        end

        function set.SweepBandwidth(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},...
            '',getString(message('phased:apps:waveformapp:errorSweepBandwidth','Sweep Bandwidth')))
            self.SweepBandwidth=value;
        end

        function set.SweepDirection(self,value)
            value=validatestring(value,{getString(message('phased:apps:waveformapp:up')),getString(message('phased:apps:waveformapp:dwn'))});
            self.SweepDirection=value;
        end

        function set.SweepInterval(self,value)
            value=validatestring(value,{getString(message('phased:apps:waveformapp:positive')),getString(message('phased:apps:waveformapp:symmetric'))});
            self.SweepInterval=value;
        end

        function set.Envelope(self,value)
            value=validatestring(value,{getString(message('phased:apps:waveformapp:RectangularEnv')),getString(message('phased:apps:waveformapp:gaussian'))});
            self.Envelope=value;
        end

        function set.PulseWidth(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},'',getString(message('phased:apps:waveformapp:errorPulseWidth','Pulse Width')));
            self.PulseWidth=value;
        end
        function waveformObject=getWaveformObject(self)

            waveformObject=phased.LinearFMWaveform(...
            "SampleRate",self.SampleRate,...
            'PRF',self.PRF,...
            'PulseWidth',self.PulseWidth,...
            'FrequencyOffset',self.FrequencyOffset,...
            'Envelope',self.Envelope,...
            'NumPulses',self.NumPulses,...
            'SweepBandwidth',self.SweepBandwidth,...
            'SweepDirection',self.SweepDirection,...
            'SweepInterval',self.SweepInterval);
        end
    end
    methods(Access=protected)
        function op=objectProperties(self)
            op=objectProperties@phased.apps.internal.WaveformViewer.WaveformElements(self);
            op{end+1,1}='Pulsewidth';
            op{end,2}=sprintf('%.15g',self.PulseWidth);
            op{end+1,1}='SweepBandwidth';
            op{end,2}=sprintf('%.15g',self.SweepBandwidth);
            op{end+1,1}='SweepDirection';
            op{end,2}=sprintf('%s',self.SweepDirection);
            op{end+1,1}='SweepInterval';
            op{end,2}=sprintf('%s',self.SweepInterval);
            op{end+1,1}='Envelope';
            op{end,2}=sprintf('%s',self.Envelope);
        end
    end

    properties(Constant,Access=protected)
        DefaultName=getString(message('phased:apps:waveformapp:LinearFM'))
    end
end