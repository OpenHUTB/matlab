


classdef PIRHDLFunctionObject<matlab.System



%#codegen

    properties(Nontunable)
FunctionName
Prop1
Prop2
    end

    methods
        function obj=PIRHDLFunctionObject(varargin)
            setProperties(obj,nargin,varargin{:});
            coder.allowpcode('plain');
        end

...
...
...
...
...
...
...
...
...
...
...

        function impl=getPIRImplmentation(obj)
            switch obj.FunctionName
            case{'sin','cos'}
                impl='hdldefaults.Cordic';
            otherwise
                impl='';
            end
        end
    end
end
