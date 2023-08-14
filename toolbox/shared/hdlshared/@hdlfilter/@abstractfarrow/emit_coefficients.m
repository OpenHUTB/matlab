function[coeffs_arch,coeffs_data]=emit_coefficients(this)






    coeffs_arch.functions='';
    coeffs_arch.typedefs='';
    coeffs_arch.constants='';
    coeffs_arch.signals='';
    coeffs_arch.body_blocks='';
    coeffs_arch.body_output_assignments='';

    coeffall=hdlgetallfromsltype(this.CoeffSLtype);
    coeffsvsize=coeffall.size;
    coeffsvbp=coeffall.bp;
    coeffssigned=coeffall.signed;
    coeffsvtype=coeffall.vtype;
    coeffssltype=coeffall.sltype;

    coeffs=this.Coefficients;

    coeffs_table=zeros(size(coeffs));
    for n=1:size(coeffs,2)
        for m=1:size(coeffs,1)
            coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),...
            'phase',num2str(n),'_',num2str(m)]);
            [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,0,0,coeffsvtype,coeffssltype);%#ok
            coeffs_table(m,n)=ptr;
            coeffs_arch.constants=[coeffs_arch.constants,...
            makehdlconstantdecl(ptr,hdlconstantvalue(coeffs(m,n),...
            coeffsvsize,coeffsvbp,coeffssigned))];
        end
    end

    coeffs_data.idx=coeffs_table;
    coeffs_data.values=0;


