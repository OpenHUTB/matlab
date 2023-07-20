function[pcomment,tsym,csym]=parse_comment_string(comment)




































    tsym=[];
    csym=[];
    pcomment=[];
    f1=findstr(comment,'<');
    c1=findstr(comment,':');
    f2=findstr(comment,'>');


    if(isempty(f1)==0)&(isempty(f2)==0)&(isempty(c1)==0)
        if(f2(1)>f1(1))&(c1(1)>f1(1))&(c1(1)<f2(1))
            str=comment(f1(1):f2(1));
            pcomment=comment(f2(1)+1:end);
            sym=comment(f1(1)+1:c1(1)-1);
            switch(sym)
            case{'S','s'}
                tsym=comment(c1(1)+1:f2(1)-1);
            case{'C','c'}
                csym=comment(c1(1)+1:f2(1)-1);
            otherwise
                pcomment=comment;
            end
        else
            pcomment=comment;
        end
    else
        pcomment=comment;
    end