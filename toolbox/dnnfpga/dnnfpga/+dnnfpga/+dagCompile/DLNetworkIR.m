classdef DLNetworkIR<handle







    properties
network
networkForDLP
Processor
ngraph
sgraph
meSupport
scheduler
ddrSupport
inputs
outputs
activations
values
states
isRNN
    end

    properties(Access=protected)
        Verbose=1;
    end

    methods


        function obj=DLNetworkIR(network,networkForDLP,processor,verbose)

            if nargin<4
                verbose=1;
            end

            obj.network=network;
            obj.networkForDLP=networkForDLP;
            obj.Processor=processor;
            obj.Verbose=verbose;
            obj.isRNN=dnnfpga.dagCompile.Utils.isRNN(network);
        end


        function createNGraph(obj,processorConfig,activationLayer)
            if nargin<2

                processorConfig=[];
            end
            if nargin<3

                activationLayer=[];
            end

            obj.ngraph=dnnfpga.dagCompile.NGraph(obj.networkForDLP,obj.Processor,activationLayer,processorConfig);
        end


        function createSGraph(obj,processorConfig,hardwareNormalization,verbose)
            obj.sgraph=dnnfpga.dagCompile.SGraph(obj.ngraph,2,processorConfig,hardwareNormalization,verbose);
        end

        function createDDRSupport(obj,processor,varargin)
            obj.ddrSupport=dnnfpga.dagCompile.DDRSupport(processor,obj.sgraph,varargin{:});
            obj.ddrSupport.allocateMemory();
            obj.ddrSupport.createMemoryRegions(obj.Verbose);
            obj.addInputDataDescriptors();
            obj.addOutputDataDescriptors();
            obj.addActivationDataDescriptors();
            obj.addValueDataDescriptors();
            obj.addStateDataDescriptors();
        end


        function createScheduler(obj,data,hPC,varargin)
            obj.scheduler=dnnfpga.dagCompile.Scheduler(obj,hPC);
            obj.scheduler.createSchedule(data,obj.Verbose,varargin{:});
            obj.scheduler.createTable(obj.Verbose);
        end


        function ws=emitSchedulerTable(obj)
            wss=obj.scheduler.emitSchedule(obj.Verbose);
            wst=obj.scheduler.emitTable(obj.Verbose);
            ws=[wss,wst];
        end


        function payloads=createSchedulerRegPayloads(obj)
            cc=obj.Processor.getCC();
            regAddressMap=cc.schedulerRegMap;
            payloads=[];


            frameBufferCount=uint32(obj.ddrSupport.inputFrameNumberLimit);
            label='frameBufferCount';
            address=uint32(regAddressMap(label));
            payload=obj.scheduler.types.defaultValue('RegPayload');
            payload.value=frameBufferCount;
            payload.addr=address;
            payloads=[payloads,payload];


            inputBaseAddr=uint32(obj.ddrSupport.hDDROffsetMap('InputDataOffset'));
            label='inputBaseAddr';
            address=uint32(regAddressMap(label));
            payload=obj.scheduler.types.defaultValue('RegPayload');
            payload.value=inputBaseAddr;
            payload.addr=address;
            payloads=[payloads,payload];


            outputBaseAddr=uint32(obj.ddrSupport.hDDROffsetMap('OutputResultOffset'));
            label='outputBaseAddr';
            address=uint32(regAddressMap(label));
            payload=obj.scheduler.types.defaultValue('RegPayload');
            payload.value=outputBaseAddr;
            payload.addr=address;
            payloads=[payloads,payload];


            inputSize=0;
            for i=1:numel(obj.inputs)
                desc=obj.inputs(i);
                inputSize=inputSize+desc.getSizeInBytes();
            end
            payload=obj.scheduler.types.defaultValue('RegPayload');
            label='inputSize';
            address=uint32(regAddressMap(label));
            payload.value=inputSize;
            payload.addr=address;
            payloads=[payloads,payload];

            outputSize=0;
            for i=1:numel(obj.outputs)
                desc=obj.outputs(i);
                outputSize=outputSize+desc.getSizeInBytes();
            end
            payload=obj.scheduler.types.defaultValue('RegPayload');
            label='outputSize';
            address=uint32(regAddressMap(label));
            payload.value=outputSize;
            payload.addr=address;
            payloads=[payloads,payload];
        end


        function pos=getInputPosition(obj,name)
            pos=0;
            iplist=obj.sgraph.getSortedInputComponents;
            if numel(iplist)==1
                singleInput=true;
            else
                singleInput=false;
            end

            if(singleInput)
                pos=1;
            else




                for i=1:numel(iplist)
                    input=iplist{i}.name;
                    if strcmpi(name,input)
                        pos=uint32(i);
                        break;
                    end
                end
            end

        end



        function addActivationDataDescriptors(obj)
            import dnnfpga.dagCompile.*
            activationDescriptors=[];
            if isa(obj.network,'DAGNetwork')||isa(obj.network,'SeriesNetwork')||isa(obj.network,'dlnetwork')
                if obj.ddrSupport.uniqueActivations
                    dataTransNum=obj.ddrSupport.dataTransNum;
                    bytesPerData=obj.ddrSupport.bytesPerData;
                    convThreadNum=obj.ddrSupport.convThreadNum;
                    fcThreadNum=obj.ddrSupport.fcThreadNum;
                    for j=1:numel(obj.sgraph.components)
                        component=obj.sgraph.components(j);
                        if component.hasKind(LayerKind.Label)
                            for pinst=component.inputs'
                                net=pinst.net;
                                mr=obj.ddrSupport.memoryRegions(net.id);
                                d=dnnfpga.dagCompile.DataDescriptor(component.name,net,mr,dataTransNum,bytesPerData,convThreadNum,fcThreadNum);
                                activationDescriptors=[activationDescriptors,d];
                            end
                        else
                            for pinst=component.outputs'
                                net=pinst.net;
                                mr=obj.ddrSupport.memoryRegions(net.id);
                                d=dnnfpga.dagCompile.DataDescriptor(component.name,net,mr,dataTransNum,bytesPerData,convThreadNum,fcThreadNum);
                                activationDescriptors=[activationDescriptors,d];
                            end
                        end
                    end
                end
            end
            obj.activations=activationDescriptors;
        end



        function pos=getOutputPosition(obj,name)
            pos=0;

            oplist=obj.sgraph.getSortedOutputComponents;
            if numel(oplist)==1
                singleOutput=true;
            else
                singleOutput=false;
            end

            if singleOutput
                pos=1;
            else
                total=numel(obj.network.OutputNames);
                for i=1:total
                    output=obj.network.OutputNames(i);
                    if strcmp(name,output)
                        pos=uint32(i);
                        break;
                    end
                end
            end
        end

        function addOutputDataDescriptors(obj)
            outputDescriptors=[];
            if isa(obj.network,'DAGNetwork')||isa(obj.network,'SeriesNetwork')||isa(obj.network,'dlnetwork')
                dataTransNum=obj.ddrSupport.dataTransNum;
                bytesPerData=obj.ddrSupport.bytesPerData;
                convThreadNum=obj.ddrSupport.convThreadNum;
                fcThreadNum=obj.ddrSupport.fcThreadNum;





                for i=1:numel(obj.ngraph.getOutputComponents)
                    outputName=obj.ngraph.getOutputComponents{i}.name;



                    try
                        component=obj.sgraph.getComponent(outputName);
                        pinst=component.inputs(1);
                        net=pinst.net;
                        mr=obj.ddrSupport.memoryRegions(net.id);
                        d=dnnfpga.dagCompile.DataDescriptor(outputName,net,mr,dataTransNum,bytesPerData,convThreadNum,fcThreadNum);
                        outputDescriptors=[outputDescriptors,d];
                    catch
                    end
                end
            end
            obj.outputs=outputDescriptors;
        end

        function addInputDataDescriptors(obj)
            inputDescriptors=[];
            if isa(obj.network,'DAGNetwork')||isa(obj.network,'SeriesNetwork')||isa(obj.network,'dlnetwork')
                dataTransNum=obj.ddrSupport.dataTransNum;
                convThreadNum=obj.ddrSupport.convThreadNum;
                fcThreadNum=obj.ddrSupport.fcThreadNum;
                bytesPerData=obj.ddrSupport.bytesPerData;



                for i=1:numel(obj.sgraph.getInputComponentList)
                    inputName=obj.sgraph.getInputComponentList{i}.name;
                    component=obj.sgraph.getComponent(inputName);
                    pinst=component.outputs(1);
                    net=pinst.net;
                    mr=obj.ddrSupport.memoryRegions(net.id);
                    d=dnnfpga.dagCompile.DataDescriptor(inputName,net,mr,dataTransNum,bytesPerData,convThreadNum,fcThreadNum);
                    inputDescriptors=[inputDescriptors,d];
                end
            end
            obj.inputs=inputDescriptors;
        end

        function addStateDataDescriptors(obj)
            import dnnfpga.dagCompile.*
            stateDescriptors=[];
            if isa(obj.network,'DAGNetwork')||isa(obj.network,'SeriesNetwork')||isa(obj.network,'dlnetwork')
                dataTransNum=obj.ddrSupport.dataTransNum;
                convThreadNum=obj.ddrSupport.convThreadNum;
                fcThreadNum=obj.ddrSupport.fcThreadNum;
                bytesPerData=obj.ddrSupport.bytesPerData;
                for component=obj.sgraph.components'
                    if component.hasKind(LayerKind.State)
                        stateName=component.name;
                        pinst=component.outputs(1);
                        net=pinst.net;
                        mr=obj.ddrSupport.memoryRegions(net.id);
                        d=dnnfpga.dagCompile.DataDescriptor(stateName,net,mr,dataTransNum,bytesPerData,convThreadNum,fcThreadNum);
                        stateDescriptors=[stateDescriptors,d];
                    end
                end
                obj.states=stateDescriptors;
            end
        end



        function addValueDataDescriptors(obj)
            valueDescriptors=[];
            if isa(obj.network,'DAGNetwork')||isa(obj.network,'SeriesNetwork')||isa(obj.network,'dlnetwork')
                dataTransNum=obj.ddrSupport.dataTransNum;
                convThreadNum=obj.ddrSupport.convThreadNum;
                bytesPerData=obj.ddrSupport.bytesPerData;
                fcThreadNum=obj.ddrSupport.fcThreadNum;

                constComps=obj.sgraph.getConstComponentList();
                for i=1:numel(constComps)
                    component=constComps{i};
                    net=component.outputs.net;
                    mr=obj.ddrSupport.memoryRegions(net.id);



                    constValue=dnnfpga.format.paddingtoDataParallelTransferNumber(component.ConstValue,dataTransNum,convThreadNum);
                    constValue=dnnfpga.format.convert3DInputToDDRVectorFormatConv4(constValue,dataTransNum);
                    d=dnnfpga.dagCompile.DataDescriptor(component.name,net,mr,dataTransNum,bytesPerData,convThreadNum,fcThreadNum,constValue);
                    valueDescriptors=[valueDescriptors,d];
                end
            end
            obj.values=valueDescriptors;
        end

    end
end


