classdef ptxEmitter<parallel.internal.gpu.Emitter









    properties(SetAccess=private,Hidden=true)


        Instr;
        Codetable;


        Interruptible;


        ComputeCapability;


        Com;



        Basename;


        Enterlabel;
        Epiloguelabel;
        Exitlabel;
        Ender;


        DebugState;


        Pfs='<<garbled>>';

        DimArray='dim';
        Ndim='ndim';

        RandState;

        SizeVariable='arraySize';

        BlockAddress;
        NoErrorCode='1000';

        InterruptPtrAddress;
        InterruptCount='2999';

    end


    methods(Static=true,Hidden=true)


        function w=typesize(type)

            if isDouble(type)
                w=8;
            elseif isSingle(type)
                w=4;
            elseif isComplexDouble(type)
                w=16;
            elseif isComplexSingle(type)
                w=8;
            elseif isLogical(type)
                w=1;
            elseif isInt32(type)||isUint32(type)
                w=4;
            elseif isComplexInt32(type)||isComplexUint32(type)
                w=8;
            elseif isInt64(type)||isUint64(type)
                w=8;
            elseif isComplexInt64(type)||isComplexUint64(type)
                w=16;
            elseif isInt16(type)||isUint16(type)||isChar(type)
                w=2;
            elseif isComplexInt16(type)||isComplexUint16(type)
                w=4;
            elseif isInt8(type)||isUint8(type)
                w=1;
            elseif isComplexInt8(type)||isComplexUint8(type)
                w=2;
            else
                assert(false,'emitter:typesize','Internal method using non-supported type: ''%s''.',mType(type));
            end

        end

        function targetDeviceProperties=makeTargetDeviceProperties(dev)

            computeCapability=str2double(dev.ComputeCapability);

            targetDeviceProperties=struct(...
            'computeCapability',computeCapability,...
            'KernelExecutionTimeout',dev.KernelExecutionTimeout,...
            'CanMapHostMemory',dev.CanMapHostMemory,...
            'codetable',parallel.internal.ptx.ptxEmitter.loadCodetable(computeCapability)...
            );

        end



        function[computecapability,interruptible,codetable]=getCodetable(dev)

            persistent targetDeviceProperties;

            if isempty(targetDeviceProperties)
                targetDeviceProperties=parallel.internal.ptx.ptxEmitter.makeTargetDeviceProperties(dev);
            else
                newComputeCapability=str2double(dev.ComputeCapability);
                if newComputeCapability~=targetDeviceProperties.computeCapability
                    targetDeviceProperties=parallel.internal.ptx.ptxEmitter.makeTargetDeviceProperties(dev);
                end
            end

            computecapability=targetDeviceProperties.computeCapability;
            interruptible=targetDeviceProperties.CanMapHostMemory&&~targetDeviceProperties.KernelExecutionTimeout;
            codetable=targetDeviceProperties.codetable;

        end


        function codetable=loadCodetable(computeCapability)

            tbxdir=toolboxdir('parallel');
            kernelsPath=fullfile(tbxdir,'gpu','+parallel','+internal','+ptx');
            SMtoUse=parallel.internal.ptx.getCodetableFile(kernelsPath,computeCapability);


            codetable=feval('_loadOnThread',fullfile(kernelsPath,SMtoUse));
            codetable=codetable.PTX;

        end


        function name=getVariableName(var)


            tokens=regexp(var,'\s','split');
            name=tokens{end};


            idx=strfind(name,'[');
            if~isempty(idx)
                assert(1==numel(idx),'oops! Andy you don''t understand the grammar!');
                name=name(1:(idx-1));
            end

        end



        function ptxbody=replaceLoadInstructions(ptxbody,invars,inReg,offset)


            for kk=1:numel(invars)

                varname=invars{kk};




                paramloadpat=sprintf('ld\\.param\\.[a-z]+[0-9]+\\s+%%[a-z]+.[0-9]+,\\s*\\[%s%s\\];',varname,offset);

                paramloadinstr=regexp(ptxbody,paramloadpat,'match');
                paramloadinstr=regexprep(paramloadinstr,'ld\.param','mov');



                invarpat=sprintf(',\\s+\\[%s%s\\];',varname,offset);
                inregpat=sprintf(', %s;',inReg{kk});
                paramloadinstr=regexprep(paramloadinstr,invarpat,inregpat);





                for jj=1:numel(paramloadinstr)
                    ptxbody=regexprep(ptxbody,paramloadpat,paramloadinstr{jj},'once');
                end

            end

        end


    end


    methods(Access=private,Hidden=true)




        function instr=formatInstruction(obj,op,comment,varargin)


            tabchrs='                                                                         ';
            n=max(20-numel(op),1);
            instr=['    ',op,tabchrs(1:n)];

            nargs=numel(varargin);

            if nargs>0
                instr=[instr,varargin{1}];
            end

            for iv=2:nargs
                instr=[instr,',',varargin{iv}];%#ok<AGROW>
            end

            instr=[instr,';'];

            if~isempty(comment)&&emitPtxWithComments(obj)

                n=max(73-numel(instr),1);
                instr=[instr,tabchrs(1:n),'// ',comment];
            end

            instr=sprintf('%s\n',instr);

        end




        function suf=regsuffix(obj,type)%#ok



            realType=coerceReal(type);

            if isDouble(realType)
                suf='.f64';
            elseif isSingle(realType)
                suf='.f32';
            elseif isLogical(realType)
                suf='.u32';
            elseif isInt32(realType)
                suf='.s32';
            elseif isUint32(realType)
                suf='.u32';
            elseif isInt64(realType)
                suf='.s64';
            elseif isUint64(realType)
                suf='.u64';
            elseif isInt16(realType)
                suf='.s16';
            elseif isUint16(realType)
                suf='.u16';
            elseif isInt8(realType)
                suf='.s8';
            elseif isUint8(realType)
                suf='.u8';
            elseif isChar(type)
                suf='.s16';
            else
                assert(false,'emitter:regsuf',...
                'Unsupported type, ''%s'' is being generated by or allowed into compilation.',mType(type));
            end

        end

        function suf=regsuffixForOperation(obj,type)%#ok





            realType=coerceReal(type);

            if isDouble(realType)
                suf='.f64';
            elseif isSingle(realType)
                suf='.f32';
            elseif isLogical(type)
                suf='.u32';
            elseif isInt32(realType)||isInt16(realType)||isInt8(realType)
                suf='.s32';
            elseif isUint32(realType)||isUint16(realType)||isUint8(realType)
                suf='.u32';
            elseif isInt64(realType)
                suf='.s64';
            elseif isUint64(realType)
                suf='.u64';
            elseif isChar(realType)
                suf='.s16';
            else
                assert(false,'emitter:regsuf',...
                'Unsupported type, ''%s'' is being generated by or allowed into compilation.',mType(type));
            end

        end

        function typeop=integerType4Op(obj,type)%#ok
            if isSignedInteger(type)
                typeop=parallel.internal.types.Atomic.buildAtomic('int32',false);
            else
                typeop=parallel.internal.types.Atomic.buildAtomic('uint32',false);
            end
        end


        function bytes=wordwidth(obj,type)%#ok

            if isDouble(type)
                bytes='8';
            elseif isComplexDouble(type)
                bytes='16';
            elseif isSingle(type)
                bytes='4';
            elseif isComplexSingle(type)
                bytes='8';
            elseif isLogical(type)
                bytes='1';
            elseif isInt32(type)
                bytes='4';
            elseif isUint32(type)
                bytes='4';
            elseif isInt64(type)
                bytes='8';
            elseif isUint64(type)
                bytes='8';
            elseif isInt16(type)
                bytes='2';
            elseif isUint16(type)
                bytes='2';
            elseif isInt8(type)
                bytes='1';
            elseif isUint8(type)
                bytes='1';
            elseif isChar(type)
                bytes='2';
            else
                assert(false,'emitter:wordwidth',...
                'Unsupported type, ''%s'' is being generated by or allowed into compilation.',mType(type));
            end

        end





        function instr=interruptHeader(obj,internalState)
            instr='';
            if containsNonStaticLoop(internalState)&&supportsInterrupt(obj)
                machineptr=getMachineptr(internalState);
                instr=sprintf('\t.global %s %s;\n',machineptr,obj.InterruptPtrAddress);
            end
        end


        function hfasm=functionHeader(obj,internalState)
            hfasm='';


            headerCode=getHeaders(internalState,obj.Codetable.Headers);

            if~isempty(headerCode)
                hfasm=sprintf('\t%s\n',headerCode{:});
            end


            t=getKernels(internalState);
            if~isempty(t)


                hfasm=[hfasm,sprintf('\t%s\n',t{:}),newline];
            end






            if initializeBlockError(internalState)
                fstructCheckError=getErrorCheckFcn(obj);
                errorFunctionCode=sprintf('\t%s\n',fstructCheckError.code);
                hfasm=[hfasm,errorFunctionCode,newline];
            end
        end


        function ptxbody=generateInlinePtx(obj,tableEntry,type,outReg,inReg,endlabel)


            prototype=tableEntry.prototype;
            argpat='(\.param(( )*(\.(\w+)) (\w+))+([\[0-9]+])*)';
            vars=regexp(prototype,argpat,'match');
            N=numel(vars);


            outvar=obj.getVariableName(vars{1});


            nargsin=N-1;
            invars=cell(1,nargsin);

            for kk=1:nargsin
                invars{kk}=obj.getVariableName(vars{kk+1});
            end


            ptxcode=tableEntry.code;
            ptxbody=regexp(ptxcode,'({.*})','match');


            returnInstr=branchToLabel(obj,endlabel);
            ptxbody=regexprep(ptxbody,'ret;',returnInstr);



            ptxbody=regexprep(ptxbody,'%SP','%SPmw');
            ptxbody=regexprep(ptxbody,'%r','%rmw');
            ptxbody=regexprep(ptxbody,'%f','%fmw');
            ptxbody=regexprep(ptxbody,'%p','%pmw');

            ptxbody=ptxbody{1};


            width=obj.typesize(coerceReal(type));
            nout=numel(outReg);
            for kk=1:nout

                outvarpat=sprintf('st.param\\.[a-z]+[0-9]+\\s+\\[%s\\+%i\\]\\s*,\\s*%%[a-z]+[0-9]+;',outvar,width*(kk-1));
                outstoreinstr=regexp(ptxbody,outvarpat,'match');

                for jj=1:numel(outstoreinstr)
                    outmovinstr=regexprep(outstoreinstr{jj},'st\.param','mov');
                    outmovinstr=regexprep(outmovinstr,sprintf('\\[%s\\+%i\\]',outvar,width*(kk-1)),outReg{kk});
                    ptxbody=regexprep(ptxbody,outvarpat,outmovinstr,'once');
                end

            end


            noOffset='';
            if isComplex(type)
                ptxbody=obj.replaceLoadInstructions(ptxbody,invars,inReg(1:2:end),noOffset);
                bytes=sprintf('\\+%i',width);
                ptxbody=obj.replaceLoadInstructions(ptxbody,invars,inReg(2:2:end),bytes);
            else
                ptxbody=obj.replaceLoadInstructions(ptxbody,invars,inReg,noOffset);
            end


            ptxbody=regexprep(ptxbody,'BB[0-9]+_[0-9]+',sprintf('$0_%s',endlabel(2:end)));

            ptxbody=[...
ptxbody...
            ,newline...
            ,formatLabel(obj,'',endlabel)...
            ];

        end


        function[ver,tgt,addr64]=getVersionAndTarget(obj)
            ver=['.version ',obj.Codetable.PTXVersion];
            tgt=['.target ',obj.Codetable.TargetArch];
            addr64='.address_size 64';
        end




        function instr=initializeMRG32K3A(obj,internalState,linearThreadID)

            [r1,r2,r3]=getRandStateRegisters(internalState);

            fstruct=obj.Codetable.randInit_d;
            funcName=manageFunc(internalState,fstruct);

            h1=rGet(internalState);
            l1=rGet(internalState);
            h2=rGet(internalState);
            l2=rGet(internalState);
            h3=rGet(internalState);
            l3=rGet(internalState);

            machineptr=getMachineptr(internalState);
            randstateptr=ptrGet(internalState);

            instr=[...
            formatInstruction(obj,['ld.param',machineptr],'',randstateptr,['[',obj.RandState,']'])...
            ,formatInstruction(obj,'ld.global.u32','',h1,['[',randstateptr,'+0]'])...
            ,formatInstruction(obj,'ld.global.u32','',l1,['[',randstateptr,'+4]'])...
            ,formatInstruction(obj,'ld.global.u32','',h2,['[',randstateptr,'+8]'])...
            ,formatInstruction(obj,'ld.global.u32','',l2,['[',randstateptr,'+12]'])...
            ,formatInstruction(obj,'ld.global.u32','',h3,['[',randstateptr,'+16]'])...
            ,formatInstruction(obj,'ld.global.u32','',l3,['[',randstateptr,'+20]'])...
            ];





            [randStateArray,randStateArrayDecl]=iManageLocalOuts(funcName,8,24);
            callinstr=sprintf('call.uni (%s), %s,',randStateArray,funcName);





            instr=[...
instr...
            ,sprintf('{\n%s;\n',randStateArrayDecl),...
            formatInstruction(obj,callinstr,'initialize random number generator state',['(',linearThreadID,',',h1,',',l1,',',h2,',',l2,',',h3,',',l3,')'])...
            ,formatInstruction(obj,'ld.param.u64','randState array to reg',r1,['[',randStateArray,'+0]'])...
            ,formatInstruction(obj,'ld.param.u64','',r2,['[',randStateArray,'+8]'])...
            ,formatInstruction(obj,'ld.param.u64','',r3,['[',randStateArray,'+16]'])...
            ,sprintf('}\n'),...
            ];
        end

        function[instr,rsample]=sampleMRG32K3A(obj,internalState)








            [randReg1,randReg2,randReg3]=getRandStateRegisters(internalState);
            rsample=fdGet(internalState);



            fstructAdvanceState1=obj.Codetable.getHalfStepState1_j;
            funcNameAdvanceState1=manageFunc(internalState,fstructAdvanceState1);

            fstructAdvanceState2=obj.Codetable.getHalfStepState2_j;
            funcNameAdvanceState2=manageFunc(internalState,fstructAdvanceState2);



            fstructSample=obj.Codetable.getSample_d;
            funcNameSample=manageFunc(internalState,fstructSample);


            instr='';
            regSample={fdGet(internalState),fdGet(internalState)};

            for kk=1:2



                state32_0=rGet(internalState);
                state32_1=rGet(internalState);
                state32_2=rGet(internalState);
                state32_3=rGet(internalState);
                state32_4=rGet(internalState);
                state32_5=rGet(internalState);


                x1=rGet(internalState);
                call=sprintf('call.uni (%s), %s,',x1,funcNameAdvanceState1);
                callhalf1=formatInstruction(obj,call,'',['(',state32_0,',',state32_1,')']);

                x2=rGet(internalState);
                call=sprintf('call.uni (%s), %s,',x2,funcNameAdvanceState2);
                callhalf2=formatInstruction(obj,call,'',['(',state32_3,',',state32_5,')']);


                call=sprintf('call.uni (%s), %s,',regSample{kk},funcNameSample);
                callsample=formatInstruction(obj,call,'',['(',x1,',',x2,')']);

                instr=[...
instr...
                ,formatInstruction(obj,'mov.b64','load state',['{',state32_0,',',state32_1,'}'],randReg1)...
                ,formatInstruction(obj,'mov.b64','',['{',state32_2,',',state32_3,'}'],randReg2)...
                ,formatInstruction(obj,'mov.b64','',['{',state32_4,',',state32_5,'}'],randReg3)...
                ,callhalf1...
                ,callhalf2...
                ,formatInstruction(obj,'mov.b64','shuffle',randReg1,['{',state32_1,',',state32_2,'}'])...
                ,formatInstruction(obj,'mov.b64','',randReg2,['{',x1,',',state32_4,'}'])...
                ,formatInstruction(obj,'mov.b64','',randReg3,['{',state32_5,',',x2,'}'])...
                ,callsample...
                ];%#ok<AGROW>

            end



            typeOfCalc=parallel.internal.types.Atomic.buildAtomic('double',false);
            [constinstr,regconst,~]=constant(obj,internalState,typeOfCalc,'5.9604644775390625e-08');
            [oneinstr,regone,~]=constant(obj,internalState,typeOfCalc,'1');

            rt0=fdGet(internalState);
            rt1=fdGet(internalState);
            rt2=fdGet(internalState);
            rt3=fdGet(internalState);

            pred=pGet(internalState);

            instr=[...
instr...
            ,constinstr...
            ,oneinstr...
            ,formatInstruction(obj,'mul.f64','',rt0,regSample{2},regconst)...
            ,formatInstruction(obj,'add.f64','',rt1,regSample{1},rt0)...
            ,formatInstruction(obj,'mov.f64','',rt2,rt1)...
            ,formatInstruction(obj,'sub.f64','',rt3,rt1,regone)...
            ,formatInstruction(obj,'setp.lt.f64','',pred,rt1,regone)...
            ,formatInstruction(obj,'selp.f64','',rsample,rt2,rt3,pred)...
            ];

        end






























        function instr=unpackLastStateElement(obj,internalState,randstateptr,byteOffset)

            lastWasBoxMuller=getRandom123LastWasBoxMuller(internalState);
            randCounter=getRandom123Counter(internalState);




            lowTwoBits=rGet(internalState);
            lastBit=rGet(internalState);

            instr=[...
...
            formatInstruction(obj,'ld.global.u32','',randCounter,['[',randstateptr,'+ ',num2str(byteOffset),+' ]'])...
...
...
...
            ,formatInstruction(obj,'mov.b32','',lastBit,'0x80000000')...
            ,formatInstruction(obj,'and.b32','',lastWasBoxMuller,randCounter,lastBit)...
...
...
...
            ,formatInstruction(obj,'mov.u32','3U',lowTwoBits,'3')...
            ,formatInstruction(obj,'and.b32','',randCounter,randCounter,lowTwoBits)...
            ];
        end

        function instr=initializeThreefry(obj,internalState,linearThreadID)






            keyRegisters=getRandom123KeyRegisters(internalState);
            counterRegisters=getRandom123CounterRegisters(internalState);


            random123CacheRegisters=getRandom123CacheRegisters(internalState);
            N=numel(random123CacheRegisters);

            machineptr=getMachineptr(internalState);
            randstateptr=ptrGet(internalState);
            instr=formatInstruction(obj,['ld.param',machineptr],'',randstateptr,['[',obj.RandState,']']);

            K=numel(keyRegisters);
            for kk=1:K

                high=rGet(internalState);
                low=rGet(internalState);

                offset0=8*(kk-1);
                offset4=offset0+4;

                instr=[...
instr...
                ,formatInstruction(obj,'ld.global.u32','',high,['[',randstateptr,'+',num2str(offset0),']'])...
                ,formatInstruction(obj,'ld.global.u32','',low,['[',randstateptr,'+',num2str(offset4),']'])...
                ,formatInstruction(obj,'mov.b64','',keyRegisters{kk},['{',low,',',high,'}'])...
                ];%#ok<AGROW>

            end

            C=numel(counterRegisters);
            for kk=1:C

                high=rGet(internalState);
                low=rGet(internalState);

                offset0=8*(kk-1+K);
                offset4=offset0+4;

                instr=[...
instr...
                ,formatInstruction(obj,'ld.global.u32','',high,['[',randstateptr,'+',num2str(offset0),']'])...
                ,formatInstruction(obj,'ld.global.u32','',low,['[',randstateptr,'+',num2str(offset4),']'])...
                ,formatInstruction(obj,'mov.b64','',counterRegisters{kk},['{',low,',',high,'}'])...
                ];%#ok<AGROW>

            end


            carrypred=pGet(internalState);
            zeropred=pGet(internalState);

            linearThreadId64Bit=rdGet(internalState);
            countertmp1=rdGet(internalState);
            cvtinstr=formatInstruction(obj,'cvt.u64.u32','',linearThreadId64Bit,linearThreadID);

            skiplabel=labelGet(internalState);

            initregcache=callRandom123(obj,internalState,random123CacheRegisters,N,counterRegisters,keyRegisters);

            disreg=rdGet(internalState);
            initFlag=getBoxMullerInitFlag(internalState);





            substreamLowWord=counterRegisters{3};
            substreamHighWord=counterRegisters{4};

            incrementSubstreamInstructions=[...
cvtinstr...
            ,formatInstruction(obj,'sub.u64','0xffffffffffffffff',disreg,'18446744073709551615',substreamLowWord)...
            ,formatInstruction(obj,'setp.lt.u64','',carrypred,disreg,linearThreadId64Bit)...
            ,formatInstruction(obj,'add.u64','',substreamLowWord,substreamLowWord,linearThreadId64Bit)...
            ,formatInstruction(obj,'add.u64','',countertmp1,substreamHighWord,'1')...
            ,formatInstruction(obj,'selp.u64','',substreamHighWord,countertmp1,substreamHighWord,carrypred)...
            ];




            counterinstr=unpackLastStateElement(obj,internalState,randstateptr,64);

            instr=[...
instr...
            ,counterinstr...
            ,formatInstruction(obj,'setp.eq.u32','',zeropred,linearThreadID,'0')...
            ,conditionalBranchToLabel(obj,zeropred,skiplabel)...
            ,incrementSubstreamInstructions...
            ,formatLabel(obj,'',skiplabel)...
            ,initregcache...
            ,formatInstruction(obj,'mov.u32','init flag for box-Muller',initFlag,'0')...
            ];
        end

        function instr=initializePhilox(obj,internalState,linearThreadID)






            keyRegisters=getRandom123KeyRegisters(internalState);
            counterRegisters=getRandom123CounterRegisters(internalState);


            random123CacheRegisters=getRandom123CacheRegisters(internalState);
            N=numel(random123CacheRegisters);

            machineptr=getMachineptr(internalState);
            randstateptr=ptrGet(internalState);
            instr=formatInstruction(obj,['ld.param',machineptr],'',randstateptr,['[',obj.RandState,']']);

            K=numel(keyRegisters);
            for kk=1:K
                instr=[...
instr...
                ,formatInstruction(obj,'ld.global.u32','',keyRegisters{kk},['[',randstateptr,'+',num2str(4*(kk-1)),']'])...
                ];%#ok<AGROW>
            end

            C=numel(counterRegisters);
            for kk=1:C
                instr=[...
instr...
                ,formatInstruction(obj,'ld.global.u32','',counterRegisters{kk},['[',randstateptr,'+',num2str(4*(kk-1+K)),']'])...
                ];%#ok<AGROW>
            end


            carrypred=pGet(internalState);
            zeropred=pGet(internalState);

            linearThreadId32Bit=rGet(internalState);
            countertmp1=rGet(internalState);
            cvtinstr=formatInstruction(obj,'mov.u32','',linearThreadId32Bit,linearThreadID);

            skiplabel=labelGet(internalState);

            initregcache=callRandom123(obj,internalState,random123CacheRegisters,N,counterRegisters,keyRegisters);

            disreg=rGet(internalState);
            initFlag=getBoxMullerInitFlag(internalState);





            substreamLowWord=counterRegisters{3};
            substreamHighWord=counterRegisters{4};
            incrementSubstreamInstructions=[...
cvtinstr...
            ,formatInstruction(obj,'sub.u32','0xffffffff',disreg,'4294967295',substreamLowWord)...
            ,formatInstruction(obj,'setp.lt.u32','',carrypred,disreg,linearThreadId32Bit)...
            ,formatInstruction(obj,'add.u32','',substreamLowWord,substreamLowWord,linearThreadId32Bit)...
            ,formatInstruction(obj,'add.u32','',countertmp1,substreamHighWord,'1')...
            ,formatInstruction(obj,'selp.u32','',substreamHighWord,countertmp1,substreamHighWord,carrypred)...
            ];




            counterinstr=unpackLastStateElement(obj,internalState,randstateptr,24);

            instr=[...
instr...
            ,counterinstr...
            ,formatInstruction(obj,'setp.eq.u32','',zeropred,linearThreadID,'0')...
            ,conditionalBranchToLabel(obj,zeropred,skiplabel)...
            ,incrementSubstreamInstructions...
            ,formatLabel(obj,'',skiplabel)...
            ,initregcache...
            ,formatInstruction(obj,'mov.u32','init flag for box-Muller',initFlag,'0')...
            ];
        end

        function instr=incrementRandom123Counter(obj,internalState,counterRegisters)



            args=sprintf('%s,',counterRegisters{1:(end-1)});
            args=sprintf('(%s%s)',args,counterRegisters{end});

            switch getRandGeneratorType(internalState)
            case 'Threefry4x64_20'
                kname='threefry4x64Increment_m';
            case 'Philox4x32_10'
                kname='philox4x32Increment_j';
            end

            fstruct=obj.Codetable.(kname);
            incrfunc=manageFunc(internalState,fstruct);

            N=numel(counterRegisters);
            counterType=getRandom123CounterType(internalState);
            width=obj.typesize(counterType);
            wordsuf=getRandom123WordSuf(internalState);

            movinstr='';







            [counter,counterDecl]=iManageLocalOuts('random123Incre',16,N*width);

            for kk=1:N
                movinstr=[...
movinstr...
                ,formatInstruction(obj,['ld.param',wordsuf],'',counterRegisters{kk},sprintf('[%s+%i]',counter,width*(kk-1)))...
                ];%#ok
            end

            call=sprintf('call.uni (%s), %s,',counter,incrfunc);
            incrinstr=formatInstruction(obj,call,'',args);

            instr=[...
            sprintf('{\n%s;\n',counterDecl),...
incrinstr...
            ,movinstr...
            ,sprintf('}\n'),...
            ];

        end

        function instr=callRandom123(obj,internalState,random123CacheRegisters,N,counterRegisters,keyRegisters)




            args=sprintf('%s,',counterRegisters{:},keyRegisters{1:(end-1)});
            args=sprintf('(%s%s)',args,keyRegisters{end});

            movinstr='';

            switch getRandGeneratorType(internalState)
            case 'Threefry4x64_20'
                kname='threefry4x64_d';
            case 'Philox4x32_10'
                kname='philox4x32_d';
            end

            fstruct=obj.Codetable.(kname);
            randfunc=manageFunc(internalState,fstruct);


            [randsample,randsampleDecl]=iManageLocalOuts('random123',16,N*8);

            for kk=1:N
                movinstr=[...
movinstr...
                ,formatInstruction(obj,'ld.param.f64','',random123CacheRegisters{kk},sprintf('[%s+%i]',randsample,8*(kk-1)))...
                ];%#ok
            end

            call=sprintf('call.uni (%s), %s,',randsample,randfunc);
            sampleinstr=formatInstruction(obj,call,'',args);

            instr=[...
            sprintf('{\n%s;\n',randsampleDecl),...
sampleinstr...
            ,movinstr...
            ,sprintf('}\n'),...
            ];

        end

        function[instr,rsample]=sampleRandom123(obj,internalState)

            counterRegisters=getRandom123CounterRegisters(internalState);
            keyRegisters=getRandom123KeyRegisters(internalState);

            random123CacheRegisters=getRandom123CacheRegisters(internalState);
            N=numel(random123CacheRegisters);

            samplegeneratorinstr=callRandom123(obj,internalState,random123CacheRegisters,N,counterRegisters,keyRegisters);

            pred=pGet(internalState);
            skiplabel=labelGet(internalState);
            rsample=fdGet(internalState);

            randCounter=getRandom123Counter(internalState);


            selectreginstr=formatInstruction(obj,'mov.f64','',rsample,random123CacheRegisters{1});


            for kk=2:N
                spred=pGet(internalState);
                iterate=sprintf('%i',(kk-1));
                selectreginstr=[...
selectreginstr...
                ,formatInstruction(obj,'setp.eq.u32','',spred,randCounter,iterate)...
                ,formatInstruction(obj,'selp.f64','',rsample,random123CacheRegisters{kk},rsample,spred)...
                ];%#ok
            end

            endrand123=labelGet(internalState);
            numsamples=sprintf('%i',numel(getRandom123CacheRegisters(internalState)));

            incrementcounterinstr=incrementRandom123Counter(obj,internalState,counterRegisters);

            instr=[...
...
            formatInstruction(obj,'setp.ne.u32','',pred,randCounter,numsamples)...
...
            ,conditionalBranchToLabel(obj,pred,skiplabel)...
...
            ,formatInstruction(obj,'mov.u32','',randCounter,'0')...
            ,incrementcounterinstr...
            ,samplegeneratorinstr...
            ,formatLabel(obj,'',skiplabel)...
            ,selectreginstr...
...
...
            ,formatInstruction(obj,'add.u32','',randCounter,randCounter,'1')...
            ,formatLabel(obj,'',endrand123)...
            ];

        end

        function[instr,regTransform]=normalTransformInversion(obj,internalState,regSample)


            fstructRandnConvert=obj.Codetable.NormalConversionInversion_d;
            funcNameRandnConvert=manageFunc(internalState,fstructRandnConvert);

            regTransform=fdGet(internalState);
            call=sprintf('call.uni (%s), %s,',regTransform,funcNameRandnConvert);
            instr=formatInstruction(obj,call,'',['(',regSample,')']);

        end

        function instr=callBoxMuller(obj,internalState,regOut1,regOut2,regU0,regU1)

            fstruct=obj.Codetable.NormalConversionBoxMuller_cd;
            transformfunc=manageFunc(internalState,fstruct);

            args=sprintf('(%s, %s)',regU0,regU1);

            [normalSample,normalSampleDecl]=iManageLocalOuts('boxmuller_outs',16,16);

            movinstr=[...
            formatInstruction(obj,'ld.param.f64','',regOut1,sprintf('[%s+0]',normalSample))...
            ,formatInstruction(obj,'ld.param.f64','',regOut2,sprintf('[%s+8]',normalSample))...
            ];

            call=sprintf('call.uni (%s), %s, ',normalSample,transformfunc);
            sampleinstr=formatInstruction(obj,call,'',args);

            instr=[...
            sprintf('{\n%s;\n',normalSampleDecl),...
sampleinstr...
            ,movinstr...
            ,sprintf('}\n'),...
            ];

        end

        function[instr,regTransform]=normalTransformBoxMuller(obj,internalState)




            normalRegisters=getBoxMullerCacheRegisters(internalState);
            uniformRegisters=getRandom123CacheRegisters(internalState);

            transforminstr='';
            N=numel(uniformRegisters)/2;
            for kk=1:N
                offset=2*(kk-1)+1;
                transforminstr=[...
transforminstr...
                ,callBoxMuller(obj,internalState,normalRegisters{offset},normalRegisters{offset+1},uniformRegisters{offset},uniformRegisters{offset+1})...
                ];%#ok
            end


            pred=pGet(internalState);
            transformlabel=labelGet(internalState);
            skiplabel=labelGet(internalState);
            regTransform=fdGet(internalState);

            randnCounter=rGet(internalState);
            randCounter=getRandom123Counter(internalState);

            selectreginstr=formatInstruction(obj,'mov.f64','',regTransform,normalRegisters{1});
            N=N*2;
            for kk=2:N
                spred=pGet(internalState);
                iterate=sprintf('%i',(kk-1));
                selectreginstr=[...
selectreginstr...
                ,formatInstruction(obj,'setp.eq.u32','',spred,randnCounter,iterate)...
                ,formatInstruction(obj,'selp.f64','',regTransform,normalRegisters{kk},regTransform,spred)...
                ];%#ok
            end




            initFlag=getBoxMullerInitFlag(internalState);
            valid=pGet(internalState);

            endinit=labelGet(internalState);

            initinstr=[...
            formatInstruction(obj,'setp.ne.u32','',valid,initFlag,'0')...
            ,conditionalBranchToLabel(obj,valid,endinit)...
            ,formatInstruction(obj,'mov.u32','',initFlag,'1')...
            ,branchToLabel(obj,transformlabel)...
            ,formatLabel(obj,'',endinit)...
            ];

            endnormal=labelGet(internalState);

            instr=[...
            formatInstruction(obj,'sub.u32','',randnCounter,randCounter,'1')...
            ,initinstr...
            ,formatInstruction(obj,'setp.ne.u32','',pred,randnCounter,'0')...
            ,conditionalBranchToLabel(obj,pred,skiplabel)...
            ,formatLabel(obj,'',transformlabel)...
            ,transforminstr...
            ,formatLabel(obj,'',skiplabel)...
            ,selectreginstr...
            ,formatLabel(obj,'',endnormal)...
            ];

        end



        function boundcheckregs=getRegistersForBoundsChecks(obj,internalState,N)%#ok
            boundcheckregs=cell(1,N);
            boundcheckregs=cellfun(@(x)(pGet(internalState)),boundcheckregs,'UniformOutput',false);
        end

        function[instr,offset]=computeCoordinateOffset(obj,internalState,boundcheckregs,type,ptrshape,coordinateTypes,coordinateIndices,numOfIndices)






            typeUint32=parallel.internal.types.Atomic.buildAtomic('uint32',false);

            [init1,reg1]=constant(obj,internalState,typeUint32,'1');
            [initoffset,offset]=constant(obj,internalState,typeUint32,'0');
            regmaxlast=reg1;




            rprod=rGet(internalState);

            instr=[...
init1...
            ,initoffset...
            ,formatInstruction(obj,'mov.u32','',rprod,'1')...
            ];


            for kk=1:numOfIndices

                currentType=coordinateTypes{kk};
                currentIndex=coordinateIndices{kk};


                flintcheckinstr='';
                if isFloatingPoint(currentType)
                    flintcheckinstr=checkIfFlint(obj,internalState,currentType,currentIndex);
                end


                [cvtinstr,currentIndex]=castreg(obj,internalState,typeUint32,currentType,currentIndex,'');

                if isScalar(type)
                    getcoordinateinstr='';
                    regmax=reg1;
                else
                    [getcoordinateinstr,regmax]=fetchCoordinate(obj,internalState,ptrshape,kk);
                end

                boundcheckreg=boundcheckregs{kk};
                boundscheckinstr=indexBoundsCheck(obj,internalState,boundcheckreg,currentIndex,reg1,regmax);


                shift=rGet(internalState);

                updateoffset=[...
                formatInstruction(obj,'sub.u32','',currentIndex,currentIndex,'1')...
                ,formatInstruction(obj,'mul.lo.u32','',rprod,rprod,regmaxlast)...
                ,formatInstruction(obj,'mul.lo.u32','',shift,currentIndex,rprod)...
                ,formatInstruction(obj,'add.u32','',offset,offset,shift)...
                ];

                regmaxlast=regmax;

                instr=[...
instr...
                ,flintcheckinstr...
                ,getcoordinateinstr...
                ,cvtinstr...
                ,boundscheckinstr...
                ,updateoffset...
                ];%#ok

            end

        end

        function instr=indexBoundsCheck(obj,internalState,errorreg,reg,regmin,regmax)

            pred1=pGet(internalState);
            pred2=pGet(internalState);

            instr=[...
            formatInstruction(obj,'setp.lt.u32','',pred1,reg,regmin)...
            ,formatInstruction(obj,'setp.lt.u32','',pred2,regmax,reg)...
            ,formatInstruction(obj,'or.pred','',errorreg,pred1,pred2)...
            ];

        end

        function instr=linearIndexBoundsCheck(obj,internalState,reg,regmin,regmax)

            checkreg=rGet(internalState);
            type4Check=parallel.internal.types.Atomic.buildAtomic('uint32',false);
            sufo=makeKey(type4Check);

            kname=['errorIfIndexIsOutOfBounds_',sufo];
            fstruct=obj.Codetable.(kname);
            funcName=manageFunc(internalState,fstruct);

            callinstr=sprintf('call.uni (%s), %s,',checkreg,funcName);



            instr=[...
            formatInstruction(obj,callinstr,'',sprintf('(%s,%s,%s)',reg,regmin,regmax))...
            ,exitIfRegisterIsTrue(obj,internalState,checkreg)...
            ];

        end

        function instr=coordinatesBoundCheck(obj,internalState,N,boundcheckregs)

            allchecksreg=pGet(internalState);
            instr=formatInstruction(obj,'mov.pred','',allchecksreg,boundcheckregs{1});
            for kk=2:N
                boundcheckreg=boundcheckregs{kk};
                instr=[...
instr...
                ,formatInstruction(obj,'or.pred','',allchecksreg,allchecksreg,boundcheckreg)...
                ];%#ok
            end

            outofboundsreg=rGet(internalState);
            zeroreg=rGet(internalState);

            pred=pGet(internalState);
            skiplabel=labelGet(internalState);

            instr=[...
instr...
            ,formatInstruction(obj,'not.pred','',pred,allchecksreg)...
            ,conditionalBranchToLabel(obj,pred,skiplabel)...
            ,formatInstruction(obj,'mov.u32','',outofboundsreg,'1')...
            ,formatInstruction(obj,'mov.u32','',zeroreg,'0')...
            ,linearIndexBoundsCheck(obj,internalState,outofboundsreg,zeroreg,zeroreg)...
            ,formatLabel(obj,'',skiplabel)...
            ];

        end

        function[instr,regmax]=prodShapeinfo(obj,internalState,ptrshape,numOfDims)



            cacheop='.ca';

            suf='.u32';
            wordsize=4;

            regmax=rGet(internalState);
            instr=formatInstruction(obj,['mov',suf],'',regmax,'1');

            for kk=1:numOfDims

                reg=rGet(internalState);
                offsetBytes=wordsize*kk;

                instr=[...
instr...
                ,formatInstruction(obj,['ld.const',cacheop,suf],'',reg,sprintf('[%s+%i]',ptrshape,offsetBytes))...
                ,formatInstruction(obj,['mul.lo',suf],'',regmax,regmax,reg)...
                ];%#ok

            end

        end

        function[instr,regcoordinate]=fetchCoordinate(obj,internalState,ptrshape,id)

            regcoordinate=rGet(internalState);



            cacheop='.ca';

            suf='.u32';
            wordsize=4;
            offsetBytes=id*wordsize;

            instr=formatInstruction(obj,['ld.const',cacheop,suf],'',regcoordinate,sprintf('[%s+%i]',ptrshape,offsetBytes));

        end





        function instr=loadElement(obj,internalState,type,outregReal,outregImag,ptrdata,ptrshape,offset)


            lireg=ptrGet(internalState);
            target=ptrGet(internalState);

            suf=regsuffix(obj,type);

            if isScalar(type)

                instr=formatInstruction(obj,['mov',suf],'',outregReal,ptrdata);
                if isComplex(type)
                    instr=[...
instr...
                    ,formatInstruction(obj,['mov',suf],'',outregImag,ptrshape)...
                    ];
                end

            else

                machineptr=getMachineptr(internalState);
                numOfBytes=wordwidth(obj,type);

                if strcmp(machineptr,'.u64')
                    convertoffset=formatInstruction(obj,['cvt',machineptr,'.u32'],'',lireg,offset);
                else
                    convertoffset=formatInstruction(obj,['mov',machineptr],'',lireg,offset);
                end

                instr=[...
convertoffset...
                ,formatInstruction(obj,['mad.lo',machineptr],'',target,lireg,numOfBytes,ptrdata)...
                ];



                cacheop='.ca';

                if isComplex(type)
                    loadinstr=formatInstruction(obj,[obj.Instr.ldg,cacheop,'.v2',suf],'',...
                    ['{',outregReal],[outregImag,'}'],['[',target,'+0]']);
                elseif isLogical(type)

                    loadinstr=formatInstruction(obj,[obj.Instr.ldg,cacheop,'.s8'],'',outregReal,['[',target,'+0]']);
                else
                    loadinstr=formatInstruction(obj,[obj.Instr.ldg,cacheop,suf],'',outregReal,['[',target,'+0]']);
                end

                instr=[...
instr...
                ,loadinstr...
                ];

            end

        end




        function instr=rangeCheckUint(obj,internalState,reg,regmin,regmax)

            returnReg=rGet(internalState);
            type4Check=parallel.internal.types.Atomic.buildAtomic('uint32',false);
            sufo=makeKey(type4Check);

            kname=['errorIfUintIsOutOfRange_',sufo];
            fstruct=obj.Codetable.(kname);
            funcName=manageFunc(internalState,fstruct);

            callinstr=sprintf('call.uni (%s), %s,',returnReg,funcName);
            instr=[...
            formatInstruction(obj,callinstr,'',sprintf('(%s,%s,%s)',reg,regmin,regmax))...
            ,exitIfRegisterIsTrue(obj,internalState,returnReg)...
            ];

        end



        function[instr,mask]=constructBitMaskWithRangeCheck(obj,internalState,type,reg)


            mask=tGet(internalState,type);
            shift=tGet(internalState,type);
            regsuf=regsuffixForOperation(obj,type);

            nbits=nonSignBits(type);
            [loadnbits,rnbits]=constant(obj,internalState,coerceScalar(type),sprintf('%i',nbits));

            type4Check=parallel.internal.types.Atomic.buildAtomic('uint32',false);
            [loadone,rone]=constant(obj,internalState,type4Check,'1');

            rangecheckinstr=rangeCheckUint(obj,internalState,reg,rone,rnbits);


            maskinstr=[...
            formatInstruction(obj,['sub',regsuf],'',shift,reg,'1')...
            ,formatInstruction(obj,'shl.b32','',mask,'1',shift)...
            ];

            instr=[...
loadone...
            ,loadnbits...
            ,rangecheckinstr...
            ,maskinstr...
            ];

        end

    end


    methods(Access=public,Hidden=true)



        function obj=ptxEmitter(fcnName,fcnType)

            dev=parallel.gpu.GPUDevice.current();


            obj.Instr=struct;
            obj.Instr.ldp='ld.param';
            obj.Instr.ldg='ld.global';
            obj.Instr.stg='st.global';


            [obj.ComputeCapability,obj.Interruptible,obj.Codetable]=...
            parallel.internal.ptx.ptxEmitter.getCodetable(dev);

            if contains(fcnType,'anonymous')
                fname='ANON';
            else
                fname=fcnName;
            end

            z=sprintf('_Z%d',numel(fname));
            g=obj.Pfs;


            obj.Basename=sprintf('__cudaparm_%s%s%s',z,fname,g);
            obj.RandState=sprintf('__cudaparm__randstate%s%s%s',z,fname,g);


            memoryNames=feval('_gpu_PtxErrorSymbols');
            obj.BlockAddress=memoryNames{1};
            obj.InterruptPtrAddress=memoryNames{2};


            obj.Com=struct;
            obj.Com.gridDimx='gridDim.x';
            obj.Com.blockIdxy='blockIdx.y';
            obj.Com.blockIdxx='blockIdx.x';
            obj.Com.blockDimx='blockDim.x';
            obj.Com.threadIdxx='threadIdx.x';

            obj.Com.width='by width of input data';
            obj.Com.vector='vector element';
            obj.Com.scalar='scalar variable';

            obj.Com.checksize='check against size of input';
            obj.Com.endofvec='off end of vector';


            obj.Enterlabel=['$LENT_MW_',z,fname,g];
            obj.Epiloguelabel=['$LEPI_MW_',z,fname,g];
            obj.Exitlabel=['$LEXT_MW_',z,fname,g];
            obj.Ender=['$LDWend_MW_',z,fname,g,':',newline];


            obj.DebugState=false;

        end





        function interruptible=supportsInterrupt(obj)
            interruptible=obj.Interruptible;
        end



        function enabled=emitPtxWithComments(obj)
            enabled=obj.DebugState;
        end




        function instr=formatComment(obj,comment)
            instr='';
            if~isempty(comment)&&emitPtxWithComments(obj)
                instr=sprintf('// %s\n',comment);
            end
        end

        function instr=formatLabel(obj,comment,label)
            if~isempty(comment)&&emitPtxWithComments(obj)
                instr=sprintf('%s:   // %s\n',label,comment);
            else
                instr=sprintf('%s:\n',label);
            end
        end




        function fstruct=getRandInitFcn(obj)
            fstruct=obj.Codetable.randInit_d;
        end

        function fstruct=getErrorCheckFcn(obj)
            fstruct=obj.Codetable.isErrorFlagSet_b;
        end




        function instr=branchToEpilogue(obj)
            instr=formatInstruction(obj,'bra','return statement',obj.Epiloguelabel);
        end


        function instr=branchToLabel(obj,label)
            instr=formatInstruction(obj,'bra','',label);
        end


        function instr=conditionalBranchToLabel(obj,branchreg,label)
            instr=formatInstruction(obj,['@',branchreg,' bra'],'',label);
        end




        function instr=arraySizeCheck(obj,internalState,gtid)

            plab=labelGet(internalState);
            rbail=rGet(internalState);
            pbail=pGet(internalState);

            arraySize=['[',obj.Basename,'_',obj.SizeVariable,']'];

            instr=[...
            formatInstruction(obj,[obj.Instr.ldp,'.s32'],'',rbail,arraySize)...
            ,formatInstruction(obj,'setp.gt.s32','',pbail,rbail,gtid)...
            ,formatInstruction(obj,['@',pbail,' bra'],obj.Com.checksize,plab)...
            ,formatInstruction(obj,'bra.uni',obj.Com.endofvec,obj.Exitlabel)...
            ,formatLabel(obj,'',plab)...
            ];

        end


        function instr=voidcall(obj,internalState,typeOut,outregReal,fn)
            kname=[fn,'_',makeKey(coerceScalar(typeOut))];
            fstruct=obj.Codetable.(kname);
            funcName=manageFunc(internalState,fstruct);
            callinstr=sprintf('call (%s), %s',outregReal,funcName);
            instr=formatInstruction(obj,callinstr,'');
        end



        function instr=unacall(obj,internalState,typeOut,outregReal,outregImag,fn,regReal,regImag)

            complexity=isComplex(typeOut);
            if complexity
                fn=['c',fn];
            end

            kname=[fn,'_',makeKey(coerceScalar(typeOut))];
            fstruct=obj.Codetable.(kname);
            funcName=manageFunc(internalState,fstruct);

            if emitAsInlinePTX(internalState,fstruct)
                assert(complexity,'Generating inline code for non-complex function!');

                if isempty(outregImag)
                    outReg={outregReal};
                else
                    outReg={outregReal,outregImag};
                end

                inReg={regReal,regImag};

                endlabel=labelGet(internalState);

                instr=generateInlinePtx(obj,fstruct,typeOut,outReg,inReg,endlabel);
            else
                if complexity

                    width=obj.typesize(typeOut);


                    [larrayin,larrayinDecl]=iManageLocalIns(funcName,width,width,1);


                    isuf=regsuffix(obj,typeOut);


                    bytesElem=sprintf('%i',width/2);

                    if~isempty(outregImag)
                        [larrayout,larrayoutDecl]=iManageLocalOuts(funcName,width,width);
                        call=sprintf('call.uni (%s), %s,',larrayout,funcName);
                        callinstr=formatInstruction(obj,call,'',['(',larrayin,')']);

                        instr=[...
                        sprintf('%s;\n',larrayinDecl),...
                        formatInstruction(obj,['st.param',isuf],'',['[',larrayin,'+0]'],regReal)...
                        ,formatInstruction(obj,['st.param',isuf],'',['[',larrayin,'+',bytesElem,']'],regImag)...
                        ,sprintf('%s;\n',larrayoutDecl),...
callinstr...
                        ,formatInstruction(obj,['ld.param',isuf],'',outregReal,['[',larrayout,'+0]'])...
                        ,formatInstruction(obj,['ld.param',isuf],'',outregImag,['[',larrayout,'+',bytesElem,']'])...
                        ];
                    else
                        call=sprintf('call.uni (%s), %s,',outregReal,funcName);
                        callinstr=formatInstruction(obj,call,'',['(',larrayin,')']);

                        instr=[...
                        sprintf('%s;\n',larrayinDecl),...
                        formatInstruction(obj,['st.param',isuf],'',['[',larrayin,'+0]'],regReal)...
                        ,formatInstruction(obj,['st.param',isuf],'',['[',larrayin,'+',bytesElem,']'],regImag)...
                        ,callinstr...
                        ];
                    end
                    instr=[...
                    sprintf('{\n'),...
                    instr,...
                    sprintf('}\n'),...
                    ];
                else

                    callinstr=sprintf('call.uni (%s), %s,',outregReal,funcName);
                    instr=formatInstruction(obj,callinstr,'',['(',regReal,')']);
                end
            end
        end



        function instr=bincall(obj,internalState,typeOut,outregReal,outregImag,fn,regReal1,regImag1,regReal2,regImag2)

            complexity=isComplexFloatingPoint(typeOut);
            if complexity
                fn=['c',fn];
            end

            kname=[fn,'_',makeKey(coerceScalar(typeOut))];
            fstruct=obj.Codetable.(kname);
            funcName=manageFunc(internalState,fstruct);

            if emitAsInlinePTX(internalState,fstruct)
                assert(complexity,'Generating inline code for non-complex function!');

                if isempty(outregImag)
                    outReg={outregReal};
                else
                    outReg={outregReal,outregImag};
                end

                inReg={regReal1,regImag1,regReal2,regImag2};
                endlabel=labelGet(internalState);

                instr=generateInlinePtx(obj,fstruct,typeOut,outReg,inReg,endlabel);
            else
                if complexity

                    width=obj.typesize(typeOut);


                    [larrayout,larrayoutDecl]=iManageLocalOuts(funcName,width,width);
                    [larrayin1,larrayin1Decl]=iManageLocalIns(funcName,width,width,1);
                    [larrayin2,larrayin2Decl]=iManageLocalIns(funcName,width,width,2);


                    isuf=regsuffix(obj,typeOut);


                    bytesElem=sprintf('%i',width/2);
                    call=sprintf('call.uni (%s), %s,',larrayout,funcName);
                    callinstr=formatInstruction(obj,call,'',['(',larrayin1,',',larrayin2,')']);

                    instr=[...
                    sprintf('{\n%s;\n',larrayin1Decl),...
                    formatInstruction(obj,['st.param',isuf],'',['[',larrayin1,'+0]'],regReal1)...
                    ,formatInstruction(obj,['st.param',isuf],'',['[',larrayin1,'+',bytesElem,']'],regImag1)...
                    ,sprintf('%s;\n',larrayin2Decl),...
                    formatInstruction(obj,['st.param',isuf],'',['[',larrayin2,'+0]'],regReal2)...
                    ,formatInstruction(obj,['st.param',isuf],'',['[',larrayin2,'+',bytesElem,']'],regImag2)...
                    ,sprintf('%s;\n',larrayoutDecl),...
callinstr...
                    ,formatInstruction(obj,['ld.param',isuf],'',outregReal,['[',larrayout,'+0]'])...
                    ,formatInstruction(obj,['ld.param',isuf],'',outregImag,['[',larrayout,'+',bytesElem,']'])...
                    ,sprintf('}\n'),...
                    ];

                else

                    callinstr=sprintf('call.uni (%s), %s,',outregReal,funcName);
                    instr=formatInstruction(obj,callinstr,'',['(',regReal1],[regReal2,')']);
                end
            end
        end



        function instr=ternarycall(obj,internalState,typeOut,outregReal,outregImag,fn,regReal1,regImag1,regReal2,regImag2,regReal3,regImag3)%#ok<INUSD,INUSL>




            complexity=isComplexFloatingPoint(typeOut);
            assert(~complexity,'Only real ternary functions are allowed for now');

            kname=[fn,'_',makeKey(coerceScalar(typeOut))];
            fstruct=obj.Codetable.(kname);
            funcName=manageFunc(internalState,fstruct);

            callinstr=sprintf('call.uni (%s), %s,',outregReal,funcName);
            instr=formatInstruction(obj,callinstr,'',['(',regReal1],regReal2,[regReal3,')']);
        end



        function instr=loadBoxedVariable(obj,internalState,mangledName,name,ptrdata,ptrshape,dims)


            dimInfoName=sprintf('__%s',name);

            numOfDims=length(dims);
            sizes=sprintf('%i, ',dims(1:(end-1)));
            sizes=sprintf('%i, %s%i',numOfDims,sizes,dims(end));

            addHeader(internalState,...
            dimInfoName,...
            sprintf('.const .align 4 .u32 %s[%i] = { %s };',dimInfoName,(numOfDims+1),sizes));

            machineptr=getMachineptr(internalState);
            instr=[...
            formatInstruction(obj,[obj.Instr.ldp,machineptr],'loading data',ptrdata,sprintf('[%s]',mangledName))...
            ,formatInstruction(obj,['mov',machineptr],'loading shapeinfo',ptrshape,dimInfoName)...
            ];

        end





        function instr=fetchArrayElementLinearIndexing(obj,internalState,outregReal,outregImag,type,ptrdata,ptrshape,typeIndex,linearIndex,numOfDims)


            typeUint32=parallel.internal.types.Atomic.buildAtomic('uint32',false);


            flintcheckinstr='';
            if isFloatingPoint(typeIndex)
                flintcheckinstr=checkIfFlint(obj,internalState,typeIndex,linearIndex);
            end


            [make1instr,reg1]=constant(obj,internalState,typeUint32,'1');

            if isScalar(type)
                prodinstr='';
                regmax=reg1;
            else
                [prodinstr,regmax]=prodShapeinfo(obj,internalState,ptrshape,numOfDims);
            end

            [cvtinstr,linearIndex]=castreg(obj,internalState,typeUint32,typeIndex,linearIndex,'');
            boundscheckinstr=linearIndexBoundsCheck(obj,internalState,linearIndex,reg1,regmax);

            loadinstr=[...
            formatInstruction(obj,'sub.u32','',linearIndex,linearIndex,'1')...
            ,loadElement(obj,internalState,type,outregReal,outregImag,ptrdata,ptrshape,linearIndex)...
            ];

            instr=[...
flintcheckinstr...
            ,prodinstr...
            ,cvtinstr...
            ,make1instr...
            ,boundscheckinstr...
            ,loadinstr...
            ];

        end





        function instr=fetchArrayElementCoordinateIndexing(obj,internalState,outregReal,outregImag,type,ptrdata,ptrshape,coordinateTypes,coordinateIndices,numOfDims)


            typeUint32=parallel.internal.types.Atomic.buildAtomic('uint32',false);

            N=numel(coordinateTypes);
            boundcheckregs=getRegistersForBoundsChecks(obj,internalState,N);


            [instr,offset]=computeCoordinateOffset(obj,internalState,boundcheckregs,type,ptrshape,coordinateTypes,coordinateIndices,numOfDims);




            [make1instr,reg1]=constant(obj,internalState,typeUint32,'1');

            instr=[...
instr...
            ,make1instr...
            ];

            for kk=(numOfDims+1):N

                currentType=coordinateTypes{kk};
                currentIndex=coordinateIndices{kk};


                flintcheckinstr='';
                if isFloatingPoint(currentType)
                    flintcheckinstr=checkIfFlint(obj,internalState,currentType,currentIndex);
                end


                [cvtinstr,currentIndex]=castreg(obj,internalState,typeUint32,currentType,currentIndex,'');

                boundcheckreg=boundcheckregs{kk};
                boundscheckinstr=indexBoundsCheck(obj,internalState,boundcheckreg,currentIndex,reg1,reg1);

                instr=[...
instr...
                ,flintcheckinstr...
                ,cvtinstr...
                ,boundscheckinstr...
                ];%#ok

            end



            outofboundsinstr=coordinatesBoundCheck(obj,internalState,N,boundcheckregs);
            loadinstr=loadElement(obj,internalState,type,outregReal,outregImag,ptrdata,ptrshape,offset);


            instr=[...
instr...
            ,outofboundsinstr...
            ,loadinstr...
            ];

        end





        function instr=fetchArrayElementFoldIndexing(obj,internalState,outregReal,outregImag,type,ptrdata,ptrshape,coordinateTypes,coordinateIndices,numOfDims)


            typeUint32=parallel.internal.types.Atomic.buildAtomic('uint32',false);



            numOfCoordIndices=numel(coordinateTypes)-1;
            boundcheckregs=getRegistersForBoundsChecks(obj,internalState,numOfCoordIndices);

            [coordoffsetinstr,coordoffset]=computeCoordinateOffset(obj,internalState,boundcheckregs,type,ptrshape,coordinateTypes,coordinateIndices,numOfCoordIndices);
            outofboundsinstr=coordinatesBoundCheck(obj,internalState,numOfCoordIndices,boundcheckregs);



            coordindexinstr=[...
coordoffsetinstr...
            ,outofboundsinstr...
            ];



            [calculatenumelinstr,regnumel]=prodShapeinfo(obj,internalState,ptrshape,numOfDims);



            typeIndex=coordinateTypes{end};
            linearIndex=coordinateIndices{end};

            [make1instr,reg1]=constant(obj,internalState,typeUint32,'1');

            flintcheckinstr='';
            if isFloatingPoint(typeIndex)
                flintcheckinstr=checkIfFlint(obj,internalState,typeIndex,linearIndex);
            end

            [cvtinstr,linearIndex]=castreg(obj,internalState,typeUint32,typeIndex,linearIndex,'');


            [strideinstr,stride]=prodShapeinfo(obj,internalState,ptrshape,numOfCoordIndices);

            offset=rGet(internalState);

            calcoffsetinstr=[...
strideinstr...
            ,formatInstruction(obj,'sub.u32','',linearIndex,linearIndex,'1')...
            ,formatInstruction(obj,'mul.lo.u32','',linearIndex,linearIndex,stride)...
            ,formatInstruction(obj,'add.u32','',offset,coordoffset,linearIndex)...
            ];

            boundscheckinstr=linearIndexBoundsCheck(obj,internalState,offset,reg1,regnumel);


            loadinstr=loadElement(obj,internalState,type,outregReal,outregImag,ptrdata,ptrshape,offset);

            instr=[...
coordindexinstr...
            ,calculatenumelinstr...
            ,flintcheckinstr...
            ,cvtinstr...
            ,make1instr...
            ,calcoffsetinstr...
            ,boundscheckinstr...
            ,loadinstr...
            ];

        end


        function instr=loadSymbol(obj,internalState,symbols,name,rdb)

            symbol=getSymbolIns(symbols,name);
            vtype=symbol.type;
            vreg=symbol.reg;
            vreg2=symbol.reg2;
            suf=regsuffix(obj,vtype);
            width=obj.typesize(vtype);

            variableName=[obj.Basename,'_',name,'in'];

            machineptr=getMachineptr(internalState);

            if isArray(vtype)


                cacheop='.cs';

                rp2=ptrGet(internalState);
                rp3=ptrGet(internalState);

                if isLogical(vtype)

                    instr=[...
                    formatInstruction(obj,[obj.Instr.ldp,machineptr],'',rp2,['[',variableName,']'])...
                    ,formatInstruction(obj,['add',machineptr],'',rp3,rp2,rdb)...
                    ];

                    rp4=rp3;

                    lreg=rhGet(internalState);
                    fetch=[...
                    formatInstruction(obj,[obj.Instr.ldg,cacheop,'.s8'],obj.Com.vector,lreg,['[',rp4,'+0]'])...
                    ,formatInstruction(obj,'cvt.u32.s8','',vreg,lreg)...
                    ];

                else

                    rp4=ptrGet(internalState);

                    instr=[...
                    formatInstruction(obj,[obj.Instr.ldp,machineptr],'',rp3,['[',variableName,']'])...
                    ,formatInstruction(obj,['mul.lo',machineptr],obj.Com.width,rp2,rdb,sprintf('%i',width))...
                    ,formatInstruction(obj,['add',machineptr],'',rp4,rp3,rp2)...
                    ];

                    if isComplex(vtype)
                        fetch=formatInstruction(obj,[obj.Instr.ldg,cacheop,'.v2',suf],obj.Com.vector,...
                        ['{',vreg],[vreg2,'}'],['[',rp4,'+0]']);
                    else
                        fetch=formatInstruction(obj,[obj.Instr.ldg,cacheop,suf],obj.Com.vector,vreg,['[',rp4,'+0]']);
                    end

                end

                instr=[...
instr...
                ,fetch...
                ];

            else

                if isComplex(vtype)
                    width=obj.typesize(coerceReal(vtype));
                    instr=[...
                    formatInstruction(obj,[obj.Instr.ldp,suf],'',vreg,['[',variableName,'+0]'])...
                    ,formatInstruction(obj,[obj.Instr.ldp,suf],'',vreg2,['[',variableName,'+',num2str(width),']'])...
                    ];
                elseif isLogical(vtype)
                    lreg=rhGet(internalState);
                    instr=[...
                    formatInstruction(obj,[obj.Instr.ldp,'.s8'],obj.Com.scalar,lreg,['[',variableName,']'])...
                    ,formatInstruction(obj,'cvt.u32.s8','',vreg,lreg)...
                    ];
                else
                    instr=formatInstruction(obj,[obj.Instr.ldp,suf],obj.Com.scalar,vreg,['[',variableName,']']);
                end

            end

        end

        function instr=loadSymbols(obj,internalState,symbols,names,expansionkey,rdb,gtid)




            if strcmp(getRuleset(internalState),'singleton')&&any(expansionkey=='e')
                instr=loadSymbolsSingletonExpansion(obj,internalState,symbols,names,expansionkey,rdb,gtid);

            else
                instr=loadSymbolsNoExpansion(obj,internalState,symbols,names,rdb);

            end

        end

        function instr=loadSymbolsSingletonExpansion(obj,internalState,symbols,names,expansionkey,rdb,gtid)


            N=numel(expansionkey);



            lido=gtid;
            szo=[obj.Basename,'_',obj.DimArray,'0'];
            ndimo=[obj.Basename,'_',obj.Ndim,'0'];

            ptrsuffix=getMachineptr(internalState);
            rszo=ptrGet(internalState);
            rndimo=rGet(internalState);

            dimloadinstr=[...
            formatInstruction(obj,['ld.param',ptrsuffix],'',rszo,['[',szo,']'])...
            ,formatInstruction(obj,'ld.param.s32','',rndimo,['[',ndimo,']'])...
            ];

            inputs={struct('dim',rszo,'ndim',rndimo)};

            for kk=1:N
                if('e'==expansionkey(kk))


                    sz=[obj.Basename,'_',obj.DimArray,num2str(kk)];
                    ndim=[obj.Basename,'_',obj.Ndim,num2str(kk)];

                    rsz=ptrGet(internalState);
                    rndim=rGet(internalState);

                    dimloadinstr=[...
dimloadinstr...
                    ,formatInstruction(obj,['ld.param',ptrsuffix],'',rsz,['[',sz,']'])...
                    ,formatInstruction(obj,'ld.param.s32','',rndim,['[',ndim,']'])...
                    ];%#ok

                    inputs{end+1}=struct('dim',rsz,'ndim',rndim);%#ok

                end

            end


            [offsetinstr,updatedoffset]=calculateSingletonExpansionOffsets(obj,internalState,lido,inputs{:});

            current=1;
            varloadinstr='';
            for kk=1:N
                if('e'==expansionkey(kk))
                    varloadinstr=[...
varloadinstr...
                    ,loadSymbol(obj,internalState,symbols,names{kk},updatedoffset{current})...
                    ];%#ok
                    current=current+1;
                else
                    varloadinstr=[...
varloadinstr...
                    ,loadSymbol(obj,internalState,symbols,names{kk},rdb)...
                    ];%#ok
                end
            end

            instr={...
dimloadinstr...
            ,offsetinstr...
            ,varloadinstr...
            };
            instr=[instr{:}];
        end

        function instr=loadSymbolsNoExpansion(obj,internalState,symbols,names,rdb)

            nin=numel(names);
            instr=cell(1,nin);

            for kk=1:nin
                instr{kk}=loadSymbol(obj,internalState,symbols,names{kk},rdb);
            end

            instr=[instr{:}];
        end


        function instr=loadImplicitSymbols(obj,internalState,fcnLabel,iR)

            instr='';


            fcnWorkspace=getFcnWorkspaceSymbols(iR,fcnLabel);
            names=getMATLABUplevelVariables(iR);

            N=numel(names);
            for kk=1:N

                name=names{kk};
                symbol=getSymbol(fcnWorkspace,name);



                vtype=symbol.type;
                vreg=symbol.reg;
                vreg2=symbol.reg2;
                suf=regsuffix(obj,vtype);

                variableName=[obj.Basename,'_',name,'in'];

                if isArray(vtype)



                    tmpinstr=loadBoxedVariable(obj,internalState,variableName,name,vreg,vreg2,symbol.shapeinfo.dims);

                else

                    if isComplex(vtype)
                        width=obj.typesize(coerceReal(vtype));
                        tmpinstr=[...
                        formatInstruction(obj,[obj.Instr.ldp,suf],'',vreg,['[',variableName,'+0]'])...
                        ,formatInstruction(obj,[obj.Instr.ldp,suf],'',vreg2,['[',variableName,'+',num2str(width),']'])...
                        ];
                    elseif isLogical(vtype)
                        lreg=rhGet(internalState);
                        tmpinstr=[...
                        formatInstruction(obj,[obj.Instr.ldp,'.s8'],obj.Com.scalar,lreg,['[',variableName,']'])...
                        ,formatInstruction(obj,'cvt.u32.s8','',vreg,lreg)...
                        ];
                    else
                        tmpinstr=formatInstruction(obj,[obj.Instr.ldp,suf],obj.Com.scalar,vreg,['[',variableName,']']);
                    end

                end

                instr=[...
instr...
                ,tmpinstr...
                ];%#ok

            end

        end


        function instr=storeSymbol(obj,internalState,symbols,name,rdb)

            machineptr=getMachineptr(internalState);

            symbol=getSymbol(symbols,name);
            vtype=symbol.type;
            assert(~isempty(vtype),'PTXANALYZER is broken.');

            suf=regsuffix(obj,vtype);
            width=obj.typesize(vtype);


            rp2=ptrGet(internalState);
            rp5=ptrGet(internalState);

            if isLogical(vtype)
                outm=formatInstruction(obj,['add',machineptr],'',rp5,rp2,rdb);
                rp6=rp5;
            else

                rp6=ptrGet(internalState);

                outm=[...
                formatInstruction(obj,['mul.lo',machineptr],obj.Com.width,rp5,rdb,sprintf('%i',width))...
                ,formatInstruction(obj,['add',machineptr],'',rp6,rp5,rp2)...
                ];

            end



            cacheop='.cs';

            variableName=['[',obj.Basename,'_',name,'out]'];

            if isComplex(vtype)
                store=formatInstruction(obj,[obj.Instr.stg,cacheop,'.v2',suf],'',...
                ['[',rp6,'+0]'],['{',symbol.reg],[symbol.reg2,'}']);
            else

                if isLogical(vtype)
                    suf='.s8';
                end

                store=formatInstruction(obj,[obj.Instr.stg,cacheop,suf],'',['[',rp6,'+0]'],symbol.reg);

            end

            instr=[...
            formatInstruction(obj,[obj.Instr.ldp,machineptr],'',rp2,variableName)...
            ,outm...
            ,store...
            ];

        end

        function instr=storeSymbols(obj,internalState,symbols,fcnName,iR,rdb)

            names=getFcnOutputs(iR,fcnName);
            nout=numel(names);
            instr=cell(1,nout);

            for kk=1:nout
                instr{kk}=storeSymbol(obj,internalState,symbols,names{kk},rdb);
            end

            instr=[instr{:}];

        end


        function instr=makePrologue(obj,internalState,entry,computeGtid,offset)

            jumpCounterInitPtx='';
            errorCheckCounterInitPtx='';
            if containsNonStaticLoop(internalState)
                if supportsInterrupt(obj)
                    rJ=getJumpCountReg(internalState);
                    jumpCounterInitPtx=formatInstruction(obj,'mov.u32','initializing CTRL-C counter',rJ,'0');
                end
                if initializeBlockError(internalState)
                    rE=getErrorCheckCountReg(internalState);
                    errorCheckCounterInitPtx=formatInstruction(obj,'mov.u32',...
                    'initialize error check counter',...
                    rE,'0');
                end
            end



            checkForError=initialCheckOfErrorFlag(obj,internalState);
            initRandState=initializeRandState(obj,internalState,offset);

            instr=[...
            entry,'{',newline...
            ,declareRegisters(obj,internalState)...
            ,obj.Enterlabel,':',newline...
            ,jumpCounterInitPtx...
            ,errorCheckCounterInitPtx...
            ,checkForError...
            ,computeGtid...
            ,initRandState...
            ];

        end


        function instr=beginEpilogue(obj)
            instr=[obj.Epiloguelabel,':',newline];
        end


        function instr=endEpilogue(obj)

            endname=obj.Basename(12:end);

            instr=[...
            obj.Exitlabel,':',newline...
            ,formatInstruction(obj,'exit','leaving kernel')...
            ,obj.Ender...
            ,'}',formatComment(obj,endname),newline...
            ];

        end

        function instr=initialCheckOfErrorFlag(obj,internalState)
            instr='';

            if initializeBlockError(internalState)


                checkreg=rGet(internalState);
                fstructCheckError=getErrorCheckFcn(obj);
                funcNameCheckError=fstructCheckError.name;
                branchreg=pGet(internalState);
                callinstr=sprintf('call (%s), %s',checkreg,funcNameCheckError);
                instr=[...
                formatInstruction(obj,callinstr,'')...
                ,formatInstruction(obj,'setp.eq.u32','',branchreg,checkreg,'1')...
                ,conditionalBranchToLabel(obj,branchreg,obj.Exitlabel)...
                ];
            end
        end


        function instr=initializeRandState(obj,internalState,linearThreadID)

            instr='';
            if containsRandCall(internalState)

                switch getRandGeneratorType(internalState)
                case 'MRG32K3A'
                    instr=initializeMRG32K3A(obj,internalState,linearThreadID);
                case 'Threefry4x64_20'
                    instr=initializeThreefry(obj,internalState,linearThreadID);
                case 'Philox4x32_10'
                    instr=initializePhilox(obj,internalState,linearThreadID);
                end

            end

        end


        function instr=checkBlockError(obj,internalState)

            rd=rGet(internalState);
            branchreg=pGet(internalState);



            checkInstr=formatInstruction(obj,'ld.global.volatile.u32','',...
            rd,['[',obj.BlockAddress,']']);
            testInstr=formatInstruction(obj,'setp.ne.u32','',branchreg,rd,obj.NoErrorCode);

            instr=[...
            formatComment(obj,'check block error')...
            ,checkInstr...
            ,testInstr...
            ,formatInstruction(obj,['@',branchreg,' bra'],'terminate kernel execution',obj.Exitlabel)...
            ];

        end

        function instr=checkFlagPeriodically(obj,internalState,rCount,...
            targetCount,loadInstr,noErrorCode,...
            blockComment)




            branchreg=pGet(internalState);
            endlabel=labelGet(internalState);

            instr=[...
            formatInstruction(obj,'setp.lt.u32',blockComment,...
            branchreg,rCount,targetCount)...
            ,formatInstruction(obj,'add.u32','',rCount,rCount,'1')...
            ,conditionalBranchToLabel(obj,branchreg,endlabel)...
            ,loadInstr...
            ,formatInstruction(obj,'setp.ne.u32','',branchreg,rCount,noErrorCode)...
            ,conditionalBranchToLabel(obj,branchreg,obj.Exitlabel)...
            ,formatInstruction(obj,'mov.u32','reset counter',rCount,'0')...
            ,formatLabel(obj,'end check',endlabel)...
            ];
        end


        function instr=periodicCheckForInterrupt(obj,internalState)


            rP=ptrGet(internalState);
            rCount=getJumpCountReg(internalState);
            ptr_ldg=sprintf('%s%s',obj.Instr.ldg,getMachineptr(internalState));
            loadAddressInstr=formatInstruction(obj,ptr_ldg,'',rP,...
            ['[',obj.InterruptPtrAddress,']']);
            loadDataInstr=formatInstruction(obj,'ld.volatile.global.u32','',...
            rCount,['[',rP,'+0]']);
            instr=checkFlagPeriodically(obj,internalState,rCount,...
            obj.InterruptCount,...
            [loadAddressInstr,newline,loadDataInstr],...
            obj.NoErrorCode,...
            'start CTRL-C interrupt check instructions');
        end





        function instr=periodicCheckForError(obj,internalState)
            rCount=getErrorCheckCountReg(internalState);
            loadInstr=formatInstruction(obj,'ld.volatile.global.u32','',rCount,...
            ['[',obj.BlockAddress,'+0]']);
            noErrorCode=obj.NoErrorCode;
            instr=checkFlagPeriodically(obj,internalState,rCount,...
            obj.InterruptCount,...
            loadInstr,noErrorCode,...
            'start periodic error check instructions');
        end


        function instr=checkIfFlint(obj,internalState,type,reg)
            returnValue=rGet(internalState);
            instr=[...
            unacall(obj,internalState,type,returnValue,'','errorIfNotFlint',reg,'')...
            ,exitIfRegisterIsTrue(obj,internalState,returnValue),...
            ];
        end


        function instr=checkIfNonNegativeFlint(obj,internalState,type,reg)
            returnValue=rGet(internalState);
            instr=[...
            unacall(obj,internalState,type,returnValue,'','errorIfNegativeOrNotFlint',reg,'')...
            ,exitIfRegisterIsTrue(obj,internalState,returnValue),...
            ];
        end



        function instr=declareRegisters(~,internalState)

            instr='';
            dotreg='    .reg ';

            numberOfRegisters=getRegRB(internalState);
            if numberOfRegisters>1
                instr=[instr,dotreg,'.u8 %rb<',sprintf('%ld',numberOfRegisters+1),'>;',newline];
            end

            numberOfRegisters=getRegRH(internalState);
            if numberOfRegisters>1
                instr=[instr,dotreg,'.u16 %rh<',sprintf('%ld',numberOfRegisters+1),'>;',newline];
            end

            numberOfRegisters=getRegR(internalState);
            if numberOfRegisters>1
                instr=[instr,dotreg,'.u32 %r<',sprintf('%ld',numberOfRegisters+1),'>;',newline];
            end

            numberOfRegisters=getRegRD(internalState);
            if numberOfRegisters>1
                instr=[instr,dotreg,'.u64 %rd<',sprintf('%ld',numberOfRegisters+1),'>;',newline];
            end

            numberOfRegisters=getRegF(internalState);
            if numberOfRegisters>1
                instr=[instr,dotreg,'.f32 %f<',sprintf('%ld',numberOfRegisters+1),'>;',newline];
            end

            numberOfRegisters=getRegFD(internalState);
            if numberOfRegisters>1
                instr=[instr,dotreg,'.f64 %fd<',sprintf('%ld',numberOfRegisters+1),'>;',newline];
            end

            numberOfRegisters=getRegP(internalState);
            if numberOfRegisters>1
                instr=[instr,dotreg,'.pred %p<',sprintf('%ld',numberOfRegisters+1),'>;',newline];
            end

        end


        function header=moduleHeader(obj,internalState,fname,needsInterrupt)

            [ver,tgt,addr64]=getVersionAndTarget(obj);

            cc='compiled on your behalf by MathWorks, Inc.';
            fn=['compiling ',fname];

            interruptStr='';
            if needsInterrupt

                interruptStr=interruptHeader(obj,internalState);
            end

            header=[...
            sprintf('%s\n%s\n%s\n',ver,tgt,addr64)...
            ,formatComment(obj,cc)...
            ,formatComment(obj,fn)...
            ,interruptStr...
            ,functionHeader(obj,internalState)...
            ];

        end

        function[PFS,cproto,types,complexities,entryname,hra,machineptr]=mangleCprotoEntryCommon(obj,internalState,symbols,outputs,inputs,par,expansionKey)
            nout=numel(outputs);
            nin=numel(inputs);

            machineptr=getMachineptr(internalState);

            entryname=obj.Basename;

            complexities=false(1,nout);

            PFS='';
            cproto='';

            types=cell(1,nout);

            hra=cell(1,1+numel(inputs)+numel(outputs)+1);
            hra{1}=['.entry ',obj.Basename,' ('];

            for o1=1:nout

                symbol=getSymbol(symbols,outputs{o1});
                ovtype=symbol.type;
                PFS=[PFS,char(ovtype)];%#ok<AGROW>
                covtype=cType(ovtype);

                if isScalar(ovtype)
                    cproto=[cproto,covtype,' * , '];%#ok<AGROW>
                else
                    cproto=[cproto,covtype,', '];%#ok<AGROW>
                end


                types{o1}=mType(coerceReal(coerceScalar(ovtype)));
                complexities(o1)=isComplex(ovtype);

                hra{end+1}=[...
                newline,par,' '...
                ,machineptr,' '...
                ,obj.Basename,'_',symbol.name,'out,'...
                ];%#ok

            end

            for i1=1:nin


                currentName=inputs{i1};
                symbol=getSymbolIns(symbols,currentName);
                ivtype=symbol.type;
                PFS=[PFS,char(ivtype)];%#ok<AGROW>

                civtype=cType(ivtype);
                cproto=[cproto,'const ',civtype,', '];%#ok<AGROW>

                if isArray(ivtype)
                    entrytype=machineptr;
                elseif isLogical(ivtype)
                    entrytype='.s8';
                else
                    entrytype=regsuffix(obj,ivtype);
                end

                if isComplex(ivtype)&&isScalar(ivtype)
                    width=obj.typesize(ivtype);
                    bytes=sprintf('%i',width);
                    hra{end+1}=[...
                    newline,par...
                    ,' .align ',bytes,' .b8 ',obj.Basename,'_',currentName,'in'...
                    ,'[',bytes,'],'
                    ];%#ok
                else
                    hra{end+1}=[...
                    newline,par,' '...
                    ,entrytype,' ',obj.Basename,'_',currentName,'in,'...
                    ];%#ok
                end

            end



            if(strcmp(getRuleset(internalState),'singleton'))

                if contains(expansionKey,'e')



                    PFS=[PFS,'Ii'];
                    cproto=[cproto,'const int *, int, '];



                    machineptr=getMachineptr(internalState);

                    hra{end+1}=[newline,par,' ',machineptr,' ',obj.Basename,'_',obj.DimArray,'0,'];
                    hra{end+1}=[newline,par,' .s32 ',obj.Basename,'_',obj.Ndim,'0,'];

                    N=numel(expansionKey);
                    for kk=1:N
                        if('e'==expansionKey(kk))


                            PFS=[PFS,'Ii'];%#ok
                            cproto=[cproto,'const int *, int, '];%#ok


                            hra{end+1}=[newline,par,' ',machineptr,' ',obj.Basename,'_',obj.DimArray,num2str(kk),','];%#ok
                            hra{end+1}=[newline,par,' .s32 ',obj.Basename,'_',obj.Ndim,num2str(kk),','];%#ok

                        end
                    end

                end

            end
        end




        function[PFS,cproto,types,complexities,entryname,entry]=mangleCprotoEntry(obj,internalState,symbols,fcnLabel,iR,expansionKey)
            par='    .param';
            outputs=getFcnOutputs(iR,fcnLabel);
            inputs=getFcnInputs(iR,fcnLabel);
            [PFS,cproto,types,complexities,entryname,hra,machineptr]=...
            mangleCprotoEntryCommon(obj,internalState,symbols,outputs,inputs,par,expansionKey);






            fcnWorkspace=getFcnWorkspaceSymbols(iR,fcnLabel);
            names=getMATLABUplevelVariables(iR);

            imin=numel(names);
            for kk=1:imin


                currentName=names{kk};
                symbol=getSymbol(fcnWorkspace,currentName);

                ivtype=symbol.type;
                PFS=[PFS,char(ivtype)];%#ok<AGROW>

                if isArray(ivtype)
                    entrytype=machineptr;
                    civtype='size_t *';
                elseif isLogical(ivtype)
                    entrytype='.s8';
                    civtype=cType(ivtype);
                else
                    entrytype=regsuffix(obj,ivtype);
                    civtype=cType(ivtype);
                end

                cproto=[cproto,'const ',civtype,', '];%#ok<AGROW>

                if isComplex(ivtype)&&isScalar(ivtype)
                    width=obj.typesize(ivtype);
                    bytes=sprintf('%i',width);
                    hra{end+1}=[...
                    newline,par...
                    ,' .align ',bytes,' .b8 ',obj.Basename,'_',currentName,'in'...
                    ,'[',bytes,'],'
                    ];%#ok
                else
                    hra{end+1}=[...
                    newline,par,' '...
                    ,entrytype,' ',obj.Basename,'_',currentName,'in,'...
                    ];%#ok
                end

            end


            if containsRandCall(internalState)
                PFS=[PFS,'J'];
                cproto=[cproto,getRandStateCudaType(internalState),','];
                hra{end+1}=[newline,par,' ',machineptr,' ',obj.RandState,','];
            end


            PFS=[PFS,'i'];
            cproto=[cproto,'int'];

            hra{end+1}=[newline,par,' .s32 ',obj.Basename,'_',obj.SizeVariable,')',newline];
            entry=[hra{:}];

        end






        function[instr,typeout,outreg]=logicalInstruction(obj,internalState,operation,typeIn1,reg1,typeIn2,reg2)

            typeout=parallel.internal.types.Atomic.buildAtomic('logical',isArray(typeIn1)||isArray(typeIn2));

            outreg=rGet(internalState);

            [cvt1,r1,~]=castreg(obj,internalState,typeout,typeIn1,reg1,'');
            [cvt2,r2,~]=castreg(obj,internalState,typeout,typeIn2,reg2,'');

            instr=[...
cvt1...
            ,cvt2...
            ,formatInstruction(obj,[operation,'.b32'],'',outreg,r1,r2)...
            ];

        end


        function[instr,typeOut,outreg]=relopInstruction(obj,internalState,operation,typeIn,regReal1,regImag1,regReal2,regImag2)

            typeOut=coerceLogical(typeIn);
            outreg=rGet(internalState);

            isuf=regsuffixForOperation(obj,typeIn);


            if isFloatingPoint(typeIn)&&strcmp(operation,'ne')
                operation='neu';
            end

            if isComplexFloatingPoint(typeIn)&&(strcmp(operation,'eq')||strcmp(operation,'neu'))

                outreg2=rGet(internalState);
                if strcmp(operation,'neu')
                    combiPtx=formatInstruction(obj,'or.b32','',outreg,outreg,outreg2);
                else
                    combiPtx=formatInstruction(obj,'and.b32','',outreg,outreg,outreg2);
                end

                instr=[...
                formatInstruction(obj,['set.',operation,'.u32',isuf],'',outreg,regReal1,regReal2)...
                ,formatInstruction(obj,'neg.s32','',outreg,outreg)...
                ,formatInstruction(obj,['set.',operation,'.u32',isuf],'',outreg2,regImag1,regImag2)...
                ,formatInstruction(obj,'neg.s32','',outreg2,outreg2)...
                ,combiPtx...
                ];

            elseif isSupported(typeIn)

                instr=[...
                formatInstruction(obj,['set.',operation,'.u32',isuf],'',outreg,regReal1,regReal2)...
                ,formatInstruction(obj,'neg.s32','',outreg,outreg)...
                ];

            else
                assert(false,'emitter:arithmetic',...
                'Attempting relational operation on unsupported type: ''%s''',mType(typeIn));
            end

        end


        function[instr,outreg]=bitshiftInstruction(obj,internalState,reg1,typeIn2,reg2)

            outreg=rGet(internalState);




            rp=pGet(internalState);
            rL=rGet(internalState);
            rR=rGet(internalState);
            r3=rGet(internalState);

            [loadzero,rzero]=constant(obj,internalState,coerceScalar(typeIn2),'0');

            instr=[...
            formatInstruction(obj,'abs.s32','',r3,reg2)...
            ,loadzero...
            ,formatInstruction(obj,'setp.lt.s32','',rp,reg2,rzero)...
            ,formatInstruction(obj,'shr.u32','',rR,reg1,r3)...
            ,formatInstruction(obj,'shl.b32','',rL,reg1,r3)...
            ,formatInstruction(obj,'selp.u32','',outreg,rR,rL,rp)...
            ];
        end


        function[instr,outreg]=bitgetInstruction(obj,internalState,type,reg1,reg2)


            outreg=tGet(internalState,type);
            [maskinstr,mask]=constructBitMaskWithRangeCheck(obj,internalState,type,reg2);

            rp=pGet(internalState);

            instr=[...
maskinstr...
            ,formatInstruction(obj,'and.b32','',outreg,reg1,mask)...
            ,formatInstruction(obj,'setp.eq.u32','',rp,outreg,'0')...
            ,formatInstruction(obj,'selp.u32','',outreg,'0','1',rp)...
            ];

        end


        function[instr,outreg]=bitsetInstruction(obj,internalState,type,reg1,reg2,reg3)


            outreg=tGet(internalState,type);
            [maskinstr,mask]=constructBitMaskWithRangeCheck(obj,internalState,type,reg2);


            setinstr=formatInstruction(obj,'or.b32','',outreg,reg1,mask);

            if isempty(reg3)

                operationinstr=setinstr;
            else

                type4Check=parallel.internal.types.Atomic.buildAtomic('uint32',false);

                [loadzero,rzero]=constant(obj,internalState,type4Check,'0');
                [loadone,rone]=constant(obj,internalState,type4Check,'1');

                rangecheckbit=rangeCheckUint(obj,internalState,reg3,rzero,rone);

                outreg1=tGet(internalState,type);
                rp=pGet(internalState);

                operationinstr=[...
loadzero...
                ,loadone...
                ,rangecheckbit...
                ,setinstr...
                ,bitcmpreg(obj,mask,mask)...
                ,formatInstruction(obj,'and.b32','',outreg1,reg1,mask)...
                ,formatInstruction(obj,'setp.eq.u32','',rp,reg3,'0')...
                ,formatInstruction(obj,'selp.u32','',outreg,outreg1,outreg,rp)...
                ];

            end

            instr=[...
maskinstr...
            ,operationinstr...
            ];

        end


        function instr=arithmeticInstruction(obj,internalState,operation,type,outregReal,outregImag,regReal1,regImag1,regReal2,regImag2)

            switch operation
            case 'plus'
                op='add';
            case 'minus'
                op='sub';
            case{'times','mtimes'}
                op='mul';
            case{'rdivide','mrdivide','ldivide','mldivide'}
                op='div';
            otherwise
                assert(false,'illegal infix operation, ''%s''.',operation)
            end

            if isDouble(type)
                instr=formatInstruction(obj,[op,'.rn.f64'],'',outregReal,regReal1,regReal2);
            elseif isSingle(type)
                modifier='.rn.f32';
                if strcmp(op,'div')
                    modifier='.full.f32';
                end

                instr=formatInstruction(obj,[op,modifier],'',outregReal,regReal1,regReal2);

            elseif isComplexFloatingPoint(type)

                if strcmp(op,'add')||strcmp(op,'sub')

                    modifier='.rn.f64';
                    if isComplexSingle(type)
                        modifier='.rn.f32';
                    end

                    instr=[...
                    formatInstruction(obj,[op,modifier],'',outregReal,regReal1,regReal2)...
                    ,formatInstruction(obj,[op,modifier],'',outregImag,regImag1,regImag2)...
                    ];

                else


                    if strcmp(op,'div')
                        func='divide';
                    elseif strcmp(op,'mul')
                        func='times';
                    end

                    instr=bincall(obj,internalState,type,outregReal,outregImag,func,regReal1,regImag1,regReal2,regImag2);

                end

            elseif isSupportedInteger(type)

                switch op
                case{'add'}
                    instr=saturatedIntegerAddition(obj,internalState,type,outregReal,regReal1,regReal2);
                case{'sub'}
                    instr=saturatedIntegerSubtraction(obj,internalState,type,outregReal,regReal1,regReal2);
                case{'mul'}
                    instr=saturatedIntegerMultiplication(obj,internalState,type,outregReal,regReal1,regReal2);
                case{'div'}
                    instr=saturatedIntegerDivision(obj,internalState,type,outregReal,regReal1,regReal2);
                otherwise
                    assert(false,'illegal arithmetic op, ''%s''.',op);
                end

            else
                assert(false,'emitter:arithmetic',...
                'Attempting arithmetic on unsupported type: ''%s''',mType(type));
            end

        end


        function instr=saturatedIntegerAddition(obj,internalState,type,outreg,intreg1,intreg2)

            suf=regsuffixForOperation(obj,type);
            typeop=integerType4Op(obj,type);

            opReg=rGet(internalState);
            [satinstr,satreg]=castreg(obj,internalState,type,typeop,opReg,'');

            if isInt32(type)
                opinstr=formatInstruction(obj,'add.sat.s32','',opReg,intreg1,intreg2);
            elseif isUint32(type)

                opReg=rdGet(internalState);
                typeop=parallel.internal.types.Atomic.buildAtomic('uint64',false);

                [cvtinstr1,reg1]=castreg(obj,internalState,typeop,type,intreg1,'');
                [cvtinstr2,reg2]=castreg(obj,internalState,typeop,type,intreg2,'');

                [satinstr,satreg]=castreg(obj,internalState,type,typeop,opReg,'');
                opinstr=[...
cvtinstr1...
                ,cvtinstr2...
                ,formatInstruction(obj,'add.u64','',opReg,reg1,reg2)...
                ];

            elseif isSupportedInteger(type)
                opinstr=formatInstruction(obj,['add',suf],'',opReg,intreg1,intreg2);
            else
                assert(false,'not supported integer type, ''%s''.',mType(type));
            end

            instr=[...
opinstr...
            ,satinstr...
            ,formatInstruction(obj,['mov',suf],'',outreg,satreg)...
            ];

        end


        function instr=saturatedIntegerSubtraction(obj,internalState,type,outreg,intreg1,intreg2)

            if isInt32(type)
                instr=formatInstruction(obj,'sub.sat.s32','',outreg,intreg1,intreg2);
            elseif isUnsignedInteger(type)

                opReg=rGet(internalState);

                tmp0=rGet(internalState);
                pred=pGet(internalState);

                instr=[...
                formatInstruction(obj,'sub.u32','',opReg,intreg1,intreg2)...
                ,formatInstruction(obj,'setp.le.u32','',pred,intreg1,intreg2)...
                ,formatInstruction(obj,'mov.u32','',tmp0,'0')...
                ,formatInstruction(obj,'selp.u32','',outreg,tmp0,opReg,pred)...
                ];

            elseif isSupportedInteger(type)

                suf=regsuffixForOperation(obj,type);
                typeop=integerType4Op(obj,type);
                opReg=rGet(internalState);
                [satinstr,satreg]=castreg(obj,internalState,type,typeop,opReg,'');

                instr=[...
                formatInstruction(obj,['sub',suf],'',opReg,intreg1,intreg2)...
                ,satinstr...
                ,formatInstruction(obj,['mov',suf],'',outreg,satreg)...
                ];

            else
                assert(false,'not supported integer type, ''%s''.',mType(type));
            end

        end


        function instr=saturatedIntegerMultiplication(obj,internalState,type,outreg,intreg1,intreg2)

            instr=bincall(obj,internalState,type,outreg,'','times',intreg1,'',intreg2,'');
        end


        function instr=saturatedIntegerDivision(obj,internalState,type,outreg,intreg1,intreg2)

            instr=bincall(obj,internalState,type,outreg,'','divide',intreg1,'',intreg2,'');




























        end


        function instr=logicalSCInstruction(obj,internalState,operation,outreg,reg,endlabel)

            branchreg=pGet(internalState);

            switch operation
            case{'and'}
                logicalop='setp.eq.u32';
            case{'or'}
                logicalop='setp.ne.u32';
            otherwise
                assert(false,'Invalid ''op'', %s, for && or ||.',operation);
            end

            instr=[...
            formatInstruction(obj,'mov.u32','',outreg,reg)...
            ,formatInstruction(obj,logicalop,'',branchreg,reg,'0')...
            ,formatInstruction(obj,['@',branchreg,' bra'],'',endlabel)...
            ];

        end








        function aligninstr=maybeAlignState(obj,internalState,fn)


            aligninstr='';



            if strcmp(getRandTransformType(internalState),'BoxMuller')

                randCounter=getRandom123Counter(internalState);
                lastWasBoxMuller=getRandom123LastWasBoxMuller(internalState);


                counterParity=rGet(internalState);
                nextIsBoxMuller=rGet(internalState);
                oneReg=rGet(internalState);


                isOddSample=pGet(internalState);
                hasRandCallSwitched=pGet(internalState);


                randnSwitchTestLabel=labelGet(internalState);
                skipSampleLabel=labelGet(internalState);
                updateLastWasBoxMullerLabel=labelGet(internalState);


                isfnRandn=num2str(strcmp(fn,'randn'));


                testinstr=[...
...
                formatInstruction(obj,'mov.u32','1U',oneReg,'1')...
                ,formatInstruction(obj,'and.b32','',counterParity,randCounter,oneReg)...
...
                ,formatInstruction(obj,'setp.eq.u32','isOddSample',isOddSample,counterParity,'1')...
...
                ,formatInstruction(obj,'mov.u32','nextIsBoxMuller',nextIsBoxMuller,isfnRandn)...
...
                ,conditionalBranchToLabel(obj,isOddSample,randnSwitchTestLabel)...
...
...
                ,branchToLabel(obj,updateLastWasBoxMullerLabel)...
                ,formatLabel(obj,'test: switching between randn and others',randnSwitchTestLabel)...
                ,formatInstruction(obj,'setp.ne.u32','hasRandCallSwitched',hasRandCallSwitched,lastWasBoxMuller,nextIsBoxMuller)...
                ,conditionalBranchToLabel(obj,hasRandCallSwitched,skipSampleLabel)...
                ,branchToLabel(obj,updateLastWasBoxMullerLabel)...
                ];

                aligninstr=[...
aligninstr...
...
                ,testinstr...
                ,formatLabel(obj,'need to skip a sample',skipSampleLabel)...
                ,formatInstruction(obj,'add.u32','randCounter+=1',randCounter,randCounter,'1')...
                ,formatLabel(obj,'update lastWasBoxMuller',updateLastWasBoxMullerLabel)...
                ,formatInstruction(obj,'mov.u32','lastWasBoxMuller = nextIsBoxMuller',lastWasBoxMuller,nextIsBoxMuller)...
                ];
            end
        end


        function[instr,ro,ro2]=sampleRandAndAdvance(obj,internalState,fn,type,varargin)

            preinstr='';

            switch getRandGeneratorType(internalState)
            case 'MRG32K3A'
                [instr,rsample]=sampleMRG32K3A(obj,internalState);
            case{'Threefry4x64_20','Philox4x32_10'}
                aligninstr=maybeAlignState(obj,internalState,fn);
                preinstr=[...
preinstr...
                ,aligninstr...
                ];
                [instr,rsample]=sampleRandom123(obj,internalState);
            end


            if strcmp(fn,'randn')

                switch getRandTransformType(internalState)
                case 'Inversion'
                    [transforminstr,rsample]=normalTransformInversion(obj,internalState,rsample);
                case 'BoxMuller'
                    [transforminstr,rsample]=normalTransformBoxMuller(obj,internalState);
                end

                instr=[...
instr...
                ,transforminstr...
                ];

            elseif strcmp(fn,'randi')


                fstructArgCheck=obj.Codetable.randiArgCheck_j;
                funcNameArgCheck=manageFunc(internalState,fstructArgCheck);

                regCheck=tGet(internalState,parallel.internal.types.Atomic.buildAtomic('logical',false));
                call=sprintf('call.uni (%s), %s,',regCheck,funcNameArgCheck);
                argcheckinstr=formatInstruction(obj,call,'',['(',varargin{1},',',varargin{2},')']);


                fstructRandiConvert=obj.Codetable.RandIConversion_d;
                funcNameRandiConvert=manageFunc(internalState,fstructRandiConvert);

                rsamplePrev=rsample;
                rsample=fdGet(internalState);
                call=sprintf('call.uni (%s), %s,',rsample,funcNameRandiConvert);
                transforminstr=formatInstruction(obj,call,'',['(',rsamplePrev,',',varargin{1},',',varargin{2},')']);

                instr=[...
argcheckinstr...
                ,instr...
                ,transforminstr...
                ];

            end


            typeOfCalc=parallel.internal.types.Atomic.buildAtomic('double',false);
            [postinstr,ro,ro2]=castreg(obj,internalState,type,typeOfCalc,rsample,'');

            instr=[...
preinstr...
            ,instr...
            ,postinstr...
            ];

        end





        function[instr,outregReal,outregImag]=constant(obj,internalState,type,scon)

            numeric=str2double(scon);

            csuf=regsuffixForOperation(obj,type);
            instrPtx=['mov',csuf];

            [outregReal,outregImag]=tGet(internalState,type);

            if isreal(numeric)&&~isReal(type)


                numeric=complex(numeric);
            end

            if~isreal(numeric)
                realtype=coerceReal(type);
                instr=[...
                formatInstruction(obj,instrPtx,'',outregReal,parallel.internal.gpu.Emitter.makehexnumber(realtype,real(numeric)))...
                ,formatInstruction(obj,instrPtx,scon,outregImag,parallel.internal.gpu.Emitter.makehexnumber(realtype,imag(numeric)))...
                ];
            else
                outregImag='';
                instr=formatInstruction(obj,instrPtx,scon,outregReal,parallel.internal.gpu.Emitter.makehexnumber(type,numeric));
            end

        end


        function[instr,outregReal,outregImag]=loadrealminmax(obj,internalState,type,fn)



            if isSingle(type)
                if strcmp(fn,'realmin')
                    value='0f00800000';
                else

                    value='0f7f7fffff';
                end
            else

                if strcmp(fn,'realmin')
                    value='0d0010000000000000';
                else

                    value='0d7fefffffffffffff';
                end
            end

            [instr,outregReal,outregImag]=copyreg(obj,internalState,type,value,'');

        end



        function[instr,outregReal,outregImag]=copyreg(obj,internalState,typeOut,regReal,regImag)

            [outregReal,outregImag]=tGet(internalState,typeOut);

            suf=regsuffixForOperation(obj,typeOut);
            instrPtx=['mov',suf];
            instr=formatInstruction(obj,instrPtx,'',outregReal,regReal);

            if isComplex(typeOut)
                instr=[...
instr...
                ,formatInstruction(obj,instrPtx,'',outregImag,regImag)...
                ];
            end
        end


        function[instr,varargout]=castregisters(obj,internalState,varargin)

            assert(mod(nargin-2,4)==0,'inputs must consists of quads: ''typeOut'', ''typeIn'', ''regReal'', ''regImag''.');

            N=numel(varargin)/4;
            instr=cell(1,N);
            varargout=cell(1,N*2);

            for kk=1:N

                vararginOffset=4*(kk-1);
                typeOut=varargin{vararginOffset+1};
                typeIn=varargin{vararginOffset+2};
                regReal=varargin{vararginOffset+3};
                regImag=varargin{vararginOffset+4};

                [cvtinstr,outregReal,outregImag]=castreg(obj,internalState,typeOut,typeIn,regReal,regImag);

                varargoutOffset=2*(kk-1);
                varargout{varargoutOffset+1}=outregReal;
                varargout{varargoutOffset+2}=outregImag;

                instr{kk}=cvtinstr;

            end

            instr=[instr{:}];

        end





        function[instr,outregReal,outregImag]=castreg(obj,internalState,typeOut,typeIn,regReal,regImag)


            if isSameBaseType(typeOut,typeIn)
                [instr,outregReal,outregImag]=copyreg(obj,internalState,typeOut,regReal,regImag);
                return;
            end


            if isFloatingPoint(typeOut)
                [instr,outregReal,outregImag]=castregToFloat(obj,internalState,...
                typeOut,typeIn,...
                regReal,regImag);

            elseif isInteger(typeOut)
                [instr,outregReal,outregImag]=castregToInt(obj,internalState,...
                typeOut,typeIn,...
                regReal,regImag);

            elseif isLogical(typeOut)
                [instr,outregReal,outregImag]=castregToLogical(obj,internalState,...
                typeOut,typeIn,...
                regReal,regImag);

            else
                iCastregError(typeIn,typeOut)
            end

        end

        function[instr,outregReal,outregImag]=castregToFloat(obj,internalState,typeOut,typeIn,regReal,regImag)


            osuf=regsuffix(obj,typeOut);
            isuf=regsuffix(obj,typeIn);


            [outregReal,outregImag]=tGet(internalState,typeOut);




            if isSingle(typeOut)&&(isDouble(typeIn)||isComplexDouble(typeIn))
                comment='Convert real or complex double to real single';
                instr=formatInstruction(obj,['cvt.rn',osuf,isuf],comment,outregReal,regReal);

            elseif isDouble(typeOut)&&(isSingle(typeIn)||isComplexSingle(typeIn))
                comment='Convert real or complex single to real double';
                instr=formatInstruction(obj,['cvt',osuf,isuf],comment,outregReal,regReal);

            elseif isComplexDouble(typeOut)&&isSingle(typeIn)
                comment='Convert single to complex double';
                instr=formatInstruction(obj,['cvt',osuf,isuf],comment,outregReal,regReal);

            elseif isComplexSingle(typeOut)&&isDouble(typeIn)
                comment='Convert double to complex single';
                instr=formatInstruction(obj,['cvt.rn',osuf,isuf],comment,outregReal,regReal);

            elseif isRealFloatingPoint(typeOut)&&(isInteger(typeIn)||isLogical(typeIn))
                comment='Convert integer or logical to floating point';

                conversion=['cvt.rn',osuf,isuf];
                instr=formatInstruction(obj,conversion,comment,outregReal,regReal);

            elseif isComplexFloatingPoint(typeOut)&&(isInteger(typeIn)||isLogical(typeIn))
                comment='Convert integer or logical to complex floating point';
                conversion=['cvt.rn',osuf,isuf];
                instr=formatInstruction(obj,conversion,comment,outregReal,regReal);
                if isComplex(typeIn)
                    instr=[...
instr...
                    ,formatInstruction(obj,conversion,comment,outregImag,regImag)...
                    ];
                end

            elseif(isDouble(typeOut)&&isComplexDouble(typeIn))||...
                (isSingle(typeOut)&&isComplexSingle(typeIn))||...
                (isComplexDouble(typeOut)&&isDouble(typeIn))||...
                (isComplexSingle(typeOut)&&isSingle(typeIn))
                comment='Convert complex->real or real->complex of same type';
                instr=formatInstruction(obj,['mov',isuf],comment,outregReal,regReal);

            elseif isComplexSingle(typeOut)||isSingle(typeOut)


                comment='Convert to single';
                instrPtx=['cvt.rn',osuf,isuf];
                instr=formatInstruction(obj,instrPtx,comment,outregReal,regReal);

                if isComplex(typeIn)
                    instr=[...
instr...
                    ,formatInstruction(obj,instrPtx,comment,outregImag,regImag)...
                    ];
                end

            elseif isComplexDouble(typeOut)||isDouble(typeOut)


                comment='Convert to double';
                instrPtx=['cvt',osuf,isuf];
                instr=formatInstruction(obj,instrPtx,comment,outregReal,regReal);

                if isComplex(typeIn)
                    instr=[...
instr...
                    ,formatInstruction(obj,instrPtx,comment,outregImag,regImag)...
                    ];
                end
            else
                iCastregError(typeIn,typeOut);
            end



            if isComplex(typeOut)&&~isComplex(typeIn)
                comment='Set imaginary part to zero';
                instr=[...
instr...
                ,formatInstruction(obj,['mov',osuf],comment,outregImag,parallel.internal.gpu.Emitter.makehexnumber(coerceScalar(coerceReal(typeOut)),0))...
                ];
            end
        end

        function[instr,outregReal,outregImag]=castregToInt(obj,internalState,typeOut,typeIn,regReal,regImag)


            osuf=regsuffix(obj,typeOut);
            isuf=regsuffix(obj,typeIn);


            [outregReal,outregImag]=tGet(internalState,typeOut);




            if isFloatingPoint(typeIn)
                comment='Cast floating-point to integer';
                rdReal=tGet(internalState,typeIn);
                rdImag=tGet(internalState,typeIn);

                [zeroload,rzero]=constant(obj,internalState,coerceScalar(typeOut),'0');
                rp=pGet(internalState);

                bsuf=regsuffixForOperation(obj,typeOut);

                instr=[...
                unacall(obj,internalState,typeIn,rdReal,rdImag,'round',regReal,regImag)...
                ,zeroload...
                ,formatInstruction(obj,['cvt.rni',osuf,isuf],comment,outregReal,rdReal)...
                ,formatInstruction(obj,['setp.eq',isuf],[comment,' - check for NaN'],rp,rdReal,rdReal)...
                ,formatInstruction(obj,['selp',bsuf],[comment,' - set NaN to zero'],outregReal,outregReal,rzero,rp)...
                ];
                if isComplex(typeIn)

                    instr=[...
instr...
                    ,formatInstruction(obj,['cvt.rni',osuf,isuf],comment,outregImag,rdImag)...
                    ,formatInstruction(obj,['setp.eq',isuf],[comment,' - check for NaN'],rp,rdImag,rdImag)...
                    ,formatInstruction(obj,['selp',bsuf],[comment,' - set NaN to zero'],outregImag,outregImag,rzero,rp)...
                    ];
                end

            elseif isLogical(typeIn)
                comment='Cast logical to integer';


                conversion=['cvt',osuf,isuf];
                instr=formatInstruction(obj,conversion,comment,outregReal,regReal);

            elseif isSignedInteger(typeOut)...
                ||(isUnsignedInteger(typeOut)&&isUnsignedInteger(typeIn))



                comment='Cast between integer types';
                sat='';
                if nonSignBits(typeIn)>nonSignBits(typeOut)
                    sat='.sat';
                end
                conversion=['cvt',sat,osuf,isuf];
                instr=formatInstruction(obj,conversion,comment,outregReal,regReal);
                if isComplex(typeIn)
                    instr=[...
instr...
                    ,formatInstruction(obj,conversion,comment,outregImag,regImag)...
                    ];
                end

            elseif isUnsignedInteger(typeOut)&&isSignedInteger(typeIn)
                comment='Cast signed integer to unsigned';



                conversion=['cvt.sat',osuf,isuf];
                instr=formatInstruction(obj,conversion,comment,outregReal,regReal);
                if isComplex(typeIn)
                    instr=[...
instr...
                    ,formatInstruction(obj,conversion,comment,outregImag,regImag)...
                    ];
                end

            else
                iCastregError(typeIn,typeOut);
            end



            if isComplex(typeOut)&&~isComplex(typeIn)
                instr=[...
instr...
                ,formatInstruction(obj,['mov',osuf],'Set imaginary part to zero',outregImag,parallel.internal.gpu.Emitter.makehexnumber(coerceScalar(coerceReal(typeOut)),0))...
                ];
            end
        end

        function[instr,outregReal,outregImag]=castregToLogical(obj,internalState,typeOut,typeIn,regReal,regImag)



            [outregReal,outregImag]=tGet(internalState,typeOut);

            if isDouble(typeIn)||isSingle(typeIn)
                instr=unacall(obj,internalState,typeIn,outregReal,outregImag,'downcast2logical',regReal,regImag);
            elseif isComplexFloatingPoint(typeIn)
                encounteredError(internalState,message('parallel:gpu:compiler:InvalidConversionComplexLogical'));
            else
                comment='Cast to logical';
                isuf=regsuffixForOperation(obj,typeIn);

                [cvt0,ro1]=constant(obj,internalState,coerceScalar(typeIn),'0');
                rotmp=rGet(internalState);

                instr=[...
cvt0...
                ,formatInstruction(obj,['set.ne.u32',isuf],comment,rotmp,regReal,ro1)...
                ,formatInstruction(obj,'neg.s32',comment,outregReal,rotmp)...
                ];
            end
        end

        function[instr,outreg]=castregWithFlintCheck(obj,internalState,typeOut,typeIn,reg)

            assert(isDouble(typeIn),'checking flint''ness of non double is not allowed.');
            flintptx=checkIfFlint(obj,internalState,typeIn,reg);
            outreg=tGet(internalState,typeOut);
            regsuf=regsuffix(obj,typeOut);

            instr=[...
flintptx...
            ,formatInstruction(obj,['cvt.rni',regsuf,'.f64'],'',outreg,reg)...
            ];

        end

        function[instr,outreg]=castregWithNonNegativeFlintCheck(obj,internalState,typeOut,typeIn,reg)

            assert(isDouble(typeIn),'checking sign and flint''ness of non double is not allowed.');
            flintptx=checkIfNonNegativeFlint(obj,internalState,typeIn,reg);
            outreg=tGet(internalState,typeOut);
            regsuf=regsuffix(obj,typeOut);

            instr=[...
flintptx...
            ,formatInstruction(obj,['cvt.rni',regsuf,'.f64'],'',outreg,reg)...
            ];

        end




        function[instr,outregReal,outregImag]=movereg(obj,internalState,typeOut,outregReal,outregImag,regReal,regImag)

            suf=regsuffixForOperation(obj,typeOut);
            instrPtx=['mov',suf];
            instr=formatInstruction(obj,instrPtx,'',outregReal,regReal);

            if isComplex(typeOut)

                if isempty(outregImag)
                    outregImag=tGet(internalState,coerceReal(typeOut));
                end

                instr=[...
instr...
                ,formatInstruction(obj,instrPtx,'',outregImag,regImag)...
                ];

            end

        end



        function[instr,outreg]=negatereg(obj,internalState,type,reg)

            outreg=tGet(internalState,type);
            suf=regsuffixForOperation(obj,type);
            instr=formatInstruction(obj,['neg',suf],'',outreg,reg);

        end


        function[instr,typeOut,outreg]=logicalnotreg(obj,internalState,typeIn,reg)

            typeOut=coerceLogical(typeIn);
            outreg=rGet(internalState);

            [cvtPtx,reg,~]=castreg(obj,internalState,typeOut,typeIn,reg,'');

            instr=[...
cvtPtx...
            ,formatInstruction(obj,'cnot.b32','',outreg,reg)...
            ];

        end


        function instr=absreg(obj,internalState,typeOut,outreg,reg)

            if isInteger(typeOut)
                isuf=regsuffixForOperation(obj,typeOut);

                absreg=tGet(internalState,typeOut);

                pred=pGet(internalState);
                mtype=mType(coerceScalar(typeOut));

                setpInstr=sprintf('setp.eq%s',isuf);
                absInstr=sprintf('abs%s',isuf);
                selpInstr=sprintf('selp%s',isuf);

                instr=[...
                formatInstruction(obj,setpInstr,'',pred,reg,num2str(intmin(mtype)))...
                ,formatInstruction(obj,absInstr,'',absreg,reg)...
                ,formatInstruction(obj,selpInstr,'',outreg,num2str(intmax(mtype)),absreg,pred)...
                ];

            else
                isuf=regsuffix(obj,typeOut);
                instr=sprintf('    abs%s              %s,%s;\n',isuf,outreg,reg);
            end

        end


        function instr=fixreg(obj,typeOut,outreg,reg)
            isuf=regsuffix(obj,typeOut);
            instr=sprintf('    cvt.rzi%s%s      %s,%s;\n',isuf,isuf,outreg,reg);
        end


        function instr=ceilfloorreg(obj,operation,typeOut,outreg,reg)
            if strcmp(operation,'ceil')
                dir='.rpi';
            else
                dir='.rmi';
            end

            isuf=regsuffix(obj,typeOut);

            instr=sprintf('    cvt%s%s%s      %s,%s;\n',dir,isuf,isuf,outreg,reg);

        end


        function instr=xorreg(obj,outreg,reg1,reg2)
            instr=formatInstruction(obj,'xor.b32','',outreg,reg1,reg2);
        end


        function instr=bitcmpreg(obj,outreg,reg)
            instr=formatInstruction(obj,'not.b32','',outreg,reg);
        end


        function instr=bitopreg(obj,operation,outreg,regReal,regImag)

            switch operation
            case 'bitand'
                op='and';
            case 'bitor'
                op='or';
            case 'bitxor'
                op='xor';
            end

            instr=formatInstruction(obj,[op,'.b32'],'',outreg,regReal,regImag);

        end


        function[instr,outregReal]=zerohigherbits(obj,internalState,type,regReal)

            if isUint32(type)
                outregReal=regReal;
                instr='';
            else

                outregReal=rGet(internalState);
                masktype=coerceScalar(type);

                if isUint16(masktype)
                    [maskload,maskreg]=constant(obj,internalState,masktype,'65535');
                elseif isUint8(masktype)
                    [maskload,maskreg]=constant(obj,internalState,masktype,'255');
                else
                    assert(false,'zeroing higher bits is only supported on unsigned integers.');
                end

                instr=[...
maskload...
                ,formatInstruction(obj,'and.b32','',outregReal,regReal,maskreg)...
                ];

            end

        end


        function instr=setpredicatereg(obj,operation,branchreg,typeIn,reg1,reg2)
            isuf=regsuffix(obj,typeIn);
            instr=formatInstruction(obj,['setp.',operation,isuf],'',branchreg,reg1,reg2);
        end





        function instr=updateShadowCounter(obj,typeShadow,regShadowCounter,regShadow,regBegin,regStep)

            shadowSuf=regsuffix(obj,typeShadow);

            instr=[...
            formatComment(obj,'shadow counter update')...
            ,formatInstruction(obj,['mul.rn',shadowSuf],'',regShadow,regShadowCounter,regStep)...
            ,formatInstruction(obj,['add.rn',shadowSuf],'',regShadow,regShadow,regBegin)...
            ,formatInstruction(obj,['add.rn',shadowSuf],'increment shadow counter',regShadowCounter,regShadowCounter,sprintf('0d%bx',1))...
            ];

        end


        function[instr,regResult]=loopLength(obj,internalState,typeIndex,regBegin,regStep,regLast,typeShadow,endlabel)

            regResult=tGet(internalState,typeShadow);

            if isSingle(typeIndex)
                sufo=makeKey(typeIndex);
            else
                sufo=makeKey(coerceDouble(typeIndex));
            end

            kname=['forLoopLength_',sufo];
            fstruct=obj.Codetable.(kname);
            funcName=manageFunc(internalState,fstruct);

            callinstr=sprintf('call.uni (%s), %s,',regResult,funcName);
            instr=formatInstruction(obj,callinstr,'',['(',regBegin],regStep,[regLast,')']);


            One=sprintf('0d%bx',1);
            shadowSuf=regsuffix(obj,typeShadow);

            nancheckreg=pGet(internalState);
            instr=[...
instr...
            ,formatInstruction(obj,['setp.eq',shadowSuf],'',nancheckreg,regResult,regResult)...
            ,formatInstruction(obj,['selp',shadowSuf],'',regResult,regResult,One,nancheckreg)...
            ];

            if isRealFloatingPoint(typeIndex)
                [nanPtx,regNan,~]=constant(obj,internalState,coerceScalar(typeShadow),'Nan');

                instr=[...
instr...
                ,nanPtx...
                ,formatInstruction(obj,['selp',shadowSuf],'',regBegin,regBegin,regNan,nancheckreg)...
                ];

            end


            Zero=sprintf('0d%bx',0);
            branchreg=pGet(internalState);

            instr=[...
instr...
            ,formatInstruction(obj,['setp.eq',shadowSuf],'',branchreg,regResult,Zero)...
            ,conditionalBranchToLabel(obj,branchreg,endlabel)...
            ];

        end








        function[instr,rdb,gtid]=calculateOffset(obj,internalState)

            machineptr=getMachineptr(internalState);




            r1=rGet(internalState);
            nctaidX=rhGet(internalState);
            ctaidY=rhGet(internalState);
            ctaidX=rGet(internalState);
            r2=rGet(internalState);
            ntidX=rGet(internalState);
            r3=rGet(internalState);
            tidX=rGet(internalState);

            gtid=rGet(internalState);

            if strcmp(machineptr,'.u64')
                rdb=ptrGet(internalState);
                cvtinstr=formatInstruction(obj,'cvt.u64.s32','',rdb,gtid);
            else
                rdb=gtid;
                cvtinstr='';
            end

            instr=[...
            formatInstruction(obj,'cvt.u32.u16',obj.Com.gridDimx,nctaidX,'%nctaid.x')...
            ,formatInstruction(obj,'cvt.u32.u16',obj.Com.blockIdxy,ctaidY,'%ctaid.y')...
            ,formatInstruction(obj,'mul.lo.u32','',r1,nctaidX,ctaidY)...
            ,formatInstruction(obj,'cvt.u32.u16',obj.Com.blockIdxx,ctaidX,'%ctaid.x')...
            ,formatInstruction(obj,'add.u32','',r2,ctaidX,r1)...
            ,formatInstruction(obj,'cvt.u32.u16',obj.Com.blockDimx,ntidX,'%ntid.x')...
            ,formatInstruction(obj,'mul.lo.u32','',r3,ntidX,r2)...
            ,formatInstruction(obj,'cvt.u32.u16',obj.Com.threadIdxx,tidX,'%tid.x')...
            ,formatInstruction(obj,'add.u32','',gtid,tidX,r3)...
            ,cvtinstr...
            ];

        end



        function[instr,outputs]=calculateSingletonExpansionOffsets(obj,internalState,lido,varargin)



            addHeader(internalState,...
            'gpu_shared_tile',...
            '.extern    .shared .align 4 .b8 gpu_shared_tile[];');

            ptrsuffix=getMachineptr(internalState);
            sharedmemoryptr=ptrGet(internalState);
            ptroffset=ptrGet(internalState);

            lidolocal=rGet(internalState);

            instr=[...
            formatInstruction(obj,'mov.s32','',lidolocal,lido)...
            ,formatInstruction(obj,['mov',ptrsuffix],'',sharedmemoryptr,'gpu_shared_tile')...
            ,formatInstruction(obj,['mov',ptrsuffix],'',ptroffset,'0')...
            ];


            N=numel(varargin);
            ptrs2shared=cell(1,N);

            loadtiles='';
            for kk=1:N

                boxedvariable=varargin{kk};
                dim=boxedvariable.dim;
                ndim=boxedvariable.ndim;


                regsharedptr=ptrGet(internalState);
                ptrs2shared{kk}=regsharedptr;

                ndimtmp=ptrGet(internalState);

                instr=[...
instr...
                ,formatInstruction(obj,['add',ptrsuffix],'',regsharedptr,sharedmemoryptr,ptroffset)...
                ,formatInstruction(obj,['cvt',ptrsuffix,'.s32'],'',ndimtmp,ndim)...
                ,formatInstruction(obj,['add',ptrsuffix],'',ndimtmp,ndimtmp,'1')...
                ,formatInstruction(obj,['mad.lo',ptrsuffix],'',ptroffset,ndimtmp,'4',ptroffset)...
                ];%#ok

                loadtiles=[...
loadtiles...
                ,sharedMemoryLoad(obj,internalState,regsharedptr,dim,ndim)...
                ];%#ok

            end



            barrierlabel=labelGet(internalState);
            pred0=pGet(internalState);
            threadidx=rGet(internalState);
            instr=[...
instr...
            ,formatInstruction(obj,'cvt.u32.u16','',threadidx,'%tid.x')...
            ,formatInstruction(obj,'setp.ne.u32','',pred0,threadidx,'0')...
            ,conditionalBranchToLabel(obj,pred0,barrierlabel)...
            ,loadtiles...
            ,formatLabel(obj,'',barrierlabel)...
            ,formatInstruction(obj,'bar.sync','finished loading shared memory','0')...
            ];





            startlabel=labelGet(internalState);
            endlabel=labelGet(internalState);

            boxedoutvariable=varargin{1};
            looplength=boxedoutvariable.ndim;
            looppred=pGet(internalState);

            iteration=rGet(internalState);
            coordinate=rGet(internalState);

            outputs=cell(1,N-1);
            outputs=cellfun(@(x)(ptrGet(internalState)),outputs,'UniformOutput',false);

            lidcalc=cell(1,N-1);
            lidcalc=cellfun(@(x)(rGet(internalState)),lidcalc,'UniformOutput',false);

            outputptr=ptrs2shared{1};
            currentoutputptr=ptrGet(internalState);

            outputsize=rGet(internalState);
            rvi=rGet(internalState);
            rtmp2=rGet(internalState);

            itertmp=ptrGet(internalState);

            initlids='';
            for kk=1:(N-1)
                initlids=[...
initlids...
                ,formatInstruction(obj,'mov.s32','',lidcalc{kk},'0')...
                ];%#ok
            end

            instr=[...
instr...
            ,initlids...
            ,formatInstruction(obj,'mov.s32','',iteration,looplength)...
            ,formatLabel(obj,'',startlabel)...
            ,formatInstruction(obj,'sub.s32','',iteration,iteration,'1')...
            ,formatInstruction(obj,['cvt',ptrsuffix,'.s32'],'',itertmp,iteration)...
            ,formatInstruction(obj,['mad.lo',ptrsuffix],'',currentoutputptr,itertmp,'4',outputptr)...
            ,formatInstruction(obj,'ld.shared.s32','',outputsize,['[',currentoutputptr,'+0]'])...
            ,formatInstruction(obj,'rem.s32','',rvi,lidolocal,outputsize)...
            ,formatInstruction(obj,'sub.s32','',rtmp2,lidolocal,rvi)...
            ,formatInstruction(obj,'div.s32','',coordinate,rtmp2,outputsize)...
            ,formatInstruction(obj,'mov.s32','',lidolocal,rvi)...
            ];

            lastiterations='';
            offsetcalc='';
            convertlids='';

            for kk=1:(N-1)


                current=kk+1;
                boxedvariable=varargin{current};
                ndim=boxedvariable.ndim;

                sharedmemoryptr=ptrs2shared{current};
                offsetptr=ptrGet(internalState);

                currentsize=rGet(internalState);
                nextsize=rGet(internalState);

                skiplabel=labelGet(internalState);
                pred=pGet(internalState);

                [updateinstr,lidupdate]=updateLinearOffset(obj,internalState,coordinate,currentsize,nextsize);

                lidcalc_local=lidcalc{kk};

                iterationtmp=ptrGet(internalState);

                offsetcalc=[...
offsetcalc...
                ,formatInstruction(obj,'setp.ge.s32','',pred,iteration,ndim)...
                ,conditionalBranchToLabel(obj,pred,skiplabel)...
                ,formatInstruction(obj,['cvt',ptrsuffix,'.s32'],'',iterationtmp,iteration)...
                ,formatInstruction(obj,['mad.lo',ptrsuffix],'',offsetptr,iterationtmp,'4',sharedmemoryptr)...
                ,formatInstruction(obj,'ld.shared.s32','',currentsize,['[',offsetptr,'+0]'])...
                ,formatInstruction(obj,'ld.shared.s32','',nextsize,['[',offsetptr,'+4]'])...
                ,updateinstr...
                ,formatInstruction(obj,'add.s32','',lidcalc_local,lidcalc_local,lidupdate)...
                ,formatLabel(obj,'',skiplabel)...
                ];%#ok

                seconddim=rGet(internalState);

                lastiterations=[...
lastiterations...
                ,formatInstruction(obj,'ld.shared.s32','',seconddim,['[',sharedmemoryptr,'+4]'])...
                ,updateLinearOffsetFinal(obj,internalState,lidcalc_local,lidolocal,seconddim)...
                ];%#ok

                lidout=outputs{kk};

                convertlids=[...
convertlids...
                ,formatInstruction(obj,['cvt',ptrsuffix,'.s32'],'',lidout,lidcalc_local)...
                ];%#ok

            end

            instr=[...
instr...
            ,offsetcalc...
            ,formatInstruction(obj,'setp.gt.s32','',looppred,iteration,'0')...
            ,conditionalBranchToLabel(obj,looppred,startlabel)...
            ,formatLabel(obj,'end singleton calculation loop',endlabel)...
            ,lastiterations...
            ,convertlids...
            ];

        end












        function instr=sharedMemoryLoad(obj,internalState,regsharedptr,dim,ndim)

            ptrsuffix=getMachineptr(internalState);

            sharedmemoryptr=ptrGet(internalState);
            dimptr=ptrGet(internalState);
            rptr1=ptrGet(internalState);

            pred=pGet(internalState);

            rtmp1=rGet(internalState);
            rtmp2=rGet(internalState);
            rtmp3=rGet(internalState);
            rvalue=rGet(internalState);

            iterlabel=labelGet(internalState);
            endlabel=labelGet(internalState);

            instr=[...
            formatInstruction(obj,['mov',ptrsuffix],'',sharedmemoryptr,regsharedptr)...
            ,formatInstruction(obj,['mov',ptrsuffix],'',dimptr,dim)...
            ,formatInstruction(obj,['mov',ptrsuffix],'',rptr1,sharedmemoryptr)...
            ,formatInstruction(obj,'mov.s32','',rtmp2,'0')...
            ,formatInstruction(obj,'mov.s32','',rtmp3,rtmp1)...
            ,formatLabel(obj,'BEGIN LOADING SHARED MEMORY',iterlabel)...
            ,formatInstruction(obj,'ld.global.s32','',rvalue,['[',dimptr,'+0]'])...
            ,formatInstruction(obj,'st.shared.s32','',['[',rptr1,'+0]'],rvalue)...
            ,formatInstruction(obj,'add.s32','',rtmp2,rtmp2,'1')...
            ,formatInstruction(obj,['add',ptrsuffix],'',rptr1,rptr1,'4')...
            ,formatInstruction(obj,['add',ptrsuffix],'',dimptr,dimptr,'4')...
            ,formatInstruction(obj,'setp.le.s32','',pred,rtmp2,ndim)...
            ,conditionalBranchToLabel(obj,pred,iterlabel)...
            ,formatLabel(obj,'END LOADING SHARED MEMORY',endlabel)...
            ];

        end


        function[instr,lidupdate]=updateLinearOffset(obj,internalState,coordinate,currentsize,nextsize)

            lidtmp1=rGet(internalState);
            lidtmp2=rGet(internalState);
            pred=pGet(internalState);

            lidupdate=rGet(internalState);

            instr=[...
            formatInstruction(obj,'mul.lo.s32','',lidtmp1,coordinate,currentsize)...
            ,formatInstruction(obj,'mov.s32','',lidtmp2,'0')...
            ,formatInstruction(obj,'setp.ne.s32','',pred,currentsize,nextsize)...
            ,formatInstruction(obj,'selp.s32','',lidupdate,lidtmp1,lidtmp2,pred)...
            ];

        end


        function instr=updateLinearOffsetFinal(obj,internalState,lid,lido,seconddim)

            lidtmp1=rGet(internalState);
            lidtmp2=rGet(internalState);

            pred=pGet(internalState);

            instr=[...
            formatInstruction(obj,'add.s32','',lidtmp1,lid,lido)...
            ,formatInstruction(obj,'mov.s32','',lidtmp2,lid)...
            ,formatInstruction(obj,'setp.ne.s32','',pred,seconddim,'1')...
            ,formatInstruction(obj,'selp.s32','',lid,lidtmp1,lidtmp2,pred)...
            ];

        end





        function instr=exitIfRegisterIsTrue(obj,internalState,checkreg)
            branchreg=pGet(internalState);

            instr=[...
            formatInstruction(obj,'setp.eq.u32','',branchreg,checkreg,'1')...
            ,conditionalBranchToLabel(obj,branchreg,obj.Exitlabel)...
            ];
        end

    end
end


function iCastregError(typeIn,typeOut)

    assert(false,'emitter:castreg:unknown','Values of type ''%s'' can not be converted to ''%s''.',...
    mType(typeIn),mType(typeOut));
end


function[array,arrayDeclaration]=iManageLocalOuts(funcName,alignment,bytes)
    alignment=sprintf('%i',alignment);
    bytes=sprintf('%i',bytes);
    array=sprintf('__cudareta__%s',funcName);
    arrayDeclaration=['    .param .align ',alignment,' .b8 ',array,'[',bytes,']'];
end

function[array,arrayDeclaration]=iManageLocalIns(funcName,alignment,bytes,number)
    alignment=sprintf('%i',alignment);
    bytes=sprintf('%i',bytes);
    array=sprintf('__cudaparma%i__%s',number,funcName);
    arrayDeclaration=['    .param .align ',alignment,' .b8 ',array,'[',bytes,']'];
end

