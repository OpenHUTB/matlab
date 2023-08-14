function varargout=setZDataImpl(~,newValue)

    if~isempty(newValue)&&isvector(newValue)
        error(message('MATLAB:contour:ZMustBeAtLeast2x2Matrix'));
    end
    varargout{1}=newValue;
end
