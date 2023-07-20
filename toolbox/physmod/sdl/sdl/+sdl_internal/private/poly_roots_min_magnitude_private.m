function[min_positive_root,min_negative_root]=poly_roots_min_magnitude_private(p,saturation)%#codegen





    coder.allowpcode('plain');






    num_rows=length(p(:,1));

    min_positive_root=zeros(num_rows,1);
    min_negative_root=zeros(num_rows,1);

    for i=1:length(p(:,1))

        p_row=p(i,:);


        poly_roots=roots(p_row);
        poly_roots_real=poly_roots(poly_roots==real(poly_roots));


        min_positive_root_i=min(poly_roots_real(poly_roots_real>0));
        min_negative_root_i=max(poly_roots_real(poly_roots_real<0));

        if~isempty(min_positive_root_i)
            min_positive_root(i)=min_positive_root_i;
        else
            min_positive_root(i)=abs(saturation);
        end
        if~isempty(min_negative_root_i)
            min_negative_root(i)=min_negative_root_i;
        else
            min_negative_root(i)=-abs(saturation);
        end

    end

end
