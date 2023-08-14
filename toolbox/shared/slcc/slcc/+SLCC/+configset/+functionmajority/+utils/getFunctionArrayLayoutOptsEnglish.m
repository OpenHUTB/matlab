function[opts]=getFunctionArrayLayoutOptsEnglish()



    persistent loc_opts;

    if isempty(loc_opts)
        loc_opts={...
        loc_message_English_string('RTW:configSet:ArrayLayout_Column_Major'),...
        loc_message_English_string('RTW:configSet:ArrayLayout_Row_Major'),...
        loc_message_English_string('RTW:configSet:ArrayLayout_Any')...
        };
    end

    opts=loc_opts;
end

function str=loc_message_English_string(resID)
    persistent loc_locale;
    if isempty(loc_locale)
        loc_locale=matlab.internal.i18n.locale('en_US');
    end

    m=message(resID);
    str=m.getString(loc_locale);
end