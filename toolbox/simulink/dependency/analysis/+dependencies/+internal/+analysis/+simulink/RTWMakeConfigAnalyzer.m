classdef RTWMakeConfigAnalyzer<dependencies.internal.analysis.FileAnalyzer






















    properties(Constant)
        CustomSourceType='CustomSource';
        CustomLibraryType='CustomLibrary';
        Extensions=[".m",".mlx"];
    end

    methods

        function analyze=canAnalyze(this,handler,node)
            analyze=canAnalyze@dependencies.internal.analysis.FileAnalyzer(this,handler,node);
            if analyze
                [~,f]=fileparts(node.Location{1});
                analyze=strcmp(f,'rtwmakecfg');
            end
        end

        function deps=analyze(this,~,node)

            cachePwd=pwd;
            pwdCleanup=onCleanup(@()cd(cachePwd));


            path=fileparts(node.Path);
            cd(path);


            rtwStruct=rtwmakecfg;


            deps=[...
            i_resolveSourceFiles(node,rtwStruct,this.CustomSourceType),...
            i_resolveLinkLibsObjs(node,rtwStruct,this.CustomLibraryType),...
            i_resolveLibraryFiles(node,rtwStruct,this.CustomLibraryType),...
            i_resolveLibrarySourceFiles(node,rtwStruct,this.CustomSourceType)];
        end

    end

end


function deps=i_resolveSourceFiles(node,rtwStruct,type)
    deps=dependencies.internal.graph.Dependency.empty(1,0);

    if~isfield(rtwStruct,'sources')||~isfield(rtwStruct,'sourcePath')
        return;
    end

    for n=1:numel(rtwStruct.sources)
        target=i_resolveOnPaths(rtwStruct.sourcePath,rtwStruct.sources{n},string.empty);
        if~isempty(target)
            deps(end+1)=dependencies.internal.graph.Dependency(node,'',target,'',type);%#ok<AGROW>
        end
    end
end


function deps=i_resolveLinkLibsObjs(node,rtwStruct,type)
    deps=dependencies.internal.graph.Dependency.empty(1,0);

    if~isfield(rtwStruct,'linkLibsObjs')
        return;
    end

    for n=1:numel(rtwStruct.linkLibsObjs)
        target=dependencies.internal.graph.Node.createFileNode(rtwStruct.linkLibsObjs{n});
        deps(end+1)=dependencies.internal.graph.Dependency(node,'',target,'',type);%#ok<AGROW>
    end
end


function deps=i_resolveLibraryFiles(node,rtwStruct,type)
    deps=dependencies.internal.graph.Dependency.empty(1,0);

    if~isfield(rtwStruct,'library')||~isfield(rtwStruct.library,'Name')||~isfield(rtwStruct.library,'Location')
        return;
    end

    for n=1:numel(rtwStruct.library)
        path=fullfile(rtwStruct.library(n).Location,rtwStruct.library(n).Name);
        target=dependencies.internal.analysis.findFile(path,[".a",".lib"]);
        deps(end+1)=dependencies.internal.graph.Dependency(node,'',target,'',type);%#ok<AGROW>
    end
end


function deps=i_resolveLibrarySourceFiles(node,rtwStruct,type)
    deps=dependencies.internal.graph.Dependency.empty(1,0);

    if~isfield(rtwStruct,'library')||~isfield(rtwStruct.library,'Modules')||~isfield(rtwStruct,'sourcePath')
        return;
    end

    for l=1:numel(rtwStruct.library)
        modules=rtwStruct.library(l).Modules;
        for n=1:numel(modules)
            target=i_resolveOnPaths(rtwStruct.sourcePath,modules{n},[".c",".cpp"]);
            if~isempty(target)
                deps(end+1)=dependencies.internal.graph.Dependency(node,'',target,'',type);%#ok<AGROW>
            end
        end
    end

end


function target=i_resolveOnPaths(paths,name,extensions)
    for m=1:numel(paths)
        path=fullfile(paths{m},name);
        target=dependencies.internal.analysis.findFile(path,extensions);
        if target.Resolved
            return;
        end
    end

    target=dependencies.internal.graph.Node.empty(1,0);
end

