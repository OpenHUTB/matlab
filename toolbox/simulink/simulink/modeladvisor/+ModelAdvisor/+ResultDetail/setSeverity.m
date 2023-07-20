function obj=setSeverity(obj,value)
    switch lower(value)
    case 'warn'
        obj.Severity=0;
    case 'fail'
        obj.Severity=1;
    otherwise
        obj.Severity=value;
    end
end