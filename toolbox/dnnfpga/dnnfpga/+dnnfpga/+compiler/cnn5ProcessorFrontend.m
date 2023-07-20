classdef cnn5ProcessorFrontend<dnnfpga.compiler.abstractDNNCompilerStage




    properties(Access=protected)
        Verbose=1;
    end

    methods(Access=public,Hidden=true)
        function obj=cnn5ProcessorFrontend(verbose)
            if nargin<1
                verbose=1;
            end

            obj@dnnfpga.compiler.abstractDNNCompilerStage();
            obj.Verbose=verbose;
        end
    end

    methods(Access=public)
        function output=doit(obj,input,processor,varargin)


            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'Verbose',1);
            addParameter(p,'ActivationLayer','',@ischar);
            addParameter(p,'ProcessorConfig',[]);
            addParameter(p,'HardwareNormalization','auto');
            addParameter(p,'ValidateTrimmableKernel',true,@(x)islogical(x));


            parse(p,varargin{:});

            verbose=p.Results.Verbose;
            activationLayer=p.Results.ActivationLayer;
            processorConfig=p.Results.ProcessorConfig;
            hardwareNormalization=p.Results.HardwareNormalization;
            validateTrimmableKernel=p.Results.ValidateTrimmableKernel;
            addedArgin={'Verbose',verbose,...
            'ActivationLayer',activationLayer,...
            'ProcessorConfig',processorConfig,...
            'HardwareNormalization',hardwareNormalization,...
            'ValidateTrimmableKernel',validateTrimmableKernel,...
            };
            net=input.net;
            argin=input.argin;
            argin=cat(2,argin,addedArgin);

            output=obj.runFrontend(net,processor,argin{:});

        end
    end

    methods(Access=private)

        function hIR=runFrontend(obj,net,processor,varargin)


            params=varargin(1:end);

            pvpairs=dnnfpga.compiler.seriesNetworkAndPIRFrontend.parse_params(params);



            if~isfield(pvpairs,'targetdir')||isempty(pvpairs.targetdir)
                pvpairs.targetdir=[pwd,filesep,'codegen'];
            end

            if(~isfield(pvpairs,'hardwarenormalization')||isempty(pvpairs.hardwarenormalization))
                pvpairs.hardwarenormalization='auto';
            end


            if~isfield(pvpairs,'isestimator')||isempty(pvpairs.isestimator)
                pvpairs.isestimator=0;
            end
            activationLayer=pvpairs.activationlayer;















            if isa(net,'dlnetwork')
                dnnfpga.compiler.validateDLNetwork(net);
                net=dnnfpga.compiler.transformDLNetwork(net,obj.Verbose);
            end




            dnnfpga.compiler.validateSegmentationLayers(processor,net);


            net=dnnfpga.compiler.wrapResize2DLayers(net,processor);


            dnnfpga.macros.Macros.registerMacro('nnet.cnn.layer.LSTMLayer',@dnnfpga.macros.createLSTMLayerNet,true);



            net=dnnfpga.compiler.optimizations.optimizeNetwork(net,pvpairs.verbose);









            dataTransNum=processor.getCC.dataTransNum;
            [netForDLP,changed]=dnnfpga.compiler.optimizations.preprocessNetworkForDLP(net,dataTransNum);
            if changed


                netForDLP=dnnfpga.compiler.optimizations.optimizeNetwork(netForDLP,pvpairs.verbose);
            end



            hIR=dnnfpga.dagCompile.DLNetworkIR(net,netForDLP,processor,obj.Verbose);


            processorConfig=pvpairs.processorconfig;
            validateTrimmableKernel=pvpairs.validatetrimmablekernel;
            hIR.createNGraph(processorConfig,activationLayer);




            cc=processor.getCC();
            isSoftmaxHWLayer=true;
            if(isfield(cc,'moduleEnable')&&~cc.moduleEnable.fc_softmax)
                hIR=dnnfpga.compiler.cnn5CosimIRFrontend.assignLayerKindSoft(hIR,'softmax');
                isSoftmaxHWLayer=false;
            else
                isConvModulePresent=strcmpi(processorConfig.getModuleProperty('conv','ModuleGeneration'),'on');
                convThreadNum=processorConfig.getModuleProperty('conv','ConvThreadNumber');
                isaPowerOfTwo=floor(log2(sqrt(convThreadNum)))==ceil(log2(sqrt(convThreadNum)));
                if(isConvModulePresent&&~isaPowerOfTwo)&&(pvpairs.verbose~=0)
                    msg=message('dnnfpga:dnnfpgacompiler:NonPowerofTwoConvThreadNotSupported');
                    warning(msg);
                    hIR=dnnfpga.compiler.cnn5CosimIRFrontend.assignLayerKindSoft(hIR,'softmax');
                    isSoftmaxHWLayer=false;
                end
            end

            [dataType,status]=dnnfpga.compiler.processorKernelType(processor);



            isSigmoidHWLayer=true;
            if(~status)
                if(~isempty(processorConfig))
                    isSigmoidInCustomModuleEnabled=strcmpi(processorConfig.getModuleProperty('custom','Sigmoid'),'on');
                    if(isSigmoidInCustomModuleEnabled)
                        hIR=dnnfpga.compiler.cnn5CosimIRFrontend.assignCustomLayerKindForSigmoidLayer(hIR,processor);
                    else
                        hIR=dnnfpga.compiler.cnn5CosimIRFrontend.assignLayerKindSoft(hIR,'sigmoid');
                        isSigmoidHWLayer=false;
                    end
                end
            else
                if(~isempty(processorConfig))
                    isConvModulePresent=strcmpi(processorConfig.getModuleProperty('conv','ModuleGeneration'),'on');
                    convThreadNum=processorConfig.getModuleProperty('conv','ConvThreadNumber');
                    isaPowerOfTwo=floor(log2(sqrt(convThreadNum)))==ceil(log2(sqrt(convThreadNum)));

                    components=hIR.ngraph.components;
                    for i=1:numel(components)
                        component=components(i);
                        if(strcmpi(class(component.nLayer),'nnet.cnn.layer.SigmoidLayer'))
                            nextComponent=component.outputs.net.receivers.component;
                            if(isConvModulePresent&&~isaPowerOfTwo)
                                if(nextComponent.hasKind(dnnfpga.dagCompile.LayerKind.Hard))
                                    msg=message('dnnfpga:dnnfpgacompiler:NonPowerofTwoConvThreadNotSupportedSigmoid',nextComponent.nLayer.Name);
                                    error(msg);
                                else
                                    msg=message('dnnfpga:dnnfpgacompiler:NonPowerofTwoConvThreadNotSupported');
                                    warning(msg);
                                    hIR=dnnfpga.compiler.cnn5CosimIRFrontend.assignLayerKindSoft(hIR,'sigmoid');
                                    isSigmoidHWLayer=false;
                                end
                            end
                        end
                    end
                end
                if(isfield(cc,'moduleEnable')&&(cc.moduleEnable.fc_sigmoid))
                    hIR=dnnfpga.compiler.cnn5CosimIRFrontend.removeCustomLayerKind(hIR);
                else
                    hIR=dnnfpga.compiler.cnn5CosimIRFrontend.assignLayerKindSoft(hIR,'sigmoid');
                    isSigmoidHWLayer=false;
                end
            end









            if~isempty(processorConfig)&&validateTrimmableKernel
                processorConfig.validateNetworkForTrimmableKernels(hIR.ngraph,pvpairs.isestimator);
            end



            hIR.createSGraph(processorConfig,pvpairs.hardwarenormalization,pvpairs.verbose);




            dnnfpga.compiler.cnn5ProcessorFrontend.declareHWSWLayers(hIR,isSoftmaxHWLayer,isSigmoidHWLayer,pvpairs.verbose);


            dnnfpga.compiler.cnn5CosimIRFrontend.sanityChecks(hIR,net);




            if(status)&&~isempty(pvpairs.exponentdata)
                connections=dnnfpga.compiler.cnn5CosimIRFrontend.setConnections(hIR);
                [mapObjInputExp,mapObjOutputExp]=dnnfpga.compiler.mapLayerExponents(pvpairs.exponentdata,net);
                hIR=obj.populateExponentsForDagComponents(net,hIR,mapObjInputExp,mapObjOutputExp,connections);
            end
        end

        function hIR=populateExponentsForDagComponents(obj,net,hIR,mapObjInputExp,mapObjOutputExp,connections)%#ok<INUSL> 
            sortedComponents=hIR.sgraph.sortedComponents;
            listOfLayerNames=strings(numel(net.Layers),1);

            for i=1:numel(net.Layers)
                listOfLayerNames(i)=net.Layers(i).Name;
            end




            for i=numel(sortedComponents):-1:1
                thisComponent=sortedComponents(i);
                if(thisComponent.isInput)
                    hIR.sgraph.sortedComponents(i).inputExp=mapObjOutputExp(sortedComponents(connections{i}+1).nLayer(end).Name);
                elseif(thisComponent.numInputs>1)
                    for j=1:thisComponent.numInputs

                        inputComponent=thisComponent.inputs(j).net.driver.component;
                        if(~isempty(inputComponent.parentComponent))



                            inputLayerName=inputComponent.parentComponent;
                        else
                            inputLayerName=inputComponent.nLayer(end).Name;
                        end
                        hIR.sgraph.sortedComponents(i).inputExp(j)=mapObjOutputExp(inputLayerName);
                    end



                    getInput=strsplit(sortedComponents(i).name,'>>');
                    if(prod(size(getInput))==2)
                        hIR.sgraph.sortedComponents(i).outputExp=mapObjOutputExp(getInput{2});
                    elseif(~isempty(thisComponent.parentComponent))
                        outputLayerName=thisComponent.parentComponent;
                        hIR.sgraph.sortedComponents(i).outputExp=mapObjOutputExp(outputLayerName);
                    elseif(isempty(thisComponent.outputExp))




                        hIR.sgraph.sortedComponents(i).outputExp=mapObjOutputExp(sortedComponents(i).name);
                    end





                    if(dnnfpga.dagCompile.Layers.isDepthConcat(thisComponent.nLayer(end)))
                        inputs=[];
                        for pp=1:thisComponent.numInputs
                            inputComponent=thisComponent.inputs(pp).net.driver.component;
                            inputComponent.outputExp=thisComponent.outputExp;
                            hIR.sgraph.sortedComponents(i).inputs(pp).net.driver.component=inputComponent;
                        end
                    end

                    idx=find(listOfLayerNames==thisComponent.nLayer(1).Name);




                    if(thisComponent.hasKind('Relu'))
                        if(isa(thisComponent.nLayer(2),'nnet.cnn.layer.ReLULayer'))
                            hIR.sgraph.sortedComponents(i).reLUMode=1;
                            hIR.sgraph.sortedComponents(i).reLUExp=0;
                            hIR.sgraph.sortedComponents(i).reLUValue=0;
                        elseif(isa(thisComponent.nLayer(2),'nnet.cnn.layer.LeakyReLULayer'))
                            ExpScale=strcat(net.Layers(idx+1).Name,'_Parameter');
                            hIR.sgraph.sortedComponents(i).reLUMode=2;
                            hIR.sgraph.sortedComponents(i).reLUExp=mapObjInputExp(ExpScale);
                            hIR.sgraph.sortedComponents(i).reLUValue=net.Layers(idx+1).Scale;
                        elseif(isa(thisComponent.nLayer(2),'nnet.cnn.layer.ClippedReLULayer'))
                            ExpScale=strcat(net.Layers(idx+1).Name,'_Parameter');
                            hIR.sgraph.sortedComponents(i).reLUMode=3;
                            hIR.sgraph.sortedComponents(i).reLUExp=mapObjInputExp(ExpScale);
                            hIR.sgraph.sortedComponents(i).reLUValue=net.Layers(idx+1).Ceiling;
                        end
                    end

                elseif(thisComponent.isPrimary)
                    if(~sortedComponents(i+1).isPrimary)
                        hIR.sgraph.sortedComponents(i).outputExp=mapObjOutputExp(sortedComponents(connections{i}+1).nLayer(end).Name);
                    end
                end
            end
        end
    end
    methods(Static)
        function declareHWSWLayers(hIR,isSoftmaxHWLayer,isSigmoidHWLayer,verbose)

            function n=findLastEmptyLine(txt)
                sz=txt.lineCount();
                n=0;
                for j=1:sz
                    width=txt.getWidth(j);
                    if width==0
                        n=j;
                    end
                end
            end

            summary=evalc('hIR.network.Layers');
            txt=dnnfpga.tool.Text(summary);
            numLeading=findLastEmptyLine(txt);
            txt.trimLeadingLines(numLeading);
            txt.padRHS();






            for i=1:numel(hIR.network.Layers)
                layer=hIR.network.Layers(i);
                if(isa(layer,'nnet.cnn.layer.SoftmaxLayer'))
                    if(isSoftmaxHWLayer)
                        suffix="  (HW Layer)";
                    else
                        suffix="  (SW Layer)";
                    end
                elseif(isa(layer,'nnet.cnn.layer.SigmoidLayer'))
                    if(isSigmoidHWLayer)
                        suffix="  (HW Layer)";
                    else
                        suffix="  (SW Layer)";
                    end
                elseif dnnfpga.dagCompile.Layers.isSoft(layer)||...
                    dnnfpga.dagCompile.Layers.isInput(layer)
                    suffix="  (SW Layer)";
                else
                    suffix="  (HW Layer)";
                end

                txt.concatToLine(suffix,i,true);
            end
            defaultVerbose=1;
            dnnfpga.disp(message('dnnfpga:dnnfpgadisp:NetworkLayerListHeader'),defaultVerbose,verbose);
            if defaultVerbose<=verbose
                fprintf("%s",txt.text);
                fprintf("\n");
            end




            components=hIR.sgraph.components;
            for i=1:numel(components)
                if(components(i).hasKind(dnnfpga.dagCompile.LayerKind.Soft))


                    isInput=~isempty(components(i).nLayer)&&isa(components(i).nLayer,'nnet.cnn.layer.ImageInputLayer');
                    if(~isInput||~strcmpi(hIR.sgraph.hardwarenormalization,'done'))

                        msg=message('dnnfpga:dnnfpgadisp:SoftwareLayerNotice',components(i).nLayer.Name,class(components(i).nLayer));
                        dnnfpga.disp(msg,1,verbose);
                    end
                end
            end

        end
    end
end


