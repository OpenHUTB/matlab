function entitysigs=createCoeffPorts(this,entitysigs)








    emitMode=isempty(pirNetworkForFilterComp);
    if~emitMode

        hN=pirNetworkForFilterComp;
    end

    coeffall=hdlgetallfromsltype(this.CoeffSLtype);
    coeffssltype=coeffall.sltype;
    if hdlgetparameter('isvhdl')
        coeffsvtype=this.coeffvectorvtype;
    else
        coeffsvtype=coeffall.vtype;
    end

    coeffs=this.Coefficients;

    fl=getfilterlengths(this);
    coeff_len=fl.coeff_len;
    fir_len=fl.firlen;

    if emitMode
        if hdlgetparameter('isvhdl')&&(hdlgetparameter('ScalarizePorts')~=1)
            complexity=~isreal(coeffs);
            coeffname=hdllegalnamersvd(hdlgetparameter('filter_coeff_name'));
            [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,complexity,...
            [coeff_len,0],coeffsvtype,coeffssltype);
            hdladdinportsignal(ptr);
            ptr_vec=hdlexpandvectorsignal(ptr);
            entitysigs.coeffs=ptr_vec;
        else
            coeffs_table=[];
            for n=1:fir_len
                complexity=~isreal(coeffs(n));
                coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),num2str(n)]);
                [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,complexity,0,coeffsvtype,coeffssltype);
                hdladdinportsignal(ptr);
                coeffs_table=[coeffs_table,ptr];
            end
            entitysigs.coeffs=coeffs_table;
        end
    else
        coeffSig=hN.PirInputSignals(2);
        entitysigs.coeffs=coeffSig.split.PirOutputSignals;
    end

end
