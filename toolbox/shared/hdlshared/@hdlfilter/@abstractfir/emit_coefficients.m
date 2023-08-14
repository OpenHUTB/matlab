function[hdl_arch,coeffs_data]=emit_coefficients(this)











    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

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

    coeffs=this.Coefficients;

    arch=this.implementation;
    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');

    fl=getfilterlengths(this);
    coeff_len=fl.coeff_len;

    if coeffs_internal
        coeffs_table=[];
        if strcmpi(arch,'serial')||strcmpi(arch,'serialcascade')||strcmpi(arch,'distributedarithmetic')
            coeffs_values=coeffs(coeffs~=0);
            for n=1:coeff_len
                if emitMode
                    coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),num2str(n)]);
                    [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,0,0,coeffsvtype,coeffssltype);%#ok<ASGLU>
                else
                    hT=pir_sfixpt_t(coeffsvsize,coeffsvbp);
                    ptr=hN.addSignal(hT,[hdlgetparameter('filter_coeff_name'),num2str(n)]);
                    ptr.SimulinkRate=hN.PirInputSignals.SimulinkRate;
                end
                if coeffs(n)~=0
                    coeffs_table=[coeffs_table,ptr];
                end
                if emitMode
                    value=hdlconstantvalue(coeffs(n),coeffsvsize,coeffsvbp,coeffssigned);
                    hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(ptr,value,coeffs(n))];
                else
                    pirelab.getConstComp(hN,ptr,coeffs(n));
                end
            end
            coeff_len=length(coeffs_table);
            coeffs_data.values=coeffs_values;
        else
            coeffs_table=[];
            for n=1:coeff_len
                complexity=~isreal(coeffs(n));
                coeffname=hdllegalnamersvd([hdlgetparameter('filter_coeff_name'),num2str(n)]);

                if emitMode
                    [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,complexity,0,coeffsvtype,coeffssltype);%#ok<ASGLU>
                    coeffs_table=[coeffs_table,ptr];
                    if complexity
                        value=hdlconstantvalue(real(coeffs(n)),coeffsvsize,coeffsvbp,coeffssigned);
                        hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(ptr,value,real(coeffs(n)))];
                        value=hdlconstantvalue(imag(coeffs(n)),coeffsvsize,coeffsvbp,coeffssigned);
                        hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(hdlsignalimag(ptr),value,imag(coeffs(n)))];
                    else
                        value=hdlconstantvalue(coeffs(n),coeffsvsize,coeffsvbp,coeffssigned);
                        hdl_arch.constants=[hdl_arch.constants,makehdlconstantdecl(ptr,value,coeffs(n))];
                    end
                else
                    num_channel=hdlgetparameter('filter_generate_multichannel');

                    if num_channel==1
                        vector_size=hN.PirInputSignals(1).Type.getDimensions;
                        vector_dims=pirelab.getVectorTypeInfo(hN.PirInputSignals(1),1);
                    else
                        vector_size=1;
                        vector_dims=1;
                    end

                    [uname,ptr]=hdlnewsignal(coeffname,'filter',-1,complexity,vector_dims,coeffsvtype,coeffssltype,hN.PirInputSignals(1).SimulinkRate/num_channel);%#ok<ASGLU>

                    coeffs_table=[coeffs_table,ptr];
                    pirelab.getConstComp(hN,ptr,repmat(coeffs(n),vector_size,1));
                end
                coeffs_data.values=coeffs;
            end
        end
    end
    coeffs_data.idx=coeffs_table;

    hdl_arch.constants=[hdl_arch.constants,'\n'];

end
