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
            case 'getAsDatastore'
                isReset=locRecurser(obj,s);
                if isReset==true
                    n=0;
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
                intermediate=obj.getAsDatastore(s(1).subs{:});

                isReset=locRecurser(intermediate,s(2:end));


                if isReset==true
                    n=0;
                else
                    n=numArgumentsFromSubscript(intermediate,s(2:end),context);
                end
            end
        end
    catch ME
        throwAsCaller(ME);
    end
end

function isReset=locRecurser(obj,s)


    curIndex=1;
    switch s(1).type
    case '.'
        if numel(s)==1
            isReset=locCheckType(obj,s(curIndex:end));
            return;
        elseif~strcmp(s(2).type,'()')
            intermediate=builtin('subsref',obj,s(1));
            curIndex=2;
        else

            intermediate=builtin('subsref',obj,s(1:2));
            curIndex=3;
        end

        if curIndex<=numel(s)
            isReset=locRecurser(intermediate,s(curIndex:end));
            return;
        else
            isReset=false;
            return;
        end

    case '()'
        if numel(s)==1
            isReset=false;
            return;
        else
            intermediate=builtin('subsref',obj,s(1));
            isReset=locRecurser(intermediate,s(2:end));
            return;
        end

    case '{}'
        if numel(s)==1
            isReset=false;
            return;
        else
            intermediate=builtin('subsref',obj,s(1));
            isReset=locRecurser(intermediate,s(2:end));
        end
    end

end


function isReset=locCheckType(obj,s)
    switch s(1).type
    case '.'
        switch s(1).subs
        case 'reset'
            switch class(obj)
            case 'matlab.io.datastore.SimulationDatastore'
                isReset=true;
            otherwise
                isReset=false;
            end
        otherwise
            isReset=false;
        end
    otherwise
        isReset=false
    end
end

