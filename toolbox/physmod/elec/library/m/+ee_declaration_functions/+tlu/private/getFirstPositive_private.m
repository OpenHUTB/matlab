function[xp,idx]=getFirstPositive_private(x_vec)












    idx=find(x_vec>0,1,'first');

    xp=x_vec(idx);

end

