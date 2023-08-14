


classdef MathOperatorConstraint<slci.compatibility.PositiveBlockParameterConstraint

    methods

        function obj=MathOperatorConstraint(aFatal,aParameterName,varargin)
            obj=obj@slci.compatibility.PositiveBlockParameterConstraint(aFatal,aParameterName,varargin{:});
        end

        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,aIncompatibility)
            out=false;
            try
                Operator=aObj.ParentBlock().getParam('Operator');
                if strcmpi(Operator,'sqrt')
                    blkH=aObj.ParentBlock().getParam('Handle');
                    newblk=replace_block(blkH,'Math','Sqrt','noprompt');
                    set_param(newblk{1},'Function','signedSqrt');
                    out=true;
                else
                    out=fix@slci.compatibility.PositiveBlockParameterConstraint.fix(aObj,aIncompatibility);
                end
            catch
            end
        end

    end
end
