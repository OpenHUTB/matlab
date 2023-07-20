function SystemInfo=dpigenerator_MATLAB_getFlattenedPortInfo(codeInfoPorts,codeInfoPortsImpl,StructInfoMap,PortInfoMap,FirstTimeCall,PortDirection,SystemInfo)

    persistent PortPosition;
    if isempty(PortPosition)
        PortPosition=1;
    end


    for idx=1:numel(codeInfoPorts)
        PortInfo=codeInfoPorts(idx);
        PortImplInfo='';


        if FirstTimeCall



            if~isempty(PortInfo.Implementation)
                PortImplInfo=PortInfo.Implementation;
            end
            n_InitializePortMapForTheFirstTime();
        else



            if idx<=numel(codeInfoPortsImpl)
                PortImplInfo=codeInfoPortsImpl(idx);
            end
            n_InitializePortMapForNestedData();
        end
    end

    function n_InitializePortMapForTheFirstTime()


        SystemInfo=l_Check_For_Unsupported_MATLAB_CoderFeatures(PortInfo,PortImplInfo,true,SystemInfo,PortDirection);

        if PortInfo.Type.isMatrix&&...
            (isa(PortImplInfo,'RTW.TypedCollection')...
            ||startsWith(PortImplInfo.Type.Identifier,SystemInfo.VarSizeInfo.emxArrPrefix)&&l_getScalarDim(PortInfo.Type.Dimensions)==Inf)
            if PortInfo.Type.BaseType.isStructure...
                &&~contains(PortInfo.Type.BaseType.Identifier,'int')
                throw(MException(message('HDLLink:DPIG:VariableSizedArrOfStructs',PortInfo.GraphicalName)));
            elseif PortInfo.Type.BaseType.isComplex

                if isa(PortImplInfo,'RTW.TypedCollection')
                    l_getStructInfo(StructInfoMap,PortInfo,true,PortInfo.Type.Dimensions,PortImplInfo.Elements(1).Type.BaseType.Identifier,~PortImplInfo.Elements(1).Type.ColumnMajor,SystemInfo);
                    structInfo(1).DataType=PortImplInfo.Elements(1).Type.BaseType.BaseType.Identifier;
                    structInfo(2).DataType=PortImplInfo.Elements(1).Type.BaseType.BaseType.Identifier;
                    structInfo(1).CPortNames={PortInfo.Implementation.Elements(1).Identifier,PortInfo.Implementation.Elements(2).Identifier};
                    structInfo(2).CPortNames={PortInfo.Implementation.Elements(1).Identifier,PortInfo.Implementation.Elements(2).Identifier};
                    structInfo(1).VarSizeType='upperBoundedArray';
                    structInfo(2).VarSizeType='upperBoundedArray';
                else
                    l_getStructInfo(StructInfoMap,PortInfo,true,PortInfo.Type.Dimensions,PortImplInfo.Type.Elements(1).Type.BaseType.Identifier,~PortInfo.Type.ColumnMajor,SystemInfo);
                    structInfo(1).DataType=PortInfo.Type.BaseType.BaseType.Identifier;
                    structInfo(2).DataType=PortInfo.Type.BaseType.BaseType.Identifier;
                    structInfo(1).EmxDataType=PortImplInfo.Type.Identifier;
                    structInfo(2).EmxDataType=PortImplInfo.Type.Identifier;
                    structInfo(1).VarSizeType='emxArray';
                    structInfo(2).VarSizeType='emxArray';
                end


                structInfo(1).Name='re';
                structInfo(2).Name='im';
                structInfo(1).NativeMATLABName=PortInfo.GraphicalName;
                structInfo(2).NativeMATLABName=PortInfo.GraphicalName;
                structInfo(1).MultiRateCounter='';
                structInfo(2).MultiRateCounter='';
                structInfo(1).StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo(1).Name);
                structInfo(2).StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo(2).Name);
                structInfo(1).IsMultirate=false;
                structInfo(2).IsMultirate=false;
                structInfo(1).IsComplex=true;
                structInfo(2).IsComplex=true;
                structInfo(1).IsEnum=false;
                structInfo(2).IsEnum=false;
                structInfo(1).IsVarSize=true;
                structInfo(2).IsVarSize=true;
                structInfo(1).EnumInfo=[];
                structInfo(2).EnumInfo=[];




                structInfo(1).Dim=1;
                structInfo(2).Dim=1;
                structInfo(1).RowMajor=false;
                structInfo(2).RowMajor=false;
                structInfo(1).DataTypeSize=PortInfo.Type.BaseType.BaseType.WordLength;
                structInfo(2).DataTypeSize=PortInfo.Type.BaseType.BaseType.WordLength;
                IsNonFloating=~(PortInfo.Type.BaseType.BaseType.isDouble||PortInfo.Type.BaseType.BaseType.isSingle||PortInfo.Type.BaseType.BaseType.isHalf);
                p=MATLAB_DPICGen.DPICGenInst;
                if strcmpi(p.PortsDataType,'BitVector')&&IsNonFloating
                    structInfo(1).DPIPortsDataType='BitVector';
                    structInfo(2).DPIPortsDataType='BitVector';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,structInfo(1).DataTypeSize,structInfo(1).DataType,structInfo(1).Dim,structInfo.IsVarSize);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,structInfo(2).DataTypeSize,structInfo(2).DataType,structInfo(2).Dim,structInfo.IsVarSize);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(1).Name,'_bit']);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(2).Name,'_bit']);
                    structInfo(1).DPI_C_InterfaceDataType='svBitVecVal';
                    structInfo(2).DPI_C_InterfaceDataType='svBitVecVal';
                elseif strcmpi(p.PortsDataType,'LogicVector')&&IsNonFloating
                    structInfo(1).DPIPortsDataType='LogicVector';
                    structInfo(2).DPIPortsDataType='LogicVector';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,structInfo(1).DataTypeSize,structInfo(1).DataType,structInfo(1).Dim,structInfo.IsVarSize);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,structInfo(2).DataTypeSize,structInfo(2).DataType,structInfo(2).Dim,structInfo.IsVarSize);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(1).Name,'_logic']);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(2).Name,'_logic']);
                    structInfo(1).DPI_C_InterfaceDataType='svLogicVecVal';
                    structInfo(2).DPI_C_InterfaceDataType='svLogicVecVal';
                else
                    structInfo(1).DPIPortsDataType='CompatibleCType';
                    structInfo(2).DPIPortsDataType='CompatibleCType';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,nan,'',nan);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,nan,'',nan);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,structInfo(1).Name);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,structInfo(2).Name);
                    structInfo(1).DPI_C_InterfaceDataType=structInfo(1).DataType;
                    structInfo(2).DPI_C_InterfaceDataType=structInfo(2).DataType;
                end

                structInfo(1).PortPosition=PortPosition;
                PortPosition=PortPosition+1;
                structInfo(2).PortPosition=PortPosition;
                PortPosition=PortPosition+1;
                if structInfo(1).IsEnum
                    structInfo(1).SVDataType=structInfo(1).EnumInfo.EnumType;
                    structInfo(2).SVDataType=structInfo(2).EnumInfo.EnumType;
                else
                    structInfo(1).SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo(1).DataType,structInfo(1).DataTypeSize,structInfo(1).DPIPortsDataType);
                    structInfo(2).SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo(2).DataType,structInfo(2).DataTypeSize,structInfo(2).DPIPortsDataType);
                end
                structInfo(1).Direction=PortDirection;
                structInfo(2).Direction=PortDirection;

                l_DataTypeErrorHandling(structInfo(1));
                structInfo(1).MLType=flip(strtok(flip(PortInfo.Type.Name),'_'));
                structInfo(2).MLType=structInfo(1).MLType;


                structInfo(1).NumOfDim=numel(PortInfo.Type.Dimensions);
                structInfo(2).NumOfDim=numel(PortInfo.Type.Dimensions);
                if isscalar(PortInfo.Type.Dimensions)
                    structInfo(1).MLMatrixSize=[PortInfo.Type.Dimensions,1];
                    structInfo(2).MLMatrixSize=[PortInfo.Type.Dimensions,1];
                else
                    structInfo(1).MLMatrixSize=PortInfo.Type.Dimensions;
                    structInfo(2).MLMatrixSize=PortInfo.Type.Dimensions;
                end

                PortInfoMap(structInfo(1).FlatName)=structInfo(1);
                PortInfoMap(structInfo(2).FlatName)=structInfo(2);


                l_CleanOneLayerOfStructInfoMap(StructInfoMap);
                return;
            else
                if isa(PortImplInfo,'RTW.TypedCollection')
                    structInfo.Name=PortInfo.Implementation.Elements(1).Identifier(1:end-5);
                    structInfo.CPortNames={PortInfo.Implementation.Elements(1).Identifier,PortInfo.Implementation.Elements(2).Identifier};


                    StructInfoMap('VariableNameDataSet')=[StructInfoMap('VariableNameDataSet'),structInfo.CPortNames];
                    structInfo.DataType=PortInfo.Type.BaseType.Identifier;
                    structInfo.VarSizeType='upperBoundedArray';
                else
                    structInfo.Name=PortInfo.Implementation.Identifier;
                    structInfo.DataType=PortInfo.Type.BaseType.Identifier;
                    structInfo.EmxDataType=PortImplInfo.Type.Identifier;
                    structInfo.VarSizeType='emxArray';
                end
                structInfo.NativeMATLABName=PortInfo.GraphicalName;
                structInfo.MultiRateCounter='';
                structInfo.StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo.Name);


                structInfo.IsMultirate=false;
                structInfo.IsComplex=false;
                structInfo.Dim=l_getScalarDim(PortInfo.Type.Dimensions);


                structInfo.NumOfDim=numel(PortInfo.Type.Dimensions);
                structInfo.RowMajor=~PortInfo.Type.ColumnMajor;
                if PortInfo.Type.BaseType.isEnum
                    if isempty(PortInfo.Type.BaseType.StorageType)
                        structInfo.DataTypeSize=32;
                        Signedness=any(PortInfo.Type.BaseType.Values<0);
                    else
                        structInfo.DataTypeSize=PortInfo.Type.BaseType.StorageType.WordLength;
                        Signedness=PortInfo.Type.BaseType.StorageType.Signedness;
                    end

                    structInfo.DataType=l_getEnumUnderlyingType(structInfo.DataTypeSize,'C',Signedness);
                    structInfo.IsEnum=true;
                    structInfo.EnumInfo=struct('EnumType',PortInfo.Type.BaseType.Identifier,...
                    'EnumUnderlyingType',l_getEnumUnderlyingType(structInfo.DataTypeSize,'SV',Signedness),...
                    'EnumStrVals',{PortInfo.Type.BaseType.Strings'},...
                    'EnumIntVals',PortInfo.Type.BaseType.Values);
                    IsNonFloating=false;
                else
                    structInfo.DataTypeSize=PortInfo.Type.BaseType.WordLength;
                    IsNonFloating=~(PortInfo.Type.BaseType.isDouble||PortInfo.Type.BaseType.isSingle||PortInfo.Type.BaseType.isHalf);
                    structInfo.IsEnum=false;
                    structInfo.EnumInfo=[];
                end
                structInfo.IsVarSize=true;





                structInfo.PortPosition=PortPosition;
                PortPosition=PortPosition+1;
            end

        elseif PortInfo.Implementation.Type.isMatrix


            if PortInfo.Implementation.Type.BaseType.isStructure...
                &&~contains(PortInfo.Implementation.Type.BaseType.Identifier,'int')




                l_getStructInfo(StructInfoMap,PortInfo,true,PortInfo.Type.Dimensions,PortInfo.Implementation.Type.BaseType.Identifier,~PortInfo.Implementation.Type.ColumnMajor);

                SystemInfo=dpigenerator_MATLAB_getFlattenedPortInfo(PortInfo.Type.BaseType.Elements,PortImplInfo.Type.BaseType.Elements,StructInfoMap,PortInfoMap,false,PortDirection,SystemInfo);


                l_CleanOneLayerOfStructInfoMap(StructInfoMap);

                return;

            elseif PortInfo.Implementation.Type.BaseType.isComplex

                l_getStructInfo(StructInfoMap,PortInfo,true,PortInfo.Type.Dimensions,PortInfo.Implementation.Type.BaseType.Identifier,~PortInfo.Implementation.Type.ColumnMajor);


                structInfo(1).Name='re';
                structInfo(2).Name='im';
                structInfo(1).NativeMATLABName=PortInfo.GraphicalName;
                structInfo(2).NativeMATLABName=PortInfo.GraphicalName;
                structInfo(1).MultiRateCounter='';
                structInfo(2).MultiRateCounter='';
                structInfo(1).DataType=PortInfo.Implementation.Type.BaseType.BaseType.Identifier;
                structInfo(2).DataType=PortInfo.Implementation.Type.BaseType.BaseType.Identifier;
                structInfo(1).StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo(1).Name);
                structInfo(2).StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo(2).Name);
                structInfo(1).IsMultirate=false;
                structInfo(2).IsMultirate=false;
                structInfo(1).IsComplex=true;
                structInfo(2).IsComplex=true;
                structInfo(1).IsEnum=false;
                structInfo(2).IsEnum=false;
                structInfo(1).IsVarSize=false;
                structInfo(2).IsVarSize=false;
                structInfo(1).EnumInfo=[];
                structInfo(2).EnumInfo=[];




                structInfo(1).Dim=1;
                structInfo(2).Dim=1;
                structInfo(1).RowMajor=false;
                structInfo(2).RowMajor=false;
                structInfo(1).DataTypeSize=PortInfo.Type.BaseType.BaseType.WordLength;
                structInfo(2).DataTypeSize=PortInfo.Type.BaseType.BaseType.WordLength;
                IsNonFloating=~(PortInfo.Type.BaseType.BaseType.isDouble||PortInfo.Type.BaseType.BaseType.isSingle||PortInfo.Type.BaseType.BaseType.isHalf);
                p=MATLAB_DPICGen.DPICGenInst;
                if strcmpi(p.PortsDataType,'BitVector')&&IsNonFloating
                    structInfo(1).DPIPortsDataType='BitVector';
                    structInfo(2).DPIPortsDataType='BitVector';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,structInfo(1).DataTypeSize,structInfo(1).DataType,structInfo(1).Dim);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,structInfo(2).DataTypeSize,structInfo(2).DataType,structInfo(2).Dim);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(1).Name,'_bit']);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(2).Name,'_bit']);
                    structInfo(1).DPI_C_InterfaceDataType='svBitVecVal';
                    structInfo(2).DPI_C_InterfaceDataType='svBitVecVal';
                elseif strcmpi(p.PortsDataType,'LogicVector')&&IsNonFloating
                    structInfo(1).DPIPortsDataType='LogicVector';
                    structInfo(2).DPIPortsDataType='LogicVector';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,structInfo(1).DataTypeSize,structInfo(1).DataType,structInfo(1).Dim);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,structInfo(2).DataTypeSize,structInfo(2).DataType,structInfo(2).Dim);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(1).Name,'_logic']);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(2).Name,'_logic']);
                    structInfo(1).DPI_C_InterfaceDataType='svLogicVecVal';
                    structInfo(2).DPI_C_InterfaceDataType='svLogicVecVal';
                else
                    structInfo(1).DPIPortsDataType='CompatibleCType';
                    structInfo(2).DPIPortsDataType='CompatibleCType';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,nan,'',nan);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,nan,'',nan);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,structInfo(1).Name);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,structInfo(2).Name);
                    structInfo(1).DPI_C_InterfaceDataType=structInfo(1).DataType;
                    structInfo(2).DPI_C_InterfaceDataType=structInfo(2).DataType;
                end

                structInfo(1).PortPosition=PortPosition;
                PortPosition=PortPosition+1;
                structInfo(2).PortPosition=PortPosition;
                PortPosition=PortPosition+1;
                if structInfo(1).IsEnum
                    structInfo(1).SVDataType=structInfo(1).EnumInfo.EnumType;
                    structInfo(2).SVDataType=structInfo(2).EnumInfo.EnumType;
                else
                    structInfo(1).SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo(1).DataType,structInfo(1).DataTypeSize,structInfo(1).DPIPortsDataType);
                    structInfo(2).SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo(2).DataType,structInfo(2).DataTypeSize,structInfo(2).DPIPortsDataType);
                end
                structInfo(1).Direction=PortDirection;
                structInfo(2).Direction=PortDirection;

                l_DataTypeErrorHandling(structInfo(1));
                structInfo(1).MLType=flip(strtok(flip(PortInfo.Type.Name),'_'));
                structInfo(2).MLType=structInfo(1).MLType;
                if isscalar(PortInfo.Type.Dimensions)
                    structInfo(1).MLMatrixSize=[PortInfo.Type.Dimensions,1];
                    structInfo(2).MLMatrixSize=[PortInfo.Type.Dimensions,1];
                else
                    structInfo(1).MLMatrixSize=PortInfo.Type.Dimensions;
                    structInfo(2).MLMatrixSize=PortInfo.Type.Dimensions;
                end

                PortInfoMap(structInfo(1).FlatName)=structInfo(1);
                PortInfoMap(structInfo(2).FlatName)=structInfo(2);


                l_CleanOneLayerOfStructInfoMap(StructInfoMap);
                return;
            else
                structInfo.Name=PortInfo.Implementation.Identifier;
                structInfo.NativeMATLABName=PortInfo.GraphicalName;

                structInfo.MultiRateCounter='';
                structInfo.DataType=PortInfo.Implementation.Type.BaseType.Identifier;
                structInfo.StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo.Name);


                structInfo.IsMultirate=false;
                structInfo.IsComplex=false;
                structInfo.IsVarSize=false;
                structInfo.Dim=l_getScalarDim(PortInfo.Implementation.Type.Dimensions);
                structInfo.RowMajor=~PortInfo.Implementation.Type.ColumnMajor;
                if PortInfo.Type.BaseType.isEnum
                    if isempty(PortInfo.Type.BaseType.StorageType)
                        structInfo.DataTypeSize=32;
                        Signedness=any(PortInfo.Type.BaseType.Values<0);
                    else
                        structInfo.DataTypeSize=PortInfo.Implementation.Type.BaseType.WordLength;
                        Signedness=PortInfo.Type.BaseType.StorageType.Signedness;
                    end

                    structInfo.DataType=l_getEnumUnderlyingType(structInfo.DataTypeSize,'C',Signedness);
                    structInfo.IsEnum=true;
                    structInfo.EnumInfo=struct('EnumType',PortInfo.Type.BaseType.Identifier,...
                    'EnumUnderlyingType',l_getEnumUnderlyingType(structInfo.DataTypeSize,'SV',Signedness),...
                    'EnumStrVals',{PortInfo.Type.BaseType.Strings'},...
                    'EnumIntVals',PortInfo.Type.BaseType.Values);
                    IsNonFloating=false;
                else
                    structInfo.DataTypeSize=PortInfo.Type.BaseType.WordLength;
                    IsNonFloating=~(PortInfo.Type.BaseType.isDouble||PortInfo.Type.BaseType.isSingle||PortInfo.Type.BaseType.isHalf);
                    structInfo.IsEnum=false;
                    structInfo.EnumInfo=[];
                end





                structInfo.PortPosition=PortPosition;
                PortPosition=PortPosition+1;
            end
        else


            if PortInfo.Implementation.Type.isStructure&&~contains(PortInfo.Implementation.Type.Identifier,'int')




                l_getStructInfo(StructInfoMap,PortInfo,true,1,PortInfo.Implementation.Type.Identifier,false);

                SystemInfo=dpigenerator_MATLAB_getFlattenedPortInfo(PortInfo.Type.Elements,PortImplInfo.Type.Elements,StructInfoMap,PortInfoMap,false,PortDirection,SystemInfo);


                l_CleanOneLayerOfStructInfoMap(StructInfoMap);

                return;

            elseif PortInfo.Implementation.Type.isComplex

                l_getStructInfo(StructInfoMap,PortInfo,true,1,PortInfo.Implementation.Type.Identifier,false);


                structInfo(1).Name='re';
                structInfo(2).Name='im';
                structInfo(1).NativeMATLABName=PortInfo.GraphicalName;
                structInfo(2).NativeMATLABName=PortInfo.GraphicalName;
                structInfo(1).MultiRateCounter='';
                structInfo(2).MultiRateCounter='';
                structInfo(1).DataType=PortInfo.Implementation.Type.BaseType.Identifier;
                structInfo(2).DataType=PortInfo.Implementation.Type.BaseType.Identifier;
                structInfo(1).StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo(1).Name);
                structInfo(2).StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo(2).Name);
                structInfo(1).IsMultirate=false;
                structInfo(2).IsMultirate=false;
                structInfo(1).IsComplex=true;
                structInfo(2).IsComplex=true;
                structInfo(1).IsEnum=false;
                structInfo(2).IsEnum=false;
                structInfo(1).IsVarSize=false;
                structInfo(2).IsVarSize=false;
                structInfo(1).EnumInfo=[];
                structInfo(2).EnumInfo=[];
                structInfo(1).Dim=1;
                structInfo(2).Dim=1;
                structInfo(1).RowMajor=false;
                structInfo(2).RowMajor=false;
                structInfo(1).DataTypeSize=PortInfo.Type.BaseType.WordLength;
                structInfo(2).DataTypeSize=PortInfo.Type.BaseType.WordLength;
                IsNonFloating=~(PortInfo.Type.BaseType.isDouble||PortInfo.Type.BaseType.isSingle||PortInfo.Type.BaseType.isHalf);
                p=MATLAB_DPICGen.DPICGenInst;
                if strcmpi(p.PortsDataType,'BitVector')&&IsNonFloating
                    structInfo(1).DPIPortsDataType='BitVector';
                    structInfo(2).DPIPortsDataType='BitVector';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,structInfo(1).DataTypeSize,structInfo(1).DataType,structInfo(1).Dim);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,structInfo(2).DataTypeSize,structInfo(2).DataType,structInfo(2).Dim);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(1).Name,'_bit']);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(2).Name,'_bit']);
                    structInfo(1).DPI_C_InterfaceDataType='svBitVecVal';
                    structInfo(2).DPI_C_InterfaceDataType='svBitVecVal';
                elseif strcmpi(p.PortsDataType,'LogicVector')&&IsNonFloating
                    structInfo(1).DPIPortsDataType='LogicVector';
                    structInfo(2).DPIPortsDataType='LogicVector';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,structInfo(1).DataTypeSize,structInfo(1).DataType,structInfo(1).Dim);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,structInfo(2).DataTypeSize,structInfo(2).DataType,structInfo(2).Dim);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(1).Name,'_logic']);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(2).Name,'_logic']);
                    structInfo(1).DPI_C_InterfaceDataType='svLogicVecVal';
                    structInfo(2).DPI_C_InterfaceDataType='svLogicVecVal';
                else
                    structInfo(1).DPIPortsDataType='CompatibleCType';
                    structInfo(2).DPIPortsDataType='CompatibleCType';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,nan,'',nan);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,nan,'',nan);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,structInfo(1).Name);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,structInfo(2).Name);
                    structInfo(1).DPI_C_InterfaceDataType=structInfo(1).DataType;
                    structInfo(2).DPI_C_InterfaceDataType=structInfo(2).DataType;
                end

                structInfo(1).PortPosition=PortPosition;
                PortPosition=PortPosition+1;
                structInfo(2).PortPosition=PortPosition;
                PortPosition=PortPosition+1;
                if structInfo(1).IsEnum
                    structInfo(1).SVDataType=structInfo(1).EnumInfo.EnumType;
                    structInfo(2).SVDataType=structInfo(2).EnumInfo.EnumType;
                else
                    structInfo(1).SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo(1).DataType,structInfo(1).DataTypeSize,structInfo(1).DPIPortsDataType);
                    structInfo(2).SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo(2).DataType,structInfo(2).DataTypeSize,structInfo(2).DPIPortsDataType);
                end
                structInfo(1).Direction=PortDirection;
                structInfo(2).Direction=PortDirection;

                l_DataTypeErrorHandling(structInfo(1));
                structInfo(1).MLType=flip(strtok(flip(PortInfo.Type.Name),'_'));
                structInfo(2).MLType=structInfo(1).MLType;
                structInfo(1).MLMatrixSize=[1,1];
                structInfo(2).MLMatrixSize=[1,1];

                PortInfoMap(structInfo(1).FlatName)=structInfo(1);
                PortInfoMap(structInfo(2).FlatName)=structInfo(2);


                l_CleanOneLayerOfStructInfoMap(StructInfoMap);
                return;
            else
                structInfo.Name=PortInfo.Implementation.Identifier;
                structInfo.NativeMATLABName=PortInfo.GraphicalName;

                structInfo.MultiRateCounter='';
                structInfo.DataType=PortInfo.Implementation.Type.Identifier;
                structInfo.StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo.Name);


                structInfo.IsMultirate=false;
                structInfo.IsComplex=false;
                structInfo.IsVarSize=false;
                structInfo.Dim=1;
                structInfo.RowMajor=false;
                if PortInfo.Type.isEnum
                    if isempty(PortInfo.Type.StorageType)
                        structInfo.DataTypeSize=32;
                        Signedness=any(PortInfo.Type.Values<0);
                    else
                        structInfo.DataTypeSize=PortInfo.Implementation.Type.WordLength;
                        Signedness=PortInfo.Implementation.Type.Signedness;
                    end
                    structInfo.DataType=l_getEnumUnderlyingType(structInfo.DataTypeSize,'C',Signedness);
                    structInfo.IsEnum=true;
                    structInfo.EnumInfo=struct('EnumType',PortInfo.Type.Identifier,...
                    'EnumUnderlyingType',l_getEnumUnderlyingType(structInfo.DataTypeSize,'SV',Signedness),...
                    'EnumStrVals',{PortInfo.Type.Strings'},...
                    'EnumIntVals',PortInfo.Type.Values);
                    IsNonFloating=false;
                else
                    structInfo.DataTypeSize=PortInfo.Type.WordLength;
                    IsNonFloating=~(PortInfo.Type.isDouble||PortInfo.Type.isSingle||PortInfo.Type.isHalf);
                    structInfo.IsEnum=false;
                    structInfo.EnumInfo=[];
                end






                structInfo.PortPosition=PortPosition;
                PortPosition=PortPosition+1;
            end
        end


        p=MATLAB_DPICGen.DPICGenInst;
        if strcmpi(p.PortsDataType,'BitVector')&&IsNonFloating
            if structInfo.IsVarSize&&strcmpi(structInfo.VarSizeType,'emxArray')

                StructInfoMap('VariableNameDataSet')=[StructInfoMap('VariableNameDataSet'),structInfo.Name];
            end
            structInfo.DPIPortsDataType='BitVector';
            structInfo.DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo.DPIPortsDataType,structInfo.DataTypeSize,structInfo.DataType,structInfo.Dim,structInfo.IsVarSize);
            structInfo.FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo.Name,'_bit']);
            structInfo.DPI_C_InterfaceDataType='svBitVecVal';
        elseif strcmpi(p.PortsDataType,'LogicVector')&&IsNonFloating
            if structInfo.IsVarSize&&strcmpi(structInfo.VarSizeType,'emxArray')

                StructInfoMap('VariableNameDataSet')=[StructInfoMap('VariableNameDataSet'),structInfo.Name];
            end
            structInfo.DPIPortsDataType='LogicVector';
            structInfo.DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo.DPIPortsDataType,structInfo.DataTypeSize,structInfo.DataType,structInfo.Dim,structInfo.IsVarSize);
            structInfo.FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo.Name,'_logic']);
            structInfo.DPI_C_InterfaceDataType='svLogicVecVal';
        else
            structInfo.DPIPortsDataType='CompatibleCType';
            structInfo.DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo.DPIPortsDataType,nan,'',nan);
            structInfo.FlatName=l_getUniqueFlatName(StructInfoMap,structInfo.Name);
            structInfo.DPI_C_InterfaceDataType=structInfo.DataType;
        end

        if structInfo.IsEnum
            structInfo.SVDataType=structInfo.EnumInfo.EnumType;
        else
            structInfo.SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo.DataType,structInfo.DataTypeSize,structInfo.DPIPortsDataType);
        end

        structInfo.Direction=PortDirection;

        l_DataTypeErrorHandling(structInfo);




        if structInfo.Dim>1


            flipName=flip(PortInfo.Type.Name);
            if isempty(regexp(flipName,'(xfni)*','once'))
                startIndex=regexp(flipName,'(x\d)*');
            else
                startIndex=min(regexp(flipName,'(x\d)*'),regexp(flipName,'(xfni)*'));
            end
            structInfo.MLType=flip(flipName(1:startIndex-1));






            if isscalar(PortInfo.Type.Dimensions)
                structInfo.MLMatrixSize=[PortInfo.Type.Dimensions,1];
            else
                structInfo.MLMatrixSize=PortInfo.Type.Dimensions;
            end
        else

            structInfo.MLType=PortInfo.Type.Name;
            structInfo.MLMatrixSize=[1,1];
        end

        PortInfoMap(structInfo.FlatName)=structInfo;
    end

    function n_InitializePortMapForNestedData()

        SystemInfo=l_Check_For_Unsupported_MATLAB_CoderFeatures(PortInfo,PortImplInfo,false,SystemInfo,PortDirection);

        if PortInfo.Type.isMatrix

            if PortInfo.Type.BaseType.isStructure&&~contains(PortInfo.Type.BaseType.Identifier,'int')




                l_getStructInfo(StructInfoMap,PortInfo,false,PortInfo.Type.Dimensions,PortInfo.Type.BaseType.Identifier,~PortInfo.Type.ColumnMajor);

                SystemInfo=dpigenerator_MATLAB_getFlattenedPortInfo(PortInfo.Type.BaseType.Elements,PortImplInfo.Type.BaseType.Elements,StructInfoMap,PortInfoMap,false,PortDirection,SystemInfo);


                l_CleanOneLayerOfStructInfoMap(StructInfoMap);

                return;

            elseif PortInfo.Type.BaseType.isComplex

                l_getStructInfo(StructInfoMap,PortInfo,false,PortInfo.Type.Dimensions,PortInfo.Type.BaseType.BaseType.Identifier,~PortInfo.Type.ColumnMajor);


                structInfo(1).Name='re';
                structInfo(2).Name='im';
                structInfo(1).NativeMATLABName='re';
                structInfo(2).NativeMATLABName='im';

                structInfo(1).MultiRateCounter='';
                structInfo(2).MultiRateCounter='';
                structInfo(1).DataType=PortInfo.Type.BaseType.BaseType.Identifier;
                structInfo(2).DataType=PortInfo.Type.BaseType.BaseType.Identifier;
                structInfo(1).StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo(1).Name);
                structInfo(2).StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo(2).Name);
                structInfo(1).IsMultirate=false;
                structInfo(2).IsMultirate=false;
                structInfo(1).IsComplex=true;
                structInfo(2).IsComplex=true;
                structInfo(1).IsVarSize=false;
                structInfo(2).IsVarSize=false;
                structInfo(1).IsEnum=false;
                structInfo(2).IsEnum=false;
                structInfo(1).EnumInfo=[];
                structInfo(2).EnumInfo=[];




                structInfo(1).Dim=1;
                structInfo(2).Dim=1;
                structInfo(1).RowMajor=false;
                structInfo(2).RowMajor=false;
                structInfo(1).DataTypeSize=PortInfo.Type.BaseType.BaseType.WordLength;
                structInfo(2).DataTypeSize=PortInfo.Type.BaseType.BaseType.WordLength;
                IsNonFloating=~(PortInfo.Type.BaseType.BaseType.isDouble||PortInfo.Type.BaseType.BaseType.isSingle||PortInfo.Type.BaseType.BaseType.isHalf);
                p=MATLAB_DPICGen.DPICGenInst;
                if strcmpi(p.PortsDataType,'BitVector')&&IsNonFloating
                    structInfo(1).DPIPortsDataType='BitVector';
                    structInfo(2).DPIPortsDataType='BitVector';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,structInfo(1).DataTypeSize,structInfo(1).DataType,structInfo(1).Dim);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,structInfo(2).DataTypeSize,structInfo(2).DataType,structInfo(2).Dim);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(1).Name,'_bit']);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(2).Name,'_bit']);
                    structInfo(1).DPI_C_InterfaceDataType='svBitVecVal';
                    structInfo(2).DPI_C_InterfaceDataType='svBitVecVal';
                elseif strcmpi(p.PortsDataType,'LogicVector')&&IsNonFloating
                    structInfo(1).DPIPortsDataType='LogicVector';
                    structInfo(2).DPIPortsDataType='LogicVector';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,structInfo(1).DataTypeSize,structInfo(1).DataType,structInfo(1).Dim);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,structInfo(2).DataTypeSize,structInfo(2).DataType,structInfo(2).Dim);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(1).Name,'_logic']);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(2).Name,'_logic']);
                    structInfo(1).DPI_C_InterfaceDataType='svLogicVecVal';
                    structInfo(2).DPI_C_InterfaceDataType='svLogicVecVal';
                else
                    structInfo(1).DPIPortsDataType='CompatibleCType';
                    structInfo(2).DPIPortsDataType='CompatibleCType';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,nan,'',nan);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,nan,'',nan);

                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,structInfo(1).Name);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,structInfo(2).Name);
                    structInfo(1).DPI_C_InterfaceDataType=structInfo(1).DataType;
                    structInfo(2).DPI_C_InterfaceDataType=structInfo(2).DataType;
                end



                structInfo(1).PortPosition=PortPosition;
                PortPosition=PortPosition+1;
                structInfo(2).PortPosition=PortPosition;
                PortPosition=PortPosition+1;
                if structInfo(1).IsEnum
                    structInfo(1).SVDataType=structInfo(1).EnumInfo.EnumType;
                    structInfo(2).SVDataType=structInfo(2).EnumInfo.EnumType;
                else
                    structInfo(1).SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo(1).DataType,structInfo(1).DataTypeSize,structInfo(1).DPIPortsDataType);
                    structInfo(2).SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo(2).DataType,structInfo(2).DataTypeSize,structInfo(2).DPIPortsDataType);
                end

                structInfo(1).Direction=PortDirection;
                structInfo(2).Direction=PortDirection;

                l_DataTypeErrorHandling(structInfo(1));
                structInfo(1).MLType=flip(strtok(flip(PortInfo.Type.Name),'_'));
                structInfo(2).MLType=structInfo(1).MLType;
                if isscalar(PortInfo.Type.Dimensions)
                    structInfo(1).MLMatrixSize=[PortInfo.Type.Dimensions,1];
                    structInfo(2).MLMatrixSize=[PortInfo.Type.Dimensions,1];
                else
                    structInfo(1).MLMatrixSize=PortInfo.Type.Dimensions;
                    structInfo(2).MLMatrixSize=PortInfo.Type.Dimensions;
                end

                PortInfoMap(structInfo(1).FlatName)=structInfo(1);
                PortInfoMap(structInfo(2).FlatName)=structInfo(2);


                l_CleanOneLayerOfStructInfoMap(StructInfoMap);
                return;
            else
                structInfo.Name=PortInfo.Identifier;
                structInfo.NativeMATLABName=PortInfo.Identifier;
                structInfo.MultiRateCounter='';
                structInfo.DataType=PortInfo.Type.BaseType.Identifier;
                structInfo.StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo.Name);


                structInfo.IsMultirate=false;
                structInfo.IsComplex=false;
                structInfo.IsEnum=false;
                structInfo.IsVarSize=false;
                structInfo.EnumInfo=[];
                structInfo.Dim=l_getScalarDim(PortInfo.Type.Dimensions);
                structInfo.RowMajor=~PortInfo.Type.ColumnMajor;
                structInfo.DataTypeSize=PortInfo.Type.BaseType.WordLength;
                IsNonFloating=~(PortInfo.Type.BaseType.isDouble||PortInfo.Type.BaseType.isSingle||PortInfo.Type.BaseType.isHalf);




                structInfo.PortPosition=PortPosition;
                PortPosition=PortPosition+1;
            end
        else

            if PortInfo.Type.isStructure&&~contains(PortInfo.Type.Identifier,'int')



                l_getStructInfo(StructInfoMap,PortInfo,false,1,PortInfo.Type.Identifier,false);

                SystemInfo=dpigenerator_MATLAB_getFlattenedPortInfo(PortInfo.Type.Elements,PortImplInfo.Type.Elements,StructInfoMap,PortInfoMap,false,PortDirection,SystemInfo);


                l_CleanOneLayerOfStructInfoMap(StructInfoMap);

                return;

            elseif PortInfo.Type.isComplex

                l_getStructInfo(StructInfoMap,PortInfo,false,1,PortInfo.Type.BaseType.Identifier,false);


                structInfo(1).Name='re';
                structInfo(2).Name='im';
                structInfo(1).NativeMATLABName=PortInfo.Identifier;
                structInfo(2).NativeMATLABName=PortInfo.Identifier;
                structInfo(1).MultiRateCounter='';
                structInfo(2).MultiRateCounter='';
                structInfo(1).DataType=PortInfo.Type.BaseType.Identifier;
                structInfo(2).DataType=PortInfo.Type.BaseType.Identifier;
                structInfo(1).StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo(1).Name);
                structInfo(2).StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo(2).Name);
                structInfo(1).IsMultirate=false;
                structInfo(2).IsMultirate=false;
                structInfo(1).IsComplex=true;
                structInfo(2).IsComplex=true;
                structInfo(1).IsVarSize=false;
                structInfo(2).IsVarSize=false;
                structInfo(1).IsEnum=false;
                structInfo(2).IsEnum=false;

                structInfo(1).EnumInfo=[];
                structInfo(2).EnumInfo=[];
                structInfo(1).Dim=1;
                structInfo(2).Dim=1;
                structInfo(1).RowMajor=false;
                structInfo(2).RowMajor=false;

                structInfo(1).DataTypeSize=PortInfo.Type.BaseType.WordLength;
                structInfo(2).DataTypeSize=PortInfo.Type.BaseType.WordLength;
                IsNonFloating=~(PortInfo.Type.BaseType.isDouble||PortInfo.Type.BaseType.isSingle||PortInfo.Type.BaseType.isHalf);
                p=MATLAB_DPICGen.DPICGenInst;
                if strcmpi(p.PortsDataType,'BitVector')&&IsNonFloating
                    structInfo(1).DPIPortsDataType='BitVector';
                    structInfo(2).DPIPortsDataType='BitVector';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,structInfo(1).DataTypeSize,structInfo(1).DataType,structInfo(1).Dim);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,structInfo(2).DataTypeSize,structInfo(2).DataType,structInfo(2).Dim);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(1).Name,'_bit']);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(2).Name,'_bit']);
                    structInfo(1).DPI_C_InterfaceDataType='svBitVecVal';
                    structInfo(2).DPI_C_InterfaceDataType='svBitVecVal';
                elseif strcmpi(p.PortsDataType,'LogicVector')&&IsNonFloating
                    structInfo(1).DPIPortsDataType='LogicVector';
                    structInfo(2).DPIPortsDataType='LogicVector';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,structInfo(1).DataTypeSize,structInfo(1).DataType,structInfo(1).Dim);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,structInfo(2).DataTypeSize,structInfo(2).DataType,structInfo(2).Dim);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(1).Name,'_logic']);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo(2).Name,'_logic']);
                    structInfo(1).DPI_C_InterfaceDataType='svLogicVecVal';
                    structInfo(2).DPI_C_InterfaceDataType='svLogicVecVal';
                else
                    structInfo(1).DPIPortsDataType='CompatibleCType';
                    structInfo(2).DPIPortsDataType='CompatibleCType';
                    structInfo(1).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(1).DPIPortsDataType,nan,'',nan);
                    structInfo(2).DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo(2).DPIPortsDataType,nan,'',nan);
                    structInfo(1).FlatName=l_getUniqueFlatName(StructInfoMap,structInfo(1).Name);
                    structInfo(2).FlatName=l_getUniqueFlatName(StructInfoMap,structInfo(2).Name);
                    structInfo(1).DPI_C_InterfaceDataType=structInfo(1).DataType;
                    structInfo(2).DPI_C_InterfaceDataType=structInfo(2).DataType;
                end

                structInfo(1).PortPosition=PortPosition;
                PortPosition=PortPosition+1;
                structInfo(2).PortPosition=PortPosition;
                PortPosition=PortPosition+1;
                if structInfo(1).IsEnum
                    structInfo(1).SVDataType=structInfo(1).EnumInfo.EnumType;
                    structInfo(2).SVDataType=structInfo(2).EnumInfo.EnumType;
                else
                    structInfo(1).SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo(1).DataType,structInfo(1).DataTypeSize,structInfo(1).DPIPortsDataType);
                    structInfo(2).SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo(2).DataType,structInfo(2).DataTypeSize,structInfo(2).DPIPortsDataType);
                end

                structInfo(1).Direction=PortDirection;
                structInfo(2).Direction=PortDirection;

                l_DataTypeErrorHandling(structInfo(1));
                structInfo(1).MLType=flip(strtok(flip(PortInfo.Type.Name),'_'));
                structInfo(2).MLType=structInfo(1).MLType;
                structInfo(1).MLMatrixSize=[1,1];
                structInfo(2).MLMatrixSize=[1,1];

                PortInfoMap(structInfo(1).FlatName)=structInfo(1);
                PortInfoMap(structInfo(2).FlatName)=structInfo(2);


                l_CleanOneLayerOfStructInfoMap(StructInfoMap);
                return;
            else
                structInfo.Name=PortInfo.Identifier;
                structInfo.NativeMATLABName=PortInfo.Identifier;
                structInfo.MultiRateCounter='';
                structInfo.DataType=PortInfo.Type.Identifier;
                structInfo.StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,structInfo.Name);
                structInfo.IsMultirate=false;
                structInfo.IsComplex=false;
                structInfo.IsVarSize=false;
                structInfo.IsEnum=false;
                structInfo.EnumInfo=[];
                structInfo.Dim=1;
                structInfo.RowMajor=false;

                structInfo.DataTypeSize=PortInfo.Type.WordLength;
                IsNonFloating=~(PortInfo.Type.isDouble||PortInfo.Type.isSingle||PortInfo.Type.isHalf);




                structInfo.PortPosition=PortPosition;
                PortPosition=PortPosition+1;
            end
        end
        p=MATLAB_DPICGen.DPICGenInst;
        if strcmpi(p.PortsDataType,'BitVector')&&IsNonFloating
            structInfo.DPIPortsDataType='BitVector';
            structInfo.DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo.DPIPortsDataType,structInfo.DataTypeSize,structInfo.DataType,structInfo.Dim);
            structInfo.FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo.Name,'_bit']);
            structInfo.DPI_C_InterfaceDataType='svBitVecVal';
        elseif strcmpi(p.PortsDataType,'LogicVector')&&IsNonFloating
            structInfo.DPIPortsDataType='LogicVector';
            structInfo.DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo.DPIPortsDataType,structInfo.DataTypeSize,structInfo.DataType,structInfo.Dim);
            structInfo.FlatName=l_getUniqueFlatName(StructInfoMap,[structInfo.Name,'_bit']);
            structInfo.DPI_C_InterfaceDataType='svLogicVecVal';
        else
            structInfo.DPIPortsDataType='CompatibleCType';
            structInfo.DPIFixedPointInterfaceMarshallingObj=dpig.internal.DPIFixedPointMarshallingFcn(structInfo.DPIPortsDataType,nan,'',nan);
            structInfo.FlatName=l_getUniqueFlatName(StructInfoMap,structInfo.Name);
            structInfo.DPI_C_InterfaceDataType=structInfo.DataType;
        end

        if structInfo.IsEnum
            structInfo.SVDataType=structInfo.EnumInfo.EnumType;
        else
            structInfo.SVDataType=dpigenerator_MATLAB_getSVDataType(structInfo.DataType,structInfo.DataTypeSize,structInfo.DPIPortsDataType);
        end
        structInfo.Direction=PortDirection;

        l_DataTypeErrorHandling(structInfo);



        if structInfo.Dim>1
            structInfo.MLType=n_getMLDataType(PortInfo.Type.BaseType);






            if isscalar(PortInfo.Type.Dimensions)
                structInfo.MLMatrixSize=[PortInfo.Type.Dimensions,1];
            else
                structInfo.MLMatrixSize=PortInfo.Type.Dimensions;
            end
        else

            structInfo.MLType=n_getMLDataType(PortInfo.Type);
            structInfo.MLMatrixSize=[1,1];
        end

        PortInfoMap(structInfo.FlatName)=structInfo;
    end

    function dataType=n_getMLDataType(coderType)
        assert(coderType.isNumeric);
        if coderType.isFixed
            dataType='Fixed';
        elseif coderType.isBoolean
            dataType='boolean';
        elseif coderType.isDouble
            dataType='double';
        elseif coderType.isSingle
            dataType='single';
        elseif coderType.isScaledDouble
            dataType='ScaledDouble';
        else
            dataType='Fixed';
        end
    end
