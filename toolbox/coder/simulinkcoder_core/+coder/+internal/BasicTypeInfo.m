classdef BasicTypeInfo < handle
    properties ( SetAccess = immutable )
        Double coder.internal.BasicType = coder.internal.BasicType.empty;
        Single coder.internal.BasicType = coder.internal.BasicType.empty;
        Boolean coder.internal.BasicType = coder.internal.BasicType.empty;
        TargetTypeInfo
        DeploymentTypeInfo
        StandardIntegerSizes
        PurelyIntegerCode
    end

    properties ( GetAccess = private, SetAccess = immutable )
        SignedIntegerTypes coder.internal.BasicType = coder.internal.BasicType.empty
        UnsignedIntegerTypes coder.internal.BasicType = coder.internal.BasicType.empty
        IntegerTypeSizes
    end


    methods

        function [ types, longLongIdx ] = getAdditionalTargetTypes( this )

            additionalTargetTypeSizes = setdiff( this.TargetTypeInfo.getTypeSizes,  ...
                union( this.StandardIntegerSizes,  ...
                this.DeploymentTypeInfo.getTypeSizes ) );

            typePriorityOrder = 'Outwards_from_long';
            [ primitiveTypesSigned, primitiveTypesUnsigned,  ...
                primitiveTypeSizes ] = i_getPreferredPrimitiveTypes ...
                ( this.TargetTypeInfo, typePriorityOrder );


            [ primitiveTypeSizes, idx ] =  ...
                intersect( primitiveTypeSizes, additionalTargetTypeSizes );
            primitiveTypesSigned = primitiveTypesSigned( idx );
            primitiveTypesUnsigned = primitiveTypesUnsigned( idx );

            n = length( primitiveTypeSizes );
            types = coder.internal.BasicType.empty( 0, 2 * n );
            for i = 1:n
                typeSize = primitiveTypeSizes( i );
                templateType = this.getIntegerType( typeSize, true );
                types( i * 2 - 1 ) = coder.internal.BasicType( templateType.Name,  ...
                    templateType.EmitName, primitiveTypesSigned{ i }, typeSize,  ...
                    typeSize, true );
                templateType = this.getIntegerType( typeSize, false );
                types( i * 2 ) = coder.internal.BasicType( templateType.Name,  ...
                    templateType.EmitName, primitiveTypesUnsigned{ i }, typeSize,  ...
                    typeSize, false );
            end


            longSize = this.TargetTypeInfo.LongNumBits;
            longLongIdx( 2:2:2 * n ) = primitiveTypeSizes > longSize;
            longLongIdx( 1:2:2 * n - 1 ) = primitiveTypeSizes > longSize;
        end




        function [ types, longLongIdx ] = getDeploymentTypes( this )


            deploymentSizes = setdiff( this.DeploymentTypeInfo.getTypeSizes,  ...
                this.StandardIntegerSizes );

            deploymentSizes = deploymentSizes ...
                ( deploymentSizes <= max( getTypeSizes( this.TargetTypeInfo ) ) );
            n = length( deploymentSizes );
            types = coder.internal.BasicType.empty( 0, 2 * n );
            for i = 1:n
                typeSize = deploymentSizes( i );
                types( i * 2 - 1 ) = getIntegerType( this, typeSize, true );
                types( i * 2 ) = getIntegerType( this, typeSize, false );
            end


            longSize = this.DeploymentTypeInfo.LongNumBits;
            longLongIdx( 2:2:2 * n ) = deploymentSizes > longSize;
            longLongIdx( 1:2:2 * n - 1 ) = deploymentSizes > longSize;

        end


        function type = getIntegerType( this, numBits, isSigned )
            idx = numBits == this.IntegerTypeSizes;
            if isSigned
                type = this.SignedIntegerTypes( idx );
            else
                type = this.UnsignedIntegerTypes( idx );
            end
        end



        function types = getStandardIntegerTypes( this )
            n = length( this.StandardIntegerSizes );
            types = coder.internal.BasicType.empty( 0, 2 * n );
            for i = 1:n
                s = this.StandardIntegerSizes( i );
                types( i * 2 - 1 ) = getIntegerType( this, s, true );
                types( i * 2 ) = getIntegerType( this, s, false );
            end
        end




        function types = getNonStandardIntegerTypes( this )

            targetSizes = getTypeSizes( this.TargetTypeInfo );
            maxTargetSize = max( targetSizes );
            deploymentSizes = getTypeSizes( this.DeploymentTypeInfo );
            deploymentSizes = deploymentSizes( deploymentSizes <= maxTargetSize );

            allSizes = union( targetSizes, deploymentSizes );
            nonStandardSizes = setdiff( allSizes, this.StandardIntegerSizes );
            n = length( nonStandardSizes );
            types = coder.internal.BasicType.empty( 0, 2 * n );
            for i = 1:n
                s = nonStandardSizes( i );
                types( i * 2 - 1 ) = getIntegerType( this, s, true );
                types( i * 2 ) = getIntegerType( this, s, false );
            end
        end


        function this = BasicTypeInfo( targetTypeInfo, deploymentTypeInfo,  ...
                typeForBoolean, purelyIntegerCode, basicTypeNames )

            arguments
                targetTypeInfo
                deploymentTypeInfo
                typeForBoolean
                purelyIntegerCode
                basicTypeNames
            end

            if isempty( basicTypeNames )
                basicTypeNames = i_getClassicNames;
            elseif strcmp( matlabRelease.Release, 'R2022b' ) &&  ...
                    isstruct( basicTypeNames )



                basicTypeNames = i_updateBasicTypeNames( basicTypeNames );
            end

            this.TargetTypeInfo = targetTypeInfo;
            this.DeploymentTypeInfo = deploymentTypeInfo;
            this.PurelyIntegerCode = purelyIntegerCode;


            this.StandardIntegerSizes = [ 8, 16, 32 ];
            if any( getTypeSizes( this.TargetTypeInfo ) == 64 )
                this.StandardIntegerSizes( end  + 1 ) = 64;
            end


            typePriorityOrder = getRtwtypesTypedefUintNPreference(  );
            [ primitiveTypesSigned, primitiveTypesUnsigned,  ...
                primitiveTypeSizes ] = i_getPreferredPrimitiveTypes ...
                ( targetTypeInfo, typePriorityOrder );



            targetTypeSizes = getTypeSizes( targetTypeInfo );
            maxTypeSize = max( targetTypeSizes );
            integerTypeSizes = unique( [ targetTypeSizes,  ...
                getTypeSizes( deploymentTypeInfo ), 8, 16, 32 ] );
            integerTypeSizes = integerTypeSizes( integerTypeSizes <= maxTypeSize );
            this.IntegerTypeSizes = integerTypeSizes;
            for i = 1:length( integerTypeSizes )
                typeSize = integerTypeSizes( i );
                intTypeName = sprintf( 'int%d', typeSize );
                uintTypeName = [ 'u', intTypeName ];


                primitiveTypeIdx = find( typeSize <= primitiveTypeSizes, 1 );
                containerTypeSize = primitiveTypeSizes( primitiveTypeIdx );


                if any( typeSize == this.StandardIntegerSizes ) &&  ...
                        any( typeSize == targetTypeSizes )


                    intEmitName = basicTypeNames( sprintf( 'int%d', typeSize ) );
                    uintEmitName = basicTypeNames( sprintf( 'uint%d', typeSize ) );
                else
                    intEmitName = [ intTypeName, '_T' ];
                    uintEmitName = [ uintTypeName, '_T' ];
                end


                this.SignedIntegerTypes( end  + 1 ) =  ...
                    coder.internal.BasicType( intTypeName,  ...
                    intEmitName, primitiveTypesSigned{ primitiveTypeIdx },  ...
                    typeSize, containerTypeSize, true );
                this.UnsignedIntegerTypes( end  + 1 ) =  ...
                    coder.internal.BasicType( uintTypeName,  ...
                    uintEmitName, primitiveTypesUnsigned{ primitiveTypeIdx },  ...
                    typeSize, containerTypeSize, false );
            end


            if strcmp( typeForBoolean, 'bool' )
                booleanPrimitiveType = 'bool';
            else
                booleanIsSigned = startsWith( typeForBoolean, 'int' );
                booleanNumBits = regexp( typeForBoolean,  ...
                    '(?<=(int)|(uint))\d+', 'match', 'once' );
                booleanNumBits = str2double( booleanNumBits );
                integerTypeForBoolean = getIntegerType( this,  ...
                    booleanNumBits, booleanIsSigned );
                booleanPrimitiveType = integerTypeForBoolean.PrimitiveType;
            end
            this.Boolean = coder.internal.BasicType ...
                ( 'boolean', basicTypeNames( 'boolean' ), booleanPrimitiveType );


            if ~purelyIntegerCode
                this.Double = coder.internal.BasicType ...
                    ( 'double', basicTypeNames( 'double' ), 'double' );
                this.Single = coder.internal.BasicType ...
                    ( 'single', basicTypeNames( 'single' ), 'float' );
            end
        end
    end
