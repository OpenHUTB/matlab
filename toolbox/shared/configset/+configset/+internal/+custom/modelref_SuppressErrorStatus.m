function result=modelref_SuppressErrorStatus(csTop,csChild,varargin)














    topSuppressErrorStatus=csTop.get_param('SuppressErrorStatus');
    childSuppressErrorStatus=csChild.get_param('SuppressErrorStatus');


    if strcmp(topSuppressErrorStatus,'off')
        result=false;
    else
        result=~isequal(topSuppressErrorStatus,childSuppressErrorStatus);
    end
end
