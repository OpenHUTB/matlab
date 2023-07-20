function P=get(A,name)











    narginchk(1,2);

    if nargin==1
        if~isscalar(A)
            error(message('MATLAB:class:get:ScalarRequired'));
        end


        for pn=properties(A)'
            S.(pn{1})=A.(pn{1});
        end
        if nargout==1
            P=S;
        else
            disp(S);
        end

    elseif nargin==2
        rows=numel(A);

        name=convertStringsToChars(name);

        if iscellstr(name)
            cols=numel(name);
            P=cell(rows,cols);
            for i=1:cols
                [P{:,i}]=A.(name{i});
            end
        elseif ischar(name)
            if(rows==1)
                P=A.(name);
            else
                [P{1:rows,1}]=A.(name);
            end
        else
            error(message('MATLAB:class:InvalidArgument','get','get'));
        end
    end



