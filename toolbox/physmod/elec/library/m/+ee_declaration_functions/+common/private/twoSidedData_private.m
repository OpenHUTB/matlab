function[x_t,y_t]=twoSidedData_private(x,y)




    if abs(x(1))<=eps
        [~,idx]=sort(-x);
        x_t=[-x(idx),x(2:end)];
        y_t=[y(idx),y(2:end)];
    elseif x(1)>0
        [~,idx]=sort(-x);
        x_t=[-x(idx),x];
        y_t=[y(idx),y];
    else
        y_t=y;
        x_t=x;
    end

end