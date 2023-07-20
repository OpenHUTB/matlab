classdef ConjuctionConstraint < systemcomposer.query.Constraint
    %CONJUCTIONCONSTRAINT A conjuction constraint
    
    %   Copyright 2019-2022 The MathWorks, Inc.
    
    properties
        LHSConstraint
        RHSConstraint
        ConjuctionFcn
    end

    methods
        function obj = ConjuctionConstraint(lhsConstraint, rhsConstraint, conjFcnHdl)
            obj.LHSConstraint = lhsConstraint;
            obj.RHSConstraint = rhsConstraint;
            obj.ConjuctionFcn = conjFcnHdl;
        end
        
        function modelElems = doGetSatisfied(obj, arch, elemKindToFind, flattenReferences, varargin)
            leftResult = obj.LHSConstraint.getSatisfied(arch, elemKindToFind, flattenReferences, varargin{:});
            rightResult = obj.RHSConstraint.getSatisfied(arch, elemKindToFind, flattenReferences, varargin{:});
            modelElems = [];
            if strcmpi(func2str(obj.ConjuctionFcn), 'or')
                modelElems = unique([leftResult rightResult]);
            elseif strcmpi(func2str(obj.ConjuctionFcn), 'and')
                modelElems = setdiff(leftResult,rightResult);
            end
        end
        
        function tf = doIsSatisfied(obj, elem)
            tf = obj.ConjuctionFcn(obj.LHSConstraint.isSatisfied(elem), obj.RHSConstraint.isSatisfied(elem));
        end
        
        function negConstraint = isNegationConstraint(obj)
            negConstraint = obj.IsNot || obj.LHSConstraint.isNegationConstraint || ...
                    obj.RHSConstraint.isNegationConstraint;
        end
    end
    
    methods (Hidden)
        function str = doStringify(obj)
            if strcmpi(func2str(obj.ConjuctionFcn), 'and')
                str = ['(' obj.LHSConstraint.stringify ' & ' obj.RHSConstraint.stringify ')'];
            else
                assert(strcmpi(func2str(obj.ConjuctionFcn), 'or'))
                str = ['(' obj.LHSConstraint.stringify ' | ' obj.RHSConstraint.stringify ')'];
            end
            
        end
        
        function validate(obj, str)
            invalidErrId = 'SystemArchitecture:Query:InvalidConstraint';
            if ~isa(obj.LHSConstraint, 'systemcomposer.query.Constraint')
                error(invalidErrId, message(invalidErrId, str).getString);
            else
                obj.LHSConstraint.validate(str);
            end
            if ~isa(obj.RHSConstraint, 'systemcomposer.query.Constraint')
                error(invalidErrId, message(invalidErrId, str).getString);
            else
                obj.RHSConstraint.validate(str);
            end
        end

        function tf = isEvaluatedUsingNewSystem(obj)
            tf = false;
            if strcmpi(func2str(obj.ConjuctionFcn), 'or')
                tf = obj.LHSConstraint.isEvaluatedUsingNewSystem && obj.RHSConstraint.isEvaluatedUsingNewSystem;
            end
        end
    end
end

