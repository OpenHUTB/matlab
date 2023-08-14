function language=getDUTLanguage(this)





    language=hdlgetparameter('lasttopleveltargetlang');
    if isempty(language)
        language=hdlgetparameter('target_language');
    end


