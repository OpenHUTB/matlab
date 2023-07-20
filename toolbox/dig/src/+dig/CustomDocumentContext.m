classdef CustomDocumentContext<handle
    properties(SetObservable=true)
        TypeChain{mustBeCellArrayOfStrings}={};
    end

    properties(SetAccess=protected)
        Name{mustBeString}='';
        Priority{mustBeInteger}=0;
        DefaultTabName{mustBeString}='';
    end

    methods
        function obj=CustomDocumentContext(name)
            obj.Name=name;
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

function mustBeString(data)
    if~ischar(data)
        throw(MException(message('dig:controller:resources:NameMustBeString')));
    end
end