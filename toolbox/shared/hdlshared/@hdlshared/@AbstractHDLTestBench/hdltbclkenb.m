function[hdlbody,hdlsignal,tbenb_dly]=hdltbclkenb(this,tb_enb,clkenb,snkDone,srcDone)


    hdlbody=this.insertComment({'Testbench clock enable'});
    hdlsetcurrentclockenable(tb_enb);
    bdt=hdlgetparameter('base_data_type');
    [~,tbenb_dly]=hdlnewsignal('tbenb_dly','block',-1,0,0,bdt,'boolean');
    if this.testBenchClockEnableDelay==1
        hdlregsignal(tbenb_dly);
    end


    oldclk=hdlgetcurrentclock;
    oldreset=hdlgetcurrentreset;


    signalTable=hdlgetsignaltable;
    hdlsetcurrentclock(signalTable.findSignalFromName(this.ClockName));
    hdlsetcurrentreset(signalTable.findSignalFromName(this.ResetName));

    if hdlgetparameter('minimizeclockenables')&&hdlgetparameter('clockinputs')==1
        tbenb_dly=tb_enb;
        hdlsignal=[];
    else
        [tmphdlbody,tmphdlsignals]=hdlintdelay(tb_enb,tbenb_dly,'tb_enb_delay',this.testBenchClockEnableDelay,0);
        hdlsignal=[makehdlsignaldecl(tbenb_dly),tmphdlsignals];
        hdlbody=[hdlbody,tmphdlbody];
    end




    hdlsetcurrentclock(oldclk);
    hdlsetcurrentreset(oldreset);
    hdlsetcurrentclockenable(clkenb);
