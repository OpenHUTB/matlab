classdef AveragePooling2DLayer<nnet.layer.Layer&coder.internal.layer.NumericDataLayer














%#codegen

    properties
        PoolSize;
        Stride;
PaddingSize
    end

    methods
        function layer=AveragePooling2DLayer(name,poolSize,stride,paddingSize)
            layer.Name=name;
            layer.PoolSize=poolSize;
            layer.Stride=stride;
            layer.PaddingSize=paddingSize;
        end

        function Z=predict(layer,X)
            coder.allowpcode('plain');



            poolingWindowFunc=@plus;



            averageFactor=1/(cast(coder.const(prod(layer.PoolSize)),class(X)));
            poolingAssignFunc=@(x)averageFactor*x;




            zeroCast=zeros(1,1,'like',X);
            paddingValue=zeroCast;
            initOpValue=zeroCast;


            Z=coder.internal.layer.poolingUtils.poolingOperation(layer,X,poolingWindowFunc,poolingAssignFunc,...
            paddingValue,initOpValue);
        end
    end
end