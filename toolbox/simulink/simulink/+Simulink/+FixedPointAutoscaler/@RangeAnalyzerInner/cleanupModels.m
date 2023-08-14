function cleanupModels(obj)



    try




        set_param(obj.model,'InRangeAnalysisMode','off');
    catch ME %#ok<NASGU>
    end



    newOpenSystems=find_system('type','block_diagram');
    systemsToClose=setdiff(newOpenSystems,obj.status.oldOpenSystems);

    close_system(systemsToClose,0,'SkipCloseFcn',true);


    if bdIsLoaded(obj.model)
        set_param(0,'CurrentSystem',obj.model);
    end
