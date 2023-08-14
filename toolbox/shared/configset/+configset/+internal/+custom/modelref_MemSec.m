function result=modelref_MemSec(csParent,csChild,varargin)















    param=varargin{1};

    parentParam=csParent.get_param(param);
    childParam=csChild.get_param(param);


    if strcmpi(csChild.get_param('ModelReferenceNumInstancesAllowed'),'Single')
        result=false;
    else
        result=~isequal(parentParam,childParam);
    end
end
