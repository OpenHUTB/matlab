classdef StretchProcessor<handle

    properties(SetObservable)
ReferenceRange
RangeSpan
RangeWindow
RangeFFTLength
    end
    properties(Access=private,Constant)
        DefaultReferenceRange=5000;
        DefaultRangeSpan=500;
        DefaultRangeWindow=getString(message('phased:apps:waveformapp:None'));
        DefaultRangeFFTLength=100;
        DefaultSideLobeAttenuation=30;
        DefaultBeta=0.5;
        DefaultNbar=4;
    end
    properties(Hidden,Access=public)
SideLobeAttenuation
Beta
Nbar
    end
    methods(Access=protected,Hidden)
        function p=makeInputParser(self)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Process',self.DefaultProcessType);
            addParameter(p,'ReferenceRange',self.DefaultReferenceRange);
            addParameter(p,'RangeSpan',self.DefaultRangeSpan);
            addParameter(p,'RangeWindow',self.DefaultRangeWindow);
            addParameter(p,'RangeFFTLength',self.DefaultRangeFFTLength);
            addParameter(p,'SideLobeAttenuation',self.DefaultSideLobeAttenuation);
            addParameter(p,'Beta',self.DefaultBeta);
            addParameter(p,'Nbar',self.DefaultNbar);
        end
        function setParsedProperties(self,p)
            self.ReferenceRange=p.Results.ReferenceRange;
            self.RangeSpan=p.Results.RangeSpan;
            self.RangeWindow=p.Results.RangeWindow;
            self.RangeFFTLength=p.Results.RangeFFTLength;
            self.SideLobeAttenuation=p.Results.SideLobeAttenuation;
            self.Beta=p.Results.Beta;
            self.Nbar=p.Results.Nbar;
        end
    end
    methods
        function self=StretchProcessor(varargin)
            narginchk(0,20)
            p=makeInputParser(self);
            parse(p,varargin{:});
            setParsedProperties(self,p);
        end
        function set.ReferenceRange(self,value)
            validateattributes(value,{'double'},{'scalar',...
            'positive','finite'},'','ReferenceRange')
            self.ReferenceRange=value;
        end
        function set.RangeWindow(self,value)
            validatestring(value,{getString(message('phased:apps:waveformapp:None')),...
            getString(message('phased:apps:waveformapp:Hamming')),getString(message('phased:apps:waveformapp:Chebyshev')),getString(message('phased:apps:waveformapp:Hann')),getString(message('phased:apps:waveformapp:Kaiser')),getString(message('phased:apps:waveformapp:Taylor'))},...
            '','RangeWindow');
            self.RangeWindow=value;
        end
        function set.SideLobeAttenuation(self,value)
            validateattributes(value,{'double'},...
            {'scalar','positive','finite'},'',...
            'SidelobeAttenuation');
            self.SideLobeAttenuation=value;
        end
        function set.Nbar(self,value)
            validateattributes(value,{'double'},...
            {'scalar','positive','finite'},'','Nbar');
            self.Nbar=value;
        end
        function set.Beta(self,value)
            validateattributes(value,{'double'},...
            {'scalar','nonnegative','finite'},'','Beta');
            self.Beta=value;
        end
        function set.RangeSpan(self,value)
            validateattributes(value,{'double'},{'scalar',...
            'positive','finite'},'','RangeSpan');
            self.RangeSpan=value;
        end
        function set.RangeFFTLength(self,value)
            validateattributes(value,{'double'},{'scalar',...
            'positive','finite'},'','RangeFFTLength');
            self.RangeFFTLength=value;
        end
    end
    properties(Constant,Access=protected)
        DefaultProcessType=getString(message('phased:apps:waveformapp:StretchProcessor'));
    end
end
