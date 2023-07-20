function SourcesToMaskParams(this)



    l_PortRowsToMaskParams(this);
    l_ClockRowsToMaskParams(this);
    l_CommSourceToMaskParams(this);

    if(this.RunAutoTimescale)
        this.Block.RunAutoTimescale='on';
    else
        this.Block.RunAutoTimescale='off';
    end

end


function l_PortRowsToMaskParams(this)

    srcData=this.PortTableSource.GetSourceData;
    PortTypeEnum=l_PortDataTypeCoversion(srcData(:,4),srcData(:,5));

    PortPaths=sprintf('%s;',srcData{:,1});
    PortPaths(end)=[];
    PortModes=['[',sprintf('%d ',srcData{:,2}),']'];
    PortTimes=['[',sprintf('%s,',srcData{:,3})];

    PortTimes(end)=']';
    PortTypeEnum=['[',sprintf('%d ',PortTypeEnum{:}),']'];
    PortFracLengths=['[',sprintf('%s,',srcData{:,6})];
    PortFracLengths(end)=']';


    set(this.Block,...
    'PortPaths',PortPaths,...
    'PortModes',PortModes,...
    'PortTimes',PortTimes,...
    'PortSigns',PortTypeEnum,...
    'PortFracLengths',PortFracLengths...
    );

end

function PortTypeEnum=l_PortDataTypeCoversion(PortDataTypes,PortSigns)
    nrow=numel(PortDataTypes);
    PortTypeEnum=cell(nrow,1);
    for m=1:nrow
        switch PortDataTypes{m}
        case-1
            PortTypeEnum{m}=-1;
        case 0
            if PortSigns{m}==0
                PortTypeEnum{m}=0;
            else
                PortTypeEnum{m}=1;
            end
        case 1
            PortTypeEnum{m}=2;
        case 2
            PortTypeEnum{m}=3;
        case 3
            PortTypeEnum{m}=4;
        end
    end
end


function l_ClockRowsToMaskParams(this)

    srcData=this.ClockTableSource.GetSourceData;

    if(isempty(srcData))
        ClockPaths='';
        ClockModes='[]';
        ClockTimes='[]';
    else
        ClockPaths=sprintf('%s;',srcData{:,1});
        ClockPaths(end)=[];
        ClockModes=['[',sprintf('%d ',srcData{:,2}),']'];
        ClockTimes=['[',sprintf('%s,',srcData{:,3})];
        ClockTimes(end)=']';
    end

    set(this.Block,...
    'ClockPaths',ClockPaths,...
    'ClockModes',ClockModes,...
    'ClockTimes',ClockTimes...
    );

end

function l_CommSourceToMaskParams(this)

    srcData=this.CommSource.GetSourceData;
    cosimBypassStr={'Full Simulation','Confirm Interface Only','No Connection'};
    set(this.Block,...
    'CommLocal',srcData{1},...
    'CommHostName',srcData{2},...
    'CommSharedMemory',srcData{3},...
    'CommPortNumber',srcData{4},...
    'CommShowInfo',srcData{5},...
    'CosimBypass',cosimBypassStr{srcData{6}+1}...
    );
end