end


function preferredSortChoice = getRtwtypesTypedefUintNPreference(  )
switch slfeature( 'RtwtypesTypedefUintNPreference' )
    case 1
        preferredSortChoice = 'Ascend';
    case 2
        preferredSortChoice = 'Descend';
    otherwise
        preferredSortChoice = 'Ascend_from_int';
end
end


function iiPrefSort = getPreferredIntSortForTypedef( targetTypeInfo,  ...
    typePriorityOrder )

primitiveTypesSigned = targetTypeInfo.getPrimitiveSignedTypes;
indexOfInt = find( strcmp( primitiveTypesSigned, 'int' ), 1 );
numTypeNames = length( primitiveTypesSigned );

switch typePriorityOrder
    case 'Ascend'
        iiPrefSort = 1:numTypeNames;
    case 'Descend'
        iiPrefSort = numTypeNames:(  - 1 ):1;
    case 'Outwards_from_long'
        iiPrefSort = [ ( indexOfInt + 1 ):numTypeNames, indexOfInt: - 1:1 ];
    case 'Ascend_from_int'
        i1 = indexOfInt;
        i2 = i1 - 1;
        iiPrefSort = [ i1:numTypeNames, 1:i2 ];
    otherwise
        assert( false, 'Invalid option: %s', typePriorityOrder )
