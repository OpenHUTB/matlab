function[hf,filtStruct]=whichhdlfilter(~,block)






    if isa(block,'dsp.BiquadFilter')
        filtStruct=block.Structure;
    else
        switch block.FilterSource
        case 'Filter object'
            hd=clone(block.UserData.filter);
            filtStruct=hd.Structure;
        otherwise
            filtStruct=block.IIRFiltStruct;
        end
    end

    switch filtStruct
    case 'Direct form I'
        hf=hdlfilter.df1sos;
    case 'Direct form I transposed'
        hf=hdlfilter.df1tsos;
    case 'Direct form II'
        hf=hdlfilter.df2sos;
    case 'Direct form II transposed'
        hf=hdlfilter.df2tsos;
    otherwise
        error(message('hdlcoder:validate:UnsupportedFilterStructure',block.Name));
    end

    hf.FilterStructure=['IIR Filter - ',filtStruct];
