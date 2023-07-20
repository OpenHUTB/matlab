function[shiftdelaybody,shiftdelaysignals,shiftdelayconsts,output]=emit_PhaseShiftRegisterDelay(this,...
    inputphase,indelayprocessname,intdelay_to)






    bdt=hdlgetparameter('base_data_type');

    [~,tempsig]=hdlnewsignal('phase_temp','filter',-1,0,0,bdt,'boolean');
    [~,regsig]=hdlnewsignal('phase_reg','filter',-1,0,0,bdt,'boolean');
    if intdelay_to==1
        hdlregsignal(regsig);
    end
    shiftdelaysignals=[makehdlsignaldecl(tempsig),makehdlsignaldecl(regsig)];

    [~,oneptr]=hdlnewsignal('const_one','filter',-1,0,0,bdt,'boolean');
    onevalue=hdlconstantvalue(1,1,0,0);
    shiftdelayconsts=makehdlconstantdecl(oneptr,onevalue);

    tempbody=hdlbitop([inputphase,oneptr],tempsig,'AND');
    if intdelay_to==1
        [intdelaybody,intdelaysignals]=hdlunitdelay(tempsig,regsig,...
        indelayprocessname,0);
    else
        obj=hdl.intdelay('clock',hdlgetcurrentclock,...
        'clockenable',hdlgetcurrentclockenable,...
        'reset',hdlgetcurrentreset,...
        'inputs',tempsig,...
        'outputs',regsig,...
        'processName',indelayprocessname,...
        'resetvalues',0,...
        'nDelays',intdelay_to);
        if~strcmpi(hdlgetparameter('RemoveResetFrom'),'none')
            obj.setResetNone;
        end
        intdelaycode=obj.emit;
        intdelaybody=intdelaycode.arch_body_blocks;
        intdelaysignals=intdelaycode.arch_signals;
    end
    shiftdelaybody=[tempbody,intdelaybody];
    shiftdelaysignals=[shiftdelaysignals,intdelaysignals];

    output=regsig;
    hdladdclockenablesignal(regsig);



