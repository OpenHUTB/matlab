classdef ProfileNodeAnalyzer<dependencies.internal.analysis.FileAnalyzer




    properties(Constant)
        ProfileType='SystemComposerProfile';
        Extensions=".xml";
    end

    methods

        function analyze=canAnalyze(this,handler,node)
            analyze=...
            canAnalyze@dependencies.internal.analysis.FileAnalyzer(this,handler,node)...
            &&dependencies.internal.analysis.sysarch.isProfile(node.Location{1});
        end

        function deps=analyze(this,handler,node)
            deps=dependencies.internal.graph.Dependency.empty;

            [~,name]=fileparts(node.Location{1});
            profiles=string(systemcomposer.internal.arch.internal.getDependentProfiles(name,true));

            for profile=profiles
                target=dependencies.internal.analysis.sysarch.resolveProfile(handler,node,profile);
                deps(end+1)=dependencies.internal.graph.Dependency(...
                node,"",target,"",this.ProfileType);%#ok<AGROW>
            end

            enums=string(systemcomposer.internal.arch.internal.getDependentEnumerationFiles(name));

            for enum=enums
                target=i_resolveEnumeration(handler,node,enum);
                deps(end+1)=dependencies.internal.graph.Dependency(...
                node,"",target,"",'Enumeration');%#ok<AGROW>
            end

            customIcons=string(systemcomposer.internal.arch.internal.getDependentStereotypeIconFiles(name));

            for customIcon=customIcons
                [~,name,ext]=fileparts(customIcon);
                target=handler.Resolver.findFile(node,name,ext);
                deps(end+1)=dependencies.internal.graph.Dependency(...
                node,"",target,"",'Icon');%#ok<AGROW>
            end
        end

    end

end

function target=i_resolveEnumeration(handler,node,name)

    target=handler.Resolver.findFile(node,name,".m");
    if target.Resolved&&~dependencies.internal.analysis.sysarch.isEnum(name)

        target=dependencies.internal.graph.Node.createFileNode(name);
    end

end
