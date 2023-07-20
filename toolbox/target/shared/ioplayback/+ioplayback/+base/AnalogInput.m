classdef AnalogInput<ioplayback.base.AnalogInSingle






%#codegen
%#ok<*EMCA>
    properties(Hidden,Nontunable)
        Logo='Generic'
    end

    methods
        function obj=AnalogInput(varargin)
            coder.allowpcode('plain');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)
        function maskDisplayCmds=getMaskDisplayImpl(obj)
            maskDisplayCmds={...
            'color(''white'');',...
            'plot([100,100,100,100]*1,[100,100,100,100]*1);',...
            'plot([100,100,100,100]*0,[100,100,100,100]*0);',...
            'color(''blue'');',...
            ['text(99, 92, ''',obj.Logo,''', ''horizontalAlignment'', ''right'');'],...
            'color(''black'');',...
            'plot([30:70],(sin(2*pi*[0.25:0.01:0.65]*(-5))+1)*15+35)',...
            ['text(50, 15, ''Pin: ',num2str(obj.Pin),''' ,''horizontalAlignment'', ''center'');'],...
            };
        end
    end
end
