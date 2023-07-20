classdef ProfileAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        SystemComposerType="SystemComposer";
        ProfileType=dependencies.internal.analysis.sysarch.ProfileNodeAnalyzer.ProfileType;
        Extensions=dependencies.internal.analysis.sysarch.ProfileNodeAnalyzer.Extensions;
    end

    properties(Constant,Access=private)
        SystemComposerToolbox=dependencies.internal.graph.Nodes.createProductNode("ZC");
    end

    methods

        function this=ProfileAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery;
            queries.Domain=BlockParameterQuery.createSystemParameterQuery("SimulinkSubDomain");

            import dependencies.internal.analysis.simulink.queries.MF0Query
            queries.Profiles=MF0Query("systemcomposer.internal.resolver.ProfileResolver","URI");
            queries.ExternalProfiles=MF0Query("systemcomposer.profile.ProfileResolver","URI");

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            deps=dependencies.internal.graph.Dependency.empty(1,0);


            if strcmp("Architecture",matches.Domain.Value)
                deps(end+1)=dependencies.internal.graph.Dependency.createToolbox(...
                node,"",this.SystemComposerToolbox,this.SystemComposerType);
            end


            profiles=[matches.Profiles.Names,matches.ExternalProfiles.Names];
            valid=profiles~="systemcomposer";

            for profile=profiles(valid)
                target=dependencies.internal.analysis.sysarch.resolveProfile(handler,node,profile);
                deps(end+1)=dependencies.internal.graph.Dependency(...
                node,"",target,"",this.ProfileType);%#ok<AGROW>
            end
        end

    end

end
