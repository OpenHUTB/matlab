function n=numArgumentsFromSubscript(obj,s,context)

    try
        switch s(1).type
        case '.'
            switch(s(1).subs)
            case 'disp'
                n=0;
            case 'plot'
                n=0;
            case 'getElementNames'
                n=1;
            case 'numElements'
                n=1;
            case{'get','getElement'}
                if numel(s)==2
                    n=3;
                else
                    n=builtin('numArgumentsFromSubscript',obj,s,context);
                end
            case{'find','compare'}
                if numel(s)==2
                    n=2;
                else
                    n=builtin('numArgumentsFromSubscript',obj,s,context);
                end
            otherwise
                n=builtin('numArgumentsFromSubscript',obj,s,context);
            end
            return;
        case '()'
            s(1).subs=obj.utReplacePDatasetEndIndex(s(1).subs);
            n=builtin('numArgumentsFromSubscript',obj,s,context);
        case '{}'
            if length(s)==1
                n=1;
            elseif ischar(s(2).subs)&&strcmp(s(2).subs,'Name')
                n=1;
            else
                s(1).subs=obj.utReplaceBDatasetEndIndex(s(1).subs);
                n=numArgumentsFromSubscript(obj.get(s(1).subs{:}),...
                s(2:end),context);
            end
        end
    catch ME
        throwAsCaller(ME);
    end
end

