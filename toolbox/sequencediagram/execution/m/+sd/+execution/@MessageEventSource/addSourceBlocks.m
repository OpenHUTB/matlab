function addSourceBlocks(obj,namePrefix,sourcePort)

    if slsvTestingHook('SequenceDiagramUseTestingBlock')==2

        qhdl1=add_block('built-in/MessageQueue',string(obj.owner.name)+"/"+namePrefix+"_q1");
        queue1=get_param(qhdl1,'Object');
        queue1.QueueType='FIFO';
        queue1.Capacity='inf';
        add_line(obj.owner.name,sourcePort,string(get_param(qhdl1,'Name'))+"/1");
    elseif slsvTestingHook('SequenceDiagramUseTestingBlock')==0

        combinerSubsystem=buildCombinerSubsystem(obj,namePrefix);

        obj.serverBlockName=get_param(combinerSubsystem,'Name');
    end
end
function bs=getBusSelector(op)

    lh=get_param(op,'LineHandles');
    lho=lh.Outport;
    bs=get_param(lho,"DstBlockHandle");
end

function ssHdl=buildCombinerSubsystem(obj,namePrefix)
    pHdl=getBusSelector(string(obj.owner.name)+"/"+namePrefix);


    bh(1)=pHdl;
    lhs=get_param(pHdl,'LineHandles');
    delete_line(lhs.Outport);



    qhdl1=add_block('built-in/MessageQueue',string(obj.owner.name)+"/"+namePrefix+"_q1");
    bh(2)=qhdl1;
    queue1=get_param(qhdl1,'Object');
    queue1.QueueType='FIFO';
    queue1.Capacity='inf';

    qhdl2=add_block('built-in/MessageQueue',string(obj.owner.name)+"/"+namePrefix+"_q2");
    bh(3)=qhdl2;
    queue2=get_param(qhdl2,'Object');
    queue2.QueueType='Priority';
    queue2.PrioritySource='order';
    queue2.EntryAction='entitySys.priority=double(entity.order)+100;';
    queue2.SortingDirection='Ascending';
    queue2.Capacity='inf';

    shdl1=add_block('built-in/EntityServer',string(obj.owner.name)+"/"+namePrefix+"_s1");
    bh(4)=shdl1;
    server1=get_param(shdl1,'Object');

    server1.ServiceTimeValue='0';

    add_line(obj.owner.name,string(get_param(qhdl2,'Name'))+"/1",string(get_param(shdl1,'Name'))+"/1");

    add_line(obj.owner.name,string(get_param(pHdl,'Name'))+"/1",string(get_param(qhdl1,'Name'))+"/1");
    add_line(obj.owner.name,string(get_param(pHdl,'Name'))+"/2",string(get_param(qhdl2,'Name'))+"/1");


    combinerOut=add_block('built-in/CompositeEntityCreator',string(obj.owner.name)+"/"+namePrefix+"_c");
    bh(5)=combinerOut;
    combiner=get_param(combinerOut,'Object');
    if(slsvTestingHook('SequenceDiagramCreateBuses')>0)
        mapping=evalin('base','portMapping');
        ports=obj.ports.toArray;
        if isKey(mapping,ports.uri)
            busType=mapping(ports.uri);
        else
            busType=obj.busName;
        end
    else
        busType=obj.busName;
    end
    combiner.EntityTypeName=busType;
    combiner.BusObject='on';

    add_line(obj.owner.name,string(get_param(shdl1,'Name'))+"/1",string(get_param(combinerOut,'Name'))+"/2");
    add_line(obj.owner.name,string(get_param(qhdl1,'Name'))+"/1",string(get_param(combinerOut,'Name'))+"/1");


    oswitchHdl=add_block('built-in/EntityOutputSwitch',string(obj.owner.name)+"/"+namePrefix+"_os");
    bh(6)=oswitchHdl;
    oswitch=get_param(oswitchHdl,'object');
    oswitch.NumberOutputPorts='3';
    oswitch.SwitchingCriterion='From attribute';
    oswitch.SwitchAttributeName='eventType';

    add_line(obj.owner.name,string(get_param(combinerOut,'Name'))+"/1",string(get_param(oswitchHdl,'Name'))+"/1");


    t2Hdl=add_block('built-in/EntityTerminator',string(obj.owner.name)+"/"+namePrefix+"_t2");
    bh(7)=t2Hdl;
    add_line(obj.owner.name,string(get_param(oswitchHdl,'Name'))+"/3",string(get_param(t2Hdl,'Name'))+"/1");


    qhdl3=add_block('built-in/MessageQueue',string(obj.owner.name)+"/"+namePrefix+"_qpop");
    bh(8)=qhdl3;
    queue3=get_param(qhdl3,'Object');
    queue3.QueueType='Priority';
    queue3.PrioritySource='order';
    queue3.EntryAction='entitySys.priority=double(entity.Metadata.order)+100;';
    queue3.SortingDirection='Ascending';
    queue3.Capacity='inf';
    add_line(obj.owner.name,string(get_param(oswitchHdl,'Name'))+"/2",string(get_param(qhdl3,'Name'))+"/1");
    shdl2=add_block('built-in/EntityServer',string(obj.owner.name)+"/"+namePrefix+"_s2");
    bh(9)=shdl2;
    server2=get_param(shdl2,'Object');

    server2.ServiceTimeValue='0';

    add_line(obj.owner.name,string(get_param(qhdl3,'Name'))+"/1",string(get_param(shdl2,'Name'))+"/1");

    qhdl4=add_block('built-in/MessageQueue',string(obj.owner.name)+"/"+namePrefix+"_qsend");
    bh(10)=qhdl4;
    queue4=get_param(qhdl4,'Object');
    queue4.QueueType='Priority';
    queue4.PrioritySource='order';
    queue4.EntryAction='entitySys.priority=double(entity.Metadata.order)+100;';
    queue4.SortingDirection='Ascending';
    queue4.Capacity='inf';
    add_line(obj.owner.name,string(get_param(oswitchHdl,'Name'))+"/1",string(get_param(qhdl4,'Name'))+"/1");
    shdl3=add_block('built-in/EntityServer',string(obj.owner.name)+"/"+namePrefix+"_s3");
    bh(11)=shdl3;
    server3=get_param(shdl3,'Object');

    server3.ServiceTimeValue='0';

    add_line(obj.owner.name,string(get_param(qhdl4,'Name'))+"/1",string(get_param(shdl3,'Name'))+"/1");
    Simulink.BlockDiagram.createSubsystem(bh,'Name',namePrefix+"_ss");
    ssHdl=get_param(string(obj.owner.name)+"/"+namePrefix+"_ss",'handle');
    op1=string(obj.owner.name)+"/"+namePrefix+"_ss/Out1";

    line=get_param(op1,'linehandles').Inport;
    sourceBlock=get_param(line,'SrcBlockHandle');
    name=string(get_param(sourceBlock,'name'));
    if(name.endsWith("_s3"))

        set_param(op1,'Port','1');
    else
        set_param(op1,'Port','2');
    end
    set_param(op1,'outdatatypestr',"Bus:"+string(busType));
    opName=string(obj.owner.name)+"/"+namePrefix+"_ss/Out2";
    set_param(opName,'outdatatypestr',"Bus:"+string(busType));
end

