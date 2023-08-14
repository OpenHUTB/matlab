function result=modelref_SupportVariableSizeSignals(csParent,csChild,varargin)














    parentParam=csParent.get_param('SupportVariableSizeSignals');
    childParam=csChild.get_param('SupportVariableSizeSignals');

    if strcmp(parentParam,'on')
        result=false;
    else
        result=~isequal(parentParam,childParam);
    end
end
