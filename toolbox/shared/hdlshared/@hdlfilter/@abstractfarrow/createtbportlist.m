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

    hdlnewsignal(innamename,'filter',-1,0,0,inputvtype,inputsltype);
    fdall=hdlgetallfromsltype(this.FDSLtype,'inputport');
    fdvtype=fdall.portvtype;
    fdsltype=fdall.portsltype;

    hdlnewsignal(hdlgetparameter('filter_fracdelay_name'),...
    'filter',-1,0,0,fdvtype,fdsltype);
    hdllastinputsignal;
    outputall=hdlgetallfromsltype(this.outputSLType,'outputport');
    outputvtype=outputall.portvtype;
    outputsltype=outputall.portsltype;

    hdlnewsignal(outnamename,'filter',-1,0,0,outputvtype,outputsltype);

    hdllastoutputsignal;

