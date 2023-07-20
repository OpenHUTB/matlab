function obj=processCodeDescriptorType(type,implType)






    obj=slrealtime.internal.TypeInfo;
    locProcessCodeDescriptorType(obj,type,implType);
end

function locProcessCodeDescriptorType(obj,type,implType)
    switch class(type)
    case{'old.coder.descriptor.types.Matrix','coder.descriptor.types.Matrix'}
        locProcessCodeDescriptorType(obj,type.BaseType,implType.BaseType);
        obj.isFrame=type.FrameData;
        if obj.isString







            for nDim=1:type.Dimensions.Size
                obj.dataTypeSize=obj.dataTypeSize*type.Dimensions(nDim);
            end
            obj.dimensions=1;
        else
            for nDim=1:type.Dimensions.Size
                obj.dimensions(nDim)=type.Dimensions(nDim);
            end
        end

    case{'old.coder.descriptor.types.Complex','coder.descriptor.types.Complex'}
        locProcessCodeDescriptorType(obj,type.BaseType,implType.BaseType);
        obj.isComplex=1;

    case{'old.coder.descriptor.types.Enum','coder.descriptor.types.Enum'}
        obj.isEnum=1;
        if isempty(type.StorageType)
            obj.enumClassification='int32';
            obj.dataTypeSize=4;
        else
            obj.enumClassification=type.StorageType.Name;

            if type.StorageType.WordLength>=8
                obj.dataTypeSize=type.StorageType.WordLength/8;
            else
                obj.dataTypeSize=1;
            end
        end
        obj.enumClassName=type.Name;
        obj.enumLabels=cell(1,type.Strings.Size);
        for nLabel=1:type.Strings.Size
            obj.enumLabels(nLabel)=type.Strings(nLabel);
            obj.enumValues(nLabel)=type.Values(nLabel);
        end

    case{'old.coder.descriptor.types.Struct','coder.descriptor.types.Struct'}
        obj.isNVBus=1;
        obj.dataTypeSize=type.TargetSize;
        for nEl=1:length(type.Elements)
            el=slrealtime.internal.TypeInfo;
            locProcessCodeDescriptorType(el,type.Elements(nEl).Type,type.Elements(nEl).Type);
            el.structElementName=type.Elements(nEl).Identifier;
            el.structElementOffset=type.Elements(nEl).TargetOffset;
            el.structElementMin=type.Elements(nEl).Min;
            el.structElementMax=type.Elements(nEl).Max;
            if isempty(obj.structElements)
                obj.structElements=el;
            else
                obj.structElements(nEl)=el;
            end
        end

    case{'old.coder.descriptor.types.Char','coder.descriptor.types.Char'}
        obj.isString=true;

        if isprop(implType,'WordLength')

            if implType.WordLength>=8
                obj.dataTypeSize=implType.WordLength/8;
            else
                obj.dataTypeSize=1;
            end
        else

            if implType.BaseType.WordLength>=8
                obj.dataTypeSize=implType.BaseType.WordLength/8;
            else
                obj.dataTypeSize=1;
            end
        end

    case{'old.coder.descriptor.types.Fixed','coder.descriptor.types.Fixed'}
        obj.isFixedPoint=1;
        obj.fxpSlopeAdjFactor=type.SlopeAdjustmentFactor;
        obj.fxpFractionLength=type.FractionLength;
        obj.fxpBias=type.Bias;
        obj.fxpWordLength=type.WordLength;
        obj.fxpFixedExponent=type.FixedExponent;
        obj.fxpSignedness=type.Signedness;

        obj.fxpNumericType=0;
        if type.isScaledDouble()
            obj.fxpNumericType=1;
        end

        if isprop(implType,'WordLength')

            if implType.WordLength<=8
                obj.dataTypeSize=1;
            elseif implType.WordLength<=16
                obj.dataTypeSize=2;
            elseif implType.WordLength<=32
                obj.dataTypeSize=4;
            elseif implType.WordLength<=64
                obj.dataTypeSize=8;
            else
                nEls=floor(double(implType.WordLength)/double(64));
                if mod(double(implType.WordLength),double(64))
                    nEls=nEls+1;
                end
                obj.dataTypeSize=8*nEls;
            end
        end

    case{'coder.descriptor.types.Half'}
        obj.isHalf=1;


        if type.WordLength>=8
            obj.dataTypeSize=type.WordLength/8;
        else
            obj.dataTypeSize=1;
        end

    otherwise
        switch class(type)
        case{'old.coder.descriptor.types.Double','coder.descriptor.types.Double'}
            obj.dataTypeID=0;
        case{'old.coder.descriptor.types.Single','coder.descriptor.types.Single'}
            obj.dataTypeID=1;
        case{'old.coder.descriptor.types.Integer','coder.descriptor.types.Integer'}
            switch type.WordLength
            case 8
                if type.Signedness
                    obj.dataTypeID=2;
                else
                    obj.dataTypeID=3;
                end
            case 16
                if type.Signedness
                    obj.dataTypeID=4;
                else
                    obj.dataTypeID=5;
                end
            case 32
                if type.Signedness
                    obj.dataTypeID=6;
                else
                    obj.dataTypeID=7;
                end
            otherwise
                assert(false);
            end
        case{'old.coder.descriptor.types.Bool','coder.descriptor.types.Bool'}
            obj.dataTypeID=8;
        otherwise
            assert(false,'Unsupported type');
        end

        if type.WordLength>=8
            obj.dataTypeSize=type.WordLength/8;
        else
            obj.dataTypeSize=1;
        end
    end
end
