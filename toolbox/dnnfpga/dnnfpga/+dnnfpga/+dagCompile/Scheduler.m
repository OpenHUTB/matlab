












classdef Scheduler<handle




    properties
types
compiler
        instructions=[];
        tableOps=[];
memoryRegions
    end

    properties(Access=private)
addrZero
payloadAddrZero
payloadAddrZeroShort
numZero
opCount
    end

    methods
        function obj=Scheduler(compiler,hPC)
            if nargin<2
                hPC=[];
            end
            if isempty(hPC)
                customLayerList=[];
            else
                customLayerList=hPC.CustomLayerManager.getLayerList;
            end

            obj.compiler=compiler;
            typedefs=dnnfpga.codegen.Defs(customLayerList);
            obj.types=typedefs.tc;

            instr=obj.types.defaultValue('DLInstr');
            obj.addrZero=cast(0,'like',instr.src0);
            entry=obj.types.defaultValue('TableEntry');
            obj.numZero=cast(0,'like',entry.num);

            addPayload=obj.types.defaultValue('AddPayload');
            obj.payloadAddrZero=cast(0,'like',addPayload.dstAddr);
            obj.payloadAddrZeroShort=cast(0,'like',addPayload.src0Addr);

            obj.memoryRegions=obj.compiler.ddrSupport.memoryRegions;

        end

        function createSchedule(obj,data,verbose,varargin)
            import dnnfpga.dagCompile.*
            if~obj.compiler.ddrSupport.isMemoryReady
                error('Schedule cannot be created until memory allocation has occurred.');
            end
            obj.opCount=1;
            obj.instructions=[];
            sortedComponents=obj.compiler.sgraph.sortedComponents();

            dnnfpga.disp('Creating Schedule',2,verbose,false);
            dnnfpga.codegen.ENUM(obj.types.enumMap);
            obj.addClearToStack();

            payloads=obj.compiler.createSchedulerRegPayloads();
            for i=1:numel(payloads)
                payload=payloads(i);
                instr=obj.createInstruction();
                instr.cmd=Scheduler.DLCmd('REG');
                g=obj.payloadToGeneric(payload);
                obj.addToStack(instr,g);
            end
            for i=1:numel(sortedComponents)
                component=sortedComponents(i);
                obj.addInstruction(component,data,verbose,varargin{:});
            end
            obj.addLastToStack();
            obj.payloadChangesForMIMO();
            if(verbose>1)
                fprintf(newline);
            end
            dnnfpga.disp('Creating Schedule...complete.',2,verbose);
        end
        function ws=emitSchedule(obj,verbose)
            function sMod=convertToNoOp(s)
                import dnnfpga.dagCompile.*
                sMod=s;
                if s.instr.cmd==Scheduler.DLCmd('STE')||s.instr.cmd==Scheduler.DLCmd('CONCAT')
                    sMod.instr.cmd=Scheduler.DLCmd('NOOP');
                end
            end
            ws=[];

            dnnfpga.disp('Emitting Schedule',2,verbose,false);
            for s=obj.instructions'
                if verbose>1
                    fprintf('.');
                end
                sMod=convertToNoOp(s);
                w=dnnfpga.codegen.Convert.toWords(sMod);
                ws=[ws,w];
            end
            if(verbose>1)
                fprintf(newline);
            end
            dnnfpga.disp('Emitting Schedule...complete.',2,verbose);
        end

        function createTable(obj,verbose)
            import dnnfpga.dagCompile.*;

            function n=calculateStaticReads(net)
                n=uint8(0);
                for pinst=net.receivers
                    if~pinst.component.hasKind(LayerKind.Label)
                        n=n+uint8(1);
                    end
                end
            end
            obj.clearTable();

            dnnfpga.disp('Creating Status Table.',2,verbose,false);
            obj.addClearToTable();
            for i=1:numel(obj.compiler.sgraph.nets)
                if verbose>1
                    fprintf('.');
                end
                net=obj.compiler.sgraph.nets(i);
                t=obj.types.defaultValue('TableOp');
                t.cmd=dnnfpga.dagCompile.Scheduler.TableOpCmd('INIT');
                t.num(:)=obj.numZero+net.id;
                t.isConstant=net.driver.component.hasKind(LayerKind.Constant);
                t.staticReads=calculateStaticReads(net);
                if net.driver.component.hasKind(LayerKind.State)
                    t.cmd=dnnfpga.dagCompile.Scheduler.TableOpCmd('INITSTATE');
                end
                obj.addToTable(t);
            end
            obj.addLastToTable();
            if(verbose>1)
                fprintf(newline);
            end
            dnnfpga.disp('Creating Status Table...complete.',2,verbose);
        end
        function ws=emitTable(obj,verbose)
            ws=[];

            dnnfpga.disp('Emitting Status Table',2,verbose,false);
            for i=1:numel(obj.tableOps)

                if verbose>1&&i~=numel(obj.tableOps)
                    fprintf('.');
                end
                s=obj.tableOps(i);
                w=dnnfpga.codegen.Convert.toWords(s);
                ws=[ws,w];
            end
            if(verbose>1)
                fprintf(newline);
            end
            dnnfpga.disp('Emitting Status Table...complete.',2,verbose);
        end

        function displayTable(obj)
            fprintf("-----------------------------------\n");
            fprintf("         Table Entries\n")
            fprintf("-----------------------------------\n");
            for i=1:numel(obj.tableOps)
                tOp=obj.tableOps(i);
                dnnfpga.dagCompile.Utils.prettyPrint(tOp);
                fprintf("-----------------------------------\n");
            end
        end

        function displaySchedule(obj)
            fprintf("-----------------------------------\n");
            fprintf("      Schedule Instructions\n")
            fprintf("-----------------------------------\n");
            for i=1:numel(obj.instructions)
                instr=obj.instructions(i);
                obj.displayIStackWData(instr);
                fprintf("-----------------------------------\n");
            end
        end

        function addInstruction(obj,component,data,verbose,varargin)
            import dnnfpga.dagCompile.*;
            if verbose>1
                fprintf('.');
            end
            processor=varargin{:};
            cc=processor.getCC();
            if component.hasKind(LayerKind.Add)||component.hasKind(LayerKind.CustomLayer)

                instr=obj.createInstruction();
                instr.cmd=Scheduler.DLCmd('ADD');
                instr.epoch=uint8(1);

                payload=obj.types.defaultValue('AddPayload');

                net=component.outputs.net;
                mr=obj.memoryRegions(net.id);
                instr.dst0(:)=obj.addrZero+net.id;
                payload.dstAddr=mr.getAddr();



                if(strcmp(cc.addp.kernelDataType,'int8'))
                    signedbit=1;
                    numInputs=2;

                    numBitsRequiredForAddition=ceil(log2(numInputs+signedbit));

                    adjustedExponent_in1=component.inputExp(1)-(32-numBitsRequiredForAddition-8);
                    adjustedExponent_in2=component.inputExp(2)-(32-numBitsRequiredForAddition-8);

                    exponentIn1=-component.inputExp(1)+adjustedExponent_in1;
                    exponentIn2=-component.inputExp(2)+adjustedExponent_in2;


                    minExp=min(adjustedExponent_in1,adjustedExponent_in2);
                    maxExp=max(adjustedExponent_in1,adjustedExponent_in2);
                    finalOutExp=0;

                    if(minExp~=maxExp)
                        if(maxExp-minExp>1)










                            outIndex=find(component.inputExp==min(component.inputExp));
                            if(outIndex==1)
                                payload.exponentIn1=int8(-minExp+maxExp+exponentIn1);
                                payload.exponentIn2=int8(exponentIn2);
                            elseif(outIndex==2)
                                payload.exponentIn1=int8(exponentIn1);
                                payload.exponentIn2=int8(-minExp+maxExp+exponentIn2);
                            end
                            finalOutExp=maxExp;
                        else


                            outIndex=find(component.inputExp==max(component.inputExp));
                            if(outIndex==1)
                                payload.exponentIn1=int8(-maxExp+minExp+exponentIn1);
                                payload.exponentIn2=int8(exponentIn2);
                            elseif(outIndex==2)
                                payload.exponentIn1=int8(exponentIn1);
                                payload.exponentIn2=int8(-maxExp+minExp+exponentIn2);
                            end
                            finalOutExp=minExp;
                        end
                    else
                        payload.exponentIn1=int8(exponentIn1);
                        payload.exponentIn2=int8(exponentIn2);
                        finalOutExp=minExp;
                    end
                    payload.exponent=int8(-(finalOutExp-component.outputExp));
                else
                    payload.exponentIn1=int8(1);
                    payload.exponentIn2=int8(2);
                    payload.exponent=int8(3);
                end

                net=component.inputs(1).net;
                mr=obj.memoryRegions(net.id);
                instr.src0(:)=obj.addrZero+net.id;
                payload.src0Addr=mr.getAddr();



                if component.numInputs==2
                    net=component.inputs(2).net;
                    mr=obj.memoryRegions(net.id);
                    instr.src1(:)=obj.addrZero+net.id;
                    payload.src1Addr=mr.getAddr();
                end

                if component.hasKind(LayerKind.Relu)
                    reluLayer=component.nLayer(2);
                    if isa(reluLayer,'nnet.cnn.layer.ReLULayer')
                    end
                    if isa(reluLayer,'nnet.cnn.layer.LeakyReLULayer')
                        if(strcmp(cc.addp.kernelDataType,'int8'))
                            quantReLUValue=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(component.reLUValue,component.reLUExp);
                            payload.reluValue=uint32(quantReLUValue);
                            payload.reluScaleExp=int8(component.reLUExp);
                        else
                            payload.reluValue=typecast(single(reluLayer.Scale),'uint32');
                            payload.reluScaleExp=int8(0);
                        end
                    end
                    if isa(reluLayer,'nnet.cnn.layer.ClippedReLULayer')
                        if(strcmp(cc.addp.kernelDataType,'int8'))
                            quantReLUValue=dnnfpga.processorbase.processorUtils.singleToInt32Conversion(component.reLUValue,finalOutExp);
                            payload.reluValue=uint32(quantReLUValue);

                            payload.reluScaleExp=int8(0);
                        else
                            payload.reluValue=typecast(single(reluLayer.Ceiling),'uint32');
                            payload.reluScaleExp=int8(0);
                        end

                    end

                end

                g=obj.payloadToGeneric(payload);
                obj.addToStack(instr,g);
            elseif component.hasKind(LayerKind.Concat)
                instr=obj.createInstruction();
                instr.cmd=Scheduler.DLCmd('CONCAT');
                instr.epoch=uint8(1);

                net=component.outputs.net;
                mr=obj.memoryRegions(net.id);
                instr.dst0(:)=obj.addrZero+net.id;

                net=component.inputs(1).net;
                mr=obj.memoryRegions(net.id);
                instr.src0(:)=obj.addrZero+net.id;

                net=component.inputs(2).net;
                mr=obj.memoryRegions(net.id);
                instr.src1(:)=obj.addrZero+net.id;

                payload=obj.types.defaultValue('NoOpPayload');
                g=obj.payloadToGeneric(payload);
                obj.addToStack(instr,g);

            elseif component.hasKind(LayerKind.FC)
                instr=obj.createInstruction();
                instr.cmd=Scheduler.DLCmd('FC');
                instr.epoch=uint8(1);

                opData=data{obj.opCount};
                obj.opCount=obj.opCount+1;
                count=opData.layerNumMinusOne+1;

                payload=obj.types.defaultValue('FCPayload');
                payload.instrCount=uint16(count);

                net=component.outputs(1).net;
                mr=obj.memoryRegions(net.id);

                instr.dst0(:)=obj.addrZero+net.id;


                payload.dstAddr=mr.getAddr();

                net=component.inputs(1).net;
                mr=obj.memoryRegions(net.id);
                instr.src0(:)=obj.addrZero+net.id;
                payload.srcAddr=mr.getAddr;

                g=obj.payloadToGeneric(payload);
                obj.addToStack(instr,g);

            elseif component.hasKind(LayerKind.Conv)
                instr=obj.createInstruction();
                instr.cmd=Scheduler.DLCmd('CONV');
                instr.epoch=uint8(1);

                payload=obj.types.defaultValue('ConvPayload');
                obj.opCount=obj.opCount+1;



                net=component.outputs(1).net;
                mr=obj.memoryRegions(net.id);
                instr.dst0(:)=obj.addrZero+net.id;
                payload.dstAddr=mr.getAddr();

                net=component.inputs(1).net;
                mr=obj.memoryRegions(net.id);
                instr.src0(:)=obj.addrZero+net.id;
                payload.srcAddr=mr.getAddr();

                if component.hasKind(LayerKind.Unpool)






                    net=component.inputs(2).net;
                    instr.src1(:)=obj.addrZero+net.id;
                end

                g=obj.payloadToGeneric(payload);
                obj.addToStack(instr,g);
            elseif component.hasKind(LayerKind.Soft)||component.hasKind(LayerKind.Constant)

            elseif component.hasKind(LayerKind.SoftToHard)




                net=component.outputs.net;
                mr=obj.memoryRegions(net.id);
                instr=obj.createInstruction();
                instr.cmd=Scheduler.DLCmd('INPUT');
                instr.dst0(:)=obj.addrZero+net.id;
                instr.epoch=uint8(1);



                names=mr.getInputNames();
                name=names{1};
                pos=obj.compiler.getInputPosition(name);

                payload=obj.types.defaultValue('InputPayload');
                payload.addr=mr.getAddr();
                size=obj.compiler.ddrSupport.normalizeSize(net.size,net.dataFormat);
                payload.sizeInBytes=uint32(prod(size)*obj.compiler.ddrSupport.bytesPerData);
                payload.id=uint8(pos);
                payload.frameNumber=uint32(1);
                g=obj.payloadToGeneric(payload);
                obj.addToStack(instr,g);
            elseif component.hasKind(LayerKind.HardToSoft)
                net=component.inputs.net;
                mr=obj.memoryRegions(net.id);
                instr=obj.createInstruction();
                instr.cmd=Scheduler.DLCmd('OUTPUT');
                instr.src0(:)=obj.addrZero+net.id;
                instr.epoch=uint8(1);



                names=mr.getOutputNames();
                name=names{1};
                pos=obj.compiler.getOutputPosition(name);
                payload=obj.types.defaultValue('OutputPayload');
                payload.addr=mr.getAddr();
                size=obj.compiler.ddrSupport.normalizeSize(net.size,net.dataFormat);
                payload.sizeInBytes=uint32(prod(size)*obj.compiler.ddrSupport.bytesPerData);
                payload.id=uint8(pos);
                g=obj.payloadToGeneric(payload);
                obj.addToStack(instr,g);
            elseif component.hasKind(LayerKind.Relu)
                name='ReLu';
                if numel(component.nLayer)==1
                    name=class(component.nLayer);
                end
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedStandaloneLayer',name);
                error(msg);
            elseif component.hasKind(LayerKind.State)
                instr=obj.createInstruction();
                instr.cmd=Scheduler.DLCmd('STE');
                instr.epoch=uint8(1);

                payload=obj.types.defaultValue('NoOpPayload');


                net=component.outputs(1).net;
                mr=obj.memoryRegions(net.id);

                instr.dst0(:)=obj.addrZero+net.id;




                net=component.inputs(1).net;
                mr=obj.memoryRegions(net.id);
                instr.src0(:)=obj.addrZero+net.id;


                g=obj.payloadToGeneric(payload);
                obj.addToStack(instr,g);
            elseif component.hasKind(LayerKind.FCFmt)
                instr=obj.createInstruction();
                instr.cmd=Scheduler.DLCmd('NOOP');
                instr.epoch=uint8(1);

                payload=obj.types.defaultValue('NoOpPayload');


                net=component.outputs(1).net;
                mr=obj.memoryRegions(net.id);

                instr.dst0(:)=obj.addrZero+net.id;




                net=component.inputs(1).net;
                mr=obj.memoryRegions(net.id);
                instr.src0(:)=obj.addrZero+net.id;


                g=obj.payloadToGeneric(payload);
                obj.addToStack(instr,g);
            elseif component.hasKind(LayerKind.Label)

            else
                msg=message('dnnfpga:dnnfpgacompiler:UnsupportedLayer',class(component.nLayer));
                error(msg);
            end
        end
    end
    methods
        function addToStack(obj,instr,payload)
            instr=obj.updateAddrModes(instr);
            wdata=obj.createIStackWData();
            wdata.instr=instr;
            wdata.payload=payload;
            wdata.cmd=dnnfpga.dagCompile.Scheduler.IStackCmd('WR');
            obj.instructions=cat(1,obj.instructions,wdata);
        end
        function addClearToStack(obj)
            wdata=obj.createIStackWData();
            wdata.cmd=dnnfpga.dagCompile.Scheduler.IStackCmd('CLR');
            obj.instructions=cat(1,obj.instructions,wdata);
        end
        function addLastToStack(obj)
            wdata=obj.createIStackWData();
            wdata.cmd=dnnfpga.dagCompile.Scheduler.IStackCmd('LST');
            obj.instructions=cat(1,obj.instructions,wdata);
        end
        function clearStack(obj)
            obj.instructions=[];
        end

        function addToTable(obj,tOp)
            obj.tableOps=cat(1,obj.tableOps,tOp);
        end
        function addClearToTable(obj)
            t=obj.types.defaultValue('TableOp');
            t.cmd=dnnfpga.dagCompile.Scheduler.TableOpCmd('CLR');
            obj.tableOps=cat(1,obj.tableOps,t);
        end
        function addLastToTable(obj)
            t=obj.types.defaultValue('TableOp');
            t.cmd=dnnfpga.dagCompile.Scheduler.TableOpCmd('LST');
            obj.tableOps=cat(1,obj.tableOps,t);
        end
        function clearTable(obj)
            obj.tableOps=[];
        end
        function instr=updateAddrModes(obj,instrIn)
            import dnnfpga.dagCompile.*;
            instr=instrIn;
            id=instr.src0;
            if id~=0
                mr=obj.memoryRegions(id);
                instr.src0Mode=obj.getAddrMode(mr,id,true);
            end
            id=instr.src1;
            if id~=0
                mr=obj.memoryRegions(id);
                instr.src1Mode=obj.getAddrMode(mr,id,true);
            end
            id=instr.dst0;
            if id~=0
                mr=obj.memoryRegions(id);
                instr.dst0Mode=obj.getAddrMode(mr,id);
            end
        end
        function mode=getAddrMode(~,memoryRegion,id,noticeState)
            if nargin<4
                noticeState=false;
            end
            import dnnfpga.dagCompile.*
            mode=Scheduler.AddrMode('Direct');
            if memoryRegion.kind==RegionKind.Input
                mode=Scheduler.AddrMode('IncrementInput');
            end
            if memoryRegion.kind==RegionKind.Output
                mode=Scheduler.AddrMode('IncrementOutput');
                if noticeState
                    for net=memoryRegion.nets'
                        if net.id==id
                            component=net.driver.component;
                            if component.hasKind(LayerKind.State)
                                mode=Scheduler.AddrMode('IncrementOutputPrev');
                            end
                        end
                    end
                end
            end
        end

        function payloadChangesForMIMO(obj)










            for i=0:numel(obj.instructions)-1
                if(isequal(obj.instructions(end-i).instr.cmd,obj.DLCmd('OUTPUT')))
                    payload=dnnfpga.codegen.Packed.fromBools(dnnfpga.codegen.Packed.toBools(obj.instructions(end-i).payload),...
                    obj.types.defaultValue('OutputPayload'));
                    payload.isLast=true;

                    obj.instructions(end-i).payload=obj.payloadToGeneric(payload);
                    break;
                end
            end






            for i=1:numel(obj.instructions)
                if(isequal(obj.instructions(i).instr.cmd,obj.DLCmd('INPUT')))
                    payload=dnnfpga.codegen.Packed.fromBools(dnnfpga.codegen.Packed.toBools(obj.instructions(i).payload),...
                    obj.types.defaultValue('InputPayload'));
                    payload.isFirst=true;

                    obj.instructions(i).payload=obj.payloadToGeneric(payload);
                    break;
                end
            end

        end
    end

    methods
        function s=createInstruction(obj,~)
            s=obj.types.defaultValue('DLInstr');
        end
        function s=createIStackWData(obj)
            s=obj.types.defaultValue('IStackWData');
        end
        function g=payloadToGeneric(obj,p)
            g=obj.types.defaultValue('Payload');
            payloadSizeMax=dnnfpga.codegen.Packed.getBitSize(g);
            payloadSize=dnnfpga.codegen.Packed.getBitSize(p);
            if payloadSize>payloadSizeMax
                error('Payload size exceeds maximum allowable. (Size of %u bits exceeds %u bit maximum),',uint32(payloadSize),uint32(payloadSizeMax));
            end
            bs=dnnfpga.codegen.Packed.toBools(p);
            bs=dnnfpga.codegen.Bools.extend(bs,payloadSizeMax);
            fs=dnnfpga.codegen.Packed.boolsToFixed(bs,payloadSizeMax,uint32(32));
            ws=arrayfun(@storedInteger,fs);
            g.words=ws;
        end
        function displayIStackWData(obj,value)
            if value.cmd.value==dnnfpga.dagCompile.Scheduler.IStackCmd('WR').value
                fprintf('DLInstr:\n');
                dnnfpga.dagCompile.Utils.prettyPrint(value.instr);
                switch(value.instr.cmd.value)
                case dnnfpga.dagCompile.Scheduler.DLCmd('INPUT').value
                    payload=dnnfpga.codegen.Packed.fromBools(dnnfpga.codegen.Packed.toBools(value.payload.words),...
                    obj.types.defaultValue('InputPayload'));
                    fprintf('InputPayload:\n');
                    dnnfpga.dagCompile.Utils.prettyPrint(payload,'addr');
                case dnnfpga.dagCompile.Scheduler.DLCmd('OUTPUT').value
                    payload=dnnfpga.codegen.Packed.fromBools(dnnfpga.codegen.Packed.toBools(value.payload.words),...
                    obj.types.defaultValue('OutputPayload'));
                    fprintf('OutputPayload:\n');
                    dnnfpga.dagCompile.Utils.prettyPrint(payload,'addr');
                case dnnfpga.dagCompile.Scheduler.DLCmd('ADD').value
                    payload=dnnfpga.codegen.Packed.fromBools(dnnfpga.codegen.Packed.toBools(value.payload.words),...
                    obj.types.defaultValue('AddPayload'));
                    fprintf('AddPayload:\n');
                    dnnfpga.dagCompile.Utils.prettyPrint(payload,'addr');
                case dnnfpga.dagCompile.Scheduler.DLCmd('CONV').value
                    payload=dnnfpga.codegen.Packed.fromBools(dnnfpga.codegen.Packed.toBools(value.payload.words),...
                    obj.types.defaultValue('ConvPayload'));
                    fprintf('ConvPayload:\n');
                    dnnfpga.dagCompile.Utils.prettyPrint(payload,'addr');
                case dnnfpga.dagCompile.Scheduler.DLCmd('FC').value
                    payload=dnnfpga.codegen.Packed.fromBools(dnnfpga.codegen.Packed.toBools(value.payload.words),...
                    obj.types.defaultValue('FCPayload'));
                    fprintf('FCPayload:\n');
                    dnnfpga.dagCompile.Utils.prettyPrint(payload,'addr');
                case dnnfpga.dagCompile.Scheduler.DLCmd('REG').value
                    payload=dnnfpga.codegen.Packed.fromBools(dnnfpga.codegen.Packed.toBools(value.payload.words),...
                    obj.types.defaultValue('RegPayload'));
                    cc=obj.compiler.Processor.getCC();
                    regAddressMap=cc.schedulerRegMap;

                    label='unknown';
                    values=regAddressMap.values;
                    keys=regAddressMap.keys;
                    for i=1:numel(values)
                        value=values{i};
                        if value==payload.addr
                            label=keys{i};
                            break;
                        end
                    end
                    fprintf('RegPayload: (%s)\n',label);
                    dnnfpga.dagCompile.Utils.prettyPrint(payload,'addr');
                otherwise
                end
            else
                dnnfpga.dagCompile.Utils.prettyPrint(value,'addr');
            end
        end
    end

    methods(Static=true,Access=private)
        function d=AddrMode(label)
            d=dnnfpga.codegen.ENUM('AddrMode',label);
        end
        function d=DLCmd(label)
            d=dnnfpga.codegen.ENUM('DLCmd',label);
        end
        function d=IStackCmd(label)
            d=dnnfpga.codegen.ENUM('IStackCmd',label);
        end
        function d=TableOpCmd(label)
            d=dnnfpga.codegen.ENUM('TableOpCmd',label);
        end
        function d=ReluMode(label)
            d=dnnfpga.codegen.ENUM('ReluMode',label);
        end





        function r=shrinkLike(addr,addrShort)
            delta=dnnfpga.codegen.Bools.getBuiltinSize(addr)-...
            dnnfpga.codegen.Bools.getBuiltinSize(addrShort);
            r=cast(bitshift(addr,-delta),'like',addrShort);
        end
    end
end



