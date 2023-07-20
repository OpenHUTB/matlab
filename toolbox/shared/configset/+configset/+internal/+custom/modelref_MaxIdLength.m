function result=modelref_MaxIdLength(csTop,csChild,varargin)













    topLength=csTop.get_param('MaxIdLength');
    childLength=csChild.get_param('MaxIdLength');


    result=false;
    if(childLength>topLength)
        result=true;
    end
end