classdef CNN5ProcessorConfig<dnnfpga.config.ProcessorConfigBase




    methods
        function obj=CNN5ProcessorConfig()



            obj=obj@dnnfpga.config.ProcessorConfigBase();


            convModule=dnnfpga.config.Conv4ModuleConfig();
            obj.addModule(convModule);

            fcModule=dnnfpga.config.FC4ModuleConfig();
            obj.addModule(fcModule);

            customLayerModule=dnnfpga.config.CustomLayerModuleConfig();
            obj.addModule(customLayerModule);


            obj.ModelManager=dnnfpga.model.ModelManager(obj);


            try
                obj.CustomLayerManager=dnnfpga.customLayer.LayerManager(obj);
            catch ME


                throwAsCaller(ME);
            end
        end

        function validateProcessorConfig(obj)



            moduleIDList=obj.getModuleIDList;
            for ii=1:length(moduleIDList)
                moduleID=moduleIDList{ii};
                hModule=obj.getModule(moduleID);
                hModule.validateModuleConfig;
                hModule.validateTrimmableProcessorProperties;
            end


            convModule=obj.getModule('conv');
            fcModule=obj.getModule('fc');
            adderModule=obj.getModule('adder');


            if~isequal(lower(convModule.KernelDataType),...
                lower(fcModule.KernelDataType),...
                lower(adderModule.KernelDataType))
                error(message('dnnfpga:quantization:UnsupportedDataTypeCombinationAllMustSame'));
            end


            obj.validationForLargeConvThreadNumbers();


            obj.validateCustomModuleDependency();



            obj.CustomLayerManager.checkLayerList;

        end
    end


    methods(Access=public)

        function registerCustomLayer(obj,varargin)



            if~strcmpi(obj.ProcessorDataType,'single')
                error(message('dnnfpga:customLayer:NotSingleDataType',obj.ProcessorDataType));
            end


            moduleID=dnnfpga.config.CustomLayerModuleConfig.DefaultModuleID;
            if obj.getModule(moduleID).ModuleGeneration
                obj.CustomLayerManager.registerLayer(varargin{:});
            else
                error(message('dnnfpga:customLayer:ModuleGenerationOff',moduleID));
            end

        end

        function openDLModel(obj,varargin)


            try
                obj.ModelManager.openDLModel(varargin{:});
            catch ME
                throw(ME);
            end
        end

        function verifyDLModel(obj,varargin)



            try
                obj.ModelManager.simulateAndValidateModel(varargin{:});
            catch ME
                throw(ME);
            end
        end

        function openCustomLayerModel(obj,varargin)



            obj.hBackDoorFiFeature.enable;

            try

                obj.CustomLayerManager.TestbenchManager.openModel(varargin{:});
            catch ME

                obj.hBackDoorFiFeature.disable;
                throw(ME);
            end


            obj.hBackDoorFiFeature.disable;
        end

        function verifyCustomLayerModel(obj,varargin)


            obj.CustomLayerManager.TestbenchManager.simulateModel(varargin{:});
        end
    end


    methods(Access=public)


        function hPC=optimizeConfigurationForNetwork(obj,net,varargin)






















            p=inputParser;



            addParameter(p,'FramesPerSecond',-1,@(x)(isnumeric(x)&&x>0));
            addParameter(p,'Verbose',0);
            parse(p,varargin{:});
            expectedFps=p.Results.FramesPerSecond;
            verbose=p.Results.Verbose;






            if nargout==1
                hPC=copyobj(obj);
            else

                hPC=obj;
            end


            if~isempty(net)

                if(isa(net,'dlquantizer'))

                    net=net.Net;
                end


                if(~dnnfpga.compiler.canCompileNet(net,false))
                    msg=message('dnnfpga:workflow:InvalidInputWrongClass',...
                    'Network','SeriesNetwork, DAGNetwork or dlnetwork',class(net));
                    error(msg);
                end


                msg=message('dnnfpga:config:OptimizeProcessorConfigBegin');
                dnnfpga.disp(msg);


                processor=hPC.createProcessorObject;


                cnn5Frontend=dnnfpga.compiler.cnn5ProcessorFrontend;


                input.net=net;
                input.argin={'exponentdata',[]};


                hIR=cnn5Frontend.doit(input,processor,'ProcessorConfig',hPC,...
                'ValidateTrimmableKernel',false,'Verbose',0,'isEstimator',1);



                [moduleLevelProperties,blockLevelProperties]=hPC.getAllModuleGenerationProperties;

                [layerMap,fcInfo,convInfo]=hPC.getLayerMap(hIR.ngraph,moduleLevelProperties,blockLevelProperties,1);



                propertyListOld=hPC.getAllPropertiesAsList;




                for idx=1:numel(moduleLevelProperties)
                    moduleLevelProperty=moduleLevelProperties{idx};
                    moduleID=moduleLevelProperty{1};
                    moduleGenerationProperty=moduleLevelProperty{2};
                    hPC.setModuleProperty(moduleID,moduleGenerationProperty,layerMap(moduleID));
                end

                for idx=1:numel(blockLevelProperties)
                    blockLevelProperty=blockLevelProperties{idx};
                    blockName=blockLevelProperty{1};
                    moduleID=blockLevelProperty{2};
                    moduleGenerationProperty=blockLevelProperty{3};
                    if layerMap(moduleID)
                        hPC.setModuleProperty(moduleID,moduleGenerationProperty,layerMap(blockName));
                    end
                end




                if expectedFps~=-1
                    hPC.meetConstraints(net,expectedFps);

                    hPC.displayChangesToHPC(propertyListOld)
                    return
                end










                if layerMap('conv')
                    hConvModule=hPC.getModule('conv');
                    memorySizeMinValue=hConvModule.MemorySizeMinValue;
                    orgConvInputMemorySize=hConvModule.InputMemorySize;
                    orgConvOutputMemorySize=hConvModule.OutputMemorySize;
                    featureSizeLimitRange=hConvModule.FeatureSizeLimitRange;





                    if prod(convInfo.InputMemorySize)<prod(memorySizeMinValue)
                        newConvInputMemorySize=memorySizeMinValue;
                    else
                        newConvInputMemorySize=convInfo.InputMemorySize;
                    end
                    if prod(convInfo.OutputMemorySize)<prod(memorySizeMinValue)
                        newConvOutputMemorySize=memorySizeMinValue;
                    else
                        newConvOutputMemorySize=convInfo.OutputMemorySize;
                    end


                    if prod(newConvInputMemorySize(1:2))<prod(orgConvInputMemorySize(1:2))
                        hPC.setModuleProperty('conv','InputMemorySize',newConvInputMemorySize);
                    end
                    if prod(newConvOutputMemorySize(1:2))<prod(orgConvOutputMemorySize(1:2))





                        hPC.setModuleProperty('conv','OutputMemorySize',[newConvOutputMemorySize(1),newConvOutputMemorySize(2),min([16,propertyListOld{1}.propertyValue,newConvOutputMemorySize(3)])]);
                    end



                    if convInfo.FeatureSize<featureSizeLimitRange(1)
                        newFeatureSize=featureSizeLimitRange(1);
                    else
                        newFeatureSize=convInfo.FeatureSize;
                    end


                    if newFeatureSize>=featureSizeLimitRange(1)&&...
                        newFeatureSize<=featureSizeLimitRange(2)
                        hPC.setModuleProperty('conv','FeatureSizeLimit',newFeatureSize);
                    end
                end


                if layerMap('fc')
                    hFCModule=hPC.getModule('fc');
                    memorySizeMinValue=hFCModule.MemorySizeMinValue;
                    newFCInputMemorySize=max(memorySizeMinValue,fcInfo.InputMemorySize);
                    newFCOutputputMemorySize=max(memorySizeMinValue,fcInfo.OutputMemorySize);
                    hPC.setModuleProperty('fc','InputMemorySize',newFCInputMemorySize);
                    hPC.setModuleProperty('fc','OutputMemorySize',newFCOutputputMemorySize);
                end


                hPC.displayChangesToHPC(propertyListOld)
            end
        end
    end

    methods(Hidden)
        function saveCustomLayerListToMatFile(obj)



            customLayerList=obj.CustomLayerManager.getLayerList;
            if~isempty(customLayerList)
                save('customLayerList.mat','customLayerList');
            end

        end
    end



    methods(Hidden)
        function bcc=applyProcessorConfigtoBCC(obj)






            convModule=obj.getModule('conv');
            fcModule=obj.getModule('fc');
            adderModule=obj.getModule('adder');






            convThreadNumber=sqrt(convModule.ConvThreadNumber);


            convInputMemorySize=convModule.InputMemorySize;
            convOutputMemorySize=convModule.OutputMemorySize;



            convFeatureSizeLimit=convModule.FeatureSizeLimit;



            convFilterSizeLimit=convModule.FilterSizeLimit;


            convLRNThreadNumber=convModule.LRNThreadNumber;


            convModule.KernelDataType=obj.ProcessorDataType;
            convKernelDataType=convModule.KernelDataType;

            convModule.updateActivationAXIDataBitwidth;


            syncInstructionNumber=convModule.SyncInstructionNumber;


            convRoundingMode=convModule.RoundingMode;


            convMemoryMinDepth=convModule.MemoryMinimumDepth;


            fcThreadNumber=fcModule.FCThreadNumber;
            fcInputMemorySize=fcModule.InputMemorySize;
            fcOutputMemorySize=fcModule.OutputMemorySize;
            fcModule.KernelDataType=obj.ProcessorDataType;
            fcKernelDataType=fcModule.KernelDataType;

            fcModule.updateWeightAXIDataBitwidth;

            fcRoundingMode=fcModule.RoundingMode;

            fcMemoryMinDepth=fcModule.MemoryMinimumDepth;


            fcWeightDataType='single';
            fcWeightAXIDataBitwidth=fcModule.WeightAXIDataBitwidth;


            adderModule.KernelDataType=obj.ProcessorDataType;
            adderKernelDataType=adderModule.KernelDataType;
            adderInputMemorySize=adderModule.InputMemorySize;
            adderOutputMemorySize=adderModule.OutputMemorySize;
            adderInputBurstLength=adderModule.InputBurstLength;
            adderOutputBurstLength=adderModule.OutputBurstLength;



            dataTransNum=convThreadNumber;
            customLayerList=obj.CustomLayerManager.getLayerList;
            bcc=dnnfpga.bcc.getBCCDefaultCNN5(convThreadNumber,fcThreadNumber,fcWeightDataType,fcWeightAXIDataBitwidth,convKernelDataType,fcKernelDataType,dataTransNum,adderKernelDataType,convRoundingMode,fcRoundingMode,convMemoryMinDepth,fcMemoryMinDepth,customLayerList);




            bcc.convp.conv.origOpWLimit=convFilterSizeLimit;






            [maxInputTileImageSize,maxOutputTileImageSize]=dnnfpga.processorbase.maxTileSize(convInputMemorySize,convOutputMemorySize,...
            convThreadNumber,1,1,[bcc.convp.conv.opW;bcc.convp.conv.opW]);
            maxImgW=max(maxInputTileImageSize(1),maxOutputTileImageSize(1));
            bcc.convp.ip0.imgWLimit=maxImgW;
            bcc.convp.ip1.imgWLimit=maxImgW;
            bcc.convp.op0.imgWLimit=maxImgW;
            bcc.convp.conv.imgWLimit=maxImgW;






            bcc.convp.conv.inputMemDepthLimit=[convInputMemorySize(3);convInputMemorySize(1);convInputMemorySize(2)];
            bcc.convp.conv.resultMemDepthLimit=[convOutputMemorySize(3);convOutputMemorySize(1);convOutputMemorySize(2)];



            bcc.convp.conv.featureSizeLimit=[convFeatureSizeLimit;convFeatureSizeLimit;1];


            bcc.convp.conv.lrnCompWindowSize=convLRNThreadNumber;


            syncInstructionBits=ceil(log2(syncInstructionNumber));
            bcc.convp.syncInstFormat.newPCMax=bcc.convp.syncInstFormat.newPCMin+syncInstructionBits;
            bcc.convp.syncInstFormat.funcMax=bcc.convp.syncInstFormat.funcMin+syncInstructionBits;



            bcc.fcp.inputMemDepthLimit=fcInputMemorySize;
            bcc.fcp.resultMemDepthLimit=fcOutputMemorySize;
            bcc.fcp.matrixSizeLimit=[fcInputMemorySize;fcOutputMemorySize];
            bcc.fcp.fcOpDataType=fcWeightDataType;


            bcc.addp.inputMemDepthLimit=adderInputMemorySize;
            bcc.addp.resultMemDepthLimit=adderOutputMemorySize;
            bcc.addp.inputBurstLength=adderInputBurstLength;
            bcc.addp.outputBurstLength=adderOutputBurstLength;


            if dnnfpga.tool.useNFP(obj)
                fpLib='NativeFloatingPoint';
                fpLibParams='minlatency';




                bcc.convp.conv=dnnfpga.processorbase.processorUtils.resolveIPLatencies(bcc.convp.conv,fpLib,fpLibParams,0,{});
                bcc.fcp=dnnfpga.processorbase.processorUtils.resolveIPLatencies(bcc.fcp,fpLib,fpLibParams,0,{});
                bcc.addp=dnnfpga.processorbase.processorUtils.resolveIPLatencies(bcc.addp,fpLib,fpLibParams,0,{});
            else


            end

            bcc.enableAxiStream=false;
            if(strcmp(obj.InputDataInterface,'AXI4-Stream')||strcmp(obj.InputDataInterface,'AXI4-Stream Video'))
                bcc.enableAxiStream=true;
            end

            moduleIDList=obj.ModuleIDList;
            moduleEnable=struct;
            for idx=1:numel(moduleIDList)
                moduleID=moduleIDList{idx};



                hModule=obj.getModule(moduleID);
                ModuleGenerationProperties=hModule.Properties(hModule.ModuleGenerationMapKeyName);

                for idy=1:numel(ModuleGenerationProperties)


                    ModuleGenerationProperty=ModuleGenerationProperties{idy};
                    if strcmp(ModuleGenerationProperty,hModule.ModuleGenerationName)

                        moduleEnable.(moduleID)=hModule.(ModuleGenerationProperty);
                    else







                        blockName=extractBefore(ModuleGenerationProperty,hModule.BlockGenerationName);
                        moduleEnable.([moduleID,'_',lower(blockName)])=hModule.(ModuleGenerationProperty);
                    end
                end
            end


            bcc.moduleEnable=moduleEnable;


            bcc.customLayersInfo=customLayerList;
        end

        function hProcessor=createProcessorObject(obj)








            bcc=obj.applyProcessorConfigtoBCC;


            hProcessor=dnnfpga.processorbase.cnn5Processor(bcc);


            obj.saveCustomLayerListToMatFile;

        end

        function[moduleLevelProperties,blockLevelProperties]=getAllModuleGenerationProperties(obj)



            moduleLevelProperties={};
            blockLevelProperties={};
            moduleIDList=obj.ModuleIDList;


            for idx=1:numel(moduleIDList)
                moduleID=moduleIDList{idx};
                hModule=obj.getModule(moduleID);
                ModuleGenerationProperties=hModule.Properties(hModule.ModuleGenerationMapKeyName);


                for idy=1:numel(ModuleGenerationProperties)
                    ModuleGenerationProperty=ModuleGenerationProperties{idy};
                    if strcmp(ModuleGenerationProperty,hModule.ModuleGenerationName)

                        moduleLevelProperties{end+1}={moduleID,ModuleGenerationProperty};%#ok<AGROW>
                    elseif strcmpi(moduleID,dnnfpga.config.CustomLayerModuleConfig.DefaultModuleID)



                        blockLevelProperties{end+1}={ModuleGenerationProperty,moduleID,ModuleGenerationProperty};%#ok<AGROW>
                    else

                        blockName=lower(extractBefore(ModuleGenerationProperty,hModule.BlockGenerationName));
                        if(strcmpi(blockName,'sigmoid'))


                            blockName=strcat(blockName,'InFC');
                        end
                        blockLevelProperties{end+1}={blockName,moduleID,ModuleGenerationProperty};%#ok<AGROW>
                    end
                end
            end
        end

        function propertyList=getAllPropertiesAsList(obj)


            propertyList={};
            moduleIDList=obj.ModuleIDList;
            for idx=1:numel(moduleIDList)
                moduleID=moduleIDList{idx};
                hModule=obj.getModule(moduleID);
                hModulePropertiesValue=hModule.Properties.values;
                hModuleProperties=cat(2,hModulePropertiesValue{:});
                for idy=1:numel(hModuleProperties)
                    hModuleProperty=hModuleProperties{idy};
                    hModulePropertyValue=hModule.(hModuleProperty);
                    propertyStruct=struct('moduleID',moduleID,...
                    'propertyName',hModuleProperty,...
                    'propertyValue',hModulePropertyValue);
                    propertyList{end+1}=propertyStruct;%#ok<AGROW>
                end
            end
        end

        function memorySize=updateMemorySize(~,memorySize,newMemorySize)


            if isempty(memorySize)
                memorySize=newMemorySize;
            else

                numelElem=numel(memorySize)-1;
                if numelElem==0
                    numelElem=1;
                end


                if prod(newMemorySize(1:numelElem))>prod(memorySize(1:numelElem))
                    memorySize=newMemorySize;
                end
            end
        end

        function validateNetworkForTrimmableKernels(obj,NGraph,isEstimator)


            [moduleLevelProperties,blockLevelProperties]=obj.getAllModuleGenerationProperties;

            layerMap=obj.getLayerMap(NGraph,moduleLevelProperties,blockLevelProperties,0);



            for idx=1:numel(moduleLevelProperties)
                moduleLevelProperty=moduleLevelProperties{idx};
                moduleID=moduleLevelProperty{1};
                moduleGenerationProperty=moduleLevelProperty{2};

                hModule=obj.getModule(moduleID);
                moduleEnable=hModule.(moduleGenerationProperty);
                if layerMap(moduleID)&&~moduleEnable
                    if isEstimator
                        msg=message('dnnfpga:config:DisabledModule',moduleID);
                    else
                        msg=message('dnnfpga:workflow:BitstreamNotContainModule',moduleID);
                    end
                    error(msg);
                end
            end

            for idx=1:numel(blockLevelProperties)
                blockLevelProperty=blockLevelProperties{idx};
                blockName=blockLevelProperty{1};
                moduleID=blockLevelProperty{2};
                blockGenerationProperty=blockLevelProperty{3};
                hModule=obj.getModule(moduleID);
                blockEnable=hModule.(blockGenerationProperty);
                if layerMap(moduleID)&&layerMap(blockName)&&~blockEnable


                    if(~(strcmpi(blockName,'softmax')||strcmpi(blockName,'sigmoidInFC')||strcmpi(blockName,'Sigmoid')))
                        if isEstimator
                            msg=message('dnnfpga:config:DisabledBlock',blockName,moduleID,blockLevelProperty{3});
                        else
                            msg=message('dnnfpga:workflow:BitstreamNotContainBlock',blockName,moduleID,blockLevelProperty{3});
                        end
                        error(msg);
                    end
                end
            end
        end

        function[layerMap,fcInfo,convInfo]=getLayerMap(obj,NGraph,moduleLevelProperties,blockLevelProperties,toOptimize)






            import dnnfpga.dagCompile.LayerKind

            layerMap=containers.Map('KeyType','char','ValueType','logical');



            for idx=1:numel(moduleLevelProperties)
                layerMap(moduleLevelProperties{idx}{1})=false;
            end

            for idx=1:numel(blockLevelProperties)
                layerMap(blockLevelProperties{idx}{1})=false;
            end


            fcInfo=struct;
            fcInfo.InputMemorySize=[];
            fcInfo.OutputMemorySize=[];


            convInfo=struct;
            convInfo.InputMemorySize=[];
            convInfo.OutputMemorySize=[];
            convInfo.FeatureSize=[];



            components=NGraph.components;
            for component=components'
                if toOptimize&&strcmpi(class(component.nLayer),'nnet.cnn.layer.ImageInputLayer')...
                    &&strcmp(obj.ProcessorDataType,'single')


                    if strcmpi(component.nLayer.Normalization,'zerocenter')
                        layerMap('custom')=true;
                        layerMap('Addition')=true;
                    elseif strcmpi(component.nLayer.Normalization,'zscore')
                        layerMap('custom')=true;
                        layerMap('Addition')=true;
                        layerMap('Multiplication')=true;
                    end
                end
                if component.hasKind(LayerKind.Conv)
                    layerMap('conv')=true;
                    layerInputSize=component.inputs(1).net.size;
                    layerOutputSize=component.outputs(1).net.size;
                    layerFeatureSize=max(layerInputSize(3),layerOutputSize(3));
                    convInfo.InputMemorySize=obj.updateMemorySize(convInfo.InputMemorySize,layerInputSize);
                    convInfo.OutputMemorySize=obj.updateMemorySize(convInfo.OutputMemorySize,layerOutputSize);
                    convInfo.FeatureSize=obj.updateMemorySize(convInfo.FeatureSize,layerFeatureSize);
                end
                if component.hasKind(LayerKind.FC)
                    layerMap('fc')=true;
                    layerInputSize=prod(component.inputs(1).net.size);
                    layerOutputSize=prod(component.outputs(1).net.size);
                    fcInfo.InputMemorySize=obj.updateMemorySize(fcInfo.InputMemorySize,layerInputSize);
                    fcInfo.OutputMemorySize=obj.updateMemorySize(fcInfo.OutputMemorySize,layerOutputSize);
                end
                if(component.hasKind(LayerKind.Add)||component.hasKind(LayerKind.CustomLayer))&&...
                    ~isa(component.nLayer,'nnet.cnn.layer.SigmoidLayer')









                    layerMap('custom')=true;


                    customLayerBlockName=component.CustomLayerInfo.ConfigBlockname;
                    if~isempty(customLayerBlockName)
                        layerMap(customLayerBlockName)=true;
                    end
                end
                if isa(component.nLayer,'nnet.cnn.layer.MaxUnpooling2DLayer')||isa(component.nLayer,'nnet.cnn.layer.TransposedConvolution2DLayer')


                    layerMap('conv')=true;
                    layerMap('segmentation')=true;
                end
                if isa(component.nLayer,'nnet.cnn.layer.CrossChannelNormalizationLayer')
                    layerMap('conv')=true;
                    layerMap('lrn')=true;
                end





                if(isa(component.nLayer,'nnet.cnn.layer.SoftmaxLayer'))
                    if(layerMap('lrn')||(layerMap('segmentation')&&strcmpi(obj.ProcessorDataType,'single')))


                        layerMap('softmax')=false;
                    else
                        isConvModulePresent=layerMap('conv');
                        convThreadNum=obj.getModuleProperty('conv','ConvThreadNumber');
                        isaPowerOfTwo=floor(log2(sqrt(convThreadNum)))==ceil(log2(sqrt(convThreadNum)));


                        if((toOptimize&&isConvModulePresent&&isaPowerOfTwo)||...
                            (toOptimize&&~isConvModulePresent)||...
                            ~component.hasKind(LayerKind.Soft))
                            layerMap('softmax')=true;
                            layerMap('fc')=true;




                            layerInputSize=prod(component.inputs(1).net.size);
                            layerOutputSize=prod(component.outputs(1).net.size);
                            fcInfo.InputMemorySize=obj.updateMemorySize(fcInfo.InputMemorySize,layerInputSize);
                            fcInfo.OutputMemorySize=obj.updateMemorySize(fcInfo.OutputMemorySize,layerOutputSize);
                        end
                    end
                end



                if(isa(component.nLayer,'nnet.cnn.layer.SigmoidLayer'))
                    if(strcmpi(obj.ProcessorDataType,'single'))
                        layerMap('sigmoidInFC')=false;
                        layerMap('Sigmoid')=true;
                        layerMap('custom')=true;
                    else
                        isConvModulePresent=layerMap('conv');
                        convThreadNum=obj.getModuleProperty('conv','ConvThreadNumber');
                        isaPowerOfTwo=floor(log2(sqrt(convThreadNum)))==ceil(log2(sqrt(convThreadNum)));



                        if((toOptimize&&isConvModulePresent&&isaPowerOfTwo)||...
                            (toOptimize&&~isConvModulePresent)||...
                            ~component.hasKind(LayerKind.Soft))
                            layerMap('sigmoidInFC')=true;
                            layerMap('fc')=true;




                            layerInputSize=prod(component.inputs(1).net.size);
                            layerOutputSize=prod(component.outputs(1).net.size);
                            fcInfo.InputMemorySize=obj.updateMemorySize(fcInfo.InputMemorySize,layerInputSize);
                            fcInfo.OutputMemorySize=obj.updateMemorySize(fcInfo.OutputMemorySize,layerOutputSize);
                        end
                    end
                end

            end
        end

        function displayChangesToHPC(hPC,propertyListOld)

            isAnyPropertyChanged=false;
            propertyListNew=hPC.getAllPropertiesAsList;
            for idx=1:numel(propertyListNew)
                moduleID=propertyListNew{idx}.moduleID;
                oldValue=propertyListOld{idx}.propertyValue;
                newValue=propertyListNew{idx}.propertyValue;
                propertyName=propertyListNew{idx}.propertyName;
                if any(string(oldValue)~=string(newValue))
                    oldValueStr=dnnfpga.config.refineValueForDisplay(oldValue);
                    newValueStr=dnnfpga.config.refineValueForDisplay(newValue);
                    hModule=hPC.getModule(moduleID);
                    if contains(propertyName,'ModuleGeneration')||...
                        contains(propertyName,hModule.BlockGenerationName)


                        layerName=extractBefore(propertyName,hModule.BlockGenerationName);
                        if isempty(layerName)
                            layerName=moduleID;
                        end



                        msg=message('dnnfpga:config:PropertyChanged',moduleID,propertyName,oldValueStr,newValueStr);
                    else

                        msg=message('dnnfpga:config:PropertyChanged',moduleID,propertyName,oldValueStr,newValueStr);
                    end
                    dnnfpga.disp(['Note: ',msg.getString]);
                    isAnyPropertyChanged=true;
                end
            end


            if isAnyPropertyChanged
                fprintf('\n');
                disp(hPC);
            end


            msg=message('dnnfpga:config:OptimizeProcessorConfigComplete');
            dnnfpga.disp(msg);
        end



        function meetConstraints(hPC,net,expectedFps)


            Tolerance=0.05;

            convThreads=[4,9,16,25,36,49,64];
            fcThreads=[4,8,16];
            cLen=numel(convThreads);
            fLen=numel(fcThreads);
            lookUpTable=zeros(fLen,cLen);


            c=floor(cLen/2);
            f=ceil(fLen/2);



            [lookUpTable(f,c),relTol]=getEstimatedFps(hPC,net,convThreads(c),fcThreads(f),expectedFps);




            if abs(relTol)>Tolerance


                if(relTol>0)
                    while(c>0&&c<=cLen)&&(f>0&&f<=fLen)


                        if(c-1)>0
                            [lookUpTable(f,c-1),relTol_lowCThread]=getEstimatedFps(hPC,net,convThreads(c-1),fcThreads(f),expectedFps);
                        end

                        if(f-1)>0
                            [lookUpTable(f-1,c),relTol_lowFThread]=getEstimatedFps(hPC,net,convThreads(c),fcThreads(f-1),expectedFps);
                        end












                        if(abs(relTol_lowCThread)>Tolerance)&&(abs(relTol_lowFThread)>Tolerance)
                            if(abs(relTol_lowCThread)<=abs(relTol_lowFThread))
                                if(c-1)>=1
                                    c=c-1;
                                    relTol=relTol_lowCThread;
                                else
                                    break;
                                end
                            else
                                if(f-1)>=1
                                    f=f-1;
                                    relTol=relTol_lowFThread;
                                else
                                    break;
                                end
                            end
                        elseif(abs(relTol_lowCThread)<=Tolerance)&&(abs(relTol_lowFThread)<=Tolerance)



                            c=c-1;
                            relTol=relTol_lowCThread;
                            break;
                        else
                            if(abs(relTol_lowCThread)<=Tolerance)
                                c=c-1;
                                relTol=relTol_lowCThread;
                                break;
                            else
                                f=f-1;
                                relTol=relTol_lowFThread;
                                break;
                            end
                        end
                        if(relTol<0)


                            if lookUpTable(f,c+1)~=0
                                fps_highCThread=lookUpTable(f,c+1);
                                relTol_highCThread=(fps_highCThread-expectedFps)/expectedFps;
                            else
                                [lookUpTable(f,c+1),relTol_highCThread]=getEstimatedFps(hPC,net,convThreads(c+1),fcThreads(f),expectedFps);
                            end

                            if lookUpTable(f+1,c)~=0
                                fps_highFThread=lookUpTable(f+1,c);
                                relTol_highFThread=(fps_highFThread-expectedFps)/expectedFps;
                            else
                                [lookUpTable(f+1,c),relTol_highFThread]=getEstimatedFps(hPC,net,convThreads(c),fcThreads(f+1),expectedFps);
                            end

                            if(abs(relTol_highCThread)<=abs(relTol_highFThread))
                                c=c+1;
                                relTol=relTol_highCThread;
                                break;
                            else
                                f=f+1;
                                relTol=relTol_highFThread;
                                break;
                            end

                        end
                    end
                else


                    while(c>0&&c<=cLen)&&(f>0&&f<=fLen)


                        if c<cLen
                            [lookUpTable(f,c+1),relTol_highCThread]=getEstimatedFps(hPC,net,convThreads(c+1),fcThreads(f),expectedFps);
                        end

                        if f<fLen
                            [lookUpTable(f+1,c),relTol_highFThread]=getEstimatedFps(hPC,net,convThreads(c),fcThreads(f+1),expectedFps);
                        end












                        if(abs(relTol_highCThread)>Tolerance)&&(abs(relTol_highFThread)>Tolerance)
                            if(abs(relTol_highCThread)<=abs(relTol_highFThread))
                                if(c+1)<=cLen
                                    c=c+1;
                                    relTol=relTol_highCThread;
                                else
                                    break;
                                end
                            else
                                if(f+1)<=fLen
                                    f=f+1;
                                    relTol=relTol_highFThread;
                                else
                                    break;
                                end
                            end
                        elseif(abs(relTol_highCThread)<=Tolerance)&&(abs(relTol_highFThread)<=Tolerance)



                            f=f+1;
                            relTol=relTol_highFThread;
                            break;
                        else
                            if(abs(relTol_highCThread)<=Tolerance)
                                c=c+1;
                                relTol=relTol_highCThread;
                                break;
                            else
                                f=f+1;
                                relTol=relTol_highFThread;
                                break;
                            end
                        end
                        if(relTol>0)


                            if lookUpTable(f-1,c)~=0
                                fps_lowFThread=lookUpTable(f-1,c);
                                relTol_lowFThread=(fps_lowFThread-expectedFps)/expectedFps;
                            else
                                [lookUpTable(f-1,c),relTol_lowFThread]=getEstimatedFps(hPC,net,convThreads(c),fcThreads(f-1),expectedFps);
                            end

                            if lookUpTable(f,c-1)~=0
                                fps_lowCThread=lookUpTable(f,c-1);
                                relTol_lowCThread=(fps_lowCThread-expectedFps)/expectedFps;
                            else
                                [lookUpTable(f,c-1),relTol_lowCThread]=getEstimatedFps(hPC,net,convThreads(c-1),fcThreads(f),expectedFps);
                            end


                            if(abs(relTol_lowCThread)<=abs(relTol_lowFThread))
                                c=c-1;
                                relTol=relTol_lowCThread;
                                break;
                            else
                                f=f-1;
                                relTol=relTol_lowFThread;
                                break;
                            end

                        end
                    end
                end
            end

            hPC.setModuleProperty('conv','ConvThreadNumber',convThreads(c));
            hPC.setModuleProperty('fc','FCThreadNumber',fcThreads(f));


            stepSize=[10,10,0];
            inputMemSize=hPC.getModuleProperty('conv','InputMemorySize');
            outputMemSize=hPC.getModuleProperty('conv','OutputMemorySize');




            if(relTol>0)
                reducedInputMemSize=inputMemSize;
                reducedOutputMemSize=outputMemSize;
                while 1
                    reducedInputMemSize=reducedInputMemSize-stepSize;
                    reducedOutputMemSize=reducedOutputMemSize-stepSize;
                    hPC.setModuleProperty('conv','InputMemorySize',reducedInputMemSize);
                    hPC.setModuleProperty('conv','OutputMemorySize',reducedOutputMemSize);
                    try
                        fps_lowMemSize=hPC.estimatePerformance(net,'Verbose',0);
                        fps_lowMemSize=str2double(fps_lowMemSize.("Frame/s"){1});
                    catch
                        fps_lowMemSize=0;
                    end
                    relTol_lowMemSize=(fps_lowMemSize-expectedFps)/expectedFps;
                    if abs(relTol_lowMemSize)>=abs(relTol)||relTol_lowMemSize<0
                        inputMemSize=reducedInputMemSize+stepSize;
                        outputMemSize=reducedOutputMemSize+stepSize;
                        break;
                    else
                        relTol=relTol_lowMemSize;
                    end
                end






            else
                reducedInputMemSize=inputMemSize;
                increasedOutputMemSize=outputMemSize;
                while 1
                    reducedInputMemSize=reducedInputMemSize-stepSize;
                    increasedOutputMemSize=increasedOutputMemSize+stepSize;
                    hPC.setModuleProperty('conv','InputMemorySize',reducedInputMemSize);
                    hPC.setModuleProperty('conv','OutputMemorySize',increasedOutputMemSize);
                    try
                        fps_highMemSize=hPC.estimatePerformance(net,'Verbose',0);
                        fps_highMemSize=str2double(fps_highMemSize.("Frame/s"){1});
                    catch
                        fps_highMemSize=0;
                    end
                    relTol_highMemSize=(fps_highMemSize-expectedFps)/expectedFps;
                    if abs(relTol_highMemSize)>=abs(relTol)||relTol_highMemSize<0
                        inputMemSize=reducedInputMemSize+stepSize;
                        outputMemSize=increasedOutputMemSize-stepSize;
                        break;
                    else
                        relTol=relTol_highMemSize;
                    end
                end
            end


            hPC.setModuleProperty('conv','InputMemorySize',inputMemSize);
            hPC.setModuleProperty('conv','OutputMemorySize',outputMemSize);




            resources=hPC.estimateResources('IncludeReferenceDesign',true);
            if(resources.DSP(1)<resources.DSP(2))||...
                (resources.blockRAM(1)<resources.blockRAM(2))||...
                (resources.LUT(1)<resources.LUT(2))




                msg=message('dnnfpga:config:InsufficientResources');
                warning(msg);
            end

        end

        function[fps,relTol]=getEstimatedFps(hPC,net,cThread,fThread,expectedFps)
            try
                hPC.setModuleProperty('conv','ConvThreadNumber',cThread);
                hPC.setModuleProperty('fc','FCThreadNumber',fThread);
                fps=hPC.estimatePerformance(net,'Verbose',0);
                fps=str2double(fps.("Frame/s"){1});
            catch
                fps=0;
            end
            relTol=(fps-expectedFps)/expectedFps;
        end

        function b=copyobj(a)

            b=eval(class(a));


            for p=properties(a).'
                b.(p{1})=a.(p{1});
            end


            convModule=dnnfpga.config.Conv4ModuleConfig();
            if strcmpi(a.getModuleProperty('conv','ModuleGeneration'),'on')
                for p=properties(convModule).'
                    if~strcmpi(p{1},'ModuleID')
                        b.setModuleProperty('conv',p{1},a.getModuleProperty('conv',p{1}))
                    end
                end
            else
                b.setModuleProperty('conv','ModuleGeneration','off')
            end


            fcModule=dnnfpga.config.FC4ModuleConfig();
            if strcmpi(a.getModuleProperty('fc','ModuleGeneration'),'on')
                for p=properties(fcModule).'
                    if~strcmpi(p{1},'ModuleID')
                        b.setModuleProperty('fc',p{1},a.getModuleProperty('fc',p{1}))
                    end
                end
            else
                b.setModuleProperty('fc','ModuleGeneration','off')
            end


            customLayerModule=dnnfpga.config.CustomLayerModuleConfig();
            if strcmpi(a.getModuleProperty('custom','ModuleGeneration'),'on')
                for p=properties(customLayerModule).'
                    if~strcmpi(p{1},'ModuleID')&&~strcmpi(p{1},'KernelDataType')
                        b.setModuleProperty('custom',p{1},a.getModuleProperty('custom',p{1}))
                    end
                end
            else
                b.setModuleProperty('custom','ModuleGeneration','off')
            end
        end

    end


    methods(Hidden)
        function validationForLargeConvThreadNumbers(obj)






            [convTF,convModule]=obj.isInModuleIDList('conv');
            [fcTF,fcModule]=obj.isInModuleIDList('fc');

            if~convTF;return;end
            if~fcTF;return;end

            CTN=convModule.ConvThreadNumber;
            FTN=fcModule.FCThreadNumber;

            if~fcModule.ModuleGeneration&&~convModule.ModuleGeneration

            elseif~fcModule.ModuleGeneration


                if CTN>=64&&FTN<sqrt(CTN)
                    fcModule.FCThreadNumber=sqrt(CTN);
                end
            elseif~convModule.ModuleGeneration

            else


                if CTN>=64&&FTN<sqrt(CTN)
                    error(message('dnnfpga:config:UnsupportedThreadNumCombo'));
                end
            end
        end

        function validateCustomModuleDependency(obj)



            [customTF,customModule]=obj.isInModuleIDList('custom');


            if(customModule.('ModuleGeneration'))
                blockNames={'Resize2D','Sigmoid','TanhLayer'};
                for i=1:numel(blockNames)
                    blockName=blockNames{i};
                    if customTF&&customModule.(blockName)&&~strcmp(obj.SynthesisTool,'Xilinx Vivado')
                        msg=message('dnnfpga:config:UnsupportedCustomLayerForIntel',blockName);
                        error(msg);
                    end
                end
            end
        end

    end



end





