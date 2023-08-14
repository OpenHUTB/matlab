function flag=isequaln(this,other)





    flag=isequal(class(this),class(other));

    if flag
        flag=flag&&all(size(this)==size(other));
    end

    if flag
        for ii=1:numel(this)
            flag=flag&&isequal(this(ii),other(ii));
            if~flag
                break;
            end
        end
    end
end