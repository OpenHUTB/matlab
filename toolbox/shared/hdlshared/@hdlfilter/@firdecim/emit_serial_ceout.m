function[hdl_arch,ce]=emit_serial_ceout(this,hdl_arch,ce,phasece,count_to)





    arch=this.implementation;

    bdt=hdlgetparameter('base_data_type');

    if hdlgetparameter('filter_registered_output')==1
        if strcmpi(arch,'serial')
            [~,ce.out_reg]=hdlnewsignal('ce_out_reg','filter',-1,0,0,bdt,'boolean');
            hdlregsignal(ce.out_reg);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_reg)];
            [intdelaybody,intdelaysignals]=hdlunitdelay(ce.outsig,ce.out_reg,['ce_out_register',hdlgetparameter('clock_process_label')],0);
            hdl_arch.body_blocks=[hdl_arch.body_blocks,intdelaybody];
            hdl_arch.signals=[hdl_arch.signals,intdelaysignals];
        else
            [~,ce.outsig]=hdlnewsignal('ce_out_temp','filter',-1,0,0,bdt,'boolean');
            [~,ce.out_reg]=hdlnewsignal('ce_out_reg','filter',-1,0,0,bdt,'boolean');
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.outsig)];
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_reg)];

            [~,oneptr]=hdlnewsignal('const_one','filter',-1,0,0,bdt,'boolean');
            onevalue=hdlconstantvalue(1,1,0,0);
            hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(oneptr,onevalue)];
            tempbody=hdlbitop([ce.ceout,oneptr],ce.outsig,'AND');
            if strcmpi(arch,'serial')
                if hdlgetparameter('filter_registered_input')==1
                    intdelay_to=3;
                else
                    intdelay_to=3;
                end
            else
                intdelay_to=count_to+1;
            end
            if intdelay_to==1
                [intdelaybody,intdelaysignals]=hdlunitdelay(ce.outsig,ce.out_reg,['ce_out_delay',hdlgetparameter('clock_process_label')],0);
            else
                obj=hdl.intdelay('clock',hdlgetcurrentclock,...
                'clockenable',hdlgetcurrentclockenable,...
                'reset',hdlgetcurrentreset,...
                'inputs',ce.outsig,...
                'outputs',ce.out_reg,...
                'processName',['ce_out_delay',hdlgetparameter('clock_process_label')],...
                'resetvalues',0,...
                'nDelays',intdelay_to);
                if~strcmpi(hdlgetparameter('RemoveResetFrom'),'none')
                    obj.setResetNone;
                end
                intdelaycode=obj.emit;
                intdelaybody=intdelaycode.arch_body_blocks;
                intdelaysignals=intdelaycode.arch_signals;
            end
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody,intdelaybody];
            hdl_arch.signals=[hdl_arch.signals,intdelaysignals];
        end

    else
        if strcmpi(arch,'serial')
            ce.out_reg=ce.outsig;
        else
            ce.out_reg=phasece(1);
        end
    end



