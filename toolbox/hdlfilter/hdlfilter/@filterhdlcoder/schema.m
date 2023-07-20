function schema




    mlock;

    schema.package('filterhdlcoder');


    if isempty(findtype('HDLTargetLanguage')),
        schema.EnumType('HDLTargetLanguage',...
        {'vhdl','verilog'});
    end
