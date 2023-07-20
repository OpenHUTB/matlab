function addFactoryGroup(this,FactoryGroupObj)




    if isa(FactoryGroupObj,'ModelAdvisor.FactoryGroup')
        this.addChildren(FactoryGroupObj);


        FactoryGroupObj.Top=false;
    else
        DAStudio.error('Simulink:tools:MAInvalidParam','ModelAdvisor.FactoryGroup Object');
    end




