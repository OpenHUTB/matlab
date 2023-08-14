
classdef GenPirTb<handle
    properties
topCtx

isDutVHDL

hD

hP

dutN
topN

        bitT;
constTrue
constFalse

snkDone

dutBaseRate
dutOverclockingFactor
scalPorts
OriginalTargetLanguage

clockTable
dutDataInport
dutDataOutport

tbClkSignal
tbRstSignal
tbEnbSignal

dutCeout
dutClk
dutRst
dutEnb
dutOutValid
dpiRst
dpiEnb

dpiBaseRate

dpiRefSignal
    end

    methods
        function this=GenPirTb
            this.hD=hdlcurrentdriver;
            this.hP=pir;
            this.topCtx=this.hP.getTopPirCtx;
            this.dutN=this.topCtx.getTopNetwork;
        end

        function delete(this)
            if~isempty(this.hP)
                gp=pir;
                gp.setTopPirCtx(this.topCtx);
            end
        end


        function buildDUTPortMap(this)
            inPorts=this.dutN.PirInputPorts;
            this.dutDataInport=[];
            for ii=1:numel(inPorts)
                name=inPorts(ii).Name;
                hS=this.dutN.findSignal('name',name);
                switch inPorts(ii).Kind
                case 'clock'
                    this.dutClk=struct('Name',hS.Name,'Signal',hS);
                case 'reset'
                    this.dutRst=[this.dutRst,struct('Name',hS.Name,'Signal',hS)];
                case 'clock_enable'
                    this.dutEnb=struct('Name',hS.Name,'Signal',hS);
                case 'data'
                    tmp=this.topN.addSignal(hS.Type,name);
                    tmp.SimulinkRate=hS.SimulinkRate;
                    this.dutDataInport=[this.dutDataInport,struct('Name',hS.Name,'Signal',tmp)];
                end
            end

            outPorts=this.dutN.PirOutputPorts;
            this.dutCeout=[];
            for ii=1:numel(outPorts)
                name=outPorts(ii).Name;
                hS=this.dutN.findSignal('name',name);
                tmp=this.topN.addSignal(hS.Type,name);
                tmp.SimulinkRate=hS.SimulinkRate;
                switch outPorts(ii).Kind
                case 'clock_enable'
                    this.dutCeout=[this.dutCeout,struct('Name',hS.Name,'Signal',tmp)];
                case 'data'
                    this.dutDataOutport=[this.dutDataOutport,struct('Name',hS.Name,'Signal',tmp,'OutValid',[])];
                end
            end
        end

        function createDutBlackBox(this,dutEnable)
            inportNames=arrayfun(@(x)x.Name,this.dutDataInport,'UniformOutput',false);
            outportNames=arrayfun(@(x)x.Name,this.dutDataOutport,'UniformOutput',false);
            inportSignals=arrayfun(@(x)x.Signal,this.dutDataInport,'UniformOutput',false);
            outportSignals=arrayfun(@(x)x.Signal,this.dutDataOutport,'UniformOutput',false);
            if~isempty(this.dutClk)
                inportNames=[inportNames,this.dutClk.Name];
                inportSignals=[inportSignals,{this.tbClkSignal}];
            end
            if~isempty(this.dutRst)

                for m=1:length(this.dutRst)
                    inportNames=[inportNames,this.dutRst(m).Name];%#ok<AGROW>
                    inportSignals=[inportSignals,{this.tbRstSignal}];%#ok<AGROW>
                end
            end
            if~isempty(this.dutEnb)
                inportNames=[inportNames,this.dutEnb.Name];
                inportSignals=[inportSignals,{dutEnable}];
            end
            for ii=1:length(this.dutCeout)
                outportNames=[outportNames,this.dutCeout(ii).Name];%#ok<AGROW>
                outportSignals=[outportSignals,{this.dutCeout(ii).Signal}];%#ok<AGROW>
            end
            pirelab.getInstantiationComp('Network',this.topN,...
            'Name',this.dutN.name,'EntityName',this.dutN.name,...
            'InportNames',inportNames,'OutportNames',outportNames,...
            'InportSignals',[inportSignals{:}],'OutportSignals',[outportSignals{:}],...
            'AddClockPort','off','AddClockEnablePort','off','AddResetPort','off');
        end

        function generateOutValidSignal(this,dutEnable)

            for ii=1:numel(this.dutDataOutport)

                validName=[this.dutDataOutport(ii).Name,'_out_valid'];
                validSignal=this.topN.addSignal(this.bitT,validName);
                validSignal.SimulinkRate=this.dutBaseRate;


                rate=this.dutDataOutport(ii).Signal.SimulinkRate;
                if rate<this.dutBaseRate
                    rate=this.dutBaseRate;
                end
                if rate==Inf||rate==0
                    countLimit=1;
                else
                    countLimit=round(rate/this.dutBaseRate)*this.dutOverclockingFactor;
                end
                if countLimit==1
                    pirelab.getWireComp(this.topN,dutEnable,validSignal,[validName,'_wire']);
                else
                    wl=ceil(log2(countLimit+1));
                    dt=pir_fixpt_t(0,wl,0);
                    validCnt=this.topN.addSignal(dt,[this.dutDataOutport(ii).Name,'_out_cnt']);
                    pirelab.getCounterLimitedComp(this.topN,validCnt,countLimit-1,...
                    this.dutBaseRate,[this.dutDataOutport(ii).Name,'counter'],0,false,dutEnable);
                    cnt0=this.topN.addSignal(this.bitT,[this.dutDataOutport(ii).Name,'_cnt_zero']);
                    cnt0.SimulinkRate=this.dutBaseRate;
                    pirelab.getCompareToValueComp(this.topN,validCnt,cnt0,...
                    '==',0);
                    pirelab.getLogicComp(this.topN,[cnt0,dutEnable],validSignal,'and');
                end
                this.dutDataOutport(ii).OutValid=validSignal;
            end
        end


        function createDPIBlackBox(this,clock,reset,clken,dpiInfo)

            dpiDims=dpiInfo.PortDims;
            dpiPortNames=dpiInfo.PortNames;

            [scalarizedVect,dpiInSize,dpiOutSize]=l_getDPIPortSizes(this,dpiDims);
            dpiInS=hdlhandles(1,dpiInSize);
            dpiOutS=hdlhandles(1,dpiOutSize);

            vectOffset=1;
            for ii=1:numel(dpiInS)
                name=dpiPortNames{ii};
                dutType=this.dutDataInport(vectOffset).Signal.Type;
                [type,wlen]=l_getDPIBlackboxDataType(dutType,dpiDims(ii));
                dpiInS(ii)=this.topN.addSignal2(...
                'Type',type,...
                'Name',name);
                [tempType,dpiTempS]=createTempSignal(this,name,dpiDims,dutType,ii);
                pirelab.getBitSliceComp(this.topN,dpiInS(ii),dpiTempS,...
                wlen-1,0,['slicer',num2str(ii)]);
                if(dpiDims(ii)>1&&scalarizedVect)
                    dpiScalTempS=hdlhandles(1,dpiDims(ii));
                    for jj=1:dpiDims(ii)
                        dpiScalTempS(jj)=this.topN.addSignal2(...
                        'Type',tempType,...
                        'Name',[name,'_temp_',num2str(jj)]);
                    end
                    pirelab.getDemuxComp(this.topN,dpiTempS,dpiScalTempS(1:end));
                    for jj=1:dpiDims(ii)
                        pirelab.getDTCComp(this.topN,dpiScalTempS(jj),this.dutDataInport(jj+vectOffset-1).Signal,'Floor','Wrap','SI');
                    end
                    vectOffset=vectOffset+dpiDims(ii);
                else
                    pirelab.getDTCComp(this.topN,dpiTempS,this.dutDataInport(vectOffset).Signal,'Floor','Wrap','SI');
                    vectOffset=vectOffset+1;
                end
            end
            dpiInName=arrayfun(@(x)x.Name,dpiInS,'UniformOutput',false);

            this.dpiRefSignal=hdlhandles(1,length(this.dutDataOutport));
            vectOffset=1;

            for ii=1:numel(dpiOutS)
                name=dpiPortNames{ii+numel(dpiInS)};
                dutType=this.dutDataOutport(vectOffset).Signal.Type;
                [type,wlen]=l_getDPIBlackboxDataType(dutType,dpiDims(ii+numel(dpiInS)));
                dpiOutS(ii)=this.topN.addSignal2(...
                'Type',type,...
                'Name',name);
                [tempType,dpiTempS]=createTempSignal(this,name,dpiDims,dutType,ii+numel(dpiInS));
                pirelab.getBitSliceComp(this.topN,dpiOutS(ii),dpiTempS,...
                wlen-1,0,['slicer',num2str(ii)]);
                if(dpiDims(ii+numel(dpiInS))>1&&scalarizedVect)
                    dpiScalTempS=hdlhandles(1,dpiDims(ii+numel(dpiInS)));
                    for jj=1:dpiDims(ii+numel(dpiInS))
                        dpiScalTempS(jj)=this.topN.addSignal2(...
                        'Type',tempType,...
                        'Name',[name,'_',num2str(jj)]);
                    end
                    pirelab.getDemuxComp(this.topN,dpiTempS,dpiScalTempS(1:end));
                    for jj=1:dpiDims(ii+numel(dpiInS))
                        this.dpiRefSignal(jj+vectOffset-1)=this.topN.addSignal2(...
                        'Type',dutType,...
                        'Name',[this.dutDataOutport(jj+vectOffset-1).Signal.Name,'_ref']);
                        this.dpiRefSignal(jj+vectOffset-1).Preserve(true);
                        pirelab.getDTCComp(this.topN,dpiScalTempS(jj),this.dpiRefSignal(jj+vectOffset-1),'Floor','Wrap','SI');
                    end
                    vectOffset=vectOffset+dpiDims(ii+numel(dpiInS));
                else
                    this.dpiRefSignal(vectOffset)=this.topN.addSignal2(...
                    'Type',dutType,...
                    'Name',[this.dutDataOutport(ii).Signal.Name,'_ref']);
                    this.dpiRefSignal(vectOffset).Preserve(true);
                    pirelab.getDTCComp(this.topN,dpiTempS,this.dpiRefSignal(vectOffset),'Floor','Wrap','SI');
                    vectOffset=vectOffset+1;
                end

            end
            dpiOutName=arrayfun(@(x)x.Name,dpiOutS,'UniformOutput',false);


            dpiInName=[{'clk','reset','clk_enable'},dpiInName];
            dpiInS=[clock,reset,clken,dpiInS];




            validRate=isSecondMultipleOfFirst(this.dpiBaseRate,this.dutBaseRate);
            assert(validRate==1,'HDL DUT''s base rate must be integer multiple of DPI model''s base rate');
            loopFactor=round(this.dutBaseRate/this.dpiBaseRate);
            if this.dutOverclockingFactor<1
                overclocking=1;
            else
                overclocking=this.dutOverclockingFactor;
            end
            genericList=sprintf('{{''loop_factor'',''%d''},{''overclocking_factor'',''%d''}}',loopFactor,overclocking);

            pirelab.getInstantiationComp('Network',this.topN,...
            'Name',dpiInfo.ModuleName,'EntityName',dpiInfo.ModuleName,...
            'InportNames',dpiInName,'OutportNames',dpiOutName,...
            'InportSignals',dpiInS,'OutportSignals',dpiOutS,...
            'GenericList',genericList,...
            'AddClockPort','off','AddClockEnablePort','off','AddResetPort','off');

        end


        function getMasterClockBundle(this,topN,clkrate)

            allClocks=this.clockTable(arrayfun(@(x)x.Kind==0,this.clockTable));
            for ii=1:numel(allClocks)
                tempSig=topN.addSignal(this.bitT,'clk_exemplar');
                tempSig.SimulinkRate=clkrate*allClocks(ii).Ratio;
                if tempSig.SimulinkRate<0
                    tempSig.SimulinkRate=0;
                end
                [clock,clken,reset]=topN.getClockBundle(tempSig,1,1,0);
                topN.removeSignal(tempSig);
                clock.Reg=true;
                reset.Reg=true;
                reset.Preserve(true);


                this.tbClkSignal=clock;
                this.tbRstSignal=reset;
                this.tbEnbSignal=clken;
            end
        end

        function baseRate=getDUTBaseRate(this)








            baseRate=max([this.hP.DutBaseRate,this.hP.getOrigDutBaseRate]);
            if baseRate<=0
                sampleTime=this.hD.PirInstance.getModelSampleTimes;
                baseRate=min(sampleTime(sampleTime>0));
            elseif baseRate==Inf
                baseRate=this.dpiBaseRate;
            end
        end

        function[tReset,tPeriod]=createClockGenerators(this,topN,global_clk)
            baseRate=this.dutBaseRate;
            rdEnb=this.topN.addSignal(this.bitT,'rdEnb');
            rdEnb.Preserve(true);
            rdEnb.SimulinkRate=baseRate;
            srcDone=this.topN.addSignal(this.bitT,'srcDone');
            srcDone.SimulinkRate=baseRate;



            tHigh=this.hD.getParameter('force_clock_high_time');
            tLow=this.hD.getParameter('force_clock_low_time');
            tHold=this.hD.getParameter('force_hold_time');
            tPeriod=tHigh+tLow;
            resetHoldCycles=this.hD.getParameter('resetlength');

            allClocks=this.clockTable(arrayfun(@(x)x.Kind==0,this.clockTable));
            minRatio=allClocks(1).Ratio;
            for ii=1:numel(allClocks)
                clk=topN.findSignal('name',allClocks(ii).Name);
                if~isempty(clk)
                    hC=pirelab.getTBClockgenComp(topN,this.snkDone,clk,...
                    tHigh*allClocks(ii).Ratio,tLow*allClocks(ii).Ratio);
                    hC.setPreserve(true);
                end
                minRatio=min(minRatio,allClocks(ii).Ratio);
            end



            allResets=this.clockTable(arrayfun(@(x)x.Kind==1,this.clockTable));
            masterRstEntry=allResets(arrayfun(@(x)x.Ratio==minRatio,allResets));
            masterRst=topN.findSignal('name',masterRstEntry.Name);
            this.dpiRst=this.topN.addSignal(this.bitT,'dpiReset');
            this.dpiEnb=this.topN.addSignal(this.bitT,'dpiEnable');

            for ii=1:numel(allResets)
                if allResets(ii).Ratio==minRatio
                    tPeriod=(tHigh+tLow)*allResets(ii).Ratio;
                    if resetHoldCycles==0
                        tReset=tHold;
                    else
                        tReset=tPeriod*resetHoldCycles;
                    end
                    pirelab.getTBResetgenComp(topN,global_clk,masterRst,tReset+tPeriod);
                    pirelab.getTBResetgenComp(topN,global_clk,this.dpiRst,tReset);
                else
                    hSubRst=topN.findSignal('name',allResets(ii).Name);
                    if~isempty(hSubRst)
                        hSubRst.Reg=false;
                        pirelab.getWireComp(topN,masterRst,hSubRst);
                    end
                end
            end
        end

        function[dutEnable,dpiEnbDelay]=createEnableSignal(this)
            resetValue=this.hD.getParameter('force_reset_value');
            if resetValue==0
                enbValues=[this.constFalse,this.constTrue];
            else
                enbValues=[this.constTrue,this.constFalse];
            end
            pirelab.getSwitchComp(this.topN,enbValues,this.tbEnbSignal,this.tbRstSignal);
            pirelab.getSwitchComp(this.topN,enbValues,this.dpiEnb,this.dpiRst);

            dutEnable=this.topN.addSignal(this.tbEnbSignal.Type,'dutEnable');
            dpiEnbDelay=this.topN.addSignal(this.tbEnbSignal.Type,'dpiEnbDelay');
            if this.hD.getParameter('MinimizeClockEnables')&&this.hD.getParameter('ClockInputs')==1
                enableDelay=0;
            else
                enableDelay=this.hD.getParameter('TestBenchClockEnableDelay');
            end
            l_createPipelineRegComp(this.topN,enableDelay,this.tbEnbSignal,dutEnable,this.tbClkSignal,...
            this.tbRstSignal,'dut_enable_delay');
            l_createPipelineRegComp(this.topN,enableDelay,this.dpiEnb,dpiEnbDelay,this.tbClkSignal,...
            this.dpiRst,'dut_enable_delay');
        end

        function isTestFailed=createOutputChecker(this)
            testFailures=hdlhandles(1,numel(this.dutDataOutport));
            hN=this.topN;
            for ii=1:numel(this.dutDataOutport)
                testFailures(ii)=hN.addSignal(this.bitT,...
                [this.dutDataOutport(ii).Name,'_testFailure']);
                hS=this.dutDataOutport(ii).Signal;
                slRate=hS.SimulinkRate;
                testFailures(ii).SimulinkRate=slRate;
                testFailures(ii).Reg=true;
                hT=hS.Type;
                isVec=hT.isArrayType;
                isNFPMode=targetcodegen.targetCodeGenerationUtils.isNFPMode;
                if isVec&&isNFPMode&&hT.getLeafType.isFloatType
                    demuxC=pirelab.getDemuxCompOnInput(hN,hS);
                    inSigs=demuxC.PirOutputSignals;
                    this.dpiRefSignal(ii).SimulinkRate=slRate;
                    demuxC=pirelab.getDemuxCompOnInput(hN,this.dpiRefSignal(ii));
                    refSigs=demuxC.PirOutputSignals;
                    vecTestFails=hdlhandles(1,hT.Dimensions);
                    for jj=1:hT.Dimensions
                        refSigs(jj).SimulinkRate=slRate;
                        vecTestFails(jj)=hN.addSignal(this.bitT,...
                        sprintf('%s_%d',testFailures(ii).Name,jj));
                        pirelab.getTBCheckerComp(hN,...
                        [this.dutDataOutport(ii).OutValid,...
                        inSigs(jj),refSigs(jj)],vecTestFails(jj));
                    end
                    pirelab.getLogicComp(hN,vecTestFails,testFailures(ii),'or');
                else
                    pirelab.getTBCheckerComp(hN,...
                    [this.dutDataOutport(ii).OutValid,...
                    hS,this.dpiRefSignal(ii)],testFailures(ii));
                end
            end
            isTestFailed=hN.addSignal(this.bitT,'isTestFailed');
            if isempty(testFailures)
                pirelab.getConstComp(hN,isTestFailed,false);
            else
                pirelab.getLogicComp(hN,testFailures,isTestFailed,'or');
            end
        end

        function initTopN(this,tbName,tbpir)

            this.topN=tbpir.addNetwork;
            this.topN.Name=tbName;
            tbpir.setTopNetwork(this.topN);
            this.bitT=this.topN.getType('Logic','WordLength',1);
            this.constFalse=this.topN.addSignal(this.bitT,'const_false');
            this.constTrue=this.topN.addSignal(this.bitT,'const_true');
            pirelab.getConstComp(this.topN,this.constFalse,false);
            pirelab.getConstComp(this.topN,this.constTrue,true);
            this.snkDone=this.topN.addSignal(this.bitT,'snkDone');
            if isempty(this.dutBaseRate)
                error(message('HDLLink:GenerateSVDPITestbench:VariableStepSizeNotSupportedForSVDPITb'));
            end
            this.snkDone.SimulinkRate=this.dutBaseRate;
        end


        function tbFilesList=generateSVPirTb(this,tbName,codeGenDir,dpiInfo,OutputPortsST)
            this.dpiBaseRate=dpiInfo.BaseRate;


            this.dutBaseRate=getDUTBaseRate(this);
            if isempty(this.dutBaseRate)
                this.dutBaseRate=this.dpiBaseRate;
            else





                for iii=1:numel(this.dutN.SLOutputSignals)
                    if abs(abs(this.dutN.SLOutputSignals(iii).SimulinkRate/this.dutBaseRate)-abs(OutputPortsST{iii}/this.dutBaseRate))>1
                        warning(message('HDLLink:GenerateSVDPITestbench:MismatchInSTBetweenGMAndOriginalMdl',this.dutN.SLOutputSignals(iii).Name));
                    end
                end
            end

            if this.hP.getDutBaseRateScalingFactor<1
                this.dutOverclockingFactor=1;
            else
                this.dutOverclockingFactor=this.hP.getDutBaseRateScalingFactor;
            end

            this.isDutVHDL=strcmpi(this.hD.getParameter('target_language'),'vhdl');

            this.hP.destroyPirCtx(tbName);

            this.scalPorts=this.hP.getParamValue('ScalarizePorts');
            this.OriginalTargetLanguage=this.hP.getParamValue('target_language');
            paramStruct=struct('target_language','systemverilog','ScalarizePorts',0,...
            'FPToleranceStrategy',this.hD.getParameter('FPToleranceStrategy'),...
            'FPToleranceValue',this.hD.getParameter('FPToleranceValue'));
            this.hP.initParams(paramStruct);
            tbpir=pir(tbName,'testbench');


            initTopN(this,tbName,tbpir);

            buildDUTPortMap(this);

            tcinfo=this.hD.getTimingControllerInfo(0);
            this.clockTable=tcinfo.clockTable;

            getMasterClockBundle(this,this.topN,this.hP.DutBaseRate);
            [tReset,tPeriod]=createClockGenerators(this,this.topN,this.tbClkSignal);
            [dutEnable,dpiEnbDelay]=createEnableSignal(this);

            createDutBlackBox(this,dutEnable);
            createDPIBlackBox(this,this.tbClkSignal,this.dpiRst,dpiEnbDelay,dpiInfo);

            generateOutValidSignal(this,dutEnable);

            testFailure=createOutputChecker(this);


            numSamples=ceil(dpiInfo.SimTime/this.dutBaseRate);
            simTime=ceil(tReset/tPeriod)*tPeriod+tPeriod*this.dutOverclockingFactor*numSamples;
            pirelab.getTBTimeDelayComp(this.topN,this.constTrue,this.snkDone,simTime);
            pirelab.getTBCompletionComp(this.topN,[this.snkDone,testFailure],'');

            this.topN.flattenHierarchy;
            tbpir.createCGIR;
            tbpir.invokeBackEnd;
            tbpir.endEmission(codeGenDir);

            this.hD.setParameter('ScalarizePorts',this.scalPorts);
            paramStruct=struct('ScalarizePorts',this.scalPorts);
            this.hP.initParams(paramStruct);
            tbFilesList=this.hD.getEntityFileNames(tbpir);

            this.hP.destroyPirCtx(tbName);
            paramStruct=struct('target_language',this.OriginalTargetLanguage);
            this.hP.initParams(paramStruct);
        end

    end
