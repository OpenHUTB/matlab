classdef Has < systemcomposer.query.Constraint
    %HAS Base "Has" constraint class
    
    %   Copyright 2019 The MathWorks, Inc.
    
    properties
        SubConstraint;
        SkipValidation = false;
    end
    
    properties (Abstract)
        AllowedParentConstraints;
    end
    
    methods
        function obj = Has(subConstraint, varargin)
            obj = obj.parseNameValuePairs(varargin);
            obj.validateSubExpr(subConstraint);
            obj.SubConstraint = subConstraint;
        end
        
        function validateSubConstraint(obj, subConstraint)
            if ~isa(subConstraint, 'systemcomposer.query.Has')
                return;
            end
            
            % Skip validation if the user has expressed.
            if subConstraint.SkipValidation
                return;
            end
            
            allowSubCons = subConstraint.AllowedParentConstraints;
            for i = 1:numel(allowSubCons)
                if isa(obj, allowSubCons{i}.Name)
                    return;
                end
            end
            
            % This constraint is not an allowed parent.
            systemcomposer.internal.throwAPIError('InvalidSubConstraint',...
                metaclass(subConstraint).Name, metaclass(obj).Name);
        end
        
    end
    
    methods (Hidden)
        function str = doStringify(obj)
            subConstraintStr = obj.SubConstraint.stringify;
            str = [metaclass(obj).Name '(' subConstraintStr ')'];
        end
    end
    
    methods (Access = private)
        function validateSubExpr(obj, subConstraint)
            systemcomposer.internal.verifyAPIArgumentType(subConstraint, ...
                2, 'systemcomposer.query.Constraint');
            
            obj.validateSubConstraint(subConstraint);
        end
        
        function obj = parseNameValuePairs(obj, nvPairs)
            for k = 1:2:numel(nvPairs)
                if strcmp(nvPairs{k}, "SkipValidation")
                    obj.SkipValidation = nvPairs{k+1};
                end             
            end
        end
    end
end

