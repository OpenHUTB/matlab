function[status,forcedTurnOnRelationalBoundary]=createNetworkSpec(modelName,testcomp,customEnhancedMCDCOpts)


    forcedTurnOnRelationalBoundary=false;
    options=testcomp.activeSettings;




    if~Sldv.utils.isPathBasedTestGeneration(options)
        status=true;
        return;
    end

    testcomp.profileStage('Path computation');
    testcomp.getMainProfileLogger().openPhase('Path computation');

    if~ischar(modelName)
        modelName=get_param(modelName,"Name");
    end

    customOptions='';
    dir='';
    if~isempty(options.PathBasedCustomization)
        file=options.PathBasedCustomization;
        [dir,name]=fileparts(file);
        if~isempty(dir)

            oldPath=addpath(dir);
        end
        if exist(file,'file')==2
            customOptions=name;
        end
    end

    depStruct=Sldv.ComputeObservable(testcomp,modelName,customOptions,customEnhancedMCDCOpts);

    forcedTurnOnRelationalBoundary=depStruct.forcedTurnOnRelationalBoundary;
    status=depStruct.constructDependencyMap();
    if status
        composeSpec=depStruct.generateCompSpec();
    end

    if~isempty(dir)

        path(oldPath);
    end


    testcomp.pathCompositionSpec=composeSpec;
    testcomp.profileStage('end');
    testcomp.getMainProfileLogger().closePhase('Path computation');
end
