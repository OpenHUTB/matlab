function outportHandles=getOutportHandles(this)





    hSubsystem=get_param(this.System,'handle');


    phan=get_param(hSubsystem,'PortHandles');


    outportHandles=phan.Outport;

end
