function language=getDUTLanguage(this)






    language=this.TargetLanguage;

    if isempty(language)
        language=hdlgetparameter('target_language');
    end