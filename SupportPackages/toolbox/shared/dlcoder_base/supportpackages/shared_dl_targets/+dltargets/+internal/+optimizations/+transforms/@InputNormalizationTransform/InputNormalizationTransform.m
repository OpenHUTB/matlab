classdef InputNormalizationTransform<handle




    properties(Access=private)
CodegenInfo
scale
offset
isSequenceInput
isImageInput
isFeatureInput
    end

    properties(Constant)

        prec='single';

    end

    methods

        function runTransform(this,CodegenInfo)


            this.CodegenInfo=CodegenInfo;

            sortedLayersArray=this.CodegenInfo.NetworkInfo.SortedLayerGraph.Layers;


            ipLayerIndices=arrayfun(@(layer)isa(layer,'nnet.cnn.layer.ImageInputLayer')||...
            isa(layer,'nnet.cnn.layer.SequenceInputLayer')||...
            isa(layer,'nnet.cnn.layer.FeatureInputLayer'),sortedLayersArray);


            ipLayers=sortedLayersArray(ipLayerIndices);

            for i=1:nnz(ipLayerIndices)


                layer=ipLayers(i);
                inputComp=this.CodegenInfo.layer2comp(layer.Name);

                if isa(layer,'nnet.cnn.layer.ImageInputLayer')

                    this.isImageInput=true;

                elseif isa(layer,'nnet.cnn.layer.FeatureInputLayer')

                    this.isFeatureInput=true;

                elseif isa(layer,'nnet.cnn.layer.SequenceInputLayer')

                    this.isSequenceInput=true;

                end

                this.processNormalization(layer,inputComp);

            end

        end

    end

    methods(Access=private)


        computeZscoreScaleAndOffset(this,layer);
        zeroCenterStrategy(this,layer,comp);
        saveLayerFiles(this,layer,comp);
        comp=createAndSetElementwiseAffineLayerComp(this,layer);
        computeRescaleNormScaleAndOffset(this,layer);

    end

    methods(Access=private)

        function processNormalization(this,layer,inputComp)

            normMethod=lower(layer.Normalization);

            switch normMethod
            case{'zerocenter','zscore','rescale-symmetric','rescale-zero-one'}

                affineLayerComp=this.doAffineLayerTransform(layer,inputComp);


                this.saveLayerFiles(layer,affineLayerComp);

            case 'none'
                return;

            otherwise
                error(message('dlcoder_spkg:cnncodegen:unsupported_invalid_normalization',layer.Normalization));
            end

        end











        function affineLayerComp=doAffineLayerTransform(this,layer,inputComp)


            this.computeScaleAndOffset(layer);


            affineLayerComp=this.createAndSetElementwiseAffineLayerComp(layer);


            ipDLTIdx=inputComp.getDLTActivationLayerIndex;


            affineLayerComp.setDLTActivationLayerIndex(int32(ipDLTIdx));


            inputComp.setDLTActivationLayerIndex(int32(-1));

            this.CodegenInfo.hN=this.reconnectComps(this.CodegenInfo.hN,inputComp,affineLayerComp);

        end









        function computeScaleAndOffset(this,layer)

            if strcmpi(layer.Normalization,'zerocenter')

                this.computeZeroCentreScaleAndOffset(layer);


            elseif strcmpi(layer.Normalization,'zscore')

                this.computeZscoreScaleAndOffset(layer);

            elseif(strcmpi(layer.Normalization,'rescale-symmetric')||strcmpi(layer.Normalization,'rescale-zero-one'))

                this.computeRescaleNormScaleAndOffset(layer);

            end

        end


        function computeZeroCentreScaleAndOffset(this,layer)

            Mean=layer.Mean;

            codegenInputSizeForLayer=this.CodegenInfo.NetworkInfo.InputLayerNameToInputSizeMap(layer.Name);
            if this.isImageInput
                isInputImageSizeSameAsTrainingSize=isequal(codegenInputSizeForLayer(1:2),layer.InputSize(1:2));
                if(~isInputImageSizeSameAsTrainingSize)


                    Mean=iComputeMeanPerChannel(Mean);
                end

            elseif this.isFeatureInput
                assert(numel(layer.InputSize)==1);

                Mean=reshape(Mean,[1,1,size(Mean,2)]);

            elseif this.isSequenceInput
                if numel(layer.InputSize)<2

                    Mean=reshape(Mean,[1,1,size(Mean,1)]);
                end
            end

            this.offset=-1*Mean;
            this.scale=ones(size(this.offset));

        end




        function hN=reconnectComps(~,hN,ipcomp,comp)


            hSignal=ipcomp.PirOutputSignals(1);
            hSignal.disconnectDriver(ipcomp,0);


            hSignal.addDriver(comp,0);


            hS=hN.addSignal;
            hS.addDriver(ipcomp,0);
            hS.addReceiver(comp,0);



            ipCompOutPorts=ipcomp.PirOutputPorts;
            dltargets.internal.setCompDataFormats(comp,{char(ipCompOutPorts.getDataFormat)},{char(ipCompOutPorts.getDataFormat)});

        end

    end

end

function out=iComputeMeanPerChannel(dataAvg)
    out=nnet.internal.cnn.layer.util.computeMeanOfMeans(dataAvg,1:2);
end
