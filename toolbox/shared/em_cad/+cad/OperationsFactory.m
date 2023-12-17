classdef OperationsFactory<handle

    methods
        function opnObj=createOperation(self,Type,varargin)
            switch Type
            case 'Add'
                opnObj=cad.BooleanOperation(Type,varargin{:});
            case 'Subtract'
                opnObj=cad.BooleanOperation(Type,varargin{:});
            case 'Intersect'
                opnObj=cad.BooleanOperation(Type,varargin{:});
            case 'Xor'
                opnObj=cad.BooleanOperation(Type,varargin{:});
            end
        end
    end
end
