function targetLangStdTfl=mapTargetLangStdTfl(langStdTfl)






    switch langStdTfl
    case 'C89/C90 (ANSI)'
        targetLangStdTfl='ANSI_C';
    case 'C99 (ISO)'
        targetLangStdTfl='ISO_C';
    case 'C++03 (ISO)'
        targetLangStdTfl='ISO_C++';
    otherwise
        assert(false,'Unexpected value for TargetLangStandard');
    end
