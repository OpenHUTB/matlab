function varargout=setXDataImpl(~,newValue)

    if isscalar(newValue)
        error(message('MATLAB:contour:XMustNotBeScalar'));
    end
    if isvector(newValue)&&~isempty(find(~isfinite(newValue),1))
        error(message('MATLAB:contour:XMustBeFinite'));
    end
    varargout{1}=newValue;
end
