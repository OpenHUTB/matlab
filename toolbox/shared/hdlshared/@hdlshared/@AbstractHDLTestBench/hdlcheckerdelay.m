function hdlbody=hdlcheckerdelay(this,instance,check_enb,check_cnt,cnt_sz,delay,task_rdenb)


    if hdlgetparameter('isvhdl')
        hdlbody=this.vhdlcheckerdelay(instance,check_enb,check_cnt,cnt_sz,delay,task_rdenb);
    else
        hdlbody=this.verilogcheckerdelay(instance,check_enb,check_cnt,cnt_sz,delay,task_rdenb);
    end
