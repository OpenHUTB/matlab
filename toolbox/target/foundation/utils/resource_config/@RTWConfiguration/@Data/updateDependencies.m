function updateDependencies(this,prop,newvalue)








    hprop=findprop(this,prop);
    for i=1:hprop.getNumDependencies
        dep=hprop.getDependency(i);

        this.enablePropOnCondition(dep.getName,newvalue,dep.getActivationVector);

        this.disablePropOnCondition(dep.getName,newvalue,dep.getDeactivationVector);
    end;
    return;
