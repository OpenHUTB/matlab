function fiSettingsStruct=getFiSettings(~)

























    fiSettingsStruct=struct('fimath',{{'BlockDefaultFimath','InputFimath'}},...
    'TreatAsFi',{{'Fixed-point','Fixed-point & Integer'}},...
    'SaturateOnIntegerOverflow',{{'on','off'}});

end
