function handle=objectToHandle(obj)





    ;

    if~(isa(obj,'double')||isa(obj,'char'))
        handle=obj.Handle;
    else
        handle=obj;
    end




