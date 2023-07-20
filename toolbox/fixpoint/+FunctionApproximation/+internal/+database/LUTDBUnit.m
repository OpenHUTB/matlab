classdef(AllowedSubclasses=?FunctionApproximation.internal.database.DirectLUDBUnit)LUTDBUnit<FunctionApproximation.internal.database.DBUnit





    properties
        ConstraintAt(1,:)double
        BreakpointSpecification FunctionApproximation.BreakpointSpecification
        Grid FunctionApproximation.internal.Grid
        GridSize(1,:)double
        StorageTypes(1,:)
        SerializeableData FunctionApproximation.internal.serializabledata.SerializableData
        TableValuesOptimized(1,1)logical=0
    end

    properties(SetAccess=private)
        StorageWordLengths(1,:)double
    end

    methods
        function gridFound=findGrid(this,gridSize)

            gridFound=all(this.GridSize==gridSize);
        end

        function this=set.StorageTypes(this,types)
            this.StorageTypes=types;
            nTypes=numel(this.StorageTypes);
            wls=zeros(1,nTypes);
            for iType=1:nTypes
                wls(iType)=this.StorageTypes(iType).WordLength;
            end
            this.StorageWordLengths=wls;%#ok<MCSUP>
        end

        function stringValue=tostring(this,options)
            gridSizeString=mat2str(this.GridSize);
            breakpointWLs=mat2str(this.StorageWordLengths(1:end-1));
            tableDataWLs=num2str(this.StorageWordLengths(end),'%.0f');
            stringValue=sprintf(...
            getFormatSpec(this),...
            num2str(this.ID,'%.0f'),...
            num2str(getObjectiveValue(this,options),getMemoryFormatSpec(this,options)),...
            num2str(this.ConstraintMet,'%.0f'),...
            gridSizeString,...
            breakpointWLs,...
            tableDataWLs,...
            this.BreakpointSpecification,...
            sprintf('%.6e, %.6e',this.ConstraintValueMustBeLessThan(1),this.ConstraintValue(1)));
        end

        function header=getHeader(this,options)
            header=sprintf(getFormatSpec(this),'ID',getMemoryHeader(this,options),'Feasible','Table Size','Breakpoints WLs','TableData WL','BreakpointSpecification','Error(Max,Current)');
        end

        function tableFormatSpec=getFormatSpec(~)
            tableFormatSpec='| %+3s | %+14s | %+8s | %+10s | %+15s | %+12s | %+23s | %+30s |';
        end

        function hexString=getHexString(this,type)




            if type==FunctionApproximation.internal.database.HexType.Partial
                constraintMetString='missing';
                tableValues='missing';
            else
                constraintMetString=num2str(this.IndividualConstraintMet);
                tableValues=num2str(this.SerializeableData.Data{end}(:)');
            end

            gridSizeString=num2str(this.GridSize);
            vWLs=num2str(this.StorageWordLengths);
            nD=numel(this.Grid.SingleDimensionDomains);
            gridValuesStrings=cell(1,nD);
            for iDim=1:nD


                if isEvenSpacing(this.BreakpointSpecification)
                    firstPoint=this.Grid.SingleDimensionDomains{iDim}(1);
                    spacing=diff(this.Grid.SingleDimensionDomains{iDim}(1:2));
                    lastPoint=this.Grid.SingleDimensionDomains{iDim}(end);
                    gridValuesStrings{iDim}=num2str([firstPoint,spacing,lastPoint]);
                else
                    gridValuesStrings{iDim}=num2str(reshape(this.Grid.SingleDimensionDomains{iDim},1,[]));
                end
            end
            gridValuesString=[gridValuesStrings{:}];
            objectiveStr=num2str(this.ObjectiveValue,'%.0f');
            bpSpecStr=char(this.BreakpointSpecification);
            stringValue=[...
            objectiveStr,' ',...
            gridSizeString,' ',...
            vWLs,' ',...
            bpSpecStr,' ',...
            gridValuesString,' ',...
            constraintMetString,' ',...
            tableValues];
            hexString=fixed.internal.utility.shaHex(stringValue);
        end

        function memoryString=getMemoryHeader(~,options)
            memoryString=sprintf('Memory (%s)',char(options.MemoryUnits));
        end

        function formatSpec=getMemoryFormatSpec(~,options)
            if options.MemoryUnits=="bits"
                formatSpec='%.0f';
            else
                formatSpec='%.4e';
            end
        end

        function objectiveValue=getObjectiveValue(this,options)
            conversionFactor=FunctionApproximation.internal.MemoryUnit.getConversionFactor(...
            FunctionApproximation.internal.MemoryUnit.bits,...
            options.MemoryUnits);
            objectiveValue=this.ObjectiveValue*conversionFactor;
        end
    end
end


