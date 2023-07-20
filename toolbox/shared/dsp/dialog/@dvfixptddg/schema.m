function schema





    schema.package('dvfixptddg');

    if isempty(findtype('DSPRoundingModeEnum'))
        schema.EnumType('DSPRoundingModeEnum',{'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'});
    end

    if isempty(findtype('DSPOverflowModeEnum'))
        schema.EnumType('DSPOverflowModeEnum',{'Wrap','Saturate'});
    end

    if isempty(findtype('DSPComplexityEnum'))
        schema.EnumType('DSPComplexityEnum',{'Real','Complex'});
    end


    if isempty(findtype('DSPFFTCompMethodEnum'))
        schema.EnumType('DSPFFTCompMethodEnum',...
        {'Trigonometric fcn','Table lookup'});
    end

    if isempty(findtype('DSPFFTTableOptEnum'))
        schema.EnumType('DSPFFTTableOptEnum',{'Speed','Memory'});
    end


    if isempty(findtype('DSPFramingEnum'))
        schema.EnumType('DSPFramingEnum',{...
        'Maintain input frame size',...
        'Maintain input frame rate'});
    end



    if isempty(findtype('DSPResetPortEnum'))
        schema.EnumType('DSPResetPortEnum',{
        'None',...
        'Rising edge',...
        'Falling edge',...
        'Either edge',...
        'Non-zero sample'});
    end


    if isempty(findtype('DSPSortAlgorithmEnum'))
        schema.EnumType('DSPSortAlgorithmEnum',{'Quick sort','Insertion sort'});
    end

    if isempty(findtype('DSPSampleModeEnum'))
        schema.EnumType('DSPSampleModeEnum',{'Discrete','Continuous'});
    end

    if isempty(findtype('DSPSourceFracBitsModeEnum'))
        schema.EnumType('DSPSourceFracBitsModeEnum',{...
        'Best precision',...
        'User-defined'});
    end


