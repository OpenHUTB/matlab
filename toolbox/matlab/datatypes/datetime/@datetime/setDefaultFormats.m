function setDefaultFormats(format,formatStr)






















    datetimeSettings=matlab.internal.datetime.getDatetimeSettings();
    if nargin==2
        [format,formatStr]=convertStringsToChars(format,formatStr);
    else
        format=convertStringsToChars(format);
    end

    switch lower(format)
    case 'default'
        verifyFormat(formatStr,'');
        datetimeSettings.DefaultFormat.PersonalValue=formatStr;
    case 'defaultdate'
        verifyFormat(formatStr,'');
        datetimeSettings.DefaultDateFormat.PersonalValue=formatStr;
    case 'reset'
        if(datetimeSettings.DefaultFormat.hasPersonalValue())
            datetimeSettings.DefaultFormat.clearPersonalValue();
        end
        if(datetimeSettings.DefaultDateFormat.hasPersonalValue())
            datetimeSettings.DefaultDateFormat.clearPersonalValue();
        end
    otherwise
        error(message('MATLAB:datetime:InvalidFormatIdentifier'));
    end
end