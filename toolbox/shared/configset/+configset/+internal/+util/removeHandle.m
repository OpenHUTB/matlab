function out=removeHandle(input)



    out=loc_removeHandle(input);

    function out=loc_removeHandle(input)

        out=input;
        if iscell(input)
            [m,n]=size(input);
            for i=1:m
                for j=1:n
                    out{i,j}=loc_removeHandle(input{i,j});
                end
            end
        elseif~isscalar(input)
            [m,n]=size(input);
            for i=1:m
                for j=1:n
                    out(i,j)=loc_removeHandle(input(i,j));
                end
            end
        elseif isstruct(input)
            fs=fields(input);
            for i=1:length(fs)
                f=fs{i};
                out.(f)=loc_removeHandle(input.(f));
            end
        elseif isa(input,'function_handle')
            out=func2str(input);
        elseif~isnumeric(input)&&(ishandle(input)||isobject(input))
            out='';
        end