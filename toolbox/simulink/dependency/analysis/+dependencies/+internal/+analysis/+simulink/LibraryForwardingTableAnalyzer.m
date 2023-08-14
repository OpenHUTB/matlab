classdef LibraryForwardingTableAnalyzer<dependencies.internal.analysis.simulink.ModelAnalyzer




    properties(Constant)
        LibraryForwardingTableType=dependencies.internal.graph.Type("LibraryLink,ForwardingTable");
        LibraryForwardingTransformType='LibraryLink,ForwardingTransform';
    end

    methods

        function this=LibraryForwardingTableAnalyzer()

            mdlString=Simulink.loadsave.Query('/Library/ForwardingTableString');
            slxString=Simulink.loadsave.Query('/ModelInformation/Library/ForwardingTableString');


            newBlock=Simulink.loadsave.Query('/ForwardingTable/Entry/NewBlock');
            transform=Simulink.loadsave.Query('/ForwardingTable/Entry/TransformationFunction');

            this.addQueries(...
            [mdlString;slxString;newBlock;transform],...
            {'mdl';'slx';'slx';'slx'},...
            [0;0;8.4;8.4],...
            [Inf;8.3;Inf;Inf]);
        end

        function deps=analyze(this,handler,node,matches)
            deps=dependencies.internal.graph.Dependency.empty;

            if length(matches)==1

                ftStrings={matches{1}.Value};
                for n=1:length(ftStrings)
                    parts=strsplit(ftStrings{n},'||','CollapseDelimiters',false);
                    for p=2:2:length(parts)
                        if p<length(parts)&&~isempty(parts{p+1})
                            switch parts{p}
                            case '__slNewName__'
                                deps(end+1)=this.createNewBlockNode(...
                                handler,node,parts{p+1});%#ok<AGROW>
                            case '__slTransformationFcn__'
                                deps(end+1)=this.createTransformationFunctionNode(...
                                handler,node,parts{p+1});%#ok<AGROW>
                            end
                        end
                    end
                end

            else

                newBlocks={matches{1}.Value};
                for n=find(~cellfun('isempty',newBlocks))
                    deps(end+1)=this.createNewBlockNode(...
                    handler,node,newBlocks{n});%#ok<AGROW>
                end


                transforms={matches{2}.Value};
                for n=find(~cellfun('isempty',transforms))
                    deps(end+1)=this.createTransformationFunctionNode(...
                    handler,node,transforms{n});%#ok<AGROW>
                end
            end
        end

    end

    methods(Access=private)
        function dep=createNewBlockNode(this,handler,node,path)
            import dependencies.internal.graph.Component;
            newModel=strtok(path,'/');
            target=handler.Analyzers.Simulink.resolve(node,newModel);
            downComp=Component.createBlock(target,path,"");
            dep=dependencies.internal.graph.Dependency.createSource(...
            Component.createRoot(node),downComp,...
            this.LibraryForwardingTableType);
        end


        function dep=createTransformationFunctionNode(this,handler,node,path)
            target=handler.Resolver.findFile(node,path,[".p",".m",".mlx"]);
            dep=dependencies.internal.graph.Dependency(node,'',target,'',...
            this.LibraryForwardingTransformType);
        end
    end

end
