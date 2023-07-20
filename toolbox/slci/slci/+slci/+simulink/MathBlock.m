


classdef MathBlock<slci.simulink.Block

    methods

        function obj=MathBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(...
            slci.compatibility.UniformPortDataTypesConstraint);
            obj.addConstraint(...
            slci.compatibility.PositiveBlockParameterConstraintWithFix(false,...
            'RndMeth','Zero','Floor'));


            obj.addConstraint(...
            slci.compatibility.MathOperatorConstraint(false,...
            'Operator','exp','log','10^u','log10','magnitude^2',...
            'pow','reciprocal','Hypot','rem','mod','square','transpose'));
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end


