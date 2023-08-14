function modelelements=getDescendants(this,ssid)





    o=SlCov.FilterEditor.getObject(ssid);
    modelelements=o.find('-isa','Simulink.Block')';
    sfrt=sfroot;
    machine=sfrt.find('-isa','Stateflow.Machine','name',o.Name);
    modelelements=[modelelements,machine.find('-isa','Stateflow.Transition')'];
    modelelements=[modelelements,machine.find('-isa','Stateflow.State')'];
