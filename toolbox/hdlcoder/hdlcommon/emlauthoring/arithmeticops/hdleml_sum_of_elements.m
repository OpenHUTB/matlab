%#codegen
function y=hdleml_sum_of_elements(u,outtp_ex,sumtp_ex)






    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex,sumtp_ex);

    if nargin<2
        outtp_ex=u(1);
    end

    inLen=numel(u);

    if isfloat(outtp_ex)
        sum_temp=u(1)+u(2);
        for ii=coder.unroll(3:inLen)
            sum_temp=sum_temp+u(ii);
        end
        y=sum_temp;
    else

        sum_temp=hdleml_add_withcast(u(1),u(2),sumtp_ex,sumtp_ex,1);
        for ii=coder.unroll(3:inLen)
            ut=fi(u(ii),fimath(sumtp_ex));
            sum_temp=hdleml_add_withcast(sum_temp,ut,sumtp_ex,sumtp_ex,1);
        end
        y=fi(sum_temp,numerictype(outtp_ex),fimath(outtp_ex));
    end
