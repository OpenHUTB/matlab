classdef LookupNDBlockDataHandler





    properties(Access={?LookupNDBlockDataHandler,?tLookupNDBlockDataHandler})
        CheckLUTObjectClass Simulink.LookupTable
        CheckBreakpointsSpecification{mustBeMember(CheckBreakpointsSpecification,{'Explicit values','Even spacing'})}='Explicit values'
        NumDim double{mustBePositive,mustBeInteger}=1;
    end

    methods
        function transferDataToBlock(this,blockPath,lutObject)


            this=validateInputs(this,blockPath,lutObject);


            set_param(blockPath,'DataSpecification','Table and breakpoints');


            set_param(blockPath,'NumberOfTableDimensions',int2str(this.NumDim));


            transferTableDataToBlock(this,blockPath,lutObject)


            switch lutObject.BreakpointsSpecification
            case 'Explicit values'
                transferBreakpointDataToBlockExplicitValues(this,blockPath,lutObject);
            case 'Even spacing'
                transferBreakpointDataToBlockEvenSpacing(this,blockPath,lutObject);


            end


            transferDesignRanges(this,blockPath,lutObject);


            transferStorageDataTypes(this,blockPath,lutObject);
        end

        function this=validateInputs(this,blockPath,lutObject)

            [isValid,diagnostic]=FunctionApproximation.internal.Utils.isLUTBlock(blockPath);
            if~isValid
                FunctionApproximation.internal.DisplayUtils.throwError(diagnostic);
            end



            this.CheckLUTObjectClass=lutObject;



            this.CheckBreakpointsSpecification=lutObject.BreakpointsSpecification;

            this.NumDim=numel(lutObject.Breakpoints);
        end

        function transferTableDataToBlock(this,blockPath,lutObject)

            tableData=lutObject.Table.Value;
            nDimensions=this.NumDim;
            if nDimensions<3
                set_param(blockPath,'Table',fixed.internal.compactButAccurateMat2Str(tableData))
            else
                set_param(blockPath,'Table',['reshape(',fixed.internal.compactButAccurateMat2Str(tableData(:)),',',mat2str(size(tableData),18),')']);
            end
        end

        function transferBreakpointDataToBlockExplicitValues(this,blockPath,lutObject)

            set_param(blockPath,'BreakpointsSpecification','Explicit values');
            for ii=1:this.NumDim
                set_param(blockPath,['BreakpointsForDimension',num2str(ii,'%g')],fixed.internal.compactButAccurateMat2Str(lutObject.Breakpoints(ii).Value));
            end
        end

        function transferBreakpointDataToBlockEvenSpacing(this,blockPath,lutObject)

            set_param(blockPath,'BreakpointsSpecification','Even spacing');
            for ii=1:this.NumDim
                dataTypeContainer=parseDataType(lutObject.Breakpoints(ii).DataType);
                dataType=dataTypeContainer.ResolvedType;
                if dataType.isscalingslopebias
                    set_param(blockPath,['BreakpointsForDimension',num2str(ii,'%g'),'FirstPoint'],this.stringOfCastedValue(lutObject.Breakpoints(ii).FirstPoint,dataType));
                    spacingType=dataType;
                    spacingType.Bias=0;
                    set_param(blockPath,['BreakpointsForDimension',num2str(ii,'%g'),'Spacing'],this.stringOfCastedValue(lutObject.Breakpoints(ii).Spacing,spacingType));
                else
                    set_param(blockPath,['BreakpointsForDimension',num2str(ii,'%g'),'FirstPoint'],this.stringOfCastedValue(lutObject.Breakpoints(ii).FirstPoint,dataType));
                    set_param(blockPath,['BreakpointsForDimension',num2str(ii,'%g'),'Spacing'],this.stringOfCastedValue(lutObject.Breakpoints(ii).Spacing,dataType));
                end
            end
        end

        function transferDesignRanges(this,blockPath,lutObject)



            set_param(blockPath,'TableMin',this.stringOfScalarValue(lutObject.Table.Min));
            set_param(blockPath,'TableMax',this.stringOfScalarValue(lutObject.Table.Max));
            set_param(blockPath,'OutMin',this.stringOfScalarValue(lutObject.Table.Min));
            set_param(blockPath,'OutMax',this.stringOfScalarValue(lutObject.Table.Max));
            for ii=1:this.NumDim
                set_param(blockPath,['BreakpointsForDimension',num2str(ii,'%g'),'Min'],this.stringOfScalarValue(lutObject.Breakpoints(ii).Min));
                set_param(blockPath,['BreakpointsForDimension',num2str(ii,'%g'),'Max'],this.stringOfScalarValue(lutObject.Breakpoints(ii).Max));
            end
        end

        function transferStorageDataTypes(this,blockPath,lutObject)




            parsedContainer=FunctionApproximation.internal.Utils.dataTypeParser(lutObject.Table.DataType);
            if parsedContainer.isInherited
                set_param(blockPath,'TableDataTypeStr','Inherit: Inherit from ''Table data''');
            else
                set_param(blockPath,'TableDataTypeStr',lutObject.Table.DataType);
            end

            for ii=1:this.NumDim
                propertyName=['BreakpointsForDimension',num2str(ii,'%g'),'DataTypeStr'];
                parsedContainer=FunctionApproximation.internal.Utils.dataTypeParser(lutObject.Breakpoints(ii).DataType);
                if parsedContainer.isInherited
                    set_param(blockPath,propertyName,'Inherit: Inherit from ''Breakpoint data''');
                else
                    set_param(blockPath,propertyName,lutObject.Breakpoints(ii).DataType);
                end
            end
        end
    end

    methods(Static)
        function stringValue=stringOfScalarValue(value)
            stringValue=fixed.internal.compactButAccurateMat2Str(value);
        end

        function stringValue=stringOfCastedValue(value,dataType)
            valueContainer=fixed.internal.math.castUniversal(value,dataType);
            if fixed.internal.type.isAnyFloat(valueContainer)||~isfi(valueContainer)
                stringValue=fixed.internal.compactButAccurateMat2Str(valueContainer);
            else
                stringValue=valueContainer.Value;
            end
        end
    end
end
