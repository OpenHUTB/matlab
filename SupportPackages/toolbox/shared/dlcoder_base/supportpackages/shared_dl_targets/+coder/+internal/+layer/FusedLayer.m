classdef FusedLayer
%#codegen







    properties
        ActivationLayerOffset=-1








    end

    methods
        function layer=FusedLayer()
            coder.allowpcode('plain');
            coder.inline('always');
        end
    end

end
