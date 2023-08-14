function schema







    mlock;

    schema.package('hdlcoderprops');


    if isempty(findtype('CodeGenerationOutputType')),
        schema.EnumType('CodeGenerationOutputType',...
        {'GenerateHDLCode',...
        'DisplayGeneratedModelOnly',...
        'GenerateHDLCodeAndDisplayGeneratedModel'});
    end

    if isempty(findtype('FilterResetTypeEnum'))
        schema.EnumType('FilterResetTypeEnum',...
        {'None',...
        'ShiftRegister'});
    end

    if isempty(findtype('HDLuint32'))
        schema.UserType('HDLuint32','int32',@check_positive_integer);
    end


    function check_positive_integer(value)

        if value<0
            error(message('HDLShared:CLI:negativeValue'));
        end
