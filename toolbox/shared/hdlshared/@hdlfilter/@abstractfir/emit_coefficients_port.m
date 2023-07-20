function[hdl_arch,coeffs_data]=emit_coefficients_port(this,entitysigs,coeffs_data)





    hdl_arch.functions='';
    hdl_arch.typedefs='';
    hdl_arch.constants='';
    hdl_arch.signals='';
    hdl_arch.body_blocks='';
    hdl_arch.body_output_assignments='';

    coeffs_data.idx=entitysigs.coeffs;





    emitMode=isempty(pirNetworkForFilterComp);

    if emitMode


        if hdlgetparameter('isvhdl')&&hdlgetparameter('filter_input_type_std_logic')
            signed_coeffs_table=zeros(size(entitysigs.coeffs));
            for n=1:length(entitysigs.coeffs)
                coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),'_signed',num2str(n-1)]);
                complexity=hdlsignaliscomplex(entitysigs.coeffs(n));
                coeffssltype=hdlsignalsltype(entitysigs.coeffs(n));
                coeffall=hdlgetallfromsltype(coeffssltype);
                coeffsvtype=coeffall.vtype;

                [~,ptr]=hdlnewsignal(coeffname,'filter',-1,complexity,0,coeffsvtype,coeffssltype);
                hdl_arch.signals=[hdl_arch.signals,makehdlsignaldecl(ptr)];
                tempbody=hdldatatypeassignment(entitysigs.coeffs(n),ptr,this.Roundmode,this.Overflowmode);
                hdl_arch.body_blocks=[hdl_arch.body_blocks,tempbody];

                signed_coeffs_table(n)=ptr;
            end
            coeffs_data.idx=signed_coeffs_table;
        end
    end
