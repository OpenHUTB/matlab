function formatSetting=getDatetimeSettings(displayFormat)













    persistent datetimeSettings;
    if isempty(datetimeSettings)
        s=settings;
        datetimeSettings=s.matlab.datetime;
    end

    if nargin<1
        formatSetting=datetimeSettings;
    else
        switch lower(displayFormat)
        case 'defaultformat'
            formatSetting=convertStringsToChars(datetimeSettings.DefaultFormat.ActiveValue);
        case 'defaultdateformat'
            formatSetting=convertStringsToChars(datetimeSettings.DefaultDateFormat.ActiveValue);
        case 'locale'
            formatSetting=convertStringsToChars(datetimeSettings.DisplayLocale.ActiveValue);
        end
    end