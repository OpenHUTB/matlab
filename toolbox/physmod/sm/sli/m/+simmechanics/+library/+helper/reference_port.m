function refPort=reference_port(blockName)




    ports=sm_ports_info('frame');

    refName=pm_message(['sm:model:blockNames:',blockName,':ports:Frame']);
    refPort=simmechanics.sli.internal.PortInfo(ports(1).PortType,refName,'right',refName);

end

