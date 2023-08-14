classdef cnn4ProcessorTransformChain<dnnfpga.compiler.abstractCNNProcessorTransformChain



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=cnn4ProcessorTransformChain()
            obj@dnnfpga.compiler.abstractCNNProcessorTransformChain();
        end
    end

    methods(Access=protected)

        function fifoParam=getFIFOIR(~,inputSize,lastConvParam,~)







        end
    end

    methods(Access=public)
        function output=doit(~,input,processor,varargin)


            dataType=dnnfpga.compiler.processorKernelType(processor);
            if(strcmpi(dataType.dataTypeConv,'int8')||strcmpi(dataType.dataTypeFC,'int8'))
                deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.InsertBFPScalingModule(input,dataType);
            else
                deployableLayerParams=input;
            end


            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'ActivationLayer','',@ischar);
            addParameter(p,'ParentDataFormat',[],@(x)isa(x,'dnnfpga.dagCompile.DataFormat'));

            parse(p,varargin{:});

            activationLayer=p.Results.ActivationLayer;
            parentDataFormat=p.Results.ParentDataFormat;
            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.scheduleDeployableLayers(deployableLayerParams,processor);

            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.reduceTillActivationLayer(deployableLayerParams,activationLayer);



            deployableLayerParams=dnnfpga.compiler.cnn4ProcessorTransformChain.resolvePaddingForSplit(deployableLayerParams,processor);


            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.insertFPGA2SNLayer(deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.cnn4ProcessorTransformChain.scheduleInsideDeployableLayers(deployableLayerParams,processor,varargin{:});
            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.activateZAdapter(deployableLayerParams,processor);




            deployableLayerParams=dnnfpga.compiler.cnn4ProcessorTransformChain.transformFCWeights(deployableLayerParams,processor,parentDataFormat);

            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.fixRAWHarzard(deployableLayerParams,processor.getFCProcessor());
            output=deployableLayerParams;
        end
    end

    methods(Access=public,Static=true)


        function deployableLayerParams=scheduleInsideDeployableLayers(deployableLayerParams,cnnp,varargin)

            for i=1:length(deployableLayerParams)
                layerType=deployableLayerParams{i}.type;
                switch layerType
                case 'FPGA_Conv'
                    deployableLayerParams{i}.params=dnnfpga.compiler.abstractCNNProcessorTransformChain.scheduleLayers(deployableLayerParams{i}.params,cnnp.getConvProcessor());
                case 'FPGA_FC'
                    deployableLayerParams{i}.params=dnnfpga.compiler.abstractCNNProcessorTransformChain.scheduleLayers(deployableLayerParams{i}.params,cnnp.getFCProcessor());
                case 'SW_SeriesNetwork'
                case 'SW_SeriesNetwork2FPGA'
                case 'SW_FPGA2SeriesNetwork'
                otherwise
                    assert(false,'Unexpected deployable layer: %s',layerType);
                end
            end

        end

































        function deployableLayerParamsOut=transformFCWeights(deployableLayerParamsIn,cnn4Processor,parentDataFormat)






























            deployableLayerParamsOut=deployableLayerParamsIn;

            for ii=1:length(deployableLayerParamsOut)
                currentModuleLayerParam=deployableLayerParamsOut{ii};
                layerType=currentModuleLayerParam.type;

                switch layerType
                case{'FPGA_FC'}














                    if(strcmpi(currentModuleLayerParam.params{1}.type,'FPGA_GAP2D')||...
                        strcmpi(currentModuleLayerParam.params{1}.type,'FPGA_Softmax')||...
                        strcmpi(currentModuleLayerParam.params{1}.type,'FPGA_Sigmoid')||...
                        strcmpi(currentModuleLayerParam.params{1}.type,'FPGA_Exponential'))
                        continue;
                    end
                    if ii>1


                        previousModuleLayerParam=deployableLayerParamsOut{ii-1};
                    else
                        previousModuleLayerParam=[];
                    end

                    if~isempty(previousModuleLayerParam)
                        previousModuleLayerType=previousModuleLayerParam.type;
                    else
                        previousModuleLayerType='';
                    end


                    if isempty(parentDataFormat)
                        continue;
                    end












                    if parentDataFormat==dnnfpga.dagCompile.DataFormat.Conv

                        previousLayer=previousModuleLayerParam.params{end};




                        dataTransNum=cnn4Processor.getCC.dataTransNum;
                        conv2Processor=cnn4Processor.getConvProcessor.getConvProcessor;
                        convThreadNum=conv2Processor.getCC.threadNumLimit;

                        if strcmpi(previousModuleLayerType,'FPGA_Conv')



                            previousOutputSize=conv2Processor.resolveOutputSizeLayerWithoutPadding(previousLayer);
                        else

                            previousOutputSize=[previousLayer.origImgSize(1:2);previousLayer.inputFeatureNum];
                        end


                        firstFCLayer=currentModuleLayerParam.params{1};
                        currentFCWeight=firstFCLayer.weights;





                        InputVectorLength=prod(previousOutputSize);


                        indexVectorIn=1:InputVectorLength;





                        index3DOut=dnnfpga.format.convertDDRVectorFormatConv4To3DOutput(...
                        indexVectorIn,convThreadNum,previousOutputSize');
                        indexVectorOut=index3DOut(:);







                        newFCWeight=currentFCWeight;
                        if any(indexVectorOut'~=indexVectorIn)





                            for ssii=1:InputVectorLength
                                newFCWeight(ssii,:)=currentFCWeight(indexVectorOut==ssii,:);
                            end
                        end
                        currentFCWeight=newFCWeight;







                        originalOutputSize3=previousOutputSize(3);
                        if(dataTransNum>1)
                            previousOutputSize(3)=ceil(previousOutputSize(3)/convThreadNum)*dataTransNum;
                        end

                        if(originalOutputSize3~=previousOutputSize(3))


                            InputVectorLength=prod(previousOutputSize);
                            startIdx=prod([previousOutputSize(1:2)',floor(originalOutputSize3/convThreadNum)*dataTransNum]);


















                            paddedSize=dataTransNum-convThreadNum;
                            if paddedSize>0
                                currentIdx=1;
                                for idx=1:dataTransNum:startIdx

                                    newFCWeight(idx:idx+convThreadNum-1,:)=currentFCWeight(currentIdx:currentIdx+convThreadNum-1,:);
                                    currentIdx=currentIdx+convThreadNum;



                                    newFCWeight(idx+convThreadNum:idx+dataTransNum-1,:)=zeros(paddedSize,size(newFCWeight,2));
                                end
                            else
                                newFCWeight=currentFCWeight(1:startIdx,:);
                                currentIdx=startIdx+1;
                            end




                            modNum=mod(originalOutputSize3,convThreadNum);
                            for newIdx=startIdx+1:dataTransNum:InputVectorLength

                                newFCWeight(newIdx:newIdx+modNum-1,:)=currentFCWeight(currentIdx:currentIdx+modNum-1,:);
                                currentIdx=currentIdx+modNum;



                                newFCWeight(newIdx+modNum:newIdx+dataTransNum-1,:)=zeros(dataTransNum-modNum,size(newFCWeight,2));
                            end


                            deployableLayerParamsOut{ii}.params{1}.matrixSize(1)=InputVectorLength;
                        else



                            newFCWeight=currentFCWeight;
                        end


                        deployableLayerParamsOut{ii}.params{1}.weights=newFCWeight;

                    end

                otherwise

                end
            end



        end

    end
end



