%#codegen
%#internal

classdef ElementwiseAffineLayer<nnet.layer.Layer&coder.internal.layer.NumericDataLayer



    properties
Scale
Offset
DoScale
DoOffset
    end

    methods
        function this=ElementwiseAffineLayer(name,Scale,Offset)
            this.Name=name;
            this.Scale=Scale;
            this.Offset=Offset;
            this.DoScale=any(Scale(:)~=1);
            this.DoOffset=any(Offset(:)~=0);
        end

        function Z=predict(this,X)
            coder.allowpcode('plain');
            Z=X;


            if this.DoScale
                Z=Z.*cast(this.Scale,'like',X);
            end
            if this.DoOffset
                Z=Z+cast(this.Offset,'like',X);
            end
        end
    end
end
