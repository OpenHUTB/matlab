classdef(StrictDefaults)DVBS2LDPCCodeParameters<matlab.System





%#codegen

    properties(Nontunable)
        Termination='Max';
        SpecifyInputs='Property';
        NumIterations=8;
        MaxNumIterations=8;
    end


    properties(Access=private)
        dataCount;
        parityInd;
        frameValid;
        endInd;
        endIndReg;
        endReg;
        validReg;
        dataOut;
        validOut;
        frameValidOut;
        resetOut;
        endIndOut;
        numIterOut;
        parityIndOut;
    end

    properties(Constant,Hidden)
        TerminationSet=matlab.system.StringSet({'Max','Early'});
        SpecifyInputsSet=matlab.system.StringSet({'Input port','Property'});
    end

    methods

        function obj=DVBS2LDPCCodeParameters(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function resetImpl(obj)

            obj.dataOut(:)=zeros(1,1);
            obj.validOut=false;
            obj.frameValidOut=false;
            obj.resetOut=false;
            obj.endIndOut=false;
            obj.numIterOut=fi(8,0,8,0);
            obj.parityIndOut=false;

            obj.dataCount(:)=0;
            obj.parityInd=false;
            obj.frameValid=false;
            obj.endInd=false;
            obj.endIndReg=false;
            obj.endReg=false;
            obj.validReg=false;
        end

        function setupImpl(obj,varargin)

            obj.dataOut=cast(zeros(1,1),'like',varargin{1});
            obj.validOut=false;
            obj.frameValidOut=false;
            obj.resetOut=false;
            obj.endIndOut=false;
            obj.numIterOut=fi(8,0,8,0);
            obj.parityIndOut=false;

            obj.dataCount=fi(0,0,16,0,hdlfimath);
            obj.parityInd=false;
            obj.frameValid=false;
            obj.endInd=false;
            obj.endIndReg=false;
            obj.endReg=false;
            obj.validReg=false;
        end

        function varargout=outputImpl(obj,varargin)

            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
            varargout{3}=obj.frameValidOut;
            varargout{4}=obj.resetOut;
            varargout{5}=obj.endIndOut;
            varargout{6}=obj.numIterOut;
            varargout{7}=obj.parityIndOut;
        end

        function updateImpl(obj,varargin)

            dataIn=varargin{1};
            ctrlIn.start=varargin{2}.start;
            ctrlIn.end=varargin{2}.end;
            ctrlIn.valid=varargin{2}.valid;

            niter=varargin{3};
            outlen=varargin{4};



            [reset,frame_valid,endind,parityind]=frameController(obj,ctrlIn.start,ctrlIn.end,ctrlIn.valid,outlen);

            obj.dataOut(:)=dataIn;
            obj.validOut(:)=ctrlIn.valid;
            obj.frameValidOut(:)=frame_valid;
            obj.resetOut(:)=reset;
            obj.endIndOut(:)=endind;
            obj.parityIndOut(:)=parityind;


            if strcmpi(obj.SpecifyInputs,'Input port')
                if(obj.resetOut)
                    if(niter>63)||(niter<1)
                        obj.numIterOut(:)=8;
                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            coder.internal.warning('whdl:DVBS2LDPCDecoder:InvalidNumIter');
                        end
                    else
                        obj.numIterOut(:)=niter;
                    end
                end
            elseif strcmpi(obj.Termination,'Early')
                obj.numIterOut(:)=obj.MaxNumIterations;
            else
                obj.numIterOut(:)=obj.NumIterations;
            end

        end

        function[reset,frame_valid,endind,parityind]=frameController(obj,starti,endi,validi,outlen)

            reset=starti&&validi;

            if starti&&validi
                obj.frameValid=true;
                obj.endInd=false;
                obj.dataCount(:)=0;
                obj.parityInd(:)=0;
            elseif obj.endReg&&obj.validReg
                obj.frameValid=false;
                obj.endInd=true;
                obj.parityInd(:)=0;
            elseif(obj.frameValid&&validi)
                obj.dataCount(:)=obj.dataCount+1;
                if obj.dataCount==outlen
                    obj.parityInd(:)=1;
                end
            end

            frame_valid=obj.frameValid;
            endind=obj.endInd&&(~obj.endIndReg);
            obj.endIndReg(:)=obj.endInd;
            parityind=obj.parityInd;

            obj.endReg(:)=endi;
            obj.validReg(:)=validi;
        end

        function num=getNumInputsImpl(~)
            num=4;
        end

        function num=getNumOutputsImpl(~)
            num=7;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.frameValid=obj.frameValid;
                s.endInd=obj.endInd;
                s.endReg=obj.endReg;
                s.validReg=obj.validReg;
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.frameValidOut=obj.frameValidOut;
                s.resetOut=obj.resetOut;
                s.endIndOut=obj.endIndOut;
                s.numIterOut=obj.numIterOut;
                s.parityIndOut=obj.parityIndOut;
                s.dataCount=obj.dataCount;
                s.endIndReg=obj.endIndReg;
                s.parityInd=obj.parityInd;
            end
        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

    end
end
