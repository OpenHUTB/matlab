


classdef S_FunctionBlock<slci.simulink.Block

    methods

        function obj=S_FunctionBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            sfunParams=obj.getParam('MaskPropertyNameString');

            if~isempty(strfind(sfunParams,'XRelSourceFile'))
                obj.addConstraint(slci.compatibility.SILConstraint());

            else
                obj.addConstraint(slci.compatibility.LCTConstraint());
            end


            constraintObj=slci.compatibility.ParamValueConstraint(...
            'Parameters',...
            'ChkNonFiniteParam',...
            'ChkComplexParam');
            obj.addConstraint(constraintObj);
            obj.setSupportsEnums(true);
            obj.setSupportsBuses(true);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
