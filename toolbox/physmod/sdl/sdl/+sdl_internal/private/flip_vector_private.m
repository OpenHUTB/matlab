function[x_flipped,y_flipped,x_flipped_zero,y_flipped_zero,flip_flag]=flip_vector_private(x,y)%#codegen



    coder.allowpcode('plain');
    x_column=x(:);
    y_column=y(:);

    x_flipped=[-x_column(end:-1:1);x_column];
    y_flipped=[y_column(end:-1:1);y_column];
    x_flipped_zero=[-x_column(end:-1:2);x_column];
    y_flipped_zero=[y_column(end:-1:2);y_column];

    if x(1)>0
        flip_flag=1;
    elseif x(1)==0
        flip_flag=2;
    else
        flip_flag=0;
    end

end