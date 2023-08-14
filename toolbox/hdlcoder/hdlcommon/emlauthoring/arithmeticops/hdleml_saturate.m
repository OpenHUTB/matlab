%#codegen
function y=hdleml_saturate(u,upper_limit,lower_limit)










    coder.allowpcode('plain')
    eml_prefer_const(upper_limit,lower_limit);

    upperLen=length(upper_limit);
    inputLen=length(u);
    lowerLen=length(lower_limit);


    if upperLen==1&&lowerLen==1&&upper_limit==lower_limit
        if inputLen==1
            y=upper_limit;
        else
            y=hdleml_define_len(u,inputLen);
            for ii=1:inputLen
                y(ii)=upper_limit;
            end
        end
    else
        y=hdleml_saturate_dynamic(upper_limit,u,lower_limit);
    end
