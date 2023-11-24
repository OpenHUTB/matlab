function populateObserver(source,container,bdHandle,sourceModelName,diagramName,designPortHdls)

    observer=sd.execution.Observer(container);
    observer.sourceModelName=sourceModelName;
    observer.name=get_param(bdHandle,'name');

    dd=get_param(sourceModelName,'DataDictionary');
    if(~isempty(dd))
        set_param(observer.name,'DataDictionary',dd);
    end

    recogniser=observer.addRecogniser(source,diagramName);


    slfeature('DataTypesInModelWS',1);

    mdlWks=get_param(observer.name,'ModelWorkspace');

    metaDataBus=slTestEventMetadata();
    assignin(mdlWks,'slTestEventMetadata',metaDataBus);

    buses=observer.getBuses(designPortHdls);
    if~isempty(buses)
        for bi=1:length(buses)
            b=buses(bi);
            srcObj=observer.sources.getByKey(b.Description);
            srcObj.busName="busType_"+string(bi);
            assignin(mdlWks,srcObj.busName,b);
        end
    end


    observer.connectSources();

    if slsvTestingHook('SequenceDiagramGenerateRecogniser')==1

        recogniser.generateSFChart(observer.name);

        observer.connectRecogniser(recogniser);
    else


        portCount=0;
        for port=recogniser.data.toArray
            if isa(port,'sd.execution.Port')&&isa(port.source,'sd.execution.MessageEventSource')
                portCount=portCount+1;
            end
        end

        hBusCreator=add_block('built-in/BusCreator',string(observer.name)+"/b_c");
        oBusCreator=get_param(hBusCreator,'Object');
        oBusCreator.Inputs=string(portCount);

        portIndex=1;
        for port=recogniser.data.toArray
            if isa(port,'sd.execution.Port')

                source=port.source;
                if isa(source,'sd.execution.MessageEventSource')
                    add_line(observer.name,source.sourcePort,string(get_param(hBusCreator,'Name'))+"/"+string(portIndex));
                    portIndex=portIndex+1;
                end
            end
        end

        qhdl2=add_block('built-in/MessageQueue',string(observer.name)+"/o_q2");
        queue2=get_param(qhdl2,'Object');
        queue2.Capacity='inf';

        add_line(observer.name,string(get_param(hBusCreator,'Name'))+"/1",string(get_param(qhdl2,'Name'))+"/1");
    end


    if slsvTestingHook('SequenceDiagramUseViewer')>0
        sv=add_block("built-in/MessageViewer",string(observer.name)+"/viewer");
        open_system(sv);
        Simulink.BlockDiagram.arrangeSystem(observer.name);
    end

end

function bus=slTestEventMetadata()
    elems(1)=Simulink.BusElement;
    elems(1).Name='order';
    elems(1).Dimensions=1;
    elems(1).DimensionsMode='Fixed';
    elems(1).DataType='int32';
    elems(1).Complexity='real';
    elems(1).Min=[];
    elems(1).Max=[];
    elems(1).DocUnits='';
    elems(1).Description='';

    elems(2)=Simulink.BusElement;
    elems(2).Name='eventType';
    elems(2).Dimensions=1;
    elems(2).DimensionsMode='Fixed';
    elems(2).DataType='Enum: slTestEventType';
    elems(2).Complexity='real';
    elems(2).Min=[];
    elems(2).Max=[];
    elems(2).DocUnits='';
    elems(2).Description='';

    elems(3)=Simulink.BusElement;
    elems(3).Name='time';
    elems(3).Dimensions=1;
    elems(3).DimensionsMode='Fixed';
    elems(3).DataType='double';
    elems(3).Complexity='real';
    elems(3).Min=[];
    elems(3).Max=[];
    elems(3).DocUnits='';
    elems(3).Description='';

    elems(4)=Simulink.BusElement;
    elems(4).Name='id';
    elems(4).Dimensions=1;
    elems(4).DimensionsMode='Fixed';
    elems(4).DataType='int32';
    elems(4).Complexity='real';
    elems(4).Min=[];
    elems(4).Max=[];
    elems(4).DocUnits='';
    elems(4).Description='';

    bus=Simulink.Bus;
    bus.HeaderFile='';
    bus.Description='';
    bus.DataScope='Auto';
    bus.Alignment=-1;
    bus.PreserveElementDimensions=0;
    bus.Elements=elems;
end


