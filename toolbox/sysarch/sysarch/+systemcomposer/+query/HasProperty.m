classdef HasProperty < systemcomposer.query.Constraint
    %HASPROPERTY Constraint that the architecture element has a property
    %with the specified fully-qualified name.
    
    %   Copyright 2020 The MathWorks, Inc.
    
    properties
        PropertyFullyQualifiedName; % The fully qualified property name to look for
    end
    
    methods
        function obj = HasProperty(propName)
            parts = strsplit(propName, '.');
            obj.PropertyFullyQualifiedName = propName;
        end
    end
    
    methods (Hidden)
        function str = doStringify(obj)
            str = [metaclass(obj).Name '("' obj.PropertyFullyQualifiedName '")'];
        end
        
        function tf = doIsSatisfied(obj, archElem)
            % Look to see if it has a stereotype which satisifes.
            tf = false;
            if (~isa(archElem, 'systemcomposer.base.StereotypableElement'))
                % This only handles architecture elements as the passed in argument.
                return;
            end
            
            tf = archElem.hasProperty(obj.PropertyFullyQualifiedName);
            if (tf)
                return;
            end
        end
    end
end

