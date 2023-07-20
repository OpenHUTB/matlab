


function sdiLogging(signalname,ModelInfo)

    if isempty(signalname)
        return;
    end

    SubSys=ModelInfo.SubSys;

    BusBlk=ModelInfo.BusBlk;

    num_signals=size(signalname,2);
    signals='';
    for k=1:num_signals
        signals=[signals,convertStringsToChars(signalname(k)),','];
    end
    signals(end)='';


    set_param([SubSys,'/',BusBlk],'OutputSignals',signals);

    for i=1:(num_signals-1)
        add_block('simulink/Sinks/Terminator',[SubSys,'/','Terminator',num2str(i)]);
        add_line(SubSys,['Bus Selector/',num2str(i+1)],['Terminator',num2str(i),'/1']);
    end

    BusObj=get_param([SubSys,'/','Bus Selector'],'porthandles');
    src=BusObj.Outport;
    for i=1:num_signals
        set_param(src(i),'DataLogging','on');
    end

end