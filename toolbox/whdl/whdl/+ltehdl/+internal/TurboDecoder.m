
classdef(StrictDefaults)TurboDecoder<matlab.System




%#codegen
%#ok<*EMCLS>

    properties(Nontunable)




        BlockSizeSource='Input port';




        BlockSize=6144;


        NumIterations=6;
    end









    properties(Access=private)



        Algorithm='Max';

        Architecture='Fully Serial';





        BLen=408;
        BLen_ext=416;


        inMessage;
        lastsample;

        FSMstate_write;
        Nextwriteaddr;


        Nextreadaddr;
        ReadCount;
        FSMstate_decoding;

        Current_Iter_Id;
        sleeping_count;
        BB_En_reg;
        Buffer_id_reg;
        Nextwriteaddr_alpha;
        En_extrinc_reg;
        beta_A_or_B;


        decoder_id_reg;
        centralcontrols_reg;
        llr_apriori;
        llrInI;
        extrinInI;
        r_addr_reg;
        r_sys_addr_reg;

        FSMstate;
        total_count;
        local_count;
        itlvaddrRAM;
        itlvaddr_cnt;
        itlv_start_reg;


        sysbuffer;
        p1buffer;
        p2buffer;



        sysram;
        p1ram;
        p2ram;
        sysOut_reg;
        p1Out_reg;
        p2Out_reg;
        iniValue;

        bufferA;
        bufferB;



        offsetValue;
        alphaInIValue;
        alphaDec;
        alpha_reg;
        acmp_reg;
        aor_reg;
        aoffset_reg;
        agamma_reg;
        agammaIn_reg;
        aen_reg;

        betaInIValue;
        betaADec;
        betaA_reg;
        bAcmp_reg;
        bAor_reg;
        bAoffset_reg;
        bAgamma_reg;
        bAgammaIn_reg;
        bAen_reg;

        betaBDec;
        betaB_reg;
        bBcmp_reg;
        bBor_reg;
        bBoffset_reg;
        bBgamma_reg;
        bBgammaIn_reg;
        bBen_reg;

        alpharam;
        alpha_addr_W_reg;
        alpha_addr_R_reg;
        beta_sel_reg;
        extrinsic_En_reg;
        extrinDataIn_reg;
        decision_reg;
        extrinsic_reg;


        Nreadaddr;
        FSMstate_outctrl;


        extrinsicram;
        extrinRAM_w_addr_reg;
        extrinRAM_r_addr_reg;


        valid_reg;
        start_reg;
        end_reg;
        dataOut_reg;




    end

    properties(Nontunable,Access=private)
        WinSize=32;
        SizefromPort;

        threshold;
        bound;
        floatType;
    end


    properties(Constant,Hidden)
        BlockSizeSourceSet=matlab.system.StringSet({...
        'Property',...
        'Input port'});








    end

    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header(mfilename('class'),...
            'ShowSourceLink',false,...
            'Title','LTE Turbo Decoder',...
            'Text','Decode turbo-encoded samples, according to the LTE standard.');
        end

    end

    methods
        function obj=TurboDecoder(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end


        end





        function set.NumIterations(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'TurboDecoder','NumIterations');
            coder.internal.errorIf(val>15,'whdl:TurboCode:InvalidIterationNum');
            obj.NumIterations=val;
        end

        function set.BlockSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'TurboDecoder','BlockSize');

            validblkSize=[40:8:512,528:16:1024,1056:32:2048,2112:64:6144];
            val_dbl=double(val);

            coder.internal.errorIf(~ismember(val_dbl,validblkSize),'whdl:TurboCode:InvalidLTEBlockSize',val_dbl);

            obj.BlockSize=val;

        end
    end

    methods(Access=protected)


        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function[dataOut,ctrlOut]=outputImpl(obj,varargin)

            dataOut=obj.dataOut_reg(1);
            ctrlOut.start=obj.start_reg(1);
            ctrlOut.end=obj.end_reg(1);
            ctrlOut.valid=obj.valid_reg(1);

        end



        function updateImpl(obj,varargin)

            dataIn=varargin{1};
            ctrlIn=varargin{2};
            startIn=ctrlIn.start;
            endIn=ctrlIn.end;
            validIn=ctrlIn.valid;


            if obj.SizefromPort&&startIn
                readBlockSize(obj,varargin{3});
            end


            [dataSource,w_addr,w_en,decoding_start]=DataRAMControler(obj,startIn,validIn,endIn);
            [r_addr,interleaver_start,controls,alpha_addr_R,alpha_addr_W,address_source,OutputStart]...
            =centralControler(obj,decoding_start);


            itlvaddr=ComputeInterleaverAddr_codegen(obj,startIn,interleaver_start,address_source);


            if address_source
                next_sys_raddr=itlvaddr;
            else
                next_sys_raddr=r_addr;
            end


            r_sys_addr=obj.r_sys_addr_reg(1);
            r_p_addr=obj.r_addr_reg(1);

            wdata=formatinputdata(obj,dataIn,w_addr);
            [sysOut,p1Out,p2Out]=RAMgroup(obj,wdata,dataSource,w_en,w_addr,r_sys_addr,r_p_addr);


            obj.r_addr_reg(1:end-1)=obj.r_addr_reg(2:end);
            obj.r_addr_reg(end)=r_addr;
            obj.r_sys_addr_reg(1:end-1)=obj.r_sys_addr_reg(2:end);
            obj.r_sys_addr_reg(end)=next_sys_raddr;





            ctrl_reg=obj.centralcontrols_reg(1);
            obj.centralcontrols_reg(1:end-1)=obj.centralcontrols_reg(2:end);
            obj.centralcontrols_reg(end)=controls;


            cached_data=cast(zeros(3,1),'like',obj.llrInI);

            if ctrl_reg.decoder_id
                cached_data(1)=cast(p2Out,'like',obj.llrInI);
            else
                cached_data(1)=cast(p1Out,'like',obj.llrInI);
            end
            cached_data(2)=cast(sysOut,'like',obj.llrInI);


            if ctrl_reg.aprior_source
                obj.llr_apriori=obj.extrinsic_reg;
            else
                obj.llr_apriori=obj.llrInI;
            end

            cached_data(3)=obj.llr_apriori;


            gamma=gammaCaculator(obj,cached_data);


            dataOutA=BiBuffer(obj,cached_data,ctrl_reg.BB_Dr,ctrl_reg.BB_Sc,ctrl_reg.BB_En,1);
            dataOutB=BiBuffer(obj,cached_data,not(ctrl_reg.BB_Dr),not(ctrl_reg.BB_Sc),ctrl_reg.BB_En,2);
            gammaA=gammaCaculator(obj,dataOutA);
            gammaB=gammaCaculator(obj,dataOutB);



            if ctrl_reg.Buffer_id
                alphaIn=gammaA;
                betaBIn=gammaB;
                betaAIn=gamma;
                extrinsicDataIn=dataOutB;
            else
                alphaIn=gammaB;
                betaBIn=gamma;
                betaAIn=gammaA;
                extrinsicDataIn=dataOutA;
            end


            alphaOut=alphabeta_delay(obj,alphaIn,ctrl_reg.alpha_En,1);
            betaBOut=alphabeta_delay(obj,betaBIn,ctrl_reg.beta_En_B,3);
            betaAOut=alphabeta_delay(obj,betaAIn,ctrl_reg.beta_En_A,2);





            alphaRAMOut=alphaRAM(obj,alphaOut,obj.alpha_addr_W_reg(1),ctrl_reg.alpha_En,obj.alpha_addr_R_reg(1));
            obj.alpha_addr_W_reg(1:end-1)=obj.alpha_addr_W_reg(2:end);
            obj.alpha_addr_W_reg(end)=alpha_addr_W;
            obj.alpha_addr_R_reg(1:end-1)=obj.alpha_addr_R_reg(2:end);
            obj.alpha_addr_R_reg(end)=alpha_addr_R;




            if obj.beta_sel_reg(1)
                betaOut=betaBOut;
            else
                betaOut=betaAOut;
            end


            [extrinsic,decision]=extrinsicInfo(obj,alphaRAMOut,betaOut,obj.extrinsic_En_reg(1),obj.extrinDataIn_reg(:,1));
            obj.beta_sel_reg(1:end-1)=obj.beta_sel_reg(2:end);
            obj.beta_sel_reg(end)=ctrl_reg.Buffer_id;

            obj.extrinDataIn_reg(:,1:end-1)=obj.extrinDataIn_reg(:,2:end);
            obj.extrinDataIn_reg(:,end)=extrinsicDataIn;









            [addrO,startO,endO,validO]=OutputController(obj,OutputStart,obj.BLen);




            extrinOut=extrinsicRAM(obj,[extrinsic,decision]',obj.extrinRAM_w_addr_reg(1),obj.extrinsic_En_reg(1),obj.extrinRAM_r_addr_reg(1));


            if controls.BB_En
                obj.extrinRAM_w_addr_reg(1:end-1)=obj.extrinRAM_w_addr_reg(2:end);
                obj.extrinRAM_w_addr_reg(end)=next_sys_raddr;
            end
            obj.extrinsic_En_reg(1:end-1)=obj.extrinsic_En_reg(2:end);
            obj.extrinsic_En_reg(end)=ctrl_reg.En_extrinc;

            obj.extrinsic_reg(1)=extrinOut(1);

            if validO
                next_extrinRAM_r_addr=addrO;
            else
                next_extrinRAM_r_addr=next_sys_raddr;
            end

            obj.extrinRAM_r_addr_reg(1:end-1)=obj.extrinRAM_r_addr_reg(2:end);
            obj.extrinRAM_r_addr_reg(end)=next_extrinRAM_r_addr;



            obj.dataOut_reg(1:end-1)=obj.dataOut_reg(2:end);
            obj.dataOut_reg(end)=and(obj.valid_reg(end-1),extrinOut(2));
            obj.valid_reg(1:end-1)=obj.valid_reg(2:end);
            obj.valid_reg(end)=validO;
            obj.start_reg(1:end-1)=obj.start_reg(2:end);
            obj.start_reg(end)=startO;
            obj.end_reg(1:end-1)=obj.end_reg(2:end);
            obj.end_reg(end)=endO;





        end



        function resetImpl(obj)

            obj.FSMstate_write=false;
            obj.Nextwriteaddr=1;
            obj.FSMstate_decoding=4;

        end



        function validateInputsImpl(obj,varargin)
            dataIn=varargin{1};



            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(dataIn,{'embedded.fi','int8','double','single'},{'vector','size',[3,1]},'TurboDecoder','dataIn');



                [inWL,inFL,signed]=dsphdlshared.hdlgetwordsizefromdata(dataIn);




                coder.internal.errorIf(signed==0,'whdl:TurboCode:InvalidDataType');
                if(inWL~=0&&(inFL<1||inWL<2))
                    coder.internal.warning('whdl:TurboCode:ImproperDataType');
                end

                if strcmp(obj.BlockSizeSource,'Input port')
                    blkSize=varargin{3};
                    validateattributes(blkSize,{'embedded.fi','uint16','double','single'},{'integer'},'TurboDecoder','blockSize');
                    if strcmp(class(blkSize),'embedded.fi')%#ok<STISA>
                        [inWL,inFL,signed]=dsphdlshared.hdlgetwordsizefromdata(blkSize);
                        if~(signed==0&&inWL==13&&inFL==0)
                            coder.internal.error('whdl:TurboCode:InvalidBlkSizeType');
                        end
                    end
                end


            end
        end





        function setupImpl(obj,varargin)




            obj.SizefromPort=strcmp(obj.BlockSizeSource,'Input port');
            if~obj.SizefromPort
                obj.BLen=obj.BlockSize;

            else
                obj.BLen=6144;

            end
            obj.BLen_ext=ceil((obj.BLen)/obj.WinSize)*obj.WinSize;

            dataIn=varargin{1};
            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(dataIn,{'embedded.fi','int8','double','single'},{'vector','size',[3,1]},'TurboDecoder','dataIn');



                [inWL,inFL,signed]=dsphdlshared.hdlgetwordsizefromdata(dataIn);




                coder.internal.errorIf(signed==0,'whdl:TurboCode:InvalidDataType');
                if(inWL~=0&&(inFL<1||inWL<2))
                    coder.internal.warning('whdl:TurboCode:ImproperDataType');
                end




                if inWL==0
                    obj.floatType=true;
                    inRef=cast(0,'like',dataIn);
                    extrinRef=cast(0,'like',dataIn);
                    stmetRef=cast(0,'like',dataIn);
                    obj.extrinInI=cast(0,'like',dataIn);

                    negLLR=0;
                    offset=12;
                    obj.threshold=20;
                    inistmet=-40;
                    obj.bound=64;

                else

                    obj.floatType=false;

                    extrinType=numerictype(1,inWL+2,inFL);
                    smetWL=inWL+5;
                    smetFL=inFL+1;
                    smetType=numerictype(1,smetWL,smetFL);


                    input_intWL=inWL-inFL-1;
                    alpha_intWL=input_intWL+4;

                    negLLR=0;
                    obj.threshold=2^(input_intWL+2);

                    offset=round(2^(alpha_intWL)*0.2);

                    inistmet=-round(2^(alpha_intWL)*0.75);

                    obj.bound=2^alpha_intWL;


                    smet_fimath=fimath('RoundMode','floor',...
                    'OverflowMode','wrap',...
                    'SumMode','KeepLSB',...
                    'SumWordLength',smetWL,...
                    'SumFractionLength',smetFL,...
                    'CastBeforeSum',true);
                    extrin_fimath=fimath('RoundMode','floor',...
                    'OverflowMode','Saturate',...
                    'SumMode','KeepLSB',...
                    'SumWordLength',smetWL,...
                    'SumFractionLength',smetFL,...
                    'CastBeforeSum',true);

                    inRef=cast(0,'like',dataIn);
                    extrinRef=fi(0,extrinType,smet_fimath);
                    stmetRef=fi(0,smetType,smet_fimath);
                    obj.extrinInI=fi(0,extrinType,extrin_fimath);
                end

                obj.inMessage=false;
                obj.lastsample=false;

                obj.FSMstate_write=false;
                obj.Nextwriteaddr=1;


                obj.FSMstate_decoding=0;

                obj.Nextreadaddr=0;

                obj.ReadCount=0;

                obj.Current_Iter_Id=0;

                obj.sleeping_count=0;

                obj.BB_En_reg=false;

                obj.Buffer_id_reg=false;

                obj.Nextwriteaddr_alpha=0;



                obj.En_extrinc_reg=false;

                obj.beta_A_or_B=false;

                obj.decoder_id_reg=false;


                obj.sysbuffer=cast(zeros(1,2),'like',inRef);
                obj.p1buffer=cast(0,'like',inRef);
                obj.p2buffer=cast(zeros(1,2),'like',inRef);



                obj.sysram=cast(zeros(1,7000),'like',inRef);
                obj.p1ram=cast(zeros(1,7000),'like',inRef);
                obj.p2ram=cast(zeros(1,7000),'like',inRef);
                obj.sysOut_reg=cast(0,'like',inRef);
                obj.p1Out_reg=cast(0,'like',inRef);
                obj.p2Out_reg=cast(0,'like',inRef);
                obj.iniValue=cast(negLLR,'like',inRef);

                obj.r_addr_reg=zeros(1,2);
                obj.r_sys_addr_reg=zeros(1,2);

                obj.FSMstate=0;
                obj.total_count=0;
                obj.local_count=0;
                obj.itlvaddrRAM=zeros(1,6144);
                obj.itlvaddr_cnt=0;
                obj.itlv_start_reg=false;



                obj.bufferA=cast(zeros(3,obj.WinSize),'like',extrinRef);
                obj.bufferB=cast(zeros(3,obj.WinSize),'like',extrinRef);

                inistru=struct('BB_Dr',false,'BB_Sc',false,'BB_En',false,...
                'Buffer_id',false,'beta_En_A',false,'beta_En_B',false,'alpha_En',false,...
                'En_extrinc',false,'decoder_id',false,'aprior_source',false);

                obj.centralcontrols_reg=[inistru,inistru,inistru];


                obj.llr_apriori=extrinRef;
                obj.llrInI=extrinRef;




                obj.offsetValue=cast(offset,'like',stmetRef);
                obj.betaInIValue=cast(zeros(8,1),'like',stmetRef);
                obj.alphaInIValue=cast([0;inistmet*ones(7,1)],'like',obj.offsetValue);
                obj.alphaDec=cast(zeros(8,1),'like',obj.offsetValue);
                obj.alpha_reg=cast(zeros(8,1),'like',obj.offsetValue);
                obj.acmp_reg=false(8,1);
                obj.aor_reg=false;
                obj.aoffset_reg=cast(zeros(4,2),'like',obj.offsetValue);
                obj.agamma_reg=cast(zeros(4,2),'like',obj.offsetValue);
                obj.agammaIn_reg=cast(zeros(4,1),'like',obj.offsetValue);
                obj.aen_reg=false(1,3);



                obj.betaADec=cast(zeros(8,1),'like',obj.offsetValue);
                obj.betaA_reg=cast(zeros(8,1),'like',obj.offsetValue);
                obj.bAcmp_reg=false(8,1);
                obj.bAor_reg=false;
                obj.bAoffset_reg=cast(zeros(4,2),'like',obj.offsetValue);
                obj.bAgamma_reg=cast(zeros(4,2),'like',obj.offsetValue);
                obj.bAgammaIn_reg=cast(zeros(4,1),'like',obj.offsetValue);
                obj.bAen_reg=false(1,3);


                obj.betaBDec=cast(zeros(8,1),'like',obj.offsetValue);
                obj.betaB_reg=cast(zeros(8,1),'like',obj.offsetValue);
                obj.bBcmp_reg=false(8,1);
                obj.bBor_reg=false;
                obj.bBoffset_reg=cast(zeros(4,2),'like',obj.offsetValue);
                obj.bBgamma_reg=cast(zeros(4,2),'like',obj.offsetValue);
                obj.bBgammaIn_reg=cast(zeros(4,1),'like',obj.offsetValue);
                obj.bBen_reg=false(1,3);


                obj.alpharam=cast(zeros(8,2*obj.WinSize),'like',obj.offsetValue);
                obj.alpha_addr_W_reg=zeros(1,6);
                obj.alpha_addr_R_reg=zeros(1,6);


                obj.beta_sel_reg=false(1,3);
                obj.extrinsic_En_reg=false(1,3);
                obj.extrinDataIn_reg=cast(zeros(3,3),'like',obj.llrInI);

                obj.decision_reg=false;
                obj.extrinsic_reg=cast(0,'like',obj.llrInI);


                obj.Nreadaddr=1;
                obj.FSMstate_outctrl=false;


                obj.extrinsicram=zeros(2,2^13);
                obj.extrinRAM_w_addr_reg=zeros(1,70);
                obj.extrinRAM_r_addr_reg=zeros(1,2);











                delay_match=4+24*obj.NumIterations;
                obj.dataOut_reg=false(1,delay_match);
                obj.valid_reg=false(1,2+delay_match);
                obj.start_reg=false(1,2+delay_match);
                obj.end_reg=false(1,2+delay_match);
            end
        end





        function readBlockSize(obj,blkSize)


            validblkSize=[40:8:512,528:16:1024,1056:32:2048,2112:64:6144];
            blkSize_actual=double(blkSize);

            coder.internal.errorIf(~ismember(blkSize_actual,validblkSize),'whdl:TurboCode:InvalidLTEBlockSize',blkSize_actual);

            obj.BLen=blkSize_actual;
            obj.BLen_ext=ceil(obj.BLen/obj.WinSize)*obj.WinSize;


        end


        function[datasource,w_addr,w_en,decoding_start]...
            =DataRAMControlerold(obj,startIn)






















            w_addr=obj.Nextwriteaddr;






            if obj.Nextwriteaddr==obj.WinSize
                decoding_start=true;
            else
                decoding_start=false;
            end

            if~obj.FSMstate_write

                w_en=startIn;
                datasource=true;
                if startIn
                    obj.FSMstate_write=true;
                    obj.Nextwriteaddr=2;
                else
                    obj.FSMstate_write=false;
                    obj.Nextwriteaddr=1;
                end
            else
                w_en=true;
                if obj.Nextwriteaddr<obj.BLen_ext+obj.WinSize+3
                    if obj.Nextwriteaddr<=obj.BLen+6
                        datasource=true;
                    else
                        datasource=false;
                    end
                    obj.FSMstate_write=true;
                    obj.Nextwriteaddr(:)=obj.Nextwriteaddr+1;
                else
                    datasource=false;
                    obj.FSMstate_write=false;
                    obj.Nextwriteaddr=1;
                end
            end

        end

        function[datasource,w_addr,w_en,decoding_start]...
            =DataRAMControler(obj,startIn,validIn,endIn)






















            obj.lastsample=false;

            if validIn

                if startIn
                    obj.inMessage=true;
                    obj.FSMstate_write=false;
                    obj.Nextwriteaddr=1;
                    obj.FSMstate_decoding=4;

                elseif endIn
                    if obj.inMessage
                        obj.inMessage=false;
                        obj.lastsample=true;
                    end
                end
            end
            w_addr=obj.Nextwriteaddr;




            t=endIn&&obj.lastsample&&(obj.Nextwriteaddr~=obj.BLen+4)&&obj.FSMstate_write;
            coder.internal.errorIf(t,...
            'whdl:TurboCode:InvalidDataLength',...
            obj.Nextwriteaddr,obj.BLen+4);










            if obj.Nextwriteaddr==obj.BLen+4
                decoding_start=true;
            else
                decoding_start=false;
            end

            if~obj.FSMstate_write

                w_en=startIn;
                datasource=true;
                if startIn
                    obj.FSMstate_write=true;
                    obj.Nextwriteaddr=2;
                else
                    obj.FSMstate_write=false;
                    obj.Nextwriteaddr=1;
                end
            else




                if obj.Nextwriteaddr<obj.BLen_ext+2*obj.WinSize+3

                    obj.FSMstate_write=true;
                    w_en=true;
                    if obj.Nextwriteaddr<=obj.BLen+6
                        datasource=true;
                        if obj.inMessage||obj.lastsample
                            if validIn
                                obj.Nextwriteaddr(:)=obj.Nextwriteaddr+1;
                            else
                                w_en=false;
                            end
                        else
                            obj.Nextwriteaddr(:)=obj.Nextwriteaddr+1;
                        end

                    else
                        datasource=false;
                        obj.Nextwriteaddr(:)=obj.Nextwriteaddr+1;
                    end

                else
                    datasource=false;
                    obj.FSMstate_write=false;
                    obj.Nextwriteaddr=1;
                    w_en=false;
                end

            end

        end


        function wdata=formatinputdata(obj,dataIn,w_addr)
            wdata=cast(zeros(1,3),'like',dataIn(1));
            blkLen=obj.BLen;

            if w_addr<=blkLen
                wdata=dataIn;

            else
                switch w_addr
                case blkLen+1
                    wdata(1)=dataIn(1);
                    obj.sysbuffer(1)=dataIn(3);
                    wdata(2)=dataIn(2);
                case blkLen+2
                    wdata(1)=obj.sysbuffer(1);
                    obj.sysbuffer(1)=dataIn(2);
                    wdata(2)=dataIn(1);
                    obj.p1buffer(1)=dataIn(3);
                case blkLen+3
                    wdata(1)=obj.sysbuffer(1);
                    obj.sysbuffer(1)=dataIn(1);
                    obj.sysbuffer(2)=dataIn(3);
                    wdata(2)=obj.p1buffer(1);
                    obj.p2buffer(1)=dataIn(2);
                case blkLen+4
                    wdata(1)=obj.sysbuffer(1);
                    obj.sysbuffer(1)=obj.sysbuffer(2);
                    obj.sysbuffer(2)=dataIn(2);
                    wdata(2)=obj.p1buffer(1);
                    wdata(3)=obj.p2buffer(1);
                    obj.p2buffer(1)=dataIn(1);
                    obj.p2buffer(2)=dataIn(3);
                otherwise
                    wdata(1)=obj.sysbuffer(1);
                    obj.sysbuffer(1)=obj.sysbuffer(2);
                    wdata(2)=obj.p1buffer(1);
                    wdata(3)=obj.p2buffer(1);
                    obj.p2buffer(1)=obj.p2buffer(2);

                end
            end

        end



        function[sysOut,p1Out,p2Out]=RAMgroup(obj,dataIn,dataSource,w_en,w_addr,r_sys_addr,r_p_addr)
            if dataSource
                sysin=dataIn(1);
                p1in=dataIn(2);
                p2in=dataIn(3);
            else
                sysin=obj.iniValue;
                p1in=obj.iniValue;
                p2in=obj.iniValue;

            end





            if r_sys_addr==0
                r_sys_addr=1;
            end

            if r_p_addr==0
                r_p_addr=1;
            end

            sysOut=obj.sysOut_reg;
            p1Out=obj.p1Out_reg;
            p2Out=obj.p2Out_reg;

            obj.sysOut_reg=obj.sysram(:,r_sys_addr);
            obj.p1Out_reg=obj.p1ram(:,r_p_addr);
            obj.p2Out_reg=obj.p2ram(:,r_p_addr);

            if w_en
                obj.sysram(:,w_addr)=sysin;
                obj.p1ram(:,w_addr)=p1in;
                obj.p2ram(:,w_addr)=p2in;

            end



        end



        function[r_addr,interleaver_start,centralcontrols,alpha_addr_R,alpha_addr_W,address_source,OutputStart]...
            =centralControler(obj,decoding_start)
























































            inter_decoder_delay=3;


            if(obj.Nextreadaddr>(obj.BLen+3)&&~obj.decoder_id_reg)||(obj.Nextreadaddr>obj.BLen&&obj.decoder_id_reg)
                r_addr=obj.Nextreadaddr+3;


            else
                r_addr=obj.Nextreadaddr;
            end

            BB_Dr=~obj.Buffer_id_reg;
            BB_Sc=~obj.Buffer_id_reg;
            BB_En=obj.BB_En_reg;
            Buffer_id=obj.Buffer_id_reg;

            En_extrinc=obj.En_extrinc_reg;
            decoder_id=obj.decoder_id_reg;

            if obj.Nextreadaddr>(obj.BLen)
                aprior_source=false;
            elseif(obj.Current_Iter_Id>1)||obj.decoder_id_reg
                aprior_source=true;
            else
                aprior_source=false;
            end

            alpha_addr_R=obj.WinSize*2-1-obj.Nextwriteaddr_alpha;
            alpha_addr_W=obj.Nextwriteaddr_alpha;




            if(~obj.decoder_id_reg)||(obj.Nextreadaddr>obj.BLen)
                address_source=false;
            else
                address_source=true;
            end



            switch obj.FSMstate_decoding
            case 0
                beta_En_A=false;
                beta_En_B=false;
                alpha_En=false;
                OutputStart=false;
                interleaver_start=false;
                obj.decoder_id_reg=false;
                if decoding_start
                    obj.FSMstate_decoding=1;
                    obj.Nextreadaddr(:)=obj.WinSize;
                    obj.ReadCount=1;
                    obj.BB_En_reg=true;
                    obj.Current_Iter_Id=1;
                else
                    obj.Current_Iter_Id=0;
                    obj.FSMstate_decoding=0;
                    obj.Nextreadaddr=0;
                    obj.ReadCount=0;
                    obj.BB_En_reg=false;
                end
                obj.Buffer_id_reg=false;
                obj.En_extrinc_reg=false;
                obj.beta_A_or_B=false;
                obj.Nextwriteaddr_alpha=0;
                obj.sleeping_count=0;
            case 1
                beta_En_A=false;
                beta_En_B=false;
                alpha_En=false;
                OutputStart=false;
                interleaver_start=false;
                obj.BB_En_reg=true;
                obj.Nextwriteaddr_alpha=0;
                obj.En_extrinc_reg=false;
                obj.beta_A_or_B=false;
                obj.sleeping_count=0;

                if obj.ReadCount==obj.WinSize

                    obj.FSMstate_decoding=2;
                    obj.Nextreadaddr(:)=obj.Nextreadaddr+obj.WinSize+obj.WinSize-1;
                    obj.ReadCount=1;
                    obj.Buffer_id_reg=~obj.Buffer_id_reg;








                else
                    obj.FSMstate_decoding=1;

                    if(obj.inMessage||obj.lastsample)&&obj.Nextreadaddr>=obj.Nextwriteaddr-1
                        obj.BB_En_reg=false;
                    else
                        obj.Nextreadaddr(:)=obj.Nextreadaddr-1;
                        obj.ReadCount(:)=obj.ReadCount+1;
                    end




                end

            case 2
                if obj.ReadCount==obj.WinSize


                    beta_En_A=~obj.beta_A_or_B;
                    beta_En_B=obj.beta_A_or_B;





                else
                    beta_En_A=true;
                    beta_En_B=true;
                end
                alpha_En=true;
                OutputStart=false;
                interleaver_start=false;
                obj.BB_En_reg=true;
                obj.sleeping_count=0;

                if obj.ReadCount==obj.WinSize
                    if obj.Nextreadaddr==obj.BLen_ext+obj.WinSize+1
                        obj.FSMstate_decoding=3;
                        obj.Nextreadaddr(:)=obj.WinSize;
                        obj.En_extrinc_reg=false;
                        obj.Buffer_id_reg=false;
                        obj.ReadCount=1;
                    else
                        obj.FSMstate_decoding=2;

                        obj.beta_A_or_B=~obj.beta_A_or_B;
                        obj.Nextreadaddr(:)=obj.Nextreadaddr+obj.WinSize+obj.WinSize-1;
                        obj.En_extrinc_reg=true;
                        obj.Buffer_id_reg=~obj.Buffer_id_reg;











                    end
                    obj.ReadCount=1;
                else

                    obj.FSMstate_decoding=2;

                    if(obj.inMessage||obj.lastsample)&&obj.Nextreadaddr>=obj.Nextwriteaddr-1
                        alpha_En=false;
                        beta_En_A=false;
                        beta_En_B=false;
                        obj.BB_En_reg=false;
                    else
                        obj.Nextreadaddr(:)=obj.Nextreadaddr-1;
                        obj.ReadCount(:)=obj.ReadCount+1;
                    end



                end
                if alpha_En
                    if obj.Nextwriteaddr_alpha==obj.WinSize+obj.WinSize-1
                        obj.Nextwriteaddr_alpha=0;
                    else
                        obj.Nextwriteaddr_alpha(:)=obj.Nextwriteaddr_alpha+1;
                    end
                end

            case 3
                beta_En_A=false;
                beta_En_B=false;
                alpha_En=false;
                obj.beta_A_or_B=false;

                if obj.sleeping_count<inter_decoder_delay


                    obj.sleeping_count(:)=obj.sleeping_count+1;
                    obj.FSMstate_decoding=3;
                    obj.Nextreadaddr(:)=obj.WinSize;
                    OutputStart=false;
                    interleaver_start=false;
                else
                    obj.sleeping_count=0;
                    if obj.decoder_id_reg
                        interleaver_start=false;
                        if obj.Current_Iter_Id==obj.NumIterations
                            obj.FSMstate_decoding=0;
                            obj.Nextreadaddr=1;
                            OutputStart=true;
                        else
                            obj.FSMstate_decoding=1;
                            obj.Current_Iter_Id(:)=obj.Current_Iter_Id+1;
                            obj.Nextreadaddr(:)=obj.WinSize;
                            OutputStart=false;
                        end
                    else
                        interleaver_start=true;
                        obj.FSMstate_decoding=1;
                        obj.Nextreadaddr(:)=obj.WinSize;
                        OutputStart=false;
                    end
                    obj.decoder_id_reg=~obj.decoder_id_reg;
                end
                obj.ReadCount=1;
                obj.Buffer_id_reg=false;
                obj.En_extrinc_reg=false;
            otherwise
                beta_En_A=false;
                beta_En_B=false;
                alpha_En=false;
                OutputStart=false;
                interleaver_start=false;
                obj.decoder_id_reg=false;
                obj.beta_A_or_B=false;
                obj.FSMstate_decoding=0;
                obj.Nextreadaddr=0;
                obj.ReadCount=1;
                obj.Nextwriteaddr_alpha=0;
                obj.BB_En_reg=false;
                obj.En_extrinc_reg=false;
                obj.Buffer_id_reg=false;
                obj.sleeping_count=0;
            end




            centralcontrols.BB_Dr=BB_Dr;
            centralcontrols.BB_Sc=BB_Sc;
            centralcontrols.BB_En=BB_En;
            centralcontrols.Buffer_id=Buffer_id;
            centralcontrols.beta_En_A=beta_En_A;
            centralcontrols.beta_En_B=beta_En_B;
            centralcontrols.alpha_En=alpha_En;
            centralcontrols.En_extrinc=En_extrinc;
            centralcontrols.decoder_id=decoder_id;
            centralcontrols.aprior_source=aprior_source;


        end


        function[RST_Head,EN_Head,RST_Body]=InterleaverController(obj,start)























            switch obj.FSMstate
            case ufi(0,1,0)
                RST_Head=false;
                EN_Head=false;
                RST_Body=false;
                if start
                    obj.FSMstate=ufi(1,1,0);
                    obj.total_count=ufi(1,13,0);
                    obj.local_count=ufi(1,13,0);
                else
                    obj.FSMstate=ufi(0,1,0);
                    obj.total_count=ufi(0,13,0);
                    obj.local_count=ufi(0,13,0);
                end
            otherwise
                RST_Head=true;
                if obj.local_count==ufi(1,13,0)
                    EN_Head=true;
                else
                    EN_Head=false;
                end
                if obj.local_count==obj.WinSize
                    RST_Body=false;
                else
                    RST_Body=true;
                end
                if obj.total_count<obj.BLen_ext
                    obj.FSMstate=ufi(1,1,0);
                    obj.total_count(:)=obj.total_count+ufi(1,13,0);
                else
                    obj.FSMstate=ufi(0,1,0);
                    obj.total_count=ufi(0,13,0);
                end
                if obj.local_count<obj.WinSize
                    obj.local_count(:)=obj.local_count+ufi(1,13,0);
                else
                    obj.local_count=ufi(1,13,0);
                end
            end


        end


        function itlvaddr=ComputeInterleaverAddr(obj,startIn,itlv_start)

            blkLen=obj.BLen;
            if startIn

                [f1,f2]=getltef1f2(blkLen);




                indices=zeros(1,blkLen);
                temp=f1+f2;


                for i=2:blkLen


                    indices(i)=indices(i-1)+temp;
                    if indices(i)>=blkLen
                        indices(i)=indices(i)-blkLen;
                    end
                    temp=temp+2*f2;
                    if temp>=2*blkLen
                        temp=temp-2*blkLen;
                    elseif temp>=blkLen
                        temp=temp-blkLen;
                    end
                end
                indices=indices+1;

                obj.itlvaddrRAM(1,1:obj.BLen_ext)=[indices,indices(1:(obj.BLen_ext-blkLen))];
            end

            localcnt=obj.itlvaddr_cnt;
            if obj.itlv_start_reg||(localcnt>0&&localcnt<obj.BLen_ext)

                idx1=floor(localcnt/32);
                outidx=2*32*idx1+32-localcnt;

                itlvaddr=obj.itlvaddrRAM(outidx);
                localcnt=localcnt+1;
                obj.itlvaddr_cnt=localcnt;
            else
                itlvaddr=obj.itlvaddrRAM(32);
                obj.itlvaddr_cnt=0;
            end
            obj.itlv_start_reg=itlv_start;
        end


        function itlvaddr=ComputeInterleaverAddr_codegen(obj,startIn,itlv_start,address_src)

            blkLen=obj.BLen;
            if startIn

                [f1,f2]=getltef1f2(blkLen);





                temp=f1+f2;
                i=2;


                indices_prev=0;
                obj.itlvaddrRAM(1)=1;

                while(i<=blkLen)

                    indices_current=indices_prev+temp;
                    if indices_current>=blkLen
                        indices_current=indices_current-blkLen;
                    end
                    temp=temp+2*f2;
                    if temp>=2*blkLen
                        temp=temp-2*blkLen;
                    elseif temp>=blkLen
                        temp=temp-blkLen;
                    end

                    obj.itlvaddrRAM(1,i)=indices_current+1;
                    i=i+1;
                    indices_prev=indices_current;
                end







            end

            localcnt=obj.itlvaddr_cnt;
            if obj.itlv_start_reg||(localcnt>0&&localcnt<obj.BLen_ext)

                idx1=floor(localcnt/32);
                outidx=2*32*idx1+32-localcnt;
                if address_src
                    itlvaddr=obj.itlvaddrRAM(outidx);
                else
                    itlvaddr=obj.itlvaddrRAM(32);
                end
                localcnt=localcnt+1;
                obj.itlvaddr_cnt=localcnt;
            else
                itlvaddr=obj.itlvaddrRAM(32);
                obj.itlvaddr_cnt=0;
            end
            obj.itlv_start_reg=itlv_start;
























        end


        function dataOut=BiBuffer(obj,dataIn,direction,source,En,bufferSource)






















            if bufferSource==1
                buffer=obj.bufferA;
            else
                buffer=obj.bufferB;
            end

            if En
                if direction
                    dataOut=buffer(:,end);
                    if source
                        datatemp=dataIn;
                    else
                        datatemp=buffer(:,end);
                    end
                    buffer=[datatemp,buffer(:,1:end-1)];
                else
                    dataOut=buffer(:,1);
                    if source
                        datatemp=dataIn;
                    else
                        datatemp=buffer(:,1);
                    end
                    buffer=[buffer(:,2:end),datatemp];
                end
            else
                dataOut=buffer(:,end);
            end

            if bufferSource==1
                obj.bufferA=buffer;
            else
                obj.bufferB=buffer;
            end
        end


        function gamma=gammaCaculator(obj,dataIn)

            temp=dataIn(2)+dataIn(3);
            prc=dataIn(1);
            gamma=cast(zeros(4,1),'like',obj.offsetValue);

            gamma(1)=-prc-temp;
            gamma(2)=temp-prc;
            gamma(3)=prc-temp;
            gamma(4)=prc+temp;
            if obj.floatType
                gamma=gamma/2;
            else
                gamma=bitshift(gamma,-1);
            end
        end


        function alphabetaOut=alphabetaCaculator(obj,gammaIn,enb,mode)


            offside=12;
            threshold=20;%#ok<PROPLC>
            infValue=-40;
            iniValue=zeros(8,1);%#ok<PROPLC>
            switch mode
            case 1
                iniValue(2:end)=infValue;%#ok<PROPLC>
                compDec=obj.alphaDec;
                comp_reg=obj.alpha_reg;
                gammaIdx1=[1,1,3,3,3,3,1,1];
                gammaIdx2=[4,4,2,2,2,2,4,4];
                alphaIdx1=[1,5,2,6,7,3,8,4];
                alphaIdx2=[5,1,6,2,3,7,4,8];
            case 2
                compDec=obj.betaADec;
                comp_reg=obj.betaA_reg;
                gammaIdx1=[1,3,3,1,1,3,3,1];
                gammaIdx2=[4,2,2,4,4,2,2,4];
                alphaIdx1=[1,3,6,8,2,4,5,7];
                alphaIdx2=[2,4,5,7,1,3,6,8];
            case 3
                compDec=obj.betaBDec;
                comp_reg=obj.betaB_reg;
                gammaIdx1=[1,3,3,1,1,3,3,1];
                gammaIdx2=[4,2,2,4,4,2,2,4];
                alphaIdx1=[1,3,6,8,2,4,5,7];
                alphaIdx2=[2,4,5,7,1,3,6,8];

            otherwise
                compDec=obj.alphaDec;
                comp_reg=obj.alpha_reg;
            end


            alphabetaOut=comp_reg;

            if sum(compDec>threshold)>0 %#ok<PROPLC>
                gamma_norm=gammaIn-offside;
            else
                gamma_norm=gammaIn;
            end



            gamma1=gamma_norm(gammaIdx1);
            gamma2=gamma_norm(gammaIdx2);



            alpha1=comp_reg(alphaIdx1);
            alpha2=comp_reg(alphaIdx2);

            add1=gamma1+alpha1;
            add2=gamma2+alpha2;

            dec=max(add1,add2);


            if any(dec>=64)
                dec=dec;%#ok<ASGSL>
            end

            if enb
                alphabeta=dec;
            else
                alphabeta=iniValue;%#ok<PROPLC>
            end




            switch mode
            case 1
                obj.alphaDec=dec;
                obj.alpha_reg=alphabeta;
            case 2
                obj.betaADec=dec;
                obj.betaA_reg=alphabeta;
            case 3
                obj.betaBDec=dec;
                obj.betaB_reg=alphabeta;
            otherwise
                obj.alphaDec=dec;
                obj.alpha_reg=alphabeta;
            end


        end

        function betaAOut=alphabeta_delay(obj,gammaIn,enb,mode)






            coder.extrinsic('sprintf');
            abInIValue=obj.betaInIValue;

            switch mode
            case 1
                abInIValue=obj.alphaInIValue;
                compDec=obj.alphaDec;
                alphabeta_reg=obj.alpha_reg;
                gammaIn_reg=obj.agammaIn_reg;
                or_reg=obj.aor_reg;
                offset_reg=obj.aoffset_reg;
                gamma_reg=obj.agamma_reg;
                en_reg=obj.aen_reg;
                cmp_reg=obj.acmp_reg;

                gammaIdx1=[1,1,3,3,3,3,1,1];
                gammaIdx2=[4,4,2,2,2,2,4,4];
                alphaIdx1=[1,5,2,6,7,3,8,4];
                alphaIdx2=[5,1,6,2,3,7,4,8];
            case 2

                compDec=obj.betaADec;
                alphabeta_reg=obj.betaA_reg;
                gammaIn_reg=obj.bAgammaIn_reg;
                or_reg=obj.bAor_reg;
                offset_reg=obj.bAoffset_reg;
                gamma_reg=obj.bAgamma_reg;
                en_reg=obj.bAen_reg;
                cmp_reg=obj.bAcmp_reg;

                gammaIdx1=[1,3,3,1,1,3,3,1];
                gammaIdx2=[4,2,2,4,4,2,2,4];
                alphaIdx1=[1,3,6,8,2,4,5,7];
                alphaIdx2=[2,4,5,7,1,3,6,8];
            case 3
                compDec=obj.betaBDec;
                alphabeta_reg=obj.betaB_reg;
                gammaIn_reg=obj.bBgammaIn_reg;
                or_reg=obj.bBor_reg;
                offset_reg=obj.bBoffset_reg;
                gamma_reg=obj.bBgamma_reg;
                en_reg=obj.bBen_reg;
                cmp_reg=obj.bBcmp_reg;

                gammaIdx1=[1,3,3,1,1,3,3,1];
                gammaIdx2=[4,2,2,4,4,2,2,4];
                alphaIdx1=[1,3,6,8,2,4,5,7];
                alphaIdx2=[2,4,5,7,1,3,6,8];

            otherwise
                compDec=obj.alphaDec;
                alphabeta_reg=obj.alpha_reg;
                gammaIn_reg=obj.agammaIn_reg;
                or_reg=obj.aor_reg;
                offset_reg=obj.aoffset_reg;
                gamma_reg=obj.agamma_reg;
                en_reg=obj.aen_reg;
                cmp_reg=obj.acmp_reg;
            end

            betaAOut=alphabeta_reg;



            gamma1=gammaIn_reg(gammaIdx1);
            gamma2=gammaIn_reg(gammaIdx2);

            alpha1=alphabeta_reg(alphaIdx1);
            alpha2=alphabeta_reg(alphaIdx2);

            add1=gamma1+alpha1;
            add2=gamma2+alpha2;

            dec=max(add1,add2);





            if or_reg
                gammaNorm=offset_reg(:,2);
            else
                gammaNorm=gamma_reg(:,2);
            end

            or_reg=sum(cmp_reg)>0;
            cmp_reg=compDec>obj.threshold;
            compDec=dec;
            gammaIn_reg=gammaNorm;
            offset_reg(:,2)=offset_reg(:,1);
            offset_reg(:,1)=gammaIn-obj.offsetValue;
            gamma_reg(:,2)=gamma_reg(:,1);
            gamma_reg(:,1)=gammaIn;


            if en_reg(3)
                alphabeta_reg=dec;
            else
                alphabeta_reg=abInIValue;
            end

            en_reg(2:3)=en_reg(1:2);
            en_reg(1)=enb;


            switch mode
            case 1
                obj.alphaDec=compDec;
                obj.alpha_reg=alphabeta_reg;
                obj.agammaIn_reg=gammaIn_reg;
                obj.aor_reg=or_reg;
                obj.aoffset_reg=offset_reg;
                obj.agamma_reg=gamma_reg;
                obj.aen_reg=en_reg;
                obj.acmp_reg=cmp_reg;

            case 2
                obj.betaADec=compDec;
                obj.betaA_reg=alphabeta_reg;
                obj.bAgammaIn_reg=gammaIn_reg;
                obj.bAor_reg=or_reg;
                obj.bAoffset_reg=offset_reg;
                obj.bAgamma_reg=gamma_reg;
                obj.bAen_reg=en_reg;
                obj.bAcmp_reg=cmp_reg;
            case 3
                obj.betaBDec=dec;
                obj.betaB_reg=alphabeta_reg;
                obj.bBgammaIn_reg=gammaIn_reg;
                obj.bBor_reg=or_reg;
                obj.bBoffset_reg=offset_reg;
                obj.bBgamma_reg=gamma_reg;
                obj.bBen_reg=en_reg;
                obj.bBcmp_reg=cmp_reg;

            otherwise
                obj.alphaDec=compDec;
                obj.alpha_reg=alphabeta_reg;
                obj.agammaIn_reg=gammaIn_reg;
                obj.aor_reg=or_reg;
                obj.aoffset_reg=offset_reg;
                obj.agamma_reg=gamma_reg;
                obj.aen_reg=en_reg;
                obj.acmp_reg=cmp_reg;
            end



        end









        function dataOut=alphaRAM(obj,dataIn,waddr,wenb,raddr)

            dataOut=obj.alpharam(:,raddr+1);
            if wenb
                obj.alpharam(:,waddr+1)=dataIn;
            end

        end



        function[extrinsic,decision]=extrinsicInfo(obj,alpha,beta,enb,data)




            beta1=beta([2,4,5,7,1,3,6,8]);
            beta2=beta([1,3,6,8,2,4,5,7]);


            prcdata=cast(data(1),'like',0);
            prc1=0.5*prcdata.*[1,-1,-1,1,1,-1,-1,1]';
            prc2=0.5*prcdata.*[-1,1,1,-1,-1,1,1,-1]';
            alphadata=cast(alpha,'like',0);
            beta1data=cast(beta1,'like',0);
            beta2data=cast(beta2,'like',0);

            sum1=alphadata+beta1data+prc1;
            sum2=alphadata+beta2data+prc2;
            t=max(sum1)-max(sum2);



            tfi=cast(t,'like',obj.extrinInI);
            post_sys_bit=cast(tfi,'like',obj.llrInI);


            if enb

                extrinsic=post_sys_bit;

            else
                extrinsic=obj.llrInI;

            end


            decision=(post_sys_bit+data(2)+data(3))>=0;

        end



        function[addr,startOut,endOut,validOut]=OutputController(obj,start,BLen)



            addr=obj.Nreadaddr;

            if~obj.FSMstate_outctrl

                startOut=false;
                endOut=false;
                validOut=false;
                if start
                    obj.FSMstate_outctrl=true;
                else
                    obj.FSMstate_outctrl=false;
                end
            else
                if obj.Nreadaddr==1
                    startOut=true;
                else
                    startOut=false;
                end
                validOut=true;
                if obj.Nreadaddr<BLen
                    endOut=false;
                    obj.Nreadaddr(:)=obj.Nreadaddr+1;
                    obj.FSMstate_outctrl=true;
                else
                    endOut=true;
                    obj.Nreadaddr=1;
                    obj.FSMstate_outctrl=false;
                end
            end
        end



        function dataOut=extrinsicRAM(obj,dataIn,waddr,wenb,raddr)


            if raddr<=0
                raddr=1;
            end
            dataOut=obj.extrinsicram(:,raddr);
            if wenb
                if waddr==0
                    waddr=1;
                end
                obj.extrinsicram(:,waddr)=dataIn;
            end

        end


        function num=getNumInputsImpl(obj)
            num=2+strcmp(obj.BlockSizeSource,'Input port');
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end


        function icon=getIconImpl(~)

            icon='LTE Turbo Decoder';
        end


        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            if strcmp(obj.BlockSizeSource,'Input port')
                varargout{3}='blockSize';
            end
        end


        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';

        end

        function varargout=getOutputSizeImpl(obj)
            varargout=cell(1,getNumOutputs(obj));

            varargout{1}=1;
            varargout{2}=propagatedInputSize(obj,2);
        end

        function varargout=isOutputComplexImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=propagatedInputComplexity(obj,1);

        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout=cell(1,getNumOutputs(obj));

            varargout{1}='logical';

            varargout{2}=samplecontrolbustype;
        end

        function varargout=isOutputFixedSizeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputFixedSize(obj,1);
            varargout{2}=propagatedInputFixedSize(obj,2);
        end



        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if strcmp(prop,'BlockSize')&&strcmp(obj.BlockSizeSource,'Input port')
                flag=true;
            end
        end




        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked


                s.Algorithm='Max';
                s.Architecture='Fully Searial';



                s.BLen=obj.BLen;
                s.BLen_ext=obj.BLen_ext;


                s.inMessage=obj.inMessage;
                s.lastsample=obj.lastsample;

                s.FSMstate_write=obj.FSMstate_write;
                s.Nextwriteaddr=obj.Nextwriteaddr;


                s.Nextreadaddr=obj.Nextreadaddr;
                s.ReadCount=obj.ReadCount;
                s.FSMstate_decoding=obj.FSMstate_decoding;

                s.Current_Iter_Id=obj.Current_Iter_Id;
                s.sleeping_count=obj.sleeping_count;
                s.BB_En_reg=obj.BB_En_reg;
                s.Buffer_id_reg=obj.Buffer_id_reg;
                s.Nextwriteaddr_alpha=obj.Nextwriteaddr_alpha;
                s.En_extrinc_reg=obj.En_extrinc_reg;
                s.beta_A_or_B=obj.beta_A_or_B;


                s.decoder_id_reg=obj.decoder_id_reg;
                s.centralcontrols_reg=obj.centralcontrols_reg;
                s.llr_apriori=obj.llr_apriori;
                s.llrInI=obj.llrInI;
                s.extrinInI=obj.extrinInI;
                s.r_addr_reg=obj.r_addr_reg;
                s.r_sys_addr_reg=obj.r_sys_addr_reg;

                s.FSMstate=obj.FSMstate;
                s.total_count=obj.total_count;
                s.local_count=obj.local_count;
                s.itlvaddrRAM=obj.itlvaddrRAM;
                s.itlvaddr_cnt=obj.itlvaddr_cnt;
                s.itlv_start_reg=obj.itlv_start_reg;


                s.sysbuffer=obj.sysbuffer;
                s.p1buffer=obj.p1buffer;
                s.p2buffer=obj.p2buffer;


                s.sysram=obj.sysram;
                s.p1ram=obj.p1ram;
                s.p2ram=obj.p2ram;
                s.sysOut_reg=obj.sysOut_reg;
                s.p1Out_reg=obj.p1Out_reg;
                s.p2Out_reg=obj.p2Out_reg;
                s.iniValue=obj.iniValue;

                s.bufferA=obj.bufferA;
                s.bufferB=obj.bufferB;


                s.offsetValue=obj.offsetValue;
                s.alphaInIValue=obj.alphaInIValue;
                s.alphaDec=obj.alphaDec;
                s.alpha_reg=obj.alpha_reg;
                s.acmp_reg=obj.acmp_reg;
                s.aor_reg=obj.aor_reg;
                s.aoffset_reg=obj.aoffset_reg;
                s.agamma_reg=obj.agamma_reg;
                s.agammaIn_reg=obj.agammaIn_reg;
                s.aen_reg=obj.aen_reg;

                s.betaInIValue=obj.betaInIValue;
                s.betaADec=obj.betaADec;
                s.betaA_reg=obj.betaA_reg;
                s.bAcmp_reg=obj.bAcmp_reg;
                s.bAor_reg=obj.bAor_reg;
                s.bAoffset_reg=obj.bAoffset_reg;
                s.bAgamma_reg=obj.bAgamma_reg;
                s.bAgammaIn_reg=obj.bAgammaIn_reg;
                s.bAen_reg=obj.bAen_reg;

                s.betaBDec=obj.betaBDec;
                s.betaB_reg=obj.betaB_reg;
                s.bBcmp_reg=obj.bBcmp_reg;
                s.bBor_reg=obj.bBor_reg;
                s.bBoffset_reg=obj.bBoffset_reg;
                s.bBgamma_reg=obj.bBgamma_reg;
                s.bBgammaIn_reg=obj.bBgammaIn_reg;
                s.bBen_reg=obj.bBen_reg;

                s.alpharam=obj.alpharam;
                s.alpha_addr_W_reg=obj.alpha_addr_W_reg;
                s.alpha_addr_R_reg=obj.alpha_addr_R_reg;
                s.beta_sel_reg=obj.beta_sel_reg;
                s.extrinsic_En_reg=obj.extrinsic_En_reg;
                s.extrinDataIn_reg=obj.extrinDataIn_reg;
                s.decision_reg=obj.decision_reg;
                s.extrinsic_reg=obj.extrinsic_reg;


                s.Nreadaddr=obj.Nreadaddr;
                s.FSMstate_outctrl=obj.FSMstate_outctrl;


                s.extrinsicram=obj.extrinsicram;
                s.extrinRAM_w_addr_reg=obj.extrinRAM_w_addr_reg;
                s.extrinRAM_r_addr_reg=obj.extrinRAM_r_addr_reg;


                s.valid_reg=obj.valid_reg;
                s.start_reg=obj.start_reg;
                s.end_reg=obj.end_reg;
                s.dataOut_reg=obj.dataOut_reg;
            end
        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end




    end

    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end

end
