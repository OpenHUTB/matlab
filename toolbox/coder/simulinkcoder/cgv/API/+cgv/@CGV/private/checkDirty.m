

function this=checkDirty(this,error)



    dirtyModels={};





    models=find_mdlrefs(this.ModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    this.SubModels=models;
    for i=1:length(models)


        try
            dirty=get_param(models(i),'dirty');
            if strcmp(dirty,'on')
                dirtyModels{end+1}=models{i};%#ok<AGROW>
            end
        catch ME %#ok<NASGU>

        end
    end
    if~isempty(dirtyModels)
        modelList=char(dirtyModels(1));
        for i=2:length(dirtyModels)
            modelList=[modelList,', ',dirtyModels{i}];%#ok<AGROW>
        end
        if error
            DAStudio.error('RTW:cgv:ModifiedModel',modelList);
        else
            disp(DAStudio.message('RTW:cgv:ModifiedModel',modelList));
        end
    end
end

