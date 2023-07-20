classdef SteppedFMWaveform<phased.apps.internal.WaveformViewer.WaveformElements



    properties(SetObservable)
FrequencyStep
NumSteps
PulseWidth
    end

    properties(Access=private,Constant)
        DefaultFrequencyStep=20000;
        DefaultNumSteps=5;
        DefaultPulseWidth=5e-5;
    end

    methods(Access=protected,Hidden)
        function p=makeInputParser(self)
            p=makeInputParser@phased.apps.internal.WaveformViewer.WaveformElements(self);
            addParameter(p,'FrequencyStep',self.DefaultFrequencyStep);
            addParameter(p,'NumSteps',self.DefaultNumSteps);
            addParameter(p,'PulseWidth',self.DefaultPulseWidth);
        end

        function setParsedProperties(self,p)
            setParsedProperties@phased.apps.internal.WaveformViewer.WaveformElements(self,p);
            self.FrequencyStep=p.Results.FrequencyStep;
            self.NumSteps=p.Results.NumSteps;
            self.PulseWidth=p.Results.PulseWidth;
        end
    end

    methods
        function self=SteppedFMWaveform(varargin)
            narginchk(0,20)
            p=makeInputParser(self);
            parse(p,varargin{:});
            setParsedProperties(self,p);
        end

        function set.FrequencyStep(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},...
            '',getString(message('phased:apps:waveformapp:errorFrequencyStep','Frequency Step')))
            self.FrequencyStep=value;
        end

        function set.NumSteps(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','integer','nonsparse'},...
            '',getString(message('phased:apps:waveformapp:errorNumberSteps','Number of Steps')))
            self.NumSteps=value;
        end

        function set.PulseWidth(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},...
            '',getString(message('phased:apps:waveformapp:errorPulseWidth','Pulse Width')))
            self.PulseWidth=value;
        end

        function waveformObject=getWaveformObject(self)

            waveformObject=phased.SteppedFMWaveform(...
            'SampleRate',self.SampleRate,...
            'PulseWidth',self.PulseWidth,...
            'PRF',self.PRF,...
            'NumPulses',self.NumPulses,...
            'NumSteps',self.NumSteps,...
            'FrequencyStep',self.FrequencyStep,...
            'FrequencyOffset',self.FrequencyOffset);
        end
    end
    methods(Access=protected)
        function op=objectProperties(self)
            op=objectProperties@phased.apps.internal.WaveformViewer.WaveformElements(self);
            op{end+1,1}='Pulsewidth';
            op{end,2}=sprintf('%.15g',self.PulseWidth);
            op{end+1,1}='FrequencyStep';
            op{end,2}=sprintf('%.15g',self.FrequencyStep);
            op{end+1,1}='NumSteps';
            op{end,2}=sprintf('%.15g',self.NumSteps);
        end
    end

    properties(Constant,Access=protected)
        DefaultName=getString(message('phased:apps:waveformapp:SteppedFM'))
    end
end