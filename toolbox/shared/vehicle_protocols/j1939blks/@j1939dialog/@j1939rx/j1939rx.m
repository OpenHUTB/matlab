function obj=j1939rx(hBlock)






    obj=j1939dialog.j1939rx(hBlock);


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
    obj.SrcAddrFilter=obj.Block.SrcAddrFilter;
    obj.SrcAddress=obj.Block.SrcAddress;
    tags=j1939.internal.createDefaultString('alltags');
    destAddrFilterSet=tags.DestAddrFilterSet;
    obj.DestAddrFilter=destAddrFilterSet{str2double(obj.Block.DestAddrFilter)};
    obj.outputNew=strcmpi(obj.Block.outputNew,'on');
    obj.SampleTime=obj.Block.SampleTime;