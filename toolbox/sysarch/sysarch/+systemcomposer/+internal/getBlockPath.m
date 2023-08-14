function blockPath=getBlockPath(comp)





    blockPath=[];

    if isa(comp,'systemcomposer.arch.BaseComponent')
        comp=comp.getImpl;
    end

    if~isa(comp,'systemcomposer.architecture.model.design.BaseComponent')
        return;
    end

    qualName=comp.getQualifiedName;

    modelId=systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier(mf.zero.getModel(comp));
    rootArch=systemcomposer.loadModel(modelId.URI).Architecture.getImpl;

    systemcomposer.utilities.UUIDMap(mf.zero.Model);
    pathNames=systemcomposer.utilities.FullPathAPI.getComponentNames(qualName);

    paths={};
    curIdx=1;
    curPath=getEscapedName(rootArch.getName);
    parent=rootArch;
    numPathNames=length(pathNames);
    for i=2:numPathNames
        elem=parent.getComponent(pathNames{i});
        curPath=[curPath,'/',getEscapedName(elem.getName)];%#ok<AGROW>
        if elem.hasReferencedArchitecture&&i~=numPathNames
            paths{curIdx}=curPath;%#ok<AGROW>
            curIdx=curIdx+1;
            curPath=getEscapedName(elem.getArchitecture.getName);
        end
        parent=elem;
    end
    paths{curIdx}=curPath;

    blockPath=Simulink.BlockPath(paths);

end

function name=getEscapedName(n)
    name=strrep(n,'/','//');
end

