function importR22bFromR22a(transformer)




    transformer.setPostModelTransform(@postModelTransform);
    function m3iModel=postModelTransform(m3iModel)
        if slfeature('AUTOSARPlatformTypesRefAndNativeDecl')
            setPlatformTypesXMLOptionsDefaults(m3iModel);
        end
    end
end


function setPlatformTypesXMLOptionsDefaults(m3iModel)
    arRoot=m3iModel.RootPackage.front;
    mustSetNativeDeclaration=false;

    propertiesToAdapt=containers.Map(...
    {...
    'PlatformDataTypePackage',...
    'UsePlatformTypeReferences',...
    'NativeDeclaration',...
    },...
    {...
    {'','String'},...
    {'BaseTypeReference','Enumeration'},...
    {'PlatformTypeName','Enumeration'},...
    });

    for k=keys(propertiesToAdapt)
        propName=k{1};
        mapValue=propertiesToAdapt(propName);
        propDefaultValue=mapValue{1};
        propType=mapValue{2};
        toolId=['ARXML_',propName];

        extraInfo=autosarcore.ModelUtils.getExtraExternalToolInfo(...
        arRoot,toolId,{'Value','Type'},{'%s','%s'});

        if isempty(extraInfo.Value)&&isempty(extraInfo.Type)
            autosarcore.ModelUtils.setExtraExternalToolInfo(arRoot,...
            toolId,...
            {'%s','%s'},...
            {propDefaultValue,propType});



            if strcmp(propName,'NativeDeclaration')
                mustSetNativeDeclaration=true;
            end
        end
    end

    if mustSetNativeDeclaration
        setNativeDeclarationDefaults(m3iModel);
    end
end


function setNativeDeclarationDefaults(m3iModel)

    adaptiveComponents=autosarcore.MetaModelFinder.findObjectByMetaClass(m3iModel,Simulink.metamodel.arplatform.component.AdaptiveApplication.MetaClass,true,true);
    isAdaptive=adaptiveComponents.size~=0;

    baseTypes=autosarcore.MetaModelFinder.findObjectByMetaClass(m3iModel,Simulink.metamodel.types.SwBaseType.MetaClass,true,true);
    for i=1:baseTypes.size()
        baseType=baseTypes.at(i);

        if baseType.PrimitiveType.size()~=0
            m3iPrimitiveType=baseType.PrimitiveType.front();
            baseType.NativeDeclaration=autosarcore.mm.sl2mm.SwBaseTypeBuilder.getSwBaseTypeNameFromImpType(m3iPrimitiveType,isAdaptive);
        end
    end

end


