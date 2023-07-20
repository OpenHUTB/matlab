function[entries,default]=getAvailableTargetLangStdEntries(targetLang)





    default='Auto';

    entries={'Auto';'C89/C90 (ANSI)';'C99 (ISO)'};

    if strcmpi(targetLang,'option.TargetLang.CPP')
        entries{end+1}='C++03 (ISO)';
        entries{end+1}='C++11 (ISO)';
    end

end
