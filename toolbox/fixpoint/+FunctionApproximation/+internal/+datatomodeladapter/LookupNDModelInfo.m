classdef LookupNDModelInfo<FunctionApproximation.internal.datatomodeladapter.ModelInfo








    properties(Constant)
        LookupNDBlockLibraryPath='simulink/Lookup Tables/n-D Lookup Table';
    end

    properties(SetAccess=immutable)


        LookupTableObjectName=['FunctionApproximation_LUTObject_',datestr(now,'yyyymmddTHHMMSSFFF')]
    end

    methods
        function fieldName=getTableFieldName(this)

            fieldName=[this.LookupTableObjectName,'_Table'];
        end

        function fieldName=getBPFieldName(this,dimension)


            fieldName=[this.LookupTableObjectName,'_BP_',int2str(dimension)];
        end

        function fieldName=getBPTunableName(this,dimension)


            fieldName=[this.LookupTableObjectName,'_N_',int2str(dimension)];
        end

        function fieldName=getBPFirstPointName(this,dimension)


            fieldName=[this.LookupTableObjectName,'_BPFP_',int2str(dimension)];
        end

        function fieldName=getBPSpacingName(this,dimension)


            fieldName=[this.LookupTableObjectName,'_BPSp_',int2str(dimension)];
        end

        function update(this,blockData)

            update@FunctionApproximation.internal.datatomodeladapter.ModelInfo(this,blockData);
            lutBlockPath=getBlockPath(this);

            lutObject=Simulink.LookupTable();
            lutObject.StructTypeInfo.Name=this.LookupTableObjectName;
            lutObject.BreakpointsSpecification=FunctionApproximation.BreakpointSpecification.getString(blockData.Spacing);


            lutObject.Breakpoints=repmat(lutObject.Breakpoints,1,blockData.NumberOfDimensions);
            if blockData.Spacing.isEvenSpacing()
                for ii=1:blockData.NumberOfDimensions
                    lutObject.Breakpoints(ii).FirstPointName=getBPFirstPointName(this,ii);
                    lutObject.Breakpoints(ii).SpacingName=getBPSpacingName(this,ii);
                    lutObject.Breakpoints(ii).TunableSizeName=getBPTunableName(this,ii);
                end
            else
                for ii=1:blockData.NumberOfDimensions
                    lutObject.Breakpoints(ii).FieldName=getBPFieldName(this,ii);
                    lutObject.Breakpoints(ii).TunableSizeName=getBPTunableName(this,ii);
                end
            end
            lutObject.Table.FieldName=getTableFieldName(this);

            if blockData.Spacing.isEvenSpacing()
                for ii=1:blockData.NumberOfDimensions
                    lutObject.Breakpoints(ii).FirstPoint=blockData.Data{ii}(1);
                    lutObject.Breakpoints(ii).Spacing=diff(blockData.Data{ii}(1:2));
                    lutObject.Breakpoints(ii).DataType=blockData.StorageTypes(ii).tostring();
                end
                set_param(lutBlockPath,'IndexSearchMethod','Evenly spaced points');
            else
                for ii=1:blockData.NumberOfDimensions
                    lutObject.Breakpoints(ii).Value=blockData.Data{ii};
                    lutObject.Breakpoints(ii).DataType=blockData.StorageTypes(ii).tostring();
                end
                set_param(lutBlockPath,'IndexSearchMethod','Binary search');
            end


            lutObject.Table.Value=blockData.Data{end};
            lutObject.Table.DataType=blockData.StorageTypes(end).tostring();


            this.ModelWorkspace.assignin(this.LookupTableObjectName,lutObject)
            set_param(lutBlockPath,'LookupTableObject',this.LookupTableObjectName);
            set_param(lutBlockPath,'DataSpecification','Lookup table object');
            set_param(lutBlockPath,'InterpMethod',FunctionApproximation.internal.getLUTInterpMethodString(blockData.InterpolationMethod));
            set_param(lutBlockPath,'ExtrapMethod',FunctionApproximation.internal.getLUTExtrapMethodString(blockData.ExtrapolationMethod));
            set_param(lutBlockPath,'OutDataTypeStr',blockData.OutputType.tostring());
            set_param(lutBlockPath,'FractionDataTypeStr',blockData.FractionDataType);
            set_param(lutBlockPath,'IntermediateResultsDataTypeStr',blockData.IntermediateType);
            set_param(lutBlockPath,'RndMeth',blockData.RoundingMode);
            set_param(lutBlockPath,'InternalRulePriority',blockData.InternalRulePriority);
            set_param(lutBlockPath,'UseLastTableValue',blockData.UseLastTableValue);
            set_param(lutBlockPath,'SaturateOnIntegerOverflow',blockData.SaturateOnIntegerOverflow);
        end
    end
end
