




classdef Type<matlab.mixin.Copyable&matlab.mixin.Heterogeneous


    properties(SetAccess=private,GetAccess=public)
        Dimensions(1,:)int32=[]
    end

    methods
        function setDimensions(this,dimIn)



            if isempty(dimIn)||numel(dimIn)>1
                this.Dimensions=dimIn;
            else

                this.Dimensions=[dimIn,1];
            end
        end
    end

    methods(Access=protected)
        function this=Type(dimensions)
            this.setDimensions(dimensions);
        end
    end

    methods(Access=public)

        function res=isUnknown(this)
            res=isa(this,'internal.mtree.type.UnknownType');
        end

        function res=isHalf(this)
            res=isa(this,'internal.mtree.type.Half');
        end

        function res=isSingle(this)
            res=isa(this,'internal.mtree.type.Single');
        end

        function res=isDouble(this)
            res=isa(this,'internal.mtree.type.Double');
        end

        function res=isFloat(this)
            res=isa(this,'internal.mtree.type.FloatType');
        end

        function res=isFi(this)
            res=isa(this,'internal.mtree.type.Fi');
        end

        function res=isInt(this)
            res=isa(this,'internal.mtree.type.Int');
        end

        function res=isNumeric(this)
            res=isa(this,'internal.mtree.type.NumericType');
        end

        function res=isLogical(this)
            res=isa(this,'internal.mtree.type.Logical');
        end

        function res=isSystemObject(this)
            res=isa(this,'internal.mtree.type.SystemObject');
        end

        function res=isStructType(this)
            res=isa(this,'internal.mtree.type.StructType');
        end

        function res=isFunctionHandle(this)
            res=isa(this,'internal.mtree.type.FunctionHandle');
        end

        function res=isVoid(this)
            res=isa(this,'internal.mtree.type.Void');
        end

        function res=isChar(this)
            res=isa(this,'internal.mtree.type.Char');
        end

        function res=isCell(this)
            res=isa(this,'internal.mtree.type.Cell');
        end

        function res=isComplex(this)
            if~this.isNumeric
                res=false;
            else
                res=this.Complex;
            end
        end

        function overflowMode=getOverflowMode(~)

            overflowMode='Wrap';
        end

        function roundMode=getRoundMode(~)

            roundMode='Floor';
        end

        function res=isSizeDynamic(this)
            res=any(this.Dimensions==-1);
        end

        function res=isEmpty(this)
            res=isempty(this.Dimensions)||any(this.Dimensions==0);
        end

        function res=isScalar(this)
            res=~isempty(this.Dimensions)&&all(this.Dimensions==1);
        end

        function res=isVector(this)
            res=~this.isEmpty&&nnz(this.Dimensions~=1)==1;
        end

        function res=isRowVector(this)
            res=this.isVector&&this.Dimensions(2)~=1;
        end

        function res=isColumnVector(this)
            res=this.isVector&&this.Dimensions(1)~=1;
        end

        function res=is2DVector(this)
            res=this.isRowVector||this.isColumnVector;
        end

        function res=isMatrix(this)


            nonScalarDims=this.Dimensions(this.Dimensions>1);
            res=numel(nonScalarDims)>=2&&~this.isEmpty;
        end

        function pirType=toPIRType(this)

            pirType=this.toScalarPIRType;


            if~this.isScalar
                af=pir_arr_factory_tc;

                af.addBaseType(pirType);

                if numel(this.Dimensions)==2&&this.Dimensions(1)==1
                    af.addDimension(this.Dimensions(2));
                    af.VectorOrientation='row';
                elseif numel(this.Dimensions)==2&&this.Dimensions(2)==1
                    af.addDimension(this.Dimensions(1));
                    af.VectorOrientation='column';
                else
                    for i=1:numel(this.Dimensions)
                        af.addDimension(this.Dimensions(i));
                    end
                end

                pirType=pir_array_t(af);
            end
        end

        function newVal=castValueToType(this,val)
            if this.isUnknown||this.isSystemObject


                newVal=val;
                reshapeDimensions=false;
            elseif this.isStructType
                assert(isstruct(val),'a non-struct type cannot be cast to a struct type');

                typeFieldNames=this.getFieldNames;
                typeFieldTypes=this.getFieldTypes;
                valFieldNames=fields(val);






                assert(isempty(setdiff(valFieldNames,typeFieldNames))&&...
                numel(typeFieldNames)>=numel(intersect(typeFieldNames,valFieldNames)),...
                'structs may only be cast to struct types with equivalent fields');

                newVal=repmat(struct,size(val));
                reshapeDimensions=true;

                for i=1:numel(val)




                    for j=1:numel(typeFieldNames)
                        fieldName=typeFieldNames{j};

                        if ismember(fieldName,valFieldNames)
                            fieldType=typeFieldTypes(j);
                            fieldVal=val(i).(fieldName);

                            newVal(i).(fieldName)=fieldType.castValueToType(fieldVal);
                        end
                    end
                end
            elseif this.isCell
                assert(iscell(val),'a non-cell type cannot be cast to a cell type');
                assert(isequal(this.Dimensions,size(val)),...
                'Dimension mismatch between cell array value and type being cast to');
                assert(isequal(this.Dimensions,size(this.cellTypes)),...
                'Dimension mismatch between dimensions and cell types of type being cast to');

                newVal=cell(size(val));

                for i=1:numel(val)
                    newVal{i}=this.cellTypes(i).castValueToType(val{i});
                end
                reshapeDimensions=false;
            else
                exVal=this.getExampleValueScalar;
                newVal=cast(val,'like',exVal);
                reshapeDimensions=true;
            end



            if reshapeDimensions&&...
                ~isScalar(this)&&(numel(val)==prod(this.Dimensions))
                newVal=reshape(newVal,this.Dimensions);
            end
        end

        function exVal=getExampleValue(this)
            exVal=this.getExampleValueScalar;
            if~this.isScalar
                exVal=repmat(exVal,this.Dimensions);
            end
        end

        function exValStr=getExampleValueString(this)
            exValStr=this.getExampleValueStringScalar;
            if~this.isScalar
                dimStr=mat2str(this.Dimensions);
                exValStr=sprintf('repmat(%s, %s)',exValStr,dimStr);
            end
        end

        function res=isDimensionsEqual(this,other)
            assert(isscalar(this)&&isscalar(other),...
            'only scalar type objects can be compared');





            if isempty(this.Dimensions)||isempty(other.Dimensions)
                res=false;
            else
                commonLen=min(numel(this.Dimensions),numel(other.Dimensions));
                commonDimsEqual=isequal(this.Dimensions(1:commonLen),...
                other.Dimensions(1:commonLen));

                uncommonDimsScalar=all(this.Dimensions(commonLen+1:end)==1)&&...
                all(other.Dimensions(commonLen+1:end)==1);

                res=commonDimsEqual&&uncommonDimsScalar;
            end
        end

        function res=isTypeEqual(this,other)
            assert(isscalar(this)&&isscalar(other),...
            'only scalar type objects can be compared');

            res=this.isTypeEqualScalar(other);
        end

        function res=eq(this,other)
            res=this.isTypeEqual(other)&&this.isDimensionsEqual(other);
        end
    end

    methods(Abstract,Access=public)


        name=toSlName(this);


        name=getMLName(this);



        doesit=supportsExampleValues(this);

    end

    methods(Abstract,Access=protected)


        exVal=getExampleValueScalar(this)


        exValStr=getExampleValueStringScalar(this)


        type=toScalarPIRType(this)



        res=isTypeEqualScalar(this,other)

    end

    methods(Static)



        function type=makeType(baseType,dimensions,isComplex)
            assert(ischar(baseType)&&isrow(baseType),...
            'baseType must be a character vector');

            if nargin<3
                isComplex=false;
            end

            switch(lower(baseType))
            case 'half'
                type=internal.mtree.type.Half(dimensions,isComplex);
            case 'single'
                type=internal.mtree.type.Single(dimensions,isComplex);
            case 'double'
                type=internal.mtree.type.Double(dimensions,isComplex);
            case 'uint8'
                type=internal.mtree.type.Int(false,8,dimensions,isComplex);
            case 'int8'
                type=internal.mtree.type.Int(true,8,dimensions,isComplex);
            case 'uint16'
                type=internal.mtree.type.Int(false,16,dimensions,isComplex);
            case 'int16'
                type=internal.mtree.type.Int(true,16,dimensions,isComplex);
            case 'uint32'
                type=internal.mtree.type.Int(false,32,dimensions,isComplex);
            case 'int32'
                type=internal.mtree.type.Int(true,32,dimensions,isComplex);
            case 'uint64'
                type=internal.mtree.type.Int(false,64,dimensions,isComplex);
            case 'int64'
                type=internal.mtree.type.Int(true,64,dimensions,isComplex);
            case{'logical','boolean'}
                type=internal.mtree.type.Logical(dimensions);
            case 'char'
                type=internal.mtree.type.Char(dimensions);
            case 'cell'
                type=internal.mtree.type.Cell(dimensions);
            otherwise
                type=internal.mtree.type.UnknownType(baseType,dimensions);
            end
        end





        function type=fromVarTypeInfo(varTypeInfo)
            if varTypeInfo.isStruct()
                type=internal.mtree.type.StructType.fromStructVarTypeInfo(varTypeInfo);
            else
                varInfo=varTypeInfo.inferred_Type;
                type=internal.mtree.Type.fromTypeInfo(varInfo);
            end
        end

        function type=fromTypeInfo(varInfo)
            dimensions=varInfo.Size;

            dimensions(varInfo.SizeDynamic)=-1;
            isComplex=varInfo.Complex;

            if strcmp(varInfo.Class,'embedded.fi')
                nt=varInfo.NumericType;
                fm=varInfo.FiMath;

                type=internal.mtree.type.Fi(nt,fm,dimensions,isComplex);
            elseif varInfo.SystemObj
                pirBased=lowersysobj.isPIRSupportedObject(varInfo.Class);
                type=internal.mtree.type.SystemObject(varInfo.Class,pirBased);
            else
                baseType=varInfo.Class;
                type=internal.mtree.Type.makeType(...
                baseType,dimensions,isComplex);
            end
        end

        function type=fromValue(val)
            dimensions=size(val);
            isComplex=isnumeric(val)&&~isreal(val);

            if isa(val,'embedded.fi')
                nt=numerictype(val);
                fm=fimath(val);

                type=internal.mtree.type.Fi(nt,fm,dimensions,isComplex);
            elseif isa(val,'struct')
                nFields=numel(fieldnames(val(1)));
                propNames=fields(val(1));
                propValues=cell(1,nFields);
                for i=1:nFields
                    propValues{i}=internal.mtree.Type.fromValue(val(1).(propNames{i}));
                end

                type=internal.mtree.type.StructType(propNames,propValues,dimensions);
            elseif matlab.system.isSystemObject(val)
                pirBased=true;
                type=internal.mtree.type.SystemObject(class(val),pirBased);
            elseif isa(val,'function_handle')
                type=internal.mtree.type.FunctionHandle(func2str(val));
            elseif iscell(val)
                typeArr=repmat(internal.mtree.type.UnknownType,dimensions);
                for i=1:numel(val)
                    typeArr(i)=internal.mtree.Type.fromValue(val{i});
                end
                type=internal.mtree.type.Cell(dimensions,typeArr);
            else
                if isa(val,'coder.internal.indexInt')
                    baseType=coder.internal.indexIntClass;
                else
                    baseType=class(val);
                end

                type=internal.mtree.Type.makeType(baseType,dimensions,isComplex);
            end
        end






        function type=fromPIRType(pirType)
            if pirType.isArrayType
                scalarType=pirType.BaseType;

                if pirType.isRowVector
                    dimensions=[1,pirType.Dimensions];
                elseif pirType.isColumnVector
                    dimensions=[pirType.Dimensions,1];
                else
                    dimensions=pirType.Dimensions;
                end
            else
                scalarType=pirType;
                dimensions=[1,1];
            end

            if scalarType.isComplexType
                realType=scalarType.getLeafType;
                isComplex=true;
            else
                realType=scalarType;
                isComplex=false;
            end

            if realType.is1BitType
                assert(~isComplex);
                type=internal.mtree.type.Logical(dimensions);
            elseif realType.isHalfType
                type=internal.mtree.type.Half(dimensions,isComplex);
            elseif realType.isSingleType
                type=internal.mtree.type.Single(dimensions,isComplex);
            elseif realType.isDoubleType
                type=internal.mtree.type.Double(dimensions,isComplex);
            elseif realType.isWordType&&...
                realType.FractionLength==0&&...
                ismember(realType.WordLength,[8,16,32,64])
                type=internal.mtree.type.Int(...
                realType.Signed,realType.WordLength,dimensions,isComplex);
            elseif realType.isWordType
                nt=numerictype(realType.Signed,...
                realType.WordLength,-realType.FractionLength);
                type=internal.mtree.type.Fi(nt,hdlfimath,dimensions,isComplex);
            else
                assert(error('Cannot create a type from PIR type ''%s''',...
                realType.ClassName));
            end
        end

        function type=getIntToHold(val,dimensions)
            assert(isequal(floor(val),val)&&isreal(val));

            isUnsigned=all(val>=0,'all');
            valMax=max(val,[],'all');

            if isUnsigned
                if valMax<=intmax('uint8')
                    typeName='uint8';
                elseif valMax<=intmax('uint16')
                    typeName='uint16';
                elseif valMax<=intmax('uint32')
                    typeName='uint32';
                else
                    assert(valMax<=intmax('uint64'));
                    typeName='uint64';
                end
            else
                valMin=min(val,[],'all');

                if valMax<=intmax('int8')&&valMin>=intmin('int8')
                    typeName='int8';
                elseif valMax<=intmax('int16')&&valMin>=intmin('int16')
                    typeName='int16';
                elseif valMax<=intmax('int32')&&valMin>=intmin('int32')
                    typeName='int32';
                else
                    assert(valMax<=intmax('int64')&&valMin>=intmin('int64'));
                    typeName='int64';
                end
            end

            type=internal.mtree.Type.makeType(typeName,dimensions,false);
        end

        function setIntegersSaturateOnOverflow(val)
            if val
                internal.mtree.type.Int.setGetOverflowBehavior('Saturate');
            else
                internal.mtree.type.Int.setGetOverflowBehavior('Wrap');
            end
        end

    end

    methods(Static,Sealed,Access=protected)
        function defaultObject=getDefaultScalarElement
            defaultObject=internal.mtree.type.UnknownType;
        end
    end

end


