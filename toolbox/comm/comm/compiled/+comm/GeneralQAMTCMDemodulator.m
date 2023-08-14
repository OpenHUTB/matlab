classdef GeneralQAMTCMDemodulator<comm.internal.TCMDemodulatorBase
























































































%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)







        TrellisStructure=poly2trellis([1,3],[1,0,0;0,5,2]);











        Constellation=exp(2*pi*1i*[0,4,2,6,1,5,3,7]/8);
    end

    methods
        function obj=GeneralQAMTCMDemodulator(varargin)
            coder.allowpcode('plain');
            obj@comm.internal.TCMDemodulatorBase(varargin{:});
        end
    end

    methods(Access=protected)

        function[err,cplxconstpts,t]=getInitializationParameters(obj)
            [err,~,cplxconstpts,t]=commblkgentcmdec(obj,'init',...
            obj.TrellisStructure,obj.Constellation,obj.TracebackDepth,...
            obj.TerminationMethod,obj.ResetInputPort);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='commdigbbndtcm2/General TCM Decoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'TrellisStructure',...
            'TerminationMethod',...
            'TracebackDepth',...
            'ResetInputPort',...
            'Constellation',...
            'OutputDataType'};
        end
    end
end
