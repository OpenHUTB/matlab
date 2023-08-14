function[xn,idx]=getLastNegative_private(x_vec)














    idx=find(x_vec<0,1,'last');

    xn=x_vec(idx);

end

