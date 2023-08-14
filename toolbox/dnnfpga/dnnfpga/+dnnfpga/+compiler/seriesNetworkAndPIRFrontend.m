classdef seriesNetworkAndPIRFrontend<dnnfpga.compiler.abstractDNNCompilerStage




    properties(Access=private)
        InstrumentationDataFilePath=[];
    end

    methods(Access=public,Hidden=true)
        function obj=seriesNetworkAndPIRFrontend(varargin)
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
            if~isempty(varargin)
                obj.InstrumentationDataFilePath=varargin{1};
            end
        end
    end

    methods(Access=public)
        function output=doit(~,input,processor,varargin)


            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'Verbose',1);
            addParameter(p,'LegLevel',0);


            parse(p,varargin{:});

            net=input.net;
            argin=input.argin;


            added=[argin,'Verbose',p.Results.Verbose,'LegLevel',p.Results.LegLevel];
            output=dnnfpga.compiler.seriesNetworkAndPIRFrontend.seriesNetworkPIRFrontend(net,processor,added{:});
        end
    end

    methods(Access=private,Static=true)
        function fpgaParamLayers=seriesNetworkPIRFrontend(net,processor,varargin)
            networkName='CnnMain';

            params=varargin(1:end);

            pvpairs=dnnfpga.compiler.seriesNetworkAndPIRFrontend.parse_params(params);

            if(isfield(pvpairs,'hastrueoutputlayer'))
                hasTrueOutputLayer=pvpairs.hastrueoutputlayer;
            else
                hasTrueOutputLayer=true;
            end

            if(isfield(pvpairs,'hastrueinputlayer'))
                hasTrueInputLayer=pvpairs.hastrueinputlayer;
            else
                hasTrueInputLayer=true;
            end

            if(isfield(pvpairs,'maxpooltype'))
                maxpoolType=pvpairs.maxpooltype;
            else
                maxpoolType=0;
            end

            if(isfield(pvpairs,'hasunpool'))
                hasUnpool=pvpairs.hasunpool;
            else
                hasUnpool=false;
            end

            if(isfield(pvpairs,'unpoolremainder'))
                unpoolRemainder=pvpairs.unpoolremainder;
            else
                unpoolRemainder=[0;0];
            end

            if(isfield(pvpairs,'hastransposedconv'))
                hasTransposedConv=pvpairs.hastransposedconv;
            else
                hasTransposedConv=false;
            end

            if(isfield(pvpairs,'issimulator'))
                isSimulator=pvpairs.issimulator;
            else
                isSimulator=false;
            end

            if(isfield(pvpairs,'isestimator'))
                isEstimator=pvpairs.isestimator;
            else
                isEstimator=false;
            end


            if~isfield(pvpairs,'targetdir')||isempty(pvpairs.targetdir)
                pvpairs.targetdir=[pwd,filesep,'codegen'];
            end

            net=dnnfpga.compiler.optimizations.optimizeNetwork(net,pvpairs.verbose);

            codegendir=pvpairs.targetdir;
            dnnfpga.compiler.makeCodegendir(codegendir);
            batchSize=1;
            codegentarget='hdl';
            try
                s=which('dltargets.internal.createPIR');
                if(isempty(s))
                    spkgname='MATLAB Coder Interface for Deep Learning Libraries';
                    spkgbasecode='ML_DEEPLEARNING_LIB';
                    msg=message('dnnfpga:dnnfpgacompiler:MissingSpkg',spkgname,spkgbasecode);
                    error(msg);
                end


                dlcfg.TargetLibrary='hdl';
                inputSize={[net.Layers(1).InputSize,batchSize]};
                networkWrapper=dltargets.internal.NetworkInfo(net,inputSize);
                transformProperties=dltargets.internal.TransformProperties(networkWrapper,-1);



                quantSpecMatFile='';



                pir=dltargets.internal.createPIR(networkWrapper,...
                networkName,...
                codegendir,...
                codegentarget,...
                dlcfg,...
                transformProperties,...
                -1,...
                quantSpecMatFile);
            catch E
                disp(E.message);
                E.getReport;
                throw(E);
            end




            topNetwork=pir.getTopNetwork;
            InputImgSize='';
            fpgaParamLayers={};
            layerNum=0;
            n=size(topNetwork.Components,1);


            WL=1;

            dataType=dnnfpga.compiler.processorKernelType(processor);

            if~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8')||strcmpi(dataType.dataTypeFC,'int8'))
                WL=8;
                [mapObjInputExp,mapObjOutputExp]=dnnfpga.compiler.mapLayerExponents(pvpairs.exponentdata,net);
            end

            bConvPresent=false;
            for i=1:n
                layer=net.Layers(i);
                keyLayerName=erase(layer.Name,'_insertZeros');
                comp=topNetwork.Components(i);




                switch class(layer)
                case 'nnet.cnn.layer.ImageInputLayer'
                    InputImgSize=layer.InputSize;
                    param=struct;
                    param.type='SW_SeriesNetwork';
                    param.internal_type='SW_SeriesNetwork_Input';
                    param.phase=layer.Name;
                    param.WL=WL;
                    param.frontendLayers={layer.Name};
                    param.snLayer=net.Layers(i);
                    if~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8')||strcmpi(dataType.dataTypeFC,'int8'))
                        param.ExpData=mapObjInputExp(keyLayerName);
                        param.OutputExpData=mapObjOutputExp(keyLayerName);
                    else
                        param.ExpData=0;
                        param.OutputExpData=0;
                    end
                    param.inputFeatureNum=InputImgSize(3);
                    param.origImgSize=[InputImgSize(1);InputImgSize(2);1];
                    param.hasTrueOutputLayer=hasTrueOutputLayer;
                    param.hasTrueInputLayer=hasTrueInputLayer;
                    fpgaParamLayers{end+1}=param;%#ok<*AGROW>



                    if~pvpairs.leglevel&&~isSimulator
                        msg=message('dnnfpga:dnnfpgadisp:SoftwareLayerNotice',layer.Name,class(layer));
                        dnnfpga.disp(msg,1,pvpairs.verbose);
                    end

                case{'nnet.cnn.layer.Convolution2DLayer','nnet.cnn.layer.GroupedConvolution2DLayer'}


                    if(isprop(layer,'PaddingValue'))


                        if(layer.PaddingValue~=0)
                            error(message('dnnfpga:dnnfpgacompiler:UnsupportedParameter',layer.Name,'PaddingValue'));
                        end
                    end
                    layerNum=layerNum+1;
                    bConvPresent=true;
                    param=struct;



                    isLayerUnpool=hasUnpool&&i==2&&...
                    isa(layer,'nnet.cnn.layer.Convolution2DLayer');



                    isLayerTransposedConv=hasTransposedConv&&i==2&&...
                    isa(layer,'nnet.cnn.layer.Convolution2DLayer');
                    if isLayerUnpool==1
                        param.type='FPGA_Unpool2D';
                        param.unpoolRemainder=unpoolRemainder;
                    elseif isLayerTransposedConv
                        param.type='FPGA_TransposedConv';
                        weightSize=size(layer.Weights);




















                        param.unpoolRemainder=[1-weightSize(1);1-weightSize(2)];
                    else
                        param.type='FPGA_Conv2D';
                        param.unpoolRemainder=[0;0];
                    end
                    param.phase=layer.Name;
                    param.frontendLayers={layer.Name};
                    param.WL=WL;
                    param.correspondingAlexnetLayer=i;
                    param.reLUScaleExp=0;
                    param.rescaleExp=0;
                    param.reLUValue=0;
                    param.avgMultiplier=1;
                    if~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8'))

                        layerWeightExp=strcat(layer.Name,'_Weights');
                        layerBiasExp=strcat(layer.Name,'_Bias');
                        layerInputExp=strcat(layer.Name);
                        if(hasTransposedConv)
                            param.ExpWeights=0;
                            param.ExpBias=0;
                        else
                            if(~any(strcmpi(keys(mapObjInputExp),layerWeightExp)))
                                exp=dlquantization.BlockFloatingPoint((layer.Weights(:)),8);
                                param.ExpWeights=exp.getExponent;
                                exp=dlquantization.BlockFloatingPoint((layer.Bias(:)),32);
                                param.ExpBias=exp.getExponent;
                            else
                                param.ExpWeights=mapObjInputExp(layerWeightExp);
                                param.ExpBias=mapObjInputExp(layerBiasExp);
                            end
                        end
                        prevLayer=strcat(net.Layers(i-1).Name);


                        param.ExpData=mapObjOutputExp(prevLayer);
                        param.OutputExpData=mapObjOutputExp(keyLayerName);

                        if(isequal(class(layer),'nnet.cnn.layer.Convolution2DLayer'))
                            param.weights=dnnfpga.processorbase.processorUtils.singleToInt8Conversion(param,layer.Weights,param.ExpWeights);
                        else


                            if((layer.NumFiltersPerGroup==1)&&(layer.NumChannelsPerGroup==1))
                                [param.weights,param.ExpWeights]=dnnfpga.processorbase.processorUtils.singleToInt8ConversionCW(param,layer.Weights,8);
                            else
                                param.weights=dnnfpga.processorbase.processorUtils.singleToInt8Conversion(param,layer.Weights,param.ExpWeights);
                            end
                        end

                        param.rescaleExp=param.ExpData+param.ExpWeights;



                        if(isequal(class(layer),'nnet.cnn.layer.Convolution2DLayer'))
                            bfpData=dlquantization.BlockFloatingPoint((layer.Bias(:)),32);
                            param.ExpBias=double(bfpData.getExponent);
                            unadjustedbias=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(layer.Bias,param.ExpBias);
                            param.bias=int32(single(unadjustedbias)*2^single(param.ExpBias-param.rescaleExp));
                        else
                            if((layer.NumFiltersPerGroup==1)&&(layer.NumChannelsPerGroup==1))
                                [unadjustedbias,param.ExpBias]=dnnfpga.processorbase.processorUtils.singleToInt8ConversionCW(param,layer.Bias,32);

                                param.bias=unadjustedbias;
                                [numChannels,numGroups]=dnnfpga.processorbase.processorUtils.getNumChannels(unadjustedbias);
                                for grp=0:numGroups-1
                                    for idx=1:numChannels
                                        input=dnnfpga.processorbase.processorUtils.getInput(unadjustedbias,idx,grp);
                                        output=int32(single(input)*2^single(param.ExpBias(grp*numChannels+idx)-param.rescaleExp(grp*numChannels+idx)));
                                        param.bias=dnnfpga.processorbase.processorUtils.writeOutput(param.bias,idx,grp,output);
                                    end
                                end
                            else
                                bfpData=dlquantization.BlockFloatingPoint((layer.Bias(:)),32);
                                param.ExpBias=double(bfpData.getExponent);
                                unadjustedbias=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(layer.Bias,param.ExpBias);
                                param.bias=int32(single(unadjustedbias)*2^single(param.ExpBias-param.rescaleExp));
                            end
                        end

                        if(isequal(class(layer),'nnet.cnn.layer.GroupedConvolution2DLayer'))
                            if((layer.NumFiltersPerGroup==1)&&(layer.NumChannelsPerGroup==1))
                                param.type='FPGA_ConvND';

                                filterSizeLimit=dnnfpga.compiler.processorPoolSizeLimit(processor);


                                if(any(layer.FilterSize<=2)||any(layer.FilterSize>filterSizeLimit))
                                    msg=message('dnnfpga:dnnfpgacompiler:UnsupportedFilterSize',param.phase,3,filterSizeLimit);
                                    error(msg);
                                end
                            end
                            [h,w,c,f,g]=size(param.weights);
                            param.weights=reshape(param.weights,[h,w,c,f*g]);
                            [h,w,c,g]=size(param.bias);
                            param.bias=reshape(param.bias,[h,w,c*g]);
                        end
                    else

                        param.weights=layer.Weights;
                        param.bias=layer.Bias;
                        if(isequal(class(layer),'nnet.cnn.layer.GroupedConvolution2DLayer'))
                            if((layer.NumFiltersPerGroup==1)&&(layer.NumChannelsPerGroup==1))
                                param.type='FPGA_ConvND';

                                filterSizeLimit=dnnfpga.compiler.processorPoolSizeLimit(processor);


                                if((layer.FilterSize<=2)|(layer.FilterSize>filterSizeLimit))%#ok<OR2> 
                                    msg=message('dnnfpga:dnnfpgacompiler:UnsupportedFilterSize',param.phase,3,filterSizeLimit);
                                    error(msg);
                                end
                            end
                            [h,w,c,f,g]=size(layer.Weights);
                            param.weights=reshape(layer.Weights,[h,w,c,f*g]);
                            [h,w,c,g]=size(layer.Bias);
                            param.bias=reshape(layer.Bias,[h,w,c*g]);

                        end

                        param.ExpWeights=0;
                        param.ExpBias=0;
                        param.ExpData=0;
                        param.OutputExpData=0;
                    end

                    if(comp.getNumGroups>1)
                        param.convSplitMode=comp.getNumGroups;
                    else
                        param.convSplitMode=0;
                    end

                    if(~strcmpi(param.type,'FPGA_ConvND')&&(param.convSplitMode>2))
                        error(message('dnnfpga:workflow:GroupedConvNumberOfGroupsNotSupported',param.phase));
                    end
                    param.strideMode=comp.getStrideW();

                    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSymmetricStride(comp.getStrideH(),comp.getStrideW(),layer.Name);
                    param.stridePhase=[0;0];
                    param.reLUMode=0;
                    strideLimit=dnnfpga.compiler.processorStrideLimit(processor);
                    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSupportedStride(comp.getStrideH(),layer.Name,strideLimit-1);
                    if isLayerUnpool||isLayerTransposedConv
                        param.paddingMode=[0;0;0;0];
                    else
                        param.paddingMode=[comp.getPaddingH_Top();comp.getPaddingH_Bottom();comp.getPaddingW_Left();comp.getPaddingW_Right()];
                    end
                    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForPaddingSize(param.paddingMode,layer.Name,8);
                    param.dilationMode=[comp.getDilationFactorH,comp.getDilationFactorW];
                    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForDilationFactor(param.dilationMode,layer.Name);
                    param.lrnLocalSize=5;
                    param.lrnAlpha=0.0001/param.lrnLocalSize;
                    param.lrnBeta=0.75;
                    param.lrnK=1;
                    param.lrnFeaturePadding=fix(param.lrnLocalSize/2);
                    if(isa(net.Layers(i-1),'nnet.cnn.layer.ImageInputLayer'))
                        param.inputFeatureNum=InputImgSize(3);
                        param.origImgSize=[InputImgSize(1);InputImgSize(2);1];
                    else
                        previousLayerParam=fpgaParamLayers{end};
                        inputSize=dnnfpga.compiler.propagateConvLayerOutputSize(previousLayerParam);
                        param.inputFeatureNum=previousLayerParam.outputFeatureNum;
                        param.origImgSize=[inputSize(1);inputSize(2);1];
                    end
                    param.firstWritePos=[];
                    param.finalWriteSize=[];

                    param.outputFeatureNum=size(param.weights,4);
                    param.origOpSizeValue=[size(param.weights,1);size(param.weights,2);1];










                    filterSizeLimit=dnnfpga.compiler.processorPoolSizeLimit(processor);
                    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForFilterSize(param.origOpSizeValue,layer.Name,1,filterSizeLimit);
                    param.smallLayerEn=0;
                    param.maxpoolType=0;

                    if isfield(processor.getBCC,'convp')
                        featureSizeLimit=max(processor.getBCC.convp.conv.featureSizeLimit);
                    else
                        featureSizeLimit=max(processor.getBCC.conv.featureSizeLimit);
                    end

                    if(param.inputFeatureNum>featureSizeLimit)
                        msg=message('dnnfpga:dnnfpgacompiler:InputFeaturesExceedLimit');
                        error(msg);
                    elseif(param.outputFeatureNum>featureSizeLimit)
                        msg=message('dnnfpga:dnnfpgacompiler:OutputFeaturesExceedLimit');
                        error(msg);
                    end

                    fpgaParamLayers{end+1}=param;
                case 'nnet.cnn.layer.ReLULayer'
                    previousLayerParam=fpgaParamLayers{end};
                    previousLayerParam.reLUScaleExp=0;
                    previousLayerParam.reLUValue=0;

                    if(isfield(previousLayerParam,'reLUMode'))
                        if(any(strcmpi(previousLayerParam.type,{'FPGA_Maxpool2D','FPGA_Avgpool2D','FPGA_GAP2D'}))||...
                            previousLayerParam.reLUMode~=0)
                            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedReLUSequence','ReLULayer',previousLayerParam.frontendLayers{end});
                            error(msg);
                        end
                        previousLayerParam.reLUMode=1;
                        if~isEstimator&&(WL==8)
                            previousLayerParam.OutputExpData=mapObjOutputExp(layer.Name);
                        end
                        previousLayerParam.frontendLayers(end+1)={layer.Name};
                        fpgaParamLayers{end}=previousLayerParam;
                    else
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedReLUSequence','ReLULayer',previousLayerParam.phase);
                        error(msg);
                    end
                case 'nnet.cnn.layer.LeakyReLULayer'
                    previousLayerParam=fpgaParamLayers{end};
                    if(isfield(previousLayerParam,'reLUMode'))
                        if(any(strcmpi(previousLayerParam.type,{'FPGA_Maxpool2D','FPGA_Avgpool2D','FPGA_GAP2D'}))||...
                            previousLayerParam.reLUMode~=0)
                            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedReLUSequence','LeakyReLULayer',previousLayerParam.frontendLayers{end});
                            error(msg);
                        end
                        previousLayerParam.reLUMode=2;
                        if~isEstimator&&(WL==8)
                            ExpScale=strcat(layer.Name,'_Parameter');
                            previousLayerParam.reLUScaleExp=mapObjInputExp(ExpScale);
                            if(any(strcmpi(previousLayerParam.type,{'FPGA_FC'})))
                                quantScale=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(layer.Scale,previousLayerParam.reLUScaleExp);
                                previousLayerParam.reLUValue=quantScale;
                                previousLayerParam.OutputExpData=mapObjOutputExp(layer.Name);
                            else


                                previousLayerParam.reLUValue=layer.Scale;
                                previousLayerParam.OutputExpData=mapObjOutputExp(layer.Name);
                            end
                        else
                            previousLayerParam.reLUValue=layer.Scale;
                        end
                        previousLayerParam.frontendLayers(end+1)={layer.Name};
                        fpgaParamLayers{end}=previousLayerParam;
                    else
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedReLUSequence','LeakyReLULayer',previousLayerParam.phase);
                        error(msg);
                    end
                case 'nnet.cnn.layer.ClippedReLULayer'
                    previousLayerParam=fpgaParamLayers{end};

                    if(isfield(previousLayerParam,'reLUMode'))
                        if(any(strcmpi(previousLayerParam.type,{'FPGA_Maxpool2D','FPGA_Avgpool2D','FPGA_GAP2D'}))||...
                            previousLayerParam.reLUMode~=0)
                            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedReLUSequence','clippedReluLayer',previousLayerParam.frontendLayers{end});
                            error(msg);
                        end
                        previousLayerParam.reLUMode=3;
                        if~isEstimator&&(WL==8)
                            if(any(strcmpi(previousLayerParam.type,{'FPGA_FC'})))
                                reLUScaleExp=previousLayerParam.rescaleExp;
                                quantScale=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(layer.Ceiling,reLUScaleExp);
                                previousLayerParam.reLUValue=quantScale;
                                previousLayerParam.OutputExpData=mapObjOutputExp(layer.Name);

                            else
                                previousLayerParam.reLUValue=layer.Ceiling;
                                previousLayerParam.OutputExpData=mapObjOutputExp(layer.Name);








                                previousLayerParam.reLUScaleExp=mapObjOutputExp(layer.Name);
                            end
                        else
                            previousLayerParam.reLUValue=layer.Ceiling;
                            previousLayerParam.reLUScaleExp=0;
                            previousLayerParam.OutputExpData=0;
                        end
                        previousLayerParam.frontendLayers(end+1)={layer.Name};
                        fpgaParamLayers{end}=previousLayerParam;
                    else
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedReLUSequence','clippedReluLayer',previousLayerParam.phase);
                        error(msg);
                    end
                case{'nnet.cnn.layer.MaxPooling2DLayer','nnet.cnn.layer.AveragePooling2DLayer'}
                    param=struct;
                    param.phase=layer.Name;
                    param.frontendLayers={layer.Name};
                    param.convSplitMode=0;
                    strideLimit=dnnfpga.compiler.processorStrideLimit(processor);
                    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSupportedStride(comp.getStrideH(),layer.Name,strideLimit-1);
                    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSymmetricStride(comp.getStrideH(),comp.getStrideW(),layer.Name);
                    param.strideMode=comp.getStrideW();
                    param.stridePhase=[0;0];






                    param.paddingMode=double([comp.getPaddingH_Top();comp.getPaddingH_Bottom();comp.getPaddingW_Left();comp.getPaddingW_Right()]);
                    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForPaddingSize(param.paddingMode,layer.Name,2);

                    param.reLUValue=0;
                    param.rescaleExp=0;
                    param.reLUScaleExp=0;
                    param.dilationMode=1;

                    param.lrnLocalSize=5;
                    param.lrnAlpha=0.0001/param.lrnLocalSize;
                    param.lrnBeta=0.75;
                    param.lrnK=1;
                    param.lrnFeaturePadding=fix(param.lrnLocalSize/2);
                    param.maxpoolType=maxpoolType;
                    param.unpoolRemainder=[0;0];
                    previousLayerParam=fpgaParamLayers{end};
                    existedOtherLayers=dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkNetworkExistsOtherLayers(net,layer);
                    if(~existedOtherLayers)
                        if(previousLayerParam.hasTrueInputLayer)


                            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedNoConv');
                            error(msg);
                        else
                            inputSize=previousLayerParam.snLayer.InputSize;
                            param.inputFeatureNum=inputSize(3);
                            param.outputFeatureNum=inputSize(3);
                        end
                    else
                        if(isa(net.Layers(i-1),'nnet.cnn.layer.ImageInputLayer'))

                            inputSize=previousLayerParam.origImgSize;
                            param.inputFeatureNum=InputImgSize(3);
                            param.outputFeatureNum=InputImgSize(3);
                        else
                            inputSize=dnnfpga.compiler.propagateConvLayerOutputSize(previousLayerParam);
                            param.inputFeatureNum=previousLayerParam.outputFeatureNum;
                            param.outputFeatureNum=previousLayerParam.outputFeatureNum;
                        end
                    end

                    if isfield(processor.getBCC,'convp')
                        featureSizeLimit=max(processor.getBCC.convp.conv.featureSizeLimit);
                    else
                        featureSizeLimit=max(processor.getBCC.conv.featureSizeLimit);
                    end

                    if(param.inputFeatureNum>featureSizeLimit)
                        msg=message('dnnfpga:dnnfpgacompiler:InputFeaturesExceedLimit');
                        error(msg);
                    elseif(param.outputFeatureNum>featureSizeLimit)
                        msg=message('dnnfpga:dnnfpgacompiler:OutputFeaturesExceedLimit');
                        error(msg);
                    end

                    param.origImgSize=[inputSize(1);inputSize(2);1];
                    param.origOpSizeValue=[comp.getPoolSizeH();comp.getPoolSizeW();1];

                    filterSizeLimit=dnnfpga.compiler.processorPoolSizeLimit(processor);
                    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForFilterSize(param.origOpSizeValue,layer.Name,1,filterSizeLimit);
                    param.firstWritePos=[];
                    param.finalWriteSize=[];
                    param.correspondingAlexnetLayer=i;
                    avgMultiplier=1/(param.origOpSizeValue(1)*param.origOpSizeValue(2));
                    if~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8'))
                        prevLayer=strcat(net.Layers(i-1).Name);
                        param.ExpData=mapObjOutputExp(prevLayer);


                        param.rescaleExp=mapObjOutputExp(prevLayer);
                        param.OutputExpData=mapObjOutputExp(layer.Name);
                        if(strcmpi(class(layer),'nnet.cnn.layer.AveragePooling2DLayer'))
                            multiplierExponentName=strcat(layer.Name,'_Parameter');
                            avgmultiplierExponent=mapObjInputExp(multiplierExponentName);



                            param.avgMultiplier=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(avgMultiplier,avgmultiplierExponent);



                            param.rescaleExp=param.rescaleExp+avgmultiplierExponent;
                        else
                            param.avgMultiplier=1;
                        end
                    else
                        param.avgMultiplier=avgMultiplier;
                        param.ExpData=0;
                        param.rescaleExp=0;
                        param.OutputExpData=0;
                    end
                    param.WL=WL;
                    if(strcmpi(class(layer),'nnet.cnn.layer.AveragePooling2DLayer'))
                        param.type='FPGA_Avgpool2D';
                    else
                        param.type='FPGA_Maxpool2D';
                    end

                    outImageSize1=dnnfpga.compiler.propagateConvLayerOutputSize(param);

                    if isfield(processor.getBCC,'convp')
                        threadNumber=processor.getBCC.convp.conv.threadNumLimit;
                    else
                        threadNumber=processor.getBCC.conv.threadNumLimit;
                    end
                    outImageSize1=[outImageSize1(1),outImageSize1(2),ceil(param.outputFeatureNum/threadNumber)];











                    if(prod(outImageSize1)<26)

                        param.smallLayerEn=1;
                    else
                        param.smallLayerEn=0;
                    end

                    fpgaParamLayers{end+1}=param;
                case 'nnet.cnn.layer.FullyConnectedLayer'
                    layerNum=layerNum+1;
                    param=struct;
                    param.type='FPGA_FC';
                    param.matrixSize=[layer.InputSize,layer.OutputSize];
                    param.featureSize=0;
                    param.gapMultiplier=1;
                    param.reLUMode=0;
                    param.reLUValue=0;
                    param.reLUScaleExp=0;
                    param.rescaleExp=0;
                    param.phase=layer.Name;
                    param.frontendLayers={layer.Name};
                    param.correspondingAlexnetLayer=i;







                    param.fcOutputExp=0;
                    param.fcInputExp=0;
                    assert(~isempty(layer.Weights)&&~isempty(layer.Bias),'Input SeriesNetwork layer %d doesn''t have weights or bias.',i);

                    if~isEstimator&&(strcmpi(dataType.dataTypeFC,'int8'))
                        layerWeightExp=strcat(layer.Name,'_Weights');
                        layerBiasExp=strcat(layer.Name,'_Bias');
                        layerInputExp=strcat(layer.Name);

                        param.ExpWeights=mapObjInputExp(layerWeightExp);
                        param.ExpBias=mapObjInputExp(layerBiasExp);
                        prevLayer=strcat(net.Layers(i-1).Name);
                        param.ExpData=mapObjOutputExp(prevLayer);

                        param.OutputExpData=mapObjOutputExp(layer.Name);
                        param.rescaleExp=param.ExpData+param.ExpWeights;
                        Weights=dnnfpga.processorbase.processorUtils.singleToInt8Conversion(param,layer.Weights,param.ExpWeights);

                        unadjustedbias=dnnfpga.processorbase.processorUtils.singleToInt8Conversion(param,layer.Bias,param.ExpBias);

                        Bias=int8(single(unadjustedbias)*2^single(param.ExpBias-param.ExpWeights));
                    elseif~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8')&&strcmpi(dataType.dataTypeFC,'single'))
                        Weights=layer.Weights;
                        Bias=layer.Bias;
                        layerInputExp=strcat(layer.Name);
                        prevLayer=strcat(net.Layers(i-1).Name);
                        param.ExpData=mapObjOutputExp(prevLayer);

                        param.OutputExpData=mapObjOutputExp(layer.Name);
                        WL=1;
                    else
                        Weights=layer.Weights;
                        Bias=layer.Bias;
                        WL=1;
                        param.ExpWeights=0;
                        param.ExpBias=0;
                        param.ExpData=0;
                        param.OutputExpData=0;
                    end
                    [importedOp,importedBias]=dnnfpga.processorbase.fcProcessor.importOperator(Weights,Bias);
                    param.weights=importedOp';
                    param.bias=importedBias;
                    param.WL=WL;
                    param.numberOfPaddedZeros=0;
                    param.denominatorAddressSizeMinusOne=0;
                    param.iterCounterWLimit=processor.getCC.fcp.iterCounterWLimit;
                    fpgaParamLayers{end+1}=param;

                case 'nnet.cnn.layer.GlobalAveragePooling2DLayer'
                    param=struct;
                    param.reLUScaleExp=0;
                    param.rescaleExp=0;
                    param.reLUValue=0;
                    layerNum=layerNum+1;
                    previousLayerParam=fpgaParamLayers{end};
                    if(isa(net.Layers(i-1),'nnet.cnn.layer.ImageInputLayer'))
                        if(previousLayerParam.hasTrueInputLayer)


                            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedNoConv');
                            error(msg);
                        else


                            param.origOpSizeValue=([InputImgSize(1),InputImgSize(2),1]);
                            featureSize=InputImgSize(1)*InputImgSize(2);
                            outputFeatures=InputImgSize(3);
                        end
                    elseif(isa(net.Layers(i-1),'nnet.cnn.layer.FullyConnectedLayer'))
                        previousLayerParam=fpgaParamLayers{end};
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',num2str(i),previousLayerParam.phase,layer.Name);
                        error(msg);
                    elseif(isa(net.Layers(i-1),'nnet.cnn.layer.GlobalAveragePooling2DLayer'))
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',num2str(i),previousLayerParam.phase,layer.Name);
                        error(msg);
                    else
                        inputSize=dnnfpga.compiler.propagateConvLayerOutputSize(previousLayerParam);
                        featureSize=inputSize(1)*inputSize(2);
                        outputFeatures=previousLayerParam.outputFeatureNum;
                    end
                    implementGAPInConv=true;
                    if(strcmpi(class(processor),'dnnfpga.processorbase.fc4Processor')||...
                        strcmpi(class(processor),'dnnfpga.processorbase.cnn4Processor')||...
                        strcmpi(class(processor),'dnnfpga.processorbase.cnn5Processor')||...
                        strcmpi(class(processor),'dnnfpga.processorbase.fc5Processor'))
                        resultMemDepthLimit=processor.getCC.fcp.resultMemDepthLimit;
                    else


                        resultMemDepthLimit=0;
                    end
                    fcThreadNum=dnnfpga.compiler.processorThreadNum(processor);
                    if(strcmpi(class(processor),'dnnfpga.processorbase.cnn4Processor')||...
                        strcmpi(class(processor),'dnnfpga.processorbase.cnn5Processor'))
                        bcc=processor.getBCC();
                        convThreadNum=bcc.convp.conv.threadNumLimit;





                        resultAddrLength=featureSize*ceil(outputFeatures/convThreadNum);
                    else
                        resultAddrLength=1;
                    end




                    if((featureSize*ceil(outputFeatures/fcThreadNum)*fcThreadNum<1024)&&...
                        (resultAddrLength<resultMemDepthLimit*fcThreadNum))
                        implementGAPInConv=false;
                    end


                    implementGAPInConv=true;
                    if(implementGAPInConv)

                        param.type='FPGA_Avgpool2D';
                        param.phase=layer.Name;
                        param.frontendLayers={layer.Name};
                        param.convSplitMode=0;
                        strideLimit=dnnfpga.compiler.processorStrideLimit(processor);
                        dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSupportedStride(comp.getStrideH(),layer.Name,strideLimit-1);
                        dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSymmetricStride(comp.getStrideH(),comp.getStrideW(),layer.Name);


                        param.strideMode=double(comp.getStrideW());
                        param.stridePhase=[0;0];
                        param.paddingMode=double([comp.getPaddingH_Top();comp.getPaddingH_Bottom();comp.getPaddingW_Left();comp.getPaddingW_Right()]);
                        dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForPaddingSize(param.paddingMode,layer.Name,2);
                        param.dilationMode=1;
                        param.lrnLocalSize=5;
                        param.lrnAlpha=0.0001/param.lrnLocalSize;
                        param.lrnBeta=0.75;


                        param.lrnK=10;
                        param.lrnFeaturePadding=fix(param.lrnLocalSize/2);
                        if(isa(net.Layers(i-1),'nnet.cnn.layer.ImageInputLayer'))
                            inputSize=InputImgSize;
                            param.inputFeatureNum=InputImgSize(3);
                            param.outputFeatureNum=InputImgSize(3);
                        else
                            inputSize=dnnfpga.compiler.propagateConvLayerOutputSize(previousLayerParam);
                            param.inputFeatureNum=previousLayerParam.outputFeatureNum;
                            param.outputFeatureNum=previousLayerParam.outputFeatureNum;
                        end
                        param.origImgSize=[inputSize(1);inputSize(2);1];


                        param.origOpSizeValue=[inputSize(1);inputSize(2);1];

                        filterSizeLimit=dnnfpga.compiler.processorPoolSizeLimit(processor);
                        dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForFilterSize(param.origOpSizeValue,layer.Name,1,filterSizeLimit);
                        param.firstWritePos=[];
                        param.finalWriteSize=[];
                        param.correspondingAlexnetLayer=i;
                        dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForMaxSupportedFeatures(param.origOpSizeValue,param.inputFeatureNum,layer.Name,processor);
                        gapMultiplier=1/(param.origOpSizeValue(1)*param.origOpSizeValue(2));
                        if~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8'))
                            prevLayer=strcat(net.Layers(i-1).Name);
                            param.ExpData=mapObjOutputExp(prevLayer);

                            param.OutputExpData=mapObjOutputExp(layer.Name);
                            gapMultiplierExponentName=strcat(layer.Name,'_Parameter');
                            gapMultiplierExponent=mapObjInputExp(gapMultiplierExponentName);


                            param.avgMultiplier=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(gapMultiplier,gapMultiplierExponent);
                            param.rescaleExp=mapObjInputExp(strcat(layer.Name))+gapMultiplierExponent;
                        else
                            param.avgMultiplier=gapMultiplier;
                            param.ExpData=0;
                            param.OutputExpData=0;
                        end
                        param.WL=WL;

                        if isfield(processor.getBCC,'convp')
                            threadNumber=processor.getBCC.convp.conv.threadNumLimit;
                        else
                            threadNumber=processor.getBCC.conv.threadNumLimit;
                        end
                        outImageSize1=ceil(param.outputFeatureNum/threadNumber);











                        if(prod(outImageSize1)<19)

                            param.smallLayerEn=1;
                        else
                            param.smallLayerEn=0;
                        end
                        param.maxpoolType=0;
                        param.unpoolRemainder=[0;0];
                        fpgaParamLayers{end+1}=param;
                    else

                        param=struct;
                        param.type='FPGA_GAP2D';
                        fcthreadNum=dnnfpga.compiler.processorThreadNum(processor);




                        if(strcmpi(class(processor),'dnnfpga.processorbase.cnn4Processor')||...
                            strcmpi(class(processor),'dnnfpga.processorbase.cnn5Processor'))
                            bcc=processor.getBCC();
                            convThreadNum=bcc.convp.conv.threadNumLimit;
                            if(convThreadNum<fcthreadNum)
                                mulFactor=ceil(fcthreadNum/convThreadNum);
                            else
                                mulFactor=1;
                            end
                        else
                            mulFactor=1;
                        end
                        if(isa(net.Layers(i-1),'nnet.cnn.layer.ImageInputLayer'))

                            param.featureSize=InputImgSize(1)*InputImgSize(2);
                            param.inputFeatureNum=InputImgSize(3);
                            param.outputFeatureNum=InputImgSize(3);




                            if(convThreadNum)
                                param.matrixSize(1)=param.featureSize*ceil(param.outputFeatureNum/convThreadNum)*convThreadNum;
                            else
                                param.matrixSize(1)=ceil(param.outputFeatureNum/fcthreadNum)*param.featureSize*fcthreadNum;
                            end
                            param.matrixSize(2)=InputImgSize(3)*mulFactor;
                        elseif(isa(net.Layers(i-1),'nnet.cnn.layer.FullyConnectedLayer'))
                            previousLayerParam=fpgaParamLayers{end};
                            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',num2str(i),previousLayerParam.phase,layer.Name);
                            error(msg);
                        elseif(isa(net.Layers(i-1),'nnet.cnn.layer.GlobalAveragePooling2DLayer'))
                            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',num2str(i),previousLayerParam.phase,layer.Name);
                            error(msg);
                        else




                            inputSize=dnnfpga.compiler.propagateConvLayerOutputSize(previousLayerParam);
                            param.inputFeatureNum=previousLayerParam.outputFeatureNum;
                            param.outputFeatureNum=previousLayerParam.outputFeatureNum;
                            param.featureSize=inputSize(1)*inputSize(2);
                            if(strcmpi(class(processor),'dnnfpga.processorbase.cnn4Processor')||...
                                strcmpi(class(processor),'dnnfpga.processorbase.cnn5Processor'))
                                bcc=processor.getBCC();
                                convThreadNum=bcc.convp.conv.threadNumLimit;



                                param.matrixSize(1)=param.featureSize*ceil(param.outputFeatureNum/convThreadNum)*convThreadNum;
                            else
                                param.matrixSize(1)=ceil(param.outputFeatureNum/fcthreadNum)*param.featureSize*fcthreadNum;
                            end
                            param.matrixSize(2)=param.outputFeatureNum*mulFactor;

                        end
                        gapMultiplier=1/param.featureSize;
                        param.phase=layer.Name;
                        if~isEstimator&&(strcmpi(dataType.dataTypeFC,'int8'))
                            layerInputExp=strcat(layer.Name);
                            param.ExpWeights=0;
                            param.ExpBias=0;
                            prevLayer=strcat(net.Layers(i-1).Name);
                            param.ExpData=mapObjOutputExp(prevLayer);

                            param.OutputExpData=mapObjOutputExp(layer.Name);
                            gapMultiplierExponentName=strcat(layer.Name,'_Parameter');
                            gapMultiplierExponent=mapObjInputExp(gapMultiplierExponentName);
                            param.gapMultiplier=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(gapMultiplier,gapMultiplierExponent);
                            param.rescaleExp=param.ExpData+gapMultiplierExponent;
                        elseif~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8')&&strcmpi(dataType.dataTypeFC,'single'))
                            layerInputExp=strcat(layer.Name);
                            prevLayer=strcat(net.Layers(i-1).Name);
                            param.ExpData=mapObjOutputExp(prevLayer);

                            param.OutputExpData=mapObjOutputExp(layer.Name);
                            param.gapMultiplier=gapMultiplier;
                        else
                            param.gapMultiplier=gapMultiplier;
                            param.OutputExpData=0;
                            param.ExpData=0;
                            param.ExpWeights=0;
                            param.ExpBias=0;
                        end
                        param.WL=WL;
                        param.frontendLayers={layer.Name};
                        param.correspondingAlexnetLayer=i;
                        param.fcOutputExp=0;
                        param.fcInputExp=0;
                        param.numberOfPaddedZeros=0;
                        param.denominatorAddressSizeMinusOne=0;
                        param.iterCounterWLimit=processor.getCC.fcp.iterCounterWLimit;
                        fpgaParamLayers{end+1}=param;
                    end
                case 'nnet.cnn.layer.SoftmaxLayer'
                    if(hasTrueOutputLayer)

                        param=struct;
                        param.type='SW_SeriesNetwork';
                        param.internal_type='';
                        param.phase=layer.Name;
                        param.frontendLayers={layer.Name};
                        param.snLayer=net.Layers(i);
                        param.WL=WL;
                        param.hasTrueOutputLayer=hasTrueOutputLayer;
                        param.hasTrueInputLayer=hasTrueInputLayer;
                        if~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8')||strcmpi(dataType.dataTypeFC,'int8'))
                            prevLayer=strcat(net.Layers(i-1).Name);
                            param.ExpData=mapObjOutputExp(prevLayer);
                        else
                            param.ExpData=0;
                        end
                        fpgaParamLayers{end+1}=param;

                        if~pvpairs.leglevel&&~isSimulator
                            msg=message('dnnfpga:dnnfpgadisp:SoftwareLayerNotice',layer.Name,class(layer));
                            dnnfpga.disp(msg,1,pvpairs.verbose);
                        end
                    else
                        param=struct;

                        if(isa(net.Layers(i-1),'nnet.cnn.layer.ImageInputLayer'))

                            param.matrixSize=[prod(InputImgSize),prod(InputImgSize)];
                        elseif(isa(net.Layers(i-1),'nnet.cnn.layer.FullyConnectedLayer'))
                            previousLayerParam=fpgaParamLayers{end};
                            param.matrixSize=[prod(previousLayerParam.outputSize),prod(previousLayerParam.outputSize)];
                        elseif(isa(net.Layers(i-1),'nnet.cnn.layer.GlobalAveragePooling2DLayer'))
                            previousLayerParam=fpgaParamLayers{end};
                            param.matrixSize=[previousLayerParam.outputFeatureNum,previousLayerParam.outputFeatureNum];
                        else
                            previousLayerParam=fpgaParamLayers{end};
                            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',num2str(i),previousLayerParam.phase,layer.Name);
                            error(msg);
                        end
                        layerNum=layerNum+1;
                        param.type='FPGA_Softmax';
                        previousLayerParam=fpgaParamLayers{end};
                        param.featureSize=0;
                        param.gapMultiplier=1;
                        param.reLUMode=0;
                        param.reLUValue=0;
                        param.reLUScaleExp=0;
                        param.rescaleExp=0;
                        param.phase=layer.Name;
                        param.frontendLayers={layer.Name};
                        param.correspondingAlexnetLayer=i;

                        fcthreadNum=dnnfpga.compiler.processorThreadNum(processor);
                        param.numberOfPaddedZeros=fcthreadNum-mod(param.matrixSize(1),fcthreadNum);
                        param.denominatorAddressSizeMinusOne=floor(param.matrixSize(1)/fcthreadNum);
                        param.iterCounterWLimit=processor.getCC.fcp.iterCounterWLimit;
                        param.fcInputExp=0;
                        param.fcOutputExp=0;
                        if~isEstimator&&(strcmpi(dataType.dataTypeFC,'int8'))
                            layerInputExp=strcat(layer.Name);
                            param.ExpWeights=0;
                            param.ExpBias=0;
                            prevLayer=strcat(net.Layers(i-1).Name);
                            param.ExpData=mapObjOutputExp(prevLayer);
                            param.OutputExpData=mapObjOutputExp(layer.Name);
                            param.rescaleExp=param.ExpData;



                            param.fcInputExp=param.ExpData;
                            param.fcOutputExp=param.OutputExpData;
                        elseif~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8')&&strcmpi(dataType.dataTypeFC,'single'))
                            layerInputExp=strcat(layer.Name);
                            prevLayer=strcat(net.Layers(i-1).Name);
                            param.ExpData=mapObjOutputExp(prevLayer);
                            param.OutputExpData=mapObjOutputExp(layer.Name);
                            WL=1;
                        else
                            WL=1;
                            param.ExpWeights=0;
                            param.ExpBias=0;
                            param.ExpData=0;
                            param.OutputExpData=0;
                        end
                        param.WL=WL;
                        fpgaParamLayers{end+1}=param;
                    end
                case 'nnet.cnn.layer.SigmoidLayer'
                    if(hasTrueOutputLayer)

                        param=struct;
                        param.type='SW_SeriesNetwork';
                        param.internal_type='SW_Sigmoid';
                        param.phase=layer.Name;
                        param.frontendLayers={layer.Name};
                        param.snLayer=net.Layers(i);
                        param.WL=WL;
                        param.hasTrueOutputLayer=hasTrueOutputLayer;
                        param.hasTrueInputLayer=hasTrueInputLayer;
                        if~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8')||strcmpi(dataType.dataTypeFC,'int8'))
                            prevLayer=strcat(net.Layers(i-1).Name);
                            param.ExpData=mapObjOutputExp(prevLayer);
                        else
                            param.ExpData=0;
                        end
                        fpgaParamLayers{end+1}=param;

                        if~pvpairs.leglevel&&~isSimulator
                            msg=message('dnnfpga:dnnfpgadisp:SoftwareLayerNotice',layer.Name,class(layer));
                            dnnfpga.disp(msg,1,pvpairs.verbose);
                        end
                    else
                        param=struct;

                        if(isa(net.Layers(i-1),'nnet.cnn.layer.ImageInputLayer'))

                            param.matrixSize=[prod(InputImgSize),prod(InputImgSize)];
                        elseif(isa(net.Layers(i-1),'nnet.cnn.layer.FullyConnectedLayer'))
                            previousLayerParam=fpgaParamLayers{end};
                            param.matrixSize=[prod(previousLayerParam.outputSize),prod(previousLayerParam.outputSize)];
                        elseif(isa(net.Layers(i-1),'nnet.cnn.layer.GlobalAveragePooling2DLayer'))
                            previousLayerParam=fpgaParamLayers{end};
                            param.matrixSize=[previousLayerParam.outputFeatureNum,previousLayerParam.outputFeatureNum];
                        else
                            previousLayerParam=fpgaParamLayers{end};
                            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',num2str(i),previousLayerParam.phase,layer.Name);
                            error(msg);
                        end
                        layerNum=layerNum+1;
                        param.type='FPGA_Sigmoid';
                        previousLayerParam=fpgaParamLayers{end};
                        param.featureSize=0;
                        param.gapMultiplier=1;
                        param.reLUMode=0;
                        param.reLUValue=0;
                        param.reLUScaleExp=0;
                        param.rescaleExp=0;
                        param.phase=layer.Name;
                        param.frontendLayers={layer.Name};
                        param.correspondingAlexnetLayer=i;

                        fcthreadNum=dnnfpga.compiler.processorThreadNum(processor);
                        param.numberOfPaddedZeros=fcthreadNum-mod(param.matrixSize(1),fcthreadNum);
                        param.denominatorAddressSizeMinusOne=floor(param.matrixSize(1)/fcthreadNum);
                        param.iterCounterWLimit=processor.getCC.fcp.iterCounterWLimit;
                        param.fcInputExp=0;
                        param.fcOutputExp=0;
                        if~isEstimator&&(strcmpi(dataType.dataTypeFC,'int8'))
                            layerInputExp=strcat(layer.Name);
                            param.ExpWeights=0;
                            param.ExpBias=0;
                            prevLayer=strcat(net.Layers(i-1).Name);
                            param.ExpData=mapObjOutputExp(prevLayer);
                            param.OutputExpData=mapObjOutputExp(layer.Name);
                            param.rescaleExp=param.ExpData;



                            param.fcInputExp=param.ExpData;
                            param.fcOutputExp=param.OutputExpData;
                        elseif~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8')&&strcmpi(dataType.dataTypeFC,'single'))
                            layerInputExp=strcat(layer.Name);
                            prevLayer=strcat(net.Layers(i-1).Name);
                            param.ExpData=mapObjOutputExp(prevLayer);
                            param.OutputExpData=mapObjOutputExp(layer.Name);
                            WL=1;
                        else
                            WL=1;
                            param.ExpWeights=0;
                            param.ExpBias=0;
                            param.ExpData=0;
                            param.OutputExpData=0;
                        end
                        param.WL=WL;
                        fpgaParamLayers{end+1}=param;
                    end
                case 'dnnfpga.layer.ExponentialLayer'
                    if(hasTrueOutputLayer)

                        param=struct;
                        param.type='SW_SeriesNetwork';
                        param.internal_type='SW_Exponential';
                        param.phase=layer.Name;
                        param.frontendLayers={layer.Name};
                        param.snLayer=net.Layers(i);
                        param.WL=WL;
                        param.hasTrueOutputLayer=hasTrueOutputLayer;
                        param.hasTrueInputLayer=hasTrueInputLayer;
                        if~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8')||strcmpi(dataType.dataTypeFC,'int8'))
                            prevLayer=strcat(net.Layers(i-1).Name);
                            param.ExpData=mapObjOutputExp(prevLayer);
                        else
                            param.ExpData=0;
                        end
                        fpgaParamLayers{end+1}=param;

                        if~pvpairs.leglevel&&~isSimulator
                            msg=message('dnnfpga:dnnfpgadisp:SoftwareLayerNotice',layer.Name,class(layer));
                            dnnfpga.disp(msg,1,pvpairs.verbose);
                        end
                    end
                case{'nnet.cnn.layer.ClassificationOutputLayer',...
                    'nnet.cnn.layer.RegressionOutputLayer',...
                    'nnet.cnn.layer.YOLOv2TransformLayer',...
                    'nnet.cnn.layer.YOLOv2OutputLayer',...
                    'nnet.cnn.layer.PixelClassificationLayer'}
                    param=struct;
                    param.type='SW_SeriesNetwork';
                    param.internal_type='';
                    param.phase=layer.Name;
                    param.frontendLayers={layer.Name};
                    param.snLayer=net.Layers(i);
                    param.WL=WL;
                    param.hasTrueOutputLayer=hasTrueOutputLayer;
                    param.hasTrueInputLayer=hasTrueInputLayer;
                    if~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8')||strcmpi(dataType.dataTypeFC,'int8'))





                        if(isa(layer,'nnet.cnn.layer.ClassificationOutputLayer')||isa(layer,'nnet.cnn.layer.YOLOv2OutputLayer')||isa(layer,'nnet.cnn.layer.PixelClassificationLayer'))
                            param.ExpData=0;
                        else
                            prevLayer=strcat(net.Layers(i-1).Name);
                            if(contains(prevLayer,'_insertZeros'))
                                prevLayer=erase(prevLayer,'_insertZeros');
                            end
                            param.ExpData=mapObjOutputExp(prevLayer);
                        end
                    else
                        param.ExpData=0;
                    end
                    fpgaParamLayers{end+1}=param;

                    if~pvpairs.leglevel&&~isSimulator
                        msg=message('dnnfpga:dnnfpgadisp:SoftwareLayerNotice',layer.Name,class(layer));
                        dnnfpga.disp(msg,1,pvpairs.verbose);
                    end


                case 'nnet.cnn.layer.CrossChannelNormalizationLayer'
                    param=struct;
                    param.type='FPGA_Lrn2D';
                    param.phase=layer.Name;
                    param.frontendLayers={layer.Name};
                    param.convSplitMode=2;
                    param.strideMode=1;
                    param.stridePhase=[0;0];
                    param.paddingMode=[0;0;0;0];
                    param.dilationMode=1;
                    param.origOpSizeValue=[1;1;1];
                    param.rescaleExp=0;
                    param.reLUScaleExp=0;
                    param.reLUValue=0;
                    param.avgMultiplier=1;
                    previousLayerParam=fpgaParamLayers{end};

                    if strcmpi(previousLayerParam.type,'FPGA_FC')
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',num2str(i),previousLayerParam.phase,layer.Name);
                        error(msg);
                    end
                    inputSize=dnnfpga.compiler.propagateConvLayerOutputSize(previousLayerParam);
                    param.lrnLocalSize=layer.WindowChannelSize;
                    param.lrnAlpha=layer.Alpha/param.lrnLocalSize;
                    param.lrnBeta=layer.Beta;
                    param.lrnK=layer.K;
                    param.lrnFeaturePadding=fix(param.lrnLocalSize/2);
                    param.origImgSize=[inputSize(1);inputSize(2);1];
                    param.firstWritePos=[];
                    param.finalWriteSize=[];
                    param.inputFeatureNum=previousLayerParam.outputFeatureNum;
                    param.outputFeatureNum=previousLayerParam.outputFeatureNum;
                    param.correspondingAlexnetLayer=i;
                    param.WL=WL;
                    if~isEstimator&&(strcmpi(dataType.dataTypeConv,'int8'))
                        param.ExpData=mapObjInputExp(strcat(layer.Name));
                        param.OutputExpData=mapObjOutputExp(layer.Name);
                    else
                        param.ExpData=0;
                        param.OutputExpData=0;
                    end
                    param.smallLayerEn=0;
                    param.maxpoolType=0;
                    param.unpoolRemainder=[0;0];

                    fpgaParamLayers{end+1}=param;
                case 'nnet.cnn.layer.BatchNormalizationLayer'
                    msg=message('dnnfpga:dnnfpgacompiler:UnsupportedBatchSequence',class(layer),class(net.Layers(i-1)));
                    error(msg);
                otherwise
                    msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayer',class(layer));
                    error(msg);
                end
                if(isa(layer,'nnet.cnn.layer.Convolution2DLayer')&&(isLayerUnpool||isLayerTransposedConv))
                    fpgaParamLayers{end}.outputSize=[fpgaParamLayers{end}.origImgSize(1:2).*fpgaParamLayers{end}.origOpSizeValue(1:2)+fpgaParamLayers{end}.unpoolRemainder;fpgaParamLayers{end}.inputFeatureNum].';
                else
                    layers_analysis=nnet.internal.cnn.analyzer.NetworkAnalyzer(net.Layers);
                    fpgaParamLayers{end}.outputSize=layers_analysis.LayerAnalyzers(i).Outputs.Size{1};

                end
            end


            if~bConvPresent&&~isa(processor,'dnnfpga.processorbase.cnn5Processor')
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedNoConv');
                error(msg);
            end
        end
    end
    methods(Access=public,Static=true)


        function pvpairs=parse_params(params)

            pvpairs=struct();
            assert(mod(length(params),2)==0);

            validParams={'batchsize','targetdir','targetfile','targetarch',...
            'cudnnversion','opencv','codetarget','targetmain',...
            'codegenonly','computecapability','exponentdata','verbose',...
            'hastrueoutputlayer','hastrueinputlayer','leglevel',...
            'activationlayer','maxpooltype','hasunpool','hardwarenormalization',...
            'unpoolremainder','hastransposedconv','processorconfig','validatetrimmablekernel','processordatatype',...
            'issimulator','isestimator'};

            for i=1:2:length(params)
                param=lower(params{i});
                if(~contains(validParams,param))
                    error(message('gpucoder:cnncodegen:invalid_parameter'));
                end
                value=params{i+1};

                pvpairs.(param)=value;
            end
        end

        function checkForSymmetricStride(strideH,strideW,layerName)


            if strideW~=strideH
                msg=message('dnnfpga:dnnfpgacompiler:OnlySymmetricStrideSupported',layerName);
                error(msg);
            end
        end

        function checkForSupportedStride(strideH,layerName,supportedSize)


            if strideH==0||strideH>supportedSize
                validRange=strcat('1-',num2str(supportedSize));
                msg=message('dnnfpga:dnnfpgacompiler:OnlyKnownStrideSupported',layerName,validRange);
                error(msg);
            end
        end

        function checkForPaddingSize(padding,layerName,maxPaddingSize)
            if any(padding>maxPaddingSize)
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedPaddingSize',layerName,maxPaddingSize);
                error(msg);
            end
        end

        function checkForDilationFactor(dilation,layerName)
            if~all(dilation==1)
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedDilationFactor',layerName);
                error(msg);
            end
        end

        function checkForFilterSize(opSize,layerName,minSize,maxSize)



            if(opSize(1)>maxSize)||(opSize(1)<minSize)...
                ||(opSize(2)>maxSize)||(opSize(2)<minSize)
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedFilterSize',layerName,minSize,maxSize);
                error(msg);
            end
        end

        function checkForMaxSupportedFeatures(inputFeatureSize,inputFeatureNum,layerName,processor)

            if(strcmpi(class(processor),'dnnfpga.processorbase.cnn4Processor')||...
                strcmpi(class(processor),'dnnfpga.processorbase.cnn5Processor'))
                convCC=processor.getCC().convp.conv;
            elseif(strcmpi(class(processor),'dnnfpga.processorbase.conv4Processor'))
                convCC=processor.getCC().conv;
            else
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayer',layerName);
                error(msg);
            end
            threadNumLimit=convCC.threadNumLimit;
            inputMemDepthLimit=convCC.inputMemDepthLimit;
            opSize=convCC.opSize;

            inputMemSizeLimit=prod(inputMemDepthLimit)*threadNumLimit;
            inputFeatureDepth=ceil(inputFeatureNum/threadNumLimit)*threadNumLimit;
            inputTileW=floor(sqrt(inputMemSizeLimit/inputFeatureDepth));
            inputTileImageSize=[inputTileW,inputTileW].*opSize(1:2)';

            if(all(inputTileImageSize<=[inputFeatureSize(1),inputFeatureSize(2)]))
                msg=message('dnnfpga:dnnfpgacompiler:ExceededInputMemorySizeSupported',inputFeatureSize(1),inputFeatureSize(2),inputFeatureNum,layerName);
                error(msg);



















            end
        end

        function existed=checkNetworkExistsOtherLayers(net,currLayer)


            filterOutLayers={'nnet.cnn.layer.ImageInputLayer',...
            'nnet.cnn.layer.RegressionOutputLayer',...
            class(currLayer)};
            existed=false;
            for idx=1:length(net.Layers)
                if(ismember(class(net.Layers(idx)),filterOutLayers))
                    continue;
                end
                existed=true;
                break;
            end
        end

    end
end






