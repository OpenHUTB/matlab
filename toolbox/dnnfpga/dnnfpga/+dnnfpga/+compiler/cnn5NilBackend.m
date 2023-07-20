classdef cnn5NilBackend<dnnfpga.compiler.abstractDNNCompilerStage





    properties(Access=private)
    end

    methods(Access=public,Hidden=true)
        function obj=cnn5NilBackend()
            obj@dnnfpga.compiler.abstractDNNCompilerStage();
        end
    end

    methods(Access=public)
        function output=doit(~,hIR,cnnp,varargin)

            p=inputParser;
            addParameter(p,'InputFrameNumberLimit',30,@isnumeric);
            addParameter(p,'exponentData',[]);
            addParameter(p,'ProcessorConfig',[]);
            addParameter(p,'Verbose',1);
            parse(p,varargin{:});
            exponentsData=p.Results.exponentData;
            verbose=p.Results.Verbose;

            [~,isQuantized]=dnnfpga.compiler.processorKernelType(cnnp);

            index=1;
            sortedComponents=hIR.sgraph.sortedComponents;

            connections=dnnfpga.compiler.cnn5CosimIRFrontend.setConnections(hIR);









            if isQuantized
                firstHWComp=3;
            else
                firstHWComp=2;
            end
            replaceIdx=cellfun(@(c)any(c(:)==firstHWComp),connections);
            connections(replaceIdx)={1};

            output={};

            for i=1:numel(sortedComponents)
                component=sortedComponents(i);
                if dnnfpga.dagCompile.SeriesCompiler.canCreateSeriesNetwork(component)

                    sn=dnnfpga.dagCompile.SeriesCompiler.createSeriesNework(component);

                    if(isQuantized)


                        prevIndex=connections{index};


                        if~prevIndex
                            prevIndex=1;
                        end


                        inputComponent=sortedComponents(prevIndex(1));
                        layers=[imageInputLayer([sn.Layers(1).InputSize],'Normalization','none','Name',inputComponent.nLayer(end).Name)
                        sn.Layers(2:end)];
                        sn=assembleNetwork(layers);
                    end

                    sn=dnnfpga.compiler.optimizations.optimizeNetwork(sn,verbose);


                    hasUnpool=component.hasKind(dnnfpga.dagCompile.LayerKind.Unpool);
                    hasTransposedConv=component.hasKind(dnnfpga.dagCompile.LayerKind.TransposedConv);


                    if hasUnpool
                        unpoolRemainder=component.outputs.net.size(1:2)-component.inputs(1).net.size(1:2).*component.nLayer.FilterSize;
                        unpoolRemainder=unpoolRemainder.';
                    else
                        unpoolRemainder=[0;0];
                    end


                    maxpoolType=0;
                    if component.hasKind(dnnfpga.dagCompile.LayerKind.MaxpoolIndex)
                        maxpoolType=1;
                    elseif component.hasKind(dnnfpga.dagCompile.LayerKind.MaxpoolData)
                        maxpoolType=2;
                    end

                    argins={...
                    'LegLevel',true,...
                    'hasTrueOutputLayer',false,...
                    'hasTrueInputLayer',false,...
                    'hasUnpool',hasUnpool,...
                    'hasTransposedConv',hasTransposedConv,...
                    'unpoolRemainder',unpoolRemainder,...
                    'maxpoolType',maxpoolType,...
                    'Verbose',verbose};

                    if isQuantized
                        argins=[argins,{'exponentData',exponentsData}];
                    end






                    parentDataFormat=component.inputs(1).net.dataFormat;
                    argins=[argins,{'ParentDataFormat',parentDataFormat}];

                    output{index}=dnnfpga.compiler.codegenSN2TPEstIR(sn,cnnp,argins{:});
                    index=index+1;

                elseif component.hasKind(dnnfpga.dagCompile.LayerKind.Add)||...
                    component.hasKind(dnnfpga.dagCompile.LayerKind.CustomLayer)
                    layer=component.nLayer(1);
                    lclass=class(layer);
                    switch lclass
                    case{'nnet.cnn.layer.AdditionLayer',...
                        'nnet.internal.cnn.coder.MultiplicationLayer',...
                        'nnet.cnn.layer.SigmoidLayer',...
                        'nnet.cnn.layer.TanhLayer',...
                        'dnnfpga.layer.ExponentialLayer',...
                        'dnnfpga.layer.identityLayer'}

                        cc=cnnp.getCC;
                        dataTransNum=cc.dataTransNum;
                        inputBurstLength=cc.addp.inputBurstLength;
                        outputBurstLength=cc.addp.inputBurstLength;


                        adderSize=prod(hIR.ddrSupport.normalizeSize(component.inputs(1).net.size,component.inputs(1).net.dataFormat));


                        param.type='FPGA_Adder';
                        param.processor=cnnp;
                        param.phase=component.nLayer(1).Name;
                        param.layerClass=lclass;
                        param.adderSize=adderSize;
                        param.inputBurstNum=ceil(adderSize/(inputBurstLength*dataTransNum));
                        param.outputBurstNum=ceil(adderSize/(outputBurstLength*dataTransNum));
                        param.params={param};

                        output{index}={param};%#ok<AGROW> 
                        index=index+1;
                    case{'dnnfpga.custom.Resize2DLayer'}

                        cc=cnnp.getCC;
                        dataTransNum=cc.dataTransNum;
                        inputBurstLength=cc.addp.inputBurstLength;
                        outputBurstLength=cc.addp.inputBurstLength;


                        inputSize=prod(hIR.ddrSupport.normalizeSize(component.inputs(1).net.size,component.inputs(1).net.dataFormat));
                        outputSize=prod(hIR.ddrSupport.normalizeSize(component.outputs(1).net.size,component.inputs(1).net.dataFormat));


                        param.type='FPGA_Adder';
                        param.processor=cnnp;
                        param.phase=component.nLayer(1).Name;
                        param.layerClass=lclass;
                        param.inputSize=inputSize;
                        param.outputSize=outputSize;
                        param.inputBurstNum=ceil(inputSize/(inputBurstLength*dataTransNum));
                        param.outputBurstNum=ceil(outputSize/(outputBurstLength*dataTransNum));



                        param.LayerInput=component.inputs(1).net.size;
                        param.Scale=double(component.nLayer.Scale);

                        param.params={param};

                        output{index}={param};%#ok<AGROW> 
                        index=index+1;
                    otherwise


                        msg=message('dnnfpga:customLayer:UnableEstimatePerformance',component.nLayer(1).Name);
                        warning(msg);
                    end
                else
                    index=index+1;
                end
            end
        end
    end
end


