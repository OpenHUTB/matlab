function[hdl_arch,last_sum,ce]=emit_dist_arth(this,entitysigs,internalstructure)











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


    coeffall=hdlgetallfromsltype(this.CoeffSLtype);
    coeffsvbp=coeffall.bp;

    inputrounding='round';
    inputsaturation=true;
    lpi=hdlgetparameter('filter_dalutpartition');

    radix=hdlgetparameter('filter_daradix');
    baat=log2(radix);
    coeffs=this.Coefficients;

    coeffs_values=coeffs(coeffs~=0);

    final_adder_style=hdlgetparameter('filter_fir_final_adder');
    if hdlgetparameter('filter_pipelined')
        final_adder_style='pipelined';
    end




    lut_max=sum(abs(coeffs));
    fp_accumbp=inputbp+coeffsvbp;

    rmax=(2^(inputsize-inputbp-1)-2^(-1*inputbp))*lut_max;
    fp_accumsize=ceil(log2(rmax))+fp_accumbp+1;








    [inputcastvtype,inputcastsltype]=hdlgettypesfromsizes(inputsize,inputbp,inputsigned);
    if baat==inputsize
        if(strcmpi(internalstructure,'symmetricfir')||...
            strcmpi(internalstructure,'antisymmetricfir'))
            inputcastsig=entitysigs.input;
        else
            [~,inputreg]=hdlnewsignal('input_register','filter',-1,0,0,inputcastvtype,inputcastsltype);
            hdlregsignal(inputreg);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(inputreg)];
            [tempbody,tempsignals]=hdlunitdelay(entitysigs.input,inputreg,...
            ['Input_Register',hdlgetparameter('clock_process_label')],0);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
            hdl_arch.signals=[hdl_arch.signals,tempsignals];
            inputcastsig=inputreg;
        end
    else

        [~,inputcastsig]=hdlnewsignal('filter_in_cast','filter',-1,0,0,inputcastvtype,inputcastsltype);
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(inputcastsig)];
        inputcastbody=hdldatatypeassignment(entitysigs.input,inputcastsig,inputrounding,inputsaturation);
        hdl_arch.body_blocks=[hdl_arch.body_blocks,inputcastbody];
    end


    if baat~=inputsize
        if~((strcmpi(internalstructure,'symmetricfir')||...
            strcmpi(internalstructure,'antisymmetricfir')))

            if(strcmpi(internalstructure,'symmetricfir')||...
                strcmpi(internalstructure,'antisymmetricfir'))
                internalstructure='fir';
                TFL=length(coeffs_values);
                num8=floor(TFL/8);
                rem8=rem(TFL,8);
                if rem8==0
                    lpi=8*ones(1,num8);
                else
                    lpi=[8*ones(1,num8),rem8];
                end
            end

            ffactor=inputsize/baat;
            count_to=ffactor;
            phases_cell{1}=count_to-1;

            if strcmpi(final_adder_style,'pipelined')
                nbaatPipeRegs=max((ceil(log2(baat))-1),0);
                nlutPipeRegs=max((ceil(log2(length(lpi)))),0);
                if mod(nlutPipeRegs,ffactor)~=0


                    phases_cell{2}=mod(count_to-1+nlutPipeRegs,ffactor);
                    mux4uminuscnt=2;
                else

                    mux4uminuscnt=1;
                end
                ce_afinalphase=mod(nbaatPipeRegs+nlutPipeRegs,ffactor);
                if ce_afinalphase==phases_cell{1}

                    afinalcnt=1;
                else
                    if ce_afinalphase==phases_cell{mux4uminuscnt}

                        afinalcnt=mux4uminuscnt;
                    else
                        phases_cell{mux4uminuscnt+1}=ce_afinalphase;
                        afinalcnt=mux4uminuscnt+1;
                    end
                end
            else
                phases_cell{2}=0;
            end


            count_bits=max(2,ceil(log2(count_to)));
            [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
            [~,ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,...
            countvtype,countsltype);
            hdlregsignal(ctr_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_out)];
            [ctr_body,ctr_sigs]=hdlcounter(ctr_out,count_to,['Counter',...
            hdlgetparameter('clock_process_label')],...
            1,count_to-1,phases_cell);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_sigs)];

            hdladdclockenablesignal(ctr_sigs);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body];
            ce_delay=ctr_sigs(1);
            ce_accum=hdlgetcurrentclockenable();
            if strcmpi(final_adder_style,'pipelined')
                ce_mux4uminus=ctr_sigs(mux4uminuscnt);
                ce_afinal=ctr_sigs(afinalcnt);
                xcycles=1+nbaatPipeRegs+nlutPipeRegs;
                xlatency=1+floor(xcycles/ffactor);
                hdlsetparameter('filter_excess_latency',...
                hdlgetparameter('filter_excess_latency')+xlatency);
            else
                ce_afinal=ctr_sigs(2);
                hdlsetparameter('filter_excess_latency',...
                hdlgetparameter('filter_excess_latency')+1);
                ce_mux4uminus=ctr_sigs(1);
            end
            controlsigs=[ce_delay,ce_accum,ce_afinal,ce_mux4uminus];
            hdlsetparameter('foldingfactor',ffactor);
            fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkrate',...
            hdlgetparameter('foldingfactor'))));
