function[hf,filtstruct]=whichhdlfilter(~,block)






    switch block.TypePopup
    case 'FIR (all zeros)'
        filtstruct=block.FIRFiltStruct;
        switch block.FIRFiltStruct
        case 'Direct form'
            hf=hdlfilter.dffir;
        case 'Direct form symmetric'
            hf=hdlfilter.dfsymfir;
        case 'Direct form antisymmetric'
            hf=hdlfilter.dfasymfir;
        case 'Direct form transposed'
            hf=hdlfilter.dffirt;
        otherwise
            error(message('hdlcoder:validate:UnsupportedFilterStructure',block.Name));
        end
    case 'IIR (poles & zeros)'
        filtstruct=block.IIRFiltStruct;
        switch block.IIRFiltStruct
        case 'Biquad direct form I (SOS)'
            hf=hdlfilter.df1sos;
        case 'Biquad direct form I transposed (SOS)'
            hf=hdlfilter.df1tsos;
        case 'Biquad direct form II (SOS)'
            hf=hdlfilter.df2sos;
        case 'Biquad direct form II transposed (SOS)'
            hf=hdlfilter.df2tsos;
        otherwise
            error(message('hdlcoder:validate:UnsupportedFilterStructure',block.Name));
        end
    otherwise
        error(message('hdlcoder:validate:UnsupportedFilterStructure',block.Name));
    end
    hf.FilterStructure=[block.TypePopup,' - ',filtstruct];