end
end



function [ primitiveTypesSigned, primitiveTypesUnsigned,  ...
    primitiveTypeSizes ] =  ...
    i_getPreferredPrimitiveTypes( targetTypeInfo, typePriorityOrder )

primitiveTypesSigned = targetTypeInfo.getPrimitiveSignedTypes;
primitiveTypesUnsigned = targetTypeInfo.getPrimitiveUnsignedTypes;
primitiveTypeSizes = getTypeSizes( targetTypeInfo );


priorityOrder = getPreferredIntSortForTypedef( targetTypeInfo, typePriorityOrder );
primitiveTypesSigned = primitiveTypesSigned( priorityOrder );
primitiveTypesUnsigned = primitiveTypesUnsigned( priorityOrder );
primitiveTypeSizes = primitiveTypeSizes( priorityOrder );


[ primitiveTypeSizes, idx ] = unique( primitiveTypeSizes );
primitiveTypesSigned = primitiveTypesSigned( idx );
primitiveTypesUnsigned = primitiveTypesUnsigned( idx );

end



function names = i_getClassicNames
names = containers.Map;
names( 'double' ) = 'real_T';
names( 'single' ) = 'real32_T';
names( 'int8' ) = 'int8_T';
names( 'uint8' ) = 'uint8_T';
names( 'int16' ) = 'int16_T';
names( 'uint16' ) = 'uint16_T';
names( 'int32' ) = 'int32_T';
names( 'uint32' ) = 'uint32_T';
names( 'int64' ) = 'int64_T';
names( 'uint64' ) = 'uint64_T';
names( 'boolean' ) = 'boolean_T';
end



function basicTypeNamesUpdated = i_updateBasicTypeNames( basicTypeNames )

basicTypeNamesUpdated = containers.Map;
basicTypeNamesUpdated( 'double' ) = basicTypeNames.Double;
basicTypeNamesUpdated( 'single' ) = basicTypeNames.Single;
basicTypeNamesUpdated( 'int8' ) = basicTypeNames.Int8;
basicTypeNamesUpdated( 'uint8' ) = basicTypeNames.Uint8;
basicTypeNamesUpdated( 'int16' ) = basicTypeNames.Int16;
basicTypeNamesUpdated( 'uint16' ) = basicTypeNames.Uint16;
basicTypeNamesUpdated( 'int32' ) = basicTypeNames.Int32;
basicTypeNamesUpdated( 'uint32' ) = basicTypeNames.Uint32;
basicTypeNamesUpdated( 'int64' ) = basicTypeNames.Int64;
basicTypeNamesUpdated( 'uint64' ) = basicTypeNames.Uint64;
basicTypeNamesUpdated( 'boolean' ) = basicTypeNames.Boolean;
end

