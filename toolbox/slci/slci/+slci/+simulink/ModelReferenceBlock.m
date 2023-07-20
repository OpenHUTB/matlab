


classdef ModelReferenceBlock<slci.simulink.Block

    methods

        function obj=ModelReferenceBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.addConstraint(slci.compatibility.CodeVariantConstraint());
            obj.addConstraint(...
            slci.compatibility.ProtectedModelConditionConstraint);
            obj.addConstraint(...
            slci.compatibility.BlockConstantSampleTimeConstraint);
            if slcifeature('MdlRefLUTObjSupport')==0
                constraintObj=slci.compatibility.ParamValueConstraint(...
                'ParameterArgumentValues',...
                'ChkNonFiniteParam',...
                'ChkComplexParam',...
                'ChkLUTParam');
            else
                constraintObj=slci.compatibility.ParamValueConstraint(...
                'ParameterArgumentValues',...
                'ChkNonFiniteParam',...
                'ChkComplexParam');
            end
            obj.addConstraint(constraintObj);


            obj.addConstraint(slci.compatibility.SupportedInportDataTypesConstraint(...
            {'double','single','int8','uint8','int16',...
            'uint16','int32','uint32','boolean'}));

            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);

            obj.addConstraint(...
            slci.compatibility.InputPortLatchParameterConstraint);
            obj.addConstraint(...
            slci.compatibility.InputPortLatchFeedbackParameterConstraint);
            obj.addConstraint(...
            slci.compatibility.isExportFunctionModelConstraint);

            obj.addConstraint(...
            slci.compatibility.BlockMultirateConstraint);


            obj.addConstraint(...
            slci.compatibility.ModelReferenceInstanceParameterAsArgumentConstraint);

            obj.addConstraint(...
            slci.compatibility.UnsupportedMaskedLookupTableObjectConstraint);
        end

        function out=checkCompatibility(aObj)
            out=checkCompatibility@slci.simulink.Block(aObj);
        end

    end

end
