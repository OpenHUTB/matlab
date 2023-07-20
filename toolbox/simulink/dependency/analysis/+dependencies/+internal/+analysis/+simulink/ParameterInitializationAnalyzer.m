classdef ParameterInitializationAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        ParameterInitializationType='ParameterInitialization';
    end

    properties(Constant,Access=private)
        ParameterQueries=i_createQueries;
    end

    methods

        function this=ParameterInitializationAnalyzer()
            this.addQueries(this.ParameterQueries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.analysis.matlab.Scope;
            import dependencies.internal.graph.Component;

            deps=dependencies.internal.graph.Dependency.empty;
            allMatches=struct2array(matches);
            params=[allMatches.Value];
            blocks=[allMatches.BlockPath];



            for n=1:length(params)
                param=params{n};
                block=blocks{n};


                blkWorkspace=handler.getWorkspace(block);
                if blkWorkspace.isVariable(param,Scope.File)
                    continue;
                end


                blockComp=Component.createBlock(node,block,handler.getSID(block));
                factory=dependencies.internal.analysis.DependencyFactory(...
                handler,blockComp,this.ParameterInitializationType);
                factory.CreateUnresolved=false;
                newDeps=handler.Analyzers.MATLAB.analyze(param,factory,blkWorkspace);

                if~isempty(newDeps)
                    deps=[deps,newDeps];%#ok<AGROW>
                end
            end

        end

    end

end


function queries=i_createQueries()


    import dependencies.internal.analysis.simulink.queries.BlockParameterQuery.createParameterQuery

    queries=struct();

    parameterMap=i_findEvalParams;
    types=parameterMap.keys;

    queryCounter=1;
    for n=1:length(types)
        fields=parameterMap(types{n});
        for m=1:length(fields)
            queries.("q"+queryCounter)=createParameterQuery(fields{m},"BlockType",types{n});
            queryCounter=queryCounter+1;
        end
    end

end


function map=i_findEvalParams()



    origWarn=warning('off');
    cleanup=onCleanup(@()warning(origWarn));

    subsystem=get_param('built-in/Subsystem','ObjectParameters');
    ignore=fieldnames(subsystem);


    registered_block_types=get_param(0,'ListOfRegisteredBlocks');


    map=containers.Map;
    for n=1:length(registered_block_types)
        type=registered_block_types{n,1};
        if~any(strcmp(type,{'SubSystem','Reference'}))
            try %#ok<TRYNC>
                found=i_findParams(['built-in/',type],ignore);
                if~isempty(found)
                    map(type)=found;
                end
            end
        end
    end

end


function found=i_findParams(block,ignore)




    found={};

    params=get_param(block,'ObjectParameters');
    names=fieldnames(params);

    idx=find(~ismember(names,ignore));
    if isempty(idx)
        return;
    end

    for n=idx'
        field=names{n};
        param=params.(field);

        if strcmp(param.Type,'string')...
            &&~any(ismember(param.Attributes,{'dont-eval','read-only','never-save'}))...
            &&length(regexp(field,'^\w*$'))==1

            found{end+1}=field;%#ok<AGROW>
        end
    end

end
