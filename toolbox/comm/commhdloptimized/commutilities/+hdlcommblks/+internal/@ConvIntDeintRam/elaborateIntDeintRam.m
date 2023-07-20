function elaborateIntDeintRam(this,hN,hC)%#ok





    slbh=hC.SimulinkHandle;

    N=hdlslResolve('N',slbh);
    B=hdlslResolve('B',slbh);


    isint=strcmpi(hdlgetblocklibpath(slbh),...
    ['commcnvintrlv2/Convolutional',newline,'Interleaver']);







    wr_addr_ic=0;
    if isint
        blkname='Convolutional Interleaver - RAM Implementation';
        rd_addr_ic=1;
        ram_rd_addr=addr_incr_1(hN,'read',rd_addr_ic,N,B);
        ram_wr_addr=addr_incr_NB1(hN,'write',wr_addr_ic,N,B);
    else
        blkname='Convolutional Deinterleaver - RAM Implementation';
        rd_addr_ic=2*((N*B)+1)-1;
        ram_rd_addr=addr_incr_NB1(hN,'read',rd_addr_ic,N,B);
        ram_wr_addr=addr_incr_1(hN,'write',wr_addr_ic,N,B);
    end


    hN.addComment(blkname);
    hN.addComment(['N (rows) = ',num2str(N),', B (register length step) = ',num2str(B)]);
    hN.addComment(['RAM size = ',num2str(N*B*N),' locations']);








    ip_sig=hN.PirInputSignals(1);
    op_sig=hN.PirOutputSignals(1);


    ram_compName=[hC.Name,'_RAM'];
    ram_wr_din=ip_sig;

    en_hT=hN.getType('Boolean');
    ram_wr_en=hN.addSignal2('Type',en_hT,'Name','ram_wr_en');
    rwenComp=pirelab.getConstComp(hN,ram_wr_en,1);
    rwenComp.addComment('RAM write enable - always high');



    ram_wr_addr.SimulinkRate=ip_sig.SimulinkRate;
    ram_rd_addr.SimulinkRate=ip_sig.SimulinkRate;
    ram_wr_en.SimulinkRate=ip_sig.SimulinkRate;
    ram_insigs=[ram_wr_din,ram_wr_addr,ram_wr_en,ram_rd_addr];



    op_hT=ram_wr_din.Type;
    ram_wr_dout=hN.addSignal2('Type',op_hT,'Name','ram_rd_out');

    ram_wr_dout.SimulinkRate=ip_sig.SimulinkRate;



    pirelab.getSimpleDualPortRamComp(hN,ram_insigs,ram_wr_dout,...
    ram_compName);





    addr_hT=ram_rd_addr.Type;
    addr_name=ram_rd_addr.Name;
    ram_rd_addr_reg=hN.addSignal2('Type',addr_hT,'Name',[addr_name,'2']);


    rd_addr_ic2=0;
    udComp=pirelab.getUnitDelayComp(hN,ram_rd_addr,ram_rd_addr_reg,'read_address2',rd_addr_ic2);
    udComp.addComment('Register read address again to align with write address');

    rd_eq_wr_signame='iseq_rd_wr_addr';
    rd_eq_wr=hN.addSignal2('Type',en_hT,'Name',rd_eq_wr_signame);
    rdeqwrComp=pirelab.getRelOpComp(hN,[ram_rd_addr_reg,ram_wr_addr],rd_eq_wr,'==');
    rdeqwrComp.addComment([rd_eq_wr_signame,' - high if read address is same as write address']);




    muxComp=pirelab.getSwitchComp(hN,[ram_wr_dout,ip_sig],op_sig,rd_eq_wr);
    muxComp.addComment('Send input if read and write addresses are the same, else send RAM output');


end

