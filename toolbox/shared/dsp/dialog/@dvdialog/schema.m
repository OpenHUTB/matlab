function schema





    schema.package('dvdialog');






    if isempty(findtype('DSPRoundingModeEnum'))
        schema.EnumType('DSPRoundingModeEnum',...
        {'Ceiling',...
        'Convergent',...
        'Floor',...
        'Nearest',...
        'Round',...
        'Simplest',...
        'Zero'});
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
        schema.EnumType('DSPFramingEnum',{'Maintain input frame size',...
        'Maintain input frame rate'});
    end


    if isempty(findtype('DSPInputProcessingEnum'))
        schema.EnumType('DSPInputProcessingEnum',...
        {'Columns as channels (frame based)',...
        'Elements as channels (sample based)',...
        'Inherited (this choice will be removed - see release notes)'});
    end

    if isempty(findtype('DSPUpgradedInputProcessingEnum'))
        schema.EnumType('DSPUpgradedInputProcessingEnum',...
        {'Columns as channels (frame based)',...
        'Elements as channels (sample based)'});
    end


    if isempty(findtype('DSPIPEnum'))
        schema.EnumType('DSPIPEnum',...
        {'Columns as channels (frame based)',...
        'Elements as channels (sample based)'});
    end


    if isempty(findtype('DSPMultirateEnum'))
        schema.EnumType('DSPMultirateEnum',...
        {'Enforce single-rate processing',...
        'Allow multirate processing'});
    end


    if isempty(findtype('DSPMultirateInhEnum'))
        schema.EnumType('DSPMultirateInhEnum',...
        {'Enforce single-rate processing',...
        'Allow multirate processing',...
        'Inherit from input (this choice will be removed - see release notes)'});
    end


