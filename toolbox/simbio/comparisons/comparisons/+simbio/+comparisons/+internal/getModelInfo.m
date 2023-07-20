function[projectNames,modelObjs,diagramFiles,projectContents]=...
    getModelInfo(modelsOrProjects,options,tmpDirectory)









































    modelNameValueArgumentName=["SourceModelName","TargetModelName"];

    projectNames=["",""];
    diagramFiles=[string(missing),string(missing)];
    projectContents=cell(1,2);
    archiveDirs=["",""];

    for i=1:2

        if isa(modelsOrProjects{i},"SimBiology.Model")




            modelObjs(i)=modelsOrProjects{i};%#ok<AGROW> 


            if~ismissing(options.(modelNameValueArgumentName(i)))&&...
                options.(modelNameValueArgumentName(i))~=modelObjs(i).Name

                error(message("SimBiology:diff:InvalidModelName",modelObjs(i).Name,...
                modelNameValueArgumentName(i),options.(modelNameValueArgumentName(i))));
            end

        elseif isstring(modelsOrProjects{i})




            modelsOrProjects{i}=string(modelsOrProjects{i});


            tfUseSingleProject=options.UseSingleProject;
            if i==1||~tfUseSingleProject
                projectNames(i)=SimBiology.internal.getCanonicalFilename(modelsOrProjects{i});
            elseif i==2&&tfUseSingleProject
                projectNames(2)=projectNames(1);
            end

            if i==1||~tfUseSingleProject


                archiveDirs(i)=fullfile(tmpDirectory,"Archive"+i);
                projectContents{i}=simbio.comparisons.internal.loadProject(projectNames(i),archiveDirs(i));
            else
                projectContents{2}=projectContents{1};
                archiveDirs(2)=archiveDirs(1);
            end


            if~options.AutoSelectModels

                specifiedModelName=options.(modelNameValueArgumentName(i));
                simbio.comparisons.internal.validateModel(specifiedModelName,projectNames(i),...
                projectContents{i},tfUseSingleProject,modelNameValueArgumentName(i));


                [modelObjs(i),diagramFiles(i)]=...
                simbio.comparisons.internal.getModelFromProject(...
                specifiedModelName,projectContents{i},tfUseSingleProject,i,archiveDirs(i));%#ok<AGROW> 
                modelNames(i)=string(modelObjs(i).Name);%#ok<AGROW> 
            elseif i==2

                modelNames=autoSelectModels(modelsOrProjects,projectContents);
                for j=1:2

                    [modelObjs(j),diagramFiles(j)]=...
                    simbio.comparisons.internal.getModelFromProject(...
                    modelNames(j),projectContents{j},tfUseSingleProject,j,archiveDirs(j));
                end
            end

        else





            error(message("SimBiology:diff:InvalidModelInput"));

        end

    end

    if modelObjs(1)==modelObjs(2)
        error(message("SimBiology:diff:RequireTwoModels"));
    end

end


function modelNames=autoSelectModels(projects,projectContents)











    allModelNamesInProject=cell(2,1);
    for j=1:2
        if isempty(projectContents{j})

            error(message("SimBiology:diff:NoModelsInFile",projects{j}));
        end
        allModelNamesInProject{j}=projectContents{j}.ModelNames;
        [idx,uniqueNames]=findgroups(allModelNamesInProject{j});
        if numel(uniqueNames)~=numel(allModelNamesInProject{j})
            counts=histcounts(idx,BinMethod="integers");
            duplicateNames=strjoin(uniqueNames(counts>1),', ');

            errorResolution=message("SimBiology:diff:UseSbioloadproject").getString();
            error(message("SimBiology:diff:AmbiguousModelName",projects{j},duplicateNames,errorResolution));
        end
    end
    [tfMatch,matchIdx]=ismember(allModelNamesInProject{1},allModelNamesInProject{2});
    if~any(tfMatch)
        matchIdxInSource=1;
        matchIdxInTarget=1;
    else
        matchIdxInSource=find(tfMatch,1);
        matchIdxInTarget=matchIdx(matchIdxInSource);
    end
    modelNames=[allModelNamesInProject{1}(matchIdxInSource),...
    allModelNamesInProject{2}(matchIdxInTarget)];
end