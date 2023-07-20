function[hdl_arch,coeffs_data]=emit_polycoeffs(this)







    polycoeffs=this.PolyphaseCoefficients;

    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    coeffall=hdlgetallfromsltype(this.CoeffSLtype);
    coeffsvsize=coeffall.size;
    coeffsvbp=coeffall.bp;
    coeffssigned=coeffall.signed;
    coeffsvtype=coeffall.vtype;
    coeffssltype=coeffall.sltype;

    productall=hdlgetallfromsltype(this.productSLtype);
    productsize=productall.size;
    productbp=productall.bp;
    productsigned=productall.signed;
    productvtype=productall.vtype;
    productsltype=productall.sltype;

    [tempname,constant_zero]=hdlnewsignal('constant_zero','filter',-1,0,0,productvtype,productsltype);

    constant_zero_used=0;
    coeffs_table=zeros(size(polycoeffs));


    for n=1:size(polycoeffs,1)
        for m=1:size(polycoeffs,2)
            complexity=~isreal(polycoeffs(n,m));
            coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),...
            'phase',num2str(n),'_',num2str(m)]);
            [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,complexity,0,coeffsvtype,coeffssltype);
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
            if polycoeffs(n,m)==0&&~strcmpi(coeffsvtype,'real')&&(strcmpi(hdlgetparameter('filter_multipliers'),'factored-csd')||strcmpi(hdlgetparameter('filter_multipliers'),'csd'))

                coeffs_table(n,m)=constant_zero;
                constant_zero_used=1;
            else
                coeffs_table(n,m)=ptr;
            end
        end

    end

    if constant_zero_used==1
        hdl_arch.constants=[hdl_arch.constants,...
        makehdlconstantdecl(constant_zero,hdlconstantvalue(0,productsize,productbp,productsigned))];
        if hdlsignaliscomplex(constant_zero)
            hdl_arch.constants=[hdl_arch.constants,...
            makehdlconstantdecl(hdlsignalimag(constant_zero),hdlconstantvalue(0,productsize,productbp,productsigned))];
        end
    end
    coeffs_data.idx=coeffs_table;
    hdl_arch.constants=[hdl_arch.constants,'\n'];




