classdef PSKTCMDemodulator<comm.internal.TCMDemodulatorBase




















































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)







        TrellisStructure=poly2trellis([1,3],[1,0,0;0,5,2]);








        ModulationOrder=8;
    end

    methods
        function obj=PSKTCMDemodulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.TCMDemodulatorBase(varargin{:});
        end

        function set.ModulationOrder(obj,value)
            coder.internal.errorIf(~isscalar(value)||...
            ~ismember(value,[4,8,16]),'comm:system:PSKTCMModulator:invalidModulationOrder');
            obj.ModulationOrder=value;
        end
    end

    methods(Access=protected)
        function[err,cplxconstpts,t]=getInitializationParameters(obj)

            [err,~,cplxconstpts,t]=commblkpsktcmdec(obj,'init',...
            obj.ModulationOrder,obj.TrellisStructure,...
            obj.TracebackDepth,obj.TerminationMethod,obj.ResetInputPort);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndtcm2/M-PSK TCM Decoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'TrellisStructure',...
            'TerminationMethod',...
            'TracebackDepth',...
            'ResetInputPort',...
            'ModulationOrder',...
            'OutputDataType'};
        end
    end
end

