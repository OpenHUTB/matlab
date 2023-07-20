classdef(StrictDefaults)DVBS2LDPCDecoderCore<matlab.System





%#codegen

    properties(Nontunable)
        FECFrameSource='Input port';
        FECFrame='Normal';
        CodeRateSource='Property';
        CodeRateNormal='1/4';
        CodeRateShort='1/4';
        Termination='Max';
        ScalingFactor=1;
        alphaWL=6;
        alphaFL=0;
        betadecmpWL=36;
        degreeLUT=30;

        ParityCheckStatus(1,1)logical=false;
    end

    properties(Nontunable,Access=private)
        memDepth;
        maxData;
    end


    properties(Access=private)


        infoVNRAM;
        parityVNRAM;
        checkMatrixLUT;
        metricCalculator;
        vDInfoCol;
        vDParityCol;


        dataIn;
        validIn;
        frameValid;
        softReset;
        parInd;
        gParValid;
        gParValidReg;
        readAddrLUT;
        gammaOut;
        gammaValid;
        layerIdx;
        layerIdxReg;
        pValid;
        pValidReg;
        shiftVal;
        ddsmInd;
        delayBalancer1;
        delayBalancer2;
        delayBalancer3;
        degreeVal;
        degreeValTmp;
        degreeValTmp1;


        iValid;
        parValid;
        count;
        rdData;
        wrEn;
        rdDataE;


        countLayer;
        layerDone;
        iterDone;
        iwrAddr;
        iwrEnb;
        iwrData;
        ivalidCount;
        pwrAddr;
        pwrEnb;
        pwrData;
        pvalidCount;
        noOp;
        dataSel;
        icount;
        icolCount;
        iaCount;
        pcount;
        pcolCount;
        paCount;
        pqCount;
        pcountTmp;
        rdEnb;
        rdValid;
        parityRead;
        rdAddr;
        finalEnb;
        rdCount;
        betaRead;
        iterCount;
        termPass;
        termPassReg;


        rdValidR;
        countR;
        rdDataR;


        iwrAddrV;
        iwrValidV;
        irdAddrV;
        pwrAddrV;
        pwrValidV;
        prdAddrV;


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


        iterDoneF;
        dataOutF;
        startOutF;
        endOutF;
        validOutF;
        count8;
        count45;
        rdCountF;
