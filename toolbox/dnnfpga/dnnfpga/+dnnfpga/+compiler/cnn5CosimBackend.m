classdef cnn5CosimBackend<dnnfpga.compiler.abstractDNNCompilerStage





    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=cnn5CosimBackend()
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end


    methods(Access=public)

        function[deployableNW,connections]=doit(this,hIR,input,connections,processor,varargin)








            p=inputParser;
            addParameter(p,'LegLevel',false,@(x)islogical(x));
            parse(p,varargin{:});
            legLevel=p.Results.LegLevel;

            deployableNWArray=this.constructDeployableNetwork(hIR,input,connections,processor,varargin{:});
            deployableNW=deployableNWArray;
        end

    end

    methods(Access=protected)
        function[deployableNWArray]=constructDeployableNetwork(this,hIR,input,connections,cnnp,varargin)
            index=1;
            pvpairs=dnnfpga.compiler.cnn5CosimIRFrontend.parse_params(input.argin);

            if(isfield(pvpairs,'processordatatype'))
                dataType=pvpairs.processordatatype;
            else
                dataType='single';
            end

            if(isfield(pvpairs,'exponentdata'))
                expData=pvpairs.exponentdata;
            else
                expData=[];
            end

            validQuantDataTypes={'int4','int8'};
            isQuantDatatype=any(strcmpi(dataType,validQuantDataTypes));


            sortedComponents=hIR.sgraph.sortedComponents;
            for i=1:numel(sortedComponents)
                component=sortedComponents(i);
                if component.isJoin
                    legLevelDeployableNW(index)=this.constructLegLevelDeployableNetwork(component,cnnp);
                    index=index+1;
                elseif dnnfpga.dagCompile.SeriesCompiler.canCreateSeriesNetwork(component)
                    fprintf('Compiling leg: %s ...\n',component.name);
                    inputComponent=sortedComponents(connections{index});
                    sn=dnnfpga.dagCompile.SeriesCompiler.createSeriesNework(component);
                    layers=[imageInputLayer([sn.Layers(1).InputSize],'Normalization','none','Name',inputComponent.nLayer(end).Name)
                    sn.Layers(2:end)];
                    sn=assembleNetwork(layers);
                    sn=dnnfpga.compiler.optimizations.optimizeNetwork(sn);
                    strOutput=evalc('disp(sn.Layers)');
                    if component.hasKind(dnnfpga.dagCompile.LayerKind.MaxpoolIndex)
                        maxpoolType=1;
                    else
                        maxpoolType=0;
                    end
                    hasTransposedConv=component.hasKind(dnnfpga.dagCompile.LayerKind.TransposedConv);






                    if(isQuantDatatype)
                        if(~isempty(component.outputExp))
                            for pp=1:numel(expData)
                                if(strcmpi(expData(pp).Name,component.nLayer(end).Name))
                                    expData(pp).Exponent=component.outputExp;
                                    break;
                                end
                            end
                        end
                        legLevelDeployableNW(index)=dnnfpga.compiler.codegenSN2Cosim(sn,cnnp,'exponentData',expData,'LegLevel',true,'hasTrueOutputLayer',false,'hasTrueInputLayer',false,'maxpoolType',maxpoolType,'hasTransposedConv',hasTransposedConv,'processorDataType',dataType);
                    else
                        legLevelDeployableNW(index)=dnnfpga.compiler.codegenSN2Cosim(sn,cnnp,'LegLevel',true,'hasTrueOutputLayer',false,'hasTrueInputLayer',false,'maxpoolType',maxpoolType,'hasTransposedConv',hasTransposedConv,'processorDataType',dataType);
                    end
                    index=index+1;
                    fprintf('Compiling leg: %s ... complete.\n',component.name);
                elseif component.isInput
                    layers=[component.nLayer
                    regressionLayer('Name',strcat('out_',component.name))];
                    imageNetwork=assembleNetwork(layers);
                    sn=dnnfpga.compiler.optimizations.optimizeNetwork(imageNetwork);
                    if(isQuantDatatype)
                        legLevelDeployableNW(index)=dnnfpga.compiler.codegenSN2Cosim(sn,cnnp,'exponentData',expData,'LegLevel',true,'hasTrueOutputLayer',false,'hasTrueInputLayer',true,'processorDataType',dataType);
                    else
                        legLevelDeployableNW(index)=dnnfpga.compiler.codegenSN2Cosim(sn,cnnp,'LegLevel',true,'hasTrueOutputLayer',false,'hasTrueInputLayer',true,'processorDataType',dataType);
                    end
                    index=index+1;
                elseif(component.isOutput)

                    inputComponent=sortedComponents(connections{index});












                    if(isa((component.nLayer),'nnet.cnn.layer.ClassificationOutputLayer')||...
                        isa((component.nLayer),'nnet.cnn.layer.YOLOv2OutputLayer')||...
                        isa((component.nLayer),'nnet.cnn.layer.PixelClassificationLayer')||...
                        isa(sortedComponents(index).nLayer(end),'nnet.cnn.layer.SigmoidLayer')||...
                        isa(sortedComponents(index).nLayer(end),'dnnfpga.layer.ExponentialLayer'))||...
                        (isa(component.nLayer,'nnet.cnn.layer.RegressionOutputLayer')&&isa(sortedComponents(index).nLayer(end),'nnet.cnn.layer.SoftmaxLayer'))
                        layers=[imageInputLayer([component.inputs(1).size],'Name',inputComponent.nLayer(end).Name,'Normalization','none')...
                        ,sortedComponents(index).nLayer...
                        ,component.nLayer];
                    else
                        layers=[imageInputLayer([component.inputs(1).size],'Name',inputComponent.nLayer(end).Name,'Normalization','none')...
                        ,component.nLayer];
                    end
                    imageNetwork=assembleNetwork(layers);
                    sn=dnnfpga.compiler.optimizations.optimizeNetwork(imageNetwork);
                    if(isQuantDatatype)
                        legLevelDeployableNW(index)=dnnfpga.compiler.codegenSN2Cosim(sn,cnnp,'exponentData',expData,'LegLevel',true,'hasTrueOutputLayer',true,'hasTrueInputLayer',false,'processorDataType',dataType);
                    else
                        legLevelDeployableNW(index)=dnnfpga.compiler.codegenSN2Cosim(sn,cnnp,'LegLevel',true,'hasTrueOutputLayer',true,'hasTrueInputLayer',false,'processorDataType',dataType);
                    end
                    index=index+1;
                elseif isa(component.nLayer,'dnnfpga.custom.Resize2DLayer')
                    legLevelDeployableNW(index)=this.constructLegLevelDeployableNetwork(component,cnnp);
                    index=index+1;
                else


                end
            end
            deployableNWArray=legLevelDeployableNW;
        end

        function deployableNW=constructLegLevelDeployableNetwork(this,component,cnnp)
            layers={};
            if(dnnfpga.dagCompile.Layers.isAdd(component.nLayer(1)))
                foo=@(input)(cnnp.getAddProcessor().MLEmulationAddLayer(component,input,cnnp));
                inputSize=[component.inputs(1).net.size];
                layers{end+1}=dnnfpga.deployablenetwork.swLayerDAG(component,inputSize,foo);
            elseif(dnnfpga.dagCompile.Layers.isDepthConcat(component.nLayer))
                foo=@(input)(this.MLEmulationDepthConcatLayer(component,input));


                inputSize{1}=[component.inputs(1).net.size];
                inputSize{2}=[component.inputs(2).net.size];
                layers{end+1}=dnnfpga.deployablenetwork.swLayerDAG(component,inputSize,foo);
            elseif component.hasKind(dnnfpga.dagCompile.LayerKind.Unpool)
                inputSize=[component.inputs(1).net.size];
                outputSize=component.outputs.net.size;
                foo=@(input)(dnnfpga.processorbase.processorUtils.Unpool([],input,outputSize));
                layers{end+1}=dnnfpga.deployablenetwork.swLayerDAG(component,inputSize,foo);
            elseif isa(component.nLayer,'dnnfpga.custom.Resize2DLayer')
                foo=@(input)(this.MLEmulationResize2DLayer(component,input));
                inputSize=[component.inputs(1).net.size];
                layers{end+1}=dnnfpga.deployablenetwork.swLayerDAG(component,inputSize,foo);
            end
            deployableNW=dnnfpga.deployablenetwork.deployableNetwork(layers);
        end

        function result=MLEmulationDepthConcatLayer(this,component,input)
            numInputs=component.numInputs;
            result=[];
            for i=1:numInputs

                inputSize=[component.inputs(i).net.size];



                input{i}=input{i}(1:prod(inputSize));
                input{i}=reshape(input{i},inputSize);


                result=cat(3,result,input{i});
            end

        end

        function result=MLEmulationResize2DLayer(~,component,input)

            ipsz=size(input);
            if numel(ipsz)==3
                X=dlarray(input,'SSC');
            elseif numel(ipsz)==4
                X=dlarray(input,'SSCB');
            end


            Z=component.nLayer.predict(X);


            result=extractdata(Z);
        end

    end

end



