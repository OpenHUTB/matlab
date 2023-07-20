classdef TypeEquivalencyChecker<autosar.mm.util.CodeDescriptorTypeVisitor












    properties(Access=private)
M3IType
CodeType
IsEquivalent
ModelName
CurrentSLObj
IsAppType
ShouldBeAppType
SLAppTypeAttributes
ApplicationTypeTracker
    end

    methods(Access=public)
        function this=TypeEquivalencyChecker(m3iType,modelName,...
            applicationTypeTracker)

            this=this@autosar.mm.util.CodeDescriptorTypeVisitor();


            this.M3IType=m3iType;
            this.IsEquivalent=false;
            this.ModelName=modelName;
            this.CurrentSLObj=[];
            this.SLAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes;
            this.IsAppType=false;
            this.ShouldBeAppType=false;
            this.ApplicationTypeTracker=applicationTypeTracker;
        end

        function result=isEquivalent(this,embeddedObj,codeType,slAppTypeAttributes,typeName,...
            isAppType,shouldBeAppType)

            this.CodeType=codeType;
            this.IsEquivalent=false;
            this.IsAppType=isAppType;
            this.ShouldBeAppType=shouldBeAppType;


            assert(this.M3IType.isvalid(),'TypeEquivalencyChecker: invalid m3iType!');
            if isempty(typeName)
                if autosar.mm.sl2mm.TypeEquivalencyChecker.isFixedPoint(embeddedObj)
                    typeName=autosar.mm.sl2mm.TypeBuilder.getFixedPointTypeName(embeddedObj,this.ModelName);
                else
                    typeName=embeddedObj.Identifier;
                end
            end




            this.SLAppTypeAttributes=slAppTypeAttributes;












            if~this.IsAppType&&this.ShouldBeAppType
                result=false;
                return;
            end


            if embeddedObj.isMatrix||...
                embeddedObj.isPointer||...
                embeddedObj.isVoid
                this.IsEquivalent=true;
            else
                this.IsEquivalent=this.areTypeNamesEquivalent(this.M3IType,...
                embeddedObj,typeName,slAppTypeAttributes);
            end


            if(this.IsEquivalent)
                this.accept(embeddedObj);
            end
            result=this.IsEquivalent;


            if result&&this.M3IType.IsApplication
                this.ApplicationTypeTracker.addAppTypeName(this.M3IType.Name);
            end
        end

    end

    methods(Access=protected)
        function ret=acceptEnumType(this,embeddedType)

            ret=[];
            this.IsEquivalent=false;


            m3iType=this.M3IType;

            if~isa(m3iType,'Simulink.metamodel.types.Enumeration')
                return;
            end

            if isempty(embeddedType.StorageType)


                this.IsEquivalent=...
                isequal(m3iType.Length.value,32)&&m3iType.IsSigned;
            else
                this.IsEquivalent=...
                isequal(embeddedType.StorageType.WordLength,m3iType.Length.value)&&...
                isequal(embeddedType.StorageType.Signedness,m3iType.IsSigned);
            end

            if~this.IsEquivalent
                return
            end


            this.IsEquivalent=isequal(numel(embeddedType.Strings.toArray),...
            numel(embeddedType.Values.toArray),...
            m3iType.OwnedLiteral.size());
            if~this.IsEquivalent
                return
            end


            for elIdx=1:m3iType.OwnedLiteral.size()
                m3iLiteral=m3iType.OwnedLiteral.at(elIdx);
                this.IsEquivalent=isequal(m3iLiteral.Name,embeddedType.Strings.toArray{elIdx})&&...
                isequal(m3iLiteral.Value,embeddedType.Values(elIdx));
                if~this.IsEquivalent
                    return
                end
            end





            this.IsEquivalent=isequal(embeddedType.Values(embeddedType.DefaultMember+1),...
            m3iType.DefaultValue);
            if~this.IsEquivalent
                return
            end
        end

        function ret=acceptStructType(this,embeddedType,finish)

            import Simulink.metamodel.types.Structure;


            ret=[];
            if~finish
                this.IsEquivalent=false;
            end


            if~finish
                if(Structure.MetaClass==this.M3IType.MetaClass)
                    this.IsEquivalent=...
                    (this.M3IType.Elements.size==length(embeddedType.Elements));
                end
            end


            this.CurrentSLObj=[];
            if(this.IsEquivalent)
                if this.IsAppType
                    slObj=autosar.mm.util.getValueFromGlobalScope(this.ModelName,embeddedType.Identifier);
                    if~isempty(slObj)&&...
                        ~any(strcmp(class(slObj),{'Simulink.StructType','Simulink.StructElement'}))
                        this.CurrentSLObj=slObj;
                        this.IsEquivalent=...
                        autosar.mm.util.DescriptionHelper.isDescriptionEquivalent(this.M3IType,this.CurrentSLObj.Description);
                    end
                end
            end
        end

        function ret=acceptStructElement(this,element,index)
            ret=[];
            if(this.IsEquivalent)
                m3iElement=this.M3IType.Elements.at(index);
                this.IsEquivalent=m3iElement.isvalid()&&...
                strcmp(m3iElement.Name,element.Identifier);
                if this.IsEquivalent
                    slMin=[];
                    slMax=[];
                    slUnit='';
                    slDesc='';
                    if~isempty(this.CurrentSLObj)
                        slMin=this.CurrentSLObj.Elements(index).Min;
                        slMax=this.CurrentSLObj.Elements(index).Max;
                        slUnit=this.CurrentSLObj.Elements(index).Unit;
                        slDesc=this.CurrentSLObj.Elements(index).Description;
                    end
                    elemType=m3iElement.ReferencedType;

                    elChecker=autosar.mm.sl2mm.TypeEquivalencyChecker(...
                    elemType,this.ModelName,this.ApplicationTypeTracker);

                    isDescEquivalent=...
                    autosar.mm.util.DescriptionHelper.isDescriptionEquivalent(elemType,slDesc);
                    elSlAppTypeAttributes=autosar.mm.util.SlAppTypeAttributes(slMin,slMax,slUnit);
                    structElementCodeType=...
                    autosar.mm.sl2mm.TypeBuilder.getStructElementCodeType(this.CodeType,index);
                    this.IsEquivalent=isDescEquivalent&&elChecker.isEquivalent(element.Type,...
                    structElementCodeType,elSlAppTypeAttributes,'',this.IsAppType,this.ShouldBeAppType);
                end
            end
        end

        function ret=acceptMatrixType(this,embeddedType,elemType)

            import Simulink.metamodel.types.Matrix;


            ret=[];
            this.IsEquivalent=false;

            embeddedTypeDimensionArray=...
            autosar.mm.sl2mm.CodeDescriptorDimensionArrayAdapter.getDimensionArray(embeddedType,this.CodeType);


            if~embeddedType.HasSymbolicDimensions&&~embeddedType.ArrSizeOne&&...
                prod(embeddedTypeDimensionArray)==1
                elChecker=autosar.mm.sl2mm.TypeEquivalencyChecker(...
                this.M3IType,this.ModelName,this.ApplicationTypeTracker);
                baseCodeType=autosar.mm.sl2mm.TypeBuilder.getMatrixBaseCodeType(...
                this.CodeType,embeddedTypeDimensionArray);
                this.IsEquivalent=elChecker.isEquivalent(elemType,baseCodeType,...
                this.SLAppTypeAttributes,'',this.IsAppType,this.ShouldBeAppType);
                return
            end


            if(Matrix.MetaClass==this.M3IType.MetaClass)


                if this.M3IType.Reference.isvalid
                    this.M3IType=this.M3IType.Reference;
                end
                m3iType=this.M3IType;

                if autosar.mm.sl2mm.TypeEquivalencyChecker.bothTypesAreSymbolic(m3iType,embeddedType)
                    m3iExpr=autosar.mm.util.Dimensions(m3iType.SymbolicDimensions);
                    m3iExprNormalized=autosar.mm.sl2mm.TypeEquivalencyChecker.normalizeDimensionExpression(m3iExpr.toString);
                    slExpr=autosar.mm.util.FormulaExpression.arxmlToMStyle(embeddedType.SymbolicWidth);
                    slExprNormalized=autosar.mm.sl2mm.TypeEquivalencyChecker.normalizeDimensionExpression(slExpr);
                    this.IsEquivalent=strcmp(m3iExprNormalized,slExprNormalized);
                elseif autosar.mm.sl2mm.TypeEquivalencyChecker.bothTypesAreNumeric(m3iType,embeddedType)
                    assert(m3iType.Dimensions.size>0,'Expected array to have a non-zero dimension.');

                    this.IsEquivalent=(m3iType.Dimensions.size==numel(embeddedTypeDimensionArray));

                    if(this.IsEquivalent)
                        for dimensionIndex=1:m3iType.Dimensions.size
                            if m3iType.Dimensions.at(dimensionIndex)~=...
                                embeddedTypeDimensionArray(dimensionIndex)
                                this.IsEquivalent=false;
                                break;
                            end
                        end
                    end
                end
            end


            if(this.IsEquivalent)
                elChecker=autosar.mm.sl2mm.TypeEquivalencyChecker(...
                this.M3IType.BaseType,this.ModelName,...
                this.ApplicationTypeTracker);
                baseCodeType=autosar.mm.sl2mm.TypeBuilder.getMatrixBaseCodeType(...
                this.CodeType,embeddedTypeDimensionArray);
                this.IsEquivalent=elChecker.isEquivalent(elemType,baseCodeType,...
                this.SLAppTypeAttributes,'',this.IsAppType,this.ShouldBeAppType);
            end
        end

        function ret=acceptNumericType(this,embeddedType)
            import Simulink.metamodel.types.FloatingPoint;
            import Simulink.metamodel.types.Boolean;
            import Simulink.metamodel.types.FixedPoint;
            import Simulink.metamodel.types.Integer;



            ret=[];
            this.IsEquivalent=false;


            m3iType=this.M3IType;

            if(embeddedType.isDouble||embeddedType.isSingle)
                if(FloatingPoint.MetaClass==m3iType.MetaClass)

                    this.IsEquivalent=true;
                end
            elseif embeddedType.isBoolean
                if(Boolean.MetaClass==m3iType.MetaClass)
                    if~isempty(m3iType.CompuMethod)
                        this.IsEquivalent=true;
                    end
                end
            elseif embeddedType.isInteger
                if(Integer.MetaClass==m3iType.MetaClass)

                    this.IsEquivalent=true;
                end
            elseif embeddedType.isFixed&&~embeddedType.isScaledDouble

                if(m3iType.MetaClass==FixedPoint.MetaClass)||...
                    (m3iType.MetaClass==Integer.MetaClass)

                    isFixedPoint=embeddedType.Slope~=1||embeddedType.Bias~=0;

                    if isFixedPoint

                        if(m3iType.Length.value==embeddedType.WordLength...
                            &&m3iType.IsSigned==embeddedType.Signedness)
                            this.IsEquivalent=true;



                            if(m3iType.MetaClass==FixedPoint.MetaClass)
                                if(m3iType.Bias~=embeddedType.Bias...
                                    ||m3iType.slope~=embeddedType.Slope)
                                    this.IsEquivalent=false;
                                end
                            end
                        end

                    else
                        if isFixedPoint
                            expectedMetaClass=FixedPoint.MetaClass;
                        else
                            expectedMetaClass=Integer.MetaClass;
                        end

                        if(expectedMetaClass==m3iType.MetaClass)

                            this.IsEquivalent=true;
                        end
                    end
                end

            end

            if this.IsEquivalent&&this.IsAppType


                this.IsEquivalent=this.SLAppTypeAttributes.isEquivalentToM3iType(this.M3IType,this.ModelName);
            end


            if(this.IsEquivalent)
                this.IsEquivalent=this.areTypeSizeAndSignEquivalent(m3iType,embeddedType);
            end


            if this.IsEquivalent
                [slDesc,descSupported]=autosar.mm.util.DescriptionHelper.getSLDescForEmbeddedObj(...
                this.ModelName,embeddedType);
                if(descSupported)
                    this.IsEquivalent=...
                    autosar.mm.util.DescriptionHelper.isDescriptionEquivalent(this.M3IType,slDesc);
                end
            end


            if this.IsEquivalent
                if~this.IsAppType
                    autosar.mm.sl2mm.TypeBuilder.updateNumericType(this.M3IType,...
                    embeddedType,this.IsAppType);
                end




            end
        end

        function ret=acceptCharType(this,type)
            this.checkIfMappedByUser(type);
            ret=[];
        end

        function ret=acceptComplexType(this,~)
            this.IsEquivalent=false;
            ret=[];
        end

        function ret=acceptOpaqueType(this,~)
            this.IsEquivalent=false;
            ret=[];
        end

        function ret=acceptPointerType(this,~,elemType)


            import Simulink.metamodel.types.Matrix;
            import Simulink.metamodel.types.VoidPointer;


            ret=[];
            this.IsEquivalent=false;


            m3iType=this.M3IType;

            if isa(elemType,'embedded.voidtype')...
                ||isa(elemType,'coder.descriptor.types.Void')
                if(VoidPointer.MetaClass==m3iType.MetaClass)
                    this.IsEquivalent=true;
                    return
                end
            end

            if(Matrix.MetaClass==m3iType.MetaClass)
                if m3iType.Dimensions.isvalid()&&m3iType.Dimensions.at(1)==1
                    this.IsEquivalent=true;
                end
            end


            if(this.IsEquivalent)
                elChecker=autosar.mm.sl2mm.TypeEquivalencyChecker(...
                this.M3IType.BaseType,this.ModelName,...
                this.ApplicationTypeTracker);
                if isempty(this.CodeType)
                    baseCodeType=[];
                else
                    baseCodeType=this.CodeType.BaseType;
                end
                this.IsEquivalent=elChecker.isEquivalent(elemType,baseCodeType,...
                this.SLAppTypeAttributes,'',this.IsAppType,this.ShouldBeAppType);
            end
        end

        function ret=acceptVoidType(this,~)


            import Simulink.metamodel.types.VoidPointer;


            ret=[];
            this.IsEquivalent=false;

        end

    end

    methods(Access=private)



        function result=areTypeSizeAndSignEquivalent(~,m3iType,embeddedType)
            import Simulink.metamodel.types.FloatingPoint;
            import Simulink.metamodel.types.FixedPoint;
            import Simulink.metamodel.types.Integer;

            result=true;

            if embeddedType.isDouble
                result=(FloatingPoint.MetaClass==m3iType.MetaClass)&&m3iType.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Double;
            elseif embeddedType.isSingle
                result=(FloatingPoint.MetaClass==m3iType.MetaClass)&&m3iType.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Single;
            elseif embeddedType.isInteger
                if(m3iType.MetaClass==FixedPoint.MetaClass)||...
                    (m3iType.MetaClass==Integer.MetaClass)
                    result=(m3iType.Length.value==embeddedType.WordLength)&&...
                    (m3iType.IsSigned==embeddedType.Signedness);
                else
                    result=false;
                end
            elseif embeddedType.isFixed&&~embeddedType.isScaledDouble
                if(m3iType.MetaClass==FixedPoint.MetaClass)||...
                    (m3iType.MetaClass==Integer.MetaClass)

                    result=(m3iType.Length.value==embeddedType.WordLength)&&...
                    (m3iType.IsSigned==embeddedType.Signedness);
                else
                    result=false;
                end
            end

        end




        function typeNamesEquivalent=areTypeNamesEquivalent(this,m3iType,...
            embeddedObj,typeName,slAppTypeAttributes)

            typeNamesEquivalent=strcmp(m3iType.Name,typeName);
            if~typeNamesEquivalent

                typeNamesEquivalent=autosar.mm.util.BuiltInTypeMapper.isEquivalent(embeddedObj.Identifier,m3iType);
            end

            if~typeNamesEquivalent


                isMappedToBuiltinInC=autosar.mm.util.BuiltInTypeMapper.isRTWBuiltIn(embeddedObj.Identifier,this.ModelName);
                if isMappedToBuiltinInC&&this.ShouldBeAppType&&...
                    slAppTypeAttributes.hasAnyAttributesSet
                    maxShortNameLength=get_param(this.ModelName,'AutosarMaxShortNameLength');
                    slMinNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(slAppTypeAttributes.Min,this.ModelName);
                    slMaxNumeric=autosar.mm.util.MinMaxHelper.getNumericValue(slAppTypeAttributes.Max,this.ModelName);

                    if~isempty(slMinNumeric)&&~isempty(slMaxNumeric)
                        mangledTypeName=slAppTypeAttributes.getAppTypeName(embeddedObj,...
                        maxShortNameLength,slMinNumeric,slMaxNumeric,this.ModelName);
                        typeNamesEquivalent=strcmp(m3iType.Name,mangledTypeName);
                    end
                end
            end
        end
    end

    methods(Static,Access=private)
        function isFixedPt=isFixedPoint(embeddedObj)
            isFixedPt=embeddedObj.isNumeric&&embeddedObj.isFixed&&...
            (embeddedObj.Slope~=1||embeddedObj.Bias~=0);
        end
    end

    methods(Static)
        function normalizedExpr=normalizeDimensionExpression(expression)







            s=Simulink.Signal;
            try
                s.Dimensions=expression;
                normalizedExpr=s.Dimensions;
            catch err
                if strcmp(err.identifier,'Simulink:SymbolicDims:UnsupportedDivision')







                    normalizedExpr=expression;
                else
                    rethrow(err);
                end
            end
        end

        function result=bothTypesAreSymbolic(m3iType,embeddedType)
            result=embeddedType.HasSymbolicDimensions&&...
            m3iType.SymbolicDimensions.size>0&&...
            m3iType.SymbolicDimensions.isvalid;
        end

        function result=bothTypesAreNumeric(m3iType,embeddedType)
            result=~embeddedType.HasSymbolicDimensions&&...
            m3iType.SymbolicDimensions.size==0&&...
            ~isempty(m3iType.Dimensions)&&...
            m3iType.Dimensions.isvalid();
        end
    end
end


