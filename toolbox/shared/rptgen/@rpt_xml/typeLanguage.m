function enumType=typeLanguage




    enumType='docbook_language';

    e=findtype(enumType);
    if isempty(e)
        langCodes={
'ca'
'cs'
'da'
'de'
'el'
'en'
'es'
'et'
'fi'
'fr'
'hu'
'id'
'it'
'ja'
'ko'
'nl'
'no'
'pl'
'pt'
'pt_br'
'ro'
'ru'
'sk'
'sl'
'sv'
'zh_cn'
        };
        langNames={
        getString(message('rptgen:rpt_xml:languagename_ca'))
        getString(message('rptgen:rpt_xml:languagename_cs'))
        getString(message('rptgen:rpt_xml:languagename_da'))
        getString(message('rptgen:rpt_xml:languagename_de'))
        getString(message('rptgen:rpt_xml:languagename_el'))
        getString(message('rptgen:rpt_xml:languagename_en'))
        getString(message('rptgen:rpt_xml:languagename_es'))
        getString(message('rptgen:rpt_xml:languagename_et'))
        getString(message('rptgen:rpt_xml:languagename_fi'))
        getString(message('rptgen:rpt_xml:languagename_fr'))
        getString(message('rptgen:rpt_xml:languagename_hu'))
        getString(message('rptgen:rpt_xml:languagename_id'))
        getString(message('rptgen:rpt_xml:languagename_it'))
        getString(message('rptgen:rpt_xml:languagename_ja'))
        getString(message('rptgen:rpt_xml:languagename_ko'))
        getString(message('rptgen:rpt_xml:languagename_nl'))
        getString(message('rptgen:rpt_xml:languagename_no'))
        getString(message('rptgen:rpt_xml:languagename_pl'))
        getString(message('rptgen:rpt_xml:languagename_pt'))
        getString(message('rptgen:rpt_xml:languagename_pt_br'))
        getString(message('rptgen:rpt_xml:languagename_ro'))
        getString(message('rptgen:rpt_xml:languagename_ru'))
        getString(message('rptgen:rpt_xml:languagename_sk'))
        getString(message('rptgen:rpt_xml:languagename_sl'))
        getString(message('rptgen:rpt_xml:languagename_sv'))
        getString(message('rptgen:rpt_xml:languagename_zh_cn'))
        };

        [langNames,sortIdx]=sort(langNames);
        langCodes=langCodes(sortIdx);

        langNames{end+1}=getString(message('rptgen:rpt_xml:languagename_auto'));
        langCodes{end+1}='auto';

        e=rptgen.enum(enumType,langCodes,langNames);
    end








