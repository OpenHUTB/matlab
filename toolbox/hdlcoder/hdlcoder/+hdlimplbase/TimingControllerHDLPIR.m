classdef TimingControllerHDLPIR<hdlimplbase.EmlImplBase






    methods
        function this=TimingControllerHDLPIR(block)
            supportedBlocks={...
            'HDLTimingController',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','PIR-based Timing Controller Internal Implementation',...
            'HelpText','PIR-based Timing Controller code generation via instantiation');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'CodeGenMode','instantiation',...
            'ArchitectureNames',{'HDLTimingController'},...
            'Description',desc);
        end
    end

    methods

        function[nstates,outputoffsets]=compute_tc_params(~,down,offset)





            for ii=1:length(down)
                if down(ii)==0
                    down(ii)=1;
                end
            end
            nstates=vector_lcm(down);
            outputoffsets=cell(1,length(down));
            for ii=1:length(down)
                if down(ii)==1

                    outputoffsets{ii}=uint32([offset(ii),1,nstates]);
                else


                    outputoffsets{ii}=uint32(offset(ii):down(ii):(nstates-1));
                end
            end
        end




        function tc=elaborate(this,hN,hC,domain,rawClkReq)
            hOutSignals=hC.PirOutputSignals;
            hInSignals=hC.PirInputSignals;
            compName=hdllegalname(hC.Name);

            hNumInports=hC.NumberOfPirInputPorts;
            hNumOutports=hC.NumberOfPirOutputPorts;
            hCInputPorts=hC.PirInputPorts;
            hInportNames=cell(1,hNumInports);
            hInportTypes=hdlhandles(1,hNumInports);
            hInportRates=zeros(1,hNumInports);
            hInportKinds=cell(1,hNumInports);
            hOutportNames=cell(1,hNumOutports);
            hOutportTypes=hdlhandles(1,hNumOutports);

            for ii=1:hNumInports
                hInportNames{ii}=hInSignals(ii).Name;
                hInportTypes(ii)=hInSignals(ii).Type;
                hInportRates(ii)=hInSignals(ii).SimulinkRate;
                hInportKinds{ii}=hCInputPorts(ii).Kind;
            end

            for ii=1:hNumOutports
                hOutportNames{ii}=hOutSignals(ii).Name;
                hOutportTypes(ii)=hOutSignals(ii).Type;
            end

            hNew=pirelab.createNewNetwork(...
            'Network',hN,...
            'Name',compName,...
            'InportNames',hInportNames,...
            'InportTypes',hInportTypes,...
            'InportRates',hInportRates,...
            'InportKinds',hInportKinds,...
            'OutportNames',hOutportNames,...
            'OutportTypes',hOutportTypes);

            hInSignals_newnet=hNew.PirInputSignals;
            hOutSignals_newnet=hNew.PirOutputSignals;


            tc=pirelab.instantiateNetwork(hN,hNew,hInSignals,hOutSignals,compName);

            hNew.generateModelFromPir;
            this.processClkReq(tc,domain,rawClkReq);
            hPhaseSignals=elaborate_inline(hNew,hC,domain,hInSignals_newnet,hOutSignals_newnet);
            addPhaseSignalsToTimingControllerInfo(domain,hPhaseSignals);
        end
    end

    methods(Hidden)
        function processClkReq(this,tcComp,clkDomain,rawClkReq)
            gp=pir;
            if clkDomain==0
                hdlEmitOversampleMessage(gp);
            end
            clockTable=gp.getClockTable(clkDomain);

            clockRatio=1;
            if clkDomain~=0


                for ii=1:numel(clockTable)
                    if clockTable(ii).Kind==0
                        clockRatio=clockTable(ii).Ratio;
                        break;
                    end
                end
            else
                if hdlgetparameter('clockinputs')==2
                    clockRatio=gp.getClockScalingFactor;
                end
            end



            if~isempty(tcComp)
                tcCompOwner=tcComp.Owner;
                tcCompName=tcCompOwner.Name;
                clkEnableSignals=gp.getActiveClockEnables(tcCompOwner,clkDomain);

                up=[rawClkReq(:).Up];
                down=[rawClkReq(:).Down];
                offset=[rawClkReq(:).Offset];

                if clockRatio>1




                    down=down/clockRatio;
                    for ii=1:numel(offset)


                        if offset(ii)~=0&&offset(ii)~=1
                            offset(ii)=mod(ceil(offset(ii)/clockRatio),down(ii));
                        end
                    end
                end


                [nstates,outputoffsets]=this.compute_tc_params(down,offset);


                timingInfoMatrix.up=up;
                timingInfoMatrix.down=down;
                timingInfoMatrix.offset=offset;
            else
                clkEnableSignals=[];
                tcCompName=[];
                nstates=[];
                outputoffsets=[];
                timingInfoMatrix=[];
            end



            updateTimingControllerInfo(clkDomain,tcCompName,...
            nstates,clkEnableSignals,outputoffsets,timingInfoMatrix,clockTable);
        end
    end