function addr_reg=addr_incr_1(hN,rdwr_flag,addr_ic,N,B)






    addr_size=N*B*N;
    addr_wl=ceil(log2(addr_size));
    addr_hT=hN.getType('FixedPoint','Signed',0,'WordLength',addr_wl,...
    'FractionLength',0);


    addr_sig=hN.addSignal2('Type',addr_hT,'Name',[rdwr_flag,'_addr']);
    addr_reg=hN.addSignal2('Type',addr_hT,'Name',[rdwr_flag,'_addr_reg']);



    const_1=hN.addSignal2('Type',addr_hT,'Name','const_1');
    c1Comp=pirelab.getConstComp(hN,const_1,1);
    c1Comp.addComment(['Constant value of 1 - used to increment ',rdwr_flag,' address']);


    addr_incr_1=hN.addSignal2('Type',addr_hT,'Name',[rdwr_flag,'_incr_1']);
    adder_inputs=[addr_reg,const_1];
    aComp=pirelab.getAddComp(hN,adder_inputs,addr_incr_1,'floor','wrap','increment_by_1');
    aComp.addComment(['Increment ',rdwr_flag,' address by 1']);


    wrap_const_0=hN.addSignal2('Type',addr_hT,'Name','wrap_const_0');
    wComp=pirelab.getConstComp(hN,wrap_const_0,0);
    wComp.addComment('Wrap around address when address reaches maximum value');







    en_hT=hN.getType('Boolean');
    is_incr_max=hN.addSignal2('Type',en_hT,'Name',['is_',rdwr_flag,'_incr_max']);
    cvComp=pirelab.getCompareToValueComp(hN,addr_reg,is_incr_max,'==',...
    addr_size-1,[rdwr_flag,'_max']);
    cvComp.addComment([is_incr_max.Name,' sent high when ',addr_incr_1.Name...
    ,' reaches the value ',num2str(addr_size-1)]);


    sComp=pirelab.getSwitchComp(hN,[wrap_const_0,addr_incr_1],addr_sig,is_incr_max,...
    'wrap_or_incr','==',1);
    sComp.addComment('If max address has not been reached, increment by 1; else wrap to 0');


    udComp=pirelab.getUnitDelayComp(hN,addr_sig,addr_reg,[rdwr_flag,'_address'],addr_ic);
    udComp.addComment(['Register ',rdwr_flag,' address']);

end


function addr_reg=addr_incr_NB1(hN,rdwr_flag,addr_ic,N,B)








    addr_size=N*B*N;
    addr_wl=ceil(log2(addr_size));
    addr_hT=hN.getType('FixedPoint','Signed',0,'WordLength',addr_wl,...
    'FractionLength',0);


    addr_sig=hN.addSignal2('Type',addr_hT,'Name',[rdwr_flag,'_addr']);
    addr_reg=hN.addSignal2('Type',addr_hT,'Name',[rdwr_flag,'_addr_reg']);



    incr_val=(N*B)+1;
    const_NB1=hN.addSignal2('Type',addr_hT,'Name','const_NB1');
    nb1Comp=pirelab.getConstComp(hN,const_NB1,incr_val);
    nb1Comp.addComment(['Increment constant for ',rdwr_flag,' address']);


    addr_incr_NB1=hN.addSignal2('Type',addr_hT,'Name',[rdwr_flag,'_incr_NB1']);
    adder_inputs=[addr_reg,const_NB1];
    incr_str=num2str(incr_val);
    aComp=pirelab.getAddComp(hN,adder_inputs,addr_incr_NB1,'floor','wrap',['increment_by_',incr_str]);
    aComp.addComment(['Increment address by ',incr_str]);






    wrap_sub_const=hN.addSignal2('Type',addr_hT,'Name','wrap_sub_const');
    decr_val=((N*B*N)-(N*B)-1);
    wcComp=pirelab.getConstComp(hN,wrap_sub_const,decr_val);
    wcComp.addComment('Constant to subtract from address');


    addr_wrap=hN.addSignal2('Type',addr_hT,'Name',[rdwr_flag,'_wrap']);
    sub_inputs=[addr_reg,wrap_sub_const];
    decr_str=num2str(decr_val);
    subComp=pirelab.getSubComp(hN,sub_inputs,addr_wrap,'floor','wrap',...
    ['subtract_',decr_str]);
    subComp.addComment(['Decrement address by ',decr_str...
    ,' - used when address has wrapped around maximum value']);



    en_hT=hN.getType('Boolean');
    addr_max_val=((N*B*N)-1)-((N*B)+1);
    is_incr_max=hN.addSignal2('Type',en_hT,'Name',['is_',rdwr_flag,'_incr_max']);
    cvComp=pirelab.getCompareToValueComp(hN,addr_reg,is_incr_max,'>',...
    addr_max_val,[rdwr_flag,'_max']);
    cvComp.addComment([is_incr_max.Name,' sent high when ',addr_reg.Name...
    ,' is greater than ',num2str(addr_max_val)]);


    sComp=pirelab.getSwitchComp(hN,[addr_wrap,addr_incr_NB1],addr_sig,is_incr_max,...
    'wrap_or_incr','==',1);
    sComp.addComment('If address is not going to wrap, use incremented address; else use wrapped address');


    udComp=pirelab.getUnitDelayComp(hN,addr_sig,addr_reg,[rdwr_flag,'_address'],addr_ic);
    udComp.addComment(['Register ',rdwr_flag,' address']);


end



