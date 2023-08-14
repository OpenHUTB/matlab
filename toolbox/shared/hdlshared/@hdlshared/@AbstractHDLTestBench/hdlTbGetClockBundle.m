function[clk,reset,clkenb,hdlsignals]=hdlTbGetClockBundle(this)



    bdt=hdlgetparameter('base_data_type');
    hdlsignals=[];

    clk=hdlsignalfindname(this.ClockName);
    if isempty(clk)
        [~,clk]=hdlnewsignal(this.ClockName,'block',-1,0,0,bdt,'boolean');
        hdlregsignal(clk);
        hdlsignals=[hdlsignals,makehdlsignaldecl(clk)];
    end

    reset=hdlsignalfindname(this.ResetName);
    if isempty(reset)
        [~,reset]=hdlnewsignal(this.ResetName,'block',-1,0,0,bdt,'boolean');
        hdlregsignal(reset);
        hdlsignals=[hdlsignals,makehdlsignaldecl(reset)];
    end

    clkenb=hdlsignalfindname(this.ClockEnableName);
    if isempty(clkenb)
        [~,clkenb]=hdlnewsignal(this.ClockEnableName,'block',-1,0,0,bdt,'boolean');
        hdlregsignal(clkenb);
        hdlsignals=[hdlsignals,makehdlsignaldecl(clkenb)];
    end

    hdladdclocksignal(clk);
    hdladdresetsignal(reset);
    hdladdclockenablesignal(clkenb);
