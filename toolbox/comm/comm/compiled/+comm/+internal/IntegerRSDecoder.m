classdef(Hidden)IntegerRSDecoder<matlab.system.SFunSystem













































%#function mcomberlekamp

    properties(Hidden,Nontunable)


        CodewordLength=7;


        MessageLength=3;



        PuncturePatternSourceIndex=0;


        PuncturePattern=[ones(2,1);zeros(2,1)];



DecoderParameters




        ErasuresInputPort(1,1)logical=false;



        NumCorrectedErrorsOutputPort(1,1)logical=true;
    end

    methods
        function obj=IntegerRSDecoder(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcomberlekamp');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Hidden)
        function setParameters(obj)









            obj.compSetParameters({...
            obj.CodewordLength,...
            obj.MessageLength,...
            obj.DecoderParameters.m,...
            obj.DecoderParameters.t,...
            obj.DecoderParameters.primPoly,...
            obj.DecoderParameters.b,...
            obj.DecoderParameters.shortened,...
            obj.PuncturePatternSourceIndex,...
            obj.PuncturePattern,...
            double(obj.ErasuresInputPort),...
            double(obj.NumCorrectedErrorsOutputPort),...
            obj.DecoderParameters.codeType...
            });
        end
    end


    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
            if obj.NumCorrectedErrorsOutputPort
                setPortDataTypeConnection(obj,1,2);
            end
        end
    end

    methods(Static,Hidden)
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

end
