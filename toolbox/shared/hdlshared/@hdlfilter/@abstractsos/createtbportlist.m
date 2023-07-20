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
    if~coeffs_internal






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

    hdllastoutputsignal;

