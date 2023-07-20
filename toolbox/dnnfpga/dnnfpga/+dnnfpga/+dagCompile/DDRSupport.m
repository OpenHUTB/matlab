classdef DDRSupport<handle




    properties
offsetStart
alignBlockSize
readBlockSize
writeBlockSize

inputFrameNumberLimit

dataTransNum
convThreadNum
fcThreadNum
bytesPerData
hDDROffsetMap

sgraph
meSupport
memoryRegions
isMemoryReady
uniqueActivations

    end
    properties(Dependent=true)
align
read
write
    end

    methods
        function obj=DDRSupport(processor,sgraph,varargin)

            obj.isMemoryReady=false;


            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'DDRStartOffset',hex2dec('00000000'),@isnumeric);
            addParameter(p,'DDRAlignBlockSize',hex2dec('00400000'),@obj.isPowerOf2);
            addParameter(p,'DDRReadBlockSize',hex2dec('00010000'),@obj.isPowerOf2);
            addParameter(p,'DDRWriteBlockSize',hex2dec('00000001'),@obj.isPowerOf2);



            addParameter(p,'InputFrameNumberLimit',2,@isnumeric);
            addParameter(p,'BytesPerData',4,@isnumeric);
            addParameter(p,'UniqueActivations','off',@dnnfpga.parseUtils.validateBoolean);

            parse(p,varargin{:});
            obj.offsetStart=uint32(p.Results.DDRStartOffset);
            obj.alignBlockSize=uint32(p.Results.DDRAlignBlockSize);
            obj.readBlockSize=uint32(p.Results.DDRReadBlockSize);
            obj.writeBlockSize=uint32(p.Results.DDRWriteBlockSize);
            obj.bytesPerData=uint32(p.Results.BytesPerData);
            obj.uniqueActivations=dnnfpga.parseUtils.toBool(p.Results.UniqueActivations);

            obj.inputFrameNumberLimit=uint32(p.Results.InputFrameNumberLimit);

            obj.dataTransNum=processor.getCC.dataTransNum;
            obj.convThreadNum=processor.getCC.convp.conv.threadNumLimit;
            if(~isempty(processor.getCC.fcp))
                obj.fcThreadNum=processor.getCC.fcp.threadNumLimit;
            else

                obj.fcThreadNum=obj.dataTransNum;
            end
            obj.hDDROffsetMap=containers.Map('KeyType','char','ValueType','uint32');
            obj.sgraph=sgraph;

            netCount=numel(obj.sgraph.nets);
            a(netCount)=dnnfpga.dagCompile.MemoryRegion();
            obj.memoryRegions=a;
        end

        function h=get.align(obj)
            h=dnnfpga.dagCompile.Rounder(obj.getExponent(obj.alignBlockSize));
        end

        function h=get.read(obj)
            h=dnnfpga.dagCompile.Rounder(obj.getExponent(obj.readBlockSize));
        end

        function h=get.write(obj)
            h=dnnfpga.dagCompile.Rounder(obj.getExponent(obj.writeBlockSize));
        end

        function allocateMemory(obj)
            import dnnfpga.dagCompile.*
            obj.meSupport=MESupport(obj.sgraph,obj.uniqueActivations);


            for i=1:numel(obj.sgraph.components)
                component=obj.sgraph.components(i);
                if component.isJoin()
                    if isa(component.nLayer,'nnet.cnn.layer.DepthConcatenationLayer')



                        net=component.outputs.net;
                        for j=1:numel(component.inputs)
                            pinst=component.inputs(j);
                            net1=pinst.net;
                            obj.meSupport.mergeNodes(net.id,net1.id)
                        end
                    end
                end


                if component.hasKind(LayerKind.Soft)||...
                    component.hasKind(LayerKind.SoftToHard)||...
                    component.hasKind(LayerKind.HardToSoft)
                    if~isempty(component.outputs)
                        net=component.outputs.net();
                        for j=1:numel(component.inputs)
                            pinst=component.inputs(j);
                            net1=pinst.net;
                            if net.size~=net1.size
                                error("Nets expected to have same size.");
                            else
                                obj.meSupport.mergeNodes(net.id,net1.id)
                            end
                        end
                    end
                end

                if component.hasKind(LayerKind.FCFmt)||component.hasKind(LayerKind.State)
                    net=component.outputs.net;
                    for j=1:numel(component.inputs)
                        pinst=component.inputs(j);
                        net1=pinst.net;
                        obj.meSupport.mergeNodes(net.id,net1.id)
                    end
                end
            end

            for i=1:numel(obj.sgraph.components)
                component=obj.sgraph.components(i);

                if component.isInput()
                    net=component.outputs.net;
                    obj.meSupport.isolateNode(net.id);
                end
                if component.isOutput()
                    net=component.inputs.net;
                    obj.meSupport.isolateNode(net.id);
                end

                if component.hasKind(LayerKind.State)
                    net=component.inputs.net;
                    obj.meSupport.isolateNode(net.id);

                    net=component.outputs.net;
                    obj.meSupport.isolateNode(net.id);
                end
            end


            for k=1:numel(obj.meSupport.pairs)
                pair=obj.meSupport.pairs(k);
                i=pair.i;
                j=pair.j;
                if obj.meSupport.canMerge(i,j)
                    obj.meSupport.mergeNodes(i,j)
                end
            end

        end
        function createMemoryRegions(obj,verbose)
            import dnnfpga.dagCompile.*



            obj.sgraph.nets.init(3000);


            inputData=0;

            outputData=1000;

            for i=1:numel(obj.sgraph.components)
                component=obj.sgraph.components(i);

                if component.isInput()
                    net=component.outputs.net;
                    net.data=inputData;
                    inputData=inputData+1;
                end
                if component.isOutput()
                    net=component.inputs.net;
                    net.data=outputData;
                    outputData=outputData+1;
                end
            end

            mrs=[];

            offset=obj.align.roundUp(obj.offsetStart);
            num=1;
            sets={};
            ds=[];
            k=uint8(1);

            netData=obj.sgraph.getNetData();

            for i=1:numel(obj.meSupport.sets)
                set=obj.meSupport.sets{i};
                if~isempty(set)
                    data=RegionKind.None;
                    for j=1:numel(set)
                        index=set(j);
                        data=min(data,netData(index));
                    end
                    sets{k}=set;
                    ds(k)=data;
                    k=k+1;
                end
            end


            [ds,I]=sort(ds);
            sets=sets(I);

            schedulerDataFound=false;

            firstInput=true;
            inputMin=0;
            inputOffset=0;

            firstOutput=true;
            outputMin=0;
            outputOffset=0;

            prev=RegionKind.None;
            for i=1:numel(sets)
                set=sets{i};
                kind=obj.dsToKindConversion(ds(i));
                if kind~=prev

                    if kind==RegionKind.None
                        obj.hDDROffsetMap('OutputResultEndOffset')=offset;
                    end
                    offset=obj.align.roundUp(offset);
                    prev=kind;
                    if kind==RegionKind.Input
                        obj.hDDROffsetMap('InputDataOffset')=offset;
                    end
                    if kind==RegionKind.Output
                        obj.hDDROffsetMap('OutputResultOffset')=offset;
                    end
                    if kind==RegionKind.None
                        schedulerDataFound=true;
                        obj.hDDROffsetMap('SchedulerDataOffset')=offset;
                    end
                else
                    offset=obj.read.roundUp(offset);
                end
                mr=dnnfpga.dagCompile.MemoryRegion(kind,obj.bytesPerData);
                mr.num=num;
                num=num+1;
                mrs=[mrs,mr];
                for j=1:numel(set)
                    n=set(j);
                    net=obj.sgraph.nets(n);
                    net.init(mr);
                    mr.addNet(net);
                end
                mr.updateSize(obj);







                if mr.kind==RegionKind.Input
                    mr.baseAddr=inputOffset;
                    inputOffset=inputOffset+mr.size;
                    if firstInput
                        inputMin=offset;
                        firstInput=false;
                    end

                    mr.defaultAddrOffset=inputMin;
                    mr.size=mr.size*obj.inputFrameNumberLimit;
                elseif mr.kind==RegionKind.Output
                    mr.baseAddr=uint32(outputOffset);
                    outputOffset=outputOffset+mr.size;
                    if firstOutput
                        outputMin=offset;
                        firstOutput=false;
                    end

                    mr.defaultAddrOffset=outputMin;
                    mr.size=mr.size*obj.inputFrameNumberLimit;
                else
                    mr.baseAddr=offset;
                end
                offset=offset+mr.size;
            end
            obj.hDDROffsetMap('SchedulerDataEndOffset')=offset;

            if prev==RegionKind.Output
                obj.hDDROffsetMap('OutputResultEndOffset')=offset;
            end
            offset=obj.align.roundUp(offset);

            if~schedulerDataFound
                obj.hDDROffsetMap('SchedulerDataOffset')=offset;
            end
            obj.hDDROffsetMap('EndOffset')=offset;
            obj.addMemoryRegions(mrs,verbose);
        end

        function kind=dsToKindConversion(obj,val)
            if(val<1000)
                kind=dnnfpga.dagCompile.RegionKind.Input;
            elseif(val<2000)
                kind=dnnfpga.dagCompile.RegionKind.Output;
            elseif(val<3000)
                kind=dnnfpga.dagCompile.RegionKind.Internal;
            else
                kind=dnnfpga.dagCompile.RegionKind.None;
            end
        end



        function n=normalizeSize(obj,s,dataFormat)

            if(nargin<3)
                dataFormat=dnnfpga.dagCompile.DataFormat.Conv;
            end










            n=obj.normalizeSizeStatic(s,obj.dataTransNum,obj.convThreadNum,dataFormat,obj.fcThreadNum);

        end

        function addMemoryRegions(obj,mrs,verbose)
            for i=1:numel(mrs)
                mr=mrs(i);
                for j=1:numel(mr.nets)
                    net=mr.nets(j);
                    obj.memoryRegions(net.id)=copy(mr);
                end
            end


            strOutput=sprintf('%u Memory Regions created.',numel(mrs));
            dnnfpga.disp(strOutput,2,verbose);


            obj.adjustAllConcatOffsets();
            obj.isMemoryReady=true;
        end


        function adjustAllConcatOffsets(obj)
            for i=1:numel(obj.sgraph.nets)
                net=obj.sgraph.nets(i);

                component=net.driver.component;
                if component.isJoin()&&dnnfpga.dagCompile.Layers.isDepthConcat(component.nLayer)
                    isTop=true;
                    for j=1:numel(net.receivers)
                        input=net.receivers(j);
                        c=input.component;
                        if c.isJoin()&&dnnfpga.dagCompile.Layers.isDepthConcat(c.nLayer)
                            isTop=false;
                            break;
                        end
                    end
                    if isTop



                        mr=obj.memoryRegions(net.id);
                        area=prod(net.size)*4;

                        obj.adjustConcatOffsets(net,0);
                    end
                end
            end
        end

        function offset=adjustConcatOffsets(obj,net,o)
            mr=obj.memoryRegions(net.id);

            mrc=copy(mr);
            mrc.offsetZ=o;
            obj.memoryRegions(net.id)=mrc;
            component=net.driver.component;
            if numel(component.inputs)==1&&component.hasSharedMem()
                netNext=component.inputs.net;
                obj.adjustConcatOffsets(netNext,o);
            end
            if component.isJoin()&&dnnfpga.dagCompile.Layers.isDepthConcat(component.nLayer)
                off=0;

                for i=1:numel(component.inputs)
                    input=component.inputs(i);
                    net0=input.net;
                    off=off+obj.adjustConcatOffsets(net0,off+o);
                end
                offset=off;
            else
                offset=prod(net.size);


                offset=offset*obj.bytesPerData;

            end
        end
    end
    methods(Access=private)
        function e=getExponent(~,value)
            e=uint32(log2(single(value)));
        end
        function v=isPowerOf2(obj,value)
            e=obj.getExponent(uint32(value));
            v=uint32(bitsll(1,e))==uint32(value);
        end
    end
    methods(Static=true)
        function n=normalizeSizeStatic(s,dataTransNum,convThreadNum,dataFormat,fcThreadNum)

            if nargin<3
                convThreadNum=dataTransNum;
            end

            if nargin<4
                dataFormat=dnnfpga.dagCompile.DataFormat.Conv;
            end

            if nargin<5

                fcThreadNum=dataTransNum;
            end

            ss=s;
            sz=size(ss);
            while sz(2)<3
                ss=[ss,1];
                sz=size(ss);
            end











            if(dataFormat==dnnfpga.dagCompile.DataFormat.FC)
                z=ceil(ss(3)/double(fcThreadNum))*fcThreadNum;
                ss(3)=z;
                n=ss;
            else
                z=ceil(ss(3)/double(convThreadNum))*dataTransNum;
                ss(3)=z;
                n=ss;
            end
        end
    end
end
