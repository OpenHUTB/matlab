classdef cnn5CosimIRFrontend<dnnfpga.compiler.abstractDNNCompilerStage




    properties(Access=private)
        InstrumentationDataFilePath=[];
    end

    methods(Access=public,Hidden=true)
        function obj=cnn5CosimIRFrontend(varargin)
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
            if~isempty(varargin)
                obj.InstrumentationDataFilePath=varargin{1};
            end
        end
    end

    methods(Access=public)
        function[output,connections]=doit(~,input,processor,varargin)


            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'Verbose',1);
            addParameter(p,'ProcessorConfig',[]);


            parse(p,varargin{:});

            net=input.net;
            argin=input.argin;
            added=horzcat(argin,{'Verbose',p.Results.Verbose,'ProcessorConfig',p.Results.ProcessorConfig});
            [output,connections]=dnnfpga.compiler.cnn5CosimIRFrontend.dagNetworkIR(net,processor,added{:});
        end
    end

    methods(Access=public,Static=true)

        function[hIR,connections]=dagNetworkIR(input,cnnp,varargin)
            net=input;




            dnnfpga.compiler.validateSegmentationLayers(cnnp,net);


            net=dnnfpga.compiler.wrapResize2DLayers(net,cnnp);

            net=dnnfpga.compiler.optimizations.optimizeNetwork(net);


            hIR=dnnfpga.dagCompile.DLNetworkIR(net,net,cnnp);

            params=varargin(1:end);
            pvpairs=dnnfpga.compiler.cnn5CosimIRFrontend.parse_params(params);

            processorConfig=pvpairs.processorconfig;
            hIR.createNGraph(processorConfig);


            hIR=dnnfpga.compiler.cnn5CosimIRFrontend.assignLayerKindSoft(hIR,'softmax');
            hIR=dnnfpga.compiler.cnn5CosimIRFrontend.assignLayerKindSoft(hIR,'sigmoid');
            hIR=dnnfpga.compiler.cnn5CosimIRFrontend.assignLayerKindSoft(hIR,'exponential');

            hIR.createSGraph([],'off',pvpairs.verbose);
            dnnfpga.compiler.cnn5CosimIRFrontend.sanityChecks(hIR,net);


            dataType=dnnfpga.compiler.processorKernelType(cnnp);

            connections=dnnfpga.compiler.cnn5CosimIRFrontend.setConnections(hIR);

            if(strcmpi(dataType.dataTypeConv,'int8'))
                [mapObjInputExp,mapObjOutputExp]=dnnfpga.compiler.mapLayerExponents(pvpairs.exponentdata,net);

                hIR=dnnfpga.compiler.cnn5CosimIRFrontend.populateExponentsForDagComponents(...
                net,dataType,hIR,mapObjOutputExp,mapObjInputExp,connections);
            else


                hIR=dnnfpga.compiler.cnn5CosimIRFrontend.adderReluParameters(net,hIR);
            end
        end



        function pvpairs=parse_params(params)

            pvpairs=struct();
            assert(mod(length(params),2)==0);


            validParams={'hastrueoutputlayer',...
            'hastrueinputlayer',...
            'maxpooltype',...
            'exponentdata',...
            'verbose',...
            'hastransposedconv',...
            'processordatatype',...
            'processorconfig',...
'issimulator'
            };

            for i=1:2:length(params)
                param=lower(params{i});
                if(~contains(validParams,param))
                    error(message('gpucoder:cnncodegen:invalid_parameter'));
                end
                value=params{i+1};

                pvpairs.(param)=value;
            end
        end

        function connections=setConnections(hIR)
            index=1;

            sortedComponents=hIR.sgraph.sortedComponents;
            for i=1:numel(sortedComponents)
                component=sortedComponents(i);
                connections{index}=dnnfpga.compiler.cnn5CosimIRFrontend.getConnections(component,sortedComponents,index);
                index=index+1;
            end
        end

        function inputIndices=getConnections(component,sortedComponents,index)

            inputIndices=[];
            if(component.numInputs)
                for i=1:component.numInputs
                    if(component.isOutput)

                        inputIndices=index-1;
                    else


                        for j=1:index


                            for k=1:numel(sortedComponents(j).outputs)
                                if(strcmp(sortedComponents(j).outputs(k).net.name,component.inputs(i).net.name))
                                    if(isempty(inputIndices))
                                        inputIndices=j;
                                    else
                                        inputIndices=cat(2,inputIndices,j);
                                    end
                                end
                            end
                        end
                    end
                end
            else

                inputIndices=0;
            end
        end

        function hIR=populateExponentsForDagComponents(net,dataType,hIR,mapObjOutputExp,mapObjInputExp,connections)
            sortedComponents=hIR.sgraph.sortedComponents;
            listOfLayerNames=strings(numel(net.Layers),1);

            for i=1:numel(net.Layers)
                listOfLayerNames(i)=net.Layers(i).Name;
            end




            for i=numel(sortedComponents):-1:1
                if(strcmpi(dataType.dataTypeConv,'int8'))

                    thisComponent=sortedComponents(i);

                    if(thisComponent.numInputs>1)

                        for j=1:thisComponent.numInputs



                            inputComponent=thisComponent.inputs(j).net.driver.component;
                            if(~isempty(inputComponent.parentComponent))



                                inputLayerName=inputComponent.parentComponent;
                            else
                                inputLayerName=inputComponent.nLayer(end).Name;
                            end
                            hIR.sgraph.sortedComponents(i).inputExp(j)=mapObjOutputExp(inputLayerName);
                        end


                        if(~isempty(thisComponent.parentComponent))
                            outputLayerName=thisComponent.parentComponent;
                        else
                            idx=find(listOfLayerNames==thisComponent.nLayer(1).Name);
                            outputLayerName=listOfLayerNames(idx);
                        end




                        if(isempty(thisComponent.outputExp))
                            hIR.sgraph.sortedComponents(i).outputExp=mapObjOutputExp(outputLayerName);
                        end





                        if(dnnfpga.dagCompile.Layers.isDepthConcat(thisComponent.nLayer(end)))
                            inputs=[];
                            for pp=1:thisComponent.numInputs
                                inputComponent=thisComponent.inputs(pp).net.driver.component;
                                inputComponent.outputExp=thisComponent.outputExp;
                                hIR.sgraph.sortedComponents(i).inputs(pp).net.driver.component=inputComponent;
                            end
                        end



                        if(thisComponent.hasKind('Relu'))
                            if(isa(thisComponent.nLayer(2),'nnet.cnn.layer.ReLULayer'))
                                hIR.sgraph.sortedComponents(i).reLUMode=1;
                                hIR.sgraph.sortedComponents(i).reLUExp=0;
                                hIR.sgraph.sortedComponents(i).reLUValue=0;
                                hIR.sgraph.sortedComponents(i).outputExp=mapObjOutputExp(net.Layers(idx+1).Name);
                            elseif(isa(thisComponent.nLayer(2),'nnet.cnn.layer.LeakyReLULayer'))
                                ExpScale=strcat(net.Layers(idx+1).Name,'_Parameter');
                                hIR.sgraph.sortedComponents(i).reLUMode=2;
                                hIR.sgraph.sortedComponents(i).reLUExp=mapObjInputExp(ExpScale);
                                hIR.sgraph.sortedComponents(i).reLUValue=net.Layers(idx+1).Scale;
                                hIR.sgraph.sortedComponents(i).outputExp=mapObjOutputExp(net.Layers(idx+1).Name);
                            elseif(isa(thisComponent.nLayer(2),'nnet.cnn.layer.ClippedReLULayer'))
                                ExpScale=strcat(net.Layers(idx+1).Name,'_Parameter');
                                hIR.sgraph.sortedComponents(i).reLUMode=3;
                                hIR.sgraph.sortedComponents(i).reLUExp=mapObjInputExp(ExpScale);
                                hIR.sgraph.sortedComponents(i).reLUValue=net.Layers(idx+1).Ceiling;
                                hIR.sgraph.sortedComponents(i).outputExp=mapObjOutputExp(net.Layers(idx+1).Name);
                            end
                        end
                    end
                end
            end
        end


        function hIR=adderReluParameters(net,hIR)
            sortedComponents=hIR.sgraph.sortedComponents;
            str=strings(numel(net.Layers),1);

            for i=1:numel(net.Layers)
                str(i)=net.Layers(i).Name;
            end
            for i=1:numel(sortedComponents)
                if(sortedComponents(i).numInputs>1)
                    idx=find(str==sortedComponents(i).nLayer(1).Name);
                    if(sortedComponents(i).hasKind('Relu'))
                        if(isa(sortedComponents(i).nLayer(2),'nnet.cnn.layer.ReLULayer'))
                            sortedComponents(i).reLUMode=1;
                            sortedComponents(i).reLUValue=0;
                        elseif(isa(sortedComponents(i).nLayer(2),'nnet.cnn.layer.LeakyReLULayer'))
                            sortedComponents(i).reLUMode=2;
                            sortedComponents(i).reLUValue=net.Layers(idx+1).Scale;
                        elseif(isa(sortedComponents(i).nLayer(2),'nnet.cnn.layer.ClippedReLULayer'))
                            sortedComponents(i).reLUMode=3;
                            sortedComponents(i).reLUValue=net.Layers(idx+1).Ceiling;
                        end
                    end
                end
            end
        end

        function sanityChecks(hIR,net)
            sortedComponents=hIR.sgraph.sortedComponents;

            for i=1:numel(sortedComponents)
                if(numel(sortedComponents(i).nLayer)==1)
                    if(isa(sortedComponents(i).nLayer,'nnet.cnn.layer.LeakyReLULayer')||...
                        isa(sortedComponents(i).nLayer,'nnet.cnn.layer.ReLULayer')||...
                        isa(sortedComponents(i).nLayer,'nnet.cnn.layer.ClippedReLULayer'))
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedStandaloneLayer',class(sortedComponents(i).nLayer));
                        error(msg);
                    end
                end
            end


            layers=net.Layers;
            for j=1:numel(layers)




                if(isa(layers(j),'nnet.cnn.layer.AdditionLayer')&&j<numel(layers))
                    if(isa(layers(j+1),'nnet.cnn.layer.SoftmaxLayer'))
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',layers(j+1).Name,class(layers(j)),class(layers(j+1)));
                        error(msg);
                    end
                end




                if(isa(layers(j),'nnet.cnn.layer.DepthConcatenationLayer')&&j<numel(layers)&&isa(layers(j+1),'nnet.cnn.layer.SoftmaxLayer'))
                    msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSequence',layers(j+1).Name,class(layers(j)),class(layers(j+1)));
                    error(msg);
                end



                if(isa(layers(j),'nnet.cnn.layer.FullyConnectedLayer')&&isa(layers(j-1),'nnet.cnn.layer.GlobalAveragePooling2DLayer'))
                    inputSize=layers(j).InputSize;
                    outputSize=layers(j).OutputSize;
                    if((inputSize>=57&&inputSize<=64)&&(outputSize>=993&&outputSize<=1008))
                        msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayerSize',layers(j).Name,class(layers(j-1)));
                        error(msg);
                    end
                end

            end

        end

        function hIR=assignCustomLayerKindForSigmoidLayer(hIR,processor)

            components=hIR.ngraph.components;

            for i=1:numel(components)
                component=components(i);
                if(any(component.layerKinds==dnnfpga.dagCompile.LayerKind.CustomLayer)&&...
                    any(component.layerKinds==dnnfpga.dagCompile.LayerKind.FC))
                    if(strcmpi(class(component.nLayer),'nnet.cnn.layer.SigmoidLayer'))
                        component.layerKinds=component.layerKinds(component.layerKinds~=dnnfpga.dagCompile.LayerKind.FC);
                        hIR.ngraph.components(i)=component;
                    end
                end
            end
        end

        function hIR=assignLayerKindSoft(hIR,blockName)



            components=hIR.ngraph.components;
            if(strcmpi(blockName,'softmax'))
                for i=1:numel(components)
                    component=components(i);



                    if(strcmpi(class(component.nLayer),'nnet.cnn.layer.SoftmaxLayer'))
                        component.layerKinds=dnnfpga.dagCompile.LayerKind.Soft;
                        hIR.ngraph.components(i)=component;
                    end
                end
            end

            if(strcmpi(blockName,'sigmoid'))
                for i=1:numel(components)
                    component=components(i);



                    if(strcmpi(class(component.nLayer),'nnet.cnn.layer.SigmoidLayer'))
                        component.layerKinds=dnnfpga.dagCompile.LayerKind.Soft;
                        hIR.ngraph.components(i)=component;
                    end
                end
            end

            if(strcmpi(blockName,'exponential'))
                for i=1:numel(components)
                    component=components(i);



                    if(strcmpi(class(component.nLayer),'dnnfpga.layer.ExponentialLayer'))
                        component.layerKinds=dnnfpga.dagCompile.LayerKind.Soft;
                        hIR.ngraph.components(i)=component;
                    end
                end
            end
        end

        function hIR=removeCustomLayerKind(hIR)

            components=hIR.ngraph.components;
            for i=1:numel(components)
                component=components(i);



                if(strcmpi(class(component.nLayer),'nnet.cnn.layer.SigmoidLayer'))
                    component.layerKinds(component.layerKinds==dnnfpga.dagCompile.LayerKind.CustomLayer)=[];
                    hIR.ngraph.components(i)=component;
                end
            end
        end

    end
end





