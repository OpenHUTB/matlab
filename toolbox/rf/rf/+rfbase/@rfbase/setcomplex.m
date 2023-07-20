function out=setcomplex(h,out,prop_name,empty_allowed,...
    updateflag,zero_allowed)




    if nargin<6
        zero_allowed=true;
    end

    if(empty_allowed&&isempty(out))
        return
    end

    if isempty(out)
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:setcomplex:EmptyNotAllowed',...
        rferrhole1,rferrhole2));
    end

    if~isscalar(out)||~isnumeric(out)||isnan(out)
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:setcomplex:NotAComplex',...
        rferrhole1,rferrhole2));
    end

    if~zero_allowed&&out==0
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:setcomplex:ZeroNotAllowed',...
        rferrhole1,rferrhole2));
    end

    if(nargin==4)||(nargin>=5&&updateflag)
        h.PropertyChanged=true;
    end