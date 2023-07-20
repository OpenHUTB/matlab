function jmaab_jc_0740





    mdladvRoot=ModelAdvisor.Root;
    rec=Advisor.Utils.getDefaultCheckObject('mathworks.jmaab.jc_0740',false,@checkAlgo,'None');

    rec.setLicense({styleguide_license,'Stateflow'});


    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    paramLookUnderMasks.ColSpan=[3,4];

    inputParamList={paramFollowLinks,paramLookUnderMasks};

    rec.setInputParametersLayoutGrid([1,1]);
    rec.setInputParameters(inputParamList);
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});

end


function FailingExpressions=checkAlgo(system)

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    FollowLinks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LookUnderMasks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');

    FailingExpressions={};

    allStates=Advisor.Utils.Stateflow.sfFindSys(system,FollowLinks.Value,...
    LookUnderMasks.Value,{'-isa','Stateflow.State'});


    allStates=mdlAdvObj.filterResultWithExclusion(allStates);

    for idx=1:length(allStates)
        state=allStates{idx};

        if state.isCommented()
            continue;
        end


        labelStr=ModelAdvisor.internal.removeCommentsInLabelString(state.LabelString,false);
        if any(cellfun(@analyze,labelStr))
            FailingExpressions=[FailingExpressions,{state}];%#ok<AGROW>
        end


    end
end


function res=analyze(text)
    res=false;
    text=regexprep(text,'(\s*)|(%.+)','');

    if isempty(text)
        return;
    end

    if~isempty(regexp(text,'((en|entry|du|during|,)?(ex|exit)(en|entry|during|du|,)*?:)','once'))
        res=true;
    end

end
