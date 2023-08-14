function info=getBlockInfo(this,slbh)



    info.fifo_size=this.hdlslResolve('fifo_size',slbh);
    info.address_size=ceil(log2(info.fifo_size));


    ratio=this.hdlslResolve('ratio',slbh);
    if ratio>1
        info.input_rate=1;
        info.output_rate=ratio;
    else
        info.input_rate=1/ratio;
        info.output_rate=1;
    end


    ison=@(s)strcmpi(get(slbh,s),'on');
    info.empty_on=ison('show_empty');
    info.full_on=ison('show_full');
    info.afull_on=false;
    info.num_on=ison('show_num');
    info.rst_on=ison('rst_port');


    info.name=hdllegalname(get(slbh,'name'));


    info.ramCorePrefix='';


    info.isFWFT=strcmpi(get_param(slbh,'mode'),'fwft');
end


