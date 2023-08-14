function str=toString(x)



    if isempty(x)
        if iscell(x)
            str='{}';
        elseif isnumeric(x)
            str='[]';
        elseif ischar(x)
            str='''''';
        end
    else
        if ismethod(x,'toString')
            str=x.toString;
        else
            if islogical(x)
                if x
                    str='true';
                else
                    str='false';
                end
            elseif ischar(x)
                str=['''',x,''''];
            elseif isnumeric(x)
                str=num2str(x);
            elseif iscell(x)
                str='{';
                for i=1:length(x)-1
                    str=[str,configset.util.toString(x{i}),', '];
                end
                str=[str,configset.util.toString(x{end}),'}'];
            else
                [m,n]=size(x);
                str=['[',num2str(m),'x',num2str(n),' ',class(x),']'];
            end
        end
    end

end

