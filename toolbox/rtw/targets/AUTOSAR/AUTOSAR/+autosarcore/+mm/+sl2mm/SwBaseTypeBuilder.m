classdef SwBaseTypeBuilder






    properties(Constant,Access=public)
        DefaultPackage='SwBaseTypes';
    end

    properties(SetAccess=immutable,GetAccess=private)
        M3ISwBaseTypePkg Simulink.metamodel.arplatform.common.Package;
        IsAdaptive logical;
    end

    methods(Access=public)
        function this=SwBaseTypeBuilder(m3iSwBaseTypePkg,isAdaptive)
            this.M3ISwBaseTypePkg=m3iSwBaseTypePkg;
            this.IsAdaptive=isAdaptive;
        end

        function addSwBaseType(this,m3iImpType)













            import autosarcore.mm.sl2mm.SwBaseTypeBuilder;

            assert(isa(this.M3ISwBaseTypePkg,'Simulink.metamodel.arplatform.common.Package'));
            switch(class(m3iImpType))
            case 'Simulink.metamodel.types.Matrix'
                m3iImpType=m3iImpType.BaseType;
                this.addSwBaseType(m3iImpType);
            case 'Simulink.metamodel.types.Structure'


                for elemIdx=1:m3iImpType.Elements.size()
                    curElementM3IType=m3iImpType.Elements.at(elemIdx).Type;
                    this.addSwBaseType(curElementM3IType);
                end
            otherwise

            end

            if isempty(m3iImpType)||...
                (~isa(m3iImpType,'Simulink.metamodel.types.PrimitiveType')&&...
                ~isa(m3iImpType,'Simulink.metamodel.types.VoidPointer'))
                return;
            end

            swBaseTypeName=this.getSwBaseTypeNameFromImpType(m3iImpType,this.IsAdaptive);

            if this.IsAdaptive
                platformTypes=SwBaseTypeBuilder.getAdaptivePlatformTypes();
            else
                platformTypes=SwBaseTypeBuilder.getClassicPlatformTypes();
            end
            impTypeIsAdaptivePlatformType=this.IsAdaptive&&...
            strcmp(m3iImpType.Name,swBaseTypeName);
            if impTypeIsAdaptivePlatformType




                return;
            end
            if~isempty(m3iImpType.SwBaseType)&&...
                ((~any(ismember(platformTypes,m3iImpType.SwBaseType.Name))&&~this.IsAdaptive)...
                ||strcmp(m3iImpType.SwBaseType.Name,swBaseTypeName))
                return;
            end
            m3iModel=m3iImpType.modelM3I;
            if this.IsAdaptive


                if~isempty(m3iImpType.Reference)&&...
                    strcmp(m3iImpType.Reference.Name,swBaseTypeName)


                    return;
                end
                primitiveTypeSeq=autosarcore.MetaModelFinder.findObjectByMetaClass(m3iModel,...
                Simulink.metamodel.types.PrimitiveType.MetaClass,true,true);
                primitivePlatformTypeSeq=m3i.filterSeq(@(x)strcmp(x.Name,swBaseTypeName),primitiveTypeSeq);
                if primitivePlatformTypeSeq.size==int32(1)


                    m3iImpType.Reference=primitivePlatformTypeSeq.at(1);
                else

                end
            end
            m3iMetaClass=Simulink.metamodel.types.SwBaseType.MetaClass;
            arPkg=m3iModel.RootPackage.at(1);
            assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModeli(arPkg,swBaseTypeName,m3iMetaClass);
            if seq.size()==0
                m3iSwBaseType=eval(['Simulink.metamodel.types.SwBaseType','(m3iModel)']);
                m3iSwBaseType.Name=swBaseTypeName;
                this.M3ISwBaseTypePkg.packagedElement.append(m3iSwBaseType);
            else
                m3iSwBaseType=seq.at(1);
            end
            m3iImpType.SwBaseType=m3iSwBaseType;
        end
    end

    methods(Static,Access=public)
        function swBaseTypeName=getSwBaseTypeNameFromImpType(m3iImpType,isAdaptive)


            switch(class(m3iImpType))
            case{'Simulink.metamodel.types.FixedPoint',...
                'Simulink.metamodel.types.Integer',...
                'Simulink.metamodel.types.Enumeration'}
                if m3iImpType.IsSigned
                    if isAdaptive
                        swBaseTypeName='int';
                    else
                        swBaseTypeName='sint';
                    end
                else
                    swBaseTypeName='uint';
                end
                if m3iImpType.Length.value<=8
                    numBits='8';
                elseif m3iImpType.Length.value<=16
                    numBits='16';
                elseif m3iImpType.Length.value<=32
                    numBits='32';
                elseif m3iImpType.Length.value<=64
                    numBits='64';
                else
                    assert(false,'number of bits should be less than or equal to 64');
                end
                swBaseTypeName=[swBaseTypeName,numBits];
                if isAdaptive
                    swBaseTypeName=[swBaseTypeName,'_t'];
                end
            case 'Simulink.metamodel.types.FloatingPoint'
                if m3iImpType.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Double
                    if isAdaptive
                        swBaseTypeName='double';
                    else
                        swBaseTypeName='float64';
                    end
                else
                    if isAdaptive
                        swBaseTypeName='float';
                    else
                        swBaseTypeName='float32';
                    end
                end
            case 'Simulink.metamodel.types.Boolean'
                if isAdaptive
                    swBaseTypeName='bool';
                else
                    swBaseTypeName='boolean';
                end
            case 'Simulink.metamodel.types.VoidPointer'
                assert(~isAdaptive,'No void pointer in adaptive');
                swBaseTypeName='void';
            case 'Simulink.metamodel.types.String'
                swBaseTypeName='MyStringBaseType';
            otherwise
                assert(false,'Unexpected class for m3iImpType');
            end
        end

        function platformTypes=getAdaptivePlatformTypes()
            platformTypes={'bool',...
            'uint8_t','uint16_t','uint32_t','uint64_t',...
            'int8_t','int16_t','int32_t','int64_t',...
            'float','double'};
        end
    end

    methods(Static,Access=private)
        function platformTypes=getClassicPlatformTypes()
            platformTypes={'boolean',...
            'uint8','uint16','uint32',...
            'sint8','sint16','sint32',...
            'float32','float64'};
        end
    end

end


