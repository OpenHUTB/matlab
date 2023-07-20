classdef ReplacementSetUp<handle





    properties(Constant)
        SourceBlockName='ReplicaOfSource'

        InputDataTypeConversionPrefix='DTC_input_'
        OutputDataTypeConversionPrefix='DTC_output_'
        DataTypeConversionRoundingMethod='Nearest';
        DataTypeConversionOutInheritance='Inherit: Inherit via back propagation'

        SubsystemPrefix='Decoupled_unsupported_'
        DataTypeConversionBlockPath='simulink/Signal Attributes/Data Type Conversion'

        InputBlockSpacing=20
        InputBlockWidth=40
        ModelNamePrefix='ModelWithDecoupledEntities_'

        TagUsed='DecoupledSystem'
        ColorBackground='lightblue'
    end

end