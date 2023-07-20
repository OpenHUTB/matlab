function[language,locale]=locale(userLanguage,clearpLangauge)

























    minArgs=0;
    maxArgs=2;
    narginchk(minArgs,maxArgs)
    persistent pLanguage;

    if(nargin==2)&&(clearpLangauge==true)

        clear pLanguage;
        return
    end

    if isempty(pLanguage)&&nargin==0
        locale=feature('locale');
        locale=locale.messages(1:5);


        if contains(locale,'en_')
            pLanguage=locale(1:2);
        else
            pLanguage=lower(locale(4:5));
        end
    end

    if nargin==0
        [language,locale]=lReturnValidLang(pLanguage);
        return
    end

    [newLanguage,newLocale]=lReturnValidLang(userLanguage);
    if isempty(pLanguage)
        language=newLanguage;
        locale=newLocale;
    else
        [language,locale]=lReturnValidLang(pLanguage);
    end
    pLanguage=newLanguage;

end

function[validLang,locale]=lReturnValidLang(lang)
    langLocaleMap=containers.Map({'en','jp','kr','cn'},{'en-us','ja-jp','ko-kr','zh-cn'});
    lang=lower(lang);
    if~isKey(langLocaleMap,lang)

        validLang='en';
    else
        validLang=lang;
    end
    locale=langLocaleMap(validLang);
end