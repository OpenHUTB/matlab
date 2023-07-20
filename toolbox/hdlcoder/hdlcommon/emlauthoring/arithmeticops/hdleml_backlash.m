%#codegen
function y=hdleml_backlash(u,width_,initial_)












    coder.allowpcode('plain')
    eml_prefer_const(width_,initial_);


    if isfloat(u)
        width=width_;
        initial=initial_;
    else
        nt_u=numerictype(u);
        fm_u=fimath(u);
        width=fi(width_,nt_u,fm_u);
        initial=fi(initial_,nt_u,fm_u);
    end

    widthLen=length(width);
    inputLen=length(u);
    initialLen=length(initial);

    outLen=max([widthLen,inputLen,initialLen]);

    y=hdleml_init_len(u,outLen);

    persistent prev time_zero
    if isempty(prev)
        prev=hdleml_init_len(u,outLen);
        time_zero=true;
    end



    for ii=1:outLen
        if time_zero==false
            initial(ii)=prev(ii);
        end
        if u(ii)>(initial(ii)+width(ii))
            y(ii)=u(ii)-(width(ii));
        elseif u(ii)<(initial(ii)-width(ii))
            y(ii)=u(ii)+(width(ii));
        else
            y(ii)=initial(ii);
        end
    end

    prev=y;
    time_zero=false;

end
