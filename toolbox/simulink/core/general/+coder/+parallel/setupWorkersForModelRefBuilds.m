function setupWorkersForModelRefBuilds(pool,iMdl,workerBaseWorkspacesMatchClientCheck)






    if nargin<3
        workerBaseWorkspacesMatchClientCheck=@coder.parallel.workerBaseWorkspacesMatchClient;
    end

    initType=get_param(iMdl,'ParallelModelReferenceMATLABWorkerInit');
    baseVars={};
    topMdl=[];

    if strcmp(initType,'Copy Base Workspace')&&~workerBaseWorkspacesMatchClientCheck(pool)


        msg=DAStudio.message('Simulink:slbuild:parBuildCopyWorkspace');
        slprivate('sl_disp_info',msg,true);


        baseVars=evalin('base','who');

        baseVars=baseVars(~strcmp(baseVars,'ans'));
        for i=1:numel(baseVars)
            baseVars{i,2}=evalin('base',baseVars{i,1});
        end

    elseif strcmp(initType,'Load Top Model')



        msg=DAStudio.message('Simulink:slbuild:parBuildLoadTopModel',iMdl);
        slprivate('sl_disp_info',msg,true);



        subsysName=coder.internal.SubsystemBuild.getNewModelName;
        if strcmp(subsysName,iMdl)
            save_system(iMdl);
            rtwprivate('rtwattic','setParallelSubsystemBuild',true);
        end

        topMdl=iMdl;
    end

    if~isempty(baseVars)||~isempty(topMdl)
        pool.runOnAllWorkersSync(@locSetupWorker,topMdl,baseVars);
    end
end

function locSetupWorker(topMdl,baseVars)

    for i=1:size(baseVars,1)
        assignin('base',baseVars{i,1},baseVars{i,2});
    end


    if~isempty(topMdl)
        load_system(topMdl);
    end
end


