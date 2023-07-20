function[max_positive,max_negative]=highest_signed_values_private(x)%#codegen




    coder.allowpcode('plain');

    x_column=x(:);

    [~,max_positive_to_end]=max([x_column(end:-1:1);1]>0);
    [~,max_negative_to_end]=max([x_column(end:-1:1);-1]<0);

    num_elements=length(x)+1;

    max_positive=num_elements-max_positive_to_end;
    max_negative=num_elements-max_negative_to_end;

end
