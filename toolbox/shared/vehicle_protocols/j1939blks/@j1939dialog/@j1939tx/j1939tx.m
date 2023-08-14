function obj=j1939tx(hBlock)






    obj=j1939dialog.j1939tx(hBlock);


    if isa(hBlock,'double')
        hBlock=get_param(hBlock,'object');
    end
    obj.Block=hBlock;


    parent=obj.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end

    obj.Root=parent;


    obj.ConfigName=obj.Block.ConfigName;
    obj.NodeName=obj.Block.NodeName;
    obj.PGList=obj.Block.PGList;
    obj.PGName=obj.Block.PGName;
    obj.PGPriority=obj.Block.PGPriority;





    if~strcmp(obj.Block.SignalInfo,'')

        rowData=textscan(obj.Block.SignalInfo,'%s','Delimiter','#');


        rowData=rowData{:};
        numberColumns=strfind(rowData{1},'$');
        if(length(numberColumns)==12)
            for idx=1:length(rowData)
                currentRow=rowData{idx};
                allIndices=strfind(currentRow,'$');
                rowData{idx}=[currentRow(1:allIndices(5)-1),'$1$0',currentRow(allIndices(5):allIndices(12))];
            end
            obj.Block.SignalInfo=sprintf('%s#',rowData{:});
        end
    end

    obj.MsgLength=obj.Block.MsgLength;
    obj.SignalInfo=obj.Block.SignalInfo;
    obj.NSignals=obj.Block.NSignals;
    obj.DestAddrID=obj.Block.DestAddrID;
    obj.DestAddrName=obj.Block.DestAddrName;
    obj.TransmitPeriodically=strcmpi(obj.Block.TransmitPeriodically,'on');
    obj.MessagePeriod=obj.Block.MessagePeriod;
    obj.SampleTime=obj.Block.SampleTime;
