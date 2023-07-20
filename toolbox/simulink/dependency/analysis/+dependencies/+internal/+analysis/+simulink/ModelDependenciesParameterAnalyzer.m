classdef ModelDependenciesParameterAnalyzer<dependencies.internal.analysis.simulink.AdvancedModelAnalyzer




    properties(Constant)
        ModelReferenceDependencyType='ModelReferenceDependency';
    end

    methods

        function this=ModelDependenciesParameterAnalyzer()
            import dependencies.internal.analysis.simulink.queries.ConfigSetQuery;
            queries.ModelDependencies=ConfigSetQuery('Simulink.ModelReferenceCC','ModelDependencies');
            this.addQueries(queries);
        end

        function deps=analyzeMatches(this,handler,node,matches)
            files=cellfun(@(matchParameter)i_GetModelRefDeps(handler,node,matchParameter),matches.ModelDependencies.Value,'UniformOutput',false);
            configset=matches.ModelDependencies.Configset;

            deps=dependencies.internal.graph.Dependency.empty;
            for i=1:length(files)
                for j=1:length(files{i})
                    target=handler.Resolver.findFile(node,files{i}{j},{});
                    deps(end+1)=dependencies.internal.graph.Dependency(...
                    node,'',target,'',[this.ModelReferenceDependencyType,',',configset{i}]);%#ok<AGROW>
                end
            end
        end

    end

end


function filenames=i_GetModelRefDeps(handler,node,dep_string)



    filenames={};

    [mdldir,mdlname]=fileparts(node.Location{1});








    dep_string=i_strip_comments(dep_string);
    if isempty(dep_string)
        return
    end

    try
        [~,deps]=evalc(dep_string);
    catch ME
        key='SimulinkDependencyAnalysis:Engine:BadModelReferenceDependencies';
        warning=dependencies.internal.graph.Warning(...
        key,message(key,mdlname,ME.message).getString,'',...
        dependencies.internal.analysis.simulink.ModelDependenciesParameterAnalyzer.ModelReferenceDependencyType);
        handler.warning(warning);
        return;
    end

    if~iscellstr(deps)
        key='SimulinkDependencyAnalysis:Engine:BadModelReferenceDependencies';
        warning=dependencies.internal.graph.Warning(...
        key,message(key,mdlname,message('SimulinkDependencyAnalysis:Engine:EvalNotCellstr').getString).getString,'',...
        dependencies.internal.analysis.simulink.ModelDependenciesParameterAnalyzer.ModelReferenceDependencyType);
        handler.warning(warning);
        return;
    end


    filenames=cell(size(deps));



    for i=1:numel(deps)
        entry=deps{i};



        if~isempty(regexp(entry,'^\$MDL.*','once'))
            entry=strrep(entry,'$MDL',mdldir);
        end



        depInfo=dir(entry);
        if~isempty(depInfo)

            depInfo=depInfo(~[depInfo.isdir]);

            depList=cell(numel(depInfo),1);
            dirname=fileparts(entry);
            for k=1:numel(depInfo)
                depList{k}=fullfile(dirname,depInfo(k).name);
            end
        elseif any(entry=='*')


            depList={};
        else



            depList={entry};
        end
        filenames{i}=depList;
    end

    filenames=vertcat(filenames{:});

end








function oStr=i_strip_comments(iStr)

    newLIdx=regexp(iStr,'\n');
    strlen=length(iStr);
    newLineLength=length(sprintf('\n'));
    str=[];
    startIdx=1;
    numRows=length(newLIdx);
    for i=1:length(newLIdx)
        str{i}=iStr(startIdx:newLIdx(i));%#ok
        startIdx=newLIdx(i)+newLineLength;
    end


    if(startIdx<strlen)
        str{length(newLIdx)+1}=iStr(startIdx:end);
        numRows=numRows+1;
    end

    oStr='';
    for i=1:numRows
        s=regexp(str{i},'^\s*%','once');
        if isempty(s)
            oStr=[oStr,str{i}];%#ok<AGROW>
        end
    end

    oStr=strtrim(oStr);
end
