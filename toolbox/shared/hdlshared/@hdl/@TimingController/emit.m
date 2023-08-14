function hdlcode=emit(this,domain)




    if isempty(this.tcinfo)

        error(message('HDLShared:directemit:incorrect_tcinfo'));
    end

    getTcInfoFromDriver(this,domain);
    multiCounter=hdlgetparameter('OptimizeTimingController');
    mcp=hdlgetparameter('MulticyclePathConstraints');





    gp=pir;
    pirtcOn=gp.isPIRTCCtxBased;

    if hdlgetparameter('isverilog')
        outsignals=this.tcinfo.outputsignals;
        for ii=1:length(outsignals)
            hS=outsignals(ii);
            vt=hdlgetparameter('base_data_type');
            hdlsignalsetvtype(hS,vt);
        end
    end


    hdlcode=hdlcodeinit;
    globalClockEnable=hdlsignalfindname(this.tcinfo.clkenable.Name);


    oldClockBundle=setClockBundle(this.tcinfo);

    if pirtcOn


        hdlbody='';
        hdlsignals=this.tcinfo.enablemap;
        for i=1:length(this.tcinfo.outputsignals)
            if mcp
                if isa(hdlsignals(i),'hdlcoder.signal')
                    addAttributeToRegisterSignal(this,i,hdlsignals(i));
                end
                addAttributeToEnableSignal(this,this.tcinfo.outputsignals(i));
            end
        end

    else

        [uniqueOffsets,enableMapping]=decoderUnification(this);


        resetTC=hdlgetparameter('ResettableTimingController')&&numel(this.tcInfo.reset)>1;
        if resetTC
            oldreset=hdlgetcurrentreset;
            sltype=hdlgetsltypefromsizes(1,0,0);
            [~,tcreset]=hdlnewsignal([hdlgetparameter('resetname'),'_tc'],'block',...
            -1,0,0,oldreset.VType,sltype);
            hdlcode.arch_signals=makehdlsignaldecl(tcreset);
            resetLevel=hdlgetparameter('reset_asserted_level');



            if resetLevel==1
                rtcBody=hdllogop(this.tcInfo.reset,tcreset,'OR');
            else
                rtcBody=hdllogop(this.tcInfo.reset,tcreset,'AND');
            end
            hdlsetcurrentreset(tcreset);
        end
        if~multiCounter


            [cntvtype,cntsltype]=hdlgettypesfromsizes(ceil(log2(this.tcinfo.nstates)),0,0);
            [~,counter_out]=hdlnewsignal('counter_out','block',-1,0,0,cntvtype,cntsltype);
            hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(counter_out)];

            hdlregsignal(counter_out);


            [hdlbody,hdlsignals]=hdlcounter(counter_out,this.tcinfo.nstates,...
            'Counter',1,1,uniqueOffsets,1);
            for i=1:length(this.tcinfo.outputsignals)
                hdlbody=[hdlbody,hdllogop([hdlsignals(enableMapping(i)),globalClockEnable],...
                this.tcinfo.outputsignals(i),'AND')];%#ok

                if mcp
                    addAttributeToRegisterSignal(this,i,hdlsignals(enableMapping(i)));
                    addAttributeToEnableSignal(this,this.tcinfo.outputsignals(i));
                end
            end
        else
            maxCount=this.tcinfo.nstates;
            [hdlbody,hdlsignals]=this.multiCounterPhaseDecoder(maxCount,uniqueOffsets,1);
            for i=1:length(this.tcinfo.outputsignals)
                hdlbody=[hdlbody,hdllogop([hdlsignals(enableMapping(i)),globalClockEnable],...
                this.tcinfo.outputsignals(i),'AND')];%#ok

                if mcp
                    addAttributeToRegisterSignal(this,i,hdlsignals(enableMapping(i)));
                    addAttributeToEnableSignal(this,this.tcinfo.outputsignals(i));
                end
            end
        end

        if resetTC
            hdlbody=[rtcBody,hdlbody];
            hdlsetcurrentreset(oldreset);
        end

        this.tcinfo.enablemap=hdlsignals(enableMapping);
    end


    setTcInfoToDriver(this,domain);


    [~]=setClockBundle(oldClockBundle);


    hdlcode.arch_body_blocks=hdlbody;
end





function[UniqueOffsets,mapping]=decoderUnification(this)
    inOffset=this.tcinfo.outputoffsets;
    down=this.tcinfo.dutTimingInfo.down;
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
                elseif length(inOffset{i})==3&&inOffset{i}(3)==this.tcinfo.nstates
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


function oldClockBundle=setClockBundle(newClockBundle)
    oldClockBundle.clk=hdlgetcurrentclock;
    oldClockBundle.reset=hdlgetcurrentreset;
    oldClockBundle.clkenable=hdlgetcurrentclockenable;





    if isempty(newClockBundle.clkenable)
        clken=[];
    else
        clken=newClockBundle.clkenable(1);
    end
    if isempty(newClockBundle.clk)
        clk=[];
    else
        clk=newClockBundle.clk(1);
    end
    if isempty(newClockBundle.reset)
        rst=[];
    else
        rst=newClockBundle.reset(1);
    end
    hdlsetcurrentclockenable(clken);
    hdlsetcurrentclock(clk);
    hdlsetcurrentreset(rst);
end




function getTcInfoFromDriver(this,domain)
    currentDriver=hdlcurrentdriver;
    clkDomain=domain;
    tcInfo=currentDriver.getTimingControllerInfo(clkDomain);
    this.tcinfo.topname=tcInfo.topname;
    this.tcinfo.nstates=tcInfo.nstates;
    this.tcinfo.outputsignals=tcInfo.outputsignals;
    this.tcinfo.outputoffsets=tcInfo.offsets;
    this.tcinfo.dutTimingInfo=tcInfo.dutTimingInfo;
    this.tcinfo.latency=tcInfo.latency;
    this.tcinfo.enablemap=tcInfo.enablemap;



end

function setTcInfoToDriver(this,domain)
    currentDriver=hdlcurrentdriver;
    clkDomain=domain;
    currentDriver.setTimingControllerInfo(clkDomain,this.tcinfo);
end

function addAttributeToRegisterSignal(this,i,regSignal)


    if(this.tcinfo.dutTimingInfo.down(i)/this.tcinfo.dutTimingInfo.up(i)>1)


        tc=this.tcinfo.dutTimingInfo;
        regSignal.setAttribute('keep','true');
        attrValue=sprintf('%s.u%d_d%d_o%d',this.tcinfo.topname,tc.up(i),tc.down(i),tc.offset(i));
        regSignal.setAttribute('mcp_info',attrValue);

    end

end

function addAttributeToEnableSignal(~,enableSignal)
    enableSignal.setAttribute('direct_enable','yes');
end


