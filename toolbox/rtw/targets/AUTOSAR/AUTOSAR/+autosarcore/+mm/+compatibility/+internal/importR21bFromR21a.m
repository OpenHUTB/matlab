function importR21bFromR21a(transformer)




    transformer.setPostModelTransform(@postModelTransform);
    function m3iModel=postModelTransform(m3iModel)
        addSwBaseTypesToImpTypes(m3iModel);
    end
end


function addSwBaseTypesToImpTypes(m3iModel)



    doRecursion=true;
    isSuperClass=true;
    m3iTypeSeq=autosarcore.MetaModelFinder.findObjectByMetaClass(m3iModel,...
    Simulink.metamodel.types.PrimitiveType.MetaClass,doRecursion,isSuperClass);






    isAdaptive=false;
    m3iSwBaseTypePkg=getOrAddM3ISwBaseTypePackage(m3iModel);
    swBaseTypeBuilder=autosarcore.mm.sl2mm.SwBaseTypeBuilder(...
    m3iSwBaseTypePkg,isAdaptive);
    for typeIdx=1:m3iTypeSeq.size()
        curM3IType=m3iTypeSeq.at(typeIdx);
        if~curM3IType.IsApplication&&~curM3IType.SwBaseType.isvalid()&&...
            isempty(curM3IType.Reference)

            swBaseTypeBuilder.addSwBaseType(curM3IType);
            setUUIDOnSwBaseType(curM3IType);
        end
    end

end

function m3iSwBaseTypePkg=getOrAddM3ISwBaseTypePackage(m3iModel)

    arRoot=m3iModel.RootPackage.front;
    toolId='ARXML_SwBaseTypePackage';
    swBaseTypePkgInfo=autosarcore.ModelUtils.getExtraExternalToolInfo(...
    arRoot,toolId,{'Value','Type'},{'%s','%s'});
    swBaseTypePkg=swBaseTypePkgInfo.Value;
    if isempty(swBaseTypePkg)
        swBaseTypePkg=[arRoot.DataTypePackage,'/'...
        ,autosarcore.mm.sl2mm.SwBaseTypeBuilder.DefaultPackage];
    end
    m3iSwBaseTypePkg=autosarcore.MetaModelFinder.getOrAddARPackage(m3iModel,...
    swBaseTypePkg);
end

function setUUIDOnSwBaseType(m3iImpType)


    toolId='ARXML_SW-BASE-TYPE';
    extraInfo=autosarcore.ModelUtils.getExtraExternalToolInfo(...
    m3iImpType,toolId,{'uuid'},{'%s'});
    if~isempty(extraInfo.uuid)
        autosarcore.ModelUtils.setExtraExternalToolInfo(m3iImpType.SwBaseType,...
        'ARXML',{'%s'},{extraInfo.uuid});
        m3iImpType.removeExternalToolInfo(M3I.ExternalToolInfo(toolId,''))
    end
end


