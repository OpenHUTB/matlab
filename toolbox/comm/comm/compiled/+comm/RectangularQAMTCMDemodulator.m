classdef RectangularQAMTCMDemodulator<comm.internal.TCMDemodulatorBase




















































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)







        TrellisStructure=poly2trellis([3,1,1],[5,2,0,0;0,0,1,0;0,0,0,1]);








        ModulationOrder=16;
    end

    methods
        function obj=RectangularQAMTCMDemodulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.TCMDemodulatorBase(varargin{:});
        end

        function set.ModulationOrder(obj,value)
            coder.internal.errorIf(~isscalar(value)||...
            ~ismember(value,[4,8,16,32,64]),'comm:system:RectangularQAMTCMModulator:invalidModulationOrder');
            obj.ModulationOrder=value;
        end
    end

    methods(Access=protected)
        function[err,cplxconstpts,t]=getInitializationParameters(obj)

            [err,~,cplxconstpts,t]=commblkqamtcmdec(obj,'init',...
            obj.TrellisStructure,obj.ModulationOrder,...
            obj.TracebackDepth,obj.TerminationMethod,obj.ResetInputPort);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndtcm2/Rectangular QAM TCM Decoder';
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
