function result=modelref_SupportComplex(csTop,csChild,varargin)














    topSupportComplex=csTop.get_param('SupportComplex');
    childSupportComplex=csChild.get_param('SupportComplex');


    if strcmp(topSupportComplex,'on')
        result=false;
    else
        result=~isequal(topSupportComplex,childSupportComplex);
    end

end
