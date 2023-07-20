function[entitysigs]=createportsforprocint(this,entitysigs)






    fl=getfilterlengths(this);

    firlen=fl.firlen;

    coeffall=hdlgetallfromsltype(this.CoeffSLtype);
    coeffsvsize=coeffall.size;
    coeffsvbp=coeffall.bp;
    coeffssigned=coeffall.signed;
    coeffsvtype=coeffall.vtype;
    coeffssltype=coeffall.sltype;

    bdt=hdlgetparameter('base_data_type');
    arithisdouble=strcmpi(this.inputSLtype,'double');
    addr_bits=ceil(log2(firlen));
    if arithisdouble
        if hdlgetparameter('isverilog')
            coeffsportvtype='wire [63:0]';
            wraddrportvtype='wire [63:0]';
        else
            coeffsportvtype='real';

            wraddrportvtype='real';
        end
        coeffsportsltype='double';
        wraddrportsltype='double';
    else
        if hdlgetparameter('filter_input_type_std_logic')==1
            [coeffsportvtype,coeffsportsltype]=hdlgetporttypesfromsizes(coeffsvsize,coeffsvbp,coeffssigned);
            [wraddrportvtype,wraddrportsltype]=hdlgetporttypesfromsizes(addr_bits,0,0);
        else
            coeffsportvtype=coeffsvtype;
            coeffsportsltype=coeffssltype;
            [wraddrportvtype,wraddrportsltype]=hdlgettypesfromsizes(addr_bits,0,0);
        end
    end

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



