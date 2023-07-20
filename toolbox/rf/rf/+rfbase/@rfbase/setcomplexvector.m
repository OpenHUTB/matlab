function out=setcomplexvector(h,out,prop_name,...
    empty_allowed,updateflag,zero_allowed)




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
        error(message('rf:rfbase:rfbase:setcomplexvector:EmptyNotAllowed',...
        rferrhole1,rferrhole2));
    end

    out=squeeze(out);
    if~isnumeric(out)||~isvector(out)||any(isnan(out))
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message(['rf:rfbase:rfbase:setcomplexvector:'...
        ,'NotAComplexVector'],rferrhole1,rferrhole2));
    end

    if~zero_allowed&&any(out==0)
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:setcomplexvector:ZeroNotAllowed',...
        rferrhole1,rferrhole2));
    end

    out=out(:);
    if(nargin==4)||(nargin>=4&&updateflag)
        oldvalue=get(h,prop_name);
        if numel(oldvalue)~=numel(out)||any(oldvalue-out)
            h.PropertyChanged=true;
        end
    end