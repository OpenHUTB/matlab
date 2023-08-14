


classdef PositiveBlockParameterConstraintWithFix<slci.compatibility.PositiveBlockParameterConstraint

    methods

        function obj=PositiveBlockParameterConstraintWithFix(aFatal,aParameterName,varargin)
            obj=obj@slci.compatibility.PositiveBlockParameterConstraint(...
            aFatal,aParameterName,varargin{:});
        end

        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            supportedValues=aObj.getSupportedValues;


            parameterName=aObj.getParameterName();
            try
                aObj.ParentBlock().setParam(parameterName,supportedValues{1});
                out=true;
            catch

            end
        end

    end
end
