function[str,st,en]=get_prototype_str(text)





    [s,~,t]=regexp([text,10],'^(?:\s*(%[^\n]*)?\n)*\s*(function)[ \f\t\v]*(\.\.\.[^\n]*\n|.)*?(?:\s*[%\n])','once');

    if isempty(s)
        str='';
        st=1;
        en=0;
        return;
    end

    pSt=t(2,1);
    pEn=t(2,2);
    st=t(1,1);
    if pSt>pEn

        en=t(1,2);
    else
        en=t(2,2);
    end

    str=text(pSt:pEn);

    if text(en)==10


        en=en-1;
    end

    return;