end

function l_getStructInfo(StructInfoMap,PortInfo,IsFirstTime,Dimensions,CDataType,RowMajor,varargin)



    if nargin>6
        SystemInfo=varargin{1};
    else
        SystemInfo='';
    end
    if IsFirstTime
        n_getStructInfoFirstTime();
    else
        n_getStructInfoNestedData();
    end

    function n_getStructInfoFirstTime()

        if isa(PortInfo.Implementation,'RTW.TypedCollection')

            StructInfoMap('TopStructName')=[StructInfoMap('TopStructName'),PortInfo.Implementation.Elements(1).Identifier(1:end-5)];
        else
            StructInfoMap('TopStructName')=[StructInfoMap('TopStructName'),PortInfo.Implementation.Identifier];
        end

        StructInfoMap('TopStructDim')=[StructInfoMap('TopStructDim'),l_getScalarDim(Dimensions)];

        StructInfoMap('TopRowMajor')=[StructInfoMap('TopRowMajor'),RowMajor];








        TempElementAccessIndexNumber=StructInfoMap('ElementAccessIndexNumber');

        if isempty(TempElementAccessIndexNumber)
            TempElementAccessIndexNumber=0;
        end
        TempTopStructDim=StructInfoMap('TopStructDim');
        TempTopStructName=StructInfoMap('TopStructName');
        TempElementAccess=StructInfoMap('ElementAccess');

        if isempty(TempElementAccess)
            TempElementAccess={''};
        end

        if TempTopStructDim(end)==1
            StructInfoMap('ElementAccessIndexNumber')=[StructInfoMap('ElementAccessIndexNumber'),TempElementAccessIndexNumber(end)];
            StructInfoMap('TopStructIndexing')=[StructInfoMap('TopStructIndexing'),{''}];
            StructInfoMap('ElementAccess')=[StructInfoMap('ElementAccess'),[TempTopStructName{end},'.']];
            StructInfoMap('ElementAccessIndexVariable')=[StructInfoMap('ElementAccessIndexVariable'),{''}];
        else
            StructInfoMap('ElementAccessIndexNumber')=[StructInfoMap('ElementAccessIndexNumber'),TempElementAccessIndexNumber(end)+1];
            StructInfoMap('TopStructIndexing')=[StructInfoMap('TopStructIndexing'),['[',num2str(TempTopStructDim(end)),']']];


            if prod(PortInfo.Type.Dimensions)==inf
                StructInfoMap('ElementAccess')=[StructInfoMap('ElementAccess'),[TempElementAccess{end},...
                TempTopStructName{end},...
                SystemInfo.VarSizeInfo.staticVarSufix,...
                '->data',...
                '[idx',num2str(TempElementAccessIndexNumber(end)),'].']];
            elseif isa(PortInfo.Implementation,'RTW.TypedCollection')

                StructInfoMap('ElementAccess')=[StructInfoMap('ElementAccess'),[TempElementAccess{end},...
                PortInfo.Implementation.Elements(1).Identifier,...
                SystemInfo.VarSizeInfo.staticVarSufix,...
                '[idx',num2str(TempElementAccessIndexNumber(end)),'].']];
            else
                StructInfoMap('ElementAccess')=[StructInfoMap('ElementAccess'),[TempElementAccess{end},...
                TempTopStructName{end},...
                '[idx',num2str(TempElementAccessIndexNumber(end)),'].']];
            end
            StructInfoMap('ElementAccessIndexVariable')=[StructInfoMap('ElementAccessIndexVariable'),{['idx',num2str(TempElementAccessIndexNumber(end))]}];
        end

        StructInfoMap('TopStructType')=[StructInfoMap('TopStructType'),CDataType];


        if isa(PortInfo.Implementation,'RTW.TypedCollection')
            StructInfoMap('VariableNameDataSet')=[StructInfoMap('VariableNameDataSet'),PortInfo.Implementation.Elements(1).Identifier,PortInfo.Implementation.Elements(2).Identifier];
        else
            StructInfoMap('VariableNameDataSet')=[StructInfoMap('VariableNameDataSet'),PortInfo.Implementation.Identifier];
        end
    end

    function n_getStructInfoNestedData()

        StructInfoMap('TopStructName')=[StructInfoMap('TopStructName'),PortInfo.Identifier];

        StructInfoMap('TopStructDim')=[StructInfoMap('TopStructDim'),l_getScalarDim(Dimensions)];

        StructInfoMap('TopRowMajor')=[StructInfoMap('TopRowMajor'),RowMajor];








        TempElementAccessIndexNumber=StructInfoMap('ElementAccessIndexNumber');

        if isempty(TempElementAccessIndexNumber)
            TempElementAccessIndexNumber=0;
        end
        TempTopStructDim=StructInfoMap('TopStructDim');
        TempTopStructName=StructInfoMap('TopStructName');
        TempElementAccess=StructInfoMap('ElementAccess');

        if isempty(TempElementAccess)
            TempElementAccess={''};
        end

        if TempTopStructDim(end)==1
            StructInfoMap('ElementAccessIndexNumber')=[StructInfoMap('ElementAccessIndexNumber'),TempElementAccessIndexNumber(end)];
            StructInfoMap('TopStructIndexing')=[StructInfoMap('TopStructIndexing'),{''}];
            StructInfoMap('ElementAccess')=[StructInfoMap('ElementAccess'),[TempTopStructName{end},'.']];
            StructInfoMap('ElementAccessIndexVariable')=[StructInfoMap('ElementAccessIndexVariable'),{''}];
        else
            StructInfoMap('ElementAccessIndexNumber')=[StructInfoMap('ElementAccessIndexNumber'),TempElementAccessIndexNumber(end)+1];
            StructInfoMap('TopStructIndexing')=[StructInfoMap('TopStructIndexing'),['[',num2str(TempTopStructDim(end)),']']];
            StructInfoMap('ElementAccess')=[StructInfoMap('ElementAccess'),[TempTopStructName{end},...
            '[idx',num2str(TempElementAccessIndexNumber(end)),'].']];
            StructInfoMap('ElementAccessIndexVariable')=[StructInfoMap('ElementAccessIndexVariable'),{['idx',num2str(TempElementAccessIndexNumber(end))]}];
        end

        StructInfoMap('TopStructType')=[StructInfoMap('TopStructType'),CDataType];


        StructInfoMap('VariableNameDataSet')=[StructInfoMap('VariableNameDataSet'),PortInfo.Identifier];
    end

