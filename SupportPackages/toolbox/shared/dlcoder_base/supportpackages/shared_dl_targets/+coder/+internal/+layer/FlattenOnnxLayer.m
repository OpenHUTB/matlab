%#codegen
%#internal

classdef FlattenOnnxLayer<nnet.layer.Layer&coder.internal.layer.NumericDataLayer



    methods
        function this=FlattenOnnxLayer(name)
            this.Name=name;
        end

        function Z=predict(~,X)
            coder.allowpcode('plain');


            [h,w,c,n]=size(X);
            Z=reshape(permute(X,[2,1,3,4]),[1,1,h*w*c,n]);
        end
    end
end
