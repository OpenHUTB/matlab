%#codegen
function y=hdleml_hitcross(u,offset_,direction)








    coder.allowpcode('plain')
    eml_prefer_const(direction);


    if isfloat(u)
        offset=offset_;
    else
        nt_u=numerictype(u);
        fm_u=fimath(u);
        offset=fi(offset_,nt_u,fm_u);
    end

    inputLen=length(u);
    offsetLen=length(offset);

    if inputLen>1
        y=hdleml_define_len(false,inputLen);
        for ii=1:inputLen


            y(ii)=0;
        end
        return;
    end




    persistent prev prev_y
    if isempty(prev)
        prev=u;
        prev_y=hdleml_define_len(false,inputLen);
    end

    if offsetLen>1
        y=hdleml_define_len(true,offsetLen);
        for ii=1:offsetLen
            if direction==0
                y(ii)=((prev_y(ii)==true)&(u==offset(ii)))|((u>=prev)&((prev<offset(ii))&(u>=offset(ii))));
            elseif direction==1
                y(ii)=((prev_y(ii)==true)&(u==offset(ii)))|((u<=prev)&((prev>offset(ii))&(u<=offset(ii))));
            else
                y(ii)=0;
            end
            prev_y(ii)=y(ii);
        end
    else
        if direction==0
            y=((prev_y==true)&(u==offset))|((u>=prev)&((prev<offset)&(u>=offset)));
        elseif direction==1
            y=((prev_y==true)&(u==offset))|((u<=prev)&((prev>offset)&(u<=offset)));
        else
            y=0;
        end
        prev_y=y;
    end

    prev=u;

end
