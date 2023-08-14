




classdef Layers
    methods(Static)

        function v=isConv(layer)
            v=false;
            switch(class(layer))
            case{'nnet.cnn.layer.AveragePooling2DLayer',...
                'nnet.cnn.layer.AveragePooling3DLayer',...
                'nnet.cnn.layer.BatchNormalizationLayer',...
                'nnet.cnn.layer.Convolution2DLayer',...
                'nnet.cnn.layer.Convolution3DLayer',...
                'nnet.cnn.layer.GlobalAveragePooling2DLayer',...
                'nnet.cnn.layer.GlobalAveragePooling3DLayer',...
                'nnet.cnn.layer.GlobalMaxPooling2DLayer',...
                'nnet.cnn.layer.GlobalMaxPooling3DLayer',...
                'nnet.cnn.layer.GroupNormalizationLayer',...
                'nnet.cnn.layer.GroupedConvolution2DLayer',...
                'nnet.cnn.layer.MaxPooling2DLayer',...
                'nnet.cnn.layer.MaxPooling3DLayer',...
                'nnet.cnn.layer.MaxUnpooling2DLayer',...
                'nnet.cnn.layer.TransposedConvolution2DLayer',...
                'nnet.keras.layer.ZeroPadding2dLayer'}
                v=true;
            end
        end
        function v=isFC(layer)
            v=false;
            switch(class(layer))
            case{'nnet.cnn.layer.FullyConnectedLayer',...
                'nnet.cnn.layer.SigmoidLayer',...
                'nnet.cnn.layer.SoftmaxLayer'}
                v=true;
            otherwise
            end
        end
        function v=isAdd(layer)
            v=false;
            switch(class(layer))
            case{'nnet.cnn.layer.AdditionLayer'}
                v=true;
            otherwise
            end
        end
        function v=isDepthConcat(layer)
            v=false;
            switch(class(layer))




            case{'nnet.cnn.layer.DepthConcatenationLayer',...
                'nnet.cnn.layer.ConcatenationLayer'}
                v=true;
            otherwise
            end
        end
        function v=isUnpool(layer)

            v=false;
            switch(class(layer))
            case{'nnet.cnn.layer.MaxUnpooling2DLayer',...
                'nnet.cnn.layer.TransposedConvolution2DLayer',}
                v=true;
            otherwise
            end
        end
        function v=isStateRead(layer)
            v=isa(layer,'nnet.cnn.layer.ImageInputLayer')&&endsWith(layer.Name,'__Read');
        end
        function v=isStateWrite(layer)
            import dnnfpga.dagCompile.*
            v=Layers.isOutput(layer)&&endsWith(layer.Name,'__Write');
        end
        function v=isSoft(layer)
            v=false;
            if~dnnfpga.dagCompile.Layers.isStateRead(layer)&&~dnnfpga.dagCompile.Layers.isStateWrite(layer)
                if isa(layer,'nnet.layer.ClassificationLayer')
                    v=true;
                else
                    switch(class(layer))


                    case{'nnet.cnn.layer.ClassificationOutputLayer',...
                        'nnet.cnn.layer.RegressionOutputLayer',...
                        'nnet.cnn.layer.YOLOv2TransformLayer',...
                        'nnet.cnn.layer.YOLOv2OutputLayer',...
                        'nnet.cnn.layer.ImageInputLayer',...
                        'nnet.cnn.layer.Image3DInputLayer',...
                        'nnet.cnn.layer.PixelClassificationLayer',...
                        'nnet.cnn.layer.SequenceInputLayer',...
                        'dnnfpga.layer.wordEmbeddingLayerDLP',...
'nnet.cnn.layer.FeatureInputLayer'...
                        }
                        v=true;
                    otherwise
                    end
                end
            end
        end
        function v=isReLU(layer)
            v=false;
            switch(class(layer))
            case{'nnet.cnn.layer.ReLULayer','nnet.cnn.layer.LeakyReLULayer','nnet.cnn.layer.ClippedReLULayer'}
                v=true;
            otherwise
            end
        end
        function v=isInput(layer)
            v=false;
            switch(class(layer))
            case{'nnet.cnn.layer.ImageInputLayer',...
                'nnet.cnn.layer.Image3DInputLayer',...
                'nnet.cnn.layer.SequenceInputLayer',...
'nnet.cnn.layer.FeatureInputLayer'...
                }
                v=true;
            otherwise
            end
        end
        function v=isOutput(layer)
            v=false;
            switch(class(layer))
            case{'nnet.cnn.layer.ClassificationOutputLayer',...
                'nnet.cnn.layer.RegressionOutputLayer',...
'nnet.cnn.layer.PixelClassificationLayer'...
                }
                v=true;
            otherwise
            end
        end
        function v=isDropout(layer)
            v=false;
            switch(class(layer))
            case{'nnet.cnn.layer.DropoutLayer'}
                v=true;
            otherwise
            end
        end

        function v=isIdentity(layer)
            v=false;
            switch(class(layer))
            case{'dnnfpga.layer.identityLayer'}
                v=true;
            otherwise
            end
        end

        function v=isConstant(layer)
            v=false;
            switch(class(layer))
            case{'dnnfpga.layer.constantLayer'}
                v=true;
            otherwise
            end
        end

        function v=isLabel(layer)
            v=false;
            switch(class(layer))
            case{'dnnfpga.layer.labelLayer'}
                v=true;
            otherwise
            end
        end

        function v=isFCFmt(layer)
            v=false;
            switch(class(layer))
            case{'dnnfpga.layer.toFCFmtLayer'}
                v=true;
            otherwise
            end
        end
        function v=isResize(layer)
            v=false;
            switch(class(layer))
            case{'dnnfpga.layer.padLayer','dnnfpga.layer.truncateLayer'}
                v=true;
            otherwise
            end
        end


        function v=isCustomLayer(layer)
            v=false;
            classes=superclasses(layer);
            notCustom=any(strcmp(classes,'dnnfpga.layer.NotCustomLayer'));
            if notCustom
                return;
            end
            for idx=1:numel(classes)
                switch(classes{idx})



                case{'nnet.layer.Layer'}
                    v=true;
                    break;
                otherwise
                end
            end
        end


        function v=isSupported(layer,hPC)


            v=false;
            supportedLayers={'nnet.cnn.layer.Convolution2DLayer',...
            'nnet.cnn.layer.GroupedConvolution2DLayer',...
            'nnet.cnn.layer.FullyConnectedLayer',...
            'nnet.cnn.layer.ReLULayer',...
            'nnet.cnn.layer.LeakyReLULayer',...
            'nnet.cnn.layer.ClippedReLULayer',...
            'nnet.cnn.layer.BatchNormalizationLayer',...
            'nnet.cnn.layer.CrossChannelNormalizationLayer',...
            'nnet.cnn.layer.MaxPooling2DLayer',...
            'nnet.cnn.layer.AveragePooling2DLayer',...
            'nnet.cnn.layer.GlobalAveragePooling2DLayer',...
            'nnet.cnn.layer.ImageInputLayer',...
            'nnet.cnn.layer.Image3DInputLayer',...
            'nnet.cnn.layer.DropoutLayer',...
            'nnet.cnn.layer.SoftmaxLayer',...
            'nnet.cnn.layer.ClassificationOutputLayer',...
            'nnet.cnn.layer.RegressionOutputLayer',...
            'nnet.cnn.layer.YOLOv2TransformLayer',...
            'nnet.cnn.layer.YOLOv2OutputLayer',...
            'nnet.cnn.layer.ConcatenationLayer',...
            'nnet.cnn.layer.DepthConcatenationLayer',...
            'nnet.cnn.layer.MaxUnpooling2DLayer',...
            'nnet.cnn.layer.TransposedConvolution2DLayer',...
            'nnet.cnn.layer.PixelClassificationLayer',...
            'nnet.cnn.layer.SigmoidLayer',...
'dnnfpga.layer.ExponentialLayer'...
            ,'nnet.cnn.layer.SequenceInputLayer'...
            ,'dnnfpga.macros.ACCUMLayer'...
            ,'dnnfpga.layer.identityLayer'...
            ,'dnnfpga.layer.constantLayer'...
            ,'dnnfpga.layer.labelLayer'...
            ,'dnnfpga.layer.toFCFmtLayer'...
            ,'dnnfpga.layer.padLayer'...
            ,'dnnfpga.layer.truncateLayer'...
            ,'dnnfpga.layer.wordEmbeddingLayerDLP',...
'nnet.cnn.layer.FeatureInputLayer'...
            };








            customLayers={};
            if~isempty(hPC)
                for hCustomLayer=hPC.CustomLayerManager.getLayerList(true)
                    customLayers{end+1}=hCustomLayer.ClassName;%#ok<AGROW>
                end
            end
            supportedLayers=cat(2,supportedLayers,customLayers);

            if isa(layer,'nnet.layer.ClassificationLayer')
                v=true;
            else
                switch(class(layer))
                case supportedLayers
                    v=true;
                otherwise
                end
            end
        end

        function validateNetworkLayers(layer,processor)





            if isa(layer,'nnet.cnn.layer.ConcatenationLayer')
                if~isequal(layer.Dim,3)
                    error(message('dnnfpga:dnnfpgacompiler:UnsupportedConcatConfig',...
                    layer.Name,sprintf('%d',layer.Dim)));
                end
            end

        end

        function validateNGraphLayers(ngraph,processor)


            import dnnfpga.dagCompile.*

            if~isa(processor,'dnnfpga.processorbase.cnn5Processor')

                return;
            end


            pcc=processor.getCC();
            convThreadNumber=pcc.convp.conv.threadNumLimit;
            fcThreadNumber=pcc.fcp.threadNumLimit;
            dataTransferNumber=pcc.dataTransNum;


            cc=ngraph.components;
            for component=cc'
                recvs=Layers.getConcatReceivers(component);
                if numel(recvs)>1
                    recvsUnique=unique(recvs);
                    if numel(recvsUnique)==1

                        concatName=recvsUnique(1).name;
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedDepthConcatSharedInputs',...
                        concatName);
                        error(msg);
                    else

                        inputName=component.name;
                        concatName=recvsUnique(1).name;
                        otherConcatName=recvsUnique(2).name;
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedDepthConcatSharedInputForMultipleDepthConcats',...
                        inputName,...
                        concatName,...
                        otherConcatName);
                        error(msg);
                    end
                end
            end

            for component=cc'
                if component.hasKind(LayerKind.Concat)


                    for pinst=component.inputs'
                        net=pinst.net;
                        format=net.dataFormat;


                        if net.driver.component.hasKind(LayerKind.Concat)
                            continue;
                        end

                        inputSize=pinst.size;

                        assert(length(inputSize)==3,'dimension should be 3');

                        inputFeatureNumber=inputSize(3);

                        driverName=net.driver.component.name;



                        if format==DataFormat.Conv||format==DataFormat.FC
                            if rem(inputFeatureNumber,dataTransferNumber)~=0
                                error(message('dnnfpga:dnnfpgacompiler:UnsupportedDepthConcatMultipleConv',...
                                driverName,sprintf('%d',inputFeatureNumber),sprintf('%d',dataTransferNumber)));
                            end
                        end




                        if format==DataFormat.FCDirect
                            if rem(inputFeatureNumber,fcThreadNumber)~=0
                                error(message('dnnfpga:dnnfpgacompiler:UnsupportedDepthConcatMultipleFC',...
                                driverName,sprintf('%d',inputFeatureNumber),sprintf('%d',fcThreadNumber)));
                            end
                        end
                    end
                end
            end
        end



        function recvs=getConcatReceivers(component)
            import dnnfpga.dagCompile.*
            recvs=[];
            for i=1:numel(component.outputs)
                pinst_driver=component.outputs(i);
                net=pinst_driver.net;
                for j=1:numel(net.receivers)
                    pinst=net.receivers(j);
                    recvComponent=pinst.component;
                    if recvComponent.hasKind(LayerKind.Concat)
                        recvs=[recvs,recvComponent];
                    end
                end
            end
        end

        function isInput=isDepthConcatInput(component)
            import dnnfpga.dagCompile.*
            isInput=false;
            net=component.outputs.net;
            for i=1:numel(net.receivers)
                pinst=net.receivers(i);
                if pinst.component.hasKind(LayerKind.Concat)
                    isInput=true;
                end
            end
        end

    end
end