end

function dim=l_getScalarDim(dimArray)


    dim=1;
    for i=1:length(dimArray)
        dim=dim*dimArray(i);
    end
end

function SystemInfo=l_Check_For_Unsupported_MATLAB_CoderFeatures(PortInfo,PortImplInfo,FirstTime,SystemInfo,PortDirection)
    if FirstTime

        if isempty(PortInfo.Implementation)

            throw(MException(message('HDLLink:DPIG:IOHasNoImplementation',PortInfo.GraphicalName)));
        elseif isa(PortInfo.Implementation,'RTW.TypedCollection')

            SystemInfo.VarSizeInfo.containUpperBoundArr=true;
            if strcmpi(PortDirection,'output')
                SystemInfo.VarSizeInfo.containVarSizeOutput=true;
            end
            if length(PortInfo.Type.Dimensions)~=1&&~(length(PortInfo.Type.Dimensions)==2&&any(PortInfo.Type.Dimensions==1))
                throw(MException(message('HDLLink:DPIG:VariableSizedMatrix',PortInfo.GraphicalName)));
            end
        elseif PortInfo.Type.isMatrix&&l_getScalarDim(PortInfo.Type.Dimensions)==Inf

            SystemInfo.VarSizeInfo.containEmxArr=true;
            if strcmpi(PortDirection,'output')
                SystemInfo.VarSizeInfo.containVarSizeOutput=true;
            end
            if length(PortInfo.Type.Dimensions)~=1&&~(length(PortInfo.Type.Dimensions)==2&&any(PortInfo.Type.Dimensions==1))
                throw(MException(message('HDLLink:DPIG:VariableSizedMatrix',PortInfo.GraphicalName)));
            end
        end
    else

        if isempty(PortInfo.Type)

            throw(MException(message('HDLLink:DPIG:IOHasNoImplementation',PortInfo.GraphicalName)));
        elseif PortInfo.Type.isMatrix&&(PortInfo.Type.BaseType.isNumeric||PortInfo.Type.BaseType.isComplex)

            if startsWith(PortImplInfo.Type.Identifier,SystemInfo.VarSizeInfo.emxArrPrefix)||l_getScalarDim(PortInfo.Type.Dimensions)==Inf
                throw(MException(message('HDLLink:DPIG:VariableSizedStructFields')));
            end
        end
    end