end

function[type,wlen]=l_getDPIBlackboxDataType(dutType,dims)
    if(dims>1||dutType.isArrayType)
        arrtypef=pir_arr_factory_tc;
        if(dims>1)
            arrtypef.addDimension(dims);
        else
            arrtypef.addDimension(dutType.Dimensions);
        end
        baseType=l_getDPIBlackboxDataType(dutType.BaseType,0);
        arrtypef.addBaseType(baseType);
        type=pir_array_t(arrtypef);
        wlen=dutType.BaseType.WordLength;
    elseif dutType.isSingleType


        type=pir_fixpt_t(false,32,0);
        wlen=32;
    else
        type=pir_fixpt_t(dutType.Signed,l_getDPIWordLen(dutType.WordLength),dutType.FractionLength);
        wlen=dutType.BaseType.WordLength;
    end
end

function wlenout=l_getDPIWordLen(wlenin)
    assert(wlenin<=64);
    if wlenin>=1&&wlenin<=8
        wlenout=8;
    else
        tmp=ceil(log2(wlenin));
        wlenout=2^tmp;
    end
end

function hC=l_createPipelineRegComp(topN,delay,tb_enb,tb_enb_delay,...
    clock,reset,compName)
    if delay==0
        hC=pirelab.getWireComp(topN,tb_enb,tb_enb_delay,compName);
    else
        for ii=1:delay
            if ii==1
                inSig=tb_enb;
            else
                inSig=outSig;
            end
            if ii==delay
                outSig=tb_enb_delay;
            else
                outSig=topN.addSignal(tb_enb.Type,sprintf('%s_pipe%d',tb_enb.Name,ii));
            end


            hC=topN.addComponent2('kind','register','name',compName,...
            'datainput',inSig,'dataoutput',outSig,'clock',clock,'reset',reset,...
            'blockcomment',['Delay inside enable generation: register depth ',delay]);
        end
    end
