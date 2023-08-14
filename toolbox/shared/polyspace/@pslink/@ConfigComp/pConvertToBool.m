

function out=pConvertToBool(val)

    assert(islogical(val)||...
    (isnumeric(val)&&numel(val)==1&&(val==0||val==1))||...
    (ischar(val)&&ismember(val,{'on','off'})));

    if ischar(val)
        out=logical(strcmp(val,'on'));
    elseif isnumeric(val)
        out=logical(val==1);
    else
        out=val;
    end

