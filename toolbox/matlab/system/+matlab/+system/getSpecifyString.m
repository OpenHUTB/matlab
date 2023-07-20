function str=getSpecifyString(type)













    if nargin<1||strcmpi(type,'either')
        str='Custom';
    elseif strcmpi(type,'unscaled')
        str='Custom';
    elseif strcmpi(type,'scaled')
        str='Custom';
    else
        matlab.system.internal.error(...
        'MATLAB:system:getSpecifyStringUnknownType',type);
    end
