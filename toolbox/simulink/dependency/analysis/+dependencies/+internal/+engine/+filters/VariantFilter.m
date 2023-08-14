classdef VariantFilter<dependencies.internal.engine.AnalysisFilter




    methods(Static)
        function filter=create
            filter=dependencies.internal.engine.filters.VariantFilter;
            filter=dependencies.internal.engine.filters.MatlabFilter(filter);
        end
    end

    methods
        function[accepted,injected]=analyzeNodes(~,nodes)
            accepted=true(size(nodes));
            injected=dependencies.internal.graph.Dependency.empty(1,0);
        end

        function[accepted,injected]=analyzeDependencies(~,deps)
            injected=dependencies.internal.graph.Dependency.empty(1,0);
            accepted=logical(arrayfun(@i_analyzeDep,deps));
        end


    end

    methods(Access=private)
        function obj=VariantFilter(varargin)
        end
    end
end

function accepted=i_analyzeDep(dep)
    accepted=true;

    upNode=dep.UpstreamNode;
    upComp=dep.UpstreamComponent.Path;

    if~i_isModel(upNode)||(upComp=="")||...
        ~i_loadAndCompileSuccessfully(upNode.Location{1})
        return
    end

    accepted=i_isCompiledIsActiveOn(upComp);
end

function isModel=i_isModel(nodes)
    import dependencies.internal.util.isFileWithExtension
    isModel=isFileWithExtension(nodes,[".slx",".mdl"]);
end

function success=i_loadAndCompileSuccessfully(modelLocation)
    [~,modelName,~]=fileparts(modelLocation);
    try
        load_system(modelLocation);
        if bdIsLibrary(modelName)
            success=false;
        else
            feval(modelName,[],[],[],'compile');
            feval(modelName,[],[],[],'term');
            success=true;
        end
    catch
        success=false;
    end
end

function isOn=i_isCompiledIsActiveOn(comp)
    isOn=strcmp(get_param(comp,"CompiledIsActive"),"on");
end
