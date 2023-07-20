classdef InternalState<handle









    properties(SetAccess=private,Hidden=true)

        Debug;
        Ruleset;

        RandType;
        RandTransformType;

        HostOS;
    end


    properties(SetAccess=private,Hidden=true)


        ErrorNode;
        Node;
        Depth;

        ErrorCurrentContext;
        CurrentContext;



        WarningStruct;






        Rb_regno;
        Rh_regno;
        R_regno;
        Rd_regno;

        F_regno;
        Fd_regno;


        P_regno;

        Machineptr64p;


        Labelnumber;


        NeededHeaders;



        NeededKernels;







        ThrowsError;
        InitializeBlockError;


        JumpCountReg;
        ErrorCheckCountReg;


        RandStateCudaType;


        RandStateReg1;
        RandStateReg2;
        RandStateReg3;


        Random123WordSuf;
        Random123CounterRegisters;
        Random123KeyRegisters;

        Random123Counter;
        Random123CounterType;

        Random123CacheRegisters;

        BoxMullerInitFlag;
        BoxMullerCacheRegisters;
        Random123LastWasBoxMuller;
    end


    methods(Hidden=true)


        function obj=InternalState(boundFcnContext,Ruleset,Debug)

            obj.Debug=Debug;

            assert((strcmp(Ruleset,'singleton')||strcmp(Ruleset,'vector')),...
            'The MATLAB Rule set options are ''vector'' or ''singleton''.');
            obj.Ruleset=Ruleset;

            obj.RandType=builtin('_gpu_retrieveRNGType');
            obj.RandTransformType=builtin('_gpu_retrieveNormalTransformType');

            obj.ErrorNode='';
            obj.Node='';
            obj.Depth=0;


            obj.WarningStruct=struct([]);

            obj.ErrorCurrentContext=boundFcnContext;
            obj.CurrentContext=boundFcnContext;




            obj.Rb_regno=1;
            obj.Rh_regno=1;
            obj.R_regno=1;
            obj.Rd_regno=1;


            obj.F_regno=1;
            obj.Fd_regno=1;


            obj.P_regno=1;

            obj.HostOS=computer();


            switch obj.HostOS
            case{'PCWIN64','GLNXA64','MACI64'}
                obj.Machineptr64p=true;
            otherwise
                obj.Machineptr64p=false;
            end


            obj.Labelnumber=1;


            obj.NeededHeaders=struct(...
            'SymbolName',cell(0,1),...
            'PTXCode',cell(0,1));
            obj.NeededKernels={};

            obj.ThrowsError=false;
            obj.InitializeBlockError=false;

            obj.JumpCountReg='';
            obj.ErrorCheckCountReg='';

            obj.RandStateReg1='';
            obj.RandStateReg2='';
            obj.RandStateReg3='';

            obj.Random123WordSuf='';
            obj.Random123CounterRegisters={};
            obj.Random123KeyRegisters={};

            obj.Random123Counter='';
            obj.Random123CounterType='';

            obj.Random123CacheRegisters={};

            obj.BoxMullerInitFlag='';
            obj.BoxMullerCacheRegisters={};
            obj.Random123LastWasBoxMuller='';

        end


        function setNodeForErrorMechanism(obj,anode)
            assert(isa(anode,'mtree'),'Only MAGIC can be used for tree nodes.');
            obj.ErrorNode=anode;
        end


        function setCompilationNode(obj,anode)
            assert(isa(anode,'mtree'),'Only MAGIC can be used for tree nodes.');
            obj.Node=anode;
        end


        function Node=getCompilationNode(obj)
            Node=obj.Node;
        end


        function incrementDepth(obj)
            obj.Depth=obj.Depth+1;
        end


        function decrementDepth(obj)

            depth=obj.Depth-1;
            assert(0<=depth,'Depth can not be less than 0.');
            obj.Depth=depth;

        end


        function Depth=getDepth(obj)
            Depth=obj.Depth;
        end






        function addWarning(obj,msgString,varargin)
            msg=message(msgString,varargin{:});
            numWarnings=numel(obj.WarningStruct);
            obj.WarningStruct(numWarnings+1,1).ID=msg.Identifier;
            obj.WarningStruct(numWarnings+1,1).String=getString(msg);
        end



        function theWarnings=getCellArrayOfWarnings(obj)
            theWarnings=struct2cell(obj.WarningStruct);
        end


        function setCurrentContextForErrorMechanism(obj,context)
            obj.ErrorCurrentContext=context;
        end

        function setCurrentContext(obj,context)
            obj.CurrentContext=context;
        end


        function context=getCurrentContext(obj)
            context=obj.CurrentContext;
        end


        function Debug=getDebug(obj)
            Debug=obj.Debug;
        end


        function Ruleset=getRuleset(obj)
            Ruleset=obj.Ruleset;
        end


        function flag=bodyThrowsError(obj)
            flag=obj.ThrowsError;
        end


        function acknowledgeError(obj)
            obj.ThrowsError=false;
        end


        function flag=initializeBlockError(obj)
            flag=obj.InitializeBlockError;
        end


        function allocateJumpCountReg(obj)
            if isempty(obj.JumpCountReg)
                obj.JumpCountReg=rGet(obj);
            end
        end


        function allocateErrorCheckCountReg(obj)
            if isempty(obj.ErrorCheckCountReg)
                obj.ErrorCheckCountReg=rGet(obj);
            end
        end



        function allocateRandState(obj,emitter)

            obj.RandStateCudaType='const uint32_T *';

            switch obj.RandType
            case{'MRG32K3A'}
                fstruct=getRandInitFcn(emitter);
                manageFunc(obj,fstruct);
                obj.RandStateReg1=rdGet(obj);
                obj.RandStateReg2=rdGet(obj);
                obj.RandStateReg3=rdGet(obj);

            case{'Threefry4x64_20'}
                obj.Random123WordSuf='.u64';
                obj.Random123CounterRegisters={rdGet(obj),rdGet(obj),rdGet(obj),rdGet(obj)};
                obj.Random123KeyRegisters={rdGet(obj),rdGet(obj),rdGet(obj),rdGet(obj)};
                obj.Random123Counter=rGet(obj);
                obj.Random123CounterType=parallel.internal.types.Atomic.buildAtomic('uint64',false);
                obj.Random123CacheRegisters={fdGet(obj),fdGet(obj),fdGet(obj),fdGet(obj)};

                obj.BoxMullerInitFlag=rGet(obj);
                obj.BoxMullerCacheRegisters={fdGet(obj),fdGet(obj),fdGet(obj),fdGet(obj)};
                obj.Random123LastWasBoxMuller=rGet(obj);
            case{'Philox4x32_10'}
                obj.Random123WordSuf='.u32';
                obj.Random123CounterRegisters={rGet(obj),rGet(obj),rGet(obj),rGet(obj)};
                obj.Random123KeyRegisters={rGet(obj),rGet(obj)};
                obj.Random123Counter=rGet(obj);
                obj.Random123CounterType=parallel.internal.types.Atomic.buildAtomic('uint32',false);
                obj.Random123CacheRegisters={fdGet(obj),fdGet(obj)};

                obj.BoxMullerInitFlag=rGet(obj);
                obj.BoxMullerCacheRegisters={fdGet(obj),fdGet(obj)};
                obj.Random123LastWasBoxMuller=rGet(obj);
            end

        end


        function flag=containsNonStaticLoop(obj)
            flag=~isempty(obj.JumpCountReg)||~isempty(obj.ErrorCheckCountReg);
        end


        function flag=containsRandCall(obj)
            flag=~isempty(obj.RandStateReg1)...
            ||~isempty(obj.Random123CounterRegisters)...
            ||~isempty(obj.Random123KeyRegisters);
        end





        function generatorType=getRandGeneratorType(obj)
            generatorType=obj.RandType;
        end

        function transformType=getRandTransformType(obj)
            transformType=obj.RandTransformType;
        end

        function[randStateReg1,randStateReg2,randStateReg3]=getRandStateRegisters(obj)
            randStateReg1=obj.RandStateReg1;
            randStateReg2=obj.RandStateReg2;
            randStateReg3=obj.RandStateReg3;
        end


        function wordsize=getRandom123WordSuf(obj)
            wordsize=obj.Random123WordSuf;
        end


        function counterRegisters=getRandom123CounterRegisters(obj)
            counterRegisters=obj.Random123CounterRegisters;
        end


        function counterType=getRandom123CounterType(obj)
            counterType=obj.Random123CounterType;
        end


        function keyRegisters=getRandom123KeyRegisters(obj)
            keyRegisters=obj.Random123KeyRegisters;
        end


        function randCounter=getRandom123Counter(obj)
            randCounter=obj.Random123Counter;
        end


        function cacheRegisters=getRandom123CacheRegisters(obj)
            cacheRegisters=obj.Random123CacheRegisters;
        end


        function initFlag=getBoxMullerInitFlag(obj)
            initFlag=obj.BoxMullerInitFlag;
        end


        function cacheRegisters=getBoxMullerCacheRegisters(obj)
            cacheRegisters=obj.BoxMullerCacheRegisters;
        end



        function lastWasBoxMuller=getRandom123LastWasBoxMuller(obj)
            lastWasBoxMuller=obj.Random123LastWasBoxMuller;
        end





        function ptrsuffix=getMachineptr(obj)
            if obj.Machineptr64p
                ptrsuffix='.u64';
            else
                ptrsuffix='.u32';
            end
        end


        function reg=getJumpCountReg(obj)
            reg=obj.JumpCountReg;
        end


        function reg=getErrorCheckCountReg(obj)
            reg=obj.ErrorCheckCountReg;
        end

        function cudatype=getRandStateCudaType(obj)
            cudatype=obj.RandStateCudaType;
        end



        function reg=rbGet(obj)
            reg=rGet(obj);
        end


        function reg=rhGet(obj)
            reg=rGet(obj);
        end


        function reg=rGet(obj)
            reg=sprintf('%%r%d',obj.R_regno);
            obj.R_regno=obj.R_regno+1;
        end


        function reg=rdGet(obj)
            reg=sprintf('%%rd%d',obj.Rd_regno);
            obj.Rd_regno=obj.Rd_regno+1;
        end


        function reg=fGet(obj)
            reg=sprintf('%%f%d',obj.F_regno);
            obj.F_regno=obj.F_regno+1;
        end


        function reg=fdGet(obj)
            reg=sprintf('%%fd%d',obj.Fd_regno);
            obj.Fd_regno=obj.Fd_regno+1;
        end


        function reg=pGet(obj)
            reg=sprintf('%%p%d',obj.P_regno);
            obj.P_regno=obj.P_regno+1;
        end


        function reg=ptrGet(obj)
            if obj.Machineptr64p
                reg=rdGet(obj);
            else
                reg=rGet(obj);
            end
        end


        function[reg,reg2]=tGet(obj,type)

            reg2='';

            if isDouble(type)
                reg=fdGet(obj);
            elseif isSingle(type)
                reg=fGet(obj);
            elseif isComplexDouble(type)
                reg=fdGet(obj);
                reg2=fdGet(obj);
            elseif isComplexSingle(type)
                reg=fGet(obj);
                reg2=fGet(obj);
            elseif isLogical(type)
                reg=rGet(obj);
            elseif isInt32(type)||isUint32(type)
                reg=rGet(obj);
            elseif isInt64(type)||isUint64(type)
                reg=rdGet(obj);
            elseif isInt16(type)||isUint16(type)||isChar(type)
                reg=rhGet(obj);
            elseif isInt8(type)||isUint8(type)
                reg=rbGet(obj);
            elseif isComplexInt32(type)||isComplexUint32(type)
                reg=rGet(obj);
                reg2=rGet(obj);
            elseif isComplexInt64(type)||isComplexUint64(type)
                reg=rdGet(obj);
                reg2=rdGet(obj);
            elseif isComplexInt16(type)||isComplexUint16(type)
                reg=rhGet(obj);
                reg2=rhGet(obj);
            elseif isComplexInt8(type)||isComplexUint8(type)
                reg=rbGet(obj);
                reg2=rbGet(obj);
            else
                assert(false,'Unsupported type ''%s''.',mType(type));
            end

        end


        function numberOfRegisters=getRegRB(obj)
            numberOfRegisters=obj.Rb_regno;
        end

        function numberOfRegisters=getRegRH(obj)
            numberOfRegisters=obj.Rh_regno;
        end

        function numberOfRegisters=getRegR(obj)
            numberOfRegisters=obj.R_regno;
        end

        function numberOfRegisters=getRegRD(obj)
            numberOfRegisters=obj.Rd_regno;
        end

        function numberOfRegisters=getRegF(obj)
            numberOfRegisters=obj.F_regno;
        end

        function numberOfRegisters=getRegFD(obj)
            numberOfRegisters=obj.Fd_regno;
        end

        function numberOfRegisters=getRegP(obj)
            numberOfRegisters=obj.P_regno;
        end


        function label=labelGet(obj)
            label=sprintf('$LtMW_0_%04d',obj.Labelnumber);
            obj.Labelnumber=obj.Labelnumber+1;
        end







        function inlinePTX=emitAsInlinePTX(obj,fstruct)
            inlinePTX=fstruct.inlineFunction&&~strcmp(obj.HostOS,'MACI64');
        end


        function addHeader(obj,symbolname,ptxcode)
            newHeader=struct(...
            'SymbolName',symbolname,...
            'PTXCode',ptxcode);
            obj.NeededHeaders(end+1,1)=newHeader;
        end


        function headers=getHeaders(obj,headerTable)

            headers=cell(size(obj.NeededHeaders));
            if isempty(headers)
                return
            end



            [symbols,ia]=unique({obj.NeededHeaders.SymbolName});
            [ia,idx]=sort(ia);
            symbols=symbols(idx);
            headers={obj.NeededHeaders(ia).PTXCode};
            allSymbols={headerTable.SymbolName};


            emptyHeaders=cellfun(@isempty,headers);
            [~,idx]=ismember(symbols(emptyHeaders),allSymbols);
            [headers{emptyHeaders}]=deal(headerTable(idx).PTXCode);


            internalSymbols=strncmp(symbols,'__',2);
            symbols=[symbols(internalSymbols),symbols(~internalSymbols)];
            headers=[headers(internalSymbols),headers(~internalSymbols)];






            done=false;
            origOrder=1:numel(symbols);
            while~done
                desiredPosition=origOrder;
                for ss=2:numel(symbols)
                    c=contains(headers(1:ss-1),symbols{ss});
                    if any(c)
                        desiredPosition(ss)=find(c,1)-1;
                    end
                end
                done=isequal(desiredPosition,origOrder);
                if~done
                    [~,idx]=sort(desiredPosition);
                    symbols=symbols(idx);
                    headers=headers(idx);
                end
            end
        end


        function kernels=getKernels(obj)

            kernels={};

            if~isempty(obj.NeededKernels)
                kernels=unique(obj.NeededKernels);
            end

        end


        function funcName=manageFunc(obj,fstruct)

            if fstruct.throwsError
                obj.ThrowsError=true;
                obj.InitializeBlockError=true;
            end

            funcName=fstruct.name;

            if~emitAsInlinePTX(obj,fstruct)
                obj.NeededKernels{end+1}=fstruct.code;
            end


            obj.NeededHeaders=[obj.NeededHeaders;fstruct.headers];
        end


        function encounteredError(obj,msg)


            fpathname=obj.ErrorCurrentContext;



            if isa(msg,'message')
                incomingTag=msg.Identifier;
                msgString=getString(msg);


                linkTagOpen='<a href="matlab:helpview(''parallel-computing'',''GPU_TIPS_AND_RESTRICTIONS'')">';
                linkTagClose='</a>';
                linkmsg=message('parallel:gpu:compiler:WrapperForTipsAndRestrictionsDocLink',...
                msgString,linkTagOpen,linkTagClose);
                msgString=getString(linkmsg);

            elseif isa(msg,'MException')
                incomingTag=msg.identifier;
                msgString=msg.message;
            else

                assert(false,'Encountered an unknown error type');
            end

            if obj.Debug&&~isempty(fpathname)&&~isempty(obj.ErrorNode)
                line=lineno(obj.ErrorNode);
                linkTagOpen=sprintf('<a href="matlab: opentoline(''%s'',%i,0)">',fpathname,line);
                linkTagClose=sprintf('%i</a>',line);

                [~,fcnName,~]=fileparts(fpathname);


                linkmsg=message('parallel:gpu:compiler:WrapperForLink',...
                msgString,fcnName,linkTagOpen,linkTagClose);
                msgString=getString(linkmsg);
            end


            exception=MException(incomingTag,'%s',msgString);
            throwAsCaller(exception);

        end
    end
end
