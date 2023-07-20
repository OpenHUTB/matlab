function ret=isequaln(this,rhs)






    if~strcmp(class(this),class(rhs))
        ret=false;
        return
    end


    if~isequal(size(this),size(rhs))
        ret=false;
        return
    end


    len=numel(this);
    for idx=1:len

        dsLen=numElements(this(idx));
        if dsLen~=numElements(rhs(idx))
            ret=false;
            return
        end


        if~strcmp(this(idx).Name,rhs(idx).Name)
            ret=false;
            return
        end


        for idx2=1:dsLen
            el1=get(this(idx),idx2);
            el2=get(rhs(idx),idx2);
            if~isequaln(el1,el2)
                ret=false;
                return
            end
        end
    end

    ret=true;
end
