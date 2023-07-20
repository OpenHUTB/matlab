function out=getLocalSolverFixedCostInfo_impl(model)












    try
        model=pm_charvector(model);

        if contains(model,'.')
            if endsWith(model,'.mdl')||endsWith(model,'.slx')
                [~,modelName,~]=fileparts(model);
            else
                error(message('physmod:simscape:engine:mli:getLocalSolverFixedCostInfo:InvalidModelName'));
            end
        else
            modelName=model;
        end


        if bdIsLoaded(modelName)
            alreadyLoaded=1;
            modelHandle=get_param(modelName,'Handle');
        else
            alreadyLoaded=0;
            modelHandle=load_system(modelName);
        end


        if(strcmp(get_param(modelName,'FastRestart'),'on'))
            error(message('physmod:simscape:engine:mli:getLocalSolverFixedCostInfo:FastRestartNotSupported'));
        end
        if(strcmp(get_param(modelName,'SimulationMode'),'rapid-accelerator'))
            error(message('physmod:simscape:engine:mli:getLocalSolverFixedCostInfo:RapidAccelNotSupported'));
        end
        if(lCheckAccel(modelName))
            error(message('physmod:simscape:engine:mli:getLocalSolverFixedCostInfo:ModelRefAccelNotSupported'));
        end


        if(lCheckModelRef(modelName))
            warning(message('physmod:simscape:engine:mli:getLocalSolverFixedCostInfo:ModelReferenceWarning'));
        end


        if(lCheckSubsystemReferences(modelName))
            warning(message('physmod:simscape:engine:mli:getLocalSolverFixedCostInfo:SubsystemReferenceWarning'));
        end






        solverBlocks=find_system(modelName,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on',...
        'LookInsideSubsystemReference','off',...
        'SubClassName','solver',...
        'UseLocalSolver','on');




        cleanupFcns=cell(2,numel(solverBlocks));
        for(i=1:length(solverBlocks))
            solverBlock=solverBlocks{i};
            if(get_param(solverBlock,'DoFixedCost')=="off")
                oldNumIters=get_param(solverBlock,'MaxNonlinIter');
                cleanupFcns{1,i}=onCleanup(@()set_param(solverBlock,'DoFixedCost','off'));
                cleanupFcns{2,i}=onCleanup(@()set_param(solverBlock,'MaxNonlinIter',oldNumIters));
                set_param(solverBlock,'DoFixedCost','on');
                set_param(solverBlock,'MaxNonlinIter','100');
            end
        end


        closeSystemCleanup=cell(1,1);
        if(~alreadyLoaded)
            closeSystemCleanup{1,1}=onCleanup(@()close_system(modelHandle,0));
        end


        oldCacheMethod=simscape.internal.cacheMethod(simscape.internal.CacheMethodType.None);
        CM=onCleanup(@()simscape.internal.cacheMethod(oldCacheMethod));


        simscape.internal.iterationsLogSwitch(modelName,true)
        C=onCleanup(@()simscape.internal.iterationsLogSwitch(modelName,false));


        sim(modelName);


        out=simscape.internal.iterationsLogResults(modelName);


        simscape.internal.iterationsLogSwitch(modelName,false);
    catch exception
        throwAsCaller(exception);
    end
end



function throwAccelError=lCheckAccel(sys)
    throwAccelError=false;
    if(strcmp(get_param(sys,'SimulationMode'),'accelerator'))


        mdlRefBlocks=find_mdlrefs(sys,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'FollowLinks','on','ReturnTopModelAsLastElement',true);
        for i=1:(length(mdlRefBlocks)-1)
            modelName=mdlRefBlocks{i};
            if~bdIsLoaded(modelName)
                modelHandle=load_system(modelName);
                closeSystemCleanup{1,1}=onCleanup(@()close_system(modelHandle,0));
            end



            solverBlocks=find_system(modelName,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on',...
            'SubClassName','solver',...
            'UseLocalSolver','on');
            if(~isempty(solverBlocks))
                throwAccelError=true;
            end
        end
    end
end



function throwModelRefWarning=lCheckModelRef(sys)
    throwModelRefWarning=false;


    mdlRefBlocks=find_mdlrefs(sys,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'FollowLinks','on','ReturnTopModelAsLastElement',true);
    for i=1:(length(mdlRefBlocks)-1)
        modelName=mdlRefBlocks{i};
        if~bdIsLoaded(modelName)
            modelHandle=load_system(modelName);
            closeSystemCleanup{1,1}=onCleanup(@()close_system(modelHandle,0));
        end



        solverBlocks=find_system(modelName,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on',...
        'SubClassName','solver',...
        'UseLocalSolver','on',...
        'DoFixedCost','off');
        if(~isempty(solverBlocks))
            throwModelRefWarning=true;
        end
    end
end



function throwSubsysRefWarning=lCheckSubsystemReferences(sys)
    throwSubsysRefWarning=false;
    solverBlocks=find_system(sys,'LookUnderMasks','all',...
    'FollowLinks','on',...
    'MatchFilter',@lUnsupportedSolverBlocks);

    throwSubsysRefWarning=~isempty(solverBlocks);
end

function match=lUnsupportedSolverBlocks(handle)
    match=false;

    if(strcmp(get_param(handle,'Type'),'block'))

        if(strcmp(get_param(handle,'BlockType'),'SubSystem')&&...
            isfield(get_param(handle,'ObjectParameters'),'SubClassName')...
            &&strcmp(get_param(handle,'SubClassName'),'solver'))
            parentHandle=get_param(handle,'Parent');

            if(strcmp(get_param(parentHandle,'Type'),'block')&&...
                strcmp(get_param(parentHandle,'BlockType'),'SubSystem')&&...
                ~isempty(get_param(parentHandle,'ReferencedSubsystem')))

                if(strcmp(get_param(handle,'UseLocalSolver'),'on')&&strcmp(get_param(handle,'DoFixedCost'),'off'))
                    match=true;
                end
            end
        end
    end
end
