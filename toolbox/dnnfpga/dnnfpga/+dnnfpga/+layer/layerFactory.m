classdef layerFactory





    properties

    end

    methods
        function obj=layerFactory()

        end
    end
    methods(Access=public)
        function layerObject=createLayerObject(this,layer)

            layerObject=[];
            switch class(layer)
            case 'nnet.cnn.layer.ImageInputLayer'
                layerObject=dnnfpga.layer.layerClass('input');
                layerObject.layer=layer;
            case{'nnet.cnn.layer.Convolution2DLayer','nnet.cnn.layer.GroupedConvolution2DLayer'}
                layerObject=dnnfpga.layer.layerClass('conv');
                layerObject.layer=layer;
            case{'nnet.cnn.layer.MaxPooling2DLayer','nnet.cnn.layer.AveragePooling2DLayer'}
                layerObject=dnnfpga.layer.layerClass('pool');
                layerObject.layer=layer;
            case{'nnet.cnn.layer.ReLULayer','nnet.cnn.layer.LeakyReLULayer','nnet.cnn.layer.ClippedReLULayer'}
                layerObject=dnnfpga.layer.layerClass('relu');
                layerObject.layer=layer;
            case{'nnet.cnn.layer.FullyConnectedLayer'}
                layerObject=dnnfpga.layer.layerClass('fc');
                layerObject.layer=layer;
            case{'nnet.cnn.layer.SoftmaxLayer',...
                'nnet.cnn.layer.ClassificationOutputLayer',...
                'nnet.cnn.layer.RegressionOutputLayer',...
                'nnet.cnn.layer.YOLOv2TransformLayer',...
                'nnet.cnn.layer.YOLOv2OutputLayer',...
                'nnet.cnn.layer.PixelClassificationLayer'}
                layerObject=dnnfpga.layer.layerClass('output');
                layerObject.layer=layer;
            otherwise
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayer',class(layer));
                error(msg);

            end
        end
    end
end
