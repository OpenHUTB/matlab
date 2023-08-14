classdef BlockCallbackAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)

        BlockCallbacks={...
        'ClipboardFcn',...
        'CloseFcn',...
        'CopyFcn',...
        'DeleteFcn',...
        'DestroyFcn',...
        'ErrorFcn',...
        'InitFcn',...
        'LoadFcn',...
        'ModelCloseFcn',...
        'MoveFcn',...
        'NameChangeFcn',...
        'OpenFcn',...
        'ParentCloseFcn',...
        'PostSaveFcn',...
        'PreCopyFcn',...
        'PreDeleteFcn',...
        'PreSaveFcn',...
        'StartFcn',...
        'PauseFcn',...
        'ContinueFcn',...
        'StopFcn',...
'UndoDeleteFcn'
        };

        SubSystemCallbacks={...
'DeleteChildFcn'
        };

        AnnotationCallbacks={...
        'ClickFcn',...
        'LoadFcn',...
'DeleteFcn'
        };

    end

    properties(GetAccess=private,SetAccess=immutable)
        QueryNameTypeMap;
    end


    methods

        function this=BlockCallbackAnalyzer()
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createSystemParameterQuery
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createAnnotationParameterQuery

            this.QueryNameTypeMap=containers.Map;

            this.createQueries("BlockCallback",@createParameterQuery,dependencies.internal.analysis.simulink.BlockCallbackAnalyzer.BlockCallbacks);
            this.createQueries("BlockCallback",@createSystemParameterQuery,dependencies.internal.analysis.simulink.BlockCallbackAnalyzer.SubSystemCallbacks);
            this.createQueries("AnnotationCallback",@createAnnotationParameterQuery,dependencies.internal.analysis.simulink.BlockCallbackAnalyzer.AnnotationCallbacks);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            deps=dependencies.internal.graph.Dependency.empty;

            queryNames=this.QueryNameTypeMap.keys;


            for n=1:length(queryNames)
                matchName=queryNames{n};

                numMatches=numel(matches.(matchName).Value);
                callbackDeps=repmat({dependencies.internal.graph.Dependency.empty},1,numMatches);


                for m=1:numMatches
                    blockPath=matches.(matchName).BlockPath{m};
                    component=dependencies.internal.graph.Component.createBlock(node,blockPath,handler.getSID(blockPath));
                    type=this.QueryNameTypeMap.values({matchName});

                    factory=dependencies.internal.analysis.DependencyFactory(handler,component,type{:});
                    code=matches.(matchName).Value{m};

                    callbackDeps{m}=handler.Analyzers.MATLAB.analyze(code,factory);
                end

                deps=[deps,callbackDeps{:}];%#ok<AGROW>
            end
        end
    end

    methods(Access=private)
        function createQueries(this,type,queryConstructor,callbacks)
            queryNames=type+callbacks;
            queryTypes=type+","+callbacks;
            for n=1:length(callbacks)
                queries.(queryNames{n})=queryConstructor(callbacks{n});
                this.QueryNameTypeMap(queryNames{n})=queryTypes{n};
            end
            this.addQueries(queries);
        end
    end
end