end

function l_DataTypeErrorHandling(structInfo)
    if isempty(structInfo.SVDataType)
        FirstCause=MException(message('HDLLink:DPITargetCC:dpigInvalidDataTypeML',structInfo.DataType,structInfo.Name));
        if strcmp(structInfo.DataType,'int128m_T')||strcmp(structInfo.DataType,'uint128m_T')


            SecondCause=MException(message('HDLLink:DPIG:FixedPointTooLarge'));
            FinalME=addCause(SecondCause,FirstCause);



        else
            FinalME=FirstCause;
        end
        throw(FinalME);
    end

end

function StructInfo=l_getStructInfoFromMapToMATLABStruct(StructInfoMap,FieldName)

    if isempty(StructInfoMap('TopStructName'))


        StructInfo=struct([]);
        return;
    end
    StructInfo=struct('TopStructName',{''},...
    'TopStructIndexing',{''},...
    'TopStructType',{''},...
    'TopStructDim',[],...
    'TopRowMajor',[],...
    'ElementAccess',{''},...
    'ElementAccessIndexNumber',[],...
    'ElementAccessIndexVariable',{''});

    for idx=keys(StructInfoMap)
        KeyVal=idx{1};
        if strcmp(KeyVal,'VariableNameDataSet')

            continue;
        end
        Temp=StructInfoMap(KeyVal);



        if strcmp(KeyVal,'TopStructDim')||strcmp(KeyVal,'ElementAccessIndexNumber')||strcmp(KeyVal,'TopStructName')||strcmp(KeyVal,'ElementAccessIndexVariable')||...
            strcmp(KeyVal,'TopRowMajor')
            StructInfo.(KeyVal)=Temp;
        elseif strcmp(KeyVal,'ElementAccess')
            StructInfo.(KeyVal)=[Temp{:},FieldName];
        else
            StructInfo.(KeyVal)=Temp(1);
        end
    end
