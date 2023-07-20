function obj=castLike(in,this)




    if(~isnumeric(this)&&~islogical(this))
        error(message('half:error:InvalidInputNotNumericOrLogical'));
    else
        obj=half(this);
        if~isreal(in)
            obj=complex(obj);
        end
    end
end
