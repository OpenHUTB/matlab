function result=isComponentSynchronousMachineModel2p1(componentPath)



    result=any(strcmp(componentPath,...
    {'ee.electromech.sync.model_2_1.abc',...
    'ee.electromech.sync.model_2_1.abc_thermal'}));
end