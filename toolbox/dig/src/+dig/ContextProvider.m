classdef ContextProvider<handle
    properties(SetObservable=true)
        TypeChain{mustBeCellArrayOfStrings}={};
    end
    methods
        function obj=ContextProvider()
            obj.TypeChain={};
        end
    end
end


function mustBeCellArrayOfStrings(data)
    if~iscell(data)
        throw(MException(message('dig:controller:resources:PropertyMustBeCellArrayOfStrings','TypeChain')));
    end
    numElements=numel(data);
    for index=1:numElements
        if~ischar(data{index})
            throw(MException(message('dig:controller:resources:PropertyMustBeCellArrayOfStrings','TypeChain')));
        end
    end
end