end

function l_CleanOneLayerOfStructInfoMap(StructInfoMap)


    for idx=keys(StructInfoMap)
        KeyVals=idx{1};
        if strcmp(KeyVals,'VariableNameDataSet')

            continue;
        end
        Temp=StructInfoMap(KeyVals);

        StructInfoMap(KeyVals)=Temp(1:end-1);
    end
end

function UniqueFlatName=l_getUniqueFlatName(StructInfoMap,Name)


    TempFlatName=cellfun(@(x)[x,'_'],StructInfoMap('TopStructName'),'UniformOutput',false);
    UniqueFlatName=matlab.lang.makeUniqueStrings([TempFlatName{:},Name],StructInfoMap('VariableNameDataSet'));

    l_CheckForSystemVerilog_And_C_Keywords(UniqueFlatName);

    assert(ischar(UniqueFlatName),'UniqueFlatName is not a char');

    StructInfoMap('VariableNameDataSet')=[StructInfoMap('VariableNameDataSet'),UniqueFlatName];%#ok<NASGU>
end

function UniqueName=l_getUniqueName(StructInfoMap,Name)


    UniqueName=matlab.lang.makeUniqueStrings(Name,StructInfoMap('VariableNameDataSet'));

    l_CheckForSystemVerilog_And_C_Keywords(UniqueName);

    assert(ischar(UniqueName),'UniqueName is not a char');

    StructInfoMap('VariableNameDataSet')=[StructInfoMap('VariableNameDataSet'),UniqueName];%#ok<NASGU>
