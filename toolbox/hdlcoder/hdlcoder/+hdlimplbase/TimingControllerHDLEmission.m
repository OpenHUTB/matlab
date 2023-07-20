classdef TimingControllerHDLEmission<hdlimplbase.HDLDirectCodeGen






























    methods
        function this=TimingControllerHDLEmission(block)
            magicClockDriverBlockImplTags='PirTimingController';

            supportedBlocks={...
            magicClockDriverBlockImplTags,...
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','Default Timing Controller Internal Implementation',...
            'HelpText','Default Timing Controller code generation via direct HDL emission');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'CodeGenMode','emission',...
            'CodeGenFunc','emit',...
            'CodeGenParams',[],...
            'HandleType','useobjandcomphandles',...
            'Description',desc);




        end

    end

    methods

        function oldContext=preEmit(~,~,~)
            oldContext.connectivity=hdlconnectivity.genConnectivity(0);
        end


        function[v]=validate(~,~)
            v.Status=0;
            v.Message='';
            v.MessageID='TimingControllerHDLEmission:validate';
        end

    end


    methods(Hidden)

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





        function hdlcode=emit(~,hC)


            fixverilogtypes;


            hdlsharedTC=hdl.TimingController;


            setSystemClockBundle(hC,hdlsharedTC);


            hDriver=hdlcurrentdriver;
            oldNetwork=hDriver.getCurrentNetwork;
            hN=hC.Owner;
            hDriver.setCurrentNetwork(hN);

            hdlcode=hdlsharedTC.emit(hC.HDLUserData);
            createClockenComments(hC,hdlsharedTC.tcinfo);


            hDriver.setCurrentNetwork(oldNetwork);
        end




        function clockTable=getClockTable(~)
            clockTable.Name='clk';
            clockTable.Rate=1;
        end


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

                if gp.isPIRTCCtxBased
                    tcCompOwner=gp.getTopNetwork();
                else
                    tcCompOwner=tcComp.Owner;
                end

                clkEnableSignals=gp.getActiveClockEnables(tcCompOwner,clkDomain);
                tcCompName=tcComp.Name;

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






        function[up,down,offset,baseRate]=scaleRelative2SampleTime(this,rawClkReq)%#ok








            hcurrentdriver=hdlcurrentdriver;
            modelSampleTime=hcurrentdriver.PirInstance.getModelSampleTimes;
            minSampleTime=min(modelSampleTime(modelSampleTime>0));
            if isempty(minSampleTime)
                minSampleTime=1;
            end

            up=[rawClkReq(:).Up];
            down=[rawClkReq(:).Down];
            offset=[rawClkReq(:).Offset];
            baseRate=minSampleTime;

        end

    end

end

function result=vector_lcm(invec)

    result=invec(1);
    for i=2:length(invec)
        result=lcm(result,floor(invec(i)));
    end
end

function setSystemClockBundle(hC,hdlSharedTC)
    hdlSharedTC.tcinfo.clk=hC.getInputSignals('clock');
    hdlSharedTC.tcinfo.reset=hC.getInputSignals('reset');
    hdlSharedTC.tcinfo.clkenable=hC.getInputSignals('clock_enable');
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


function createClockenComments(hC,tcinfo)
    dutTimingInfo=tcinfo.dutTimingInfo;

    clkName=tcinfo.clk(1).Name;
    for ii=1:numel(hC.PirInputSignals)
        if hC.PirInputSignals(ii).isClockEnable
            enName=hC.PirInputSignals(ii).Name;
            break;
        end
    end


    c=sprintf('Master clock enable input: %s\n\n',enName);
    for pp=1:numel(hC.PirOutputSignals)
        hS=hC.PirOutputSignals(pp);
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


    hC.Owner.addComment(c);
end
function updateTimingControllerInfo(clkDomain,name,nstates,outputsignals,...
    outputoffsets,timingInfoMatrix,clockTable)
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
