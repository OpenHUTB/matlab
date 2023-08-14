function leftEqualsRight=compareData(left,right)





    leftEqualsRight=all(left==right);

    if~leftEqualsRight&&isnumeric(left)&&isnumeric(right)
        leftEqualsRight=isnan(left)&&isnan(right);
    end

end