classdef(StrictDefaults)CCSDSLDPCFunctionalUnit<matlab.System

%#codegen

    properties(Nontunable)
        alphaWL=6;
        alphaFL=0;
        betaWL=4;
        minWL=3;
        betaCompWL=32;
        betaIdxWL=8;
        memDepth=64;
    end

    properties(Nontunable,Access=private)
        maxCol;
    end


    properties(Access=private)
        gammaOut;
        validOut;
        betaCompress1;
        betaCompress2;
        betaCompress3;
        betaCompress4;
        betaValidOut;
        shiftOut;
        gammaOutReg;
        validOutReg;
        betaCompress1Reg;
        betaCompress2Reg;
        betaCompress3Reg;
        betaCompress4Reg;
        betaValidOutReg;
        shiftOutReg;

        countTo1;
        enb;
        alpha;
        alphaD;
        rdEnable;
        rdEnableD;
        rdEnableDReg;
        countTo2;
        countTo3;
        enb1;
        enb2;
        rdvalid;
        wrAddr;
        rdAddr;
        betatmp;
        valid;
        signsBeta1;
        signsBeta2;
        minVal1;
        minVal2;
        minIdx;
        signsAll;
        prodSign;
        prodSignBit;
        dataMax;

        variableDelay;
        variableDelayShift;
        variableDelayEnb;

        delayBalancer1;
        delayBalancer2;
        delayBalancer3;
        delayBalancer4;
        delayBalancer5;
        delayBalancer6;
        delayBalancer7;
        delayBalancer8;
        delayBalancer9;
    end

    methods


        function obj=CCSDSLDPCFunctionalUnit(varargin)
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

            obj.gammaOut(:)=zeros(obj.memDepth,1);
            obj.validOut(:)=false;
            obj.betaCompress1(:)=zeros(obj.memDepth,1);
            obj.betaCompress2(:)=zeros(obj.memDepth,1);
            obj.betaCompress3(:)=zeros(obj.memDepth,1);
            obj.betaCompress4(:)=zeros(obj.memDepth,1);
            obj.betaValidOut(:)=false;
            obj.shiftOut(:)=0;
            obj.rdEnableD(:)=zeros(obj.memDepth,1)>0;

            obj.gammaOutReg(:)=zeros(obj.memDepth,1);
            obj.validOutReg(:)=false;
            obj.betaCompress1Reg(:)=zeros(obj.memDepth,1);
            obj.betaCompress2Reg(:)=zeros(obj.memDepth,1);
            obj.betaCompress3Reg(:)=zeros(obj.memDepth,1);
            obj.betaCompress4Reg(:)=zeros(obj.memDepth,1);
            obj.betaValidOutReg(:)=false;
            obj.shiftOutReg(:)=0;
            obj.rdEnableDReg(:)=zeros(obj.memDepth,1)>0;

            reset(obj.variableDelay);
        end

        function setupImpl(obj,varargin)

            obj.gammaOut=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.validOut=false;
            obj.gammaOutReg=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.validOutReg=false;


            obj.betaCompress1=fi(zeros(obj.memDepth,1),0,obj.betaCompWL,0);
            obj.betaCompress2=fi(zeros(obj.memDepth,1),0,obj.betaCompWL,0);
            obj.betaCompress3=fi(zeros(obj.memDepth,1),0,obj.betaIdxWL,0);
            obj.betaCompress4=fi(zeros(obj.memDepth,1),0,2*obj.minWL,0);
            obj.betaValidOut=false;
            obj.shiftOut=cast(0,'like',varargin{11});
            obj.betaCompress1Reg=fi(zeros(obj.memDepth,1),0,obj.betaCompWL,0);
            obj.betaCompress2Reg=fi(zeros(obj.memDepth,1),0,obj.betaCompWL,0);
            obj.betaCompress3Reg=fi(zeros(obj.memDepth,1),0,obj.betaIdxWL,0);
            obj.betaCompress4Reg=fi(zeros(obj.memDepth,1),0,2*obj.minWL,0);
            obj.betaValidOutReg=false;
            obj.shiftOutReg=cast(0,'like',varargin{11});

            obj.countTo1=cast(0,'like',varargin{3});
            obj.enb=false;
            obj.alpha=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.countTo2=cast(0,'like',varargin{3});
            obj.countTo3=cast(0,'like',varargin{3});
            obj.enb1=false;
            obj.enb2=false;
            obj.rdvalid=false;
            obj.valid=false;
            obj.wrAddr=uint8(0);
            obj.rdAddr=uint8(0);
            obj.betatmp=fi(zeros(obj.memDepth,1),1,obj.betaWL,obj.alphaFL);

            WL=obj.minWL+1;
            obj.alphaD=cast(zeros(obj.memDepth,1),'like',obj.betatmp);
            obj.dataMax=cast(ones(obj.memDepth,1)*2^(WL-1)-1,'like',obj.betatmp);
            obj.variableDelay=hdl.RAM('RAMType','Simple dual port');
            obj.rdEnable=zeros(obj.memDepth,1)>0;
            obj.rdEnableD=zeros(obj.memDepth,1)>0;
            obj.rdEnableDReg=zeros(obj.memDepth,1)>0;

            obj.variableDelayShift=hdl.RAM('RAMType','Simple dual port');
            obj.variableDelayEnb=hdl.RAM('RAMType','Simple dual port');

            obj.minVal1=fi(ones(obj.memDepth,1)*obj.dataMax(1),0,obj.minWL,obj.alphaFL);
            obj.minVal2=fi(ones(obj.memDepth,1)*obj.dataMax(1),0,obj.minWL,obj.alphaFL);
            obj.minIdx=fi(zeros(obj.memDepth,1),0,obj.betaIdxWL-1,0);
            obj.prodSign=fi(ones(obj.memDepth,1),1,2,0);
            obj.prodSignBit=fi(ones(obj.memDepth,1),0,1,0);

            if obj.memDepth==64
                obj.signsBeta1=fi(zeros(2*obj.betaCompWL,obj.memDepth),1,2,0);
                obj.signsBeta2=fi(zeros(2*obj.betaCompWL,obj.memDepth),1,2,0);
                obj.maxCol=64;
            else
                obj.signsBeta1=fi(zeros(obj.betaCompWL,obj.memDepth),1,2,0);
                obj.signsBeta2=fi(zeros(obj.betaCompWL,obj.memDepth),1,2,0);
                obj.maxCol=31;
            end
            obj.signsAll=fi(zeros(obj.maxCol,obj.memDepth),0,1,0);

            obj.delayBalancer1=dsp.Delay(obj.memDepth*4);
            obj.delayBalancer2=dsp.Delay(4);
            obj.delayBalancer3=dsp.Delay(obj.memDepth*3);
            obj.delayBalancer4=dsp.Delay(obj.memDepth*3);
            obj.delayBalancer5=dsp.Delay(obj.memDepth*3);
            obj.delayBalancer6=dsp.Delay(obj.memDepth*3);
            obj.delayBalancer7=dsp.Delay(3);
            obj.delayBalancer8=dsp.Delay(4);
            obj.delayBalancer9=dsp.Delay(obj.memDepth*4);

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.gammaOutReg;
            varargout{2}=obj.validOutReg;
            varargout{3}=obj.betaCompress1Reg;
            varargout{4}=obj.betaCompress2Reg;
            varargout{5}=obj.betaCompress3Reg;
            varargout{6}=obj.betaCompress4Reg;
            varargout{7}=obj.betaValidOutReg;
            varargout{8}=obj.shiftOutReg;
            varargout{9}=obj.rdEnableDReg;
        end

        function updateImpl(obj,varargin)

            validD=obj.valid;

            data=varargin{1};
            obj.valid=varargin{2};
            count=varargin{3};
            rdenable=varargin{4};
            betacompress1=fi(varargin{5},0,obj.betaCompWL,0);
            betacompress2=fi(varargin{6},0,obj.betaCompWL,0);
            betacompress3=fi(varargin{7},0,obj.betaIdxWL,0);
            betacompress4=varargin{8};
            beta_valid=varargin{9};
            reset=varargin{10};
            shift=varargin{11};

            if reset
                obj.gammaOut(:)=zeros(obj.memDepth,1);
                obj.validOut(:)=false;
                obj.betaCompress1(:)=zeros(obj.memDepth,1);
                obj.betaCompress2(:)=zeros(obj.memDepth,1);
                obj.betaCompress3(:)=zeros(obj.memDepth,1);
                obj.betaCompress4(:)=zeros(obj.memDepth,1);
                obj.betaValidOut(:)=false;

                obj.countTo1(:)=0;
                obj.enb(:)=false;
                obj.alpha(:)=cast(zeros(obj.memDepth,1),'like',varargin{1});
                obj.countTo2(:)=0;
                obj.countTo3(:)=0;
                obj.enb1(:)=false;
                obj.enb2(:)=false;
                obj.rdvalid(:)=false;
                obj.valid(:)=false;
                obj.wrAddr(:)=0;
                obj.rdAddr(:)=0;
                obj.betatmp(:)=zeros(obj.memDepth,1);

                WL=obj.minWL+1;
                obj.alphaD(:)=zeros(obj.memDepth,1);
                obj.dataMax(:)=ones(obj.memDepth,1)*2^(WL-1)-1;
                obj.minVal1(:)=ones(obj.memDepth,1)*obj.dataMax(1);
                obj.minVal2(:)=ones(obj.memDepth,1)*obj.dataMax(1);
                obj.minIdx(:)=zeros(obj.memDepth,1);
                obj.prodSign(:)=zeros(obj.memDepth,1);
                obj.prodSignBit(:)=zeros(obj.memDepth,1);
                obj.signsAll(:)=zeros(obj.maxCol,obj.memDepth);
            end


            if obj.memDepth==64
                for idx=1:32
                    obj.signsBeta1(idx,:)=fi(bitget(betacompress1,33-idx),1,2,0);
                end
                for idx=33:64
                    obj.signsBeta1(idx,:)=fi(bitget(betacompress2,65-idx),1,2,0);
                end
            else
                for idx=1:31
                    obj.signsBeta1(idx,:)=fi(bitget(betacompress1,32-idx),1,2,0);
                end
            end

            min_index=bitsliceget(betacompress3,obj.betaIdxWL-1,1);
            prodsign=fi(bitsliceget(betacompress3,obj.betaIdxWL,obj.betaIdxWL),1,2,0);

            min2=bitsliceget(betacompress4,obj.minWL,1);
            min1=bitsliceget(betacompress4,2*(obj.minWL),obj.minWL+1);

            min2=fi(double(min2)/(2^obj.alphaFL),0,obj.minWL,obj.alphaFL);
            min1=fi(double(min1)/(2^obj.alphaFL),0,obj.minWL,obj.alphaFL);

            obj.signsBeta1(obj.signsBeta1==0)=fi(-1,1,2,0);
            prodsign(prodsign==0)=fi(-1,1,2,0);


            if beta_valid
                obj.countTo1(:)=0;
                obj.enb=true;
            else
                if obj.countTo1==count
                    obj.countTo1(:)=0;
                    obj.enb=false;
                else
                    if(obj.enb)
                        obj.countTo1(:)=obj.countTo1+1;
                        obj.enb=true;
                    else
                        obj.enb=false;
                    end
                end
            end

            beta_tmp=calculateBeta(obj,prodsign,obj.signsBeta1,min1,min2,min_index,obj.countTo1,rdenable);



            obj.alphaD(:)=obj.alpha;

            if obj.enb
                beta=beta_tmp;
            else
                beta=cast(zeros(obj.memDepth,1),'like',beta_tmp);
            end

            if obj.valid
                for idx=1:obj.memDepth
                    obj.alpha(idx)=cast(data(idx)-beta(idx),'like',obj.alpha);
                end
            end



            if validD
                if obj.countTo2==count
                    enable=true;
                else
                    enable=false;
                end
                calculateBetaCompressed(obj,obj.alphaD,validD,enable,obj.rdEnable);
                if obj.countTo2==count
                    obj.countTo2(:)=0;
                else
                    obj.countTo2(:)=obj.countTo2+1;
                end
            else
                enable=false;
            end

            obj.rdEnable(:)=rdenable;
            obj.betaValidOut(:)=enable;


            if obj.memDepth==64
                for idx=1:32
                    obj.signsBeta2(idx,:)=fi(bitget(obj.betaCompress1,33-idx),1,2,0);
                end
                for idx=33:64
                    obj.signsBeta2(idx,:)=fi(bitget(obj.betaCompress2,65-idx),1,2,0);
                end
            else
                for idx=1:31
                    obj.signsBeta2(idx,:)=fi(bitget(obj.betaCompress1,32-idx),1,2,0);
                end
            end

            min_index_1=bitsliceget(obj.betaCompress3,obj.betaIdxWL-1,1);
            prodsign_1=fi(bitsliceget(obj.betaCompress3,obj.betaIdxWL,obj.betaIdxWL),1,2,0);

            min2_1=bitsliceget(obj.betaCompress4,obj.minWL,1);
            min1_1=bitsliceget(obj.betaCompress4,2*(obj.minWL),obj.minWL+1);

            min2_1=fi(double(min2_1)/(2^obj.alphaFL),0,obj.minWL,obj.alphaFL);
            min1_1=fi(double(min1_1)/(2^obj.alphaFL),0,obj.minWL,obj.alphaFL);

            obj.signsBeta2(obj.signsBeta2==0)=fi(-1,1,2,0);
            prodsign_1(prodsign_1==0)=fi(-1,1,2,0);
            obj.enb2=obj.enb1;


            if obj.betaValidOut
                obj.countTo3(:)=0;
                obj.enb1=true;
            else
                if obj.countTo3==count
                    obj.countTo3(:)=0;
                    obj.enb1=false;
                else
                    if(obj.enb1)
                        obj.countTo3(:)=obj.countTo3+1;
                        obj.enb1=true;
                    else
                        obj.enb1=false;
                    end
                end
            end


            wraddr=obj.wrAddr;
            addrGeneration(obj,obj.betaValidOut,count,obj.valid);

            rdaddr=obj.rdAddr;
            alpha_delay=step(obj.variableDelay,obj.alpha,wraddr,obj.valid,rdaddr);
            obj.shiftOut(:)=step(obj.variableDelayShift,shift,wraddr,obj.valid,rdaddr);
            obj.rdEnableD(:)=step(obj.variableDelayEnb,fi(rdenable,0,1,0),wraddr,obj.valid,rdaddr);

            beta_tmp_1=calculateBeta(obj,prodsign_1,obj.signsBeta2,min1_1,min2_1,min_index_1,obj.countTo3,obj.rdEnableD);


            if obj.enb1
                for idx=1:obj.memDepth
                    obj.gammaOut(idx)=cast(alpha_delay(idx)+beta_tmp_1(idx),'like',obj.gammaOut);
                end
            end
            obj.betatmp(:)=beta_tmp_1;
            obj.validOut(:)=obj.enb1;

            gamma_delay=obj.delayBalancer1(obj.gammaOut);
            valid_delay=obj.delayBalancer2(obj.validOut);
            bcomp1_delay=obj.delayBalancer3(obj.betaCompress1);
            bcomp2_delay=obj.delayBalancer4(obj.betaCompress2);
            bcomp3_delay=obj.delayBalancer5(obj.betaCompress3);
            bcomp4_delay=obj.delayBalancer6(obj.betaCompress4);
            bvalid_delay=obj.delayBalancer7(obj.betaValidOut);
            shift_delay=obj.delayBalancer8(obj.shiftOut);
            rd_delay=obj.delayBalancer9(obj.rdEnableD);

            obj.gammaOutReg(:)=gamma_delay;
            obj.validOutReg(:)=valid_delay;
            obj.betaCompress1Reg(:)=bcomp1_delay;
            obj.betaCompress2Reg(:)=bcomp2_delay;
            obj.betaCompress3Reg(:)=bcomp3_delay;
            obj.betaCompress4Reg(:)=bcomp4_delay;
            obj.betaValidOutReg(:)=bvalid_delay;
            obj.shiftOutReg(:)=shift_delay;
            obj.rdEnableDReg(:)=rd_delay;

        end

        function beta=calculateBeta(obj,prodsign,signs,min1,min2,min_index,dc,rdenable)

            beta=fi(zeros(obj.memDepth,1),1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');%#ok<*NASGU>
            betatemp=zeros(obj.memDepth,1);

            smux=zeros(1,obj.maxCol*obj.memDepth);
            if obj.memDepth==64
                for idx=0:63
                    smux(double((idx*obj.memDepth)+1:(idx+1)*obj.memDepth))=signs(idx+1,:);%#ok<*AGROW>
                end
            else
                for idx=0:30
                    smux(double((idx*obj.memDepth)+1:(idx+1)*obj.memDepth))=signs(idx+1,:);%#ok<*AGROW>
                end
            end

            smux=[smux,signs(1,:)];

            dc1=double(dc);
            s=smux(double((dc1*obj.memDepth)+1:(dc1+1)*obj.memDepth));

            for idx=1:obj.memDepth
                if rdenable(idx)
                    if(min_index(idx)==dc+1)
                        Mag=min2(idx);
                    else
                        Mag=min1(idx);
                    end
                    betatemp(idx)=double(prodsign(idx)*Mag*s(idx));
                else
                    betatemp(idx)=0;
                end
            end

            beta=fi(betatemp,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');
        end

        function calculateBetaCompressed(obj,data,valid,enable,rdenable)

            if obj.countTo2==0
                obj.minVal1(:)=ones(obj.memDepth,1)*obj.dataMax(1);
                obj.minVal2(:)=ones(obj.memDepth,1)*obj.dataMax(1);
                obj.minIdx(:)=ones(obj.memDepth,1);
                obj.signsAll(:)=ones(obj.maxCol,obj.memDepth);
                obj.prodSign(:)=ones(obj.memDepth,1);
                obj.prodSignBit(:)=ones(obj.memDepth,1);
            end

            if valid
                for idx=1:obj.memDepth
                    dataAbs=abs(data(idx));
                    if rdenable(idx)
                        if dataAbs<obj.minVal1(idx)
                            obj.minVal2(idx)=obj.minVal1(idx);
                            obj.minVal1(idx)=dataAbs;
                            obj.minIdx(idx)=obj.countTo2+1;
                        elseif dataAbs<obj.minVal2(idx)
                            obj.minVal2(idx)=dataAbs;
                        end
                        obj.signsAll(obj.countTo2+1,idx)=sign(data(idx))>=0;
                        signdata=sign(data(idx));
                        signdata(signdata==0)=fi(1,1,2,0);
                        obj.prodSign(idx)=obj.prodSign(idx)*signdata;
                    end
                end
                obj.prodSignBit(:)=obj.prodSign>0;
                if enable
                    for idx=1:obj.memDepth
                        if obj.memDepth==64
                            obj.betaCompress1(idx)=bitconcat(obj.signsAll(1:32,idx));
                            obj.betaCompress2(idx)=bitconcat(obj.signsAll(33:64,idx));
                        else
                            obj.betaCompress1(idx)=bitconcat(obj.signsAll(1:31,idx));
                        end
                        obj.betaCompress3(idx)=bitconcat(obj.prodSignBit(idx),obj.minIdx(idx));
                        obj.betaCompress4(idx)=bitconcat(obj.minVal1(idx),obj.minVal2(idx));
                    end
                end
            end
        end

        function addrGeneration(obj,valid_beta,count,valid_alpha)


            if count==obj.rdAddr
                reset=true;
            else
                reset=false;
            end

            if valid_beta
                obj.rdvalid(:)=true;
            else
                if count==obj.rdAddr
                    obj.rdvalid(:)=false;
                end
            end


            if reset
                obj.wrAddr(:)=0;
            else
                if valid_alpha
                    obj.wrAddr(:)=obj.wrAddr+1;
                end
            end


            if reset
                obj.rdAddr(:)=0;
            else
                if obj.rdvalid
                    obj.rdAddr(:)=obj.rdAddr+1;
                end
            end
        end

        function num=getNumInputsImpl(~)
            num=11;
        end

        function num=getNumOutputsImpl(~)
            num=9;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.alphaWL=obj.alphaWL;
                s.alphaFL=obj.alphaFL;
                s.betaWL=obj.betaWL;
                s.minWL=obj.minWL;
                s.betaCompWL=obj.betaCompWL;
                s.betaIdxWL=obj.betaIdxWL;
                s.memDepth=obj.memDepth;

                s.gammaOut=obj.gammaOut;
                s.validOut=obj.validOut;
                s.betaCompress1=obj.betaCompress1;
                s.betaCompress2=obj.betaCompress2;
                s.betaCompress3=obj.betaCompress3;
                s.betaCompress4=obj.betaCompress4;
                s.betaValidOut=obj.betaValidOut;
                s.rdEnableD=obj.rdEnableD;
                s.shiftOut=obj.shiftOut;
                s.gammaOutReg=obj.gammaOutReg;
                s.validOutReg=obj.validOutReg;
                s.betaCompress1Reg=obj.betaCompress1Reg;
                s.betaCompress2Reg=obj.betaCompress2Reg;
                s.betaCompress3Reg=obj.betaCompress3Reg;
                s.betaCompress4Reg=obj.betaCompress4Reg;
                s.betaValidOutReg=obj.betaValidOutReg;
                s.rdEnableDReg=obj.rdEnableDReg;
                s.shiftOutReg=obj.shiftOutReg;

                s.countTo1=obj.countTo1;
                s.enb=obj.enb;
                s.alpha=obj.alpha;
                s.alphaD=obj.alphaD;
                s.countTo2=obj.countTo2;
                s.countTo3=obj.countTo3;
                s.enb1=obj.enb1;
                s.enb2=obj.enb2;
                s.rdvalid=obj.rdvalid;
                s.wrAddr=obj.wrAddr;
                s.rdAddr=obj.rdAddr;
                s.betatmp=obj.betatmp;
                s.valid=obj.valid;
                s.signsBeta1=obj.signsBeta1;
                s.signsBeta2=obj.signsBeta2;
                s.minVal1=obj.minVal1;
                s.minVal2=obj.minVal2;
                s.minIdx=obj.minIdx;
                s.signsAll=obj.signsAll;
                s.prodSign=obj.prodSign;
                s.dataMax=obj.dataMax;
                s.maxCol=obj.maxCol;
                s.prodSignBit=obj.prodSignBit;
                s.rdEnable=obj.rdEnable;
                s.rdEnableD=obj.rdEnableD;
                s.rdEnableDReg=obj.rdEnableDReg;


                s.variableDelay=obj.variableDelay;
                s.variableDelayShift=obj.variableDelayShift;
                s.variableDelayEnb=obj.variableDelayEnb;

                s.delayBalancer1=obj.delayBalancer1;
                s.delayBalancer2=obj.delayBalancer2;
                s.delayBalancer3=obj.delayBalancer3;
                s.delayBalancer4=obj.delayBalancer4;
                s.delayBalancer5=obj.delayBalancer5;
                s.delayBalancer6=obj.delayBalancer6;
                s.delayBalancer7=obj.delayBalancer7;
                s.delayBalancer8=obj.delayBalancer8;
                s.delayBalancer9=obj.delayBalancer9;

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
