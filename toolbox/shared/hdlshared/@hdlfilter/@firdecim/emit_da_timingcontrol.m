function[hdl_arch,ce,phasece,ctr_out,tcinfo]=emit_da_timingcontrol(this,ce)







    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    arch=this.implementation;

    coeffall=hdlgetallfromsltype(this.coeffSLtype);
    coeffsvbp=coeffall.bp;

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputsize=inputall.size;
    inputbp=inputall.bp;
    inputsigned=inputall.signed;

    clken=hdlsignalfindname(hdlgetparameter('clockenablename'));

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];
    phases=this.decimationfactor;
    polycoeffs=this.polyphasecoefficients;

    daengineindx=any(polycoeffs,2);
    daengines=length(find(daengineindx));
    final_adder_style=hdlgetparameter('filter_fir_final_adder');
    if hdlgetparameter('filter_pipelined')
        final_adder_style='pipelined';
    end

    radix=hdlgetparameter('filter_daradix');
    baat=log2(radix);

    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    if inputsize~=baat






        if strcmpi(final_adder_style,'pipelined')
            ffactor=inputsize/baat;
        else
            ffactor=inputsize/baat;
        end

        if phases==ffactor
            count_to=ffactor;
            phases_cell=0:count_to-1;


            count_bits=max(2,ceil(log2(count_to)));
            [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
            [uname,ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,...
            countvtype,countsltype);
            hdlregsignal(ctr_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_out)];
            tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);

            [ctr_body,ctr_sigs]=hdlcounter(ctr_out,count_to,['Counter',...
            hdlgetparameter('clock_process_label')],...
            1,count_to-1,phases_cell);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_sigs)];

            hdladdclockenablesignal(ctr_sigs);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body];

            ce.load_en=ctr_sigs(end:-1:1);
            ce.accum=clken*(ones(1,count_to));
            ce.afinal=[ctr_sigs(1),ctr_sigs(end:-1:2)];
            ce.ceout=ctr_sigs(2);
            hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+ffactor);

            fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkratesame')));
...
...
...
...
        else
            if phases>ffactor

                count_to=phases;
                count_bits=max(2,ceil(log2(count_to)));
                [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
                [uname,ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,...
                countvtype,countsltype);
                hdlregsignal(ctr_out);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_out)];


                for n=1:phases
                    phases_cell{n}=phases-n;
                end


                phase_tmp1=0:phases-1;
                phase_tmp1=[phase_tmp1,phase_tmp1(1:ffactor-1)];
                for n=1:daengines
                    daindx=find(daengineindx);
                    phases_cell{phases+n}=phase_tmp1(phases-daindx(n)+1:phases-daindx(n)+1+ffactor-1);
                end
                tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
                [ctr_body,ctr_sigs]=hdlcounter(ctr_out,count_to,['Counter',...
                hdlgetparameter('clock_process_label')],...
                1,count_to-1,phases_cell);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_sigs)];

                hdladdclockenablesignal(ctr_sigs);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body];
                ctrlsigs_tmp=[ctr_sigs(phases),ctr_sigs(1:phases-1)];
                ctr_sigindx=1;
                for n=1:phases
                    load_en(n)=ctr_sigs(n);
                    ce.afinal(n)=ctrlsigs_tmp(n);
                    if daengineindx(n)
                        ce.accum(n)=ctr_sigs(phases+ctr_sigindx);
                        ctr_sigindx=ctr_sigindx+1;
                    else
                        ce.accum(n)=0;
                    end
                end
                ce.load_en=load_en;
                ce.ceout=ctr_sigs(phases-1);
                hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+phases);
                fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkrate',...
                phases)));
...
...
...
...
            else

                count_to=phases*ceil(ffactor/phases);
                count_bits=max(2,ceil(log2(count_to)));
                [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
                [uname,ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,...
                countvtype,countsltype);
                hdlregsignal(ctr_out);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_out)];



                for n=1:phases
                    temp_phase=count_to-1-(count_to/phases)*(n-1);
                    phases_cell{2*n-1}=temp_phase;
                    if n==1
                        phases_cell{2*n}=0;
                    else
                        phases_cell{2*n}=temp_phase+1;
                    end
                end



                phase_tmp1=0:count_to-1;
                phase_tmp1=[phase_tmp1,phase_tmp1(1:ffactor-1)];
                if mod(ffactor,phases)==0

                else
                    for n=1:daengines
                        daindx=find(daengineindx);
                        strt_ix=count_to-(count_to/phases)*(daindx(n)-1);
                        phases_cell{2*phases+n}=phase_tmp1(strt_ix:strt_ix+ffactor-1);
                    end
                end

                tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
                [ctr_body,ctr_sigs]=hdlcounter(ctr_out,count_to,['Counter',...
                hdlgetparameter('clock_process_label')],...
                1,count_to-1,phases_cell);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_sigs)];

                hdladdclockenablesignal(ctr_sigs);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body];
                ctr_sigindx=1;
                for n=1:phases
                    load_en(n)=ctr_sigs(2*n-1);
                    ce.afinal(n)=ctr_sigs(2*n);
                    if daengineindx(n)
                        if mod(ffactor,phases)==0
                            ce.accum(n)=clken;
                        else
                            ce.accum(n)=ctr_sigs(phases*2+ctr_sigindx);
                            ctr_sigindx=ctr_sigindx+1;
                        end
                    else
                        ce.accum(n)=0;
                    end
                end
                ce.load_en=load_en;
                ce.ceout=ctr_sigs(2*phases-1);
                clksbetinputs=count_to/phases;
                hdlsetparameter('foldingfactor',clksbetinputs);
                clkchkoutput=ffactor/clksbetinputs;
                hdlsetparameter('filter_excess_latency',hdlgetparameter('filter_excess_latency')+clkchkoutput);
                fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkrateinout',...
                count_to/phases,count_to)));
...
...
...
...
...
            end
        end
        tcinfo.phases=phases_cell;
        tcinfo.enbsOut=ctr_sigs;
        tcinfo.maxCount=count_to;
        phasece=ce.ceout;
        tcinfo.initValue=count_to-1;
    else

        [counter_arch,ce,phasece,ctr_out,tcinfo]=emit_ringcounter(this,ce);
        hdl_arch=combinehdlcode(this,hdl_arch,counter_arch);
    end

    if multiclock==0&&hdlgetparameter('filter_generate_ceout')



        hdl_arch.body_blocks=[hdl_arch.body_blocks,...
        indentedcomment,...
        '  ------------------ CE Output Generation ------------------\n\n'];

        if strcmpi(arch,'distributedarithmetic')&&(baat~=inputsize)

            phasece=0;
            [hdl_arch,ce]=emit_serial_ceout(this,hdl_arch,ce,phasece,count_to);
        else

        end
    end

