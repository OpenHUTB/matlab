function isDefault=isDefaultSetting(settingValue)

    validateattributes(settingValue,{'char','string'},{'nonempty','scalartext'});
    isDefault=strcmp(settingValue,'__DEFAULT__');
end