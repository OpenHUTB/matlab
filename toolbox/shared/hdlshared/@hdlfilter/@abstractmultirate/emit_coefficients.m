function[hdl_arch,coeffs_data]=emit_coefficients(this)








    hdl_arch.constants='';

    coeffall=hdlgetallfromsltype(this.CoeffSLtype);
    coeffsvsize=coeffall.size;
    coeffsvbp=coeffall.bp;
    coeffssigned=coeffall.signed;
    coeffsvtype=coeffall.vtype;
    coeffssltype=coeffall.sltype;

    polycoeffs=this.polyphasecoefficients;
    coeffs_table=zeros(size(polycoeffs));
    for n=1:size(polycoeffs,1)
        for m=1:size(polycoeffs,2)
            complexity=~isreal(polycoeffs(n,m));
            coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),...
            'phase',num2str(n),'_',num2str(m)]);
            [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,complexity,0,coeffsvtype,coeffssltype);
            coeffs_table(n,m)=ptr;
            if complexity
                value=hdlconstantvalue(real(polycoeffs(n,m)),coeffsvsize,coeffsvbp,coeffssigned);
                hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(ptr,value)];
                value=hdlconstantvalue(imag(polycoeffs(n,m)),coeffsvsize,coeffsvbp,coeffssigned);
                hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(hdlsignalimag(ptr),value)];
            else
                hdl_arch.constants=[hdl_arch.constants,...
                makehdlconstantdecl(ptr,hdlconstantvalue(polycoeffs(n,m),...
                coeffsvsize,coeffsvbp,coeffssigned))];
            end

        end
    end
    coeffs_data.idx=coeffs_table;
    hdl_arch.constants=[hdl_arch.constants,'\n'];


