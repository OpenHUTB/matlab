classdef GroupConstraintFactory




    methods
        function constraint=makeConstraint(~,blkObj,inputGroupInfos,pathItemToGroupInfo)
            switch class(blkObj)
            case 'Simulink.Sum'
                constraint=cpopt.internal.constraints.SumConstraint(inputGroupInfos,pathItemToGroupInfo,blkObj);
            case 'Simulink.Product'
                constraint=cpopt.internal.constraints.ProductConstraint(inputGroupInfos,pathItemToGroupInfo,blkObj);
            case 'Simulink.DataTypeConversion'
                constraint=cpopt.internal.constraints.CastConstraint(inputGroupInfos,pathItemToGroupInfo,blkObj);
            case 'Simulink.Gain'
                constraint=cpopt.internal.constraints.GainConstraint(inputGroupInfos,pathItemToGroupInfo,blkObj);
            case 'Simulink.Lookup_nD'
                constraint=cpopt.internal.constraints.LutConstraint(inputGroupInfos,pathItemToGroupInfo,blkObj);
            case{'Simulink.Outport','Simulink.Inport','Simulink.Constant'}
                constraint=cpopt.internal.constraints.NullConstraint();
            case 'Simulink.UnaryMinus'
                constraint=cpopt.internal.constraints.UnaryMinusConstraint(inputGroupInfos,pathItemToGroupInfo,blkObj);
            case{'Simulink.Bias','Simulink.UnitDelay','Simulink.Delay'}
                constraint=cpopt.internal.constraints.NullConstraint();
            case 'Simulink.Switch'
                constraint=cpopt.internal.constraints.SwitchConstraint(inputGroupInfos,pathItemToGroupInfo,blkObj);
            case 'Simulink.DotProduct'
                constraint=cpopt.internal.constraints.DotProductConstraint(inputGroupInfos,pathItemToGroupInfo,blkObj);
            otherwise
                constraint=cpopt.internal.constraints.BinaryPointConstraint(inputGroupInfos,pathItemToGroupInfo,blkObj);
            end
        end
    end
end

