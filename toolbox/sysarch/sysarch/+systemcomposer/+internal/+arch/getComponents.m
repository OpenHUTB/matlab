function[cNames,comps]=getComponents(app)



    appName=app.getName;
    rootArch=systemcomposer.arch.Architecture(app.getTopLevelCompositionArchitecture);
    comps=rootArch.Components;

    cNames=generateHierarchicalNames(rootArch,appName,cell(0));
    cNames=cNames';

end






function[hierarchicalNames]=generateHierarchicalNames(arch,namePattern,hierarchicalNames)

    if(~isa(arch,'systemcomposer.arch.Architecture'))
        error('arch must be of type "systemcomposer.arch.Architecture"');
    end

    if(~isempty(arch))
        archComponents=arch.Components;
        for idx=1:numel(archComponents)
            compAbsolutePath=[namePattern,'/',archComponents(idx).Name];
            hierarchicalNames={hierarchicalNames{:},compAbsolutePath};%#ok<*CCAT>
            subCompAbsolutePath=generateHierarchicalNames(archComponents(idx).Architecture,compAbsolutePath,cell(0));
            hierarchicalNames={hierarchicalNames{:},subCompAbsolutePath{:}};
        end
    else
        return;
    end

end



