classdef SimulinkModelAnalyzer<dependencies.internal.analysis.FileAnalyzer





    properties(Constant,Hidden)
        ResaveVersion=simulink_version("R2014b")
    end

    properties(Constant,Access=private)
        SIDAnalyzer=dependencies.internal.analysis.simulink.SimulinkIDAnalyzer
        SSIDAnalyzer=dependencies.internal.analysis.simulink.StateflowSSIDAnalyzer
    end

    properties(SetAccess=immutable)
        Analyzers(:,1)dependencies.internal.analysis.simulink.ModelAnalyzer
        Queries(1,1)dependencies.internal.analysis.simulink.QueryTable
    end

    properties
        AnalyzeUnsavedChanges(1,1)logical=false
    end

    methods

        function this=SimulinkModelAnalyzer(analyzers)

            if nargin==0
                analyzers=dependencies.internal.Registry.Instance.ModelAnalyzers;
            else
                idx=arrayfun(@(a)~isa(a,'dependencies.internal.analysis.simulink.SimulinkIDAnalyzer')&&~isa(a,'dependencies.internal.analysis.simulink.StateflowSSIDAnalyzer'),analyzers);
                analyzers=analyzers(idx);
                analyzers=analyzers(:);
            end


            this.Analyzers=[this.SIDAnalyzer;this.SSIDAnalyzer;analyzers];


            this.Queries=dependencies.internal.analysis.simulink.QueryTable;

            for n=1:length(this.Analyzers)
                queries=this.Analyzers(n).Queries;
                this.Queries.addTable(queries,n);
            end
        end

        function deps=analyze(this,handler,node)


            [nodeToAnalyze,oldName,wasResaved]=this.prepareNode(node);


            modelHandler=dependencies.internal.analysis.simulink.SimulinkHandler(handler,nodeToAnalyze.Path,oldName);

            version=modelHandler.ModelInfo.SimulinkVersion;
            if~version.valid
                deps=dependencies.internal.graph.Dependency.empty;
                if modelHandler.ModelInfo.IsValid
                    node.setProperty("futureRelease","true");
                else
                    node.setProperty("invalidFormat","true");
                end
            else

                [queries,owner]=this.getQueries(modelHandler);


                matches=this.runQueries(nodeToAnalyze,queries);


                [~,newName]=fileparts(nodeToAnalyze.Path);
                if~strcmp(oldName,newName)
                    matches=this.rewriteMatches(queries,matches,newName,oldName);
                end


                deps=this.analyzeMatches(modelHandler,node,queries,matches,owner);
            end


            if wasResaved
                delete(nodeToAnalyze.Path);
            end
        end

    end

    methods(Access=protected)

        function[node,oldName,wasResaved]=prepareNode(this,node)
            [~,oldName]=fileparts(node.Path);
            if this.isDirty(node.Path,oldName)||this.isOld(node.Path)
                tmpFile=dependencies.internal.analysis.simulink.saveModelToLatestVersion(node.Path);
                node=dependencies.internal.graph.Node.createFileNode(tmpFile);
                wasResaved=true;
            else
                wasResaved=false;
            end
        end

        function isDirty=isDirty(this,file,model)
            isDirty=this.AnalyzeUnsavedChanges...
            &&bdIsLoaded(model)...
            &&strcmp(get_param(model,'Filename'),file)...
            &&strcmp(get_param(model,'Dirty'),'on');
        end

        function isOld=isOld(this,file)
            info=Simulink.MDLInfo(file);
            version=simulink_version(info.SimulinkVersion);
            isOld=version.valid&&version<=this.ResaveVersion;
        end

        function[queries,owner]=getQueries(this,handler)
            if handler.ModelInfo.IsSLX
                type='slx';
            else
                type='mdl';
            end
            version=handler.ModelInfo.SimulinkVersion.version;
            [queries,owner]=this.Queries.select(type,version);
        end

        function matches=runQueries(~,node,queries)
            queries=num2cell(queries);
            matches=cell(size(queries));
            [matches{:}]=Simulink.loadsave.findAll(node.Path,queries{:});
            for n=1:length(matches)
                matches{n}=matches{n}{1};
            end
        end

        function matches=rewriteMatches(~,queries,matches,name,newName)
            for n=1:numel(matches)
                if ismember(queries(n).Modifier,[Simulink.loadsave.Modifier.BlockPath,Simulink.loadsave.Modifier.AnnotationPath])
                    for m=1:numel(matches{n})
                        matches{n}(m)=Simulink.loadsave.Match(...
                        matches{n}(m).Hint,...
                        matches{n}(m).Path,...
                        regexprep(matches{n}(m).Value,['^',name,'($|(?=/))'],newName));
                    end
                end
            end
        end

        function deps=analyzeMatches(this,handler,node,~,matches,owner)
            deps=repmat({dependencies.internal.graph.Dependency.empty},size(this.Analyzers));
            for n=1:length(this.Analyzers)
                try
                    ownedMatches=matches(owner==n);
                    if this.Analyzers(n).AlwaysAnalyze||~all(cellfun('isempty',ownedMatches))
                        deps{n}=this.Analyzers(n).analyze(handler,node,ownedMatches);
                    end
                catch exception
                    handler.error(exception);
                end
            end
            deps=[deps{:}];
        end

    end

end