end


function result=vector_lcm(invec)
    result=invec(1);
    for i=2:length(invec)
        result=lcm(result,floor(invec(i)));
    end
end


function hPhaseSignals=elaborate_inline(hN,hC,domain,hInSignals,hOutSignals)

    hDriver=hdlcurrentdriver;
    if~isempty(hDriver)

        tcinfo=hDriver.getTimingControllerInfo(domain);
    end

    if isempty(tcinfo)

        error(message('HDLShared:directemit:incorrect_tcinfo'));
    end


    fixverilogtypes;


    tcinfo.clk=hC.getInputSignals('clock');
    tcinfo.reset=hC.getInputSignals('reset');
    tcinfo.clkenable=hC.getInputSignals('clock_enable');


    oldNetwork=hDriver.getCurrentNetwork;
    hDriver.setCurrentNetwork(hN);


    multiCounter=hdlgetparameter('OptimizeTimingController');

    if multiCounter

        hPhaseSignals=tcOptimal(hN,tcinfo,hInSignals,hOutSignals);
    else

        hPhaseSignals=tcNonOptimal(hN,tcinfo,hInSignals,hOutSignals);
    end
    createClockenComments(hN,tcinfo,hOutSignals);
    hDriver.setCurrentNetwork(oldNetwork);
    hN.renderCodegenPir(true);
end


