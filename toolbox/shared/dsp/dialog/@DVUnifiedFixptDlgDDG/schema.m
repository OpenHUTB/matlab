function schema





    schema.package('DVUnifiedFixptDlgDDG');

    if isempty(findtype('SPCRoundingModeEnum'))
        schema.EnumType('SPCRoundingModeEnum',{'Ceiling','Convergent','Floor','Nearest','Round','Simplest','Zero'});
    end

    if isempty(findtype('SPCOverflowModeEnum'))
        schema.EnumType('SPCOverflowModeEnum',{'Wrap','Saturate'});
    end

    if isempty(findtype('SPCResetPortEnum'))
        schema.EnumType('SPCResetPortEnum',{
        'None',...
        'Rising edge',...
        'Falling edge',...
        'Either edge',...
        'Non-zero sample'});
    end








    if isempty(findtype('SPCSortAlgorithmEnum'))
        schema.EnumType('SPCSortAlgorithmEnum',{'Quick sort','Insertion sort'});
    end

