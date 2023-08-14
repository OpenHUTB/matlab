function beScope=getBirdsEyeScope(modelName,forceCreation)






    if nargin<2
        forceCreation=false;
    end

    modelHandle=get_param(modelName,'Handle');

    beScope=matlabshared.scopes.WebScope.GetInstanceForType(modelHandle,"BirdsEyeScope");
    if forceCreation&&isempty(beScope)

        preserve_dirty=Simulink.PreserveDirtyFlag(modelHandle,'blockDiagram');%#ok<NASGU>
        pm=Simulink.PluginMgr;
        pm.attach(modelHandle,'BirdsEyeScopePlugin');

        register_birds_eye_scope(modelName);

        beScope=matlabshared.scopes.WebScope.GetInstanceForType(modelHandle,"BirdsEyeScope");
    end


end

