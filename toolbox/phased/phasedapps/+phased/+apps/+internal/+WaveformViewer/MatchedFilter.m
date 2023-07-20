classdef MatchedFilter<handle


    properties(SetObservable)
SpectrumWindow
    end
    properties(Access=private,Constant)
        DefaultSpectrumWindow=getString(message('phased:apps:waveformapp:None'));
        DefaultSideLobeAttenuation=30;
        DefaultSpectrumRange=[0,100000];
        DefaultBeta=0.5;
        DefaultNbar=4;
    end
    properties(Hidden,Access=public)
SpectrumRange
SideLobeAttenuation
Beta
Nbar
    end
    methods(Access=protected,Hidden)
        function p=makeInputParser(self)
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'Process',self.DefaultProcessType);
            addParameter(p,'SpectrumWindow',self.DefaultSpectrumWindow);
            addParameter(p,'SideLobeAttenuation',self.DefaultSideLobeAttenuation);
            addParameter(p,'SpectrumRange',self.DefaultSpectrumRange);
            addParameter(p,'Beta',self.DefaultBeta);
            addParameter(p,'Nbar',self.DefaultNbar);
        end
        function setParsedProperties(self,p)
            self.SpectrumWindow=p.Results.SpectrumWindow;
            self.SideLobeAttenuation=p.Results.SideLobeAttenuation;
            self.SpectrumRange=p.Results.SpectrumRange;
            self.Beta=p.Results.Beta;
            self.Nbar=p.Results.Nbar;
        end
    end
    methods
        function self=MatchedFilter(varargin)
            narginchk(0,20)
            p=makeInputParser(self);
            parse(p,varargin{:});
            setParsedProperties(self,p);
        end
        function set.SpectrumRange(self,value)
            validateattributes(value,{'double'},...
            {'real','finite','size',[1,2]},'',...
            'SpectrumRange');
            cond=value(1)>value(2);
            if cond
                coder.internal.errorIf(cond,'phased:phased:MatchedFilter:InvalidSpectrumRange');
            end
            self.SpectrumRange=value;
        end
        function set.SpectrumWindow(self,value)
            validatestring(value,{getString(message('phased:apps:waveformapp:None')),...
            getString(message('phased:apps:waveformapp:Hamming')),getString(message('phased:apps:waveformapp:Chebyshev')),getString(message('phased:apps:waveformapp:Hann')),getString(message('phased:apps:waveformapp:Kaiser')),getString(message('phased:apps:waveformapp:Taylor'))},...
            '','SpectrumWindow');
            self.SpectrumWindow=value;
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
    end
    properties(Constant,Access=protected)
        DefaultProcessType=getString(message('phased:apps:waveformapp:MatchedFilter'));
    end
end
