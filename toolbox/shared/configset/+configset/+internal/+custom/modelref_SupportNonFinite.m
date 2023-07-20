function result=modelref_SupportNonFinite(csTop,csChild,varargin)














    topSupportNonFinite=csTop.get_param('SupportNonFinite');
    childSupportNonFinite=csChild.get_param('SupportNonFinite');


    if strcmp(topSupportNonFinite,'on')
        result=false;
    else
        result=~isequal(topSupportNonFinite,childSupportNonFinite);
    end
end
