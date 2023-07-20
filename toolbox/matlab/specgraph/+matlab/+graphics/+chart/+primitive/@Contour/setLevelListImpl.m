function varargout=setLevelListImpl(~,newValue)

    if~isempty(newValue)&&~isvector(newValue)
        error(message('MATLAB:contour:LMustBeVectorOrScalar'));
    end
    if any(isnan(newValue))
        error(message('MATLAB:contour:LMustBeFinite'));
    end
    if(numel(newValue)>1)&&(any(diff(newValue)<=0))
        varargout{1}=unique(newValue);
    else
        varargout{1}=newValue;
    end
end
