function result=isComponentSinglePhaseAsynchronousMachine(componentPath)



    result=any(strcmp(componentPath,...
    {'ee.electromech.async.single_phase.ab',...
    'ee.electromech.async.single_phase.ab_thermal'}));
end

