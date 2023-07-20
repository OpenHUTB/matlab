function[buildSpec,...
    modelReferenceTargetType,...
    topModelStandalone,...
    updateTopModelReferenceTarget,...
    isSimBuild]=getBuildSpecContext(p,model)





    modelReferenceTargetType=locGetMdlRefTgtTypeForBuildSpec(...
    p.Results.BuildSpec,p.Results.ModelReferenceTargetType);
    isSimBuild=slprivate('isSimulationBuild',model,modelReferenceTargetType);
    if isSimBuild||(p.Results.BuildSpec=="ModelReferenceTarget"&&...
        p.Results.UpdateTopModelReferenceTarget==false)


        buildSpec=p.Results.BuildSpec;
        [topModelStandalone,updateTopModelReferenceTarget]=...
        locGetTopModelInfoForBuildSpec(buildSpec,p.Results.UpdateTopModelReferenceTarget);
        return;
    end


    mapping=Simulink.CodeMapping.getCurrentMapping(model);
    hasSetDeploymentType=~isempty(mapping)&&isprop(mapping,'DeploymentType')&&...
    mapping.DeploymentType~="Unset";
    if~hasSetDeploymentType

        buildSpec=p.Results.BuildSpec;
        [topModelStandalone,updateTopModelReferenceTarget]=...
        locGetTopModelInfoForBuildSpec(buildSpec,p.Results.UpdateTopModelReferenceTarget);
        return;
    end




    allowedToChangeBuildSpec=...
    p.Results.CalledFromInsideSimulink||any(strcmpi(p.UsingDefaults,'BuildSpec'));
    if~allowedToChangeBuildSpec




        platformType=coder.dictionary.internal.getPlatformType(model);
        locValidateBuildSpec(mapping.DeploymentType,p.Results.BuildSpec,platformType);
        buildSpec=p.Results.BuildSpec;
        [topModelStandalone,updateTopModelReferenceTarget]=...
        locGetTopModelInfoForBuildSpec(buildSpec,p.Results.UpdateTopModelReferenceTarget);
        return;
    end





    switch mapping.DeploymentType
    case{'Component','Application'}
        buildSpec='StandaloneCoderTarget';
        if~strcmpi(p.Results.BuildSpec,buildSpec)
            modelReferenceTargetType=locGetMdlRefTgtTypeForBuildSpec(buildSpec);
            assert(~slprivate('isSimulationBuild',model,modelReferenceTargetType),...
            'Unexpected simulation build encountered.');
        end
    case 'Subcomponent'
        buildSpec='ModelReferenceCoderTarget';
        if~strcmpi(p.Results.BuildSpec,buildSpec)
            modelReferenceTargetType=locGetMdlRefTgtTypeForBuildSpec(buildSpec);
            assert(~slprivate('isSimulationBuild',model,modelReferenceTargetType),...
            'Unexpected simulation build encountered.');
        end
    otherwise
        assert(false,'Unexpected deployment type encountered.');
    end
    [topModelStandalone,updateTopModelReferenceTarget]=locGetTopModelInfoForBuildSpec(buildSpec);
end


function modelReferenceTargetType=locGetMdlRefTgtTypeForBuildSpec(...
    buildSpec,resultsModelReferenceTargetType)
    assert(coder.build.internal.isBuildSpec(buildSpec),'Unknown BuildSpec encountered.');
    switch buildSpec
    case{'','StandaloneRTWTarget','StandaloneCoderTarget'}
        modelReferenceTargetType='NONE';

    case 'ModelReferenceTarget'

        modelReferenceTargetType=resultsModelReferenceTargetType;

    case{'ModelReferenceSimTarget','ModelReferenceProtectedSimTarget'}
        modelReferenceTargetType='SIM';

    case{'ModelReferenceRTWTarget','ModelReferenceRTWTargetOnly',...
        'ModelReferenceCoderTarget','ModelReferenceCoderTargetOnly'}
        modelReferenceTargetType='RTW';

    case 'CleanTopModel'
        modelReferenceTargetType='CLEAN_TOP_MODEL';

    otherwise
        assert(false,'Unexpected new BuildSpec encountered.');
    end
end

function[topModelStandalone,updateTopModelReferenceTarget]=...
    locGetTopModelInfoForBuildSpec(buildSpec,resultsUpdateTopModelReferenceTarget)
    assert(coder.build.internal.isBuildSpec(buildSpec),'Unknown BuildSpec encountered.');
    switch buildSpec
    case{'','StandaloneRTWTarget','StandaloneCoderTarget'}
        topModelStandalone=true;
        updateTopModelReferenceTarget=false;

    case 'ModelReferenceTarget'

        topModelStandalone=false;
        updateTopModelReferenceTarget=resultsUpdateTopModelReferenceTarget;

    case{'ModelReferenceSimTarget','ModelReferenceProtectedSimTarget'}
        topModelStandalone=false;
        updateTopModelReferenceTarget=true;

    case{'ModelReferenceRTWTarget','ModelReferenceRTWTargetOnly',...
        'ModelReferenceCoderTarget','ModelReferenceCoderTargetOnly'}
        topModelStandalone=false;
        updateTopModelReferenceTarget=true;

    case 'CleanTopModel'
        topModelStandalone=true;
        updateTopModelReferenceTarget=false;

    otherwise
        assert(false,'Unexpected new BuildSpec encountered.');
    end
end

function locValidateBuildSpec(deploymentType,buildSpec,platformType)
    switch deploymentType
    case{'Component','Application'}
        allowedBuildSpecs={'StandaloneRTWTarget','StandaloneCoderTarget'};
        isValidBuildSpec=any(strcmpi(buildSpec,allowedBuildSpecs));
        if~isValidBuildSpec
            error(message('RTW:buildProcess:DeploymentTypeBuildSpecMismatch',...
            buildSpec,'Component',...
            'StandaloneCoderTarget','Subcomponent'));
        end
    case 'Subcomponent'
        allowedBuildSpecs={'ModelReferenceRTWTarget','ModelReferenceRTWTargetOnly',...
        'ModelReferenceCoderTarget','ModelReferenceCoderTargetOnly'};
        isValidBuildSpec=any(strcmpi(buildSpec,allowedBuildSpecs));
        if~isValidBuildSpec
            switch platformType
            case 'ApplicationPlatform'
                deploymentTypeSuggestion='Automatic';
            case 'FunctionPlatform'
                deploymentTypeSuggestion='Component';
            otherwise
                assert(false,'Platform type should be either Application or Function.');
            end
            error(message('RTW:buildProcess:DeploymentTypeBuildSpecMismatch',...
            buildSpec,'Subcomponent',...
            'ModelReferenceCoderTarget/ModelReferenceCoderTargetOnly',...
            deploymentTypeSuggestion));
        end
    otherwise
        assert(false,'Deployment type should be Application, Component, or Subcomponent.');
    end
end
