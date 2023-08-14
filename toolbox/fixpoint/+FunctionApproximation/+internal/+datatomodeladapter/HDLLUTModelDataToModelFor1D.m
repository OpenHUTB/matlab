classdef HDLLUTModelDataToModelFor1D<FunctionApproximation.internal.datatomodeladapter.BlockDataToModel





    methods(Hidden)
        function modelInfo=initializeModelInfo(~)
            modelInfo=FunctionApproximation.internal.datatomodeladapter.HDLLUTModelInfo();
        end

        function copyOriginalBlock(~,modelInfo,blockData)
            lutBlockPath=getBlockPath(modelInfo);
            add_block(modelInfo.SubsystemLibraryPath,lutBlockPath)
            Simulink.SubSystem.deleteContents(lutBlockPath);

            add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForDelayAtInput(1));
            add_block(modelInfo.InportBlockLibraryPath,modelInfo.getPathForInput(1));
            if blockData.Data{1}(1)~=0
                add_block(modelInfo.SubtractLibraryPath,modelInfo.getPathForSubtractAtInput(1))
                set_param(modelInfo.getPathForSubtractAtInput(1),'OutDataTypeStr','Inherit: Keep MSB');
                add_block(modelInfo.ConstantBlockLibraryPath,modelInfo.getPathForInputSubractionConstant(1))
                set_param(modelInfo.getPathForInputSubractionConstant(1),'Value',modelInfo.getFirstBreakpointVariableName(1),'OutDataTypeStr','Inherit: Inherit via back propagation');
                add_line(lutBlockPath,[modelInfo.getNameForInput(1),'/1'],[modelInfo.getNameForSubtractAtInput(1),'/1'])
                add_line(lutBlockPath,[modelInfo.getNameForInputSubractionConstant(1),'/1'],[modelInfo.getNameForSubtractAtInput(1),'/2'])
                add_line(lutBlockPath,[modelInfo.getNameForSubtractAtInput(1),'/1'],[modelInfo.getNameForDelayAtInput(1),'/1'])
            else
                add_line(lutBlockPath,[modelInfo.getNameForInput(1),'/1'],[modelInfo.getNameForDelayAtInput(1),'/1'])
            end

            add_block(modelInfo.SwitchLibraryPath,modelInfo.getPathForSwitchSaturationUpperBound(1));
            set_param(modelInfo.getPathForSwitchSaturationUpperBound(1),'OutDataTypeStr','Inherit: Inherit via back propagation');
            set_param(modelInfo.getPathForSwitchSaturationUpperBound(1),'Threshold',modelInfo.getDeltaXSaturationUpperBoundVariableName(1));
            add_block(modelInfo.ConstantBlockLibraryPath,modelInfo.getPathForConstantSaturationUpperBound(1));
            set_param(modelInfo.getPathForConstantSaturationUpperBound(1),'Value',modelInfo.getDeltaXSaturationUpperBoundVariableName(1));
            add_line(lutBlockPath,[modelInfo.getNameForConstantSaturationUpperBound(1),'/1'],[modelInfo.getNameForSwitchSaturationUpperBound(1),'/1'])
            add_line(lutBlockPath,[modelInfo.getNameForDelayAtInput(1),'/1'],[modelInfo.getNameForSwitchSaturationUpperBound(1),'/2'])
            add_line(lutBlockPath,[modelInfo.getNameForDelayAtInput(1),'/1'],[modelInfo.getNameForSwitchSaturationUpperBound(1),'/3'])

            add_block(modelInfo.SameDTLibraryPath,modelInfo.getPathForSameDTAtInput(1));
            set_param(modelInfo.getPathForSameDTAtInput(1),'NumInputPorts','2');
            add_line(lutBlockPath,[modelInfo.getNameForSwitchSaturationUpperBound(1),'/1'],[modelInfo.getNameForSameDTAtInput(1),'/1'])
            add_line(lutBlockPath,[modelInfo.getNameForDelayAtInput(1),'/1'],[modelInfo.getNameForSameDTAtInput(1),'/2'])

            add_block(modelInfo.GainLibraryPath,modelInfo.getPathForReciprocalSpacingGain(1));
            set_param(modelInfo.getPathForReciprocalSpacingGain(1),'Gain',modelInfo.getIndexSearchGainVariableName(1));
            set_param(modelInfo.getPathForReciprocalSpacingGain(1),'SaturateOnIntegerOverflow','on');
            add_line(lutBlockPath,[modelInfo.getNameForSwitchSaturationUpperBound(1),'/1'],[modelInfo.getNameForReciprocalSpacingGain(1),'/1'])

            add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForPreIndexSearchDelay(1));
            add_line(lutBlockPath,[modelInfo.getNameForReciprocalSpacingGain(1),'/1'],[modelInfo.getNameForPreIndexSearchDelay(1),'/1'])

            add_block(modelInfo.BitSliceLibraryPath,modelInfo.getPathForIndexBitSlice(1));
            add_line(lutBlockPath,[modelInfo.getNameForPreIndexSearchDelay(1),'/1'],[modelInfo.getNameForIndexBitSlice(1),'/1'])

            directLUBlockPath=modelInfo.getPathForTableValueLU();
            add_block(modelInfo.DirectLUTBlockLibraryPath,directLUBlockPath);
            set_param(directLUBlockPath,'NumberOfTableDimensions','1');
            set_param(directLUBlockPath,'LockScale','on');
            set_param(directLUBlockPath,'Table',modelInfo.getTableValueVariableName());
            set_param(directLUBlockPath,'InputsSelectThisObjectFromTable','Element');

            set_param(directLUBlockPath,'DiagnosticForOutOfRangeInput','None');
            add_line(lutBlockPath,[modelInfo.getNameForIndexBitSlice(1),'/1'],[modelInfo.getNameForTableValueLU(),'/1'])

            delayBlockHandle=add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForResetAfterTableValueLU());
            modelInfo.setDelayReset(delayBlockHandle,'none');
            add_line(lutBlockPath,[modelInfo.getNameForTableValueLU(),'/1'],[modelInfo.getNameForResetAfterTableValueLU(),'/1'])
            add_block(modelInfo.OutportBlockLibraryPath,modelInfo.getPathForOutput());

            if~strcmp(blockData.InterpolationMethod,'linear')
                add_block(modelInfo.DataTypeConversionBlockPath,modelInfo.getPathForOutDTC());
                add_line(lutBlockPath,[modelInfo.getNameForResetAfterTableValueLU(),'/1'],[modelInfo.getNameForOutDTC(),'/1'])
                add_line(lutBlockPath,[modelInfo.getNameForOutDTC(),'/1'],[modelInfo.getNameForOutput(),'/1'])
            else
                add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForRegisterPreProductTableValueLine());
                set_param(modelInfo.getPathForRegisterPreProductTableValueLine(),'DelayLength','1');
                add_line(lutBlockPath,[modelInfo.getNameForResetAfterTableValueLU(),'/1'],[modelInfo.getNameForRegisterPreProductTableValueLine(),'/1'])

                add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForRegisterPostProductTableValueLine());
                set_param(modelInfo.getPathForRegisterPostProductTableValueLine(),'DelayLength','1');
                add_line(lutBlockPath,[modelInfo.getNameForRegisterPreProductTableValueLine(),'/1'],[modelInfo.getNameForRegisterPostProductTableValueLine(),'/1'])

                add_block(modelInfo.BitSliceLibraryPath,modelInfo.getPathForFractionBitSlice(1));
                add_line(lutBlockPath,[modelInfo.getNameForPreIndexSearchDelay(1),'/1'],[modelInfo.getNameForFractionBitSlice(1),'/1'])

                add_block(modelInfo.DataTypeConversionBlockPath,modelInfo.getPathForIndexExtractor(1));
                set_param(modelInfo.getPathForIndexExtractor(1),'ConvertRealWorld','Stored Integer (SI)');
                add_line(lutBlockPath,[modelInfo.getNameForFractionBitSlice(1),'/1'],[modelInfo.getNameForIndexExtractor(1),'/1'])

                directLUBlockPathDeltaTV=modelInfo.getPathForDeltaTableValueLU();
                add_block(modelInfo.DirectLUTBlockLibraryPath,directLUBlockPathDeltaTV);
                set_param(directLUBlockPathDeltaTV,'NumberOfTableDimensions','1');
                set_param(directLUBlockPathDeltaTV,'LockScale','on');
                set_param(directLUBlockPathDeltaTV,'Table',modelInfo.getDeltaTableValueVariableName());
                set_param(directLUBlockPathDeltaTV,'InputsSelectThisObjectFromTable','Element');

                set_param(directLUBlockPathDeltaTV,'DiagnosticForOutOfRangeInput','None');
                add_line(lutBlockPath,[modelInfo.getNameForIndexBitSlice(1),'/1'],[modelInfo.getNameForDeltaTableValueLU(),'/1'])

                delayBlockHandle=add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForResetAfterDeltaTableValueLU());
                modelInfo.setDelayReset(delayBlockHandle,'none');
                add_line(lutBlockPath,[modelInfo.getNameForDeltaTableValueLU(),'/1'],[modelInfo.getNameForResetAfterDeltaTableValueLU(),'/1'])

                delayBlockHandle=add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForResetAfterDeltaTableValueLUForFractionLine());
                modelInfo.setDelayReset(delayBlockHandle,'none');
                add_line(lutBlockPath,[modelInfo.getNameForIndexExtractor(1),'/1'],[modelInfo.getNameForResetAfterDeltaTableValueLUForFractionLine(),'/1'])

                add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForRegisterPreProductDeltaTableValueLine());
                set_param(modelInfo.getPathForRegisterPreProductDeltaTableValueLine(),'DelayLength','1');
                add_line(lutBlockPath,[modelInfo.getNameForResetAfterDeltaTableValueLU(),'/1'],[modelInfo.getNameForRegisterPreProductDeltaTableValueLine(),'/1'])

                add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForRegisterPreProductFractionLine());
                set_param(modelInfo.getPathForRegisterPreProductFractionLine(),'DelayLength','1');
                add_line(lutBlockPath,[modelInfo.getNameForResetAfterDeltaTableValueLUForFractionLine(),'/1'],[modelInfo.getNameForRegisterPreProductFractionLine(),'/1'])

                add_block(modelInfo.ProductLibraryPath,modelInfo.getPathForProductPostTableValue());
                set_param(modelInfo.getPathForProductPostTableValue(),'OutDataTypeStr','Inherit: Inherit via back propagation');
                add_line(lutBlockPath,[modelInfo.getNameForRegisterPreProductDeltaTableValueLine(),'/1'],[modelInfo.getNameForProductPostTableValue(),'/1'])
                add_line(lutBlockPath,[modelInfo.getNameForRegisterPreProductFractionLine(),'/1'],[modelInfo.getNameForProductPostTableValue(),'/2'])

                add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForRegisterPostProduct());
                set_param(modelInfo.getPathForRegisterPostProduct(),'DelayLength','1');
                add_line(lutBlockPath,[modelInfo.getNameForProductPostTableValue(),'/1'],[modelInfo.getNameForRegisterPostProduct(),'/1'])

                add_block(modelInfo.AddLibraryPath,modelInfo.getPathForAddingTableValue());
                set_param(modelInfo.getPathForAddingTableValue(),'OutDataTypeStr','Inherit: Inherit via back propagation');
                add_line(lutBlockPath,[modelInfo.getNameForRegisterPostProductTableValueLine(),'/1'],[modelInfo.getNameForAddingTableValue(),'/1'])
                add_line(lutBlockPath,[modelInfo.getNameForRegisterPostProduct(),'/1'],[modelInfo.getNameForAddingTableValue(),'/2'])

                add_block(modelInfo.DelayLibraryPath,modelInfo.getPathForDelayPostInterpolation());
                add_line(lutBlockPath,[modelInfo.getNameForAddingTableValue(),'/1'],[modelInfo.getNameForDelayPostInterpolation(),'/1'])

                add_line(lutBlockPath,[modelInfo.getNameForDelayPostInterpolation(),'/1'],[modelInfo.getNameForOutput(),'/1'])
            end
            Simulink.BlockDiagram.arrangeSystem(lutBlockPath);

            set_param(modelInfo.ModelName,'AlgebraicLoopMsg','error');
            set_param(modelInfo.ModelName,'DefaultParameterBehavior','Inlined');
            set_param(modelInfo.ModelName,'BlockReduction','off');
            set_param(modelInfo.ModelName,'ConditionallyExecuteInputs','off');
            set_param(modelInfo.ModelName,'ProdHWDeviceType','ASIC/FPGA');

            modelInfo.turnDelaysOff();
        end
    end
end


