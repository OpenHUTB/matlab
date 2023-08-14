function[hdl_arch,entitysigs,controlsigs,ce,inputcastsig]=emit_dist_arith(this,entitysigs,ce)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputsize=inputall.size;
    inputbp=inputall.bp;
    inputsigned=inputall.signed;

    clken=hdlsignalfindname(hdlgetparameter('clockenablename'));

    phases=this.interpolationfactor;

    final_adder_style=hdlgetparameter('filter_fir_final_adder');
    if hdlgetparameter('filter_pipelined')
        final_adder_style='pipelined';
    end

    lpi=hdlgetparameter('filter_dalutpartition');
    radix=hdlgetparameter('filter_daradix');
    baat=log2(radix);

    if size(lpi,1)==1
        lpi=resolveDALUTPartition(this,lpi);
    end

    if inputsize~=baat


        [inputcastvtype,inputcastsltype]=hdlgettypesfromsizes(inputsize,inputbp,inputsigned);
        [~,inputcastsig]=hdlnewsignal('filter_in_cast','filter',-1,0,0,inputcastvtype,inputcastsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(inputcastsig)];
        inputcastbody=hdldatatypeassignment(entitysigs.input,inputcastsig,'floor',0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,inputcastbody];





        if strcmpi(final_adder_style,'pipelined')
            ffactor=inputsize/baat+ceil(log2(baat))-1;
        else
            ffactor=inputsize/baat;
        end

        if phases==ffactor

            count_to=ffactor;
            phases_cell{1}=count_to-1;
            phases_cell{2}=0;


            count_bits=max(2,ceil(log2(count_to)));
            [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
            [~,ce.ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,...
            countvtype,countsltype);
            hdlregsignal(ce.ctr_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr_out)];

            tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
            [ctr_body,ce.ctr_sigs]=hdlcounter(ce.ctr_out,count_to,['Counter',...
            hdlgetparameter('clock_process_label')],...
            1,count_to-1,phases_cell);

            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr_sigs)];

            hdladdclockenablesignal(ce.ctr_sigs);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body];
            ce.delay=ce.ctr_sigs(1);
            ce.accum=hdlgetcurrentclockenable();
            ce.afinal=ce.ctr_sigs(2);
            load_en=ce.ctr_sigs(1);
            ce.output=clken;
            ce.out_temp=ce.delay;
            controlsigs=[ce.delay,ce.accum,ce.afinal];
            hdlsetparameter('filter_excess_latency',...
            hdlgetparameter('filter_excess_latency')+1);
            fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkrate',...
            ffactor)));
...
...
...
...
            ce.ctr1_out=ce.ctr_out;
        else
            if phases>ffactor





                count_to=phases;
                count_bits=max(2,ceil(log2(count_to)));
                [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
                [~,ce.ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,...
                countvtype,countsltype);
                hdlregsignal(ce.ctr_out);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr_out)];


                phases_cell{1}=count_to-1;
                phases_cell{2}=0;
                phases_cell{3}=[count_to-1,0:ffactor-2];


                tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
                [ctr_body,ce.ctr_sigs]=hdlcounter(ce.ctr_out,count_to,['Counter',...
                hdlgetparameter('clock_process_label')],...
                1,count_to-1,phases_cell);

                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr_sigs)];

                hdladdclockenablesignal(ce.ctr_sigs);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body];

                load_en=ce.ctr_sigs(1);
                ce.delay=ce.ctr_sigs(1);
                ce.afinal=ce.ctr_sigs(2);
                ce.accum=ce.ctr_sigs(3);
                ce.output=clken;
                ce.out_temp=ce.ctr_sigs(1);
                controlsigs=[ce.delay,ce.accum,ce.afinal];
                hdlsetparameter('filter_excess_latency',...
                hdlgetparameter('filter_excess_latency')+1);
                fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkrate',...
                phases)));
...
...
...
...
                ce.ctr1_out=ce.ctr_out;
            else

                count_to=phases*ceil(ffactor/phases);
                count_bits=max(2,ceil(log2(count_to)));
                count_mult=count_to/phases;
                [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
                [~,ce.ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,...
                countvtype,countsltype);
                hdlregsignal(ce.ctr_out);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr_out)];


                phases_cell{1}=count_to-1;
                phases_cell{2}=0;
                if ffactor==count_to

                    phases_cnt=2;
                else
                    phases_cell{3}=[count_to-1,0:ffactor-2];
                    phases_cnt=3;
                end
                phases_cell{phases_cnt+1}=0:count_mult:count_to-count_mult;
                if mod(phases,2)==0&&floor(log2(count_mult))==log2(count_mult)

                else

                    phases_cell{phases_cnt+2}=[count_to-1,count_mult-1:count_mult:count_to-count_mult-1];
                end

                tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
                [ctr_body,ce.ctr_sigs]=hdlcounter(ce.ctr_out,count_to,['Counter',...
                hdlgetparameter('clock_process_label')],...
                1,count_to-1,phases_cell);

                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr_sigs)];

                hdladdclockenablesignal(ce.ctr_sigs);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body];

                if mod(phases,2)==0&&floor(log2(count_mult))==log2(count_mult)




                    cutbits=log2(count_mult);
                    count_bits1=count_bits-cutbits;
                    [countvtype,countsltype]=hdlgettypesfromsizes(count_bits1,0,0);
                    [~,ce.ctr1_out]=hdlnewsignal('cur_count1','filter',-1,0,0,...
                    countvtype,countsltype);

                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr1_out)];
                    ce.ce.ctr_out1bdy=hdlsliceconcat(ce.ctr_out,{[count_bits-1:-1:0+cutbits]},ce.ctr1_out);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,ce.ce.ctr_out1bdy];
                else


                    count_to1=phases;
                    count_bits=max(2,ceil(log2(count_to1)));
                    [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
                    [~,ce.ctr1_out]=hdlnewsignal('cur_count1','filter',-1,0,0,...
                    countvtype,countsltype);
                    hdlregsignal(ce.ctr1_out);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr1_out)];
                    hdladdclockenablesignal(ce.ctr_sigs(phases_cnt+2));
                    oldce=hdlgetcurrentclockenable;
                    hdlsetcurrentclockenable(ce.ctr_sigs(phases_cnt+2));
                    [ctr_body1,ce.ctr_sigs1]=hdlcounter(ce.ctr1_out,count_to1,['Counter1',...
                    hdlgetparameter('clock_process_label')],1,count_to1-1,{});


                    hdlsetcurrentclockenable(oldce);
                    hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body1];
                end
                load_en=ce.ctr_sigs(1);
                ce.delay=ce.ctr_sigs(1);
                ce.afinal=ce.ctr_sigs(2);
                if ffactor==count_to
                    ce.accum=clken;
                else
                    ce.accum=ce.ctr_sigs(3);
                end
                ce.output=ce.ctr_sigs(phases_cnt+1);
                ce.out_temp=ce.ctr_sigs(1);
                controlsigs=[ce.delay,ce.accum,ce.afinal,load_en];
                hdlsetparameter('foldingfactor',count_to/phases);
                hdlsetparameter('filter_excess_latency',...
                hdlgetparameter('filter_excess_latency')+1);
                fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkrateinout',...
                count_to,count_to/phases)));
