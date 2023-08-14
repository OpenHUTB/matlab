%#codegen
function y=hdleml_saturate_dynamic(upper_lim,u,lower_lim)











    coder.allowpcode('plain')


    if isfloat(u)
        upper_limit=upper_lim;
        lower_limit=lower_lim;
    else
        nt_u=numerictype(u);
        fm_u=fimath('RoundingMethod',u.RoundingMethod,'OverflowAction','Saturate');
        upper_limit=fi(upper_lim,nt_u,fm_u);
        lower_limit=fi(lower_lim,nt_u,fm_u);
    end

    upperLen=length(upper_limit);
    inputLen=length(u);
    lowerLen=length(lower_limit);

    outLen=max([upperLen,inputLen,lowerLen]);

    y=hdleml_define_len(u,outLen);

    if inputLen==1&&upperLen>1&&lowerLen==1
        for ii=1:outLen
            if u>upper_limit(ii)
                y(ii)=upper_limit(ii);
            elseif u<lower_limit
                y(ii)=lower_limit;
            else
                y(ii)=u;
            end
        end

    elseif inputLen==1&&upperLen>1&&lowerLen>1
        for ii=1:outLen
            if u>upper_limit(ii)
                y(ii)=upper_limit(ii);
            elseif u<lower_limit(ii)
                y(ii)=lower_limit(ii);
            else
                y(ii)=u;
            end
        end

    elseif inputLen==1&&upperLen==1&&lowerLen>1
        for ii=1:outLen
            if u>upper_limit
                y(ii)=upper_limit;
            elseif u<lower_limit(ii)
                y(ii)=lower_limit(ii);
            else
                y(ii)=u;
            end
        end

    elseif inputLen>1&&upperLen>1&&lowerLen==1
        for ii=1:outLen
            if u(ii)>upper_limit(ii)
                y(ii)=upper_limit(ii);
            elseif u(ii)<lower_limit
                y(ii)=lower_limit;
            else
                y(ii)=u(ii);
            end
        end

    elseif inputLen>1&&upperLen==1&&lowerLen>1
        for ii=1:outLen
            if u(ii)>upper_limit
                y(ii)=upper_limit;
            elseif u(ii)<lower_limit(ii)
                y(ii)=lower_limit(ii);
            else
                y(ii)=u(ii);
            end
        end

    elseif inputLen>1&&upperLen==1&&lowerLen==1
        for ii=1:outLen
            if u(ii)>upper_limit
                y(ii)=upper_limit;
            elseif u(ii)<lower_limit
                y(ii)=lower_limit;
            else
                y(ii)=u(ii);
            end
        end

    else

        for ii=1:outLen
            if u(ii)>upper_limit(ii)
                y(ii)=upper_limit(ii);
            elseif u(ii)<lower_limit(ii)
                y(ii)=lower_limit(ii);
            else
                y(ii)=u(ii);
            end
        end

    end
