function generateSFChart(obj,modelName)






    load_system('sfAuthoredChartLib');
    c=onCleanup(@()close_system('sfAuthoredChartLib',0));

    chartSLHandle=add_block('sfAuthoredChartLib/authoredChart',modelName+"/"+obj.name);
    set_param(chartSLHandle,'LinkStatus','none');


    rt=sfroot;
    obj.chart=rt.find('-isa','Stateflow.Chart','-and','Path',modelName+"/"+obj.name);


    sf('set',obj.chart.id,'.locked',0);
    dummyStateName='AA';
    dummyState=rt.find('-isa','Stateflow.State','path',modelName+"/"+obj.name,'name',dummyStateName);
    dummyState.delete;


    sf('set',obj.chart.Id,'chart.type',5);
    sf('set',obj.chart.Id,'.isDesChartWithStringSupport',1);

    root=obj.root.createSFState(obj.chart);


    dt=Stateflow.Transition(obj.chart);
    destX=obj.root.x+50;
    dt.SourceEndPoint=[destX,obj.root.y-50];
    dt.DestinationEndPoint=[destX,obj.root.y];
    dt.Destination=root;


    for m=obj.data.toArray
        if isa(m,'sd.execution.Port')
            if isa(m,'sd.execution.DataPort')
                tx=Stateflow.Data(obj.chart);
                tx.Scope='Input';
                tx.Name=m.name;
            else
                tx=Stateflow.Message(obj.chart);
                tx.Scope='Input';
                tx.Name=m.name;
                tx.QueueCapacity='1';
            end
            m.portNumber=tx.Port;
        elseif isa(m,'sd.execution.EventMessage')
            tx=Stateflow.Message(obj.chart);
            tx.Scope='Local';
            tx.QueueCapacity=string(m.queueSize);
            tx.Name=m.name;
            if(~isempty(m.dataType))
                tx.DataType=m.dataType;
            end
            if(~isempty(m.initialValue))
                tx.Props.InitialValue=m.initialValue;
            end
            tx.Priority=string(m.priority);
        else
            tx=Stateflow.Data(obj.chart);
            tx.Scope='Local';
            tx.Name=m.name;
            tx.Props.Type.Method=m.dataMethod;
            if(strcmp(m.dataMethod,'Bus Object'))
                tx.Props.Type.BusObject=m.dataType;
                tx.Props.Array.Size='1';
            else
                tx.Props.InitialValue=m.initialValue;
                if~isempty(m.dataType)
                    tx.DataType=m.dataType;
                end
            end
        end
    end


    for e=obj.localEvents.toArray
        tx=Stateflow.Event(obj.chart);
        tx.Scope='Local';
        tx.Name=e.name;
    end



    tx=Stateflow.Data(obj.chart);
    tx.Scope='Output';
    tx.Name=obj.verdictPort.name;
    tx.Port=obj.verdictPort.portNumber;
    tx.Props.InitialValue=obj.verdictPort.initialValue;

    tx=Stateflow.Data(obj.chart);
    tx.Scope='Output';
    tx.Name=obj.warningPort.name;
    tx.Port=obj.warningPort.portNumber;
    tx.Props.InitialValue=obj.warningPort.initialValue;
end


