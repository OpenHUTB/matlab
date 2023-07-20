function hdlcode=emit(this)





    if(isempty(this.tcinfo)||(numel(this.tcinfo)>1))

        error(message('HDLShared:hdlfilter:incorrect_tcinfo'));
    end



    registerOut=true;
    multiCounter=hdlgetparameter('OptimizeTimingController');


    hdlcode=hdlcodeinit;


    globalClockEnableName=hdlgetparameter('clockenablename');


    if(this.tcinfo(1).nstates<2)
        hdlbody=[];
        for i=1:length(this.tcinfo(1).outputsignals)
            hdlbody=[hdlbody...
            ,hdlsignalassignment(this.tcinfo(1).clkenable,this.tcinfo(1).outputsignals(i),[],[])];
        end
    else
        [uniqueOffsets,enableMapping]=decoderUnification(this);


        oldClockBundle=setClockBundle(this.tcinfo(1));
        if~multiCounter

            [cntvtype,cntsltype]=hdlgettypesfromsizes(ceil(log2(this.tcinfo(1).nstates)),0,0);
            [idxname,counter_out]=hdlnewsignal('counter_out','block',-1,0,0,cntvtype,cntsltype);
            hdlcode.arch_signals=[hdlcode.arch_signals,makehdlsignaldecl(counter_out)];

            hdlregsignal(counter_out);


            ProcessName='Counter';

            if registerOut

                [hdlbody,hdlsignals]=hdlcounter(counter_out,this.tcinfo(1).nstates,ProcessName,1,1,uniqueOffsets,1);
                for i=1:length(this.tcinfo(1).outputsignals)
                    hdlbody=[hdlbody,hdllogop([hdlsignals(enableMapping(i)),hdlsignalfindname(globalClockEnableName)],this.tcinfo(1).outputsignals(i),'AND')];
                end
            else
                [hdlbody,hdlsignals]=hdlcounter(counter_out,this.tcinfo(1).nstates,ProcessName,1,1,uniqueOffsets,-1);
                for i=1:length(this.tcinfo(1).outputsignals)
                    hdlbody=[hdlbody,hdlsignalassignment(hdlsignals(enableMapping(i)),this.tcinfo(1).outputsignals(i),[],[])];
                end
            end


        else
            maxCount=this.tcinfo(1).nstates;
            clkenable=this.tcinfo(1).clkenable;

            if registerOut
                [hdlbody,hdlsignals,tc_phase_sigs]=this.multiCounterPhaseDecoder(clkenable,maxCount,uniqueOffsets,1);
                hdlcode.arch_signals=[hdlcode.arch_signals,hdlsignals];
                for i=1:length(this.tcinfo(1).outputsignals)
                    hdlbody=[hdlbody,hdllogop([tc_phase_sigs(enableMapping(i)),hdlsignalfindname(globalClockEnableName)],this.tcinfo(1).outputsignals(i),'AND')];
                end
            else
                [hdlbody,hdlsignals,tc_phase_sigs]=this.multiCounterPhaseDecoder(clkenable,maxCount,uniqueOffsets,-1);
                hdlcode.arch_signals=[hdlcode.arch_signals,hdlsignals];
                for i=1:length(this.tcinfo(1).outputsignals)
                    hdlbody=[hdlbody,hdlsignalassignment(tc_phase_sigs(enableMapping(i)),this.tcinfo(1).outputsignals(i),[],[])];
                end
            end
        end

        newClockBundle=setClockBundle(oldClockBundle);
    end


    hdlcode.arch_body_blocks=hdlbody;




    function[UniqueOffsets,mapping]=decoderUnification(this)
        inOffset=this.tcinfo(1).outputoffsets;
        UniqueOffsets={};
        UniqueOffsets(end+1)=inOffset(1);
        mapping=[1];
        found=false;
        for i=2:length(inOffset)
            for j=1:length(UniqueOffsets)
                if length(inOffset{i})==length(UniqueOffsets{j})
                    if all(sort(inOffset{i})==sort(UniqueOffsets{j}))
                        found=true;
                        idx=j;
                        break;
                    end
                end
            end
            if found
                found=false;
                mapping=[mapping,idx];
            else
                UniqueOffsets(end+1)=inOffset(i);
                mapping=[mapping,max(mapping)+1];
            end
        end


        function oldClockBundle=setClockBundle(newClockBundle)

            oldClockBundle.clk=hdlgetcurrentclock;
            oldClockBundle.reset=hdlgetcurrentreset;
            oldClockBundle.clkenable=hdlgetcurrentclockenable;


            hdlsetcurrentclockenable(newClockBundle.clkenable);
            hdlsetcurrentclock(newClockBundle.clk);
            hdlsetcurrentreset(newClockBundle.reset);





