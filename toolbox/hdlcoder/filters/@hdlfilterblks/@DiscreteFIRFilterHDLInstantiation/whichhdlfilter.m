function[hf,filtstruct]=whichhdlfilter(~,block)





    if isa(block,'dsp.FIRFilter')
        filtstruct=block.Structure;
        name='FIR Filter - ';
    else
        filtstruct=block.FirFiltStruct;
        name=[block.Name,' - '];
    end

    switch filtstruct
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
    hf.FilterStructure=[name,filtstruct];
