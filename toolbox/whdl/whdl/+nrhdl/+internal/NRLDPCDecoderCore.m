classdef(StrictDefaults)NRLDPCDecoderCore<matlab.System





%#codegen

    properties(Nontunable)
        SpecifyInputs='Property';
        NumIterations=8;
        ScalingFactor=0.75;
        alphaWL=12;
        alphaFL=4;
        betaWL=8;
        minWL=8;
        betadecmpWL=16;
        memDepth=384;
        vectorSize=64;
        Termination='Max';
        MaxNumIterations=8;

        RateCompatible(1,1)logical=false;
        ParityCheckStatus(1,1)logical=false;
    end


    properties(Access=private)


        dataMemory;
        checkMatrixLUT;
        metricCalculator;
        finalDecision;


        gamma;
        validMC;
        iterDone;
        resetD;
        endInd;
        numIter;
        finalShifts;
        countLayer;
        iterCount;
        betaRead;
        iterInd;
        wrData;
        wrEnb;
        wrAddr;
        rdAddr;
        rdAddr1;
        rdAddrFinal;
        rdValid;
        enb;
        zCount;
        wrCount;
        validDelay;
        rdenb;
        finalEnb;
        layerDone;
        resetDelay;
        resetDelay1;
        rdCount;
        validCount;
        validC;
        zCount1;
        rdFinEnb;
        outZCount;
        outWrData;
        LUTData;
        outAddr;
        FData;
        colCount;
        rdEnb;
        wrLUTAddr;
        rdLUTAddr;
        rdLUTAddr1;
        initCount;
        rdZCount;
        rdValidReg;
        funcEnb;
        noOp;


        fPChecks;
        fPChecksD;
        earColCount;
        earLayCount;
        earEnb;
        earEnbDelay;
        checkFailed;
        earEnbLayer;
        earEnbLayerD;
        termPass;
        termPassReg;
        termPassD;
        termPassD1;
        termPassD2;
        earPFCount;


        dataOut;
        decBits;
        ctrlOut;
        iterOut;
        parCheck;

        dataOutReg;
        ctrlOutReg;
        iterOutReg;
        dataOutReg1;
        ctrlOutReg1;
        iterOutReg1;

        delayBalancer1;
        delayBalancer2;
        delayBalancer3;
        delayBalancer4;
        delayBalancer5;
        delayBalancer6;

    end

    properties(Constant,Hidden)
        SpecifyInputsSet=matlab.system.StringSet({'Input port','Property'});
    end

    methods


        function obj=NRLDPCDecoderCore(varargin)
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


            reset(obj.dataMemory);
            reset(obj.checkMatrixLUT);
            reset(obj.metricCalculator);
            reset(obj.finalDecision);

            reset(obj.delayBalancer1);
            reset(obj.delayBalancer2);
            reset(obj.delayBalancer3);
            reset(obj.delayBalancer4);
            reset(obj.delayBalancer5);
            reset(obj.delayBalancer6);

            obj.dataOut(:)=zeros(obj.vectorSize,1);
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.iterOut=uint8(0);

            obj.dataOutReg(:)=zeros(obj.vectorSize,1);
            obj.ctrlOutReg=struct('start',false,'end',false,'valid',false);
            obj.iterOutReg=uint8(0);
            obj.parCheck(:)=false;
            obj.termPassD1(:)=false;
            obj.termPassD2(:)=false;

            obj.dataOutReg1(:)=zeros(obj.vectorSize,1);
            obj.ctrlOutReg1=struct('start',false,'end',false,'valid',false);
            obj.iterOutReg1=uint8(0);
        end

        function setupImpl(obj,varargin)



            obj.dataMemory=hdl.RAM('RAMType','Simple dual port');


            obj.checkMatrixLUT=nrhdl.internal.NRLDPCDecoderCheckMatrixLUT('RateCompatible',obj.RateCompatible);


            obj.metricCalculator=nrhdl.internal.NRLDPCDecoderMetricCalculator(...
            'ScalingFactor',obj.ScalingFactor,'alphaWL',obj.alphaWL,...
            'alphaFL',obj.alphaFL,'betaWL',obj.betaWL,'minWL',obj.minWL,...
            'betadecmpWL',obj.betadecmpWL,'memDepth',obj.memDepth,'vectorSize',obj.vectorSize);


            obj.finalDecision=nrhdl.internal.NRLDPCDecoderFinalDecision('memDepth',384,'vectorSize',obj.vectorSize);


            obj.gamma=cast(zeros(obj.memDepth,1),'like',varargin{1});

            obj.finalShifts=fi(zeros(1,1),0,9,0);

            obj.validMC=false;
            obj.iterDone=false;
            obj.resetD=false;
            obj.endInd=false;
            obj.numIter=uint8(8);

            obj.countLayer=fi(1,0,6,0);
            obj.iterCount=fi(0,0,6,0);
            obj.betaRead=false;
            obj.iterInd=false;
            obj.wrData=cast(zeros(384,1),'like',obj.gamma);
            obj.wrEnb=(zeros(384,1))>0;
            obj.wrAddr=uint8(3);
            obj.rdAddr=uint8(0);
            obj.rdAddr1=uint8(0);
            obj.rdAddrFinal=uint8(1);
            obj.rdValid=false;
            obj.enb=false;
            obj.zCount=fi(0,0,9,0,hdlfimath);
            obj.wrCount=fi(1,0,9,0,hdlfimath);
            obj.validDelay=false;
            obj.rdenb=false;
            obj.finalEnb=false;
            obj.layerDone=false;
            obj.resetDelay=false;
            obj.resetDelay1=false;
            obj.rdCount=fi(1,0,9,0,hdlfimath);
            obj.validCount=fi(1,0,5,0,hdlfimath);
            obj.validC=fi(1,0,5,0,hdlfimath);
            obj.zCount1=fi(1,0,3,0,hdlfimath);
            obj.rdFinEnb=false;
            obj.outZCount=fi(1,0,9,0,hdlfimath);
            obj.outWrData=zeros(obj.vectorSize,1)>0;
            obj.LUTData=zeros(64,1)>0;
            obj.outAddr=fi(1,0,6,0);
            obj.noOp=false;
            obj.colCount=fi(1,0,9,0);
            obj.rdEnb=false;
            obj.wrLUTAddr=fi(0,0,10,0,hdlfimath);
            obj.rdLUTAddr=fi(0,0,10,0,hdlfimath);
            obj.rdLUTAddr1=fi(0,0,10,0,hdlfimath);
            obj.initCount=fi(1,0,9,0);
            obj.rdZCount=fi(1,0,3,0,hdlfimath);
            obj.rdValidReg=false;
            obj.funcEnb=false;


            if obj.vectorSize==64
                vAddr=384;
            else
                vAddr=64;
            end
            obj.fPChecks=zeros(vAddr,1)>0;
            obj.fPChecksD=zeros(vAddr,1)>0;

            obj.earColCount=fi(0,0,5,0,hdlfimath);
            obj.earLayCount=fi(0,0,6,0,hdlfimath);
            obj.earEnb=false;
            obj.earEnbDelay=false;
            obj.checkFailed=false;
            obj.earEnbLayer=false;
            obj.earEnbLayerD=false;
            obj.termPass=false;
            obj.termPassReg=false;
            obj.termPassD=false;
            obj.earPFCount=fi(1,0,3,0,hdlfimath);


            obj.dataOut=zeros(obj.vectorSize,1)>0;
            obj.decBits=zeros(384,1)>0;
            obj.FData=zeros(384,1)>0;
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.iterOut=uint8(0);
            obj.parCheck=false;
            obj.termPassD1=false;
            obj.termPassD2=false;

            obj.dataOutReg=zeros(obj.vectorSize,1)>0;
            obj.ctrlOutReg=struct('start',false,'end',false,'valid',false);
            obj.iterOutReg=uint8(0);
            obj.dataOutReg1=zeros(obj.vectorSize,1)>0;
            obj.ctrlOutReg1=struct('start',false,'end',false,'valid',false);
            obj.iterOutReg1=uint8(0);


            obj.delayBalancer1=dsp.Delay(obj.vectorSize*8);
            obj.delayBalancer2=dsp.Delay(8);
            obj.delayBalancer3=dsp.Delay(8);
            obj.delayBalancer4=dsp.Delay(8);
            obj.delayBalancer5=dsp.Delay(8);
            obj.delayBalancer6=dsp.Delay(8);

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.ctrlOut;
            if strcmpi(obj.Termination,'Early')
                varargout{3}=obj.iterOut;
                varargout{4}=obj.parCheck;
            else
                varargout{3}=obj.parCheck;
            end
        end

        function updateImpl(obj,varargin)

            reset=obj.resetD;

            data=varargin{1};
            valid=varargin{2};
            frame_valid=varargin{3};
            obj.resetD=varargin{4};
            bgn=varargin{5};
            setindex=varargin{6};
            liftsize=varargin{7};
            endind=varargin{8};

            if obj.resetD
                obj.decBits(:)=zeros(384,1);
                obj.FData(:)=zeros(384,1);
            end

            if(strcmpi(obj.SpecifyInputs,'Property'))
                zaddr=varargin{9};
                numrows=varargin{10};
            else
                niter=varargin{9};
                zaddr=varargin{10};
                numrows=varargin{11};
            end

            data_mc=obj.gamma;
            valid_mc=obj.validMC;

            if strcmpi(obj.Termination,'Early')
                termpass=obj.termPassD;
                numIterations=obj.MaxNumIterations;
            else
                termpass=false;
                numIterations=obj.NumIterations;
            end

            if liftsize>fi(384,0,9,0)
                liftsize=fi(384,0,9,0);
            else
                liftsize=liftsize;
            end

            if(strcmpi(obj.SpecifyInputs,'Property'))

                if obj.vectorSize==64
                    [wr_data,wr_addr,wr_en,rd_addr,rd_valid,iterdone,iterind,...
                    betaread,countidx,layeridx,validcount,softreset,iterout]=iterationControllerVector(obj,data,valid,frame_valid,...
                    obj.resetD,data_mc,valid_mc,bgn,liftsize,endind,numIterations,numrows,termpass);
                    funcenb=false;
                else
                    [wr_data,wr_addr,wr_en,rd_addr,rd_valid,layeridx,iterind,...
                    validcount,betaread,countidx,iterdone,softreset,funcenb,iterout]=iterationControllerScalar(obj,data,valid,...
                    frame_valid,obj.resetD,bgn,liftsize,endind,data_mc,valid_mc,numIterations,numrows,termpass);
                end
            else

                if obj.vectorSize==64
                    [wr_data,wr_addr,wr_en,rd_addr,rd_valid,iterdone,iterind,...
                    betaread,countidx,layeridx,validcount,softreset,iterout]=iterationControllerVector(obj,data,valid,frame_valid,...
                    obj.resetD,data_mc,valid_mc,bgn,liftsize,endind,niter,numrows,termpass);
                    funcenb=false;
                else
                    [wr_data,wr_addr,wr_en,rd_addr,rd_valid,layeridx,iterind,...
                    validcount,betaread,countidx,iterdone,softreset,funcenb,iterout]=iterationControllerScalar(obj,data,valid,...
                    frame_valid,obj.resetD,bgn,liftsize,endind,data_mc,valid_mc,niter,numrows,termpass);
                end
            end

            wr_addrD=wr_addr*uint8(ones(384,1));
            rd_addrD=rd_addr*uint8(ones(384,1));


            coldata=obj.dataMemory(wr_data,wr_addrD,wr_en,rd_addrD);


            nrows_idx=cast(numrows-4,'like',numrows);

            [V,finalV]=obj.checkMatrixLUT(bgn,setindex,layeridx,iterind,zaddr,obj.validC,nrows_idx);
            obj.validC(:)=validcount;


            V_new=cast(V+liftsize,'like',V);

            int_reset=softreset||reset;

            if obj.vectorSize==64
                iterdone_flag=obj.iterDone;
            else
                iterdone_flag=iterdone;
            end


            [gammaout,gammavalid]=obj.metricCalculator(coldata,liftsize,V_new,rd_valid,...
            layeridx,betaread,countidx,int_reset,funcenb,iterdone_flag);
            obj.funcEnb(:)=funcenb;


            [dataout,ctrlout,finshift]=obj.finalDecision(coldata,iterdone_flag,liftsize,bgn,finalV,int_reset);
            obj.iterDone=iterdone;



            if strcmpi(obj.Termination,'Early')||obj.ParityCheckStatus
                obj.termPassD(:)=earlyTermination(obj,obj.resetD,gammaout,gammavalid,liftsize,countidx,numrows);
            end


            obj.gamma=gammaout;
            obj.validMC=gammavalid;


            Z=liftsize;
            obj.decBits(1:Z)=circshift(obj.FData(1:Z),int32(mod(obj.finalShifts,Z)));
            obj.finalShifts=finshift;
            obj.FData(:)=dataout;



            if obj.vectorSize==64
                validtmp=ctrlout.valid;
                if obj.RateCompatible
                    obj.dataOut(:)=obj.delayBalancer1(obj.dataOutReg1);
                    obj.iterOut(:)=obj.delayBalancer2(obj.iterOutReg1);
                    obj.parCheck(:)=obj.delayBalancer3(obj.termPassD2);
                else
                    obj.dataOut(:)=obj.dataOutReg1;
                    obj.iterOut(:)=obj.iterOutReg1;
                    obj.parCheck(:)=obj.termPassD2;
                end
            else
                validtmp=obj.ctrlOutReg.valid;
                if obj.RateCompatible
                    obj.dataOut(:)=obj.delayBalancer1(obj.dataOutReg);
                    obj.iterOut(:)=obj.delayBalancer2(obj.iterOutReg);
                    obj.parCheck(:)=obj.delayBalancer3(obj.termPassD1);
                else
                    obj.dataOut(:)=obj.dataOutReg;
                    obj.iterOut(:)=obj.iterOutReg;
                    obj.parCheck(:)=obj.termPassD1;
                end
            end

            obj.dataOutReg1(:)=obj.dataOutReg;
            obj.iterOutReg1(:)=obj.iterOutReg;

            obj.dataOutReg(:)=outputGeneration(obj,obj.decBits,zaddr,setindex,liftsize,validtmp,int_reset);


            obj.iterOutReg(:)=iterout;

            if~validtmp
                obj.dataOutReg(:)=zeros(obj.vectorSize,1);
                obj.iterOutReg(:)=0;
            end

            obj.termPassD2(:)=obj.termPassD1;
            obj.termPassD1(:)=obj.termPassD;

            if obj.RateCompatible
                obj.ctrlOut.start(:)=obj.delayBalancer4(obj.ctrlOutReg1.start);
                obj.ctrlOut.end(:)=obj.delayBalancer5(obj.ctrlOutReg1.end);
                obj.ctrlOut.valid(:)=obj.delayBalancer6(obj.ctrlOutReg1.valid);
            else
                obj.ctrlOut=obj.ctrlOutReg1;
            end

            obj.ctrlOutReg1=obj.ctrlOutReg;
            obj.ctrlOutReg=ctrlout;

            if~obj.ctrlOut.valid
                obj.parCheck(:)=false;
            end

        end

        function[wr_data,wr_addr,wr_en,rd_addr,rd_valid,iterdone,iterind,...
            betaread,countidx,countlayer,validcount,softreset,iterout]=iterationControllerVector(obj,data,valid,framevalid,...
            reset,data_delay,valid_delay,bgn,liftsize,endind,numiter,nrows,termpass)

            countbgn1=fi([19,19,19,19,3,8,9,7,10,9,7,8,7,6,7,7,6,6,6,6,6,6,5,5,6,5,5,4,5,5,5,5,5,5,5,5,5,4,5,5,4,5,4,5,5,4]-1,0,5,0);
            countbgn2=fi([8,10,8,10,4,6,6,6,4,5,5,5,4,5,5,4,5,5,4,4,4,4,3,4,4,3,5,3,4,3,5,3,4,4,4,4,4,3,4,4,4,4,4,5,5,4]-1,0,5,0);


            AddrLUT=uint8([1;2;3;4;6;7;10;11;12;13;14;16;17;19;20;21;22;23;24;1;3;4;5;6;8;9;10;12;13;15;16;17;18;20;22;23;24;25;1;2;3;5;6;7;8;9;10;11;14;15;
            16;18;19;20;21;25;26;1;2;4;5;7;8;9;11;12;13;14;15;17;18;19;21;22;23;26;1;2;27;1;2;4;13;17;22;23;28;1;7;11;12;14;18;19;21;29;1;2;5;8;
            9;15;30;1;2;4;13;17;20;22;23;25;31;1;2;11;12;14;18;19;21;32;2;3;5;8;9;15;33;1;2;13;17;22;23;24;34;1;2;11;12;14;19;35;1;4;8;21;24;36;
            1;13;16;17;18;22;37;1;2;11;14;19;26;38;2;4;12;21;23;39;1;15;17;18;22;40;2;13;14;19;20;41;1;2;8;9;11;42;1;4;10;12;23;43;2;6;17;21;22;44;
            1;13;14;18;45;2;3;11;19;46;1;4;5;12;23;47;2;7;8;15;48;1;3;5;16;49;2;7;9;50;1;5;20;22;51;2;15;19;26;52;1;11;14;25;53;2;8;23;26;54;
            1;13;15;25;55;2;3;12;22;56;1;8;16;18;57;2;7;13;23;58;1;15;16;19;59;2;14;24;60;1;10;11;13;61;2;4;8;20;62;1;9;18;63;2;4;10;19;64;1;5;
            25;65;2;17;19;26;66;1;8;10;23;67;2;7;11;68;zeros(196,1);
            1;2;3;4;7;10;11;12;1;4;5;6;7;8;9;10;12;13;1;2;4;5;9;11;13;14;2;3;5;6;7;8;9;10;11;14;1;2;12;15;1;2;6;8;12;16;1;6;8;10;
            12;17;2;6;8;12;14;18;1;2;13;19;2;9;11;12;20;1;2;7;8;21;1;8;10;14;22;2;4;12;23;1;2;9;14;24;2;7;12;14;25;1;11;12;26;2;10;12;13;27;
            2;6;12;13;28;1;7;8;29;1;2;11;30;2;5;12;31;1;9;14;32;2;3;33;1;4;6;34;2;3;10;35;1;6;36;3;8;13;14;37;1;7;38;2;3;6;39;1;5;40;
            3;6;8;10;41;2;14;42;1;6;13;43;3;8;11;44;1;13;14;45;2;6;12;46;1;3;8;47;11;14;48;2;6;12;49;1;8;13;50;3;11;14;51;2;6;12;52;zeros(315,1)]);


            if bgn
                countidx=countbgn2(obj.countLayer);
                maxCount=fi(10,0,8,0,hdlfimath);
            else
                countidx=countbgn1(obj.countLayer);
                maxCount=fi(22,0,8,0,hdlfimath);
            end

            softreset=((~obj.endInd)&&endind);
            obj.layerDone(:)=((~valid_delay)&&obj.validDelay);

            if reset
                obj.noOp(:)=true;
            elseif softreset
                obj.noOp(:)=false;
            end


            if obj.noOp
                datasel=false;
            else
                datasel=~(framevalid);
            end

            if strcmpi(obj.Termination,'Early')
                if termpass
                    iterout=uint8(obj.iterCount);
                else
                    iterout=uint8(numiter);
                end
            else
                iterout=uint8(numiter);
            end



            if reset
                iterdone=false;
                obj.countLayer(:)=fi(1,0,6,0);
                obj.iterCount(:)=fi(0,0,6,0);
                obj.betaRead(:)=false;
                resetcount=true;
            else
                if(obj.iterCount==fi(numiter,0,6,0)||termpass)
                    if strcmpi(obj.Termination,'Early')
                        iterdone=true;
                        resetcount=true;
                    else
                        if obj.iterCount==fi(numiter,0,6,0)
                            iterdone=true;
                            resetcount=true;
                        else
                            iterdone=false;
                            resetcount=false;
                        end
                    end
                else
                    iterdone=false;
                    if obj.layerDone&&datasel
                        if obj.countLayer==nrows
                            obj.betaRead(:)=true;
                            obj.iterCount(:)=obj.iterCount+1;
                            obj.countLayer(:)=1;
                            resetcount=true;
                        else
                            obj.countLayer(:)=obj.countLayer+fi(1,0,1,0);
                            resetcount=false;
                        end
                    else
                        resetcount=false;
                    end
                end
            end

            if obj.iterCount==fi(0,0,6,0)
                obj.iterInd(:)=false;
            else
                obj.iterInd(:)=true;
            end


            ztemp=bitsliceget(cast(liftsize-fi(1,0,1,0),'like',liftsize),9,7);
            zcount=cast(ztemp+fi(2,0,2,0),'like',obj.zCount);
            if reset||obj.resetDelay
                if reset
                    obj.wrAddr(:)=1;
                    obj.wrEnb(:)=ones(384,1)>0;
                    obj.wrData(:)=zeros(384,1);
                    obj.wrCount(:)=1;
                    obj.zCount(:)=0;
                    obj.enb(:)=false;
                    obj.endInd(:)=true;
                    obj.validDelay(:)=false;
                    obj.validCount(:)=0;
                    obj.rdenb(:)=false;
                    obj.rdValid(:)=false;
                    obj.rdAddrFinal(:)=uint8(1);
                    obj.rdAddr(:)=uint8(0);
                    obj.rdAddr1(:)=uint8(0);
                    obj.rdCount(:)=1;
                    obj.finalEnb(:)=false;
                    obj.zCount1=fi(1,0,3,0,hdlfimath);
                    obj.rdFinEnb=false;
                elseif obj.resetDelay
                    obj.wrAddr(:)=2;
                    obj.wrEnb(:)=ones(384,1)>0;
                    obj.wrData(:)=zeros(384,1);
                end
            else
                if~datasel
                    obj.wrCount(:)=1;
                    if liftsize>fi(64,0,9,0)
                        if valid
                            if obj.zCount==zcount-1
                                obj.zCount(:)=1;
                                obj.enb(:)=true;
                            else
                                obj.zCount(:)=obj.zCount+1;
                                obj.enb(:)=false;
                            end

                            if obj.enb
                                obj.wrAddr(:)=obj.wrAddr+1;
                            end

                            if obj.zCount==1
                                obj.wrEnb(:)=[ones(64,1);zeros(320,1)]>0;
                                obj.wrData(:)=[data;zeros(320,1)];
                            elseif obj.zCount==2
                                obj.wrEnb(:)=[zeros(64,1);ones(64,1);zeros(256,1)]>0;
                                obj.wrData(:)=[zeros(64,1);data;zeros(256,1)];
                            elseif obj.zCount==3
                                obj.wrEnb(:)=[zeros(128,1);ones(64,1);zeros(192,1)]>0;
                                obj.wrData(:)=[zeros(128,1);data;zeros(192,1)];
                            elseif obj.zCount==4
                                obj.wrEnb(:)=[zeros(192,1);ones(64,1);zeros(128,1)]>0;
                                obj.wrData(:)=[zeros(192,1);data;zeros(128,1)];
                            elseif obj.zCount==5
                                obj.wrEnb(:)=[zeros(256,1);ones(64,1);zeros(64,1)]>0;
                                obj.wrData(:)=[zeros(256,1);data;zeros(64,1)];
                            elseif obj.zCount==6
                                obj.wrEnb(:)=[zeros(320,1);ones(64,1)]>0;
                                obj.wrData(:)=[zeros(320,1);data;];
                            else
                                obj.wrEnb(:)=zeros(384,1)>0;
                                obj.wrData(:)=zeros(384,1);
                            end
                        end

                    else
                        if obj.enb
                            obj.wrAddr(:)=obj.wrAddr+1;
                        end
                        if valid
                            obj.enb(:)=true;
                            obj.wrEnb(:)=[ones(64,1);zeros(320,1)]>0;
                            obj.wrData(:)=[data;zeros(320,1)];
                        else
                            obj.enb(:)=false;
                        end
                    end
                else
                    if valid_delay
                        obj.wrData(:)=data_delay;
                        obj.wrEnb(:)=ones(384,1)>0;
                        obj.wrAddr(:)=AddrLUT(bitconcat(fi(bgn,0,1,0),obj.wrCount));
                    else
                        obj.wrEnb(:)=zeros(384,1)>0;
                    end

                    if resetcount
                        obj.wrCount(:)=1;
                    elseif valid_delay
                        obj.wrCount(:)=obj.wrCount+1;
                    end

                end
            end

            obj.resetDelay1(:)=obj.resetDelay;
            obj.resetDelay(:)=reset;










            trigger=softreset||obj.layerDone;
            obj.endInd(:)=endind;
            obj.validDelay(:)=valid_delay;

            if trigger&&~iterdone&&datasel
                obj.rdenb(:)=true;
            else
                if iterdone
                    obj.rdenb(:)=false;
                end
            end

            if datasel
                rd_valid=obj.rdValid;
            else
                rd_valid=false;
            end

            obj.rdValid(:)=obj.rdenb;

            if obj.rdenb&&datasel
                if obj.validCount==countidx
                    obj.validCount(:)=0;
                    obj.rdenb(:)=false;
                else
                    obj.validCount(:)=obj.validCount+1;
                end
            else
                obj.validCount(:)=0;
            end

            obj.rdAddr=AddrLUT(bitconcat(fi(bgn,0,1,0),obj.rdCount));

            if datasel
                if resetcount
                    obj.rdCount(:)=1;
                else
                    if obj.rdValid
                        obj.rdCount(:)=obj.rdCount+1;
                    end
                end
            else
                obj.rdCount(:)=1;
            end

            obj.rdAddr1=AddrLUT(bitconcat(fi(bgn,0,1,0),obj.rdCount));

            if iterdone
                obj.finalEnb(:)=true;
            end

            if obj.zCount1==zcount-1
                obj.zCount1(:)=1;
                obj.rdFinEnb(:)=true;
            else
                if obj.finalEnb
                    obj.zCount1(:)=obj.zCount1+1;
                end
                obj.rdFinEnb(:)=false;
            end

            if obj.finalEnb
                if obj.rdAddrFinal==maxCount
                    obj.finalEnb(:)=false;
                else
                    if obj.rdFinEnb
                        obj.rdAddrFinal(:)=obj.rdAddrFinal+1;
                    end
                end
            else
                obj.rdAddrFinal(:)=1;
            end


            countlayer=obj.countLayer;
            betaread=obj.betaRead;
            iterind=obj.iterInd;
            wr_data=obj.wrData;
            wr_en=obj.wrEnb;
            wr_addr=obj.wrAddr;

            if datasel
                if iterdone
                    rd_addr=obj.rdAddrFinal;
                else
                    if obj.iterInd
                        rd_addr=obj.rdAddr1;
                    else
                        rd_addr=obj.rdAddr;
                    end
                end
            else
                rd_addr=cast(1,'like',obj.rdAddr);
            end

            validcount=cast(obj.validCount+1,'like',obj.validCount);

            if obj.resetDelay1
                obj.wrAddr(:)=3;
            end

        end

        function[wr_data,wr_addr,wr_en,rd_addr,rd_valid,countlayer,iterind,validcount,...
            enable,countidx,iterdone,softreset,funcenb,iterout]=iterationControllerScalar(obj,data,valid,framevalid,...
            reset,bgn,liftsize,endind,data_delay,valid_delay,numiter,nrows,termpass)

            countbgn1=fi([19,19,19,19,3,8,9,7,10,9,7,8,7,6,7,7,6,6,6,6,6,6,5,5,6,5,5,4,5,5,5,5,5,5,5,5,5,4,5,5,4,5,4,5,5,4]-1,0,5,0);
            countbgn2=fi([8,10,8,10,4,6,6,6,4,5,5,5,4,5,5,4,5,5,4,4,4,4,3,4,4,3,5,3,4,3,5,3,4,4,4,4,4,3,4,4,4,4,4,5,5,4]-1,0,5,0);


            maxCountbgn1=fi([76;76;76;76;79;87;96;103;113;122;129;137;144;150;157;164;170;176;182;188;194;
            200;205;210;216;221;226;230;235;240;245;250;255;260;265;270;275;279;284;
            289;293;298;302;307;312;316]+1,0,9,0,hdlfimath);
            maxCountbgn2=fi([36;36;36;36;40;46;52;58;62;67;72;77;81;86;91;95;100;105;109;113;117;
            121;124;128;132;135;140;143;147;150;155;158;162;166;170;174;178;181;185
            189;193;197;197;197;197;197]+1,0,9,0,hdlfimath);



            AddrLUT=uint8([1;2;3;4;6;7;10;11;12;13;14;16;17;19;20;21;22;23;24;1;3;4;5;6;8;9;10;12;13;15;16;17;18;20;22;23;24;25;1;2;3;5;6;7;8;9;10;11;14;15;
            16;18;19;20;21;25;26;1;2;4;5;7;8;9;11;12;13;14;15;17;18;19;21;22;23;26;1;2;27;1;2;4;13;17;22;23;28;1;7;11;12;14;18;19;21;29;1;2;5;8;
            9;15;30;1;2;4;13;17;20;22;23;25;31;1;2;11;12;14;18;19;21;32;2;3;5;8;9;15;33;1;2;13;17;22;23;24;34;1;2;11;12;14;19;35;1;4;8;21;24;36;
            1;13;16;17;18;22;37;1;2;11;14;19;26;38;2;4;12;21;23;39;1;15;17;18;22;40;2;13;14;19;20;41;1;2;8;9;11;42;1;4;10;12;23;43;2;6;17;21;22;44;
            1;13;14;18;45;2;3;11;19;46;1;4;5;12;23;47;2;7;8;15;48;1;3;5;16;49;2;7;9;50;1;5;20;22;51;2;15;19;26;52;1;11;14;25;53;2;8;23;26;54;
            1;13;15;25;55;2;3;12;22;56;1;8;16;18;57;2;7;13;23;58;1;15;16;19;59;2;14;24;60;1;10;11;13;61;2;4;8;20;62;1;9;18;63;2;4;10;19;64;1;5;
            25;65;2;17;19;26;66;1;8;10;23;67;2;7;11;68;zeros(196,1);
            1;2;3;4;7;10;11;12;1;4;5;6;7;8;9;10;12;13;1;2;4;5;9;11;13;14;2;3;5;6;7;8;9;10;11;14;1;2;12;15;1;2;6;8;12;16;1;6;8;10;
            12;17;2;6;8;12;14;18;1;2;13;19;2;9;11;12;20;1;2;7;8;21;1;8;10;14;22;2;4;12;23;1;2;9;14;24;2;7;12;14;25;1;11;12;26;2;10;12;13;27;
            2;6;12;13;28;1;7;8;29;1;2;11;30;2;5;12;31;1;9;14;32;2;3;33;1;4;6;34;2;3;10;35;1;6;36;3;8;13;14;37;1;7;38;2;3;6;39;1;5;40;
            3;6;8;10;41;2;14;42;1;6;13;43;3;8;11;44;1;13;14;45;2;6;12;46;1;3;8;47;11;14;48;2;6;12;49;1;8;13;50;3;11;14;51;2;6;12;52;zeros(315,1)]);

            if bgn
                countidx=countbgn2(obj.countLayer);
                maxCount=maxCountbgn2(nrows);
            else
                countidx=countbgn1(obj.countLayer);
                maxCount=maxCountbgn1(nrows);
            end
            startCount=fi(1,0,9,0,hdlfimath);

            softreset=((~obj.endInd)&&endind);

            if reset
                obj.noOp(:)=true;
            elseif softreset
                obj.noOp(:)=false;
            end

            if strcmpi(obj.Termination,'Early')
                if termpass
                    iterout=uint8(obj.iterCount);
                else
                    iterout=uint8(numiter);
                end
            else
                iterout=uint8(numiter);
            end


            if obj.noOp
                datasel=false;
            else
                datasel=~(framevalid);
            end

            ztemp=bitsliceget(cast(liftsize-fi(1,0,9,0),'like',liftsize),9,7);
            zcount=cast(ztemp+fi(1,0,1,0),'like',obj.rdZCount);



            if((~valid_delay)&&obj.validDelay)&&datasel
                obj.rdZCount(:)=obj.rdZCount+1;
                if obj.rdZCount==fi(zcount+1,0,3,0)
                    if obj.colCount==maxCount
                        obj.initCount(:)=startCount;
                    else
                        obj.initCount(:)=obj.colCount;
                    end
                    obj.colCount(:)=obj.initCount;
                else
                    obj.colCount(:)=obj.initCount;
                end
            end

            obj.layerDone=((~valid_delay)&&obj.validDelay)&&(obj.rdZCount==fi(zcount+1,0,3,0));

            funcenb=((~valid_delay)&&obj.validDelay)&&~(obj.rdZCount==fi(zcount+1,0,3,0));



            if reset
                iterdone=false;
                obj.countLayer(:)=1;
                obj.iterCount(:)=0;
                obj.betaRead(:)=false;
                resetcount=true;
            else
                if(obj.iterCount==fi(numiter,0,6,0)||termpass)
                    if strcmpi(obj.Termination,'Early')
                        iterdone=true;
                        resetcount=true;
                    else
                        if obj.iterCount==fi(numiter,0,6,0)
                            iterdone=true;
                            resetcount=true;
                        else
                            iterdone=false;
                            resetcount=false;
                        end
                    end
                else
                    iterdone=false;
                    if obj.layerDone&&datasel
                        obj.rdZCount(:)=1;
                        if obj.countLayer==nrows
                            obj.betaRead(:)=true;
                            obj.iterCount(:)=obj.iterCount+1;
                            obj.countLayer(:)=1;
                            resetcount=true;
                        else
                            obj.countLayer(:)=obj.countLayer+1;
                            resetcount=false;
                        end
                    else
                        resetcount=false;
                    end
                end
            end

            if obj.iterCount==fi(0,0,6,0,hdlfimath)
                obj.iterInd(:)=false;
            else
                obj.iterInd(:)=true;
            end

            if reset||obj.resetDelay
                if reset
                    obj.wrAddr(:)=1;
                    obj.wrEnb(:)=ones(384,1)>0;
                    obj.wrData(:)=zeros(384,1);
                    obj.wrCount(:)=3;
                    obj.validCount(:)=0;
                    obj.rdEnb(:)=false;
                    obj.rdValid(:)=false;
                    obj.rdAddrFinal(:)=1;
                    obj.rdAddr(:)=0;
                    obj.rdAddr1(:)=0;
                    obj.rdCount(:)=1;
                    obj.finalEnb(:)=false;
                    obj.wrLUTAddr(:)=0;
                    obj.rdLUTAddr(:)=0;
                    obj.rdLUTAddr1(:)=0;
                    obj.rdFinEnb(:)=false;
                    obj.zCount(:)=1;
                    obj.colCount(:)=1;
                    obj.rdZCount(:)=1;
                    obj.initCount(:)=1;
                    obj.endInd(:)=false;
                    obj.validDelay(:)=false;
                elseif obj.resetDelay
                    obj.wrAddr(:)=2;
                    obj.wrEnb(:)=ones(384,1)>0;
                    obj.wrData(:)=zeros(384,1);
                end
            else

                if~datasel
                    if valid
                        for idx=1:384
                            if obj.colCount==fi(idx,0,9,0)
                                obj.wrEnb(idx)=true;
                                obj.wrData(idx)=data;
                            else
                                obj.wrEnb(idx)=false;
                                obj.wrData(idx)=0;
                            end
                        end
                        obj.wrAddr(:)=obj.wrCount;

                        if obj.colCount==liftsize
                            obj.colCount(:)=1;
                            obj.wrCount(:)=obj.wrCount+1;
                        else
                            obj.colCount(:)=obj.colCount+1;
                        end
                    else
                        obj.wrEnb(:)=zeros(384,1)>0;
                        obj.wrData(:)=zeros(384,1);
                    end
                else
                    if valid_delay
                        obj.wrLUTAddr=fi(bitconcat(fi(bgn,0,1,0),obj.colCount),0,10,0,hdlfimath);
                        obj.wrAddr(:)=AddrLUT(obj.wrLUTAddr);
                        if obj.rdZCount==fi(1,0,3,0,hdlfimath)
                            obj.wrEnb(:)=[ones(64,1);zeros(320,1)];
                            obj.wrData(:)=[data_delay;zeros(320,1)];
                        elseif obj.rdZCount==fi(2,0,3,0,hdlfimath)
                            obj.wrEnb(:)=[zeros(64,1);ones(64,1);zeros(256,1)];
                            obj.wrData(:)=[zeros(64,1);data_delay;zeros(256,1)];
                        elseif obj.rdZCount==fi(3,0,3,0,hdlfimath)
                            obj.wrEnb(:)=[zeros(128,1);ones(64,1);zeros(192,1)];
                            obj.wrData(:)=[zeros(128,1);data_delay;zeros(192,1)];
                        elseif obj.rdZCount==fi(4,0,3,0,hdlfimath)
                            obj.wrEnb(:)=[zeros(192,1);ones(64,1);zeros(128,1)];
                            obj.wrData(:)=[zeros(192,1);data_delay;zeros(128,1)];
                        elseif obj.rdZCount==fi(5,0,3,0,hdlfimath)
                            obj.wrEnb(:)=[zeros(256,1);ones(64,1);zeros(64,1)];
                            obj.wrData(:)=[zeros(256,1);data_delay;zeros(64,1)];
                        elseif obj.rdZCount==fi(6,0,3,0,hdlfimath)
                            obj.wrEnb(:)=[zeros(320,1);ones(64,1)];
                            obj.wrData(:)=[zeros(320,1);data_delay;];
                        else
                            obj.wrEnb(:)=zeros(384,1)>0;
                            obj.wrData(:)=zeros(384,1);
                        end
                    else
                        obj.wrEnb(:)=zeros(384,1)>0;
                        obj.wrData(:)=zeros(384,1);
                    end
                    if resetcount
                        obj.colCount(:)=1;
                    elseif valid_delay
                        obj.colCount(:)=obj.colCount+1;
                    end
                end
            end








            obj.resetDelay1(:)=obj.resetDelay;
            obj.resetDelay(:)=reset;

            obj.endInd(:)=endind;
            obj.validDelay(:)=valid_delay;

            trigger=softreset||obj.layerDone;

            if trigger&&~iterdone&&datasel
                obj.rdEnb(:)=true;
            else
                if iterdone||~datasel
                    obj.rdEnb(:)=false;
                end
            end

            if datasel
                rd_valid=obj.rdValid;
            else
                rd_valid=false;
            end

            obj.rdValid=obj.rdEnb;

            if obj.rdEnb&&datasel
                if obj.validCount==countidx
                    obj.validCount(:)=0;
                    obj.rdEnb(:)=false;
                else
                    obj.validCount(:)=obj.validCount+1;
                end
            else
                obj.validCount(:)=0;
            end

            obj.rdLUTAddr(:)=fi(bitconcat(fi(bgn,0,1,0),obj.rdCount),0,10,0,hdlfimath);

            obj.rdAddr(:)=AddrLUT(obj.rdLUTAddr);

            if datasel
                if resetcount
                    obj.rdCount(:)=1;
                else
                    if obj.rdValid
                        obj.rdCount(:)=obj.rdCount+1;
                    end
                end
            else
                obj.rdCount(:)=1;
            end

            obj.rdLUTAddr1(:)=fi(bitconcat(fi(bgn,0,1,0),obj.rdCount),0,10,0,hdlfimath);

            obj.rdAddr1(:)=AddrLUT(obj.rdLUTAddr1);

            if iterdone
                obj.finalEnb(:)=true;
            end

            if obj.zCount==liftsize
                obj.zCount(:)=1;
                obj.rdFinEnb(:)=true;
            else
                if obj.finalEnb
                    obj.zCount(:)=obj.zCount+1;
                end
                obj.rdFinEnb(:)=false;
            end

            if obj.finalEnb
                if obj.rdAddrFinal==maxCount
                    obj.finalEnb(:)=false;
                else
                    if obj.rdFinEnb
                        obj.rdAddrFinal(:)=obj.rdAddrFinal+1;
                    end
                end
            else
                obj.rdAddrFinal(:)=1;
            end

            wr_data=obj.wrData;
            wr_addr=obj.wrAddr;
            wr_en=obj.wrEnb;
            if datasel
                if iterdone
                    rd_addr=obj.rdAddrFinal;
                else
                    if obj.iterInd
                        rd_addr=obj.rdAddr1;
                    else
                        rd_addr=obj.rdAddr;
                    end
                end
            else
                rd_addr=cast(1,'like',obj.rdAddr);
            end
            countlayer=obj.countLayer;
            iterind=obj.iterInd;
            enable=obj.betaRead;

            validcount=cast(obj.validCount+1,'like',obj.validCount);

            if obj.resetDelay1
                obj.wrAddr(:)=3;
            end
        end

        function termpass=earlyTermination(obj,reset,gamma,valid,liftsize,countidx,maxlayer)

            if obj.vectorSize==64
                vAddr=384;
            else
                vAddr=64;
            end

            if reset
                termpass=false;
            else
                termpass=obj.termPass;
            end

            hardDec=gamma<=0;


            if reset
                obj.fPChecks(:)=zeros(vAddr,1);
            else
                if valid
                    for idx=1:vAddr
                        if fi(idx,0,9,0)<=liftsize
                            if hardDec(idx)
                                obj.fPChecks(idx)=~obj.fPChecks(idx);
                            end
                        end
                    end
                else
                    obj.fPChecks(:)=zeros(vAddr,1);
                end
            end


            if obj.vectorSize==64
                if reset
                    obj.earColCount(:)=0;
                    obj.earLayCount(:)=0;
                    obj.earEnb(:)=false;
                    obj.earEnbLayer(:)=false;
                else
                    if valid
                        if obj.earColCount==countidx
                            obj.earColCount(:)=0;
                            obj.earEnb(:)=true;
                            if obj.earLayCount==maxlayer-fi(1,0,1,0)
                                obj.earLayCount(:)=0;
                                obj.earEnbLayer(:)=true;
                            else
                                obj.earLayCount(:)=obj.earLayCount+1;
                            end
                        else
                            obj.earColCount(:)=obj.earColCount+1;
                            obj.earEnb(:)=false;
                        end
                    else
                        obj.earEnb(:)=false;
                        obj.earEnbLayer(:)=false;
                    end
                end
            else
                ztemp=bitsliceget(cast(liftsize-fi(1,0,9,0),'like',liftsize),9,7);
                zcount=cast(ztemp+fi(1,0,1,0),'like',obj.rdZCount);
                if reset
                    obj.earColCount(:)=0;
                    obj.earLayCount(:)=0;
                    obj.earEnb(:)=false;
                    obj.earEnbLayer(:)=false;
                    obj.earPFCount(:)=1;
                else
                    if valid
                        if obj.earColCount==countidx
                            obj.earColCount(:)=0;
                            obj.earEnb(:)=true;
                            if obj.earPFCount==zcount
                                obj.earPFCount(:)=1;
                                if obj.earLayCount==maxlayer-fi(1,0,1,0)
                                    obj.earLayCount(:)=0;
                                    obj.earEnbLayer(:)=true;
                                else
                                    obj.earLayCount(:)=obj.earLayCount+1;
                                end
                            else
                                obj.earPFCount(:)=obj.earPFCount+1;
                            end
                        else
                            obj.earColCount(:)=obj.earColCount+1;
                            obj.earEnb(:)=false;
                        end
                    else
                        obj.earEnb(:)=false;
                        obj.earEnbLayer(:)=false;
                    end
                end
            end
            if obj.earEnbDelay
                if~obj.checkFailed
                    for idx=1:vAddr
                        if(obj.fPChecksD(idx)==1)
                            obj.checkFailed(:)=true;
                        end
                    end
                end
            end

            obj.earEnbDelay(:)=obj.earEnb;
            obj.fPChecksD(:)=obj.fPChecks;

            if reset
                obj.termPass(:)=false;
                obj.checkFailed(:)=false;
            elseif obj.earEnbLayerD
                obj.termPass(:)=~obj.checkFailed;
                if obj.earLayCount==0
                    obj.checkFailed(:)=false;
                end
            end

            obj.earEnbLayerD(:)=obj.earEnbLayer;

        end

        function y=outputGeneration(obj,data,zaddr,iLS,liftsize,valid,reset)

            LUT=[fi([ones(1,2),zeros(1,62)],0,1,0);
            fi([ones(1,4),zeros(1,60)],0,1,0);
            fi([ones(1,8),zeros(1,56)],0,1,0);
            fi([ones(1,16),zeros(1,48)],0,1,0);
            fi([ones(1,32),zeros(1,32)],0,1,0);
            fi(ones(1,64),0,1,0);
            fi(ones(1,64),0,1,0);
            fi(ones(1,64),0,1,0);
            fi([ones(1,3),zeros(1,61)],0,1,0);
            fi([ones(1,6),zeros(1,58)],0,1,0);
            fi([ones(1,12),zeros(1,52)],0,1,0);
            fi([ones(1,24),zeros(1,40)],0,1,0);
            fi([ones(1,48),zeros(1,16)],0,1,0);
            fi([ones(1,32),zeros(1,32)],0,1,0);
            fi(ones(1,64),0,1,0);
            fi(ones(1,64),0,1,0);
            fi([ones(1,5),zeros(1,59)],0,1,0);
            fi([ones(1,10),zeros(1,54)],0,1,0);
            fi([ones(1,20),zeros(1,44)],0,1,0);
            fi([ones(1,40),zeros(1,24)],0,1,0);
            fi([ones(1,16),zeros(1,48)],0,1,0);
            fi([ones(1,32),zeros(1,32)],0,1,0);
            fi(ones(1,64),0,1,0);
            fi([ones(1,5),zeros(1,59)],0,1,0);
            fi([ones(1,7),zeros(1,57)],0,1,0);
            fi([ones(1,14),zeros(1,50)],0,1,0);
            fi([ones(1,28),zeros(1,36)],0,1,0);
            fi([ones(1,56),zeros(1,8)],0,1,0);
            fi([ones(1,48),zeros(1,16)],0,1,0);
            fi([ones(1,32),zeros(1,32)],0,1,0);
            fi([ones(1,7),zeros(1,57)],0,1,0);
            fi([ones(1,7),zeros(1,57)],0,1,0);
            fi([ones(1,9),zeros(1,55)],0,1,0);
            fi([ones(1,18),zeros(1,46)],0,1,0);
            fi([ones(1,36),zeros(1,28)],0,1,0);
            fi([ones(1,8),zeros(1,56)],0,1,0);
            fi([ones(1,16),zeros(1,48)],0,1,0);
            fi([ones(1,32),zeros(1,32)],0,1,0);
            fi([ones(1,9),zeros(1,55)],0,1,0);
            fi([ones(1,9),zeros(1,55)],0,1,0);
            fi([ones(1,11),zeros(1,53)],0,1,0);
            fi([ones(1,22),zeros(1,42)],0,1,0);
            fi([ones(1,44),zeros(1,20)],0,1,0);
            fi([ones(1,24),zeros(1,40)],0,1,0);
            fi([ones(1,48),zeros(1,16)],0,1,0);
            fi([ones(1,32),zeros(1,32)],0,1,0);
            fi([ones(1,11),zeros(1,53)],0,1,0);
            fi([ones(1,11),zeros(1,53)],0,1,0);
            fi([ones(1,13),zeros(1,51)],0,1,0);
            fi([ones(1,26),zeros(1,38)],0,1,0);
            fi([ones(1,52),zeros(1,12)],0,1,0);
            fi([ones(1,40),zeros(1,24)],0,1,0);
            fi([ones(1,16),zeros(1,48)],0,1,0);
            fi([ones(1,13),zeros(1,51)],0,1,0);
            fi([ones(1,13),zeros(1,51)],0,1,0);
            fi([ones(1,13),zeros(1,51)],0,1,0);
            fi([ones(1,15),zeros(1,49)],0,1,0);
            fi([ones(1,30),zeros(1,34)],0,1,0);
            fi([ones(1,60),zeros(1,4)],0,1,0);
            fi([ones(1,56),zeros(1,8)],0,1,0);
            fi([ones(1,48),zeros(1,16)],0,1,0);
            fi([ones(1,15),zeros(1,49)],0,1,0);
            fi([ones(1,15),zeros(1,49)],0,1,0);
            fi([ones(1,15),zeros(1,49)],0,1,0);];

            ztemp=bitsliceget(cast(liftsize-fi(1,0,1,0),'like',liftsize),9,7);
            zcount=cast(ztemp+fi(1,0,2,0),'like',obj.outZCount);

            if reset
                obj.outZCount=fi(1,0,9,0,hdlfimath);
                obj.outWrData=zeros(obj.vectorSize,1)>0;
                obj.LUTData=zeros(64,1)>0;
                obj.outAddr=fi(1,0,6,0);
            end

            if obj.vectorSize==64
                if obj.outZCount==1
                    obj.outWrData(:)=data(1:64);
                elseif obj.outZCount==2
                    obj.outWrData(:)=data(65:128);
                elseif obj.outZCount==3
                    obj.outWrData(:)=data(129:192);
                elseif obj.outZCount==4
                    obj.outWrData(:)=data(193:256);
                elseif obj.outZCount==5
                    obj.outWrData(:)=data(257:320);
                elseif obj.outZCount==6
                    obj.outWrData(:)=data(321:384);
                else
                    obj.outWrData(:)=data(1:64);
                end

                if valid
                    if(obj.outZCount==cast(zcount,'like',obj.outZCount))
                        lutenb=true;
                    else
                        obj.outZCount(:)=obj.outZCount+1;
                        lutenb=false;
                    end
                else
                    lutenb=false;
                end

                obj.outAddr(:)=bitconcat(iLS,zaddr);

                if lutenb
                    obj.LUTData(:)=LUT(obj.outAddr+1);
                else
                    obj.LUTData(:)=fi(ones(1,64),0,1,0);
                end

                if lutenb
                    obj.outZCount(:)=1;
                end

                y=cast(obj.outWrData&obj.LUTData,'like',obj.outWrData);
            else
                obj.outWrData(:)=data(obj.outZCount);

                if valid
                    if(obj.outZCount==cast(liftsize,'like',obj.outZCount))
                        lutenb=true;
                    else
                        obj.outZCount(:)=obj.outZCount+1;
                        lutenb=false;
                    end
                else
                    lutenb=false;
                end

                if lutenb
                    obj.outZCount(:)=1;
                end

                y=cast(obj.outWrData,'like',obj.outWrData);
            end

        end

        function num=getNumInputsImpl(obj)
            if strcmpi(obj.SpecifyInputs,'Input port')
                num=11;
            else
                num=10;
            end
        end

        function num=getNumOutputsImpl(obj)
            if strcmpi(obj.Termination,'Early')
                num=4;
            else
                num=3;
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked

                s.dataMemory=obj.dataMemory;
                s.checkMatrixLUT=obj.checkMatrixLUT;
                s.metricCalculator=obj.metricCalculator;
                s.finalDecision=obj.finalDecision;


                s.gamma=obj.gamma;
                s.validMC=obj.validMC;
                s.iterDone=obj.iterDone;
                s.resetDelay=obj.resetDelay;
                s.endInd=obj.endInd;
                s.numIter=obj.numIter;
                s.finalShifts=obj.finalShifts;
                s.resetD=obj.resetD;
                s.countLayer=obj.countLayer;
                s.iterCount=obj.iterCount;
                s.betaRead=obj.betaRead;
                s.iterInd=obj.iterInd;
                s.wrData=obj.wrData;
                s.wrEnb=obj.wrEnb;
                s.wrAddr=obj.wrAddr;
                s.rdAddr=obj.rdAddr;
                s.rdAddr1=obj.rdAddr1;
                s.rdAddrFinal=obj.rdAddrFinal;
                s.rdValid=obj.rdValid;
                s.enb=obj.enb;
                s.zCount=obj.zCount;
                s.wrCount=obj.wrCount;
                s.validDelay=obj.validDelay;
                s.rdenb=obj.rdenb;
                s.finalEnb=obj.finalEnb;
                s.layerDone=obj.layerDone;
                s.resetDelay1=obj.resetDelay1;
                s.rdCount=obj.rdCount;
                s.validCount=obj.validCount;
                s.validC=obj.validC;
                s.zCount1=obj.zCount1;
                s.rdFinEnb=obj.rdFinEnb;
                s.outZCount=obj.outZCount;
                s.outWrData=obj.outWrData;
                s.LUTData=obj.LUTData;
                s.outAddr=obj.outAddr;
                s.FData=obj.FData;
                s.decBits=obj.decBits;
                s.noOp=obj.noOp;
                s.colCount=obj.colCount;
                s.rdEnb=obj.rdEnb;
                s.wrLUTAddr=obj.wrLUTAddr;
                s.rdLUTAddr=obj.rdLUTAddr;
                s.rdLUTAddr1=obj.rdLUTAddr1;
                s.initCount=obj.initCount;
                s.rdZCount=obj.rdZCount;
                s.rdValidReg=obj.rdValidReg;
                s.funcEnb=obj.funcEnb;


                s.fPChecks=obj.fPChecks;
                s.fPChecksD=obj.fPChecksD;
                s.earColCount=obj.earColCount;
                s.earLayCount=obj.earLayCount;
                s.earEnb=obj.earEnb;
                s.earEnbDelay=obj.earEnbDelay;
                s.checkFailed=obj.checkFailed;
                s.earEnbLayer=obj.earEnbLayer;
                s.earEnbLayerD=obj.earEnbLayerD;
                s.termPass=obj.termPass;
                s.termPassD=obj.termPassD;
                s.termPassD1=obj.termPassD1;
                s.termPassD2=obj.termPassD2;
                s.earPFCount=obj.earPFCount;


                s.dataOut=obj.dataOut;
                s.ctrlOut=obj.ctrlOut;
                s.iterOut=obj.iterOut;
                s.parCheck=obj.parCheck;

                s.dataOutReg=obj.dataOutReg;
                s.ctrlOutReg=obj.ctrlOutReg;
                s.iterOutReg=obj.iterOutReg;
                s.dataOutReg1=obj.dataOutReg1;
                s.ctrlOutReg1=obj.ctrlOutReg1;
                s.iterOutReg1=obj.iterOutReg1;

                s.delayBalancer1=obj.delayBalancer1;
                s.delayBalancer2=obj.delayBalancer2;
                s.delayBalancer3=obj.delayBalancer3;
                s.delayBalancer4=obj.delayBalancer4;
                s.delayBalancer5=obj.delayBalancer5;
                s.delayBalancer6=obj.delayBalancer6;

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
