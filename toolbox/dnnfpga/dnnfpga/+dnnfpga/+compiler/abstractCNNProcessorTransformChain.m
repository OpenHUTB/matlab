classdef abstractCNNProcessorTransformChain<dnnfpga.compiler.abstractDNNCompilerStage



    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=abstractCNNProcessorTransformChain()
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end

    methods(Access=protected,Abstract=true)
        fifoParam=getFIFOIR(~,inputSize,lastConvParam,processor)
    end

    methods(Access=public)
        function output=doit(this,input,processor,varargin)
            cc=processor.getCC();
            dataType=dnnfpga.compiler.processorKernelType(processor);
            if(strcmpi(dataType.dataTypeConv,'int8')||strcmpi(dataType.dataTypeFC,'int8'))
                deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.InsertBFPScalingModule(input,dataType);
            else
                deployableLayerParams=input;
            end
            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.scheduleDeployableLayers(deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.makeInputSquare(deployableLayerParams);


            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.resolvePaddingForSplit(deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.configureFIFOs(this,deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.insertFPGA2SNLayer(deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.scheduleInsideDeployableLayers(deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.activateZAdapter(deployableLayerParams,processor);
            deployableLayerParams=dnnfpga.compiler.cnnProcessorTransformChain.fixRAWHarzard(deployableLayerParams,processor.getFCProcessor());
            output=deployableLayerParams;
        end
    end

    methods(Access=public,Static=true)
        function deployableLayerParams=scheduleDeployableLayers(fpgaParamLayers,processor)
            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.fuseLayers(fpgaParamLayers,processor);
        end

        function deployableLayerParams=makeInputSquare(fpgaParamLayers)
            rowsGreaterThanColumns=true;
            noConvLayers=true;
            for i=1:length(fpgaParamLayers)
                param=fpgaParamLayers{i};
                layerType=param.type;
                lastOrigConvInpSize=0;

                if isequal(layerType,'FPGA_Conv')
                    noConvLayers=false;
                    imgSize=param.params{1}.origImgSize;



                    if imgSize(1)==imgSize(2)
                        break;
                    elseif imgSize(1)<imgSize(2)
                        rowsGreaterThanColumns=false;
                    end
                end
                switch layerType
                case 'FPGA_Conv'



                    for j=1:length(param.params)
                        currConv=param.params{j};
                        imgSize=currConv.origImgSize;
                        maxOrgImgSize=max(imgSize(1),imgSize(2));




                        lastOrigConvOutputSize=dnnfpga.compiler.propagateConvLayerOutputSize(currConv);
                        currConv.origImgSize=[maxOrgImgSize;maxOrgImgSize;imgSize(3)];
                        param.params{j}=currConv;

                    end

                case 'FPGA_FC'

                    if noConvLayers
                        break
                    end

                    firstFC=param.params{1};
                    matrixSize=firstFC.matrixSize;
                    weights=firstFC.weights;


                    lastConvOutSize=dnnfpga.compiler.propagateConvLayerOutputSize(fpgaParamLayers{i-1}.params{end});
                    lastConvOutFeatureNum=fpgaParamLayers{i-1}.params{end}.outputFeatureNum;

                    newMatrixSize=matrixSize;
                    newMatrixSize(1)=prod(lastConvOutSize)*lastConvOutFeatureNum;
                    newWeights=zeros(newMatrixSize);





                    lowerSize=min(lastOrigConvOutputSize(1:2));
                    zeroPadLength=(lastConvOutSize(1)-lowerSize);





                    if rowsGreaterThanColumns
                        startRowIdx=1;endRowIdx=1;origWeightsEndIdx=0;

                        for k=1:lastConvOutFeatureNum
                            origWeightsStartIdx=origWeightsEndIdx+1;
                            origWeightsEndIdx=origWeightsStartIdx+lowerSize*lastConvOutSize(1)-1;
                            startRowIdx=endRowIdx;
                            endRowIdx=startRowIdx+lowerSize*lastConvOutSize(1)-1;
                            newWeights(startRowIdx:endRowIdx,:)=weights(origWeightsStartIdx:origWeightsEndIdx,:);
                            endRowIdx=endRowIdx+zeroPadLength*lastConvOutSize(1)+1;
                        end
                    else
                        startRowIdx=1;endRowIdx=lastConvOutSize(1);
                        for k=0:(lastConvOutSize(1)*lastConvOutFeatureNum-1)
                            origMatrixStartIdx=k*lowerSize+1;
                            newWeights(startRowIdx:endRowIdx,:)=[weights(origMatrixStartIdx:(origMatrixStartIdx+lowerSize-1),:);
                            zeros(zeroPadLength,newMatrixSize(2))];

                            startRowIdx=endRowIdx+1;
                            endRowIdx=startRowIdx+lastConvOutSize(1)-1;
                        end
                    end

                    firstFC.matrixSize=newMatrixSize;
                    firstFC.weights=newWeights;

                    param.params{1}=firstFC;
                end
                fpgaParamLayers{i}=param;
            end

            deployableLayerParams=fpgaParamLayers;
        end






        function deployableLayerIR=reduceTillActivationLayer(deployableLayerParams,activationLayer)
            deployableLayerIR={};
            for jj=1:length(deployableLayerParams)
                layerIR=deployableLayerParams{jj};
                deployableLayerIR{end+1}=layerIR;
                if(strcmp(layerIR.type,'FPGA_Conv')||strcmp(layerIR.type,'FPGA_FC'))
                    params={};
                    for ii=1:length(layerIR.params)
                        params{end+1}=layerIR.params{ii};
                        if(any(strcmp(layerIR.params{ii}.frontendLayers,activationLayer)))
                            deployableLayerIR{end}.params=params;
                            return;
                        end
                    end

                end
            end
        end

        function deployableLayerParams=fuseLayers(fpgaParamLayers,processor)

            deployableLayerParams={};
            convParams={};
            fcParams={};
            state=0;
            for i=1:length(fpgaParamLayers)
                param=fpgaParamLayers{i};
                layerType=param.type;

                switch state
                case 0
                    switch layerType
                    case{'FPGA_Conv2D','FPGA_Maxpool2D','FPGA_Avgpool2D','FPGA_Input','FPGA_Lrn2D','FPGA_ConvND','FPGA_Unpool2D','FPGA_TransposedConv'}
                        convParams{1}=param;
                        state=1;

                    case{'FPGA_FC','FPGA_GAP2D','FPGA_Softmax','FPGA_Sigmoid','FPGA_Exponential'}
                        fcParams{1}=param;
                        state=2;

                    case{'FPGA_FIFO','SW_SeriesNetwork'}
                        deployableLayerParams{end+1}=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams(layerType,{param},processor);
                        state=0;
                    otherwise
                        assert(false,'Unexpected layers "%s"',layerType);
                    end
                case 1
                    switch layerType
                    case{'FPGA_Conv2D','FPGA_Maxpool2D','FPGA_Avgpool2D','FPGA_Input','FPGA_Lrn2D','FPGA_ConvND','FPGA_Unpool2D','FPGA_TransposedConv'}
                        convParams{end+1}=param;
                        state=1;

                    case{'FPGA_FC','FPGA_GAP2D','FPGA_Softmax','FPGA_Sigmoid','FPGA_Exponential'}
                        deployableLayerParams{end+1}=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams('FPGA_Conv',convParams,processor);
                        convParams={};
                        fcParams{1}=param;
                        state=2;

                    case{'FPGA_FIFO','SW_SeriesNetwork'}
                        deployableLayerParams{end+1}=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams('FPGA_Conv',convParams,processor);
                        convParams={};
                        deployableLayerParams{end+1}=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams(layerType,{param},processor);
                        state=0;
                    otherwise
                        assert(false,'Unexpected layers "%s"',layerType);
                    end
                case 2
                    switch layerType
                    case{'FPGA_Conv2D','FPGA_Maxpool2D','FPGA_Avgpool2D','FPGA_Input','FPGA_Lrn2D','FPGA_ConvND','FPGA_Unpool2D','FPGA_TransposedConv'}
                        deployableLayerParams{end+1}=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams('FPGA_FC',fcParams,processor);
                        fcParams={};
                        convParams{1}=param;
                        state=1;

                    case{'FPGA_FC','FPGA_Output','FPGA_GAP2D','FPGA_Softmax','FPGA_Sigmoid','FPGA_Exponential'}
                        fcParams{end+1}=param;
                        state=2;

                    case{'FPGA_FIFO','SW_SeriesNetwork'}
                        deployableLayerParams{end+1}=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams('FPGA_FC',fcParams,processor);
                        fcParams={};
                        deployableLayerParams{end+1}=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams(layerType,{param},processor);
                        state=0;
                    otherwise
                        assert(false,'Unexpected layers "%s"',layerType);
                    end
                otherwise
                    assert(false,'Unexpected state "%d"',state);
                end
            end
            if(~isempty(convParams))
                assert(isempty(fcParams));
                deployableLayerParams{end+1}=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams('FPGA_Conv',convParams,processor);
            elseif(~isempty(fcParams))
                deployableLayerParams{end+1}=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams('FPGA_FC',fcParams,processor);
            end
        end

        function dlp=getDepolyablelayerParams(type,params,processor)
            dlp.type=type;
            dlp.params=params;
            dlp.processor=processor;
        end

        function deployableLayerParams=configureFIFOs(transformChain,deployableLayerParams,processor)
            state=0;
            i=1;
            while(i<=length(deployableLayerParams))
                dlp=deployableLayerParams{i};
                layerType=dlp.type;

                switch state
                case 0
                    switch layerType
                    case 'FPGA_Conv'

                        if isa(processor,'dnnfpga.processorbase.cnn2Processor')
                            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.insertInputLayer(deployableLayerParams,i,processor);
                        elseif isa(processor,'dnnfpga.processorbase.conv2Processor')
                            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.insertInputLayer(deployableLayerParams,i,processor);
                        elseif isa(processor,'dnnfpga.processorbase.conv4Processor')
                            deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.insertInputLayer(deployableLayerParams,i,processor);
                        end
                        state=1;
                    case 'FPGA_FC'
                        state=3;
                    case 'SW_SeriesNetwork'
                        state=0;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                case 1
                    switch layerType
                    case 'FPGA_FIFO'
                        state=2;
                    case 'FPGA_FC'

                        lastConvParam=deployableLayerParams{i-1}.params{end};
                        inputSize=dnnfpga.compiler.propagateConvLayerOutputSize(lastConvParam);
                        fifo1Param=transformChain.getFIFOIR(inputSize,lastConvParam,processor);
                        dlp=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams('FPGA_FIFO',{fifo1Param},processor);
                        deployableLayerParams={deployableLayerParams{1:i-1},dlp,deployableLayerParams{i:end}};

                        i=i+1;
                        state=3;
                    case 'SW_SeriesNetwork'
                        state=3;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                case 2
                    switch layerType
                    case 'FPGA_FC'
                        state=3;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                case 3
                    switch layerType
                    case 'FPGA_Output'
                        state=4;
                    case 'SW_SeriesNetwork'

                        deployableLayerParams=dnnfpga.compiler.abstractCNNProcessorTransformChain.insertOutputLayer(deployableLayerParams,i,processor.getFCProcessor);
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                case 4
                    switch layerType
                    case 'SW_SeriesNetwork'
                        state=4;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end














                otherwise
                    assert(false,'Unexpected state "%d"',state);
                end
                i=i+1;
            end
        end




























        function deployableLayerParams=insertInputLayer(deployableLayerParams,i,processor)
            if~strcmpi(deployableLayerParams{i}.params{1}.type,'FPGA_Input')
                inputParam=deployableLayerParams{i}.params{1};
                if isfield(inputParam,'weights')
                    inputParam=rmfield(inputParam,'weights');
                end
                if isfield(inputParam,'bias')
                    inputParam=rmfield(inputParam,'bias');
                end
                inputParam.outputFeatureNum=inputParam.inputFeatureNum;
                inputParam.outputFeatureNumToPadForSplit=deployableLayerParams{i}.params{1}.inputFeatureNumToPadForSplit;
                inputParam.inputFeatureNumToPadForSplit=inputParam.outputFeatureNumToPadForSplit;
                inputParam.activeFIFOMemSel=false;
                inputParam.type='FPGA_Input';
                inputParam.phase='input1';
                inputParam.frontendLayers={inputParam.phase};
                if(isfield(deployableLayerParams{1}.params{1},'snLayer'))
                    if(strcmp(deployableLayerParams{1}.params{1}.snLayer.Normalization,'none'))
                        meanSubtraction=false;
                    else
                        meanSubtraction=true;
                    end
                else
                    meanSubtraction=false;
                end
                selectPaddingType=dnnfpga.processorbase.conv2Processor.determinePaddingType(deployableLayerParams{i}.params{1},processor.getConvProcessor().getCC().threadNumLimit,meanSubtraction);
                inputParam.selectPaddingType=selectPaddingType;
                deployableLayerParams{i}.params=[{inputParam},deployableLayerParams{i}.params];
            end
        end

        function deployableLayerParams=insertOutputLayer(deployableLayerParams,i,~)
            if strcmpi(deployableLayerParams{i-1}.params{end}.type,'FPGA_FC')
                inputParam=deployableLayerParams{i-1}.params{end};
                if isfield(inputParam,'weights')
                    inputParam=rmfield(inputParam,'weights');
                end
                if isfield(inputParam,'bias')
                    inputParam=rmfield(inputParam,'bias');
                end
                inputParam.type='FPGA_Output';
                inputParam.phase='output1';
                inputParam.frontendLayers={inputParam.phase};
                deployableLayerParams{i-1}.params=[deployableLayerParams{i-1}.params,{inputParam}];
            end
        end

        function deployableLayerParams=insertFPGA2SNLayer(deployableLayerParams,processor)
            state=0;
            i=1;
            while(i<=length(deployableLayerParams))
                dlp=deployableLayerParams{i};
                layerType=dlp.type;

                switch state
                case 0
                    switch layerType
                    case 'SW_SeriesNetwork'
                        state=1;
                    otherwise
                        state=2;
                    end
                case 1
                    switch layerType
                    case 'SW_SeriesNetwork'
                        state=1;
                    case{'FPGA_Conv','FPGA_FC'}








                        prevDeployableLayerParams=deployableLayerParams{i-1}.params;
                        dlp=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams('SW_SeriesNetwork2FPGA',prevDeployableLayerParams,processor);
                        deployableLayerParams={deployableLayerParams{1:i-1},dlp,deployableLayerParams{i:end}};
                        i=i+1;
                        state=2;
                    otherwise
                        state=1;
                    end
                case 2
                    switch layerType
                    case 'SW_SeriesNetwork'

                        dlp1=dlp;
                        dlp=dnnfpga.compiler.abstractCNNProcessorTransformChain.getDepolyablelayerParams('SW_FPGA2SeriesNetwork',dlp1.params,processor);
                        deployableLayerParams={deployableLayerParams{1:i-1},dlp,deployableLayerParams{i:end}};
                        i=i+1;
                        state=3;
                    otherwise
                        state=2;
                    end
                case 3
                    switch layerType
                    case 'SW_SeriesNetwork'
                        state=1;
                    otherwise
                        assert(false,'Unexpected deployable layer: %s',layerType);
                    end
                otherwise
                    assert(false,'Unexpected state "%d"',state);
                end
                i=i+1;
            end
        end

        function deployableLayerParams=scheduleInsideDeployableLayers(deployableLayerParams,cnnp)
            for i=1:length(deployableLayerParams)
                layerType=deployableLayerParams{i}.type;
                switch layerType
                case 'FPGA_Conv'
                    deployableLayerParams{i}.params=dnnfpga.compiler.abstractCNNProcessorTransformChain.scheduleLayers(deployableLayerParams{i}.params,cnnp.getConvProcessor());
                case 'FPGA_FC'
                    deployableLayerParams{i}.params=dnnfpga.compiler.abstractCNNProcessorTransformChain.scheduleLayers(deployableLayerParams{i}.params,cnnp.getFCProcessor());
                case 'FPGA_FIFO'
                    deployableLayerParams{i}.params=dnnfpga.compiler.abstractCNNProcessorTransformChain.scheduleLayers(deployableLayerParams{i}.params,cnnp.getFIFO1Processor());
                case 'SW_SeriesNetwork'
                case 'SW_SeriesNetwork2FPGA'
                case 'SW_FPGA2SeriesNetwork'
                otherwise
                    assert(false,'Unexpected deployable layer: %s',layerType);
                end
            end
        end

        function params=scheduleLayers(params,processor)
            logs=processor.sanityCheckNetwork(params);
            if(~isempty(logs))
                logs=strjoin(logs,'\n');
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedNetwork',logs);
                error(msg);
                return;%#ok<UNRCH>
            end
            memDir=true;
            for i=1:length(params)
                if(strcmp(params{i}.type,'FPGA_Lrn2D'))
                    memDir=~memDir;
                end
                params{i}.memDirection=memDir;
                llogs=processor.sanityCheckLayer(params{i});
                if(~isempty(llogs))
                    llogStr=sprintf('%s',strjoin((llogs),'\n'));
                    logs=[logs,llogStr];
                end
                if~strcmp(params{i}.type,'FPGA_Input')
                    memDir=~memDir;
                end
            end
            if(~isempty(logs))
                logs=strjoin(logs,'\n');
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedNetwork',logs);
                error(msg);
            end
        end

        function deployableLayerParams=activateZAdapter(deployableLayerParams,processor)
            for i=1:length(deployableLayerParams)
                layerType=deployableLayerParams{i}.type;
                switch layerType
                case 'FPGA_Conv'
                    convParams=deployableLayerParams{i}.params;
                    for j=1:length(convParams)
                        param=convParams{j};
                        layerType=param.type;
                        convParams{j}.inputMemZAdapterActive=processor.getConvProcessor.inputMemZAdapterActivePred(convParams{j});
                    end
                    deployableLayerParams{i}.params=convParams;
                case 'FPGA_FC'
                case 'FPGA_FIFO'
                case 'SW_SeriesNetwork'
                case 'SW_SeriesNetwork2FPGA'
                case 'SW_FPGA2SeriesNetwork'
                otherwise
                    assert(false,'Unexpected deployable layer: %s',layerType);
                end
            end
        end

        function deployableLayerParams=resolvePaddingForSplit(deployableLayerParams,processor)
            for i=1:length(deployableLayerParams)
                switch deployableLayerParams{i}.type
                case 'FPGA_Conv'
                    deployableLayerParams{i}.params=dnnfpga.compiler.compilerUtils.resolvePaddingForSplitForConv(deployableLayerParams{i}.params,processor);
                case 'FPGA_FC'
                case 'FPGA_FIFO'
                case 'SW_SeriesNetwork'
                otherwise
                    assert(false,'Unexpected type %s',deployableLayerParams{i}.type);
                end
            end
        end


        function deployableLayerParams=fixRAWHarzard(deployableLayerParams,processor)
            for i=1:length(deployableLayerParams)
                switch deployableLayerParams{i}.type
                case 'FPGA_FC'
                    deployableLayerParams{i}.params=dnnfpga.compiler.compilerUtils.fixFCRAWHarzard(deployableLayerParams{i}.params,processor);
                case{'SW_SeriesNetwork','SW_SeriesNetwork2FPGA','SW_FPGA2SeriesNetwork','FPGA_Conv','FPGA_FIFO'}
                otherwise
                    assert(false,'Unexpected type %s',deployableLayerParams{i}.type);
                end
            end
        end




        function deployableLayerParams=InsertBFPScalingModule(fpgaParamLayers,dataType)





            deployableLayerParams={};


            finalRescalingDone=0;
            state=0;
            n=length(fpgaParamLayers);
            for i=1:n
                param=fpgaParamLayers{i};
                layerType=param.type;
                if(i>1)
                    param_prevLayer=fpgaParamLayers{i-1};
                end
                if(i<n)
                    param_nextLayer=fpgaParamLayers{i+1};
                end
                switch state
                case 0
                    switch layerType
                    case{'FPGA_Conv2D','FPGA_Maxpool2D','FPGA_ConvND','FPGA_Avgpool2D','FPGA_TransposedConv'}








                        NextLayerExp=param.OutputExpData;

                        param.rescaleExp=(param.rescaleExp)-(NextLayerExp);
                        deployableLayerParams{end+1}=param;

                        state=0;
                    case{'FPGA_FC','FPGA_GAP2D','FPGA_Softmax','FPGA_Sigmoid','FPGA_Exponential'}
                        if(strcmpi(dataType.dataTypeFC,'single'))



                            if(finalRescalingDone)
                                deployableLayerParams{end+1}=param;
                                continue;
                            end





                            param.fcInputExp=param.ExpData;
                            param.fcOutputExp=param.OutputExpData;
                            deployableLayerParams{end+1}=param;
                            finalRescalingDone=1;
                            continue;
                        else



                            if(~(strcmpi(param.type,'FPGA_Softmax')||strcmpi(param.type,'FPGA_Sigmoid')||strcmpi(param.type,'FPGA_Exponential')))
                                param.fcInputExp=0;
                                param.fcOutputExp=0;
                            end
                        end









                        NextLayerExp=param.OutputExpData;
                        param.rescaleExp=(param.rescaleExp)-(NextLayerExp);

                        deployableLayerParams{end+1}=param;

                        state=0;
                    case{'FPGA_Lrn2D'}







                        param.int8ToSingleExp=param.ExpData;



                        param.singleToInt8Exp=param.OutputExpData;
                        param.rescaleExp=0;

                        deployableLayerParams{end+1}=param;

                        state=0;
                    case{'SW_SeriesNetwork'}

                        if(strcmpi(param.internal_type,'SW_SeriesNetwork_Input'))







                            param.singleToInt8Exp=param.OutputExpData;
                            deployableLayerParams{end+1}=param;

                            state=0;
                            continue;
                        end




                        if(finalRescalingDone)
                            deployableLayerParams{end+1}=param;
                            continue;
                        end


                        param.int8ToSingleExp=param_prevLayer.OutputExpData;

                        deployableLayerParams{end+1}=param;
                        finalRescalingDone=1;
                        state=0;
                    otherwise
                        deployableLayerParams{end+1}=param;
                        state=0;
                    end
                otherwise
                    assert(false,'Unexpected state "%d"',state);
                end
            end
        end
    end
end