...
...
...
...
        else



            ffactor=inputsize/baat+1;
            count_to=ffactor;
            phases_cell{1}=count_to-1;
            phases_cell{2}=0;
            phases_cell{3}=[count_to-1,0:count_to-3];
            if baat>1
                phases_cell{4}=count_to-2;
            end

            count_bits=max(2,ceil(log2(count_to)));
            [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
            [~,ctr_out]=hdlnewsignal('cur_count','filter',-1,0,0,...
            countvtype,countsltype);
            hdlregsignal(ctr_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_out)];
            [ctr_body,ctr_sigs]=hdlcounter(ctr_out,count_to,['Counter',...
            hdlgetparameter('clock_process_label')],...
            1,count_to-1,phases_cell);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ctr_sigs)];

            hdladdclockenablesignal(ctr_sigs);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body];
            ce_delay=ctr_sigs(1);
            ce_accum=hdlgetcurrentclockenable();
            ce_afinal=ctr_sigs(2);
            ce_mux4uminus=ctr_sigs(1);
            ce_serializer=ctr_sigs(3);
            if baat>1
                ce_symcarry=ctr_sigs(4);
                controlsigs=[ce_delay,ce_accum,ce_afinal,ce_mux4uminus,ce_serializer,ce_symcarry];
            else
                controlsigs=[ce_delay,ce_accum,ce_afinal,ce_mux4uminus,ce_serializer];
            end
            hdlsetparameter('foldingfactor',ffactor);
            hdlsetparameter('filter_excess_latency',...
            hdlgetparameter('filter_excess_latency')+1);
            fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkrate',...
            hdlgetparameter('foldingfactor'))));
...
...
...
...
        end

        LocalTCinfo.enbsIn=hdlsignalname(hdlgetcurrentclockenable);
        LocalTCinfo.enbsOut=ctr_sigs;
        LocalTCinfo.phases=phases_cell;
        LocalTCinfo.maxCount=count_to;
        LocalTCinfo.initValue=count_to-1;
        setLocalTimingInfo(this,LocalTCinfo);

    else


        if strcmpi(final_adder_style,'pipelined')
            nbaatPipeRegs=max((ceil(log2(baat))-1),0);
            nlutPipeRegs=max((ceil(log2(length(lpi)))),0);
            hdlsetparameter('filter_excess_latency',...
            hdlgetparameter('filter_excess_latency')+nlutPipeRegs+nbaatPipeRegs);
        end
        hdlsetparameter('foldingfactor',1);

        ce_delay=hdlgetcurrentclockenable();
        controlsigs=[ce_delay,ce_delay];
        fprintf('%s\n',getString(message('HDLShared:hdlfilter:codegenmessage:clkratesame')));
...
...
...
...
    end




    if hdlgetparameter('filter_generate_datavalid_output')

        if baat~=inputsize

            count_bits=max(2,ceil(log2(count_to)));
            [countvtype,countsltype]=hdlgettypesfromsizes(count_bits,0,0);
            [~,ce.ctr2_out]=hdlnewsignal('cur_count1','filter',-1,0,0,...
            countvtype,countsltype);
            hdlregsignal(ce.ctr2_out);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.ctr2_out)];

            [ctr_body1,ce.outputvld]=hdlcounter(ce.ctr2_out,count_to,['Counter2',...
            hdlgetparameter('clock_process_label')],1,count_to-1,count_to-1);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,ctr_body1];
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.outputvld)];
        else

            ce.outputvld=hdlgetcurrentclockenable;
        end

    end
    [hdlbody,hdlsignals,hdltypedefs,hdlconstants,last_sum]=this.emit_damac(inputcastsig,coeffs,internalstructure,controlsigs,lpi,fp_accumsize,final_adder_style,'');
    hdl_arch.body_blocks=[hdl_arch.body_blocks,hdlbody];
    hdl_arch.signals=[hdl_arch.signals,hdlsignals];
    hdl_arch.typedefs=[hdl_arch.typedefs,hdltypedefs];
    hdl_arch.constants=[hdl_arch.constants,hdlconstants];
    ce.delay=ce_delay;
