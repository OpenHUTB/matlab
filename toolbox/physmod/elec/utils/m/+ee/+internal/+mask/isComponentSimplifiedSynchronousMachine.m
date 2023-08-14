function result=isComponentSimplifiedSynchronousMachine(componentPath)



    result=any(strcmp(componentPath,...
    {'ee.electromech.sync.simplified.abc',...
    'ee.electromech.sync.simplified.abc_thermal'}));
end

