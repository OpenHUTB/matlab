function result=modelref_RemoveResetFunc(csTop,csChild,varargin)














    parentRemoveResetFunc=csTop.get_param('RemoveResetFunc');
    childRemoveResetFunc=csChild.get_param('RemoveResetFunc');

    targetType=varargin{2};



    if strcmpi(targetType,'NONE')||strcmp(parentRemoveResetFunc,'on')
        result=false;
    else
        result=~isequal(parentRemoveResetFunc,childRemoveResetFunc);
    end
end
