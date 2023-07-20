



function FailingObjs=algo_maab_v3(sfElements)
    FailingObjs=[];

    for k=1:length(sfElements)
        [result,failingElements]=...
        ModelAdvisor.internal.jc_0531.hasDefaultTransitionsNotConnectedTop(...
        ModelAdvisor.internal.getDefaultTransitions(sfElements{k},1));
        if result
            failingElements=arrayfun(@(x){x},failingElements);
            ElementResults=Advisor.Utils.createResultDetailObjs(failingElements,...
            'Description',DAStudio.message('ModelAdvisor:styleguide:jc_0531_jmaab_tip'),...
            'Status',DAStudio.message('ModelAdvisor:styleguide:jc_0531_warn_default_transition_not_top'),...
            'RecAction',DAStudio.message('ModelAdvisor:styleguide:jc_0531_rec_action_default_transition_not_top'));
            FailingObjs=[FailingObjs,ElementResults];%#ok<AGROW>
        end


        [result,failingElements]=...
        ModelAdvisor.internal.jc_0531.isDestinationNotPositionedOnTop(sfElements{k});
        if result
            failingElements=arrayfun(@(x){x},failingElements);
            ElementResults=Advisor.Utils.createResultDetailObjs(failingElements,...
            'Description',DAStudio.message('ModelAdvisor:styleguide:jc_0531_jmaab_tip'),...
            'Status',DAStudio.message('ModelAdvisor:styleguide:jc_0531_warn_default_transition_destination_not_top'),...
            'RecAction',DAStudio.message('ModelAdvisor:styleguide:jc_0531_rec_action_default_transition_destination_not_top'));
            FailingObjs=[FailingObjs,ElementResults];%#ok<AGROW>
        end
    end
end