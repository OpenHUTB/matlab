classdef RectangularWaveform<phased.apps.internal.WaveformViewer.WaveformElements



    properties(SetObservable)
PulseWidth
    end

    properties(Access=private,Constant)
        DefaultPulseWidth=5e-5;
    end

    methods(Access=protected,Hidden)
        function p=makeInputParser(self)
            p=makeInputParser@phased.apps.internal.WaveformViewer.WaveformElements(self);
            addParameter(p,'PulseWidth',self.DefaultPulseWidth);
        end

        function setParsedProperties(self,p)
            setParsedProperties@phased.apps.internal.WaveformViewer.WaveformElements(self,p);
            self.PulseWidth=p.Results.PulseWidth;
        end
    end

    methods
        function self=RectangularWaveform(varargin)
            self@phased.apps.internal.WaveformViewer.WaveformElements(varargin{:});
            p=makeInputParser(self);
            parse(p,varargin{:});
            setParsedProperties(self,p);
        end

        function set.PulseWidth(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},'',getString(message('phased:apps:waveformapp:errorPulseWidth','Pulse Width')));
            self.PulseWidth=value;
        end

        function waveformObject=getWaveformObject(self)

            waveformObject=phased.RectangularWaveform(...
            'SampleRate',self.SampleRate,...
            'PulseWidth',self.PulseWidth,...
            'PRF',self.PRF,...
            'NumPulses',self.NumPulses,...
            'FrequencyOffset',self.FrequencyOffset);
        end
    end
    methods(Access=protected)
        function op=objectProperties(self)
            op=objectProperties@phased.apps.internal.WaveformViewer.WaveformElements(self);
            op{end+1,1}='Pulsewidth';
            op{end,2}=sprintf('%.15g',self.PulseWidth);
        end
    end

    properties(Constant,Access=protected)
        DefaultName=getString(message('phased:apps:waveformapp:Rectangular'));
    end
end