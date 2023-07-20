classdef MaxPooling2DLayer<nnet.layer.Layer















%#codegen


    properties
        PoolSize;
        Stride;
        PaddingSize;
    end

    methods
        function layer=MaxPooling2DLayer(name,poolSize,stride,paddingSize)
            layer.Name=name;
            layer.PoolSize=poolSize;
            layer.Stride=stride;
            layer.PaddingSize=paddingSize;
        end

        function Z=predict(layer,X)
            coder.allowpcode('plain');




            poolingWindowFunc=@(x,y)max(x,y);



            poolingAssignFunc=@(x)x;




            minimumValue=-realmax(class(X));
            paddingValue=minimumValue;
            initOpValue=minimumValue;


            Z=coder.internal.layer.poolingUtils.poolingOperation(layer,X,poolingWindowFunc,poolingAssignFunc,...
            paddingValue,initOpValue);

        end

    end
end