end


function[scalarizedVect,dpiInSize,dpiOutSize]=l_getDPIPortSizes(this,dpiDims)
    if(~this.scalPorts&&this.isDutVHDL)
        scalarizedVect=0;
        dpiInSize=length(this.dutDataInport);
        dpiOutSize=length(this.dutDataOutport);
    else
        scalarizedVect=1;
        dpiCumSum=cumsum(dpiDims);
        if(isempty(this.dutDataInport))
            dpiInSize=0;
        else
            dpiInSize=find(dpiCumSum==length(this.dutDataInport));
        end
        if(isempty(this.dutDataOutport))
            dpiOutSize=0;
        else
            dpiOutSize=find(dpiCumSum==length(this.dutDataInport)+length(this.dutDataOutport))-dpiInSize;
        end
    end
end


function[tempType,dpiTempS]=createTempSignal(this,name,dpiDims,dutType,ii)
    if dutType.BaseType.isBooleanType
        tempType=dutType.BaseType;
    else
        tempType=pir_fixpt_t(0,dutType.BaseType.WordLength,0);
    end
    if(dpiDims(ii)>1)
        vectTempType=pirelab.createPirArrayType(tempType,[dpiDims(ii),0]);
        dpiTempS=this.topN.addSignal2(...
        'Type',vectTempType,...
        'Name',[name,'_temp']);
    else
        dpiTempS=this.topN.addSignal2(...
        'Type',tempType,...
        'Name',[name,'_temp']);
    end
end