function sortedPhaseSignals=tcOptimal(hN,tcinfo,hInSignals,hOutSignals)
    maxCount=tcinfo.nstates;
    [uniqueOffsets,mapping]=decoderUnification(tcinfo);
    [counterSizes,firstPhase]=findCounterSizes(tcinfo,uniqueOffsets);
    uniqueCounters=unique(counterSizes);
    clockEnableSig=hInSignals(3);
    phaseSignals=[];
    phaseSignalsLoc=[];


    for i=1:length(uniqueCounters)
        count=uniqueCounters(i);

        counterSizesIdx=find(counterSizes==count);
        dontNeedCounter=count==maxCount&&...
        numel(counterSizes(counterSizes==count))==1&&...
        all(uniqueOffsets{counterSizesIdx}==[0,1,count]);
        if~dontNeedCounter
            countStr=int2str(count);
            counter_out=hN.addSignal(pir_ufixpt_t(ceil(log2(count)),0),hdllegalname(['count',countStr]));
            counter_out.Reg=true;
            counter_out.SimulinkRate=hInSignals(1).SimulinkRate;
            pireml.getCounterComp('Network',hN,'OutputSignal',counter_out,...
            'OutputSimulinkRate',0,'Name',['counter_',countStr],...
            'InitialValue',1,'StepValue',1,'ClockEnableSignal',clockEnableSig,...
            'CountFromValue',0,'CountToValue',(count-1),...
            'LimitedCounterOptimize',false);

            if count==maxCount
                phase=uniqueOffsets(counterSizes==count);
            else
                phase=firstPhase(counterSizesIdx);
            end

            for ii=1:length(phase)
                tmp_phase=phase(ii);
                if iscell(phase)
                    tmp_phase=cell2mat(phase(ii));
                end
                if all(tmp_phase>=0)
                    if length(tmp_phase)>1
                        if length(tmp_phase)==3&&tmp_phase(3)==count
                            phase_inc=tmp_phase(2);
                            fullLen=true;
                        else
                            phase_inc=abs(tmp_phase(2)-tmp_phase(1));
                            fullLen=length(phase)==count;
                        end
                    else
                        phase_inc=tmp_phase(1);
                        fullLen=false;
                    end
                    if phase_inc==1&&fullLen
                        phase_out=clockEnableSig;
                    else
                        phase_suffix=int2str(phase_inc);
                        phase_out=hN.addSignal(pir_boolean_t,hdllegalname(['phase_',phase_suffix]));
                        phase_out.Reg=true;
                        phase_tmp=hN.addSignal(pir_boolean_t,hdllegalname(['phase_',phase_suffix,'_tmp']));
                        compare_out=hN.addSignal(pir_boolean_t,hdllegalname(['comp_',phase_suffix,'_tmp']));

                        if phase_inc==0
                            phase_cmp=count-1;
                        else
                            phase_cmp=phase_inc-1;
                        end
                        pirelab.getCompareToValueComp(hN,counter_out,compare_out,'==',phase_cmp,count,'TC_Comp');
                        pirelab.getLogicComp(hN,[compare_out,clockEnableSig],phase_tmp,'and');
                        if phase_inc==1
                            IC=1;
                        else
                            IC=0;
                        end
                        pirelab.getUnitDelayComp(hN,phase_tmp,phase_out,'phase_delay',IC);
                    end
                    phaseSignals=[phaseSignals,phase_out];%#ok <AGROW>
                end
            end
            phaseLocation=counterSizesIdx;
            phaseSignalsLoc=[phaseSignalsLoc,phaseLocation];%#ok<AGROW>
        else
            phaseSignals=[phaseSignals,clockEnableSig];%#ok <AGROW>
            phaseSignalsLoc=[phaseSignalsLoc,counterSizesIdx(1)];%#ok<AGROW>
        end
    end

    phaseLocMap=containers.Map(phaseSignalsLoc,1:length(phaseSignalsLoc));


    sortedPhaseSignals=phaseSignals;
    for i=1:length(hOutSignals)
        pSig=phaseSignals(phaseLocMap(mapping(i)));
        sortedPhaseSignals(i)=pSig;
        pOut=hOutSignals(i);
        if pSig==clockEnableSig
            pirelab.getWireComp(hN,pSig,pOut);
        else
            pirelab.getLogicComp(hN,[pSig,clockEnableSig],pOut,'and');
        end
    end

end


