classdef (Abstract) Constraint < handle
    %CONSTRAINT Base class representing all systemcomposer constraints
    
    %   Copyright 2019-2022 The MathWorks, Inc.
    
    properties (Hidden)
        IsNot = false;
    end
    
    methods (Static, Hidden)
        function c = createFromString(str)
            import systemcomposer.query.*;
            c = eval(str);
            if ~isa(c, 'systemcomposer.query.Constraint')
                invalidErrId = 'SystemArchitecture:Query:InvalidConstraint';
                error(invalidErrId, message(invalidErrId, str).getString);
            end
            c.validate(str);
        end
        
        function err = validateString(str)
            import systemcomposer.query.*;
            err = "";
            try
                Constraint.createFromString(str);
            catch ME
                err = ME.message;
            end
        end
    end
    
    methods (Sealed)
        function elems = getSatisfied(obj, arch, elemKindToFind, flattenReferences, varargin)
            elems = obj.doGetSatisfied(arch, elemKindToFind, flattenReferences, varargin{:});
        end
        
        function stereotypeNames = getSatisfiedStereotypeNames(obj, cache)
            stereotypeNames = obj.doGetSatisfiedStereotypeNames(cache);
        end
        
        function tf = isSatisfied(obj, elem)
            tf = obj.doIsSatisfied(elem);
            if obj.IsNot
                tf = ~tf;
            end
            
%             if (tf && ~isempty(obj.AndConstraint))
%                 % The LHS was satisifed and we have an and constraint so
%                 % execute it as well.
%                 tf = tf && obj.AndConstraint.isSatisfied(elem);
%             end
%             
%             if (~tf && ~isempty(obj.OrConstraint))
%                 % The LHS was not satsified and we have an or constraint sp
%                 % execute it as well.
%                 tf = tf || obj.OrConstraint.isSatisfied(elem);
%             end
        end
        
        function str = stringify(obj)
            str = obj.doStringify;
            if (obj.IsNot)
                str = ['~' str];
            end
            
%             if ~isempty(obj.AndConstraint)
%                 rhs_str = obj.AndConstraint.stringify;
%                 str = [str '.and(' rhs_str ')'];
%             end
%             
%             if ~isempty(obj.OrConstraint)
%                 rhs_str = obj.OrConstraint.stringify;
%                 str = [str '.or(' rhs_str ')'];
%             end
            
            if (isstring(str) || iscell(str))
                str = strjoin(str, '');
            end
        end
    end
    
    methods (Abstract, Hidden)
        tf = doIsSatisfied(obj, elem); % Local implementation for each sub-class
        str = doStringify(obj); % Local implementation for each sub-class
    end
    
    methods (Hidden)
        function validate(obj, str)
            if ~isa(obj, 'systemcomposer.query.Constraint')
                invalidErrId = 'SystemArchitecture:Query:InvalidConstraint';
                error(invalidErrId, message(invalidErrId, str).getString);
            end
        end
        
        function negConstraint = isNegationConstraint(obj)
            negConstraint = obj.IsNot;
        end

        function tf = isEvaluatedUsingNewSystem(~)
            tf = false;
        end
    end
    
    methods
        function conjConstraint = and(lhsConstraint, rhsConstraint)
            conjConstraint = systemcomposer.query.ConjuctionConstraint(lhsConstraint, rhsConstraint, @and);
        end
        
        function conjConstraint = or(lhsConstraint, rhsConstraint)
            conjConstraint = systemcomposer.query.ConjuctionConstraint(lhsConstraint, rhsConstraint, @or);
        end
        function constraint = not(constraint)
            constraint.IsNot = true;
        end
    end
end
