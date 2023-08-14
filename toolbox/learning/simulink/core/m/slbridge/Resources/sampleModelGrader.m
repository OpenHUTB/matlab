function[pass,requirements]=sampleModelGrader(block)









    model=bdroot(block);

    requirements={'Uses solver ODE23','Contains a gain block'};

    pass=strcmp(get_param(model,'Solver'),'ode23');


    pass(2)=~isempty(find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Gain'));

end