function sortedPhaseSignals=tcNonOptimal(hN,tcinfo,hInSignals,hOutSignals)
    clockEnableSig=hInSignals(3);
    [uniqueOffsets,mapping]=decoderUnification(tcinfo);

    count=tcinfo.nstates;
    [cntvtype,cntsltype]=hdlgettypesfromsizes(ceil(log2(count)),0,0);
    countStr=int2str(count);
    [~,counter_out]=hdlnewsignal(hdllegalname(['count',countStr]),'block',...
    -1,0,0,cntvtype,cntsltype);
    hdlregsignal(counter_out);

    counter_out.SimulinkRate=hInSignals(1).SimulinkRate;
    pireml.getCounterComp('Network',hN,'OutputSignal',counter_out,'OutputSimulinkRate',0,...
    'Name',['counter_',countStr],'InitialValue',1,'StepValue',1,...
    'ClockEnableSignal',clockEnableSig,'CountFromValue',0,...
    'CountToValue',(count-1),'LimitedCounterOptimize',false);

    phase=uniqueOffsets;
    phaseSignals=[];


    for ii=1:length(phase)
        tmp_phase=phase(ii);
        if iscell(phase)
            tmp_phase=cell2mat(phase(ii));
        end
        if all(tmp_phase>=0)
            if length(tmp_phase)>1
                if length(tmp_phase)==3&&tmp_phase(3)==count
                    phase_inc=tmp_phase(2);
                    fullLen=true;
                else
                    phase_inc=abs(tmp_phase(2)-tmp_phase(1));
                    fullLen=length(phase)==count;
                end
            else
                phase_inc=tmp_phase(1);
                fullLen=false;
            end
            if phase_inc==1&&fullLen
                phase_out=clockEnableSig;
            else
                phase_suffix=int2str(phase_inc);
                [~,phase_out]=hdlnewsignal(hdllegalname(['phase_',phase_suffix]),'filter',-1,0,0,'std_logic','boolean');
                [~,phase_tmp]=hdlnewsignal(hdllegalname(['phase_',phase_suffix,'_tmp']),'filter',-1,0,0,'std_logic','boolean');
                [~,comp_out]=hdlnewsignal(hdllegalname(['comp',phase_suffix,'_tmp']),'filter',-1,0,0,'std_logic','boolean');
                compare_outputs=[];
                for jj=1:length(tmp_phase)
                    phase_idx=tmp_phase(jj);
                    phase_suffix_idx=int2str(phase_idx);
                    [~,compare_out]=hdlnewsignal(hdllegalname(['comp_',phase_suffix_idx,'_tmp']),'filter',-1,0,0,'std_logic','boolean');
                    if phase_idx==0
                        phase_cmp=count-1;
                    else
                        phase_cmp=phase_idx-1;
                    end
                    pirelab.getCompareToValueComp(hN,counter_out,compare_out,'==',phase_cmp,'TC_Comp');
                    compare_outputs=[compare_outputs,compare_out];%#ok <AGROW>
                end
                pirelab.getLogicComp(hN,compare_outputs,comp_out,'or');
                pirelab.getLogicComp(hN,[comp_out,clockEnableSig],phase_tmp,'and');
                if tmp_phase(1)==1
                    IC=1;
                else
                    IC=0;
                end
                pirelab.getUnitDelayComp(hN,phase_tmp,phase_out,'phase_delay',IC);
            end
            phaseSignals=[phaseSignals,phase_out];%#ok <AGROW>
        end
    end


    sortedPhaseSignals=phaseSignals;
    for i=1:length(hOutSignals)
        pSig=phaseSignals(mapping(i));
        sortedPhaseSignals(i)=pSig;
        pOut=hOutSignals(i);
        if pSig==clockEnableSig
            pirelab.getWireComp(hN,pSig,pOut);
        else
            pirelab.getLogicComp(hN,[pSig,clockEnableSig],pOut,'and');
        end
    end
end

function fixverilogtypes
    if hdlgetparameter('isverilog')
        insignals=hdlinportsignals;
        for ii=1:length(insignals)
            hS=insignals(ii);
            vt=hdlgetparameter('base_data_type');
            hdlsignalsetvtype(hS,vt);
        end
        outsignals=hdloutportsignals;
        for ii=1:length(outsignals)
            hS=outsignals(ii);
            vt=hdlgetparameter('base_data_type');
            hdlsignalsetvtype(hS,vt);
        end
    end
end



