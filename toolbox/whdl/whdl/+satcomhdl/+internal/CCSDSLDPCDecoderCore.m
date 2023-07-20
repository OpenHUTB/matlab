classdef(StrictDefaults)CCSDSLDPCDecoderCore<matlab.System





%#codegen

    properties(Nontunable)
        LDPCConfiguration='(8160,7136) LDPC';
        Termination='Max';
        alphaWL=6;
        alphaFL=0;
        betaWL=4;
        minWL=3;
        betaCompWL=32;
        betaIdxWL=8;
        ParityCheckStatus(1,1)logical=false;
    end

    properties(Nontunable,Access=private)
        scalarFlag;
        memDepth;
        outLenLUT;
        nRowLUT;
    end


    properties(Access=private)


        variableNodeRAM;
        checkMatrixLUT;
        metricCalculator;
        variableColRAM;
        variableWrEnbRAM;
        finalOutput;


        gammaOut;
        gValid;
        gValidReg;
        endInd;
        shiftVal;
        wrAddrV;
        rdValidV;
        rdAddrV;
        gAddr;
        colVal;
        gWrEnable;
        gRdEnable;
        wrEnable;
        rdEnable;
        rdValidOut;
        betaDecomp1;
        betaDecomp2;
        betaDecomp3;
        betaDecomp4;
        betaValid;
        eraseData;
        eraseCol;
        eraseAddr;


        wrData;
        wrAddr;
        wrEnb;
        rdValid;
        noOp;
        dataSel;
        countLayer;
        layerDone;
        iterCount;
        betaRead;
        iterDone;
        zCount;
        wrAddrEnb;
        idxCount;
        wrCount;
        validCount;
        rdEnb;
        countIdx;
        finalEnb;
        rdFinEnb;
        fCount;
        rdAddrFinal;


        termPass;
        fPChecks;
        fPChecksD;
        eColCount;
        eLayCount;
        eEnb;
        eEnbDelay;
        checkFailed;
        eEnbLayer;
        eEnbLayerD;
        termPassD;


        delayBalancer1;
        delayBalancer2;
        delayBalancer3;
        betaDelayBalancer1;
        betaDelayBalancer2;
        betaDelayBalancer3;
        betaDelayBalancer4;
        betaDelayBalancer5;


        dataOut;
        ctrlOut;
        iterOut;
        parCheck;

    end

    properties(Constant,Hidden)
        LDPCConfigurationSet=matlab.system.StringSet({'(8160,7136) LDPC','AR4JA LDPC'});
        TerminationSet=matlab.system.StringSet({'Max','Early'});
    end

    methods

        function obj=CCSDSLDPCDecoderCore(varargin)
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

            reset(obj.variableNodeRAM);
            reset(obj.checkMatrixLUT);
            reset(obj.metricCalculator);
            reset(obj.variableColRAM);
            reset(obj.variableWrEnbRAM);
            reset(obj.finalOutput);

            if obj.scalarFlag
                obj.dataOut(:)=zeros(1,1);
            else
                obj.dataOut(:)=zeros(8,1);
            end

            obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
            obj.iterOut(:)=uint8(0);
            obj.parCheck(:)=false;
        end

        function setupImpl(obj,varargin)
            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                obj.memDepth=64;
            else
                obj.memDepth=128;
            end

            if isscalar(varargin{1})
                obj.scalarFlag=true;
                obj.outLenLUT=fi([1024;4096;16384;16384],0,15,0);
            else
                obj.scalarFlag=false;
                obj.outLenLUT=fi([128;512;2048;2048],0,12,0);
            end



            obj.variableNodeRAM=hdl.RAM('RAMType','Simple dual port');


            obj.checkMatrixLUT=satcomhdl.internal.CCSDSLDPCCheckMatrixLUT('LDPCConfiguration',obj.LDPCConfiguration);


            obj.metricCalculator=satcomhdl.internal.CCSDSLDPCMetricCalculator('alphaWL',obj.alphaWL,'alphaFL',obj.alphaFL,...
            'betaWL',obj.betaWL,'minWL',obj.minWL,'betaCompWL',obj.betaCompWL,...
            'betaIdxWL',obj.betaIdxWL,'memDepth',obj.memDepth);


            obj.variableColRAM=hdl.RAM('RAMType','Simple dual port');


            obj.variableWrEnbRAM=hdl.RAM('RAMType','Simple dual port');


            obj.finalOutput=satcomhdl.internal.CCSDSLDPCFinalOutput('LDPCConfiguration',obj.LDPCConfiguration,...
            'scalarFlag',obj.scalarFlag);

            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                vWL=6;vaddrWL=7;
                cWL=8;layWL=5;zWL=4;
                obj.idxCount=fi(19,0,vWL+1,0,hdlfimath);
                obj.countIdx=fi(56,0,vaddrWL,0,hdlfimath);
                if obj.scalarFlag
                    obj.fCount=fi(0,0,7,0,hdlfimath);
                else
                    obj.fCount=fi(0,0,4,0,hdlfimath);
                end
            else
                vWL=7;vaddrWL=6;
                cWL=9;layWL=8;zWL=5;
                obj.idxCount=fi(1,0,vWL+1,0,hdlfimath);
                obj.countIdx=fi(2,0,vaddrWL,0,hdlfimath);
                if~obj.scalarFlag
                    obj.fCount=fi(0,0,5,0,hdlfimath);
                else
                    obj.fCount=fi(0,0,8,0,hdlfimath);
                end
            end


            obj.gammaOut=fi(zeros(obj.memDepth,1),1,obj.alphaWL,obj.alphaFL);
            obj.gValid=false;
            obj.gValidReg=false;
            obj.endInd=false;
            obj.rdValidV=false;
            obj.gWrEnable=fi(zeros(obj.memDepth,1),0,1,0);
            obj.gRdEnable=fi(zeros(obj.memDepth,1),0,1,0);
            obj.wrEnable=zeros(obj.memDepth,1)>0;
            obj.rdEnable=zeros(obj.memDepth,1)>0;
            obj.rdValidOut=false;
            obj.betaDecomp1=fi(zeros(obj.memDepth,1),0,obj.betaCompWL,0);
            obj.betaDecomp2=fi(zeros(obj.memDepth,1),0,obj.betaCompWL,0);
            obj.betaDecomp3=fi(zeros(obj.memDepth,1),0,obj.betaIdxWL,0);
            obj.betaDecomp4=fi(zeros(obj.memDepth,1),0,2*obj.minWL,0);
            obj.betaValid=false;
            obj.shiftVal=fi(0,0,vWL,0);
            obj.wrAddrV=fi(0,0,vaddrWL,0,hdlfimath);
            obj.rdAddrV=fi(1,0,vaddrWL,0,hdlfimath);
            obj.gAddr=fi(0,0,cWL,0,hdlfimath);
            obj.colVal=fi(0,0,cWL,0,hdlfimath);
            obj.eraseData=fi(zeros(obj.memDepth,1),1,obj.alphaWL,obj.alphaFL);
            obj.eraseCol=false;
            obj.eraseAddr=fi(0,0,cWL,0,hdlfimath);


            obj.wrData=fi(zeros(obj.memDepth,1),1,obj.alphaWL,obj.alphaFL);
            obj.wrEnb=zeros(obj.memDepth,1)>0;
            obj.rdValid=false;
            obj.noOp=false;
            obj.dataSel=false;
            obj.layerDone=false;
            obj.betaRead=false;
            obj.iterDone=false;
            obj.wrAddrEnb=false;
            obj.rdEnb=false;
            obj.finalEnb=false;
            obj.rdFinEnb=false;
            obj.iterCount=fi(0,0,8,0,hdlfimath);
            obj.wrAddr=fi(0,0,cWL,0,hdlfimath);
            obj.countLayer=fi(1,0,layWL,0,hdlfimath);
            obj.zCount=fi(0,0,zWL,0,hdlfimath);
            obj.wrCount=fi(0,0,cWL,0,hdlfimath);
            obj.validCount=fi(1,0,vaddrWL,0,hdlfimath);
            obj.rdAddrFinal=fi(0,0,cWL,0,hdlfimath);


            obj.termPass=false;
            obj.fPChecks=zeros(obj.memDepth,1)>0;
            obj.fPChecksD=zeros(obj.memDepth,1)>0;
            obj.eEnb=false;
            obj.eEnbDelay=false;
            obj.checkFailed=false;
            obj.eEnbLayer=false;
            obj.eEnbLayerD=false;
            obj.termPassD=false;
            obj.eColCount=fi(0,0,cWL,0,hdlfimath);
            obj.eLayCount=fi(0,0,layWL,0,hdlfimath);


            if obj.scalarFlag
                obj.dataOut=zeros(1,1)>0;
            else
                obj.dataOut=zeros(8,1)>0;
            end
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.iterOut=uint8(0);
            obj.parCheck=false;


            obj.delayBalancer1=dsp.Delay(2);
            obj.delayBalancer2=dsp.Delay(obj.memDepth*2);
            obj.delayBalancer3=dsp.Delay(1);
            obj.betaDelayBalancer1=dsp.Delay(obj.memDepth*2);
            obj.betaDelayBalancer2=dsp.Delay(obj.memDepth*2);
            obj.betaDelayBalancer3=dsp.Delay(obj.memDepth*2);
            obj.betaDelayBalancer4=dsp.Delay(obj.memDepth*2);
            obj.betaDelayBalancer5=dsp.Delay(2);

            obj.nRowLUT=fi([12,12,12,12,48,24,12,12,192,96,48,48,192,96,48,48]-1,0,8,0);

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.ctrlOut;
            varargout{3}=obj.iterOut;
            varargout{4}=obj.parCheck;
        end

        function updateImpl(obj,varargin)

            data=varargin{1};
            valid=varargin{2};
            framevalid=varargin{3};
            reset=varargin{4};
            endind=varargin{5};
            numiter=varargin{6};
            blocklen=varargin{7};
            coderate=varargin{8};

            data_mc=obj.gammaOut;
            valid_mc=obj.gValid;
            gaddr=obj.gAddr;

            if strcmpi(obj.Termination,'Early')
                termpass=obj.termPass;
            else
                termpass=false;
            end

            layerdone=(~valid_mc)&&obj.gValidReg;
            obj.gValidReg(:)=obj.gValid;

            softreset=endind&&(~obj.endInd);
            obj.endInd(:)=endind;


            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                gwrenable=obj.gWrEnable;
                [wr_data,wr_addr,wr_enb,rd_valid,countidx,iterdone,betaread,layeridx,...
                validcount,rdout_addr,rdout_valid,iterout]=iterationLayerControllerBASE(obj,data,valid,...
                framevalid,reset,softreset,data_mc,valid_mc,gaddr,gwrenable,layerdone,numiter,termpass);
            else
                gwrenable=obj.gRdEnable;
                [wr_data,wr_addr,wr_enb,rd_valid,countidx,iterdone,betaread,layeridx,...
                validcount,rdout_addr,rdout_valid,iterout,itercount]=iterationLayerControllerAR4JA(obj,data,valid,...
                framevalid,reset,softreset,blocklen,coderate,data_mc,valid_mc,gaddr,gwrenable,layerdone,...
                numiter,termpass);
            end

            int_reset=softreset||reset;


            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                [colval,shift,rdenb,wrenb]=obj.checkMatrixLUT(blocklen,coderate,layeridx,validcount);
            else
                [colval,shift,rdenb,erasecol]=obj.checkMatrixLUT(blocklen,coderate,layeridx,validcount);
            end

            rd_valid_reg=obj.delayBalancer1(rd_valid);
            obj.rdEnable(:)=obj.delayBalancer2(rdenb);


            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                wrdata_ram=wr_data;
                wraddr_ram=wr_addr;
                wrenb_ram=wr_enb;
            else
                iterind=itercount>0;
                if(obj.eraseCol&&~iterind)
                    wrdata_ram=cast(zeros(obj.memDepth,1),'like',wr_data);
                    wrenb_ram=ones(obj.memDepth,1)>0;
                    wraddr_ram=obj.eraseAddr;
                else
                    wrdata_ram=wr_data;
                    wraddr_ram=wr_addr;
                    wrenb_ram=wr_enb;
                end
            end

            if iterdone
                rdaddr_ram=cast(rdout_addr,'like',colval);
            else
                rdaddr_ram=cast(colval,'like',colval);
            end

            obj.eraseAddr(:)=rdaddr_ram;

            rd_addrD=rdaddr_ram*uint8(ones(obj.memDepth,1));
            wr_addrD=wraddr_ram*uint8(ones(obj.memDepth,1));


            coldata=obj.variableNodeRAM(wrdata_ram,wr_addrD,wrenb_ram,rd_addrD);

            if blocklen==0&&coderate==1
                shiftsel=fi(1,0,2,0);
            elseif blocklen==0&&coderate==2
                shiftsel=fi(2,0,2,0);
            else
                shiftsel=fi(0,0,2,0);
            end

            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                obj.eraseData(:)=coldata;
            else
                if(obj.eraseCol&&~iterind)
                    obj.eraseData(:)=zeros(obj.memDepth,1);
                else
                    obj.eraseData(:)=coldata;
                end
                obj.eraseCol(:)=erasecol;
            end


            [gamma,gammavalid,gdata,grdenb]=obj.metricCalculator(obj.eraseData,rd_valid_reg,...
            obj.shiftVal,countidx,betaread,obj.rdEnable,layeridx,int_reset,shiftsel);
            obj.shiftVal(:)=shift;
            obj.gammaOut(:)=gamma;
            obj.gValid(:)=gammavalid;
            obj.gRdEnable(:)=grdenb;


            [wr_addr_v,rd_addr_v]=addressGeneration(obj,rd_valid_reg,countidx,obj.gValid,int_reset);


            obj.gAddr(:)=obj.variableColRAM(obj.colVal,wr_addr_v,rd_valid_reg,rd_addr_v);
            obj.colVal(:)=colval;

            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')

                obj.gWrEnable(:)=obj.variableWrEnbRAM(fi(obj.wrEnable,0,1,0),wr_addr_v,rd_valid_reg,rd_addr_v);
                obj.wrEnable(:)=wrenb;
                nrow=fi(15,0,5,0);
            else
                addridx=bitconcat(fi(blocklen,0,2,0),fi(coderate,0,2,0));
                nrow=obj.nRowLUT(addridx+1);
            end



            if strcmpi(obj.Termination,'Early')||obj.ParityCheckStatus
                obj.termPass(:)=earlyTermination(obj,int_reset,gdata,gammavalid,countidx,grdenb,nrow);
            end


            outlen=obj.outLenLUT(blocklen+1);
            datai=coldata<=0;

            [data_out,ctrl_out]=obj.finalOutput(int_reset,iterdone,obj.rdValidOut,datai,outlen,shiftsel);
            obj.rdValidOut(:)=rdout_valid;

            obj.dataOut(:)=data_out;
            obj.ctrlOut(:)=ctrl_out;

            if ctrl_out.valid
                obj.iterOut(:)=iterout;
                obj.parCheck(:)=obj.termPass;
            else
                if obj.scalarFlag
                    obj.dataOut(:)=0;
                else
                    obj.dataOut(:)=zeros(8,1);
                end
                obj.iterOut(:)=0;
                obj.parCheck(:)=false;
            end
        end

        function[wr_data,wr_addr,wr_enb,rd_valid,count,iterdone,betaread,layeridx,...
            validcount,rd_addr,rd_out_valid,iterout]=iterationLayerControllerBASE(obj,data,...
            valid,framevalid,reset,softreset,gamma,gvalid,gaddr,gwrenable,layerdone,numiter,termpass)

            nonZCount=fi([56,56,56,56,56,56,56,56,63,63,63,63,64,63,63,62]-1,0,7,0);
            obj.layerDone(:)=layerdone;


            wr_data=obj.wrData;
            wr_addr=obj.wrAddr;
            wr_enb=obj.wrEnb;
            rd_valid=obj.rdValid;
            layeridx=obj.countLayer;
            betaread=obj.betaRead;
            iterdone=obj.iterDone;
            count=obj.countIdx;
            validcount=obj.validCount;
            rd_out_valid=obj.rdFinEnb;
            rd_addr=obj.rdAddrFinal;

            if strcmpi(obj.Termination,'Early')
                if termpass
                    iterout=uint8(obj.iterCount+1);
                else
                    iterout=uint8(numiter);
                end
            else
                iterout=uint8(numiter);
            end

            if reset
                obj.noOp(:)=true;
            elseif softreset
                obj.noOp(:)=false;
            end



            if obj.noOp
                obj.dataSel(:)=logical(false);
            else
                obj.dataSel(:)=logical((framevalid));
            end


            if reset
                obj.iterDone(:)=false;
                obj.countLayer(:)=1;
                obj.iterCount(:)=0;
                obj.betaRead(:)=false;
                resetcount=true;
            else
                if(obj.iterCount==fi(numiter,0,8,0)||termpass)
                    obj.iterDone(:)=true;
                    resetcount=true;
                else
                    obj.iterDone(:)=false;
                    if obj.layerDone&&obj.dataSel
                        if obj.countLayer==fi(16,0,5,0)
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




            if reset
                obj.wrAddr(:)=1;
                obj.wrEnb(:)=ones(64,1);
                obj.wrData(:)=zeros(64,1);
                obj.rdValid(:)=false;
                obj.zCount(:)=0;
                obj.wrAddrEnb(:)=0;
                obj.idxCount(:)=19;
                obj.wrCount(:)=1;
            else


                if~obj.dataSel
                    if valid

                        if~obj.scalarFlag
                            if obj.zCount==fi(8,0,4,0)
                                obj.zCount(:)=1;
                                obj.wrAddrEnb(:)=true;
                            else
                                obj.zCount(:)=obj.zCount+1;
                                obj.wrAddrEnb(:)=false;
                            end

                            if obj.wrAddrEnb
                                obj.wrAddr(:)=obj.wrAddr+1;
                            end

                            if obj.zCount==1
                                obj.wrEnb(:)=[ones(8,1);zeros(56,1)]>0;
                                obj.wrData(:)=[data;zeros(56,1)];
                            elseif obj.zCount==2
                                obj.wrEnb(:)=[zeros(8,1);ones(8,1);zeros(48,1)]>0;
                                obj.wrData(:)=[zeros(8,1);data;zeros(48,1)];
                            elseif obj.zCount==3
                                obj.wrEnb(:)=[zeros(16,1);ones(8,1);zeros(40,1)]>0;
                                obj.wrData(:)=[zeros(16,1);data;zeros(40,1)];
                            elseif obj.zCount==4
                                obj.wrEnb(:)=[zeros(24,1);ones(8,1);zeros(32,1)]>0;
                                obj.wrData(:)=[zeros(24,1);data;zeros(32,1)];
                            elseif obj.zCount==5
                                obj.wrEnb(:)=[zeros(32,1);ones(8,1);zeros(24,1)]>0;
                                obj.wrData(:)=[zeros(32,1);data;zeros(24,1)];
                            elseif obj.zCount==6
                                obj.wrEnb(:)=[zeros(40,1);ones(8,1);zeros(16,1)]>0;
                                obj.wrData(:)=[zeros(40,1);data;zeros(16,1)];
                            elseif obj.zCount==7
                                obj.wrEnb(:)=[zeros(48,1);ones(8,1);zeros(8,1)]>0;
                                obj.wrData(:)=[zeros(48,1);data;zeros(8,1)];
                            elseif obj.zCount==8
                                obj.wrEnb(:)=[zeros(56,1);ones(8,1)]>0;
                                obj.wrData(:)=[zeros(56,1);data;];
                            else
                                obj.wrEnb(:)=zeros(64,1)>0;
                                obj.wrData(:)=zeros(64,1);
                            end
                        else

                            for idx=1:64
                                if obj.idxCount==fi(idx,0,7,0)
                                    obj.wrEnb(idx)=true;
                                    obj.wrData(idx)=data;
                                else
                                    obj.wrEnb(idx)=false;
                                    obj.wrData(idx)=0;
                                end
                            end
                            obj.wrAddr(:)=obj.wrCount;
                            if mod(obj.wrCount,fi(8,0,4,0))==0
                                wMaxCount=fi(63,0,7,0);
                            else
                                wMaxCount=fi(64,0,7,0);
                            end

                            if obj.idxCount==wMaxCount
                                obj.idxCount(:)=1;
                                obj.wrCount(:)=obj.wrCount+1;
                            else
                                obj.idxCount(:)=obj.idxCount+1;
                            end
                        end
                    else
                        obj.wrEnb(:)=zeros(64,1)>0;
                        obj.wrData(:)=zeros(64,1);
                    end
                else
                    if gvalid
                        obj.wrData(:)=gamma;
                        obj.wrAddr(:)=gaddr;
                        obj.wrEnb(:)=gwrenable;
                    else
                        obj.wrEnb(:)=zeros(64,1)>0;
                        obj.wrData(:)=zeros(64,1);
                        obj.wrAddr(:)=0;
                    end
                end
            end







            maxCount=fi(113,0,8,0,hdlfimath);
            obj.countIdx(:)=nonZCount(obj.countLayer);
            trigger=softreset||obj.layerDone;

            if reset
                obj.validCount(:)=0;
            else
                if obj.rdEnb&&obj.dataSel
                    if obj.validCount==obj.countIdx
                        obj.validCount(:)=0;
                        obj.rdEnb(:)=false;
                    else
                        obj.validCount(:)=obj.validCount+1;
                    end
                else
                    obj.validCount(:)=0;
                end
            end


            if reset
                obj.rdEnb(:)=false;
            else
                if trigger&&~obj.iterDone&&obj.dataSel
                    obj.rdEnb(:)=true;
                else
                    if obj.iterDone
                        obj.rdEnb(:)=false;
                    end
                end
            end

            obj.rdValid(:)=obj.rdEnb;

            if obj.iterDone
                obj.finalEnb(:)=true;
            end

            if~obj.scalarFlag
                fMaxCount=fi(7,0,4,0);
            else
                if mod(obj.rdAddrFinal,fi(8,0,4,0))==0
                    fMaxCount=fi(62,0,7,0);
                else
                    fMaxCount=fi(63,0,7,0);
                end
            end

            if softreset
                obj.fCount(:)=0;
                obj.rdFinEnb(:)=false;
            else
                if obj.fCount==fMaxCount
                    obj.fCount(:)=0;
                    obj.rdFinEnb(:)=true;
                else
                    if obj.finalEnb
                        obj.fCount(:)=obj.fCount+1;
                    end
                    obj.rdFinEnb(:)=false;
                end
            end

            if softreset
                obj.rdAddrFinal(:)=0;
                obj.finalEnb(:)=false;
            else
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
            end
        end

        function[wr_data,wr_addr,wr_enb,rd_valid,count,iterdone,betaread,layeridx,...
            validcount,rd_addr,rd_out_valid,iterout,itercount]=iterationLayerControllerAR4JA(obj,data,valid,...
            framevalid,reset,softreset,blocklen,coderate,gamma,gvalid,gaddr,gwrenable,layerdone,numiter,termpass)

            initCountLUT=fi([0;12;24;24;36;84;108;108;120;312;408;408;408;408;408;408],0,9,0);
            nonZCountLUT=fi([3;3;3;3;6;6;6;6;6;6;6;6;3;3;3;3;10;10;10;10;10;10;10;10;3;3;3;3;18;18;18;18;18;18;18;18;...
            4;4;4;4;3;3;3;3;3;3;3;3;3;3;3;3;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;10;10;10;10;10;10;10;10;...
            10;10;10;10;10;10;10;10;4;4;3;3;3;3;3;3;16;16;16;16;16;16;16;16;17;17;17;17;17;17;17;17;...
            3;3;3;3;18;18;18;18;18;18;18;18;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;3;3;3;3;...
            3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;9;9;9;9;9;9;9;9;...
            9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;9;...
            9;9;9;9;9;9;9;9;9;9;9;9;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;...
            10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;10;...
            10;10;10;10;10;10;10;10;10;10;10;10;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;...
            3;3;3;3;3;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;...
            16;16;16;16;16;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;17;...
            17;17;17;17;17;17;17;4;4;4;4;3;3;3;3;3;3;3;3;3;3;3;3;30;30;30;30;30;30;30;30;30;30;30;30;30;...
            30;30;30;31;31;31;31;31;31;31;31;31;31;31;31;31;31;31;31]-1,0,5,0);
            nLayersLUT=fi([12,12,12,12,48,24,12,12,192,96,48,48,48,48,48],0,8,0);
            maxCountLUT=fi([8,16,32,32,32,32,32,32,128,128,128,128,128,128,128,128],0,9,0);
            wrInitCountLUT=fi([17,25,41,41,65,49,41,41,257,193,161,161,257,193,161,161],0,9,0);
            wrMaxCountLUT=fi([20,28,44,44,80,56,44,44,320,224,176,176,320,224,176,176],0,9,0);

            addrIdx=fi(bitconcat(blocklen,coderate)+1,0,4,0);

            nRow=nLayersLUT(addrIdx);
            initCount=initCountLUT(addrIdx);
            maxCount=maxCountLUT(addrIdx);
            wrInitCount=wrInitCountLUT(addrIdx);
            wrDepCount=wrMaxCountLUT(addrIdx);

            obj.layerDone(:)=layerdone;


            wr_data=obj.wrData;
            wr_addr=obj.wrAddr;
            wr_enb=obj.wrEnb;
            rd_valid=obj.rdValid;
            layeridx=obj.countLayer;
            betaread=obj.betaRead;
            iterdone=obj.iterDone;
            count=obj.countIdx;
            validcount=obj.validCount;
            rd_out_valid=obj.rdFinEnb;
            rd_addr=obj.rdAddrFinal;
            itercount=obj.iterCount;

            if strcmpi(obj.Termination,'Early')
                if termpass
                    iterout=uint8(obj.iterCount+1);
                else
                    iterout=uint8(numiter);
                end
            else
                iterout=uint8(numiter);
            end

            if reset
                obj.noOp(:)=true;
            elseif softreset
                obj.noOp(:)=false;
            end



            if obj.noOp
                obj.dataSel(:)=logical(false);
            else
                obj.dataSel(:)=logical((framevalid));
            end


            if reset
                obj.iterDone(:)=false;
                obj.countLayer(:)=1;
                obj.iterCount(:)=0;
                obj.betaRead(:)=false;
                resetcount=true;
            else
                if(obj.iterCount==fi(numiter,0,8,0)||termpass)
                    obj.iterDone(:)=true;
                    resetcount=true;
                else
                    obj.iterDone(:)=false;
                    if obj.layerDone&&obj.dataSel
                        if obj.countLayer==nRow
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

            if blocklen==0&&coderate==1
                maxZCount=fi(8,0,5,0);
                wMaxCount=fi(64,0,8,0);
            elseif blocklen==0&&coderate==2
                maxZCount=fi(4,0,5,0);
                wMaxCount=fi(32,0,8,0);
            else
                maxZCount=fi(16,0,5,0);
                wMaxCount=fi(128,0,8,0);
            end




            if reset
                obj.wrAddr(:)=1;
                obj.wrEnb(:)=ones(128,1);
                obj.wrData(:)=zeros(128,1);
                obj.rdValid(:)=false;
                obj.zCount(:)=0;
                obj.wrAddrEnb(:)=0;
                obj.idxCount(:)=1;
                obj.wrCount(:)=1;
            else


                if~obj.dataSel
                    if valid

                        if~obj.scalarFlag
                            if obj.zCount==maxZCount
                                obj.zCount(:)=1;
                                obj.wrAddrEnb(:)=true;
                            else
                                obj.zCount(:)=obj.zCount+1;
                                obj.wrAddrEnb(:)=false;
                            end

                            if obj.wrAddrEnb
                                obj.wrAddr(:)=obj.wrAddr+1;
                            end

                            if obj.zCount==1
                                obj.wrEnb(:)=[ones(8,1);zeros(120,1)]>0;
                                obj.wrData(:)=[data;zeros(120,1)];
                            elseif obj.zCount==2
                                obj.wrEnb(:)=[zeros(8,1);ones(8,1);zeros(112,1)]>0;
                                obj.wrData(:)=[zeros(8,1);data;zeros(112,1)];
                            elseif obj.zCount==3
                                obj.wrEnb(:)=[zeros(16,1);ones(8,1);zeros(104,1)]>0;
                                obj.wrData(:)=[zeros(16,1);data;zeros(104,1)];
                            elseif obj.zCount==4
                                obj.wrEnb(:)=[zeros(24,1);ones(8,1);zeros(96,1)]>0;
                                obj.wrData(:)=[zeros(24,1);data;zeros(96,1)];
                            elseif obj.zCount==5
                                obj.wrEnb(:)=[zeros(32,1);ones(8,1);zeros(88,1)]>0;
                                obj.wrData(:)=[zeros(32,1);data;zeros(88,1)];
                            elseif obj.zCount==6
                                obj.wrEnb(:)=[zeros(40,1);ones(8,1);zeros(80,1)]>0;
                                obj.wrData(:)=[zeros(40,1);data;zeros(80,1)];
                            elseif obj.zCount==7
                                obj.wrEnb(:)=[zeros(48,1);ones(8,1);zeros(72,1)]>0;
                                obj.wrData(:)=[zeros(48,1);data;zeros(72,1)];
                            elseif obj.zCount==8
                                obj.wrEnb(:)=[zeros(56,1);ones(8,1);zeros(64,1)]>0;
                                obj.wrData(:)=[zeros(56,1);data;zeros(64,1)];
                            elseif obj.zCount==9
                                obj.wrEnb(:)=[zeros(64,1);ones(8,1);zeros(56,1)]>0;
                                obj.wrData(:)=[zeros(64,1);data;zeros(56,1)];
                            elseif obj.zCount==10
                                obj.wrEnb(:)=[zeros(72,1);ones(8,1);zeros(48,1)]>0;
                                obj.wrData(:)=[zeros(72,1);data;zeros(48,1)];
                            elseif obj.zCount==11
                                obj.wrEnb(:)=[zeros(80,1);ones(8,1);zeros(40,1)]>0;
                                obj.wrData(:)=[zeros(80,1);data;zeros(40,1)];
                            elseif obj.zCount==12
                                obj.wrEnb(:)=[zeros(88,1);ones(8,1);zeros(32,1)]>0;
                                obj.wrData(:)=[zeros(88,1);data;zeros(32,1)];
                            elseif obj.zCount==13
                                obj.wrEnb(:)=[zeros(96,1);ones(8,1);zeros(24,1)]>0;
                                obj.wrData(:)=[zeros(96,1);data;zeros(24,1)];
                            elseif obj.zCount==14
                                obj.wrEnb(:)=[zeros(104,1);ones(8,1);zeros(16,1)]>0;
                                obj.wrData(:)=[zeros(104,1);data;zeros(16,1)];
                            elseif obj.zCount==15
                                obj.wrEnb(:)=[zeros(112,1);ones(8,1);zeros(8,1)]>0;
                                obj.wrData(:)=[zeros(112,1);data;zeros(8,1)];
                            elseif obj.zCount==16
                                obj.wrEnb(:)=[zeros(120,1);ones(8,1)]>0;
                                obj.wrData(:)=[zeros(120,1);data;];
                            else
                                obj.wrEnb(:)=zeros(128,1)>0;
                                obj.wrData(:)=zeros(128,1);
                            end
                        else

                            for idx=1:128
                                if obj.idxCount==fi(idx,0,8,0)
                                    obj.wrEnb(idx)=true;
                                    obj.wrData(idx)=data;
                                else
                                    obj.wrEnb(idx)=false;
                                    obj.wrData(idx)=0;
                                end
                            end
                            obj.wrAddr(:)=obj.wrCount;
                            if obj.idxCount==wMaxCount
                                obj.idxCount(:)=1;
                                obj.wrCount(:)=obj.wrCount+1;
                            else
                                obj.idxCount(:)=obj.idxCount+1;
                            end
                        end
                    else
                        obj.wrEnb(:)=zeros(128,1)>0;
                        obj.wrData(:)=zeros(128,1);
                    end
                else
                    if gvalid
                        obj.wrData(:)=gamma;
                        obj.wrAddr(:)=gaddr;
                        if blocklen==0&&coderate==1
                            obj.wrEnb(:)=[ones(64,1);zeros(64,1)]>0;
                        elseif blocklen==0&&coderate==2
                            obj.wrEnb(:)=[ones(32,1);zeros(32,1);zeros(32,1);zeros(32,1)]>0;
                        else
                            for idx=1:128
                                obj.wrEnb(idx)=gwrenable(129-idx)>0;
                            end
                        end
                    else
                        obj.wrEnb(:)=zeros(128,1)>0;
                        obj.wrData(:)=zeros(128,1);
                        obj.wrAddr(:)=0;
                    end
                end
            end







            obj.countIdx(:)=nonZCountLUT(initCount+obj.countLayer);
            trigger=softreset||obj.layerDone;

            if reset
                obj.validCount(:)=0;
            else
                if obj.rdEnb&&obj.dataSel
                    if obj.validCount==obj.countIdx
                        obj.validCount(:)=0;
                        obj.rdEnb(:)=false;
                    else
                        obj.validCount(:)=obj.validCount+1;
                    end
                else
                    obj.validCount(:)=0;
                end
            end


            if reset
                obj.rdEnb(:)=false;
            else
                if trigger&&~obj.iterDone&&obj.dataSel
                    obj.rdEnb(:)=true;
                else
                    if obj.iterDone
                        obj.rdEnb(:)=false;
                    end
                end
            end

            obj.rdValid(:)=obj.rdEnb;

            if obj.iterDone
                obj.finalEnb(:)=true;
            end

            if~obj.scalarFlag
                fMaxCount=cast(maxZCount,'like',maxZCount);
            else
                fMaxCount=cast(wMaxCount,'like',wMaxCount);
            end

            if softreset
                obj.fCount(:)=0;
                obj.rdFinEnb(:)=false;
            else
                if obj.fCount==fMaxCount
                    obj.fCount(:)=1;
                    obj.rdFinEnb(:)=true;
                else
                    if obj.finalEnb
                        obj.fCount(:)=obj.fCount+1;
                    end
                    obj.rdFinEnb(:)=false;
                end
            end

            if softreset
                obj.finalEnb(:)=false;
                obj.rdAddrFinal(:)=0;
            else
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
            end
        end

        function[wr_addr,rd_addr]=addressGeneration(obj,wr_valid,count,rd_valid,reset)


            if obj.rdAddrV==count+1
                int_reset=true;
            else
                int_reset=false;
            end
            rst=reset||int_reset;

            if rst
                obj.rdValidV(:)=false;
            else
                if rd_valid
                    obj.rdValidV(:)=true;
                else
                    if obj.rdAddrV==count+1
                        obj.rdValidV(:)=false;
                    end
                end
            end


            if rst
                obj.wrAddrV(:)=0;
            else
                if wr_valid
                    obj.wrAddrV(:)=obj.wrAddrV+1;
                end
            end


            if rst
                obj.rdAddrV(:)=1;
            else
                if obj.rdValidV
                    obj.rdAddrV(:)=obj.rdAddrV+1;
                end
            end

            wr_addr=obj.wrAddrV;
            rd_addr=obj.rdAddrV;
        end

        function termpass=earlyTermination(obj,reset,gamma,valid,countidx,rdenb,nrow)

            hardDec=gamma<=0;

            if reset
                obj.fPChecks(:)=zeros(obj.memDepth,1);
            else
                if valid
                    for idx=1:obj.memDepth
                        if hardDec(idx)&&rdenb(idx)
                            obj.fPChecks(idx)=~obj.fPChecks(idx);
                        end
                    end
                else
                    obj.fPChecks(:)=zeros(obj.memDepth,1);
                end
            end


            if reset
                obj.eColCount(:)=0;
                obj.eLayCount(:)=0;
                obj.eEnb(:)=false;
                obj.eEnbLayer(:)=false;
            else
                if valid
                    if obj.eColCount==countidx
                        obj.eColCount(:)=0;
                        obj.eEnb(:)=true;
                        if obj.eLayCount==nrow
                            obj.eLayCount(:)=0;
                            obj.eEnbLayer(:)=true;
                        else
                            obj.eLayCount(:)=obj.eLayCount+1;
                        end
                    else
                        obj.eColCount(:)=obj.eColCount+1;
                        obj.eEnb(:)=false;
                    end
                else
                    obj.eEnb(:)=false;
                    obj.eEnbLayer(:)=false;
                end
            end

            if obj.eEnbDelay
                if~obj.checkFailed
                    for idx=1:obj.memDepth
                        if(obj.fPChecksD(idx)==1)
                            obj.checkFailed(:)=true;
                        end
                    end
                end
            end

            obj.eEnbDelay(:)=obj.eEnb;
            obj.fPChecksD(:)=obj.fPChecks;

            if reset
                obj.termPassD(:)=false;
                obj.checkFailed(:)=false;
            elseif obj.eEnbLayerD
                obj.termPassD(:)=~obj.checkFailed;
                if obj.eLayCount==0
                    obj.checkFailed(:)=false;
                end
            end

            obj.eEnbLayerD(:)=obj.eEnbLayer;

            if reset
                termpass=false;
            else
                termpass=obj.termPassD;
            end


        end

        function num=getNumInputsImpl(~)
            num=8;
        end

        function num=getNumOutputsImpl(~)
            num=4;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.alphaWL=obj.alphaWL;
                s.alphaFL=obj.alphaFL;
                s.LDPCConfiguration=obj.LDPCConfiguration;
                s.Termination=obj.Termination;
                s.betaWL=obj.betaWL;
                s.minWL=obj.minWL;
                s.betaCompWL=obj.betaCompWL;
                s.betaIdxWL=obj.betaIdxWL;
                s.ParityCheckStatus=obj.ParityCheckStatus;
                s.memDepth=obj.memDepth;
                s.scalarFlag=obj.scalarFlag;
                s.outLenLUT=obj.outLenLUT;
                s.nRowLUT=obj.nRowLUT;

                s.variableNodeRAM=obj.variableNodeRAM;
                s.checkMatrixLUT=obj.checkMatrixLUT;
                s.metricCalculator=obj.metricCalculator;
                s.variableColRAM=obj.variableColRAM;
                s.variableWrEnbRAM=obj.variableWrEnbRAM;
                s.finalOutput=obj.finalOutput;


                s.gammaOut=obj.gammaOut;
                s.gValid=obj.gValid;
                s.gValidReg=obj.gValidReg;
                s.endInd=obj.endInd;
                s.shiftVal=obj.shiftVal;
                s.wrAddrV=obj.wrAddrV;
                s.rdValidV=obj.rdValidV;
                s.rdAddrV=obj.rdAddrV;
                s.gAddr=obj.gAddr;
                s.colVal=obj.colVal;
                s.gRdEnable=obj.gRdEnable;
                s.gWrEnable=obj.gWrEnable;
                s.wrEnable=obj.wrEnable;
                s.rdEnable=obj.rdEnable;
                s.rdValidOut=obj.rdValidOut;
                s.betaDecomp1=obj.betaDecomp1;
                s.betaDecomp2=obj.betaDecomp2;
                s.betaDecomp3=obj.betaDecomp3;
                s.betaDecomp4=obj.betaDecomp4;
                s.betaValid=obj.betaValid;
                s.eraseData=obj.eraseData;
                s.eraseCol=obj.eraseCol;
                s.eraseAddr=obj.eraseAddr;


                s.wrData=obj.wrData;
                s.wrAddr=obj.wrAddr;
                s.wrEnb=obj.wrEnb;
                s.rdValid=obj.rdValid;
                s.noOp=obj.noOp;
                s.dataSel=obj.dataSel;
                s.countLayer=obj.countLayer;
                s.layerDone=obj.layerDone;
                s.iterCount=obj.iterCount;
                s.betaRead=obj.betaRead;
                s.iterDone=obj.iterDone;
                s.zCount=obj.zCount;
                s.wrAddrEnb=obj.wrAddrEnb;
                s.idxCount=obj.idxCount;
                s.wrCount=obj.wrCount;
                s.validCount=obj.validCount;
                s.rdEnb=obj.rdEnb;
                s.countIdx=obj.countIdx;
                s.finalEnb=obj.finalEnb;
                s.rdFinEnb=obj.rdFinEnb;
                s.fCount=obj.fCount;
                s.rdAddrFinal=obj.rdAddrFinal;


                s.termPass=obj.termPass;
                s.fPChecks=obj.fPChecks;
                s.fPChecksD=obj.fPChecksD;
                s.eColCount=obj.eColCount;
                s.eLayCount=obj.eLayCount;
                s.eEnb=obj.eEnb;
                s.eEnbDelay=obj.eEnbDelay;
                s.checkFailed=obj.checkFailed;
                s.eEnbLayer=obj.eEnbLayer;
                s.eEnbLayerD=obj.eEnbLayerD;
                s.termPassD=obj.termPassD;


                s.delayBalancer1=obj.delayBalancer1;
                s.delayBalancer2=obj.delayBalancer2;
                s.delayBalancer3=obj.delayBalancer3;
                s.betaDelayBalancer1=obj.betaDelayBalancer1;
                s.betaDelayBalancer2=obj.betaDelayBalancer2;
                s.betaDelayBalancer3=obj.betaDelayBalancer3;
                s.betaDelayBalancer4=obj.betaDelayBalancer4;
                s.betaDelayBalancer5=obj.betaDelayBalancer5;


                s.dataOut=obj.dataOut;
                s.ctrlOut=obj.ctrlOut;
                s.iterOut=obj.iterOut;
                s.parCheck=obj.parCheck;

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
