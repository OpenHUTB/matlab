function checkrealscalardouble(h,prop_name,val)




    if~isa(val,'double')||~isscalar(val)||~isreal(val)
        if isempty(h.Block)
            rferrhole1=h.Name;
        else
            rferrhole1=upper(class(h));
        end
        rferrhole2=prop_name;
        error(message(['rf:rfbase:rfbase:checkrealscalardouble:'...
        ,'NotARealScalarDouble'],rferrhole1,rferrhole2));
    end