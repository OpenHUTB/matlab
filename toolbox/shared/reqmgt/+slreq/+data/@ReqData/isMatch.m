function yesno=isMatch(item,filter)






    yesno=false;

    fields=filter(:,1);
    for i=1:length(fields)
        field=fields{i};
        pattern=filter{i,2};
        value=item.(field);
        switch class(value)
        case 'mf.zero.PrimitiveSequence'

            if~matchedInSequence(value,pattern)
                return;
            end
        case 'datetime'
            if~contains(datestr(value),pattern)
                return;
            end
        otherwise

            if isnumeric(value)
                if value~=pattern
                    return;
                end
            else

                if isRegexpPattern(pattern)

                    if isempty(regexp(value,pattern,'once'))
                        return;
                    end
                else

                    if~strcmp(value,pattern)
                        return;
                    end
                end
            end
        end
    end

    yesno=true;
end


function tf=matchedInSequence(value,pattern)
    if ischar(pattern)
        tf=any(strcmp(value.toArray,pattern));
    else
        tf=any(value.toArray==pattern);
    end
end

function tf=isRegexpPattern(pattern)


    tf=pattern(1)=='^'||pattern(end)=='$'...
    ||contains(pattern,'\d')||contains(pattern,'.*');
end
