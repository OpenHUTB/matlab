function schema



    schema.package('slhdlcoder');


    if isempty(findtype('HDLTargetLanguage')),
        schema.EnumType('HDLTargetLanguage',...
        {'VHDL','Verilog','SystemVerilog'});
    end
