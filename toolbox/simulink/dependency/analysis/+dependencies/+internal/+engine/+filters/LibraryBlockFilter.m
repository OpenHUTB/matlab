classdef LibraryBlockFilter<dependencies.internal.engine.AnalysisFilter




    properties(Access=private)
        Nodes(1,:)dependencies.internal.graph.Node;
        Dependencies(1,:)dependencies.internal.graph.Dependency;
        Components(1,:)string;
        LibraryCache;
    end

    properties(Constant,Access=private)
        NodeFilter=dependencies.internal.graph.NodeFilter.fileExists([".slx",".mdl"]);
        DependencyFilter=dependencies.internal.graph.DependencyFilter.dependencyType("LibraryLink");
    end

    methods(Static)
        function filter=create(varargin)
            import dependencies.internal.engine.filters.MatlabFilter;
            import dependencies.internal.engine.filters.LibraryBlockFilter;
            filter=MatlabFilter(LibraryBlockFilter(varargin{:}));
        end
    end

    methods(Access=private)
        function this=LibraryBlockFilter(nodes)
            if nargin>0
                this.Nodes=nodes;
            end
            this.LibraryCache=containers.Map;
        end
    end

    methods
        function[accept,inject]=analyzeNodes(~,nodes)
            accept=true(size(nodes));
            inject=dependencies.internal.graph.Dependency.empty(1,0);
        end

        function[accept,inject]=analyzeDependencies(this,deps)
            import dependencies.internal.graph.NodeFilter.isMember;

            accept=true(size(deps));
            inject=dependencies.internal.graph.Dependency.empty(1,0);

            if isempty(deps)
                return;
            end


            libIdx=this.DependencyFilter.apply(deps);
            this.Components=[this.Components,arrayfun(@(dep)dep.DownstreamComponent.Path,deps(libIdx))];


            rootIdx=false(size(deps));
            rootIdx(~libIdx)=arrayfun(@this.isLibrary,[deps(~libIdx).DownstreamNode]);
            this.Nodes=[this.Nodes,deps(rootIdx).DownstreamNode];


            accept=~arrayfun(@this.isLibraryBlockDependency,deps);
            this.Dependencies=[this.Dependencies,deps(~accept)];


            if~isempty(this.Dependencies)
                components=arrayfun(@(dep)dep.UpstreamComponent.Path,this.Dependencies);
                nodes=[this.Dependencies.UpstreamNode];
                compIdx=startsWith(components,this.Components)|apply(isMember(this.Nodes),nodes);
                inject=this.Dependencies(compIdx);
                this.Dependencies(compIdx)=[];
            end
        end
    end

    methods(Access=private)
        function isLibrary=findLibrary(this,node)
            isLibrary=false;

            if~this.NodeFilter.apply(node)
                return;
            end

            try %#ok<TRYNC>
                [~,name]=slfileparts(node.Location{1});
                type=get_param(name,'LibraryType');
                isLibrary=~strcmp(type,'None');
                return;
            end

            try %#ok<TRYNC>
                info=Simulink.MDLInfo(node.Location{1});
                isLibrary=info.IsLibrary;
            end
        end

        function isLibrary=isLibrary(this,node)
            if this.LibraryCache.isKey(node.ID)
                isLibrary=this.LibraryCache(node.ID);
            else
                isLibrary=this.findLibrary(node);
                this.LibraryCache(node.ID)=isLibrary;
            end
        end

        function accept=isLibraryBlockDependency(this,dep)
            isLibrary=this.isLibrary(dep.UpstreamNode);
            if isLibrary
                [~,name]=slfileparts(dep.UpstreamNode.Location{1});
                accept=(dep.UpstreamComponent.Path~="")&&~strcmp(name,dep.UpstreamComponent.Path);
            else
                accept=false;
            end
        end
    end

end
