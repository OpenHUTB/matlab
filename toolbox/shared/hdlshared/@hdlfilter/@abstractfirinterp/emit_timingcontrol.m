function[hdl_arch,ce,counter_out]=emit_timingcontrol(this,ce)






    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    phases=this.interpolationfactor;

    arch=this.Implementation;

    if phases==1
        [countervtype,countersltype]=hdlgettypesfromsizes(1,0,0);
        [~,counter_out]=hdlnewsignal('cur_count','filter',-1,0,0,countervtype,countersltype);
        hdl_arch.constants=[hdl_arch.constants,...
        makehdlconstantdecl(counter_out,hdlconstantvalue(0,1,0,0))];
    else
        if strcmpi(arch,'serial')
            [hdl_arch,ce,counter_out,tcinfo]=emit_serial_timingcontrol(this,ce);
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
            clken=hdlgetcurrentclockenable;
            ce.output=clken;
        end

    end

    setLocalTimingInfo(this,tcinfo);


