function lang=getLanguage(langCode)






    if nargin<1||strcmp(langCode,'auto')




        lang=char(java.util.Locale.getDefault.getLanguage.toLowerCase);


        if strcmp(lang,'zh')








            lang='zh_cn';
        end



        okCodes=get(findtype(rpt_xml.typeLanguage),'Strings');
        if~any(strcmp(okCodes,lang))||strcmp(lang,'auto')
            lang='en';
        end
    else
        lang=langCode;

    end



