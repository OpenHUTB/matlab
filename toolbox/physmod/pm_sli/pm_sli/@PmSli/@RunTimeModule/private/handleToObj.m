function obj=handleToObj(handle)





    ;

    if isa(handle,'double')||isa(handle,'char')
        obj=get_param(handle,'Object');
    else
        obj=handle;
    end




