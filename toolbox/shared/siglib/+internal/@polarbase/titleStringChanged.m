function titleStringChanged(p,select)


    is_top=strcmpi(select,'top');
    if is_top
        h=p.hTitleTop;
    else
        h=p.hTitleBottom;
    end




    str=h.String;




    plain_txt=downdateDataLabels(str);















    if is_top
        propName='TitleTop';
    else
        propName='TitleBottom';
    end
    p.pDelayedParamChanges={propName,plain_txt};