function[UniqueOffsets,mapping]=decoderUnification(tcinfo)
    inOffset=tcinfo.offsets;
    down=tcinfo.dutTimingInfo.down;
    UniqueOffsets{1}=inOffset{1};
    mapping=1;
    sortedDown=down(1);
    idx=0;
    for i=2:length(inOffset)
        for j=1:length(UniqueOffsets)
            if length(inOffset{i})==length(UniqueOffsets{j})
                if all(sort(inOffset{i})==sort(UniqueOffsets{j}))
                    if down(i)==sortedDown(j)
                        idx=j;
                        break;
                    end
                elseif length(inOffset{i})==3&&inOffset{i}(3)==tcinfo.nstates
                    if inOffset{i}(2)==UniqueOffsets{j}(2)&&inOffset{i}(3)==UniqueOffsets{j}(3)
                        idx=j;
                        break;
                    end
                end
            end
        end
        if idx>0

            mapping=[mapping,idx];%#ok
            sortedDown(i)=down(idx);
            idx=0;
        else

            UniqueOffsets(end+1)=inOffset(i);%#ok
            mapping=[mapping,max(mapping)+1];%#ok
            sortedDown(i)=down(i);
        end
    end
end


function[counter,phase]=findCounterSizes(tcinfo,offsets)
    counter=zeros(1,length(offsets));
    phase=zeros(1,length(offsets));

    for i=1:length(offsets)
        offsetsVector=cell2mat(offsets(i));
        phase(i)=offsetsVector(1);
        if length(offsetsVector)==1||...
            length(offsetsVector)==tcinfo.nstates||...
            (length(offsetsVector)==3&&offsetsVector(3)==tcinfo.nstates)
            counter(i)=tcinfo.nstates;
        else
            counter(i)=abs(offsetsVector(2)-offsetsVector(1));
        end
    end
end


function updateTimingControllerInfo(clkDomain,name,nstates,...
    outputsignals,outputoffsets,timingInfoMatrix,clockTable)
    tcinfo=[];
    tcinfo.topname=name;
    tcinfo.nstates=nstates;
    tcinfo.outputsignals=outputsignals;
    needMulticycle=~isempty(hdlgetparameter('multicyclepathinfo'))&&hdlgetparameter('multicyclepathinfo');
    if clkDomain==0&&~needMulticycle



        tcinfo.offsets=[];
    else
        tcinfo.offsets=outputoffsets;
    end
    tcinfo.enablemap=[];
    tcinfo.dutTimingInfo=timingInfoMatrix;
    tcinfo.latency=0;
    tcinfo.clockTable=clockTable;


    currentDriver=hdlcurrentdriver;
    if~isempty(currentDriver)

        currentDriver.setTimingControllerInfo(clkDomain,tcinfo);
    end
end


function addPhaseSignalsToTimingControllerInfo(clkDomain,phaseSignals)

    currentDriver=hdlcurrentdriver;
    if~isempty(currentDriver)

        tcinfo=currentDriver.getTimingControllerInfo(clkDomain);

        if isempty(tcinfo)

            error(message('HDLShared:directemit:incorrect_tcinfo'));
        end

        tcinfo.enablemap=phaseSignals(:);
        currentDriver.setTimingControllerInfo(clkDomain,tcinfo);
    end


end


function createClockenComments(hN,tcinfo,hOutSignals)
    dutTimingInfo=tcinfo.dutTimingInfo;

    clkName=tcinfo.clk(1).Name;
    enName=tcinfo.clkenable(1).Name;


    c=sprintf('Master clock enable input: %s\n\n',enName);
    for pp=1:numel(hOutSignals)
        hS=hOutSignals(pp);
        if dutTimingInfo.down(pp)==1
            c=sprintf('%s%-12s: identical to %s\n',c,hS.Name,enName);
        else
            if dutTimingInfo.offset(pp)==0
                phaseStr='last phase';
            else
                phaseStr=sprintf('phase %d',dutTimingInfo.offset(pp));
            end
            c=sprintf('%s%-12s: %dx slower than %s with %s\n',c,hS.Name,...
            dutTimingInfo.down(pp),clkName,phaseStr);
        end
    end


    p=pir(hN.getCtxName);
    p.getTopNetwork.addComment(c);

end
