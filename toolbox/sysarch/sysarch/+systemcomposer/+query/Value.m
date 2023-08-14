classdef Value
    %VALUE An object which holds a value and optionally units.
   
    %   Copyright 2019 The MathWorks, Inc.
    
    properties
        Val
        Units
    end
    
    methods
        function obj = Value(value, units)
            obj.Val = value;
            if nargin > 1
                obj.Units = units;
            end
        end
        
        function str = stringify(obj)
            str = ['systemcomposer.query.Value(' obj.stringifyValue(obj.Val) ',' '"' char(obj.Units) '"' ')'];
        end
        
        function str = stringifyValue(~, val)
            if isa(val, 'Simulink.IntEnumType')
                str = [metaclass(val).Name '.' char(val)];
            elseif (ischar(val) || isstring(val))
                str = ['"' char(val) '"'];
            else
                str = num2str(val);
            end
        end
    end
end

