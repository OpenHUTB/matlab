%#codegen
function[y,satout]=hdleml_saturate_in_dti(u,upper_limit,lower_limit)













    coder.allowpcode('plain')
    eml_prefer_const(upper_limit,lower_limit);

    upperLen=length(upper_limit);
    inputLen=length(u);
    lowerLen=length(lower_limit);

    outLen=max([upperLen,inputLen,lowerLen]);

    y=hdleml_define_len(u,outLen);
    if isfloat(u)
        satout=hdleml_define_len(u,outLen);
    else
        satout=coder.nullcopy(fi(zeros(outLen,1),1,8,0,fimath(u)));
    end

    if inputLen==1&&upperLen>1&&lowerLen==1
        for ii=1:outLen
            if u>=upper_limit(ii)
                y(ii)=upper_limit(ii);
                satout(ii)=1;
            elseif u<=lower_limit
                y(ii)=lower_limit;
                satout(ii)=-1;
            else
                y(ii)=u;
                satout(ii)=0;
            end
        end

    elseif inputLen==1&&upperLen>1&&lowerLen>1
        for ii=1:outLen
            if u>=upper_limit(ii)
                y(ii)=upper_limit(ii);
                satout(ii)=1;
            elseif u<=lower_limit(ii)
                y(ii)=lower_limit(ii);
                satout(ii)=-1;
            else
                y(ii)=u;
                satout(ii)=0;
            end
        end

    elseif inputLen==1&&upperLen==1&&lowerLen>1
        for ii=1:outLen
            if u>=upper_limit
                y(ii)=upper_limit;
                satout(ii)=1;
            elseif u<=lower_limit(ii)
                y(ii)=lower_limit(ii);
                satout(ii)=-1;
            else
                y(ii)=u;
                satout(ii)=0;
            end
        end

    elseif inputLen>1&&upperLen>1&&lowerLen==1
        for ii=1:outLen
            if u(ii)>=upper_limit(ii)
                y(ii)=upper_limit(ii);
                satout(ii)=1;
            elseif u(ii)<=lower_limit
                y(ii)=lower_limit;
                satout(ii)=-1;
            else
                y(ii)=u(ii);
                satout(ii)=0;
            end
        end

    elseif inputLen>1&&upperLen==1&&lowerLen>1
        for ii=1:outLen
            if u(ii)>=upper_limit
                y(ii)=upper_limit;
                satout(ii)=1;
            elseif u(ii)<=lower_limit(ii)
                y(ii)=lower_limit(ii);
                satout(ii)=-1;
            else
                y(ii)=u(ii);
                satout(ii)=0;
            end
        end

    elseif inputLen>1&&upperLen==1&&lowerLen==1
        for ii=1:outLen
            if u(ii)>=upper_limit
                y(ii)=upper_limit;
                satout(ii)=1;
            elseif u(ii)<=lower_limit
                y(ii)=lower_limit;
                satout(ii)=-1;
            else
                y(ii)=u(ii);
                satout(ii)=0;
            end
        end

    else

        for ii=1:outLen
            if u(ii)>=upper_limit(ii)
                y(ii)=upper_limit(ii);
                satout(ii)=1;
            elseif u(ii)<=lower_limit(ii)
                y(ii)=lower_limit(ii);
                satout(ii)=-1;
            else
                y(ii)=u(ii);
                satout(ii)=0;
            end
        end

    end
