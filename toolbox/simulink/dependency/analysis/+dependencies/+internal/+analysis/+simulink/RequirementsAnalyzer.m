classdef RequirementsAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        RequirementType=dependencies.internal.graph.Type("RequirementInfo");
        SimulinkRequirementType=dependencies.internal.graph.Type("RequirementInfo,Simulink");
        StateflowRequirementType=dependencies.internal.graph.Type("RequirementInfo,Stateflow");
    end

    methods

        function this=RequirementsAnalyzer()
            import dependencies.internal.analysis.simulink.queries.ModelParameterQuery
            import dependencies.internal.analysis.simulink.queries.BlockParameterQuery
            import dependencies.internal.analysis.simulink.queries.StateflowQuery

            this@dependencies.internal.analysis.simulink.AdvancedModelAnalyzer(true)

            queries.models=ModelParameterQuery("RequirementInfo");
            queries.blocks=BlockParameterQuery.createParameterQuery("RequirementInfo");
            queries.subsystem=BlockParameterQuery.createSystemParameterQuery("RequirementInfo");
            queries.states=StateflowQuery.createStateQuery("requirementInfo");
            queries.transitions=StateflowQuery.createTransitionQuery("requirementInfo");

            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            import dependencies.internal.util.resolveExternalRequirementLinks

            deps=dependencies.internal.graph.Dependency.empty;
            [~,model]=fileparts(node.Location{1});


            values=[matches.models.Value,matches.blocks.Value,matches.subsystem.Value];
            if~isempty(values)
                models=repmat({handler.ModelInfo.BlockDiagramName},size(matches.models.Value));
                paths=[models,matches.blocks.BlockPath,matches.subsystem.BlockPath];
                components=i_createSimulinkComponents(handler,paths,node,model);
                deps=i_findLinks(handler,node,values,components,this.SimulinkRequirementType);
            end


            sfMatches=[matches.states,matches.transitions];
            if~isempty(sfMatches)
                components=i_createStateflowComponents(sfMatches,model);
                deps=[deps,i_findLinks(handler,node,[sfMatches.Value],components,this.StateflowRequirementType)];
            end


            reqDeps=resolveExternalRequirementLinks(handler,node,this.RequirementType,...
            @(sid,compNode)i_getComponentFromSID(handler,this.RequirementType,sid,compNode));
            if~isempty(reqDeps)
                deps=[deps,reqDeps];
            end
        end

    end

end


function deps=i_findLinks(handler,node,values,components,type)
    deps=dependencies.internal.graph.Dependency.empty;

    numLinks=length(values);
    for i=1:numLinks
        if isempty(values{i})
            continue;
        end

        try
            [~,links]=evalc(values{i});
        catch
            continue;
        end

        if~iscell(links)
            continue;
        end

        dim=size(links);
        for j=1:dim(1)
            link=links(j,:);
            reqType=link{1};
            reqPath=link{2};
            reqId=link{3};
            reqSID=handler.getSID(reqId);
            deps=[deps,dependencies.internal.util.resolveRequirementLink(...
            node,components(i),reqType,reqPath,reqId,reqSID,type)];%#ok<AGROW>
        end
    end

end

function components=i_createSimulinkComponents(handler,paths,node,model)
    import dependencies.internal.graph.Component;
    components=repmat(Component.createRoot(node),1,length(paths));
    isBlockPaths=~strcmp(paths,model);
    components(isBlockPaths)=Component.createBlock(repmat(node,size(paths(isBlockPaths))),paths(isBlockPaths),i_getSIDsFromPaths(handler,paths(isBlockPaths)));
end

function sids=i_getSIDsFromPaths(handler,paths)
    sids=cell(1,length(paths));
    for n=1:length(paths)
        sids{n}=handler.getSID(paths{n});
    end
end

function components=i_createStateflowComponents(matches,model)
    import dependencies.internal.graph.Component;
    components=repmat(Component.createRoot(matches(1).Node),1,length(matches));
    for n=1:length(matches)
        if~strcmp(matches(n).Path,model)
            components(n)=matches(n).createComponent();
        end
    end
end

function component=i_getComponentFromSID(handler,type,sid,compNode)
    import dependencies.internal.graph.Component;
    if isempty(sid)
        component=Component.createRoot(compNode);
    else
        fullSid=strip(sid,':');
        fullSid=strtok(fullSid,'.');
        [mainSid,SSID]=strtok(fullSid,':');
        path=handler.getPath(mainSid);
        if isempty(SSID)
            component=Component.createBlock(compNode,path,fullSid);
        else
            component=Component(compNode,strcat(path,SSID),type,0,"",strcat(path,SSID),fullSid);
        end
    end
end
