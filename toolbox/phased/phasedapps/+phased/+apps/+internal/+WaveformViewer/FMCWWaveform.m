classdef FMCWWaveform<phased.apps.internal.WaveformViewer.WaveformName



    properties(SetObservable)
SampleRate
SweepTime
SweepBandwidth
SweepDirection
SweepInterval
NumSweeps
PropagationSpeed
    end

    properties(Access=private,Constant)
        DefaultSampleRate=1e6;
        DefaultSweepTime=0.0001;
        DefaultSweepBandwidth=100000;
        DefaultSweepDirection=getString(message('phased:apps:waveformapp:up'))
        DefaultSweepInterval=getString(message('phased:apps:waveformapp:positive'));
        DefaultNumSweeps=1;
        DefaultPropagationSpeed=3e8
    end

    methods(Access=protected,Hidden)
        function p=makeInputParser(self)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Name',self.DefaultName);
            addParameter(p,'SampleRate',self.DefaultSampleRate);
            addParameter(p,'SweepTime',self.DefaultSweepTime);
            addParameter(p,'SweepBandwidth',self.DefaultSweepBandwidth);
            addParameter(p,'SweepDirection',self.DefaultSweepDirection);
            addParameter(p,'SweepInterval',self.DefaultSweepInterval);
            addParameter(p,'NumSweeps',self.DefaultNumSweeps);
            addParameter(p,'PropagationSpeed',self.DefaultPropagationSpeed);
        end

        function setParsedProperties(self,p)
            self.Name=p.Results.Name;
            self.SampleRate=p.Results.SampleRate;
            self.SweepTime=p.Results.SweepTime;
            self.NumSweeps=p.Results.NumSweeps;
            self.SweepBandwidth=p.Results.SweepBandwidth;
            self.SweepDirection=p.Results.SweepDirection;
            self.SweepInterval=p.Results.SweepInterval;
            self.PropagationSpeed=p.Results.PropagationSpeed;
        end
    end

    methods
        function self=FMCWWaveform(varargin)
            narginchk(0,20)
            p=makeInputParser(self);
            parse(p,varargin{:});
            setParsedProperties(self,p);
        end
        function set.SampleRate(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},'',getString(message('phased:apps:waveformapp:LabelWithColon','Sample Rate')))
            self.SampleRate=value;
        end

        function set.NumSweeps(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','integer','nonsparse'},'',getString(message('phased:apps:waveformapp:errorNumberSweeps','Number of Sweeps')))
            self.NumSweeps=value;
        end

        function set.SweepTime(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},'',getString(message('phased:apps:waveformapp:errorSweepTime','Sweep Time')))

            self.SweepTime=value;
        end

        function set.SweepBandwidth(self,value)
            validateattributes(value,{'single','double'},...
            {'nonempty','scalar','real','finite','positive','nonsparse'},...
            '',getString(message('phased:apps:waveformapp:errorSweepBandwidth','Sweep Bandwidth')))
            self.SweepBandwidth=value;
        end

        function set.SweepDirection(self,value)
            value=validatestring(value,{getString(message('phased:apps:waveformapp:up')),getString(message('phased:apps:waveformapp:dwn')),getString(message('phased:apps:waveformapp:triangle'))});
            self.SweepDirection=value;
        end

        function set.SweepInterval(self,value)
            value=validatestring(value,{getString(message('phased:apps:waveformapp:positive')),getString(message('phased:apps:waveformapp:symmetric'))});
            self.SweepInterval=value;
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

        function waveformObject=getWaveformObject(self)

            waveformObject=phased.FMCWWaveform(...
            'SampleRate',self.SampleRate,...
            'SweepTime',self.SweepTime,...
            'SweepBandwidth',self.SweepBandwidth,...
            'SweepDirection',self.SweepDirection,...
            'SweepInterval',self.SweepInterval,...
            'NumSweeps',self.NumSweeps);
        end
    end

    properties(Constant,Access=protected)
        DefaultName=getString(message('phased:apps:waveformapp:FMCW'));
    end
end