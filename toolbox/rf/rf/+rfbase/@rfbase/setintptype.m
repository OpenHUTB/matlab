function out=setintptype(h,out,prop_name,empty_allowed,updateflag)




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
        error(message('rf:rfbase:rfbase:setintptype:EmptyNotAllowed',...
        rferrhole1,rferrhole2));
    end

    if~isa(out,'char')
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:setintptype:NotAString',...
        rferrhole1,rferrhole2));
    end
    if~strcmpi(out,'linear')&&~strcmpi(out,'cubic')&&...
        ~strcmpi(out,'spline')
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:setintptype:WrongType',...
        rferrhole1,rferrhole2));
    end
    if(nargin==4)||(nargin==5&&updateflag)
        oldvalue=get(h,prop_name);
        if~strcmpi(oldvalue,out)
            h.PropertyChanged=true;
        end
    end