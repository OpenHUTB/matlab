function varargout=setYDataImpl(~,newValue)

    if isscalar(newValue)
        error(message('MATLAB:contour:YMustNotBeScalar'));
    end
    if isvector(newValue)&&~isempty(find(~isfinite(newValue),1))
        error(message('MATLAB:contour:YMustBeFinite'));
    end
    varargout{1}=newValue;
end
