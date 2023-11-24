function addSourceBlocks(obj,namePrefix,sourcePort)
    obj.signalGeneratorName=namePrefix+"_gen";
    hdl1=add_block('built-in/MATLABDiscreteEventSystem',string(obj.owner.name)+"/"+obj.signalGeneratorName);
    sg=get_param(hdl1,'Object');
    sg.System='sd.execution.SignalDetector';
    sg.SimulateUsing='Interpreted execution';
    set_param(hdl1,'edge',obj.getEdgeValue());
    set_param(hdl1,'threshold',obj.getThresholdValue());
    set_param(hdl1,'id',string(obj.getIdValue()));


    obj.sendBlockName=namePrefix+"_send";
    hdls=add_block('built-in/Send',string(obj.owner.name)+"/"+obj.sendBlockName);

    add_line(obj.owner.name,string(get_param(hdls,'Name'))+"/1",string(get_param(hdl1,'Name'))+"/1");

    add_line(obj.owner.name,sourcePort,string(get_param(hdls,'Name'))+"/1");
    if(obj.ports.Size>1)


        obj.replicatorBlockName=namePrefix+"_rep";
        hdl2=add_block('built-in/EntityReplicator',string(obj.owner.name)+"/"+obj.replicatorBlockName);

        er=get_param(hdl2,'Object');
        er.HoldOriginalEntityUntilAllReplicasDepart='on';
        er.ReplicasDepartFrom='Single output port';
        er.ReplicationAmountSource='Dialog';
        er.NumberReplicas='1';

        add_line(obj.owner.name,string(get_param(hdl1,'Name'))+"/1",string(get_param(hdl2,'Name'))+"/1");
    end
end
