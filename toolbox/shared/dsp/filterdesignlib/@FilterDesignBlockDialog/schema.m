function schema





    schema.package('FilterDesignBlockDialog');



    if isempty(findtype('FDDlgInputProcessing'))
        schema.EnumType('FDDlgInputProcessing',{'columnsaschannels',...
        'elementsaschannels',...
        'inherited'});
    end


    if isempty(findtype('FDDlgInputProcessingNew'))
        schema.EnumType('FDDlgInputProcessingNew',{'columnsaschannels',...
        'elementsaschannels'});
    end

    if isempty(findtype('FDDlgRateOption'))
        schema.EnumType('FDDlgRateOption',{'enforcesinglerate',...
        'allowmultirate'});
    end


