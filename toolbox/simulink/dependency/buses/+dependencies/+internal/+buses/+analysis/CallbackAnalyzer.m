classdef CallbackAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(GetAccess=private,SetAccess=immutable)
        Types(1,:)dependencies.internal.graph.Type;
        IsBlockBased(1,:)logical;
    end

    methods(Access=public)
        function this=CallbackAnalyzer()
            import dependencies.internal.analysis.simulink.ModelCallbackAnalyzer
            import dependencies.internal.analysis.simulink.BlockCallbackAnalyzer

            [mdlQueries,mdlTypes]=i_createQueries(ModelCallbackAnalyzer.ModelCallbacks,"//Model/","ModelCallback",Simulink.loadsave.Modifier.BlockPath);
            [libQueries,libTypes]=i_createQueries(ModelCallbackAnalyzer.ModelCallbacks,"//Library/","ModelCallback",Simulink.loadsave.Modifier.BlockPath);
            [blkQueries,blkTypes]=i_createQueries(BlockCallbackAnalyzer.BlockCallbacks,"//System/Block/","BlockCallback",Simulink.loadsave.Modifier.BlockPath);
            [sysQueries,sysTypes]=i_createQueries(BlockCallbackAnalyzer.SubSystemCallbacks,"//System/","BlockCallback",Simulink.loadsave.Modifier.BlockPath);
            [annQueries,annTypes]=i_createQueries(BlockCallbackAnalyzer.AnnotationCallbacks,"//System/Annotation/","AnnotationCallback",Simulink.loadsave.Modifier.AnnotationPath);

            this.addQueries([mdlQueries,libQueries,blkQueries,sysQueries,annQueries]);
            this.Types=[mdlTypes,libTypes,blkTypes,sysTypes,annTypes];
            this.IsBlockBased=[false(1,length([mdlTypes,libTypes])),...
            true(1,length([blkTypes,sysTypes,annTypes]))];
        end

        function deps=analyze(this,handler,fileNode,matches)
            import dependencies.internal.buses.util.CodeUtils;
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;

            busNode=handler.Analyzers.Bus.BusNode;
            busElement=busNode.Location{end};


            for n=1:length(this.Types)
                type=this.Types(n);
                codeMatches=matches{2*n-1};
                componentMatches=matches{2*n};

                isBlock=this.IsBlockBased(n);


                for m=1:length(codeMatches)
                    code=codeMatches(m).Value;
                    component=componentMatches(m).Value;

                    if isempty(CodeUtils.searchCode(code,busElement))
                        continue;
                    end

                    if isBlock
                        upComp=Component.createBlock(fileNode,component,handler.getSID(component));
                    else
                        upComp=Component(fileNode,component,type,0,"","","");
                    end

                    deps(end+1)=createBusDependency(...
                    upComp,busNode,type);%#ok<AGROW>
                end
            end
        end
    end
end

function[queries,types]=i_createQueries(callbacks,query,type,modifier)
    [queries,modifiedQueries,types]=cellfun(...
    @(callback)i_createQuery(callback,query,type,modifier),callbacks);

    queries=reshape([queries;modifiedQueries],1,[]);
end

function[query,modifiedQuery,type]=i_createQuery(callback,queryString,typeString,modifier)
    queryText=strcat(queryString,callback);
    query=Simulink.loadsave.Query(queryText);
    modifiedQuery=Simulink.loadsave.Query(queryText);
    modifiedQuery.Modifier=modifier;
    type=dependencies.internal.graph.Type(strcat(typeString,",",callback));
end
