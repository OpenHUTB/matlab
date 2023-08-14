function[hdlcode,clkenables,fdinit]=emit_timingcontrol(this,entity_ceouts)






    entity_cein_output=entity_ceouts(1);
    entity_ceout_output=entity_ceouts(2);


    arch_signals='';
    arch_body_blocks='';
    arch_body_output_assignments='';
    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];


    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end
    addinputreg=hdlgetparameter('filter_registered_input');
    addoutputreg=hdlgetparameter('filter_registered_output');
    bdt=hdlgetparameter('base_data_type');

    if isa(this,'hdlfilter.firsrc')
        phases=this.ratechangefactors(1);
        decim_factor=this.ratechangefactors(1);
    else
        phases=this.InterpolationFactor;
        decim_factor=this.DecimationFactor;
    end

    rcf=[phases,decim_factor];

    [clkrate,count_to,cforder,phase_ceout,phase_cein,phase_fd,iporder,oporder]=hsrc(rcf);

    fdinittemp=phases+1-cforder;
    fdinit=fdinittemp(end);
    countsize=max(2,ceil(log2(count_to+1)));
    if phases<decim_factor


        decodeval={phase_ceout,phase_fd};
        if~addinputreg&&addoutputreg

            fdinit=fdinittemp(1);
        end
    else
        if decim_factor==1



            decodeval={phase_cein};
            if~addinputreg&&addoutputreg

                fdinit=fdinittemp(1);
            end
        else
            if~addinputreg
                fdinit=fdinittemp(1);
                if~addoutputreg
                    decodeval={phase_cein,phase_ceout-1,phase_fd,mod((phase_cein+1),(count_to+1))};
                else
                    decodeval={phase_cein,phase_ceout-1,phase_fd};
                end
            else
                decodeval={phase_cein,phase_ceout,phase_fd};
            end
        end
    end

    [countervtype,countersltype]=hdlgettypesfromsizes(countsize,0,0);
    [tempname,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
    hdlregsignal(counter_out);
    arch_signals=[arch_signals,makehdlsignaldecl(counter_out)];



    [tempprocessbody,ce_outs]=hdlcounter(counter_out,count_to+1,'ce_output',1,double(~addinputreg),decodeval);

    arch_signals=[arch_signals,makehdlsignaldecl(ce_outs)];
    hdladdclockenablesignal(ce_outs);

    clken=hdlgetcurrentclockenable;

    if phases<decim_factor
        ce_in_temp=clken;
        ce_out_temp=ce_outs(1);
        ce_fd=ce_outs(2);
    else
        if decim_factor==1
            ce_in_temp=ce_outs(1);
            ce_out_temp=clken;
            ce_fd=clken;
        else
            ce_in_temp=ce_outs(1);
            ce_out_temp=ce_outs(2);
            ce_fd=ce_outs(3);
            if~addinputreg&&~addoutputreg
                ce_inputoutputoff_temp=ce_outs(4);
            end
        end
    end









    arch_body_blocks=[arch_body_blocks,...
    indentedcomment,...
    '  ------------------ CE Output Generation ------------------\n\n'];
    arch_body_blocks=[arch_body_blocks,tempprocessbody];


    if multiclock==0




        if addoutputreg
            arch_body_blocks=[arch_body_blocks,...
            indentedcomment,...
            '  ------------------ CE Output Register ------------------\n\n'];

            [tempname,ce_out_reg]=hdlnewsignal('ce_out_reg','filter',-1,0,0,bdt,'boolean');
            hdladdclockenablesignal(ce_out_reg);
            if decim_factor==1&&addinputreg
                arch_signals=[arch_signals,makehdlsignaldecl(ce_out_reg)];
                obj=hdl.intdelay('clock',hdlgetcurrentclock,...
                'clockenable',hdlgetcurrentclockenable,...
                'reset',hdlgetcurrentreset,...
                'inputs',ce_out_temp,...
                'outputs',ce_out_reg,...
                'processName',['ce_out_delay',hdlgetparameter('clock_process_label')],...
                'resetvalues',0,...
                'nDelays',2);
                if~strcmpi(hdlgetparameter('RemoveResetFrom'),'none')
                    obj.setResetNone;
                end
                intdelaycode=obj.emit;
                arch_body_blocks=[arch_body_blocks,intdelaycode.arch_body_blocks];
                arch_signals=[arch_signals,intdelaycode.arch_signals];
            else
                hdlregsignal(ce_out_reg);
                arch_signals=[arch_signals,makehdlsignaldecl(ce_out_reg)];



                [tempprocessbody,tempsignal]=hdlunitdelay(ce_out_temp,ce_out_reg,['ce_out_delay',hdlgetparameter('clock_process_label')],0);


                if~isempty(tempsignal)
                    arch_signals=[arch_signals,makehdlsignaldecl(tempsignal)];
                end
                arch_body_blocks=[arch_body_blocks,tempprocessbody];
            end


            arch_body_blocks=[arch_body_blocks,...
            indentedcomment,...
            '  ------------------ CE Input Register ------------------\n\n'];

            [tempname,ce_in_reg]=hdlnewsignal('ce_in_reg','filter',-1,0,0,bdt,'boolean');
            hdlregsignal(ce_in_reg);
            hdladdclockenablesignal(ce_in_reg);
            arch_signals=[arch_signals,makehdlsignaldecl(ce_in_reg)];


            temp_enable=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable([]);
            [tempprocessbody,tempsignal]=hdlunitdelay(ce_in_temp,ce_in_reg,'ce_input_register',0);
            hdlsetcurrentclockenable(temp_enable);


            if~isempty(tempsignal)
                arch_signals=[arch_signals,makehdlsignaldecl(tempsignal)];
            end
            arch_body_blocks=[arch_body_blocks,tempprocessbody];
        else
            ce_out_reg=ce_out_temp;
            if~addinputreg&&~addoutputreg&&(phases>decim_factor)
                ce_in_reg=ce_inputoutputoff_temp;
            else
                ce_in_reg=ce_in_temp;
            end
        end

        [tempname,ce_out_phase]=hdlnewsignal('ce_out_phase','filter',-1,0,0,bdt,'boolean');
        arch_signals=[arch_signals,makehdlsignaldecl(ce_out_phase)];
        tempbody=hdlbitop([ce_out_reg,hdlgetcurrentclockenable],ce_out_phase,'AND');
        arch_body_blocks=[arch_body_blocks,tempbody];
        ce_out_reg=ce_out_phase;

        [tempbody,tempsignals]=hdlfinalassignment(ce_out_reg,entity_ceout_output);
        arch_signals=[arch_signals,tempsignals];
        arch_body_output_assignments=[arch_body_output_assignments,tempbody];
        [tempbody,tempsignals]=hdlfinalassignment(ce_in_reg,entity_cein_output);
        arch_signals=[arch_signals,tempsignals];
        arch_body_output_assignments=[arch_body_output_assignments,tempbody];
        hdlcode.signals=arch_signals;
        hdlcode.body_blocks=arch_body_blocks;
        hdlcode.body_output_assignments=arch_body_output_assignments;
        clkenables.in_reg=ce_in_reg;
        clkenables.delay=ce_in_temp;
        clkenables.output=ce_out_temp;
        clkenables.out_reg=ce_out_reg;
        clkenables.fd=ce_fd;
    end

    function[clkrate,count_to,cforder,decodedop,decodedip,decodedfd,iporder,oporder]=hsrc(rcf)




        intf=rcf(1);
        df=rcf(2);

        tempip=[];
        tempop=[];

        for n=1:df
            tempip=[tempip,n*ones(1,intf)];
        end
        for n=1:intf
            tempop=[tempop,n*ones(1,df)];
        end
        tempcf=0:intf*df-1;
        tempcf=mod(tempcf,intf)+1;
        cforder=tempcf(1:df:end);
        oporder=tempop(1:df:end);
        iporder=tempip(1:df:end);

        clkrate=ceil(intf/df);
        count_to=ceil(intf/df)*df-1;
        if intf>df


            ipunique=unique(iporder);
            ipfreq=[];
            for n=1:length(ipunique)
                ipfreq=[ipfreq,length(find(iporder==ipunique(n)))];
            end
            counts=[1:count_to,0];
            phaseindx=[];
            strt=1;
            for n=1:length(ipfreq)
                phaseindx=[phaseindx,strt:strt+ipfreq(n)-1];
                strt=strt+clkrate;
            end
            decodedop=counts(phaseindx);
        else

            decodedop=iporder;
        end
        countsip=0:count_to;
        decodedip=countsip(1:clkrate:end);
        decodedfd=decodedop-1;


