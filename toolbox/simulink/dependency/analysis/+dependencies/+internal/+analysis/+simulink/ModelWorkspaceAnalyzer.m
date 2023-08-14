classdef ModelWorkspaceAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        ModelWorkspaceType='ModelWorkspace';
    end

    properties(Access=private,Constant)
        WorkspaceMxArrayPart="/simulink/modelWorkspace.mxarray";
        WorkspaceMatFilePart="/simulink/modelworkspace.mat";
    end

    methods

        function this=ModelWorkspaceAnalyzer()
            this@dependencies.internal.analysis.simulink.ModelAnalyzer(true);

            queries=[

            Simulink.loadsave.Query('/Model/WSSourceFileName')
            Simulink.loadsave.Query('/Model/WSMATLABCode')

            Simulink.loadsave.Query('/ModelInformation/Model/ModelWorkspace/WSSourceFileName')
            Simulink.loadsave.Query('/ModelInformation/Model/ModelWorkspace/WSMATLABCode')

            Simulink.loadsave.Query('/Model/WSMdlFileData');
            ];

            this.addQueries(queries,{'mdl';'mdl';'slx';'slx';'mdl'});
        end

        function deps=analyze(this,handler,node,matches)
            import dependencies.internal.graph.Component;
            deps=dependencies.internal.graph.Dependency.empty;


            if~isempty(matches{1})
                filename=matches{1}(1).Value;


                [~,~,ext]=fileparts(filename);
                if isempty(ext)
                    ext='.mat';
                    filename=[filename,ext];
                end


                target=handler.Resolver.findFile(node,filename,[".mat",".m"]);
                deps=dependencies.internal.graph.Dependency(node,'',target,'',this.ModelWorkspaceType);


                if target.Resolved
                    switch ext
                    case '.mat'
                        vars=dependencies.internal.analysis.readVariables(target.Location{1});
                        handler.ModelWorkspace.addVariables(vars);
                    case '.m'
                        factory=dependencies.internal.analysis.DependencyFactory(...
                        handler,Component.createRoot(node),this.ModelWorkspaceType);
                        code=matlab.internal.getCode(target.Location{1});
                        handler.Analyzers.MATLAB.analyze(code,factory,handler.ModelWorkspace);
                    end
                end
            end


            if~isempty(matches{2})
                factory=dependencies.internal.analysis.DependencyFactory(...
                handler,Component.createRoot(node),this.ModelWorkspaceType);
                code=matches{2}(1).Value;
                deps=[deps,handler.Analyzers.MATLAB.analyze(code,factory,handler.ModelWorkspace)];
            end


            if handler.ModelInfo.IsSLX
                this.analyzeFromModelFile(handler);
            elseif~isempty(matches{3})
                data=dependencies.internal.analysis.simulink.readMxData(...
                handler,matches{3}(1).Value);
                handler.ModelWorkspace.addVariables({data.Name});
            end
        end

        function analyzeFromModelFile(this,handler)
            reader=Simulink.loadsave.SLXPackageReader(handler.ModelInfo.ResavedPath);
            if reader.hasPart(this.WorkspaceMxArrayPart)

                origWarn=warning('off');
                cleanup=onCleanup(@()warning(origWarn));
                ws=reader.readPartToVariable(this.WorkspaceMxArrayPart);
                names=fieldnames(ws);
                values=struct2cell(ws);
                types=cellfun(@class,values,'UniformOutput',false);
                vars=struct('Name',names,'Type',types);
                for i=1:numel(vars)
                    handler.ModelWorkspace.addVariables(...
                    dependencies.internal.analysis.matlab.Variable(vars(i).Name,{vars(i).Type}));
                end

            elseif reader.hasPart(this.WorkspaceMatFilePart)

                origWarn=warning('off');
                cleanup=onCleanup(@()warning(origWarn));

                vars=dependencies.internal.analysis.simulink.readMatData(...
                reader,this.WorkspaceMatFilePart,...
                @(file)dependencies.internal.analysis.readVariables(file));
                handler.ModelWorkspace.addVariables(vars);

            end
        end

    end

end
