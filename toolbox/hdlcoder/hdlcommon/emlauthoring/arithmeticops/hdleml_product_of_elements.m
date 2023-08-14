%#codegen
function y=hdleml_product_of_elements(u,outtp_ex,useFullPrecision)







    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex,useFullPrecision);

    if nargin<3
        useFullPrecision=0;
    end

    if nargin<2
        outtp_ex=u(1);
    end

    inLen=numel(u);
    if inLen==1

        y=u;
    else
        mul_temp=hdleml_product(u(1),u(2),outtp_ex,useFullPrecision);
        for ii=coder.unroll(3:inLen)
            if isfloat(u(ii))
                ut=u(ii);
            else
                ut=fi(u(ii),fimath(outtp_ex));
            end
            mul_temp=hdleml_product(mul_temp,ut,outtp_ex,useFullPrecision);
        end
        y=mul_temp;
    end
