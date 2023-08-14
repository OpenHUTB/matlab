function refModelNames=i_find_mdlrefs(modelName,optArgs)






    if nargin==1
        optArgs=struct();
    end

    if~isfield(optArgs,'RefModelNamesSoFar')
        optArgs.RefModelNamesSoFar={};
    end

    optArgs.RefModelNamesSoFar=[optArgs.RefModelNamesSoFar,modelName];

    refModelNames=cell(1,0);
    refModelNamesCurr=cell(1,0);
    modelBlocks=find_system(modelName,'IncludeCommented',false,...
    'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks',false,'skiplinks','on','BlockType','ModelReference');
    for i=1:numel(modelBlocks)
        if strcmp(get_param(modelBlocks(i),'ProtectedModel'),'off')
            refModelNamesCurr=[refModelNamesCurr,get_param(modelBlocks(i),'ModelName')];%#ok<AGROW>
        end
    end
    refModelNamesCurr=unique(refModelNamesCurr);
    invalidModelNames={};
    for i=1:numel(refModelNamesCurr)
        if isempty(intersect(refModelNamesCurr{i},optArgs.RefModelNamesSoFar))
            if isvarname(refModelNamesCurr{i})&&bdIsLoaded(refModelNamesCurr{i})

                refModelNames=[refModelNames,slvariants.internal.manager.core.i_find_mdlrefs(refModelNamesCurr{i},optArgs)];%#ok<AGROW>
                optArgs.RefModelNamesSoFar=[optArgs.RefModelNamesSoFar,refModelNamesCurr{i}];
            else
                invalidModelNames{end+1}=refModelNamesCurr{i};%#ok<AGROW>
            end
        end
    end
    refModelNamesCurr=setdiff(refModelNamesCurr,invalidModelNames);
    refModelNames=unique([refModelNames,refModelNamesCurr]);
end
