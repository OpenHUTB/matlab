function[hdl_arch,ce,cforder,phase_ceout]=emit_timingcontrol(this,entitysigs,ce)









    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    indentedcomment=['  ',hdlgetparameter('comment_char'),' '];


    if hdlgetparameter('clockinputs')==1
        multiclock=0;
    else
        multiclock=1;
    end
    addinputreg=hdlgetparameter('filter_registered_input');
    addoutputreg=hdlgetparameter('filter_registered_output');
    bdt=hdlgetparameter('base_data_type');

    phases=this.ratechangefactors(1);
    decim_factor=this.ratechangefactors(2);
    rcf=[phases,decim_factor];

    [clkrate,count_to,cforder,phase_ceout,phase_cein,iporder,oporder]=hsrc(rcf);
    countsize=max(2,ceil(log2(count_to+1)));

    if phases<decim_factor
        decodeval={phase_ceout};

    else
        if decim_factor==1
            decodeval={phase_cein};

        else

            if~addinputreg&&~addoutputreg
                decodeval={phase_cein,phase_ceout,mod((phase_cein+1),(count_to+1))};
            else
                decodeval={phase_cein,phase_ceout};
            end
        end
    end

    [countervtype,countersltype]=hdlgettypesfromsizes(countsize,0,0);
    [tempname,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
    hdlregsignal(counter_out);
    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(counter_out)];


    [tempprocessbody,ce.out]=hdlcounter(counter_out,count_to+1,'ce_output',1,double(~addinputreg),decodeval);

    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out)];
    hdladdclockenablesignal(ce.out);

    clken=hdlsignalfindname(hdlgetparameter('clockenablename'));

    if phases<decim_factor
        ce.in_temp=clken;
        ce.out_temp=ce.out(1);
    else
        if decim_factor==1
            ce.in_temp=ce.out(1);
            ce.out_temp=clken;
        else
            ce.in_temp=ce.out(1);
            ce.out_temp=ce.out(2);
            if~addinputreg&&~addoutputreg
                ce.inputoutputoff_temp=ce.out(3);
            end
        end
    end










    hdl_arch.body_blocks=[hdl_arch.body_blocks,...
    indentedcomment,...
    '  ------------------ CE Output Generation ------------------\n\n'];
    hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];
    ce.output=clken;




    if multiclock==0









        if addoutputreg
            hdl_arch.body_blocks=[hdl_arch.body_blocks,...
            indentedcomment,...
            '  ------------------ CE Output Register ------------------\n\n'];

            [tempname,ce.out_reg]=hdlnewsignal('ce_out_reg','filter',-1,0,0,bdt,'boolean');
            hdladdclockenablesignal(ce.out_reg);
            if decim_factor==1&&addinputreg
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_reg)];

                obj=hdl.intdelay('clock',hdlgetcurrentclock,...
                'clockenable',hdlgetcurrentclockenable,...
                'reset',hdlgetcurrentreset,...
                'inputs',ce.out_temp,...
                'outputs',ce.out_reg,...
                'processName',['ce_out_delay',hdlgetparameter('clock_process_label')],...
                'resetvalues',0,...
                'nDelays',2);
                if strcmpi(hdlgetparameter('RemoveResetFrom'),'none')
                    obj.setResetNone;
                end
                intdelaycode=obj.emit;
                hdl_arch.body_blocks=[hdl_arch.body_blocks,intdelaycode.arch_body_blocks];
                hdl_arch.signals=[hdl_arch.signals,intdelaycode.arch_signals];
            else
                hdlregsignal(ce.out_reg);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.out_reg)];

                temp_enable=hdlgetcurrentclockenable;
                hdlsetcurrentclockenable([]);
                [tempprocessbody,tempsignal]=hdlunitdelay(ce.out_temp,ce.out_reg,['ce_out_delay',hdlgetparameter('clock_process_label')],0);
                hdlsetcurrentclockenable(temp_enable);

                if~isempty(tempsignal)
                    hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(tempsignal)];
                end
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];
            end


            hdl_arch.body_blocks=[hdl_arch.body_blocks,...
            indentedcomment,...
            '  ------------------ CE Input Register ------------------\n\n'];

            [tempname,ce.in_reg]=hdlnewsignal('ce_in_reg','filter',-1,0,0,bdt,'boolean');
            hdlregsignal(ce.in_reg);
            hdladdclockenablesignal(ce.in_reg);
            hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce.in_reg)];


            temp_enable=hdlgetcurrentclockenable;
            hdlsetcurrentclockenable([]);
            [tempprocessbody,tempsignal]=hdlunitdelay(ce.in_temp,ce.in_reg,'ce_input_register',0);
            hdlsetcurrentclockenable(temp_enable);


            if~isempty(tempsignal)
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(tempsignal)];
            end
            hdl_arch.body_blocks=[hdl_arch.body_blocks,tempprocessbody];
        else
            ce.out_reg=ce.out_temp;
            if~addinputreg&&~addoutputreg&&(phases>decim_factor)
                ce.in_reg=ce.inputoutputoff_temp;
            else
                ce.in_reg=ce.in_temp;
            end
        end


        [tempname,ce_out_phase]=hdlnewsignal('ce_out_phase','filter',-1,0,0,bdt,'boolean');
        hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ce_out_phase)];
        tempbody=hdlbitop([ce.out_reg,hdlgetcurrentclockenable],ce_out_phase,'AND');
        hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];
        ce.out_reg=ce_out_phase;

        [tempbody,tempsignals]=hdlfinalassignment(ce.out_reg,entitysigs.ceout_output);
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
        [tempbody,tempsignals]=hdlfinalassignment(ce.in_reg,entitysigs.cein_output);
        hdl_arch.signals=[hdl_arch.signals,tempsignals];
        hdl_arch.body_output_assignments=[hdl_arch.body_output_assignments,tempbody];
    end

    function[clkrate,count_to,cforder,decodedop,decodedip,iporder,oporder]=hsrc(rcf)




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
        ipstr=[];opstr=[];cfstr=[];
        spacing=length(num2str(max(rcf)))+3;
        for n=1:intf
            ipstr=[ipstr,'I',num2str(iporder(n)),' '*ones(1,spacing-length(num2str(iporder(n))))];
            opstr=[opstr,'O',num2str(oporder(n)),' '*ones(1,spacing-length(num2str(oporder(n))))];
            cfstr=[cfstr,num2str(cforder(n)),' '*ones(1,spacing+1-length(num2str(cforder(n))))];
        end
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


