function createtbportlist(this)









    entity_name=hdlentitytop;
    if isempty(entity_name)
        if isempty(hdlgetparameter('filter_name'))
            error(message('HDLShared:hdlfilter:nofilter'));
        else
            entity_name=hdlgetparameter('filter_name');
        end
    end

    hdlentitysignalsinit;




    clkname=hdlgetparameter('clockname');
    if isempty(clkname)
        clkname='clk';
    end

    clkenname=hdlgetparameter('clockenablename');
    if isempty(clkenname)
        clkenname='clk_enable';
    end

    resetname=hdlgetparameter('resetname');
    if isempty(resetname)
        resetname='reset';
    end

    innamename=hdlgetparameter('filter_input_name');
    if isempty(innamename)
        innamename='filter_in';
    end

    outnamename=hdlgetparameter('filter_output_name');
    if isempty(outnamename)
        outnamename='filter_out';
    end

    bdt=hdlgetparameter('base_data_type');

    hdlnewsignal(clkname,'filter',-1,0,0,bdt,'boolean');
    hdlnewsignal(clkenname,'filter',-1,0,0,bdt,'boolean');
    hdlnewsignal(resetname,'filter',-1,0,0,bdt,'boolean');

    inputall=hdlgetallfromsltype(this.inputSLtype,'inputport');
    inputvtype=inputall.portvtype;
    inputsltype=inputall.portsltype;






    hdlnewsignal(innamename,'filter',-1,this.isInputPortComplex,0,inputvtype,inputsltype);
    coeffs_internal=strcmpi(hdlgetparameter('filter_coefficient_source'),'internal');
    arithisdouble=strcmpi(this.inputsltype,'double');
    if~coeffs_internal
        fl=this.getfilterlengths;
        firlen=fl.firlen;
        coeff_len=fl.coeff_len;
        addr_bits=ceil(log2(coeff_len));
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
            coeffall=hdlgetallfromsltype(this.CoeffSLtype);
            coeffsvsize=coeffall.size;
            coeffsvbp=coeffall.bp;
            coeffssigned=coeffall.signed;
            coeffsvtype=coeffall.vtype;
            coeffssltype=coeffall.sltype;
            if hdlgetparameter('filter_input_type_std_logic')==1
                [coeffsportvtype,coeffsportsltype]=hdlgetporttypesfromsizes(coeffsvsize,coeffsvbp,coeffssigned);
                [wraddrportvtype,wraddrportsltype]=hdlgetporttypesfromsizes(addr_bits,0,0);
            else
                coeffsportvtype=coeffsvtype;
                coeffsportsltype=coeffssltype;
                [wraddrportvtype,wraddrportsltype]=hdlgettypesfromsizes(addr_bits,0,0);
            end
        end


        hdlnewsignal('write_enable',...
        'filter',-1,0,0,bdt,'boolean');

        hdlnewsignal('write_done',...
        'filter',-1,0,0,bdt,'boolean');

        hdlnewsignal('write_address',...
        'filter',-1,0,0,wraddrportvtype,wraddrportsltype);

        hdlnewsignal('coeffs_in',...
        'filter',-1,0,0,...
        coeffsportvtype,coeffsportsltype);
    end

    hdllastinputsignal;

    outputall=hdlgetallfromsltype(this.outputSLtype,'outputport');
    outputvtype=outputall.portvtype;
    outputsltype=outputall.portsltype;






    hdlnewsignal(outnamename,'filter',-1,this.isOutputPortComplex,0,outputvtype,outputsltype);
    if hdlgetparameter('filter_generate_datavalid_output')
        ceoutvldname=hdlgetparameter('clockenableoutputvalidname');
        if isempty(ceoutvldname)
            ceoutvldname='ce_out_valid';
        end
        hdlnewsignal(ceoutvldname,'filter',-1,0,0,bdt,'boolean');

    end
    hdllastoutputsignal;

