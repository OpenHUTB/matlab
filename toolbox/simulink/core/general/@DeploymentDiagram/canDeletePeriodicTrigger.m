function retVal=canDeletePeriodicTrigger(obj)




    assert(isa(obj,'Simulink.SoftwareTarget.PeriodicTrigger'));


    tc=obj.ParentTaskConfiguration;
    trigTypes={tc.Triggers.TriggerType};
    retVal=(sum(strcmp(trigTypes,'PeriodicTrigger'))>1);

end
