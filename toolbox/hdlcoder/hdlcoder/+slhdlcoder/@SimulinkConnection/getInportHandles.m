function inportHandles=getInportHandles(this)





    hSubsystem=get_param(this.System,'handle');


    phan=get_param(hSubsystem,'PortHandles');


    inportHandles=phan.Inport;

end
