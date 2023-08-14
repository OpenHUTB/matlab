classdef(StrictDefaults)DVBS2LDPCMetricCalculator<matlab.System




%#codegen

    properties(Nontunable)
        ScalingFactor=1;
        alphaWL=6;
        alphaFL=0;
        betadecmpWL=36;
        nLayers=1080;
    end

    properties(Nontunable,Access=private)
        memDepth;
        minWL;
    end


    properties(Access=private)


        functionalUnit;
        betaMemory;
        betaDecompDelayBalancer1;
        betaDecompDelayBalancer2;
        betaDecompDelayBalancer3;
        delayBalancer1;
        delayBalancer2;
        delayBalancer3;
        delayBalancer4;
        vDShift;
        vDValid;


        betaDecomp1;
        betaDecomp2;
        betaValid;
        ddsmInd;
        sData;
        sValid;
        wrAddr;
        rdAddr;
        wrValid;
        wrEnbReg;


        gammaOut;
        gammaValid;
        gParValid;
        sDataOut;
    end

    methods


        function obj=DVBS2LDPCMetricCalculator(varargin)
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

            reset(obj.functionalUnit);
            reset(obj.betaMemory);
            reset(obj.betaDecompDelayBalancer1);
            reset(obj.betaDecompDelayBalancer2);
            reset(obj.betaDecompDelayBalancer3);
            reset(obj.delayBalancer1);
            reset(obj.delayBalancer2);
            reset(obj.delayBalancer3);
            reset(obj.delayBalancer4);
            reset(obj.vDShift);
            reset(obj.vDValid);

            obj.gammaOut(:)=zeros(obj.memDepth,1);
            obj.gammaValid(:)=false;
            obj.gParValid(:)=false;
            obj.sDataOut(:)=zeros(obj.memDepth,1);
        end

        function setupImpl(obj,varargin)
            obj.memDepth=45;
            obj.minWL=obj.alphaWL-3;


            obj.functionalUnit=satcomhdl.internal.DVBS2LDPCFunctionalUnit(...
            'ScalingFactor',obj.ScalingFactor,'alphaWL',obj.alphaWL,'alphaFL',obj.alphaFL,...
            'betadecmpWL',obj.betadecmpWL);

            obj.betaMemory=satcomhdl.internal.DVBS2LDPCCheckNodeRAM('nLayers',obj.nLayers);

            obj.vDShift=hdl.RAM('RAMType','Simple dual port');
            obj.vDValid=hdl.RAM('RAMType','Simple dual port');


            obj.betaDecompDelayBalancer1=dsp.Delay(obj.memDepth);
            obj.betaDecompDelayBalancer2=dsp.Delay(obj.memDepth);
            obj.betaDecompDelayBalancer3=dsp.Delay(1);
            obj.delayBalancer1=dsp.Delay(obj.memDepth*4);
            obj.delayBalancer2=dsp.Delay(4);
            obj.delayBalancer3=dsp.Delay(4);
            obj.delayBalancer4=dsp.Delay(obj.memDepth*4);


            obj.betaDecomp1=fi(zeros(obj.memDepth,1),0,obj.betadecmpWL,0);
            obj.betaDecomp2=fi(zeros(obj.memDepth,1),0,2*obj.minWL,0);
            obj.betaValid=false;
            obj.ddsmInd=false;
            obj.sData=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.sValid=false;
            obj.wrAddr=fi(0,0,5,0,hdlfimath);
            obj.rdAddr=fi(0,0,5,0,hdlfimath);
            obj.wrValid=false;
            obj.wrEnbReg=false;


            obj.gammaOut=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.gammaValid=false;
            obj.gParValid=false;
            obj.sDataOut=cast(zeros(obj.memDepth,1),'like',varargin{1});
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.gammaOut;
            varargout{2}=obj.gammaValid;
            varargout{3}=obj.gParValid;
            varargout{4}=obj.sDataOut;
        end

        function updateImpl(obj,varargin)

            data=varargin{1};
            valid=varargin{2};
            shift=varargin{3};
            reset=varargin{4};
            ddsm=varargin{5};
            parvalid=varargin{6};
            layeridx=varargin{7};
            betaenb=varargin{8};
            degree=varargin{9};


            shiftdata1=circshift(data,int32(obj.memDepth-shift));

            betain1=obj.betaDecomp1;
            betain2=obj.betaDecomp2;
            wrenb=obj.betaValid;


            rdenb=(valid&&(~obj.sValid))&&betaenb;


            [cnudecomp1,cnudecomp2,cnuvalid]=obj.betaMemory(betain1,betain2,...
            layeridx,rdenb,wrenb);


            [gamma,validout,betadecomp1,betadecomp2,betavalid]=...
            obj.functionalUnit(obj.sData,obj.sValid,...
            degree,cnudecomp1,cnudecomp2,cnuvalid,reset,obj.ddsmInd);

            obj.ddsmInd(:)=ddsm;
            obj.sData(:)=shiftdata1';
            obj.sValid(:)=valid;

            obj.betaDecomp1(:)=obj.betaDecompDelayBalancer1(betadecomp1);
            obj.betaDecomp2(:)=obj.betaDecompDelayBalancer2(betadecomp2);
            obj.betaValid(:)=obj.betaDecompDelayBalancer3(betavalid);


            [wr_addr,wr_enb,rd_addr]=variableDelay(obj,valid,validout);

            sval=obj.vDShift(shift,wr_addr,wr_enb,rd_addr);
            gpvalid=obj.vDValid(fi(parvalid,0,1,0),wr_addr,obj.wrEnbReg,rd_addr);
            obj.wrEnbReg(:)=wr_enb;


            obj.gammaOut(:)=obj.delayBalancer1(circshift(gamma,int32(sval)));
            obj.gammaValid(:)=obj.delayBalancer2(validout);
            obj.gParValid(:)=obj.delayBalancer3(gpvalid);

            obj.sDataOut(:)=obj.delayBalancer4(gamma);

        end

        function[wr_addr,wr_enb,rd_addr]=variableDelay(obj,wr_valid,rd_valid)
            wr_addr=obj.wrAddr;

            if wr_valid
                obj.wrAddr(:)=obj.wrAddr+1;
            else
                obj.wrAddr(:)=0;
            end

            if rd_valid
                obj.rdAddr(:)=obj.rdAddr+1;
            else
                obj.rdAddr(:)=0;
            end

            obj.wrValid(:)=wr_valid;
            wr_enb=obj.wrValid;
            rd_addr=obj.rdAddr;
        end

        function num=getNumInputsImpl(~)
            num=9;
        end

        function num=getNumOutputsImpl(~)
            num=4;
        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked

                s.functionalUnit=obj.functionalUnit;
                s.betaMemory=obj.betaMemory;
                s.betaDecompDelayBalancer1=obj.betaDecompDelayBalancer1;
                s.betaDecompDelayBalancer2=obj.betaDecompDelayBalancer2;
                s.betaDecompDelayBalancer3=obj.betaDecompDelayBalancer3;
                s.delayBalancer1=obj.delayBalancer1;
                s.delayBalancer2=obj.delayBalancer2;
                s.delayBalancer3=obj.delayBalancer3;
                s.delayBalancer4=obj.delayBalancer4;
                s.vDShift=obj.vDShift;
                s.vDValid=obj.vDValid;


                s.betaDecomp1=obj.betaDecomp1;
                s.betaDecomp2=obj.betaDecomp2;
                s.betaValid=obj.betaValid;
                s.ddsmInd=obj.ddsmInd;
                s.sData=obj.sData;
                s.sValid=obj.sValid;
                s.wrAddr=obj.wrAddr;
                s.rdAddr=obj.rdAddr;
                s.wrValid=obj.wrValid;
                s.wrEnbReg=obj.wrEnbReg;
                s.memDepth=obj.memDepth;
                s.minWL=obj.minWL;


                s.gammaOut=obj.gammaOut;
                s.gammaValid=obj.gammaValid;
                s.gParValid=obj.gParValid;
                s.sDataOut=obj.sDataOut;
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
