function ports=constraint_ports()




    framePort=sm_ports_info('frame');
    baseName=pm_message('sm:model:blockNames:constraint:ports:Base');
    leftPort=simmechanics.sli.internal.PortInfo(framePort.PortType,baseName,'left',baseName);

    follName=pm_message('sm:model:blockNames:constraint:ports:Follower');
    rightPort=simmechanics.sli.internal.PortInfo(framePort.PortType,follName,'right',follName);

    ports=[leftPort,rightPort];

end

