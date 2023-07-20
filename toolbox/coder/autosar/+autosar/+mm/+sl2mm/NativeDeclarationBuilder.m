classdef NativeDeclarationBuilder<handle




    properties
        TargetNativeSettingsValue;
        TargetNativeSettingsString;
    end

    properties(Constant)

        TargetNativeProperties={'ProdBitPerChar',...
        'ProdBitPerShort',...
        'ProdBitPerInt',...
        'ProdBitPerLong',...
        'ProdBitPerLongLong'};


        TargetNativeDefaults={8,16,32,64,64};


        CIntegralNames={'char','short','int','long','long long'};
    end

    methods(Access=public)
        function this=NativeDeclarationBuilder(modelName)
            this.TargetNativeSettingsValue=containers.Map;
            this.TargetNativeSettingsString=containers.Map;


            settingsKeys=this.TargetNativeProperties;

            if~isempty(modelName)&&bdIsLoaded(modelName)
                for i=1:numel(settingsKeys)
                    settingName=settingsKeys{i};
                    this.TargetNativeSettingsValue(settingName)=get_param(modelName,settingName);
                end
            else
                for i=1:numel(settingsKeys)
                    settingName=settingsKeys{i};
                    this.TargetNativeSettingsValue(settingName)=this.TargetNativeDefaults{i};
                end
            end

            for i=1:numel(settingsKeys)
                settingName=settingsKeys{i};
                this.TargetNativeSettingsString(settingName)=this.CIntegralNames{i};
            end
        end


        function nativeDeclaration=getNativeDeclaration(this,m3iPrimitiveType)
            import autosar.mm.util.XmlOptionsAdapter;
            import autosar.mm.Model;

            nativeDeclaration='';

            arRoot=m3iPrimitiveType.rootModel.RootPackage.front();
            nativeDeclarationOptionValue=XmlOptionsAdapter.get(arRoot,'NativeDeclaration');
            switch(nativeDeclarationOptionValue)
            case 'PlatformTypeName'
                nativeDeclaration=autosarcore.mm.sl2mm.SwBaseTypeBuilder.getSwBaseTypeNameFromImpType(m3iPrimitiveType,false);
            case 'CIntegralTypeName'

                switch class(m3iPrimitiveType)
                case{'Simulink.metamodel.types.Integer','Simulink.metamodel.types.FixedPoint'}
                    nativeDeclaration=this.inferCNativeDeclaration(m3iPrimitiveType.Length.value,m3iPrimitiveType.IsSigned);
                case 'Simulink.metamodel.types.FloatingPoint'
                    if strcmp(m3iPrimitiveType.Kind.toString,'IEEE_Single')
                        nativeDeclaration='float';
                    else
                        nativeDeclaration='double';
                    end
                case 'Simulink.metamodel.types.Boolean'
                    nativeDeclaration=this.inferCNativeDeclaration(8,false);
                case 'Simulink.metamodel.types.Enumeration'
                    nativeDeclaration=this.inferCNativeDeclaration(m3iPrimitiveType.Length.value,m3iPrimitiveType.IsSigned);
                case 'Simulink.metamodel.types.String'

                otherwise
                    assert(false,'Unexpected class of m3iPrimitiveType %s!',class(m3iPrimitiveType));
                end

            otherwise
                assert(false,'Unexpected enumeration for NativeDeclaration %s!',class(m3iPrimitiveType));
            end
        end
    end

    methods(Access=private)


        function nativeDeclaration=inferCNativeDeclaration(this,length,isSigned)
            nativeDeclaration='';

            if isSigned
                sign='signed';
            else
                sign='unsigned';
            end

            if length<=8
                length=8;
            elseif length<=16
                length=16;
            elseif length<=32
                length=32;
            elseif length<=64
                length=64;
            end

            settingsKeys=this.TargetNativeProperties;
            for i=1:numel(settingsKeys)
                settingName=settingsKeys{i};
                settingSize=this.TargetNativeSettingsValue(settingName);

                if(length==settingSize)
                    nativeDeclaration=this.TargetNativeSettingsString(settingName);
                    break;
                end
            end

            if isempty(nativeDeclaration)
                assert(length>=0&&length<=64,'0 to 64 bit fixed/integer types supported only');


                nativeDeclaration=this.TargetNativeSettingsString('ProdBitPerChar');
            end

            nativeDeclaration=sprintf('%s %s',sign,nativeDeclaration);
        end

    end
end


