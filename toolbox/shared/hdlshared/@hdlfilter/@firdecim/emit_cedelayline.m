function[hdl_arch]=emit_cedelayline(this,entitysigs,ce_out_reg)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    bdt=hdlgetparameter('base_data_type');
    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end

    clken=hdlsignalfindname(hdlgetparameter('clockenablename'));

    if multiclock==0

        if~(strcmpi(this.implementation,'serial')||strcmpi(this.implementation,'serialcascade'))

            if(hdlgetparameter('filter_pipelined')||...
                strcmpi(hdlgetparameter('filter_fir_final_adder'),'pipelined')||...
                hdlgetparameter('multiplier_input_pipeline')>0||...
                hdlgetparameter('multiplier_output_pipeline')>0)...
                &&hdlgetparameter('filter_excess_latency')~=0

                saved_ce=hdlgetcurrentclockenable;
                hdlsetcurrentclockenable(clken);
                cedelaylen=hdlgetparameter('filter_excess_latency');
                if hdlgetparameter('filter_registered_input')==1
                    if hdlgetparameter('filter_registered_output')==1

                        lenextra=2;
                    else

                        lenextra=1;
                    end
                else
                    if hdlgetparameter('filter_registered_output')==1

                        lenextra=1;
                    else

                        lenextra=0;
                    end
                end
                cedelaylen=cedelaylen+lenextra;
                if cedelaylen==1
                    [~,ce_delayline]=hdlnewsignal('ce_delayline','filter',-1,0,0,bdt,'boolean');
                    hdlregsignal(ce_delayline);
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce_delayline)];
                    [tempbody,tempsignals]=hdlunitdelay(clken,ce_delayline,'ce_delay',0);
                else
                    for ce=1:cedelaylen
                        [~,tmpsig]=hdlnewsignal(['ce_delayline',num2str(ce)],'filter',-1,0,0,...
                        bdt,'boolean');
                        hdlregsignal(tmpsig);
                        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(tmpsig)];
                        ce_delayline(ce)=tmpsig;
                    end
                    [tempbody,tempsignals]=hdlunitdelay([clken,ce_delayline(1:end-1)],...
                    ce_delayline,'ce_delay',...
                    zeros(1,cedelaylen));
                    ce_delayline=ce_delayline(end);
                end
                hdl_arch.signals=[hdl_arch.signals,tempsignals];
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];

                [~,ce_internal]=hdlnewsignal('ce_gated','filter',-1,0,0,bdt,'boolean');
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce_internal)];
                temp_body=hdllogop([ce_delayline,ce_out_reg],ce_internal,'AND');
                hdl_arch.body_blocks=[hdl_arch.body_blocks,temp_body];
                ce_out_reg=ce_internal;
                hdlsetcurrentclockenable(saved_ce);
            end
        end
        [tempbody,tempsignals]=hdlfinalassignment(ce_out_reg,entitysigs.ceoutput);
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
    end