...
...
...
...
            end
        end

        tcinfo.enbsOut=ce.ctr_sigs;
        tcinfo.maxCount=count_to;
        tcinfo.phases=phases_cell;
        tcinfo.initValue=count_to-1;
    else

        if phases==1
            [countervtype,countersltype]=hdlgettypesfromsizes(1,0,0);
            [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
            hdl_arch.constants=[hdl_arch.constants,...
            makehdlconstantdecl(counter_out,hdlconstantvalue(0,1,0,0))];
        else
            decodeval=phases-1;

            countsize=max(2,ceil(log2(phases)));
            [countervtype,countersltype]=hdlgettypesfromsizes(countsize,0,0);
            [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
            hdlregsignal(counter_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];
            tcinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
            [tempprocessbody,ce.out_temp]=hdlcounter(counter_out,phases,'ce_output',1,0,decodeval);

            tcinfo.enbsOut=ce.out_temp;
            tcinfo.maxCount=phases;
            tcinfo.phases=decodeval;
            tcinfo.initValue=0;

            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_temp)];
            hdladdclockenablesignal(ce.out_temp);

            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];
            ce.output=clken;
        end


        [inputcastvtype,inputcastsltype]=hdlgettypesfromsizes(inputsize,inputbp,inputsigned);
        [~,inputcastptr]=hdlnewsignal('filter_in_cast','filter',-1,0,0,inputcastvtype,inputcastsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(inputcastptr)];
        inputcastbody=hdldatatypeassignment(entitysigs.input,inputcastptr,'floor',0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,inputcastbody];


        [~,inputreg]=hdlnewsignal('input_register','filter',-1,0,0,inputcastvtype,inputcastsltype);
        hdlregsignal(inputreg);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(inputreg)];
        oldce=hdlgetcurrentclockenable;
        hdlsetcurrentclockenable(ce.out_temp);
        [tempbody,tempsignals]=hdlunitdelay(inputcastptr,inputreg,...
        ['Input_Register',hdlgetparameter('clock_process_label')],0);
        hdlsetcurrentclockenable(oldce);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        inputcastsig=inputreg;
        ce.delay=ce.out_temp;
        ce.accum=ce.out_temp;
        ce.output=clken;
        controlsigs=ce.delay;
        ce.ctr1_out=counter_out;
    end





    if hdlgetparameter('filter_generate_datavalid_output')
        [inprate,outprate]=this.gettbclkrate;
        count_to2=inprate*outprate;

        count_bits=max(2,ceil(log2(count_to2)));
        [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
        [~,ce.ctr2_out]=hdlnewsignal('cur_count2','filter',-1,0,0,...
        countvtype,countsltype);
        hdlregsignal(ce.ctr2_out);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr2_out)];

        [ctr_body1,ce.outputvld]=hdlcounter(ce.ctr2_out,count_to2,['CounterVld',...
        hdlgetparameter('clock_process_label')],1,count_to2-1,0);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body1];
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.outputvld)];

    end
    setLocalTimingInfo(this,tcinfo);


    function lpi_modified=resolvelpi(lpi,polyc)
        lpi=sort(lpi,'descend');
        lpi_modified=[];

        out={};
        for n=1:size(polyc,1)
            allowedin=max(length(find(polyc(n,:))),1);
            m=1;
            done=0;
            out1=[];
            while~done
                if allowedin>lpi(m)
                    out1=[out1,lpi(m)];
                    allowedin=allowedin-lpi(m);
                else
                    out1=[out1,allowedin];
                    done=1;
                end
                m=m+1;
            end
            out{n}=out1;
        end
        maxlen=0;
        for n=1:length(out)
            if maxlen<length(out{n})
                maxlen=length(out{n});
            end
        end
        for n=1:length(out)
            if length(out{n})<maxlen
                lpi_modified(n,:)=[out{n},zeros(1,(maxlen-length(out{n})))];
            else
                lpi_modified(n,:)=out{n};
            end
        end



