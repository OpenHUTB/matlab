

function refModelNames=i_find_mdlrefs(modelName,optArgs)
    if nargin==1
        optArgs=struct();
    end

    if~isfield(optArgs,'RefModelNamesSoFar')
        optArgs.RefModelNamesSoFar={};
    end

    if~isfield(optArgs,'RecurseIntoModelReferences')
        optArgs.RecurseIntoModelReferences=false;
    end

    if~isfield(optArgs,'IgnoreInvalidModels')
        optArgs.IgnoreInvalidModels=true;
    end

    optArgs.RefModelNamesSoFar=[optArgs.RefModelNamesSoFar,modelName];
    refModelNames=cell(1,0);
    findOpts=Simulink.FindOptions('IncludeCommented',false,...
    'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks',true);
    refModelNamesCurr=cell(1,0);
    modelBlocks=Simulink.findBlocksOfType(modelName,'ModelReference',findOpts);
    for i=1:numel(modelBlocks)
        if strcmp(get_param(modelBlocks(i),'ProtectedModel'),'off')
            refModelNamesCurr=[refModelNamesCurr,get_param(modelBlocks(i),'ModelName')];%#ok<AGROW>
        end
    end
    refModelNamesCurr=unique(refModelNamesCurr);
    invalidModelNames={};
    for i=1:numel(refModelNamesCurr)
        if isempty(intersect(refModelNamesCurr{i},optArgs.RefModelNamesSoFar))
            try
                load_system(refModelNamesCurr{i});
            catch
                if optArgs.IgnoreInvalidModels
                    invalidModelNames{end+1}=refModelNamesCurr{i};%#ok<AGROW>
                end
                continue;
            end
            if optArgs.RecurseIntoModelReferences

                refModelNames=[refModelNames,Simulink.variant.utils.i_find_mdlrefs(refModelNamesCurr{i},optArgs)];%#ok<AGROW>
            end
            optArgs.RefModelNamesSoFar=[optArgs.RefModelNamesSoFar,refModelNamesCurr{i}];
        end
    end
    refModelNamesCurr=setdiff(refModelNamesCurr,invalidModelNames);
    refModelNames=unique([refModelNames,refModelNamesCurr]);
end
