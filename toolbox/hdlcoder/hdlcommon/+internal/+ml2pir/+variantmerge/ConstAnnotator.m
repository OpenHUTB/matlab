classdef ConstAnnotator<internal.mtree.analysis.ConstAnnotator







    methods(Static)

        function run(functionInfoRegistry)
            import internal.mtree.analysis.ConstAnnotator.*

            fcnTypeInfos=functionInfoRegistry.getAllFunctionTypeInfos();
            analyzers=containers.Map();

            assert(numel(fcnTypeInfos)==1,'Variant Merge block expects only one function')
            functionTypeInfo=fcnTypeInfos{1};
            analyzer=internal.ml2pir.variantmerge.ConstAnnotator(functionTypeInfo,functionInfoRegistry,analyzers);
            analyzers(fcnTypeInfos{1}.specializationName)=analyzer;
            topLevelAnalyzers={analyzer};

            analyzers=analyzers.values();


            warnStates=warning('off','all');

            runAll(topLevelAnalyzers,analyzers);


            for i=1:numel(warnStates)
                s=warnStates(i);
                warning(s.state,s.identifier);
            end
        end

    end

    methods(Access=protected)

        function type=getTypeFromMTree(this,node,~)
            type=internal.mtree.type.UnknownType;
            if strcmp(node.kind,'ID')

                varInfo=this.FunctionTypeInfo.getVarInfo(node.tree2str);
                if~isempty(varInfo)
                    type=internal.mtree.Type.fromVarTypeInfo(varInfo);
                end
            end
        end
    end
end



