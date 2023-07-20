
function FailingObjs=algo_jmaab(sfElements,systemToCheck)


    FailingObjs=ModelAdvisor.internal.jc_0531.algo_maab_v3(sfElements);

    for k=1:length(sfElements)

        defaultTransitions=ModelAdvisor.internal.getDefaultTransitions(...
        sfElements{k},1);


        [parallelStates,exclusiveStates]=ModelAdvisor.internal.getStates(...
        sfElements{k},1,false,true);

        junctions=ModelAdvisor.internal.getJunctions(sfElements{k},1,true);

        [result,failingElements]=...
        ModelAdvisor.internal.jc_0531.hasNoDefaultTransition(...
        defaultTransitions,[exclusiveStates;junctions]);
        if result
            ElementResults=createElementResults(failingElements,...
            DAStudio.message('ModelAdvisor:styleguide:jc_0531_warn_default_transition'),...
            DAStudio.message('ModelAdvisor:styleguide:jc_0531_rec_action_default_transition'));
            FailingObjs=[FailingObjs,ElementResults];%#ok<AGROW>
        end



        [result,failingElements]=...
        ModelAdvisor.internal.jc_0531.hasDefaultTransitionForParallelStates(...
        defaultTransitions,parallelStates);
        if result
            ElementResults=createElementResults(failingElements,...
            DAStudio.message('ModelAdvisor:styleguide:jc_0531_warn_parallel_states_default_transition'),...
            DAStudio.message('ModelAdvisor:styleguide:jc_0531_rec_action_parallel_states_default_transition'));
            FailingObjs=[FailingObjs,ElementResults];%#ok<AGROW>
        end



        [result,failingElements]=...
        ModelAdvisor.internal.jc_0531.hasMultipleDefaultTransitions(...
        defaultTransitions);
        if result
            ElementResults=createElementResults(failingElements,...
            DAStudio.message('ModelAdvisor:styleguide:jc_0531_warn_multiple_default_transition'),...
            DAStudio.message('ModelAdvisor:styleguide:jc_0531_rec_action_multiple_default_transition'));
            FailingObjs=[FailingObjs,ElementResults];%#ok<AGROW>
        end



        [result,failingElements]=...
        ModelAdvisor.internal.jc_0531.doesDefaultTransitionExceedStateBoundary(...
        defaultTransitions,[parallelStates,exclusiveStates]);

        if result
            ElementResults=createElementResults(failingElements,...
            DAStudio.message('ModelAdvisor:styleguide:jc_0531_warn_default_transition_exceed_state_boundary'),...
            DAStudio.message('ModelAdvisor:styleguide:jc_0531_rec_action_default_transition_exceed_state_boundary'));
            FailingObjs=[FailingObjs,ElementResults];%#ok<AGROW>
        end
    end

    if ModelAdvisor.internal.jc_0531.dontHaveSingleNonGuardPath(systemToCheck)

        tempFailObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(tempFailObj,'Model',systemToCheck,'Parameter','SFNoUnconditionalDefaultTransitionDiag','CurrentValue',get_param(bdroot(systemToCheck),'SFNoUnconditionalDefaultTransitionDiag'),'RecommendedValue','error');
        tempFailObj.RecAction=DAStudio.message('ModelAdvisor:styleguide:jc_0531_warn_default_transition_no_guard');
        tempFailObj.Status=DAStudio.message('ModelAdvisor:styleguide:jc_0531_rec_action_default_transition_no_guard');
        FailingObjs=[FailingObjs,tempFailObj];
    end

end

function ElementResults=createElementResults(failingElements,warn,rec)
    if~iscell(failingElements)
        failingElements=arrayfun(@(x){x},failingElements);
    end
    ElementResults=Advisor.Utils.createResultDetailObjs(failingElements,...
    'Description',DAStudio.message('ModelAdvisor:styleguide:jc_0531_jmaab_tip'),...
    'Status',warn,'RecAction',rec);
end