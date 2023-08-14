classdef(ConstructOnLoad)CustomEditOperationEvenData<event.EventData





    properties
        Operation;
IsTemporal
        IsClassBased=[];
    end

    methods

        function data=CustomEditOperationEvenData(operation,varargin)
            if nargin>1
                data.IsTemporal=varargin{1};
                data.IsClassBased=varargin{2};
            end

            data.Operation=operation;
        end
    end

end