end


function l_CheckForSystemVerilog_And_C_Keywords(uniqueVarName)

    SystemVerilogKeyWords={'always','ifnone','rpmos','and','initial','rtran','assign','inout','rtranif0','begin',...
    'input','rtranif1','buf','integer','scalared','bufif0','join','small','bufif1',...
    'large','specify','case','macromodule','specparam','casex','medium','strong0',...
    'casez','module','strong1','cmos','nand','supply0','deassign','negedge','supply1',...
    'default','nmos','table','defparam','nor','task','disable','not','time','edge','notif0',...
    'tran','else','notif1','tranif0','end','or','tranif1','endcase','output','tri','endmodule',...
    'parameter','tri0','endfunction','pmos','tri1','endprimitive','posedge','triand','endspecify',...
    'primitive','trior','endtable','pull0','trireg','endtask','pull1','vectored','event','pullup',...
    'wait','for','pulldown','wand','force','rcmos','weak0','forever','real','weak1','fork','realtime',...
    'while','function','reg','wire','highz0','release','wor','highz1','repeat','xnor','if','rnmos',...
    'xor'};



    if any(strcmp(uniqueVarName,SystemVerilogKeyWords))

        error(message('HDLLink:DPITargetCC:SVKeywordsNotAllowed',uniqueVarName));
    end

end

function EType=l_getEnumUnderlyingType(WordLength,TargetLang,signedness)
    if WordLength==8&&signedness
        CType='int8_T';
        SVType='byte';
    elseif WordLength==16&&signedness
        CType='int16_T';
        SVType='shortint';
    elseif WordLength==32&&signedness
        CType='int32_T';
        SVType='int';
    elseif WordLength==8&&~signedness
        CType='uint8_T';
        SVType='byte unsigned';
    elseif WordLength==16&&~signedness
        CType='uint16_T';
        SVType='shortint unsigned';
    elseif WordLength==32&&~signedness
        CType='uint32_T';
        SVType='int unsigned';
    else
        error(message('HDLLink:DPIG:Unsupported64BitEnum'));
    end

    if strcmp(TargetLang,'SV')
        EType=SVType;
    else
        EType=CType;
    end
end