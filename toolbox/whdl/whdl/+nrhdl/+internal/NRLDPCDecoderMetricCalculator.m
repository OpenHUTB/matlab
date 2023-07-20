classdef(StrictDefaults)NRLDPCDecoderMetricCalculator<matlab.System




%#codegen

    properties(Nontunable)
        ScalingFactor=0.75;
        alphaWL=12;
        alphaFL=4;
        betaWL=8;
        minWL=8;
        betadecmpWL=16;
        memDepth=384;
        vectorSize=64;
    end


    properties(Access=private)


        cyclicShifterRead;
        betaMemory;
        functionalUnit;

        betaDecompDelayBalancer1;
        betaDecompDelayBalancer2;
        betaDecompDelayBalancer3;

        delayBalancer1;
        delayBalancer2;

        betaDecomp1;
        betaDecomp2;
        betaValid;

        validIn;
        resetD;
        rdEnb;
        wrData1;
        wrData2;
        wrData3;
        wrData4;
        wrData5;
        wrData6;
        wrEnb1;
        wrEnb2;
        wrEnb3;
        wrEnb4;
        wrEnb5;
        wrEnb6;
        wrAddr;
        selBank;
        validOutReg;
        rdAddr;
        rdCount;
        funcEnb;
        validTmp;

        PFMemory1;
        PFMemory2;
        PFMemory3;
        PFMemory4;
        PFMemory5;
        PFMemory6;

        betaOut1;
        betaOut2;
        betaValidD;
        funcEnbD;
        enableOut;
        betaEnb;
        betaEnbD;
        shiftData;
        shiftValid;
        funcrdEnb;
        validTrig;


        dataOut;
        validOut;

    end

    methods


        function obj=NRLDPCDecoderMetricCalculator(varargin)
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

            reset(obj.cyclicShifterRead);
            reset(obj.betaMemory);
            reset(obj.functionalUnit);

            reset(obj.betaDecompDelayBalancer1);
            reset(obj.betaDecompDelayBalancer2);
            reset(obj.betaDecompDelayBalancer3);
            reset(obj.delayBalancer1);
            reset(obj.delayBalancer2);

            obj.dataOut(:)=zeros(obj.memDepth,1);
            obj.validOut=false;

            obj.betaDecomp1=fi(zeros(obj.memDepth,1),0,25,0);
            obj.betaDecomp2=fi(zeros(obj.memDepth,1),0,obj.betadecmpWL,0);

            obj.betaOut1=cast(zeros(384,1),'like',obj.betaDecomp1);
            obj.betaOut2=cast(zeros(384,1),'like',obj.betaDecomp2);

            reset(obj.PFMemory1);
            reset(obj.PFMemory2);
            reset(obj.PFMemory3);
            reset(obj.PFMemory4);
            reset(obj.PFMemory5);
            reset(obj.PFMemory6);
        end

        function setupImpl(obj,varargin)



            obj.cyclicShifterRead=nrhdl.internal.NRLDPCDecoderCyclicShifter('memDepth',384,'vectorSize',obj.vectorSize);

            obj.betaMemory=nrhdl.internal.NRLDPCDecoderBetaMemory('memDepth',384);

            obj.functionalUnit=nrhdl.internal.NRLDPCDecoderFunctionalUnit(...
            'ScalingFactor',obj.ScalingFactor,'alphaWL',obj.alphaWL,'alphaFL',obj.alphaFL,...
            'betaWL',obj.betaWL,'minWL',obj.minWL,'betadecmpWL',obj.betadecmpWL,'memDepth',obj.memDepth);

            obj.betaDecompDelayBalancer1=dsp.Delay(obj.memDepth);
            obj.betaDecompDelayBalancer2=dsp.Delay(obj.memDepth);
            obj.betaDecompDelayBalancer3=dsp.Delay(1);

            if obj.vectorSize==64
                obj.delayBalancer1=dsp.Delay(obj.memDepth*4);
                obj.delayBalancer2=dsp.Delay(4);
            else
                obj.delayBalancer1=dsp.Delay(obj.memDepth*3);
                obj.delayBalancer2=dsp.Delay(3);
            end

            obj.betaDecomp1=fi(zeros(obj.memDepth,1),0,25,0);
            obj.betaDecomp2=fi(zeros(obj.memDepth,1),0,obj.betadecmpWL,0);
            obj.betaValid=false;

            obj.validIn=false;
            obj.resetD=false;
            obj.rdEnb=false;

            obj.dataOut=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.validOut=false;

            obj.wrData1=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.wrData2=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.wrData3=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.wrData4=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.wrData5=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.wrData6=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.wrEnb1=zeros(obj.memDepth,1)>0;
            obj.wrEnb2=zeros(obj.memDepth,1)>0;
            obj.wrEnb3=zeros(obj.memDepth,1)>0;
            obj.wrEnb4=zeros(obj.memDepth,1)>0;
            obj.wrEnb5=zeros(obj.memDepth,1)>0;
            obj.wrEnb6=zeros(obj.memDepth,1)>0;
            obj.wrAddr=fi(1,0,5,0,hdlfimath);
            obj.selBank=fi(1,0,3,0);
            obj.validOutReg=false;
            obj.rdAddr=fi(1,0,5,0,hdlfimath);
            obj.rdCount=fi(0,0,3,0,hdlfimath);
            obj.funcEnb=false;
            obj.validTmp=false;

            obj.PFMemory1=hdl.RAM('RAMType','Simple dual port');
            obj.PFMemory2=hdl.RAM('RAMType','Simple dual port');
            obj.PFMemory3=hdl.RAM('RAMType','Simple dual port');
            obj.PFMemory4=hdl.RAM('RAMType','Simple dual port');
            obj.PFMemory5=hdl.RAM('RAMType','Simple dual port');
            obj.PFMemory6=hdl.RAM('RAMType','Simple dual port');

            obj.betaOut1=cast(zeros(384,1),'like',obj.betaDecomp1);
            obj.betaOut2=cast(zeros(384,1),'like',obj.betaDecomp2);
            obj.betaValidD=false;
            obj.funcEnbD=false;
            obj.funcrdEnb=false;
            obj.enableOut=false;
            obj.betaEnb=false;
            obj.betaEnbD=false;

            obj.shiftData=cast(zeros(384,1),'like',varargin{1});
            obj.shiftValid=false;
            obj.validTrig=false;

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
        end

        function updateImpl(obj,varargin)

            data=varargin{1};
            liftsize=varargin{2};
            V=varargin{3};

            valid=obj.validIn;
            obj.validIn=varargin{4};
            layeridx=varargin{5};

            rdenb=obj.rdEnb;
            obj.rdEnb=varargin{6};
            count=varargin{7};

            reset=obj.resetD;
            obj.resetD=varargin{8};
            funcenb=varargin{9};
            iterdone=varargin{10};


            [shiftdata,shiftvalid]=obj.cyclicShifterRead(data,liftsize,V,obj.validIn,count,iterdone);
            if obj.vectorSize==64

                betain1=obj.betaDecomp1;
                betain2=obj.betaDecomp2;
                wrenb=obj.betaValid;

                betaenb=((~valid)&&obj.validIn)&&rdenb;

                [cnudecomp1,cnudecomp2,cnuvalid]=obj.betaMemory(betain1,betain2,...
                layeridx,betaenb,wrenb);


                [gamma,validout,betadecomp1,betadecomp2,betavalid]=...
                obj.functionalUnit(shiftdata,shiftvalid,...
                count,cnudecomp1,cnudecomp2,cnuvalid,reset);

                obj.betaDecomp1=obj.betaDecompDelayBalancer1(betadecomp1);
                obj.betaDecomp2=obj.betaDecompDelayBalancer2(betadecomp2);
                obj.betaValid=obj.betaDecompDelayBalancer3(betavalid);

                obj.dataOut=obj.delayBalancer1(gamma);
                obj.validOut=obj.delayBalancer2(validout);
            else



                [data1,rdaddr,wren1,data2,wraddr,wren2,data3,wren3,data4,wren4,data5,wren5,data6,wren6,...
                selbank,validfunc,countout,validtrig]=functionalInputController(obj,obj.shiftData,obj.shiftValid,liftsize,count,reset,funcenb);

                obj.shiftData(:)=shiftdata;
                obj.shiftValid(:)=shiftvalid;

                wraddrD=cast(ones(obj.memDepth,1)*wraddr,'like',wraddr);
                rdaddrD=cast(ones(obj.memDepth,1)*rdaddr,'like',rdaddr);

                coldata1=obj.PFMemory1(data1,wraddrD,wren1,rdaddrD);

                coldata2=obj.PFMemory2(data2,wraddrD,wren2,rdaddrD);

                coldata3=obj.PFMemory3(data3,wraddrD,wren3,rdaddrD);

                coldata4=obj.PFMemory4(data4,wraddrD,wren4,rdaddrD);

                coldata5=obj.PFMemory5(data5,wraddrD,wren5,rdaddrD);

                coldata6=obj.PFMemory6(data6,wraddrD,wren6,rdaddrD);

                if selbank==fi(1,0,3,0)
                    datafunc=coldata1;
                elseif selbank==fi(2,0,3,0)
                    datafunc=coldata2;
                elseif selbank==fi(3,0,3,0)
                    datafunc=coldata3;
                elseif selbank==fi(4,0,3,0)
                    datafunc=coldata4;
                elseif selbank==fi(5,0,3,0)
                    datafunc=coldata5;
                elseif selbank==fi(6,0,3,0)
                    datafunc=coldata6;
                else
                    datafunc=coldata1;
                end

                betain1=obj.betaDecomp1;
                betain2=obj.betaDecomp2;
                wrenb=obj.betaValid;

                betaenb=((validtrig)&&(~obj.validTrig))&&obj.rdEnb;
                obj.validTrig=validtrig;

                [betain1D,betain2D,betavalidD]=betaMemoryInputController(obj,betain1,betain2,wrenb,selbank);


                [cnudecomp1,cnudecomp2,cnuvalid]=obj.betaMemory(betain1D,betain2D,...
                layeridx,betaenb,betavalidD);


                [betaout1_1,betaout1_2,betaout1_3,betaout1_4,betaout1_5,betaout1_6,betaout2_1,...
                betaout2_2,betaout2_3,betaout2_4,betaout2_5,betaout2_6]=betaMemoryOutputController(obj,cnudecomp1,cnudecomp2);


                if selbank==fi(1,0,3,0)
                    cnudecomp1D=betaout1_1;
                    cnudecomp2D=betaout2_1;
                elseif selbank==fi(2,0,3,0)
                    cnudecomp1D=betaout1_2;
                    cnudecomp2D=betaout2_2;
                elseif selbank==fi(3,0,3,0)
                    cnudecomp1D=betaout1_3;
                    cnudecomp2D=betaout2_3;
                elseif selbank==fi(4,0,3,0)
                    cnudecomp1D=betaout1_4;
                    cnudecomp2D=betaout2_4;
                elseif selbank==fi(5,0,3,0)
                    cnudecomp1D=betaout1_5;
                    cnudecomp2D=betaout2_5;
                elseif selbank==fi(6,0,3,0)
                    cnudecomp1D=betaout1_6;
                    cnudecomp2D=betaout2_6;
                else
                    cnudecomp1D=betaout1_1;
                    cnudecomp2D=betaout2_1;
                end

                if reset
                    obj.enableOut(:)=false;
                else
                    if betaenb
                        obj.enableOut(:)=true;
                    end
                end

                cnuvalidD=cnuvalid||obj.funcEnbD&&(obj.enableOut);
                obj.funcEnbD(:)=funcenb;


                [gamma,validout,betadecomp1,betadecomp2,betavalid]=...
                obj.functionalUnit(datafunc,validfunc,countout,cnudecomp1D,...
                cnudecomp2D,cnuvalidD,reset);

                obj.betaDecomp1=obj.betaDecompDelayBalancer1(betadecomp1);
                obj.betaDecomp2=obj.betaDecompDelayBalancer2(betadecomp2);
                obj.betaValid=obj.betaDecompDelayBalancer3(betavalid);

                obj.dataOut=obj.delayBalancer1(gamma);
                obj.validOut=obj.delayBalancer2(validout);

            end

        end

        function[data1,rdaddr,wren1,data2,wraddr,wren2,data3,wren3,data4,wren4,data5,wren5,data6,wren6,...
            selbank,validout,countout,validtrig]=functionalInputController(obj,shiftdata,valid,liftsize,count,reset,valid_delay)

            validout=obj.validOutReg;
            validtrig=obj.funcrdEnb;

            wraddr=obj.wrAddr;
            rdaddr=obj.rdAddr;

            selbank=obj.selBank;
            countout=count;

            ztemp=bitsliceget(cast(liftsize-fi(1,0,9,0),'like',liftsize),9,7);
            zcount=cast(ztemp+fi(1,0,1,0),'like',obj.rdCount);

            if reset
                obj.funcEnb(:)=false;
            elseif valid_delay&&(zcount>fi(1,0,3,0,hdlfimath))
                obj.funcEnb(:)=true;
                obj.selBank(:)=obj.selBank(:)+1;
            end

            if reset
                obj.wrData1=cast(zeros(64,1),'like',shiftdata);
                obj.wrData2=cast(zeros(64,1),'like',shiftdata);
                obj.wrData3=cast(zeros(64,1),'like',shiftdata);
                obj.wrData4=cast(zeros(64,1),'like',shiftdata);
                obj.wrData5=cast(zeros(64,1),'like',shiftdata);
                obj.wrData6=cast(zeros(64,1),'like',shiftdata);
                obj.wrEnb1=zeros(64,1)>0;
                obj.wrEnb2=zeros(64,1)>0;
                obj.wrEnb3=zeros(64,1)>0;
                obj.wrEnb4=zeros(64,1)>0;
                obj.wrEnb5=zeros(64,1)>0;
                obj.wrEnb6=zeros(64,1)>0;
                obj.wrAddr=fi(1,0,5,0,hdlfimath);
                obj.selBank=fi(0,0,3,0);
                obj.validOutReg=false;
                obj.validTmp(:)=false;
                obj.rdAddr=fi(1,0,5,0,hdlfimath);
                valido=false;
                obj.funcrdEnb(:)=false;
            else
                obj.wrData1(:)=shiftdata(1:64);
                obj.wrData2(:)=shiftdata(65:128);
                obj.wrData3(:)=shiftdata(129:192);
                obj.wrData4(:)=shiftdata(193:256);
                obj.wrData5(:)=shiftdata(257:320);
                obj.wrData6(:)=shiftdata(321:384);

                if valid
                    obj.wrEnb1=ones(64,1)>0;
                    obj.validTmp(:)=false;
                    if zcount==fi(6,0,3,0,hdlfimath)
                        obj.wrEnb2(:)=ones(64,1)>0;
                        obj.wrEnb3(:)=ones(64,1)>0;
                        obj.wrEnb4(:)=ones(64,1)>0;
                        obj.wrEnb5(:)=ones(64,1)>0;
                        obj.wrEnb6(:)=ones(64,1)>0;
                    elseif zcount==fi(5,0,3,0,hdlfimath)
                        obj.wrEnb2(:)=ones(64,1)>0;
                        obj.wrEnb3(:)=ones(64,1)>0;
                        obj.wrEnb4(:)=ones(64,1)>0;
                        obj.wrEnb5(:)=ones(64,1)>0;
                        obj.wrEnb6(:)=zeros(64,1)>0;
                    elseif zcount==fi(4,0,3,0,hdlfimath)
                        obj.wrEnb2(:)=ones(64,1)>0;
                        obj.wrEnb3(:)=ones(64,1)>0;
                        obj.wrEnb4(:)=ones(64,1)>0;
                        obj.wrEnb5(:)=zeros(64,1)>0;
                        obj.wrEnb6(:)=zeros(64,1)>0;
                    elseif zcount==fi(3,0,3,0,hdlfimath)
                        obj.wrEnb2(:)=ones(64,1)>0;
                        obj.wrEnb3(:)=ones(64,1)>0;
                        obj.wrEnb4(:)=zeros(64,1)>0;
                        obj.wrEnb5(:)=zeros(64,1)>0;
                        obj.wrEnb6(:)=zeros(64,1)>0;
                    elseif zcount==fi(2,0,3,0,hdlfimath)
                        obj.wrEnb2(:)=ones(64,1)>0;
                        obj.wrEnb3(:)=zeros(64,1)>0;
                        obj.wrEnb4(:)=zeros(64,1)>0;
                        obj.wrEnb5(:)=zeros(64,1)>0;
                        obj.wrEnb6(:)=zeros(64,1)>0;
                    elseif zcount==fi(1,0,3,0,hdlfimath)
                        obj.wrEnb2(:)=zeros(64,1)>0;
                        obj.wrEnb3(:)=zeros(64,1)>0;
                        obj.wrEnb4(:)=zeros(64,1)>0;
                        obj.wrEnb5(:)=zeros(64,1)>0;
                        obj.wrEnb6(:)=zeros(64,1)>0;
                    else
                        obj.wrEnb2(:)=zeros(64,1)>0;
                        obj.wrEnb3(:)=zeros(64,1)>0;
                        obj.wrEnb4(:)=zeros(64,1)>0;
                        obj.wrEnb5(:)=zeros(64,1)>0;
                        obj.wrEnb6(:)=zeros(64,1)>0;
                    end
                    valido=false;
                    if obj.wrAddr==fi(count+1,0,5,0,hdlfimath)
                        obj.wrAddr(:)=1;
                        obj.funcrdEnb(:)=true;
                    else
                        obj.wrAddr(:)=obj.wrAddr+1;
                        obj.selBank(:)=fi(1,0,3,0);
                    end
                else
                    obj.wrEnb1=zeros(obj.memDepth,1)>0;
                    obj.wrEnb2=zeros(obj.memDepth,1)>0;
                    obj.wrEnb3=zeros(obj.memDepth,1)>0;
                    obj.wrEnb4=zeros(obj.memDepth,1)>0;
                    obj.wrEnb5=zeros(obj.memDepth,1)>0;
                    obj.wrEnb6=zeros(obj.memDepth,1)>0;
                    if obj.funcEnb||obj.funcrdEnb
                        if obj.rdAddr==fi(count+1,0,5,0,hdlfimath)
                            obj.rdAddr(:)=1;
                            valido=false;
                            obj.funcEnb(:)=false;
                            obj.funcrdEnb(:)=false;
                        else
                            obj.rdAddr(:)=obj.rdAddr+1;
                            valido=true;
                        end
                    else
                        valido=false;
                    end
                    obj.validOutReg(:)=valido||obj.validTmp;
                    obj.validTmp(:)=valido;
                end
            end
            data1=obj.wrData1;
            data2=obj.wrData2;
            data3=obj.wrData3;
            data4=obj.wrData4;
            data5=obj.wrData5;
            data6=obj.wrData6;
            wren1=obj.wrEnb1;
            wren2=obj.wrEnb2;
            wren3=obj.wrEnb3;
            wren4=obj.wrEnb4;
            wren5=obj.wrEnb5;
            wren6=obj.wrEnb6;
        end

        function[betain1D,betain2D,betavalidD]=betaMemoryInputController(obj,betain1,betain2,wrenb,selcount)

            betain1D=obj.betaOut1;
            betain2D=obj.betaOut2;
            betavalidD=obj.betaValidD;
            if selcount==fi(1,0,3,0)
                obj.betaOut1(:)=[betain1;zeros(320,1)];
                obj.betaOut2(:)=[betain2;zeros(320,1)];
            elseif selcount==fi(2,0,3,0)
                obj.betaOut1(:)=[obj.betaOut1(1:64);betain1;zeros(256,1)];
                obj.betaOut2(:)=[obj.betaOut2(1:64);betain2;zeros(256,1)];
            elseif selcount==fi(3,0,3,0)
                obj.betaOut1(:)=[obj.betaOut1(1:128);betain1;zeros(192,1)];
                obj.betaOut2(:)=[obj.betaOut2(1:128);betain2;zeros(192,1)];
            elseif selcount==fi(4,0,3,0)
                obj.betaOut1(:)=[obj.betaOut1(1:192);betain1;zeros(128,1)];
                obj.betaOut2(:)=[obj.betaOut2(1:192);betain2;zeros(128,1)];
            elseif selcount==fi(5,0,3,0)
                obj.betaOut1(:)=[obj.betaOut1(1:256);betain1;zeros(64,1)];
                obj.betaOut2(:)=[obj.betaOut2(1:256);betain2;zeros(64,1)];
            elseif selcount==fi(6,0,3,0)
                obj.betaOut1(:)=[obj.betaOut1(1:320);betain1;];
                obj.betaOut2(:)=[obj.betaOut2(1:320);betain2;];
            else
                obj.betaOut1(:)=zeros(384,1);
                obj.betaOut2(:)=zeros(384,1);
            end

            obj.betaValidD(:)=wrenb;
        end

        function[betaout1_1,betaout1_2,betaout1_3,betaout1_4,betaout1_5,betaout1_6,...
            betaout2_1,betaout2_2,betaout2_3,betaout2_4,betaout2_5,betaout2_6]=betaMemoryOutputController(~,betain1,betain2)

            betaout1_1=betain1(1:64);
            betaout1_2=betain1(65:128);
            betaout1_3=betain1(129:192);
            betaout1_4=betain1(193:256);
            betaout1_5=betain1(257:320);
            betaout1_6=betain1(321:384);

            betaout2_1=betain2(1:64);
            betaout2_2=betain2(65:128);
            betaout2_3=betain2(129:192);
            betaout2_4=betain2(193:256);
            betaout2_5=betain2(257:320);
            betaout2_6=betain2(321:384);
        end

        function num=getNumInputsImpl(~)
            num=10;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end




        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked

                s.cyclicShifterRead=obj.cyclicShifterRead;
                s.betaMemory=obj.betaMemory;
                s.functionalUnit=obj.functionalUnit;

                s.betaDecompDelayBalancer1=obj.betaDecompDelayBalancer1;
                s.betaDecompDelayBalancer2=obj.betaDecompDelayBalancer2;
                s.betaDecompDelayBalancer3=obj.betaDecompDelayBalancer3;
                s.delayBalancer1=obj.delayBalancer1;
                s.delayBalancer2=obj.delayBalancer2;

                s.betaDecomp1=obj.betaDecomp1;
                s.betaDecomp2=obj.betaDecomp2;
                s.betaValid=obj.betaValid;
                s.validIn=obj.validIn;
                s.resetD=obj.resetD;
                s.rdEnb=obj.rdEnb;
                s.wrData1=obj.wrData1;
                s.wrData2=obj.wrData2;
                s.wrData3=obj.wrData3;
                s.wrData4=obj.wrData4;
                s.wrData5=obj.wrData5;
                s.wrData6=obj.wrData6;
                s.wrEnb1=obj.wrEnb1;
                s.wrEnb2=obj.wrEnb2;
                s.wrEnb3=obj.wrEnb3;
                s.wrEnb4=obj.wrEnb4;
                s.wrEnb5=obj.wrEnb5;
                s.wrEnb6=obj.wrEnb6;
                s.wrAddr=obj.wrAddr;
                s.selBank=obj.selBank;
                s.validOutReg=obj.validOutReg;
                s.rdAddr=obj.rdAddr;
                s.rdCount=obj.rdCount;
                s.funcEnb=obj.funcEnb;
                s.validTmp=obj.validTmp;

                s.PFMemory1=obj.PFMemory1;
                s.PFMemory2=obj.PFMemory2;
                s.PFMemory3=obj.PFMemory3;
                s.PFMemory4=obj.PFMemory4;
                s.PFMemory5=obj.PFMemory5;
                s.PFMemory6=obj.PFMemory6;

                s.betaOut1=obj.betaOut1;
                s.betaOut2=obj.betaOut2;
                s.betaValidD=obj.betaValidD;
                s.funcEnbD=obj.funcEnbD;
                s.funcrdEnb=obj.funcrdEnb;
                s.enableOut=obj.enableOut;
                s.betaEnb=obj.betaEnb;
                s.betaEnbD=obj.betaEnbD;
                s.shiftData=obj.shiftData;
                s.shiftValid=obj.shiftValid;
                s.validTrig=obj.validTrig;


                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;


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
