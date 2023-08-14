classdef LUTDBUnitLosslessDataTypeConverter<FunctionApproximation.internal.losslessdatatypeconverter.LosslessDataTypeConverter







    methods
        function[addUnit,newDBUnit]=convert(this,dbUnit,options)
            storageTypes=dbUnit.SerializeableData.StorageTypes;
            interfaceTypes=[dbUnit.SerializeableData.InputTypes,dbUnit.SerializeableData.OutputType];
            useHalf=FunctionApproximation.internal.useHalfAsStorageType([interfaceTypes,storageTypes]);
            newTypes=getNewStorageTypes(this,storageTypes,dbUnit,options,useHalf);



            if useHalf&&~FunctionApproximation.internal.useHalfAsStorageType(newTypes)
                newTypes=adjustTypesForHalf(this,storageTypes,dbUnit,options,useHalf);
            end
            newWLs=arrayfun(@(x)x.WordLength,newTypes);
            addUnit=any(newWLs-dbUnit.StorageWordLengths<0);
            newDBUnit=dbUnit;
            if addUnit

                serializableData=dbUnit.SerializeableData;
                serializableData.StorageTypes=newTypes;
                serializableData.ExtrapolationMethod='Clip';
                compressedMemoryBits=serializableData.MemoryUsage.getBits();
                newDBUnit.ConstraintValue(2)=compressedMemoryBits;
                newDBUnit.ObjectiveValue=compressedMemoryBits;
                newDBUnit.StorageTypes=newTypes;
                newDBUnit.SerializeableData=serializableData;
            end
        end
    end

    methods(Hidden)
        function newTypes=getNewStorageTypes(~,storageTypes,dbUnit,options,useHalf)
            nDim=dbUnit.SerializeableData.NumberOfDimensions;
            newTypes=storageTypes;
            [~,indicesWithoutConstraints]=FunctionApproximation.internal.solvers.getIndicesForWLConstraints(nDim,options);

            for ii=indicesWithoutConstraints
                storageType=storageTypes(ii);
                values=dbUnit.SerializeableData.Data{ii};
                if isEvenSpacing(dbUnit.SerializeableData.Spacing)&&(ii<nDim+1)







                    bpData=dbUnit.SerializeableData.Data{ii};
                    spacingValue=bpData(2)-bpData(1);
                    if spacingValue>values(end)
                        values=[values,spacingValue];%#ok<AGROW>
                    end
                end
                quantizedValues=double(fixed.internal.math.castUniversal(values,storageType));
                maxWL=max(storageType.WordLength,max(options.WordLengths));
                [isValid,snappedWL,snappedType]=FunctionApproximation.internal.getWlUsingTightDataType(quantizedValues,maxWL,options,useHalf);
                if isValid
                    newTypes(ii)=snappedType;
                    if~fixed.internal.type.isAnyFloat(newTypes(ii))
                        newTypes(ii).WordLength=snappedWL;
                    end
                end
            end
        end

        function newTypes=adjustTypesForHalf(this,storageTypes,dbUnit,options,useHalf)







            newTypesAllFixed=storageTypes;
            if options.ExploreFixedPoint
                tmpOptions=options;
                tmpOptions.ExploreFloatingPoint=false;
                newTypesAllFixed=getNewStorageTypes(this,storageTypes,dbUnit,tmpOptions,useHalf);
            end

            newTypesAllFloat=storageTypes;
            if options.ExploreFloatingPoint
                tmpOptions=options;
                tmpOptions.ExploreFixedPoint=false;
                newTypesAllFloat=getNewStorageTypes(this,storageTypes,dbUnit,tmpOptions,useHalf);
            end


            wlsAllFixed=arrayfun(@(x)x.WordLength,newTypesAllFixed);
            memoryAllFixed=FunctionApproximation.internal.getLUTDataMemoryUsage(dbUnit.BreakpointSpecification,dbUnit.GridSize,wlsAllFixed(1:end-1),wlsAllFixed(end));
            wlsAllFloat=arrayfun(@(x)x.WordLength,newTypesAllFloat);
            memoryAllFloat=FunctionApproximation.internal.getLUTDataMemoryUsage(dbUnit.BreakpointSpecification,dbUnit.GridSize,wlsAllFloat(1:end-1),wlsAllFloat(end));
            if memoryAllFloat<memoryAllFixed
                newTypes=newTypesAllFloat;
            else
                newTypes=newTypesAllFixed;
            end
        end
    end
end


