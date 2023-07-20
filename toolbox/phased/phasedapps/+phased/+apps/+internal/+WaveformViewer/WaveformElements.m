classdef(Abstract)WaveformElements<phased.apps.internal.WaveformViewer.WaveformName



    properties(SetObservable)
SampleRate
NumPulses
PRF
FrequencyOffset
PropagationSpeed
    end

    properties(Access=private,Constant)
        DefaultSampleRate=1e6
        DefaultNumPulses=1
        DefaultPRF=1e4
        DefaultFrequencyOffset=0
        DefaultPropagationSpeed=physconst('LightSpeed')
    end

    methods(Access=protected,Hidden)
        function p=makeInputParser(self)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Name',self.DefaultName);
            addParameter(p,'SampleRate',self.DefaultSampleRate);
            addParameter(p,'NumPulses',self.DefaultNumPulses);
            addParameter(p,'PRF',self.DefaultPRF);
            addParameter(p,'FrequencyOffset',self.DefaultFrequencyOffset);
            addParameter(p,'PropagationSpeed',self.DefaultPropagationSpeed);
        end

        function setParsedProperties(self,p)
            self.Name=p.Results.Name;
            self.SampleRate=p.Results.SampleRate;
            self.NumPulses=p.Results.NumPulses;
            self.PRF=p.Results.PRF;
            self.FrequencyOffset=p.Results.FrequencyOffset;
            self.PropagationSpeed=p.Results.PropagationSpeed;
        end
    end

    methods
        function self=WaveformElements(varargin)
            p=makeInputParser(self);
            parse(p,varargin{:});
            setParsedProperties(self,p);
        end

        function set.SampleRate(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},'',getString(message('phased:apps:waveformapp:errorSampleRate','Sample Rate')))
            self.SampleRate=value;
        end

        function set.NumPulses(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','integer'...
            ,'nonnan','nonsparse'},'',getString(message('phased:apps:waveformapp:errorNumberPulses','Number of Pulses')))
            self.NumPulses=value;
        end

        function set.PRF(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},'','PRF')
            self.PRF=value;
        end

        function set.FrequencyOffset(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','nonsparse'},'',getString(message('phased:apps:waveformapp:errorFrequencyOffset','Frequency Offset')))
            self.FrequencyOffset=value;
        end

        function set.PropagationSpeed(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},'',getString(message('phased:apps:waveformapp:errorPropagationSpeed','Propagation Speed')))
            if value>3e8
                me=MException('',getString(message('phased:apps:waveformapp:propspeederr','Propagation speed')));
                throw(me);
            end
            self.PropagationSpeed=value;
        end
    end

    methods(Access=protected)
        function op=objectProperties(self)
            op=cell(0,2);
            op{end+1,1}='Name';
            op{end,2}=sprintf('''%s''',self.Name);
            op{end+1,1}='NumPulses';
            op{end,2}=sprintf('%.15g',self.NumPulses);
            op{end+1,1}='PRF';
            op{end,2}=sprintf('%.15g',self.PRF);
            op{end+1,1}='FrequencyOffset';
            op{end,2}=sprintf('%.15g',self.FrequencyOffset);
            op{end+1,1}='PropagationSpeed';
            op{end,2}=sprintf('%.15g',self.PropagationSpeed);
        end
    end

    methods(Hidden)
        function exportScript(self,sw,vn)
            op=objectProperties(self);
            add(sw,'%s = ',vn)
            WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(self));
            switch WaveformType
            case 'LinearFMWaveform'
                add(sw,'{')
                add(sw,'''%s'',','LinearFM')
                add(sw,'''%s'',%s,',op{3,1},op{3,2})
                add(sw,'''%s'',%s,',op{6,1},op{6,2})

                add(sw,'...')
                addcr(sw)
                add(sw,sprintf('\t\t\t'))
                add(sw,'''%s'',%s,',op{4,1},op{4,2})
                add(sw,'''%s'',%s,',op{7,1},op{7,2})

                add(sw,'''%s'',''%s'',',op{8,1},op{8,2})
                add(sw,'...')
                addcr(sw)
                add(sw,sprintf('\t\t\t'))
                add(sw,'''%s'',''%s'',',op{9,1},op{9,2})
                add(sw,'''%s'',''%s''};',op{10,1},op{10,2})
            case 'RectangularWaveform'
                add(sw,'{')
                add(sw,'''%s'',','Rectangular');
                add(sw,'''%s'',%s,',op{3,1},op{3,2})
                add(sw,'''%s'',%s,',op{6,1},op{6,2})
                add(sw,'''%s'',%s};',op{4,1},op{4,2})
            case 'SteppedFMWaveform'
                add(sw,'{')
                add(sw,'''%s'',','SteppedFM')
                add(sw,'''%s'',%s,',op{3,1},op{3,2})
                add(sw,'''%s'',%s,',op{6,1},op{6,2})
                add(sw,'...')
                addcr(sw)
                add(sw,sprintf('\t\t\t'))
                add(sw,'''%s'',%s,',op{4,1},op{4,2})
                add(sw,'''%s'',%s,',op{7,1},op{7,2})
                add(sw,'''%s'',%s};',op{8,1},op{8,2})
            case 'PhaseCodedWaveform'
                add(sw,'{')
                add(sw,'''%s'',','PhaseCoded')
                add(sw,'''%s'',%s,',op{3,1},op{3,2})
                add(sw,'''%s'',%s,',op{6,1},op{6,2})
                add(sw,'...')
                addcr(sw)
                add(sw,sprintf('\t\t\t'))
                add(sw,'''%s'',%s,',op{4,1},op{4,2})
                add(sw,'''%s'',''%s'',',op{7,1},op{7,2})
                if strcmp(self.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
                    add(sw,'''%s'',%s,',op{8,1},op{8,2})
                    add(sw,'''%s'',%s};',op{9,1},op{9,2})
                else
                    add(sw,'''%s'',%s};',op{8,1},op{8,2})
                end
            end
        end
    end
end