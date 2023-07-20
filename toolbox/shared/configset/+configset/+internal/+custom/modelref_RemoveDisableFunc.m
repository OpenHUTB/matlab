function result=modelref_RemoveDisableFunc(csTop,csChild,varargin)














    parentRemoveDisableFunc=csTop.get_param('RemoveDisableFunc');
    childRemoveDisableFunc=csChild.get_param('RemoveDisableFunc');

    targetType=varargin{2};



    if strcmpi(targetType,'NONE')||strcmp(parentRemoveDisableFunc,'on')
        result=false;
    else
        result=~isequal(parentRemoveDisableFunc,childRemoveDisableFunc);
    end
end
