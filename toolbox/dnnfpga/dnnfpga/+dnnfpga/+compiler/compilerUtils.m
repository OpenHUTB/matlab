classdef compilerUtils



    methods(Static=true)

        function params=resolvePaddingForSplitForConv(params,processor)
            hasIOFP=false;
            foundFirstConvLayer=false;
            for i=1:length(params)
                if(~strcmpi(params{i}.type,'FPGA_Conv2D'))
                    continue;
                end
                hasIFP=isfield(params{i},'inputFeatureNumToPadForSplit');
                hasOFP=isfield(params{i},'outputFeatureNumToPadForSplit');
                assert(hasIFP==hasOFP,'Only one in/outputFeatureNumToPadForSplit field exists');
                if(~foundFirstConvLayer)
                    hasIOFP=hasIFP;
                    foundFirstConvLayer=true;
                else
                    assert(hasIOFP==hasIFP,'Some conv layers have in/outputFeatureNumToPadForSplit fields, but some don''t');
                end
            end
            if(~hasIOFP)
                cc=processor.getConvProcessor.getCCS();
                convLayerIdx=[];
                for i=1:length(params)
                    if(strcmpi(params{i}.type,'FPGA_Conv2D'))
                        convLayerIdx(end+1)=i;
                    end
                    params{i}.inputFeatureNumToPadForSplit=0;
                    params{i}.outputFeatureNumToPadForSplit=0;
                end
                for i=1:length(convLayerIdx)
                    curLayerIdx=convLayerIdx(i);
                    if(params{curLayerIdx}.convSplitMode)

                        params{curLayerIdx}.inputFeatureNumToPadForSplit=mod(-params{curLayerIdx}.inputFeatureNum/2,cc.threadNumLimit)*2;

                        params{curLayerIdx}.outputFeatureNumToPadForSplit=mod(-params{curLayerIdx}.outputFeatureNum/2,cc.threadNumLimit)*2;
                    else
                        if(i>1&&params{convLayerIdx(i-1)}.outputFeatureNumToPadForSplit>0)

                            params{curLayerIdx}.inputFeatureNumToPadForSplit=mod(-params{curLayerIdx}.inputFeatureNum/2,cc.threadNumLimit)*2;
                        end
                        if(i<length(convLayerIdx)&&params{convLayerIdx(i+1)}.convSplitMode)

                            params{curLayerIdx}.outputFeatureNumToPadForSplit=mod(-params{curLayerIdx}.outputFeatureNum/2,cc.threadNumLimit)*2;
                        end
                    end
                end
            end
            for i=2:length(params)
                if(strcmpi(params{i}.type,'FPGA_Conv2D'))
                    continue;
                end
                params{i}.inputFeatureNumToPadForSplit=params{i-1}.outputFeatureNumToPadForSplit;
                params{i}.outputFeatureNumToPadForSplit=params{i-1}.outputFeatureNumToPadForSplit;
            end
        end

        function Z=SNLayerPredict(externalLayer,X)









            if(~license('test','Neural_Network_Toolbox'))
                assert(false,'Neural network toolbox license is not available.');
            end
            internalLayer=nnet.internal.cnn.layer.util.ExternalInternalConverter.getInternalLayers(externalLayer);
            internalLayer=internalLayer{1};
            Z=internalLayer.predict(X);
        end

        function params=fixFCRAWHarzard(params,processor)
            cc=processor.getCC();


            if~iscell(params)&&(length(params)==1)
                params={params};
            end

            for i=1:length(params)
                if strcmpi(params{i}.type,'FPGA_Output')
                    params{i}.outputNumToPadForRAWHazard=0;
                    continue;
                end
                if(~(strcmpi(params{i}.type,'FPGA_FC')||...
                    strcmpi(params{i}.type,'FPGA_GAP2D')||...
                    strcmpi(params{i}.type,'FPGA_Softmax')||...
                    strcmpi(params{i}.type,'FPGA_Sigmoid')||...
                    strcmpi(params{i}.type,'FPGA_Exponential')))
                    continue;
                end
                params{i}.inputNumToPadForRAWHazard=0;
                outputToPad=cc.RAWHazardLatencyThreshold*cc.threadNumLimit-params{i}.matrixSize(2);
                if(outputToPad<0)
                    outputToPad=0;
                end
                params{i}.matrixSize(2)=params{i}.matrixSize(2)+outputToPad;
                if(mod(params{i}.matrixSize(2),cc.threadNumLimit)~=0)
                    outputToPad=outputToPad+mod(-params{i}.matrixSize(2),cc.threadNumLimit);
                    params{i}.matrixSize(2)=params{i}.matrixSize(2)+mod(-params{i}.matrixSize(2),cc.threadNumLimit);
                end
                params{i}.outputNumToPadForRAWHazard=outputToPad;
                if(i<length(params))
                    params{i+1}.inputNumToPadForRAWHazard=outputToPad;
                end
            end
        end

        function originalSNLayer=getCorrespondingSNLayer(param)
            originalSNLayer=[];
            if isfield(param,'frontendLayers')
                originalSNLayer=strjoin(param.frontendLayers,'/');
            end
        end
    end
end


