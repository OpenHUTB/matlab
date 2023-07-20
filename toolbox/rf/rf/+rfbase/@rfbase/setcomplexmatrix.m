function out=setcomplexmatrix(h,out,prop_name,...
    empty_allowed,updateflag)




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
        error(message('rf:rfbase:rfbase:setcomplexmatrix:EmptyNotAllowed',...
        rferrhole1,rferrhole2));
    end

    if~isnumeric(out)||anynan(out)
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:setcomplexmatrix:NotAComplexMatrix',...
        rferrhole1,rferrhole2));
    end
    [m1,m2,~,d4,d5,d6]=size(out);
    if(m1~=m2)||(d4~=1)||(d5~=1)||(d6~=1)
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:setcomplexmatrix:NotARightMatrix',...
        rferrhole1,rferrhole2));
    end

    if(nargin==4)||(nargin==5&&updateflag)
        h.PropertyChanged=true;
    end
