classdef(StrictDefaults)DVBS2LDPCFunctionalUnit<matlab.System




%#codegen

    properties(Nontunable)
        ScalingFactor=1;
        alphaWL=6;
        alphaFL=0;
        betadecmpWL=36;
    end

    properties(Nontunable,Access=private)
        minWL;
        betaWL;
        memDepth;
        countVec;
    end


    properties(Access=private)
        gammaOut;
        validOut;
        betaCompress1;
        betaCompress2;
        bcomp2;
        betaValidOut;

        countTo1;
        enb;
        alpha;
        alphaD;
        countTo2;
        countTo3;
        enb1;
        enb2;
        rdvalid;
        wrAddr;
        rdAddr;
        betatmp;
        valid;

        datax;
        dataMax;

        variableDelay;
    end

    methods


        function obj=DVBS2LDPCFunctionalUnit(varargin)
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
            obj.betaValidOut(:)=false;

            reset(obj.variableDelay);
        end

        function setupImpl(obj,varargin)

            obj.memDepth=45;
            obj.countVec=obj.betadecmpWL-6;
            obj.betaWL=obj.alphaWL-2;
            obj.minWL=obj.betaWL-1;

            obj.gammaOut=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.validOut=false;

            obj.betaCompress1=fi(zeros(obj.memDepth,1),0,obj.betadecmpWL,0);
            obj.betaCompress2=fi(zeros(obj.memDepth,1),0,2*obj.minWL,0);
            obj.bcomp2=fi(zeros(obj.memDepth,1),0,2*obj.minWL,0);
            obj.betaValidOut=false;

            obj.countTo1=fi(0,0,5,0);
            obj.enb=false;
            obj.alpha=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.countTo2=fi(0,0,5,0);
            obj.countTo3=fi(0,0,5,0);
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
            obj.datax=cast(ones(obj.memDepth,obj.countVec)*2^(WL-1)-1,'like',obj.betatmp);

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.gammaOut;
            varargout{2}=obj.validOut;
            varargout{3}=obj.betaCompress1;
            varargout{4}=obj.betaCompress2;
            varargout{5}=obj.betaValidOut;
        end

        function updateImpl(obj,varargin)

            validD=obj.valid;
            data=varargin{1};
            obj.valid=varargin{2};
            count=varargin{3};
            betacompress1=varargin{4};
            betacompress2=varargin{5};
            beta_valid=varargin{6};
            reset=varargin{7};
            ddsm=varargin{8};

            if reset
                obj.gammaOut=cast(zeros(obj.memDepth,1),'like',varargin{1});
                obj.validOut=false;
                obj.betaCompress1=fi(zeros(obj.memDepth,1),0,obj.betadecmpWL,0);
                obj.betaCompress2=fi(zeros(obj.memDepth,1),0,2*obj.minWL,0);
                obj.bcomp2=fi(zeros(obj.memDepth,1),0,2*obj.minWL,0);
                obj.betaValidOut=false;

                obj.countTo1=fi(0,0,5,0);
                obj.enb=false;
                obj.alpha=cast(zeros(obj.memDepth,1),'like',varargin{1});
                obj.countTo2=fi(0,0,5,0);
                obj.countTo3=fi(0,0,5,0);
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

                obj.datax=cast(ones(obj.memDepth,obj.countVec)*2^(WL-1)-1,'like',obj.betatmp);
            end


            sign30=-1*fi(bitsliceget(betacompress1,1,1),1,2,0);
            sign29=-1*fi(bitsliceget(betacompress1,2,2),1,2,0);
            sign28=-1*fi(bitsliceget(betacompress1,3,3),1,2,0);
            sign27=-1*fi(bitsliceget(betacompress1,4,4),1,2,0);
            sign26=-1*fi(bitsliceget(betacompress1,5,5),1,2,0);
            sign25=-1*fi(bitsliceget(betacompress1,6,6),1,2,0);
            sign24=-1*fi(bitsliceget(betacompress1,7,7),1,2,0);
            sign23=-1*fi(bitsliceget(betacompress1,8,8),1,2,0);
            sign22=-1*fi(bitsliceget(betacompress1,9,9),1,2,0);
            sign21=-1*fi(bitsliceget(betacompress1,10,10),1,2,0);
            sign20=-1*fi(bitsliceget(betacompress1,11,11),1,2,0);
            sign19=-1*fi(bitsliceget(betacompress1,12,12),1,2,0);
            sign18=-1*fi(bitsliceget(betacompress1,13,13),1,2,0);
            sign17=-1*fi(bitsliceget(betacompress1,14,14),1,2,0);
            sign16=-1*fi(bitsliceget(betacompress1,15,15),1,2,0);
            sign15=-1*fi(bitsliceget(betacompress1,16,16),1,2,0);
            sign14=-1*fi(bitsliceget(betacompress1,17,17),1,2,0);
            sign13=-1*fi(bitsliceget(betacompress1,18,18),1,2,0);
            sign12=-1*fi(bitsliceget(betacompress1,19,19),1,2,0);
            sign11=-1*fi(bitsliceget(betacompress1,20,20),1,2,0);
            sign10=-1*fi(bitsliceget(betacompress1,21,21),1,2,0);
            sign9=-1*fi(bitsliceget(betacompress1,22,22),1,2,0);
            sign8=-1*fi(bitsliceget(betacompress1,23,23),1,2,0);
            sign7=-1*fi(bitsliceget(betacompress1,24,24),1,2,0);
            sign6=-1*fi(bitsliceget(betacompress1,25,25),1,2,0);
            sign5=-1*fi(bitsliceget(betacompress1,26,26),1,2,0);
            sign4=-1*fi(bitsliceget(betacompress1,27,27),1,2,0);
            sign3=-1*fi(bitsliceget(betacompress1,28,28),1,2,0);
            sign2=-1*fi(bitsliceget(betacompress1,29,29),1,2,0);
            sign1=-1*fi(bitsliceget(betacompress1,30,30),1,2,0);

            min_index=bitsliceget(betacompress1,35,31);
            prodsign=-1*fi(bitsliceget(betacompress1,36,36),1,2,0);

            obj.bcomp2(:)=betacompress2;

            min2=bitsliceget(obj.bcomp2,obj.minWL,1);
            min1=bitsliceget(obj.bcomp2,2*(obj.minWL),obj.minWL+1);

            min2=fi(double(min2)/(2^obj.alphaFL),0,obj.minWL,obj.alphaFL);
            min1=fi(double(min1)/(2^obj.alphaFL),0,obj.minWL,obj.alphaFL);

            sign1(sign1==0)=fi(1,1,2,0);
            sign2(sign2==0)=fi(1,1,2,0);
            sign3(sign3==0)=fi(1,1,2,0);
            sign4(sign4==0)=fi(1,1,2,0);
            sign5(sign5==0)=fi(1,1,2,0);
            sign6(sign6==0)=fi(1,1,2,0);
            sign7(sign7==0)=fi(1,1,2,0);
            sign8(sign8==0)=fi(1,1,2,0);
            sign9(sign9==0)=fi(1,1,2,0);
            sign10(sign10==0)=fi(1,1,2,0);
            sign11(sign11==0)=fi(1,1,2,0);
            sign12(sign12==0)=fi(1,1,2,0);
            sign13(sign13==0)=fi(1,1,2,0);
            sign14(sign14==0)=fi(1,1,2,0);
            sign15(sign15==0)=fi(1,1,2,0);
            sign16(sign16==0)=fi(1,1,2,0);
            sign17(sign17==0)=fi(1,1,2,0);
            sign18(sign18==0)=fi(1,1,2,0);
            sign19(sign19==0)=fi(1,1,2,0);
            sign20(sign20==0)=fi(1,1,2,0);
            sign21(sign21==0)=fi(1,1,2,0);
            sign22(sign22==0)=fi(1,1,2,0);
            sign23(sign23==0)=fi(1,1,2,0);
            sign24(sign24==0)=fi(1,1,2,0);
            sign25(sign25==0)=fi(1,1,2,0);
            sign26(sign26==0)=fi(1,1,2,0);
            sign27(sign27==0)=fi(1,1,2,0);
            sign28(sign28==0)=fi(1,1,2,0);
            sign29(sign29==0)=fi(1,1,2,0);
            sign30(sign30==0)=fi(1,1,2,0);

            prodsign(prodsign==0)=fi(1,1,2,0);

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

            beta_tmp=calculateBeta(obj,prodsign,sign1,sign2,sign3,sign4,sign5,sign6,sign7,sign8,sign9,sign10,sign11,sign12,sign13,sign14,sign15,...
            sign16,sign17,sign18,sign19,sign20,sign21,sign22,sign23,sign24,sign25,sign26,sign27,sign28,sign29,sign30,min1,min2,min_index,obj.countTo1);



            obj.alphaD(:)=obj.alpha;

            if obj.enb
                beta=beta_tmp;
            else
                beta=cast(zeros(obj.memDepth,1),'like',beta_tmp);
            end

            if obj.valid
                if ddsm
                    obj.alpha(:)=data;
                else
                    obj.alpha(:)=data-beta;
                end
            end



            if validD
                if obj.countTo2==count
                    enable=true;
                else
                    enable=false;
                end
                calculateBetaCompressed(obj,obj.alphaD,enable);
                if obj.countTo2==count
                    obj.countTo2(:)=0;
                else
                    obj.countTo2(:)=obj.countTo2+1;
                end
            else
                enable=false;
            end

            obj.betaValidOut=enable;


            sign30_1=-1*fi(bitsliceget(obj.betaCompress1,1,1),1,2,0);
            sign29_1=-1*fi(bitsliceget(obj.betaCompress1,2,2),1,2,0);
            sign28_1=-1*fi(bitsliceget(obj.betaCompress1,3,3),1,2,0);
            sign27_1=-1*fi(bitsliceget(obj.betaCompress1,4,4),1,2,0);
            sign26_1=-1*fi(bitsliceget(obj.betaCompress1,5,5),1,2,0);
            sign25_1=-1*fi(bitsliceget(obj.betaCompress1,6,6),1,2,0);
            sign24_1=-1*fi(bitsliceget(obj.betaCompress1,7,7),1,2,0);
            sign23_1=-1*fi(bitsliceget(obj.betaCompress1,8,8),1,2,0);
            sign22_1=-1*fi(bitsliceget(obj.betaCompress1,9,9),1,2,0);
            sign21_1=-1*fi(bitsliceget(obj.betaCompress1,10,10),1,2,0);
            sign20_1=-1*fi(bitsliceget(obj.betaCompress1,11,11),1,2,0);
            sign19_1=-1*fi(bitsliceget(obj.betaCompress1,12,12),1,2,0);
            sign18_1=-1*fi(bitsliceget(obj.betaCompress1,13,13),1,2,0);
            sign17_1=-1*fi(bitsliceget(obj.betaCompress1,14,14),1,2,0);
            sign16_1=-1*fi(bitsliceget(obj.betaCompress1,15,15),1,2,0);
            sign15_1=-1*fi(bitsliceget(obj.betaCompress1,16,16),1,2,0);
            sign14_1=-1*fi(bitsliceget(obj.betaCompress1,17,17),1,2,0);
            sign13_1=-1*fi(bitsliceget(obj.betaCompress1,18,18),1,2,0);
            sign12_1=-1*fi(bitsliceget(obj.betaCompress1,19,19),1,2,0);
            sign11_1=-1*fi(bitsliceget(obj.betaCompress1,20,20),1,2,0);
            sign10_1=-1*fi(bitsliceget(obj.betaCompress1,21,21),1,2,0);
            sign9_1=-1*fi(bitsliceget(obj.betaCompress1,22,22),1,2,0);
            sign8_1=-1*fi(bitsliceget(obj.betaCompress1,23,23),1,2,0);
            sign7_1=-1*fi(bitsliceget(obj.betaCompress1,24,24),1,2,0);
            sign6_1=-1*fi(bitsliceget(obj.betaCompress1,25,25),1,2,0);
            sign5_1=-1*fi(bitsliceget(obj.betaCompress1,26,26),1,2,0);
            sign4_1=-1*fi(bitsliceget(obj.betaCompress1,27,27),1,2,0);
            sign3_1=-1*fi(bitsliceget(obj.betaCompress1,28,28),1,2,0);
            sign2_1=-1*fi(bitsliceget(obj.betaCompress1,29,29),1,2,0);
            sign1_1=-1*fi(bitsliceget(obj.betaCompress1,30,30),1,2,0);

            min_index_1=bitsliceget(obj.betaCompress1,35,31);
            prodsign_1=-1*fi(bitsliceget(obj.betaCompress1,36,36),1,2,0);

            min2_1=bitsliceget(obj.betaCompress2,obj.minWL,1);
            min1_1=bitsliceget(obj.betaCompress2,2*(obj.minWL),obj.minWL+1);

            min2_1=fi(double(min2_1)/(2^obj.alphaFL),0,obj.minWL,obj.alphaFL);
            min1_1=fi(double(min1_1)/(2^obj.alphaFL),0,obj.minWL,obj.alphaFL);

            sign1_1(sign1_1==0)=fi(1,1,2,0);
            sign2_1(sign2_1==0)=fi(1,1,2,0);
            sign3_1(sign3_1==0)=fi(1,1,2,0);
            sign4_1(sign4_1==0)=fi(1,1,2,0);
            sign5_1(sign5_1==0)=fi(1,1,2,0);
            sign6_1(sign6_1==0)=fi(1,1,2,0);
            sign7_1(sign7_1==0)=fi(1,1,2,0);
            sign8_1(sign8_1==0)=fi(1,1,2,0);
            sign9_1(sign9_1==0)=fi(1,1,2,0);
            sign10_1(sign10_1==0)=fi(1,1,2,0);
            sign11_1(sign11_1==0)=fi(1,1,2,0);
            sign12_1(sign12_1==0)=fi(1,1,2,0);
            sign13_1(sign13_1==0)=fi(1,1,2,0);
            sign14_1(sign14_1==0)=fi(1,1,2,0);
            sign15_1(sign15_1==0)=fi(1,1,2,0);
            sign16_1(sign16_1==0)=fi(1,1,2,0);
            sign17_1(sign17_1==0)=fi(1,1,2,0);
            sign18_1(sign18_1==0)=fi(1,1,2,0);
            sign19_1(sign19_1==0)=fi(1,1,2,0);
            sign20_1(sign20_1==0)=fi(1,1,2,0);
            sign21_1(sign21_1==0)=fi(1,1,2,0);
            sign22_1(sign22_1==0)=fi(1,1,2,0);
            sign23_1(sign23_1==0)=fi(1,1,2,0);
            sign24_1(sign24_1==0)=fi(1,1,2,0);
            sign25_1(sign25_1==0)=fi(1,1,2,0);
            sign26_1(sign26_1==0)=fi(1,1,2,0);
            sign27_1(sign27_1==0)=fi(1,1,2,0);
            sign28_1(sign28_1==0)=fi(1,1,2,0);
            sign29_1(sign29_1==0)=fi(1,1,2,0);
            sign30_1(sign30_1==0)=fi(1,1,2,0);

            prodsign_1(prodsign_1==0)=fi(1,1,2,0);
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

            beta_tmp_1=calculateBeta(obj,prodsign_1,sign1_1,sign2_1,sign3_1,sign4_1,sign5_1,sign6_1,sign7_1,sign8_1,sign9_1,sign10_1,sign11_1,sign12_1,sign13_1,sign14_1,...
            sign15_1,sign16_1,sign17_1,sign18_1,sign19_1,sign20_1,sign21_1,sign22_1,sign23_1,sign24_1,sign25_1,sign26_1,sign27_1,sign28_1,sign29_1,sign30_1,min1_1,min2_1,min_index_1,obj.countTo3);


            wraddr=obj.wrAddr;
            addrGeneration(obj,obj.betaValidOut,count,obj.valid);

            rdaddr=obj.rdAddr;
            alpha_delay=step(obj.variableDelay,obj.alpha,wraddr,obj.valid,rdaddr);


            if obj.enb1
                for idx=1:obj.memDepth
                    obj.gammaOut(idx)=cast(alpha_delay(idx)+beta_tmp_1(idx),'like',obj.gammaOut);
                end
            end
            obj.betatmp(:)=beta_tmp_1;
            obj.validOut(:)=obj.enb1;

        end

        function beta=calculateBeta(obj,prodsign,datasign1,datasign2,datasign3,datasign4,datasign5,...
            datasign6,datasign7,datasign8,datasign9,datasign10,datasign11,datasign12,datasign13,...
            datasign14,datasign15,datasign16,datasign17,datasign18,datasign19,datasign20,datasign21,datasign22,...
            datasign23,datasign24,datasign25,datasign26,datasign27,datasign28,datasign29,datasign30,min1,min2,min_index,dc)
            beta=fi(zeros(obj.memDepth,1),1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');%#ok<*NASGU>
            betatemp=zeros(obj.memDepth,1);
            smux=[datasign1,datasign2,datasign3,datasign4,datasign5,datasign6,datasign7,datasign8,datasign9,datasign10,...
            datasign11,datasign12,datasign13,datasign14,datasign15,datasign16,datasign17,datasign18,datasign19,datasign20,...
            datasign21,datasign22,datasign23,datasign24,datasign25,datasign26,datasign27,datasign28,datasign29,datasign30,datasign1];

            dc1=double(dc);
            s=smux(double((dc1*obj.memDepth)+1:(dc1+1)*obj.memDepth));

            for idx=1:obj.memDepth
                if(min_index(idx)==dc+1)
                    Mag=min2(idx);
                else
                    Mag=min1(idx);
                end
                betatemp(idx)=double(prodsign(idx)*Mag*s(idx));
            end

            if obj.ScalingFactor==1
                y=betatemp;
            elseif obj.ScalingFactor==0.5
                y=fi(betatemp/2,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');
            elseif obj.ScalingFactor==0.5625
                y=fi(betatemp/2,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap')+fi(betatemp/16,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');
            elseif obj.ScalingFactor==0.625
                y=fi(betatemp/2,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap')+fi(betatemp/8,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');
            elseif obj.ScalingFactor==0.6875
                y=fi(betatemp/2,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap')+fi(betatemp/8,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap')+...
                fi(betatemp/16,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');
            elseif obj.ScalingFactor==0.75
                y=fi(betatemp/2,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap')+fi(betatemp/4,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');
            elseif obj.ScalingFactor==0.8125
                y=fi(betatemp/2,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap')+fi(betatemp/4,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap')+...
                fi(betatemp/16,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');
            elseif obj.ScalingFactor==0.875
                y=fi(betatemp,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap')-fi(betatemp/8,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');
            elseif obj.ScalingFactor==0.9375
                y=fi(betatemp,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap')-fi(betatemp/16,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');
            else
                y=betatemp;
            end
            beta=fi(y,1,obj.betaWL,obj.alphaFL,'RoundingMethod','Floor','OverflowAction','Wrap');
        end

        function calculateBetaCompressed(obj,data,enable)

            if obj.countTo2==0
                obj.datax(:,1)=data;
                for idx=2:obj.countVec
                    obj.datax(:,idx)=obj.dataMax;
                end
            else
                obj.datax(:,obj.countTo2+1)=data;
            end

            for idx=1:obj.memDepth
                dataval=[obj.datax(idx,1);obj.datax(idx,2);obj.datax(idx,3);obj.datax(idx,4);obj.datax(idx,5);obj.datax(idx,6);obj.datax(idx,7);...
                obj.datax(idx,8);obj.datax(idx,9);obj.datax(idx,10);obj.datax(idx,11);obj.datax(idx,12);obj.datax(idx,13);obj.datax(idx,14);...
                obj.datax(idx,15);obj.datax(idx,16);obj.datax(idx,17);obj.datax(idx,18);obj.datax(idx,19);obj.datax(idx,20);obj.datax(idx,21);...
                obj.datax(idx,22);obj.datax(idx,23);obj.datax(idx,24);obj.datax(idx,25);obj.datax(idx,26);obj.datax(idx,27);obj.datax(idx,28);...
                obj.datax(idx,29);obj.datax(idx,30)];

                [min,minidx]=sort(abs((dataval)));

                min1=fi(min(1),0,obj.minWL,obj.alphaFL);
                min2=fi(min(2),0,obj.minWL,obj.alphaFL);
                minindex=fi(minidx(1),0,5,0);
                signdata=sign(dataval);
                signdata(signdata==0)=fi(1,1,2,0);

                signs=bitconcat(fi(signdata>0,0,1,0));
                prodsign=fi(prod(signdata),0,1,0);

                betacomp1=bitconcat(prodsign,minindex,signs);
                betacomp2=bitconcat(min1,min2);

                if enable
                    obj.betaCompress1(idx)=bitconcat(prodsign,minindex,signs);
                    obj.betaCompress2(idx)=bitconcat(min1,min2);
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
            num=8;
        end

        function num=getNumOutputsImpl(~)
            num=5;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.gammaOut=obj.gammaOut;
                s.validOut=obj.validOut;
                s.betaCompress1=obj.betaCompress1;
                s.betaCompress2=obj.betaCompress2;
                s.bcomp2=obj.bcomp2;
                s.betaValidOut=obj.betaValidOut;

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
                s.minWL=obj.minWL;
                s.betaWL=obj.betaWL;
                s.memDepth=obj.memDepth;
                s.countVec=obj.countVec;

                s.datax=obj.datax;
                s.dataMax=obj.dataMax;

                s.variableDelay=obj.variableDelay;
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
