classdef(Abstract)Constraint<handle




    properties(Hidden)
        IsNot=false;
    end

    methods(Static,Hidden)
        function c=createFromString(str)
            import slreq.query.*;
            c=eval(str);
            if~isa(c,'slreq.query.Constraint')
                invalidErrId='Slreq:Query:InvalidConstraint';
                error(invalidErrId,message(invalidErrId,str).getString);
            end
            c.validate(str);
        end

        function err=validateString(str)
            import slreq.query.*;
            err="";
            try
                Constraint.createFromString(str);
            catch ME
                err=ME.message;
            end
        end
    end

    methods(Sealed)
        function elems=getSatisfied(obj,arch,elemKindToFind,flattenReferences,varargin)
            elems=obj.doGetSatisfied(arch,elemKindToFind,flattenReferences,varargin{:});
        end

        function stereotypeNames=getSatisfiedStereotypeNames(obj,cache)
            stereotypeNames=obj.doGetSatisfiedStereotypeNames(cache);
        end

        function tf=isSatisfied(obj,elem)
            tf=obj.doIsSatisfied(elem);
            if obj.IsNot
                tf=~tf;
            end












        end

        function str=stringify(obj)
            str=obj.doStringify;
            if(obj.IsNot)
                str=['~',str];
            end











            if(isstring(str)||iscell(str))
                str=strjoin(str,'');
            end
        end
    end

    methods(Abstract,Hidden)
        tf=doIsSatisfied(obj,elem);
        str=doStringify(obj);
    end

    methods(Hidden)
        function validate(obj,str)
            if~isa(obj,'slreq.query.Constraint')
                invalidErrId='Slreq:Query:InvalidConstraint';
                error(invalidErrId,message(invalidErrId,str).getString);
            end
        end

        function negConstraint=isNegationConstraint(obj)
            negConstraint=obj.IsNot;
        end
    end

    methods
        function conjConstraint=and(lhsConstraint,rhsConstraint)
            conjConstraint=slreq.query.ConjuctionConstraint(lhsConstraint,rhsConstraint,@and);
        end

        function conjConstraint=or(lhsConstraint,rhsConstraint)
            conjConstraint=slreq.query.ConjuctionConstraint(lhsConstraint,rhsConstraint,@or);
        end
        function constraint=not(constraint)
            constraint.IsNot=true;
        end
    end
end