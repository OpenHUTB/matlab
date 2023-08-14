function validateModel(modelName,projectFileName,projectContent,...
    tfUseSingleProject,modelNameValueArgumentName)
























    numModelsInProject=height(projectContent);

    if isempty(projectContent)

        error(message("SimBiology:diff:NoModelsInFile",projectFileName));
    elseif tfUseSingleProject&&numModelsInProject==1

        error(message("SimBiology:diff:RequireTwoModels"));
    end

    tfModelNameSpecified=~ismissing(modelName);

    modelNamesInProject=projectContent.ModelNames;
    modelNamesForMessage=join(compose("'%s'",modelNamesInProject),", ");

    if tfModelNameSpecified

        tfModelNameMatchInProject=modelNamesInProject==modelName;
        if sum(tfModelNameMatchInProject)==0
            error(message("SimBiology:diff:ModelNotFoundInFile",projectFileName,...
            modelName,modelNameValueArgumentName,modelNamesForMessage));
        elseif sum(tfModelNameMatchInProject)>1
            errorResolution=message("SimBiology:diff:UseSbioloadproject").getString();
            error(message("SimBiology:diff:AmbiguousModelName",projectFileName,modelName,errorResolution));
        end
    else

        if tfUseSingleProject&&numModelsInProject>2


            error(message("SimBiology:diff:MustSpecifyModelName",...
            modelNameValueArgumentName,modelNamesForMessage));
        elseif~tfUseSingleProject&&numModelsInProject~=1



            error(message("SimBiology:diff:MultipleModelsInFile",projectFileName,...
            modelNameValueArgumentName,modelNamesForMessage));
        end
    end

end