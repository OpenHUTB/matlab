function varargout=setTextListImpl(~,newValue)

    if~isempty(newValue)&&~isvector(newValue)
        error(message('MATLAB:contour:TextListMustBeVectorOrScalar'));
    end
    if~isempty(find(~isfinite(newValue),1))
        error(message('MATLAB:contour:TextListMustBeFinite'));
    end
    if(numel(newValue)>1)&&(any(diff(newValue)<=0))
        varargout{1}=unique(newValue);
    else
        varargout{1}=newValue;
    end
end
