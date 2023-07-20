function[]=spsDrivesMuxCbak(block)


    detailLevel=get_param(block,'detailLevel');
    driveType=get_param(block,'driveType');

    switch detailLevel
    case 'Detailed'
        maskVisibilities={'on','off'};
        variantSuffix='';
    case 'Average'
        maskVisibilities={'on','on'};
        variantSuffix=['_',driveType];
    end

    variantName=[detailLevel,variantSuffix];

    if~isequal(get_param(block,'LabelModeActiveChoice'),variantName)
        set_param(block,'LabelModeActiveChoice',variantName);
    end
    set_param(block,'MaskVisibilities',maskVisibilities);