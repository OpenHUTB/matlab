function customCode=getCustomCodeFromSettings(customCodeSettings)



    if isempty(customCodeSettings.customSourceCode)
        customCode=customCodeSettings.customCode;
    else
        customCode=[customCodeSettings.customCode,newline,...
        customCodeSettings.customSourceCode];
    end
end
