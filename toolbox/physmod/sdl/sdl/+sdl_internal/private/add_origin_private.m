function[x_padded,y_padded,through_origin,has_origin]=add_origin_private(x,y)%#codegen





    coder.allowpcode('plain');

    has_origin=any(x==0);

    if has_origin==0
        through_origin=1;
        if x(end)<0
            x_padded=[x(:);0];
            y_padded=[y(:);0];
        elseif x(1)>0
            x_padded=[0;x(:)];
            y_padded=[0;y(:)];
        else
            x_padded=[x(:);0].*([x(:);0]<0)+[0;x(:)].*([0;x(:)]>0);
            y_padded=[y(:);0].*([x(:);0]<0)+[0;y(:)].*([0;x(:)]>0);
        end
    else
        x_padded=[0;x(:)];
        y_padded=[0;y(:)];
        [~,origin_value]=max(x==0);
        if y(origin_value)~=0
            through_origin=0;
        else
            through_origin=1;
        end
    end

end