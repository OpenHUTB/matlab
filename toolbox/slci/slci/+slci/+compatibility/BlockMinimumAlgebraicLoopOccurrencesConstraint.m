

classdef BlockMinimumAlgebraicLoopOccurrencesConstraint<slci.compatibility.PositiveBlockParameterConstraintWithFix

    methods

        function obj=BlockMinimumAlgebraicLoopOccurrencesConstraint(aFatal,aParameterName,varargin)
            obj=obj@slci.compatibility.PositiveBlockParameterConstraintWithFix(aFatal,aParameterName,varargin{:});
        end


        function out=check(aObj)
            out=[];
            treatAsAtomic=aObj.ParentBlock().getParam('TreatAsAtomicUnit');
            parameterName=aObj.getParameterName;


            if strcmpi(treatAsAtomic,'on')&&~strcmpi(...
                aObj.ParentBlock().getParam(parameterName),'off')
                out=aObj.getIncompatibility();
            end
        end


    end
end