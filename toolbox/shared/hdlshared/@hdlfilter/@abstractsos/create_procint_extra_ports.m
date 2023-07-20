function[entitysigs]=create_procint_extra_ports(this,entitysigs)












    coeff_num=hdlgetallfromsltype(this.NumCoeffSLtype,'inputport');




    coeffsvsize=coeff_num.size;
    coeffssigned=coeff_num.signed;
    coeffsportvtype=coeff_num.portvtype;





    coeffsvbp=0;
    coeffsportsltype=hdlgetsltypefromsizes(coeffsvsize,coeffsvbp,coeffssigned);

    bdt=hdlgetparameter('base_data_type');















    addr_bits=ceil(log2(this.NumSections))+3;
    wraddrportsltype=hdlgetsltypefromsizes(addr_bits,0,0);
    wraddrall=hdlgetallfromsltype(wraddrportsltype,'inputport');
    wraddrportvtype=wraddrall.portvtype;
    wraddrportsltype=wraddrall.portsltype;



    [wrenbname,entitysigs.wrenb]=hdlnewsignal('write_enable',...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(entitysigs.wrenb);

    [wrdonename,entitysigs.wrdone]=hdlnewsignal('write_done',...
    'filter',-1,0,0,bdt,'boolean');
    hdladdinportsignal(entitysigs.wrdone);

    [wraddrname,entitysigs.wraddr]=hdlnewsignal('write_address',...
    'filter',-1,0,0,wraddrportvtype,wraddrportsltype);
    hdladdinportsignal(entitysigs.wraddr);

    [coeffsinname,entitysigs.coeffs]=hdlnewsignal('coeffs_in',...
    'filter',-1,0,0,...
    coeffsportvtype,coeffsportsltype);
    hdladdinportsignal(entitysigs.coeffs);

end

