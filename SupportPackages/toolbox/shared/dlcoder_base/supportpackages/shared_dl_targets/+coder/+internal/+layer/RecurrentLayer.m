classdef(Abstract)RecurrentLayer<nnet.layer.Layer
%#codegen







    properties
        NumStates=0
        State=cell(1,0)



    end

    methods
        function layer=RecurrentLayer()
            coder.allowpcode('plain');
            coder.inline('always');
        end
    end

    methods(Static,Hidden)
        function n=matlabCodegenNontunableProperties(~)
            n={'NumStates'};
        end
    end

end
