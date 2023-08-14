function schema







    mlock;

    pk=findpackage('hdlcoderprops');
    c=schema.class(pk,'AbstractProp');
    set(c,'Description','abstract');

    if isempty(findtype('HDLTargetLanguageType'))
        schema.EnumType('HDLTargetLanguageType',{'VHDL','Verilog','SystemVerilog'});
    end

    if isempty(findtype('HDLFinalAddersType'))
        schema.EnumType('HDLFinalAddersType',{'linear','tree','pipelined'});
    end

    if isempty(findtype('HDLMultipliersType'))
        schema.EnumType('HDLMultipliersType',{'Multiplier','CSD','Factored-CSD'});
    end


