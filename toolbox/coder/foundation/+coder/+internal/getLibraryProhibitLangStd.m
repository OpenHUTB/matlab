function prohibitLangStandardTfl=getLibraryProhibitLangStd(lTargetRegistry,libName)




    refreshCRL(lTargetRegistry);
    TflNamesList=libName;

    if~iscell(TflNamesList)
        TflNamesList={TflNamesList};
    else
        TflNamesList=unique(TflNamesList,'stable');
    end
    Tfl_QueryString=TflNamesList{1};
    currentLib=coder.internal.getTfl(lTargetRegistry,Tfl_QueryString);
    if isempty(currentLib)||currentLib.IsLangStdTfl
        prohibitLangStandardTfl=false;
    else
        prohibitLangStandardTfl=loc_prohibitLangStandardTfl(lTargetRegistry,currentLib);%#ok<ASGLU>
    end

end

function prohibitLangStandardTfl=loc_prohibitLangStandardTfl(lTargetRegistry,currentLib)
    prohibitLangStandardTfl=false;
    while(~isempty(currentLib))
        prohibitLangStandardTfl=(prohibitLangStandardTfl||currentLib.OverrideLangStdTfls);
        if prohibitLangStandardTfl
            break;
        end

        if~currentLib.IsLangStdTfl
            currentLib=coder.internal.getTfl(lTargetRegistry,currentLib.BaseTfl);
        else
            break;
        end
    end
end