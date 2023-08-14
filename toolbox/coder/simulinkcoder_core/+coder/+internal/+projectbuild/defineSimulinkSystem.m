function defineSimulinkSystem(project,model,systemName,modelType,overwrite)





    parser=coder.internal.projectbuild.SimulinkSystemModelParser();
    projectData=coder.internal.projectbuild.ProjectData(project);

    if nargin<4

        modelType=coder.internal.projectbuild.SystemModelType.SystemLevel;
    end

    if nargin<5

        overwrite=false;
    end


    parser.parse(model,projectData,modelType,systemName,overwrite);


    projectData.save(project);
end

