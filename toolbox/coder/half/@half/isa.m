function out=isa(~,className)
    switch className
    case 'integer'
        out=false;
    case 'uint16'
        out=false;
    case 'float'
        out=true;
    case 'numeric'
        out=true;
    case 'half'
        out=true;
    otherwise
        out=false;
    end
end

