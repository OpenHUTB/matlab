%#codegen
function y=hdleml_minus_sum_of_elements(u,outtp_ex,subtp_ex)







    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex,subtp_ex);

    if nargin<2
        outtp_ex=u(1);
    end

    inLen=numel(u);


    if isfloat(outtp_ex)
        sub_temp=-u(1)-u(2);
        for ii=coder.unroll(3:inLen)
            sub_temp=sub_temp-u(ii);
        end
        y=sub_temp;
    else


        sub_temp=hdleml_subsub(u(1),u(2),subtp_ex,subtp_ex,1);
        for ii=coder.unroll(3:inLen)
            ut=fi(u(ii),fimath(subtp_ex));
            sub_temp=hdleml_sub_withcast(sub_temp,ut,subtp_ex,subtp_ex,1);
        end
        y=fi(sub_temp,numerictype(outtp_ex),fimath(outtp_ex));
    end


