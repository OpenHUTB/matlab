classdef(StrictDefaults)NRLDPCDecoderCodeParameters<matlab.System





%#codegen

    properties(Nontunable)
        SpecifyInputs='Property';
        vectorSize=64;
        Termination='Max';

        RateCompatible(1,1)logical=false;
    end


    properties(Access=private)
        dataIn;
        dataInReg;
        ctrlIn;
        ctrlInReg;
        bgn;
        bgnReg;
        liftingSize;
        liftingSizeReg;
        startValid;
        endValid;
        frame;
        frameValid;
        BGN;
        Ztemp;
        setIndex;
        validZ;
        Z;
        toggle;
        endInd;
        endIndD;
        numIter;
        numIterReg;
        numIterOut;
        set1;
        set2;
        set3;
        set4;
        set5;
        set6;
        set7;
        set8;
        zAddr;

        dataInRegD;
        dataValid;
        frameValidD;
        delayBalancer1;
        delayBalancer2;
        delayBalancer3;
        delayBalancer4;
        delayBalancer5;

        dataOut;
        validOut;
        frameValidOut;
        resetOut;
        endIndOut;
        setIndexReg;
        zAddrReg;
        BGNReg;

        rstNextFrame;
        endValidReg;

        newFrame;
        newCount;
        dataReg;
        frameReg;

        startReg;
        validReg;
        startReg1;
        validReg1;

        numRows;
        numRowsReg;
        numRowsOut;

    end

    properties(Constant,Hidden)
        SpecifyInputsSet=matlab.system.StringSet({'Input port','Property'});
        TerminationSet=matlab.system.StringSet({'Max','Early'});
    end

    methods


        function obj=NRLDPCDecoderCodeParameters(varargin)
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

            obj.dataInRegD(:)=zeros(obj.vectorSize,1);
            obj.ctrlIn=struct('start',false,'end',false,'valid',false);
            obj.ctrlInReg=struct('start',false,'end',false,'valid',false);
            obj.frameValid=false;
            obj.dataValid=false;
            obj.frameValidD=false;
            obj.BGN=false;
            obj.setIndex=fi(0,0,3,0);
            obj.Ztemp=fi(0,0,9,0);
            obj.toggle=true;
            obj.endInd=false;
            obj.endIndD=false;
            reset(obj.delayBalancer1);
            reset(obj.delayBalancer2);
            reset(obj.delayBalancer3);
            reset(obj.delayBalancer4);
            reset(obj.delayBalancer5);

            obj.zAddr=fi(0,0,3,0);
            obj.numIterOut(:)=8;
            obj.rstNextFrame(:)=false;
            obj.endValidReg=false;

            obj.dataOut=obj.dataInRegD;
            obj.validOut=obj.dataValid;
            obj.frameValidOut=obj.frameValidD;
            obj.resetOut=false;
            obj.endIndOut=obj.endIndD;

            obj.setIndexReg=obj.setIndex;
            obj.zAddrReg=fi(0,0,3,0);
            obj.BGNReg=obj.BGN;
            obj.numRowsOut(:)=46;

        end

        function setupImpl(obj,varargin)

            obj.dataIn=cast(zeros(obj.vectorSize,1),'like',varargin{1});
            obj.dataInReg=obj.dataIn;
            obj.dataInRegD=obj.dataIn;
            obj.ctrlIn=struct('start',false,'end',false,'valid',false);
            obj.ctrlInReg=obj.ctrlIn;
            obj.bgn=false;
            obj.bgnReg=obj.bgn;
            obj.liftingSize=fi(0,0,9,0);
            obj.liftingSizeReg=obj.liftingSize;

            obj.startValid=false;
            obj.endValid=false;
            obj.dataValid=false;
            obj.frame=false;
            obj.frameValid=false;
            obj.frameValidD=false;

            obj.BGN=false;
            obj.Ztemp=obj.liftingSize;
            obj.setIndex=fi(0,0,3,0);
            obj.validZ=true;
            obj.Z=obj.liftingSize;
            obj.toggle=true;
            obj.endInd=false;
            obj.endIndD=false;
            obj.numIter=uint8(8);
            obj.numIterReg=uint8(8);
            obj.numIterOut=uint8(8);
            obj.zAddr=fi(0,0,3,0);

            obj.set1=[2,4,8,16,32,64,128,256];
            obj.set2=[3,6,12,24,48,96,192,384];
            obj.set3=[5,10,20,40,80,160,320];
            obj.set4=[7,14,28,56,112,224];
            obj.set5=[9,18,36,72,144,288];
            obj.set6=[11,22,44,88,176,352];
            obj.set7=[13,26,52,104,208];
            obj.set8=[15,30,60,120,240];

            obj.delayBalancer1=dsp.Delay(obj.vectorSize*6);
            obj.delayBalancer2=dsp.Delay(6);
            obj.delayBalancer3=dsp.Delay(5);
            obj.delayBalancer4=dsp.Delay(6);
            obj.delayBalancer5=dsp.Delay(6);

            obj.rstNextFrame=false;
            obj.endValidReg=false;

            obj.newFrame=false;
            obj.newCount=fi(0,0,3,0,hdlfimath);
            obj.dataReg=obj.dataIn;
            obj.frameReg=false;

            obj.startReg=false;
            obj.validReg=false;
            obj.startReg1=false;
            obj.validReg1=false;

            obj.numRows=fi(46,0,6,0);
            obj.numRowsReg=obj.numRows;
            obj.numRowsOut=obj.numRows;
        end

        function varargout=outputImpl(obj,varargin)

            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
            varargout{3}=obj.frameValidOut;
            varargout{4}=obj.resetOut;
            varargout{5}=obj.BGN;
            varargout{6}=obj.setIndexReg;
            varargout{7}=obj.Ztemp;
            varargout{8}=obj.endIndOut;
            varargout{9}=obj.numIterOut;
            varargout{10}=obj.zAddrReg;
            varargout{11}=obj.rstNextFrame;
            varargout{12}=obj.numRowsOut;

        end

        function updateImpl(obj,varargin)

            obj.dataOut=obj.dataInRegD;
            obj.validOut=obj.dataValid;
            obj.frameValidOut=obj.frameValidD;
            obj.resetOut=obj.ctrlIn.start&&obj.ctrlIn.valid;
            obj.endIndOut=obj.endIndD;
            obj.setIndexReg=obj.setIndex;
            obj.zAddrReg=obj.zAddr;
            obj.BGNReg=obj.BGN;

            obj.dataInReg(:)=obj.dataIn;
            obj.ctrlInReg(:)=obj.ctrlIn;
            obj.bgnReg(:)=obj.bgn;
            obj.liftingSizeReg(:)=obj.liftingSize;

            obj.dataReg(:)=obj.delayBalancer1(obj.dataInReg);
            obj.validReg(:)=obj.delayBalancer2(obj.ctrlInReg.valid);
            obj.frameReg(:)=obj.delayBalancer3(obj.frameValid);

            obj.startReg1(:)=obj.startReg;
            obj.validReg1(:)=obj.validReg;

            obj.startReg(:)=obj.delayBalancer5(obj.ctrlInReg.start);

            if obj.newFrame
                obj.dataInRegD(:)=zeros(obj.vectorSize,1);
                obj.dataValid(:)=false;
                obj.frameValidD(:)=false;
            else
                obj.dataInRegD(:)=obj.dataReg;
                obj.dataValid(:)=obj.validReg;
                obj.frameValidD(:)=obj.frameReg;
            end

            if obj.ctrlIn.start&&obj.ctrlIn.valid
                obj.endInd=false;
                reset(obj.delayBalancer4);
            end

            obj.endIndD=obj.delayBalancer4(obj.endInd);

            obj.dataIn(:)=varargin{1};
            obj.ctrlIn(:)=varargin{2};
            obj.bgn(:)=varargin{3};
            obj.liftingSize(:)=varargin{4};%#ok<*STRNU>

            if obj.ctrlIn.start&&obj.ctrlIn.valid
                obj.newFrame(:)=true;
                obj.newCount(:)=0;
            elseif obj.newCount==6
                obj.newFrame(:)=false;
            end

            if obj.newFrame
                obj.newCount(:)=obj.newCount+1;
            end

            obj.endValidReg(:)=obj.endValid;

            obj.startValid(:)=obj.ctrlInReg.start&&obj.ctrlInReg.valid;
            obj.endValid(:)=obj.ctrlInReg.end&&obj.ctrlInReg.valid;

            obj.numIterReg(:)=obj.numIter;
            obj.numRowsReg(:)=obj.numRows;

            if strcmpi(obj.SpecifyInputs,'Input port')
                if(obj.ctrlIn.start&&obj.ctrlIn.valid)
                    obj.numIter(:)=varargin{5};
                    obj.numRows(:)=varargin{6};
                end
                if(obj.startValid)
                    if(obj.numIterReg>63)||(obj.numIterReg<1)
                        obj.numIterOut(:)=8;
                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            coder.internal.warning('whdl:NRLDPCDecoder:InvalidNumIter');
                        end
                    else
                        obj.numIterOut(:)=obj.numIterReg;
                    end
                end
            else
                if obj.ctrlIn.start&&obj.ctrlIn.valid
                    obj.numRows(:)=varargin{5};
                end
            end


            if(obj.startValid)
                obj.rstNextFrame(:)=false;
                obj.BGN(:)=obj.bgnReg;
                obj.Ztemp(:)=obj.liftingSizeReg;
            end


            if obj.BGN==0
                maxlayer=fi(46,0,6,0,hdlfimath);
            else
                maxlayer=fi(42,0,6,0,hdlfimath);
            end

            if obj.RateCompatible
                if(obj.startValid)
                    if((obj.numRowsReg<fi(4,0,6,0,hdlfimath))||(obj.numRowsReg>maxlayer))
                        obj.numRowsOut(:)=46;
                        obj.rstNextFrame=true;
                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            coder.internal.warning('whdl:NRLDPCDecoder:InvalidNumRow');
                        end
                    else
                        obj.numRowsOut(:)=obj.numRowsReg;
                    end
                end
            else
                obj.numRowsOut(:)=maxlayer;
            end


            if(obj.startValid)
                obj.frame(:)=true;
                obj.toggle(:)=false;
                obj.endInd=false;
            elseif(obj.endValid&&~obj.endInd)
                obj.endInd=true;
            elseif(obj.endValidReg)
                obj.frame(:)=false;
            end

            obj.frameValid(:)=obj.frame;


            if obj.startValid
                if~isempty(find(ismember(obj.set1,double(obj.Ztemp))))%#ok<*EFIND>
                    obj.setIndex(:)=0;
                    obj.validZ(:)=true;
                    obj.zAddr(:)=find(ismember(obj.set1,double(obj.Ztemp)))-1;
                elseif~isempty(find(ismember(obj.set2,double(obj.Ztemp))))
                    obj.setIndex(:)=1;
                    obj.validZ(:)=true;
                    obj.zAddr(:)=find(ismember(obj.set2,double(obj.Ztemp)))-1;
                elseif~isempty(find(ismember(obj.set3,double(obj.Ztemp))))
                    obj.setIndex(:)=2;
                    obj.validZ(:)=true;
                    obj.zAddr(:)=find(ismember(obj.set3,double(obj.Ztemp)))-1;
                elseif~isempty(find(ismember(obj.set4,double(obj.Ztemp))))
                    obj.setIndex(:)=3;
                    obj.validZ(:)=true;
                    obj.zAddr(:)=find(ismember(obj.set4,double(obj.Ztemp)))-1;
                elseif~isempty(find(ismember(obj.set5,double(obj.Ztemp))))
                    obj.setIndex(:)=4;
                    obj.validZ(:)=true;
                    obj.zAddr(:)=find(ismember(obj.set5,double(obj.Ztemp)))-1;
                elseif~isempty(find(ismember(obj.set6,double(obj.Ztemp))))
                    obj.setIndex(:)=5;
                    obj.validZ(:)=true;
                    obj.zAddr(:)=find(ismember(obj.set6,double(obj.Ztemp)))-1;
                elseif~isempty(find(ismember(obj.set7,double(obj.Ztemp))))
                    obj.setIndex(:)=6;
                    obj.validZ(:)=true;
                    obj.zAddr(:)=find(ismember(obj.set7,double(obj.Ztemp)))-1;
                elseif~isempty(find(ismember(obj.set8,double(obj.Ztemp))))
                    obj.setIndex(:)=7;
                    obj.validZ(:)=true;
                    obj.zAddr(:)=find(ismember(obj.set8,double(obj.Ztemp)))-1;
                else
                    obj.setIndex(:)=0;
                    obj.validZ(:)=false;
                    obj.zAddr(:)=0;
                end
            end


            if(~obj.validZ)
                obj.Z(:)=2;
                if obj.startReg1&&obj.validReg1
                    obj.validZ(:)=true;
                    obj.rstNextFrame=true;
                    if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                        coder.internal.warning('whdl:NRLDPCDecoder:InvalidZ');
                    end
                else
                    obj.validZ(:)=false;
                end

            else
                obj.Z(:)=obj.Ztemp;
            end

        end

        function num=getNumInputsImpl(obj)
            if strcmpi(obj.SpecifyInputs,'Input port')
                num=6;
            else
                num=5;
            end
        end

        function num=getNumOutputsImpl(~)
            num=12;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.dataIn=obj.dataIn;
                s.dataInReg=obj.dataInReg;
                s.ctrlIn=obj.ctrlIn;
                s.ctrlInReg=obj.ctrlInReg;
                s.bgn=obj.bgn;
                s.bgnReg=obj.bgnReg;
                s.liftingSize=obj.liftingSize;
                s.liftingSizeReg=obj.liftingSizeReg;
                s.startValid=obj.startValid;
                s.endValid=obj.endValid;
                s.endValidReg=obj.endValidReg;
                s.frame=obj.frame;
                s.frameValid=obj.frameValid;
                s.BGN=obj.BGN;
                s.Ztemp=obj.Ztemp;
                s.setIndex=obj.setIndex;
                s.validZ=obj.validZ;
                s.Z=obj.Z;
                s.toggle=obj.toggle;
                s.endInd=obj.endInd;
                s.endIndD=obj.endIndD;
                s.set1=obj.set1;
                s.set2=obj.set2;
                s.set3=obj.set3;
                s.set4=obj.set4;
                s.set5=obj.set5;
                s.set6=obj.set6;
                s.set7=obj.set7;
                s.set8=obj.set8;
                s.numIter=obj.numIter;
                s.numIterReg=obj.numIterReg;
                s.numIterOut=obj.numIterOut;
                s.dataInRegD=obj.dataInRegD;
                s.dataValid=obj.dataValid;
                s.frameValidD=obj.frameValidD;
                s.delayBalancer1=obj.delayBalancer1;
                s.delayBalancer2=obj.delayBalancer2;
                s.delayBalancer3=obj.delayBalancer3;
                s.delayBalancer4=obj.delayBalancer4;
                s.delayBalancer5=obj.delayBalancer5;
                s.zAddr=obj.zAddr;
                s.rstNextFrame=obj.rstNextFrame;
                s.newFrame=obj.newFrame;
                s.newCount=obj.newCount;
                s.dataReg=obj.dataReg;
                s.validReg=obj.validReg;
                s.frameReg=obj.frameReg;

                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.frameValidOut=obj.frameValidOut;
                s.resetOut=obj.resetOut;
                s.endIndOut=obj.endIndOut;
                s.setIndexReg=obj.setIndexReg;
                s.zAddrReg=obj.zAddrReg;
                s.BGNReg=obj.BGNReg;

                s.startReg=obj.startReg;
                s.startReg1=obj.startReg1;
                s.validReg1=obj.validReg1;

                s.numRows=obj.numRows;
                s.numRowsReg=obj.numRowsReg;
                s.numRowsOut=obj.numRowsOut;
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
