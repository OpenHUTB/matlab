function builder=createBuilder(model,projectData,override)






    if nargin<2
        projectData=[];
    end

    persistent builderOverride




    if nargin>2
        assert(isa(override,'coder.internal.build.Builder'),...
        'Builder factory method can only be overridden with a coder.internal.build.Builder');
        builderOverride=override;
    end

    if~isempty(builderOverride)
        builder=builderOverride;
        return;
    end


    [inSystem,system,type]=coder.internal.projectbuild.isModelInSystem(projectData,model);
    if inSystem
        switch type
        case coder.internal.projectbuild.SystemModelType.SystemLevel
            builder=coder.internal.projectbuild.SimulinkSystemBuilder(model,projectData,system);
        case coder.internal.projectbuild.SystemModelType.ComponentRoot
            builder=coder.internal.projectbuild.DefaultBuilder(model,'StandaloneCoderTarget','HardwareBuildFolders',true);
        case coder.internal.projectbuild.SystemModelType.ComponentChild
            builder=coder.internal.projectbuild.DefaultBuilder...
            (model,'ModelReferenceCoderTargetOnly',...
            'ModelReferenceTargetType','RTW',...
            'HardwareBuildFolders',true);

        otherwise
            assert(false,'Unrecognized model type for Simulink system model build.');
        end
    else
        builder=coder.internal.projectbuild.DefaultBuilder(model,'StandaloneCoderTarget');
    end
end


