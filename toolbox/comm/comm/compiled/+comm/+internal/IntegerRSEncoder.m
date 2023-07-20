classdef(Hidden)IntegerRSEncoder<matlab.system.SFunSystem

























%#function mcombchrsencoder

    properties(Hidden,Nontunable)


        CodewordLength=7;


        MessageLength=3;



        PuncturePatternSourceIndex=0;


        PuncturePattern=[ones(2,1);zeros(2,1)];



EncoderParameters
    end

    methods
        function obj=IntegerRSEncoder(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mcombchrsencoder');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Hidden)
        function setParameters(obj)







            obj.compSetParameters({...
            obj.CodewordLength,...
            obj.MessageLength,...
            obj.EncoderParameters.m,...
            obj.EncoderParameters.primPoly,...
            obj.EncoderParameters.genPoly,...
            obj.EncoderParameters.shortened,...
            obj.PuncturePatternSourceIndex,...
            obj.PuncturePattern,...
            obj.EncoderParameters.codeType...
            });
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

    methods(Static,Hidden)
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

end