readF
        startEnb;


        dataOut;
        ctrlOut;
        iterOut;
        parCheck;

    end

    properties(Constant,Hidden)
        FECFrameSourceSet=matlab.system.StringSet({'Input port','Property'});
        FECFrameSet=matlab.system.StringSet({'Normal','Short'});
        CodeRateSourceSet=matlab.system.StringSet({'Input port','Property'});
        CodeRateNormalSet=matlab.system.StringSet({'1/4','1/3','2/5','1/2','3/5','2/3','3/4','4/5','5/6','8/9','9/10'});
        CodeRateShortSet=matlab.system.StringSet({'1/4','1/3','2/5','1/2','3/5','2/3','3/4','4/5','5/6','8/9'});
        TerminationSet=matlab.system.StringSet({'Max','Early'});
    end

    methods

        function obj=DVBS2LDPCDecoderCore(varargin)
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


            reset(obj.infoVNRAM);
            reset(obj.parityVNRAM);
            reset(obj.checkMatrixLUT);
            reset(obj.metricCalculator);
            reset(obj.vDInfoCol);
            reset(obj.vDParityCol);
            reset(obj.delayBalancer1);
            reset(obj.delayBalancer2);
            reset(obj.delayBalancer3);

            obj.dataOut(:)=0;
            obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
            obj.iterOut(:)=uint8(0);
            obj.parCheck(:)=false;
        end

        function setupImpl(obj,varargin)

            obj.memDepth=45;
            obj.maxData=fi(2^(obj.alphaWL-1),1,obj.alphaWL,obj.alphaFL);




            obj.infoVNRAM=hdl.RAM('RAMType','Simple dual port');



            obj.parityVNRAM=hdl.RAM('RAMType','Simple dual port');



            obj.checkMatrixLUT=satcomhdl.internal.DVBS2LDPCCheckMatrixLUT('FECFrameSource',obj.FECFrameSource,...
            'FECFrame',obj.FECFrame,'CodeRateSource',obj.CodeRateSource,...
            'CodeRateNormal',obj.CodeRateNormal,'CodeRateShort',obj.CodeRateShort);


            obj.metricCalculator=satcomhdl.internal.DVBS2LDPCMetricCalculator('ScalingFactor',obj.ScalingFactor,...
            'alphaWL',obj.alphaWL,'alphaFL',obj.alphaFL,'betadecmpWL',obj.betadecmpWL,...
            'nLayers',1080);


            obj.vDInfoCol=hdl.RAM('RAMType','Simple dual port');
            obj.vDParityCol=hdl.RAM('RAMType','Simple dual port');

            obj.delayBalancer1=dsp.Delay(2);
            obj.delayBalancer2=dsp.Delay(2);
            obj.delayBalancer3=dsp.Delay(2);
            obj.degreeVal=fi(0,0,6,0);
            obj.degreeValTmp=fi(0,0,6,0);
            obj.degreeValTmp1=fi(0,0,6,0);

            obj.dataIn=fi(0,1,obj.alphaWL,obj.alphaFL);
            obj.validIn=false;
            obj.frameValid=false;
            obj.softReset=false;
            obj.parInd=false;
            obj.gParValid=false;
            obj.gParValidReg=false;
            obj.gammaOut=fi(zeros(obj.memDepth,1),1,obj.alphaWL,obj.alphaFL);
            obj.gammaValid=false;
            obj.layerIdx=fi(1,0,11,0);
            obj.layerIdxReg=fi(1,0,11,0);
            obj.pValid=false;
            obj.pValidReg=false;
            obj.shiftVal=fi(0,0,6,0);
            obj.ddsmInd=false;
            LUT=zeros(58320,1);k=0;
            for i=1:8:1296
                LUT(k+1:k+360)=[i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7...
                ,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7...
                ,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7,i:i+7];%#ok<*AGROW>
                k=k+360;
            end
            obj.readAddrLUT=fi(LUT',0,11,0);


            obj.iValid=false;
            obj.parValid=false;
            obj.count=fi(0,0,3,0,hdlfimath);
            obj.rdData=fi(zeros(obj.memDepth,1),1,obj.alphaWL,obj.alphaFL);
            obj.wrEn=zeros(obj.memDepth,1)>0;
            obj.rdDataE=fi(zeros(obj.memDepth,1),1,obj.alphaWL,obj.alphaFL);


            obj.countLayer=fi(1,0,11,0,hdlfimath);
            obj.layerDone=false;
            obj.iterDone=false;
            obj.iwrAddr=fi(0,0,11,0,hdlfimath);
            obj.iwrEnb=zeros(obj.memDepth,1)>0;
            obj.iwrData=cast(zeros(obj.memDepth,1),'like',obj.rdData);
            obj.ivalidCount=fi(1,0,5,0,hdlfimath);
            obj.pwrAddr=fi(0,0,11,0,hdlfimath);
            obj.pwrEnb=zeros(obj.memDepth,1)>0;
            obj.pwrData=cast(zeros(obj.memDepth,1),'like',obj.rdData);
            obj.pvalidCount=fi(1,0,3,0,hdlfimath);
            obj.noOp=false;
            obj.dataSel=false;
            obj.icount=fi(0,0,4,0,hdlfimath);
            obj.icolCount=fi(1,0,6,0,hdlfimath);
            obj.iaCount=fi(0,0,11,0,hdlfimath);
            obj.pcount=fi(0,0,11,0,hdlfimath);
            obj.pcolCount=fi(1,0,11,0,hdlfimath);
            obj.paCount=fi(0,0,6,0,hdlfimath);
            obj.pqCount=fi(0,0,11,0,hdlfimath);
            obj.pcountTmp=fi(0,0,8,0,hdlfimath);
            obj.rdEnb=false;
            obj.rdValid=false;
            obj.parityRead=false;
            obj.rdAddr=fi(0,0,16,0,hdlfimath);
            obj.finalEnb=false;
            obj.rdCount=fi(0,0,16,0,hdlfimath);
            obj.betaRead=false;
            obj.iterCount=uint8(0);
            obj.termPass=false;
            obj.termPassReg=false;


            obj.rdValidR=false;
            obj.countR=fi(0,0,3,0,hdlfimath);
            obj.rdDataR=fi(zeros(obj.memDepth,1),1,obj.alphaWL,obj.alphaFL);


            obj.iwrAddrV=fi(0,0,5,0,hdlfimath);
            obj.iwrValidV=false;
            obj.irdAddrV=fi(0,0,5,0,hdlfimath);
            obj.pwrAddrV=fi(0,0,3,0,hdlfimath);
            obj.pwrValidV=false;
            obj.prdAddrV=fi(0,0,3,0,hdlfimath);


            obj.fPChecks=zeros(obj.memDepth,1)>0;
            obj.fPChecksD=zeros(obj.memDepth,1)>0;
            obj.eColCount=fi(0,0,5,0,hdlfimath);
            obj.eLayCount=fi(0,0,11,0,hdlfimath);
            obj.eEnb=false;
            obj.eEnbDelay=false;
            obj.checkFailed=false;
            obj.eEnbLayer=false;
            obj.eEnbLayerD=false;
            obj.termPassD=false;


            obj.iterDoneF=false;
            obj.dataOutF=false;
            obj.startOutF=false;
            obj.endOutF=false;
            obj.validOutF=false;
            obj.count8=fi(0,0,4,0,hdlfimath);
            obj.count45=fi(0,0,6,0,hdlfimath);
            obj.rdCountF=fi(0,0,16,0,hdlfimath);
            obj.readF=false;
            obj.startEnb=false;


            obj.dataOut=zeros(1,1)>0;
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);
            obj.iterOut=uint8(0);
            obj.parCheck=false;

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.ctrlOut;
            varargout{3}=obj.iterOut;
            varargout{4}=obj.parCheck;
        end

        function updateImpl(obj,varargin)

            data=obj.dataIn;
            obj.dataIn(:)=varargin{1};

            valid=obj.validIn;
            obj.validIn(:)=varargin{2};

            framevalid=obj.frameValid;
            obj.frameValid(:)=(~varargin{3});

            reset=varargin{4};

            softreset=obj.softReset;
            obj.softReset(:)=varargin{5};

            numiter=varargin{6};

            parind=obj.parInd;
            obj.parInd(:)=varargin{7};

            nlayers=varargin{8};
            outlen=varargin{9};
            rateidx=varargin{10};
            lenidx=varargin{11};

            datasel=framevalid;

            parity_ind=obj.gParValidReg||parind;
            obj.gParValidReg(:)=obj.gParValid;

            int_reset=softreset||reset;


            [data_mc,valid_mc,wrenb_mc,layerdone]=parityVNWriting(obj,obj.gammaOut,...
            obj.gammaValid,obj.gParValid,obj.layerIdxReg,int_reset);
            obj.layerIdxReg(:)=obj.layerIdx;

            if strcmpi(obj.Termination,'Early')
                termpass=obj.termPass;
            else
                termpass=false;
            end


            [iterdone,inmode,iwr_data,iwr_addr,iwr_enb,pwr_data,pwr_addr,...
            pwr_enb,layeridx,ivcount,pvcount,parity,r_valid,rd_count,...
            betaenb,iterout]=iterationController(obj,data,valid,...
            datasel,reset,softreset,numiter,parity_ind,data_mc,valid_mc,...
            wrenb_mc,layerdone,nlayers,outlen,rateidx,lenidx,termpass);
            obj.layerIdx(:)=layeridx;
            obj.termPassReg(:)=obj.termPass;

            valid_lut=r_valid&~(parity);


            [i_lut,sval,p_lut,ddsm]=obj.checkMatrixLUT(obj.layerIdx,ivcount,pvcount,rateidx,lenidx,valid_lut);
            rd_valid=obj.delayBalancer1(r_valid);


            [v_wraddr_i,v_wren_i,v_rdaddr_i,v_wraddr_p,v_wren_p,...
            v_rdaddr_p]=addressGeneration(obj,rd_valid,obj.gammaValid,...
            obj.pValid,obj.gParValid,int_reset);

            i_lut_reg=obj.delayBalancer2(i_lut);
            p_lut_reg=obj.delayBalancer3(p_lut);

            i_addr=obj.vDInfoCol(i_lut_reg,v_wraddr_i,v_wren_i,v_rdaddr_i);
            p_addr=obj.vDParityCol(p_lut_reg,v_wraddr_p,v_wren_p,v_rdaddr_p);


            if~inmode
                wraddr_i=cast(iwr_addr,'like',obj.iwrAddr);
                wraddr_p=cast(pwr_addr,'like',obj.pwrAddr);
            else
                wraddr_i=cast(i_addr,'like',obj.iwrAddr);
                wraddr_p=cast(p_addr,'like',obj.pwrAddr);
            end

            if iterdone
                rdaddr_i=obj.readAddrLUT(rd_count);
            else
                rdaddr_i=fi(i_lut,0,11,0);
            end

            iwr_addrD=fi(wraddr_i*ones(obj.memDepth,1),0,11,0);
            ird_addrD=fi(rdaddr_i*ones(obj.memDepth,1),0,11,0);

            pwr_addrD=fi(wraddr_p*ones(obj.memDepth,1),0,11,0);
            prd_addrD=fi(p_lut*ones(obj.memDepth,1),0,11,0);


            i_coldata=obj.infoVNRAM(iwr_data,iwr_addrD,iwr_enb,ird_addrD);
            p_coldata=obj.parityVNRAM(pwr_data,pwr_addrD,pwr_enb,prd_addrD);


            p_coldata_tmp=parityVNReading(obj,p_coldata,obj.pValid,obj.layerIdx,int_reset);

            if~obj.pValidReg
                rd_data=i_coldata;
                shift=obj.shiftVal;
            else
                rd_data=p_coldata_tmp;
                shift=cast(0,'like',obj.shiftVal);
            end
            obj.shiftVal(:)=sval;


            [gamma,gammavalid,gparvalid,sdata]=obj.metricCalculator(rd_data,...
            rd_valid,shift,int_reset,obj.ddsmInd,obj.pValidReg,obj.layerIdx,...
            betaenb,obj.degreeVal);
            obj.ddsmInd(:)=ddsm;
            obj.pValidReg(:)=obj.pValid;
            obj.pValid(:)=parity;

            obj.gammaOut(:)=gamma;
            obj.gammaValid(:)=gammavalid;
            obj.gParValid(:)=gparvalid;



            if strcmpi(obj.Termination,'Early')||obj.ParityCheckStatus
                obj.termPass(:)=earlyTermination(obj,int_reset,sdata,obj.gammaValid,obj.degreeVal,nlayers);
            end


            [datao,starto,endo,valido]=finalDecision(obj,i_coldata,iterdone,rd_count,int_reset,outlen);

            obj.ctrlOut.start(:)=starto;
            obj.ctrlOut.end(:)=endo;
            obj.ctrlOut.valid(:)=valido;

            if valido
                if strcmpi(obj.Termination,'Early')&&obj.termPass
                    obj.iterOut(:)=iterout+1;
                else
                    obj.iterOut(:)=iterout;
                end
                obj.dataOut(:)=datao;
                obj.parCheck(:)=obj.termPass;
            else
                obj.dataOut(:)=0;
                obj.iterOut(:)=0;
                obj.parCheck(:)=false;
            end
        end

        function[iterdone,datasel,iwr_data,iwr_addr,iwr_enb,pwr_data,pwr_addr,pwr_enb,count_layer,...
            ivalid_count,pvalid_count,parity,rd_valid,rd_addr,betaenb,iterout]=iterationController(obj,data,valid,framevalid,...
            reset,softreset,num_iter,parity_ind,gamma,gvalid,gwr_enb,layerdone,nlayers,outlen,rateidx,lenidx,termpass)

            SFactor=8;


            degreeShort_1_4=[4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;...
            4;4;4;4;4;4;3;3;3;3;3;3;3;3;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;...
            4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;...
            3;3;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;...
            4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;3;3;...
            3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;3;4;4;4;4;4;4;4;4;3;3;3;3;3;3;3;3;4;4;4;4;...
            4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;4;zeros(792,1)];

            degreeShort_1_2=[5;5;5;5;5;5;5;5;6;6;6;6;6;6;6;6;7;7;7;7;7;7;7;7;6;6;6;6;6;6;6;6;4;4;4;4;4;4;4;4;5;5;...
            5;5;5;5;5;5;4;4;4;4;4;4;4;4;5;5;5;5;5;5;5;5;6;6;6;6;6;6;6;6;5;5;5;5;5;5;5;5;5;5;5;5;...
            5;5;5;5;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;6;5;5;5;5;5;5;...
            5;5;4;4;4;4;4;4;4;4;6;6;6;6;6;6;6;6;5;5;5;5;5;5;5;5;4;4;4;4;4;4;4;4;6;6;6;6;6;6;6;6;...
            5;5;5;5;5;5;5;5;6;6;6;6;6;6;6;6;5;5;5;5;5;5;5;5;7;7;7;7;7;7;7;7;7;zeros(88,1);zeros(792,1)];

            degreeShort_3_4=[10;10;10;10;10;10;10;10;12;12;12;12;12;12;12;12;11;11;11;11;11;11;11;11;9;9;9;9;9;...
            9;9;9;10;10;10;10;10;10;10;10;13;13;13;13;13;13;13;13;11;11;11;11;11;11;11;11;12;12;...
            12;12;12;12;12;12;11;11;11;11;11;11;11;11;10;10;10;10;10;10;10;10;11;11;11;11;11;11;11;...
            11;12;12;12;12;12;12;12;12;13;zeros(192,1);zeros(792,1)];

            degreeShort_4_5=[12;12;12;12;12;12;12;12;11;11;11;11;11;11;11;11;13;13;13;13;13;13;13;13;12;12;12;12;12;...
            12;12;12;12;12;12;12;12;12;12;12;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;...
            13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;13;zeros(208,1);zeros(792,1)];

            degreeShort_5_6=[16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;16;...
            16;16;16;19;19;19;19;19;19;19;19;18;18;18;18;18;18;18;18;19;19;19;19;19;19;19;19;17;17;...
            17;17;17;17;17;17;17;zeros(224,1);zeros(792,1)];


            iwr_data=cast(obj.iwrData,'like',obj.iwrData);
            iwr_enb=obj.iwrEnb;
            iwr_addr=obj.iwrAddr;

            pwr_data=cast(obj.pwrData,'like',obj.pwrData);
            pwr_enb=obj.pwrEnb;
            pwr_addr=obj.pwrAddr;

            count_layer=obj.countLayer;
            ivalid_count=obj.ivalidCount;

            if obj.dataSel
                rd_valid=obj.rdValid;
            else
                rd_valid=false;
            end

            parity=obj.parityRead;
            betaenb=obj.betaRead;
            datasel=obj.dataSel;
            iterdone=obj.iterDone;
            rd_addr=obj.rdAddr;
            iterout=obj.iterCount;
            obj.layerDone(:)=layerdone;

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
                resetcount=true;%#ok<*NASGU>
            else
                if(obj.iterCount==fi(num_iter,0,8,0)||termpass)%#ok<*OR2>
                    obj.iterDone(:)=true;
                    resetcount=true;
                else
                    obj.iterDone(:)=false;
                    if obj.layerDone&&obj.dataSel
                        if obj.countLayer==nlayers
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


            if size(obj.degreeLUT,1)==1
                obj.degreeValTmp(:)=obj.degreeLUT-1;
            else
                if(strcmpi(obj.FECFrameSource,'Property')&&strcmpi(obj.FECFrame,'Short')&&strcmpi(obj.CodeRateSource,'Property'))
                    obj.degreeValTmp(:)=obj.degreeLUT(obj.countLayer)-1;
                else
                    obj.degreeValTmp(:)=obj.degreeLUT(rateidx+1)-1;
                end
            end

            if(strcmpi(obj.FECFrameSource,'Input port'))
                if rateidx==fi(0,0,4,0)&&lenidx==fi(1,0,4,0)
                    obj.degreeValTmp1(:)=degreeShort_1_4(obj.countLayer)-1;
                elseif rateidx==fi(3,0,4,0)&&lenidx==fi(1,0,4,0)
                    obj.degreeValTmp1(:)=degreeShort_1_2(obj.countLayer)-1;
                elseif rateidx==fi(6,0,4,0)&&lenidx==fi(1,0,4,0)
                    obj.degreeValTmp1(:)=degreeShort_3_4(obj.countLayer)-1;
                elseif rateidx==fi(7,0,4,0)&&lenidx==fi(1,0,4,0)
                    obj.degreeValTmp1(:)=degreeShort_4_5(obj.countLayer)-1;
                elseif rateidx==fi(8,0,4,0)&&lenidx==fi(1,0,4,0)
                    obj.degreeValTmp1(:)=degreeShort_5_6(obj.countLayer)-1;
                else
                    obj.degreeValTmp1(:)=obj.degreeValTmp;
                end
                obj.degreeVal(:)=obj.degreeValTmp1;
            elseif((strcmpi(obj.FECFrameSource,'Property')&&strcmpi(obj.CodeRateSource,'Input port')&&strcmpi(obj.FECFrame,'Short')))
                if rateidx==fi(0,0,4,0)
                    obj.degreeValTmp1(:)=degreeShort_1_4(obj.countLayer)-1;
                elseif rateidx==fi(3,0,4,0)
                    obj.degreeValTmp1(:)=degreeShort_1_2(obj.countLayer)-1;
                elseif rateidx==fi(6,0,4,0)
                    obj.degreeValTmp1(:)=degreeShort_3_4(obj.countLayer)-1;
                elseif rateidx==fi(7,0,4,0)
                    obj.degreeValTmp1(:)=degreeShort_4_5(obj.countLayer)-1;
                elseif rateidx==fi(8,0,4,0)
                    obj.degreeValTmp1(:)=degreeShort_5_6(obj.countLayer)-1;
                else
                    obj.degreeValTmp1(:)=obj.degreeValTmp;
                end
                obj.degreeVal(:)=obj.degreeValTmp1;
            else
                obj.degreeVal(:)=obj.degreeValTmp;
            end


            if reset
                obj.iwrAddr(:)=1;
                obj.iwrEnb(:)=ones(obj.memDepth,1)>0;
                obj.iwrData(:)=zeros(obj.memDepth,1);
                obj.ivalidCount(:)=0;
                obj.icount(:)=0;
                obj.iaCount(:)=0;
                obj.icolCount(:)=1;

                obj.pwrAddr(:)=1;
                obj.pwrEnb(:)=ones(obj.memDepth,1)>0;
                obj.pwrData(:)=zeros(obj.memDepth,1);
                obj.pvalidCount(:)=0;
                obj.pcount(:)=0;
                obj.paCount(:)=1;
                obj.pcolCount(:)=1;
                obj.pqCount(:)=0;
                obj.pcountTmp(:)=0;

                obj.rdEnb=false;
                obj.rdValid=false;
                obj.parityRead=false;
            else
                if~obj.dataSel
                    if valid
                        if parity_ind
                            obj.pwrEnb(:)=zeros(obj.memDepth,1)>0;
                            obj.pwrData(:)=zeros(obj.memDepth,1);
                            if obj.pcount==nlayers
                                if obj.paCount==45
                                    obj.paCount(:)=45;
                                else
                                    obj.paCount(:)=obj.paCount+1;
                                end
                                obj.pcount(:)=1;
                                obj.pqCount(:)=1;
                                obj.pcolCount(:)=0;
                                obj.pcountTmp(:)=1;
                            else
                                obj.pcount(:)=obj.pcount+1;
                                if((obj.pcountTmp==nlayers/8)||obj.pcount==1)
                                    obj.pqCount(:)=obj.pqCount+1;
                                    obj.pcolCount(:)=0;
                                    obj.pcountTmp(:)=1;
                                else
                                    obj.pcountTmp(:)=obj.pcountTmp+1;
                                    obj.pcolCount(:)=obj.pcolCount+SFactor;
                                end
                            end
                            obj.pwrEnb(obj.paCount)=true;
                            obj.pwrData(obj.paCount)=data;
                            obj.pwrAddr(:)=obj.pcolCount+obj.pqCount;
                        else
                            obj.iwrEnb(:)=zeros(obj.memDepth,1)>0;
                            obj.iwrData(:)=zeros(obj.memDepth,1);
                            if obj.icount==SFactor
                                obj.icount(:)=1;
                                if obj.icolCount==obj.memDepth
                                    obj.icolCount(:)=1;
                                    obj.iaCount(:)=obj.iaCount+SFactor;
                                else
                                    obj.icolCount(:)=obj.icolCount+1;
                                end
                            else
                                obj.icount(:)=obj.icount+1;
                            end
                            obj.iwrEnb(obj.icolCount)=true;
                            obj.iwrData(obj.icolCount)=data;
                            obj.iwrAddr(:)=obj.iaCount+obj.icount;
                        end
                    end
                else
                    if gvalid
                        if parity_ind
                            obj.pwrData(:)=gamma;
                            obj.pwrEnb(:)=gwr_enb;
                            obj.iwrEnb(:)=zeros(obj.memDepth,1);
                        else
                            obj.iwrData(:)=gamma;
                            obj.iwrEnb(:)=ones(obj.memDepth,1);
                            obj.pwrEnb(:)=zeros(obj.memDepth,1);
                        end
                        obj.iwrAddr(:)=1;
                        obj.pwrAddr(:)=1;
                    else
                        obj.pwrData(:)=zeros(obj.memDepth,1);
                        obj.pwrEnb(:)=zeros(obj.memDepth,1);
                        obj.iwrData(:)=zeros(obj.memDepth,1);
                        obj.iwrEnb(:)=zeros(obj.memDepth,1);
                        obj.iwrAddr(:)=1;
                        obj.pwrAddr(:)=1;
                    end
                end
            end









            trigger=softreset||obj.layerDone;

            if reset
                obj.parityRead(:)=false;
                obj.pvalidCount(:)=0;
                obj.ivalidCount(:)=0;
            else
                if obj.rdEnb&&obj.dataSel
                    if obj.ivalidCount==cast(obj.degreeVal-2,'like',obj.ivalidCount)
                        if obj.pvalidCount==2
                            obj.rdEnb(:)=false;
                            obj.ivalidCount(:)=0;
                            obj.pvalidCount(:)=0;
                            obj.parityRead(:)=false;
                        else
                            obj.pvalidCount(:)=obj.pvalidCount+1;
                            obj.parityRead(:)=true;
                        end
                    else
                        obj.parityRead(:)=false;
                        obj.ivalidCount(:)=obj.ivalidCount+1;
                    end
                else
                    obj.parityRead(:)=false;
                    obj.pvalidCount(:)=0;
                    obj.ivalidCount(:)=0;
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

            pvalid_count=obj.pvalidCount;


            if obj.iterDone
                obj.finalEnb(:)=true;
            end

            if reset
                obj.rdCount(:)=0;
            else
                if obj.finalEnb
                    if obj.rdCount==outlen
                        obj.rdCount(:)=1;
                        obj.finalEnb(:)=false;
                    else
                        obj.rdCount(:)=obj.rdCount+1;
                    end
                else
                    obj.rdCount(:)=0;
                end
            end

            obj.rdAddr(:)=obj.rdCount;

        end

        function[dataout,validout,wr_enb,layerdone]=parityVNWriting(obj,data,valid,pvalid,layeridx,reset)

            validout=cast(obj.iValid,'like',valid);
            layerdone=obj.iValid&&(~valid);


            if reset
                dataout=cast(zeros(obj.memDepth,1),'like',data);
                obj.wrEn(:)=zeros(obj.memDepth,1);
                obj.rdDataE(:)=zeros(obj.memDepth,1);
            else
                if obj.iValid
                    if obj.parValid
                        if(layeridx==1&&obj.count==1)
                            dataout=[obj.rdData(2:obj.memDepth);0];
                            obj.wrEn(:)=[ones(44,1);0];
                            obj.rdDataE(:)=[obj.rdData(1);data(2:obj.memDepth)];
                        elseif(layeridx==1&&obj.count==2)
                            dataout=obj.rdDataE;
                            obj.wrEn(:)=ones(obj.memDepth,1);
                        else
                            dataout=obj.rdData;
                            obj.wrEn(:)=ones(obj.memDepth,1);
                        end
                    else
                        dataout=obj.rdData;
                        obj.wrEn(:)=zeros(obj.memDepth,1);
                    end
                else
                    dataout=cast(zeros(obj.memDepth,1),'like',data);
                    obj.wrEn(:)=zeros(obj.memDepth,1);
                end
            end

            wr_enb=obj.wrEn;

            if reset
                obj.count(:)=0;
            else
                if pvalid&&valid
                    if obj.count==2
                        obj.count(:)=0;
                    else
                        obj.count(:)=obj.count+1;
                    end
                else
                    obj.count(:)=0;
                end
            end

            obj.parValid(:)=pvalid;
            obj.iValid(:)=valid;
            obj.rdData(:)=data;
        end

        function rd_data_tmp=parityVNReading(obj,prd_data,pvalid,layeridx,reset)


            if reset
                rd_data_tmp=cast(zeros(obj.memDepth,1),'like',prd_data);
            else
                if obj.rdValidR
                    if(layeridx==1&&obj.countR==1)
                        rd_data_tmp=[prd_data(1);obj.rdDataR(1:obj.memDepth-1)];
                    elseif(layeridx==1&&obj.countR==2)
                        rd_data_tmp=[obj.maxData;obj.rdDataR(2:obj.memDepth)];
                    else
                        rd_data_tmp=obj.rdDataR;
                    end
                else
                    rd_data_tmp=cast(zeros(obj.memDepth,1),'like',prd_data);
                end
            end

            obj.rdValidR(:)=pvalid;
            obj.rdDataR(:)=prd_data;

            if reset
                obj.countR(:)=0;
            else
                if obj.rdValidR
                    if obj.countR==2
                        obj.countR(:)=0;
                    else
                        obj.countR(:)=obj.countR+1;
                    end
                else
                    obj.countR(:)=0;
                end
            end
        end

        function[iwr_addr,iwr_en,ird_addr,pwr_addr,pwr_en,prd_addr]=addressGeneration(obj,iwr_valid,ird_valid,pwr_valid,prd_valid,reset)

            iwr_addr=obj.iwrAddrV;
            iwr_en=obj.iwrValidV;
            ird_addr=obj.irdAddrV;

            pwr_addr=obj.pwrAddrV;
            pwr_en=obj.pwrValidV;
            prd_addr=obj.prdAddrV;


            if reset
                obj.iwrAddrV(:)=0;
                obj.irdAddrV(:)=0;
                obj.pwrAddrV(:)=0;
                obj.prdAddrV(:)=0;
            else
                if iwr_valid
                    obj.iwrAddrV(:)=obj.iwrAddrV+1;
                else
                    obj.iwrAddrV(:)=0;
                end

                if ird_valid
                    obj.irdAddrV(:)=obj.irdAddrV+1;
                else
                    obj.irdAddrV(:)=0;
                end

                if pwr_valid
                    obj.pwrAddrV(:)=obj.pwrAddrV+1;
                else
                    obj.pwrAddrV(:)=0;
                end

                if prd_valid
                    obj.prdAddrV(:)=obj.prdAddrV+1;
                else
                    obj.prdAddrV(:)=0;
                end
            end

            obj.iwrValidV(:)=iwr_valid;
            obj.pwrValidV(:)=pwr_valid;
        end

        function termpass=earlyTermination(obj,reset,gamma,valid,countidx,maxlayer)

            hardDec=gamma<=0;


            if reset
                obj.fPChecks(:)=zeros(obj.memDepth,1);
            else
                if valid
                    for idx=1:obj.memDepth
                        if hardDec(idx)
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
                        if obj.eLayCount==maxlayer-fi(1,0,1,0)
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

        function[datao,starto,endo,valido]=finalDecision(obj,data,iterdone,count,reset,outlen)


            datao=obj.dataOutF;
            starto=obj.startOutF;
            endo=obj.endOutF;
            valido=obj.validOutF;

            if reset
                obj.readF(:)=false;
                obj.startOutF(:)=false;
                obj.endOutF(:)=false;
                obj.validOutF(:)=false;
            else
                if obj.startEnb
                    obj.readF(:)=true;
                end

                if obj.readF
                    if obj.rdCountF==1
                        obj.startOutF(:)=true;
                        obj.endOutF(:)=false;
                        obj.validOutF(:)=true;
                    elseif obj.rdCountF==outlen
                        obj.startOutF(:)=false;
                        obj.endOutF(:)=true;
                        obj.validOutF(:)=true;
                        obj.readF(:)=false;
                    else
                        obj.startOutF(:)=false;
                        obj.endOutF(:)=false;
                        obj.validOutF(:)=true;
                    end
                else
                    obj.startOutF(:)=false;
                    obj.endOutF(:)=false;
                    obj.validOutF(:)=false;
                end
            end


            if obj.startOutF
                obj.count8(:)=1;
                obj.count45(:)=1;
            else
                if obj.validOutF
                    if obj.count8==8
                        obj.count8(:)=1;
                        if obj.count45==obj.memDepth
                            obj.count45(:)=1;
                        else
                            obj.count45(:)=obj.count45+1;
                        end
                    else
                        obj.count8(:)=obj.count8+1;
                    end
                else
                    obj.count8(:)=1;
                    obj.count45(:)=1;
                end
            end

            obj.dataOutF(:)=data(obj.count45)<=0;

            obj.startEnb=(~obj.iterDoneF)&&iterdone;
            obj.iterDoneF(:)=iterdone;
            obj.rdCountF(:)=count;

        end

        function num=getNumInputsImpl(~)
            num=11;
        end

        function num=getNumOutputsImpl(~)
            num=4;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked

                s.infoVNRAM=obj.infoVNRAM;
                s.parityVNRAM=obj.parityVNRAM;
                s.checkMatrixLUT=obj.checkMatrixLUT;
                s.metricCalculator=obj.metricCalculator;
                s.vDInfoCol=obj.vDInfoCol;
                s.vDParityCol=obj.vDParityCol;


                s.dataIn=obj.dataIn;
                s.validIn=obj.validIn;
                s.frameValid=obj.frameValid;
                s.softReset=obj.softReset;
                s.parInd=obj.parInd;
                s.gParValid=obj.gParValid;
                s.gParValidReg=obj.gParValidReg;
                s.readAddrLUT=obj.readAddrLUT;
                s.gammaOut=obj.gammaOut;
                s.gammaValid=obj.gammaValid;
                s.layerIdx=obj.layerIdx;
                s.layerIdxReg=obj.layerIdxReg;
                s.pValid=obj.pValid;
                s.pValidReg=obj.pValidReg;
                s.shiftVal=obj.shiftVal;
                s.ddsmInd=obj.ddsmInd;
                s.delayBalancer1=obj.delayBalancer1;
                s.delayBalancer2=obj.delayBalancer2;
                s.delayBalancer3=obj.delayBalancer3;
                s.degreeVal=obj.degreeVal;
                s.degreeValTmp=obj.degreeValTmp;
                s.degreeValTmp1=obj.degreeValTmp1;
                s.memDepth=obj.memDepth;
                s.maxData=obj.maxData;


                s.iValid=obj.iValid;
                s.parValid=obj.parValid;
                s.count=obj.count;
                s.rdData=obj.rdData;
                s.wrEn=obj.wrEn;
                s.rdDataE=obj.rdDataE;


                s.countLayer=obj.countLayer;
                s.layerDone=obj.layerDone;
                s.iterDone=obj.iterDone;
                s.iwrAddr=obj.iwrAddr;
                s.iwrEnb=obj.iwrEnb;
                s.iwrData=obj.iwrData;
                s.ivalidCount=obj.ivalidCount;
                s.pwrAddr=obj.pwrAddr;
                s.pwrEnb=obj.pwrEnb;
                s.pwrData=obj.pwrData;
                s.pvalidCount=obj.pvalidCount;
                s.noOp=obj.noOp;
                s.dataSel=obj.dataSel;
                s.icount=obj.icount;
                s.icolCount=obj.icolCount;
                s.iaCount=obj.iaCount;
                s.pcount=obj.pcount;
                s.pcolCount=obj.pcolCount;
                s.paCount=obj.paCount;
                s.pqCount=obj.pqCount;
                s.pcountTmp=obj.pcountTmp;
                s.rdEnb=obj.rdEnb;
                s.rdValid=obj.rdValid;
                s.parityRead=obj.parityRead;
                s.rdAddr=obj.rdAddr;
                s.finalEnb=obj.finalEnb;
                s.rdCount=obj.rdCount;
                s.betaRead=obj.betaRead;
                s.iterCount=obj.iterCount;
                s.termPass=obj.termPass;
                s.termPassReg=obj.termPassReg;


                s.rdValidR=obj.rdValidR;
                s.countR=obj.countR;
                s.rdDataR=obj.rdDataR;


                s.iwrAddrV=obj.iwrAddrV;
                s.iwrValidV=obj.iwrValidV;
                s.irdAddrV=obj.irdAddrV;
                s.pwrAddrV=obj.pwrAddrV;
                s.pwrValidV=obj.pwrValidV;
                s.prdAddrV=obj.prdAddrV;


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


                s.iterDoneF=obj.iterDoneF;
                s.dataOutF=obj.dataOutF;
                s.startOutF=obj.startOutF;
                s.endOutF=obj.endOutF;
                s.validOutF=obj.validOutF;
                s.count8=obj.count8;
                s.count45=obj.count45;
                s.rdCountF=obj.rdCountF;
                s.readF=obj.readF;
                s.startEnb=obj.startEnb;


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
