function tracelogInst=plotTrace(PMInfo,traceDataStruct)




    len=length(traceDataStruct.Overflow);
    numslots=PMInfo.NumSlots;
    numDmas=PMInfo.NumDmas;
    DmaIndex=PMInfo.DmaSlotIndex;


    for slotCtrl=1:numslots
        slot=sprintf('Master%d',slotCtrl);
        BurstExecutionEvent.(slot)=BurstEvent(1);
        tranSize.(slot)=-1;
        tranLen.(slot)=-1;
        BytesTransfered.(slot)=0;
    end

    traceData.('timeInfo')(1).OverFlow=false;
    traceData.('timeInfo')(1).TimeDiff=0;
    for slotCtrl=1:8
        slot=sprintf('Master%d',slotCtrl);
        traceData.(slot)(1).('BurstExecutionEvent')=BurstEvent(1);
        traceData.(slot)(1).('MasterID')=-1;
        traceData.(slot)(1).('DataWidth')=-1;
        traceData.(slot)(1).('BurstLength')=-1;
        traceData.(slot)(1).('BurstsTransferred')=0;
        traceData.(slot)(1).('BytesTransferred')=0;
    end
    traceData.('Overal')(1).('BurstExecutionEvent')=BurstEvent(1);
    traceData.('Overal')(1).('MasterID')=-1;
    traceData.('Overal')(1).('DataWidth')=-1;
    traceData.('Overal')(1).('BurstLength')=-1;
    traceData.('Overal')(1).('BurstsTransferred')=0;
    traceData.('Overal')(1).('BytesTransferred')=0;
    traceData.('Master1DMAFIFOUtilization')(1)=FIFOState(0);
    traceData.('Master2DMAFIFOUtilization')(1)=FIFOState(0);


    for ii=2:len+1
        traceData.('timeInfo')(ii).OverFlow=traceDataStruct.Overflow(ii-1);
        traceData.('timeInfo')(ii).TimeDiff=traceDataStruct.TimeDiff(ii-1);
        sumBurstsTransferred=0;
        sumBytesTransferred=0;
        for slotCtrl=1:numslots
            slot=sprintf('Master%d',slotCtrl);

            if(traceDataStruct.(slot).WAL(ii-1)||traceDataStruct.(slot).RAL(ii-1))
                BurstExecutionEvent.(slot)=BurstEvent(2);
            elseif(traceDataStruct.(slot).FW(ii-1)||traceDataStruct.(slot).FR(ii-1))
                BurstExecutionEvent.(slot)=BurstEvent(3);
            elseif(traceDataStruct.(slot).RES(ii-1)||traceDataStruct.(slot).LR(ii-1))
                BurstExecutionEvent.(slot)=BurstEvent(4);
            end
            traceData.(slot)(ii).('BurstExecutionEvent')=BurstExecutionEvent.(slot);
            if(strcmp(BurstExecutionEvent.(slot),'BurstDone'))
                BurstExecutionEvent.(slot)=BurstEvent(1);
            end

            traceData.(slot)(ii).('MasterID')=slotCtrl;
            if(traceDataStruct.(slot).WAL(ii-1)||traceDataStruct.(slot).RAL(ii-1))
                tranSize.(slot)=(traceDataStruct.(slot).WAL(ii-1)*(PMInfo.SlotDw(slotCtrl)))+...
                (traceDataStruct.(slot).RAL(ii-1)*(PMInfo.SlotDw(slotCtrl)));
                tranLen.(slot)=(traceDataStruct.(slot).WAL(ii-1)*(traceDataStruct.(slot).WLEN(ii-1)+1))+...
                (traceDataStruct.(slot).RAL(ii-1)*(traceDataStruct.(slot).RLEN(ii-1)+1));
            end

            traceData.(slot)(ii).('DataWidth')=tranSize.(slot);

            traceData.(slot)(ii).('BurstLength')=tranLen.(slot);

            traceData.(slot)(ii).('BurstsTransferred')=sum(traceDataStruct.(slot).RES(1:ii-1))+...
            sum(traceDataStruct.(slot).LR(1:ii-1));
            if(traceDataStruct.(slot).WAL(ii-1)||traceDataStruct.(slot).RAL(ii-1))
                tranSize.(slot)=(traceDataStruct.(slot).WAL(ii-1)*(PMInfo.SlotDw(slotCtrl)))+...
                (traceDataStruct.(slot).RAL(ii-1)*(PMInfo.SlotDw(slotCtrl)));
                tranLen.(slot)=(traceDataStruct.(slot).WAL(ii-1)*(traceDataStruct.(slot).WLEN(ii-1)+1))+...
                (traceDataStruct.(slot).RAL(ii-1)*(traceDataStruct.(slot).RLEN(ii-1)+1));
            end

            if(traceDataStruct.(slot).RES(ii-1)||traceDataStruct.(slot).LR(ii-1))
                traceData.(slot)(ii).('BytesTransferred')=((tranSize.(slot)*tranLen.(slot))/8)+BytesTransfered.(slot);
                BytesTransfered.(slot)=traceData.(slot)(ii).('BytesTransferred');
            else
                traceData.(slot)(ii).('BytesTransferred')=BytesTransfered.(slot);
            end

            sumBurstsTransferred=sumBurstsTransferred+traceData.(slot)(ii).('BurstsTransferred');
            sumBytesTransferred=sumBytesTransferred+traceData.(slot)(ii).('BytesTransferred');
        end
        for slotCtrl=numslots+1:8
            slot=sprintf('Master%d',slotCtrl);
            traceData.(slot)(ii).('BurstExecutionEvent')=BurstEvent(1);
            traceData.(slot)(ii).('MasterID')=slotCtrl;
            traceData.(slot)(ii).('DataWidth')=0;
            traceData.(slot)(ii).('BurstLength')=0;
            traceData.(slot)(ii).('BurstsTransferred')=0;
            traceData.(slot)(ii).('BytesTransferred')=0;
        end
        activeMaster=find(traceDataStruct.MasterValid(ii-1,:));
        if(~isempty(activeMaster))
            Master=sprintf('Master%d',activeMaster(1));
            traceData.('Overal')(ii).('BurstExecutionEvent')=traceData.(Master)(ii).('BurstExecutionEvent');
            traceData.('Overal')(ii).('MasterID')=activeMaster(1);
            traceData.('Overal')(ii).('DataWidth')=traceData.(Master)(ii).('DataWidth');
            traceData.('Overal')(ii).('BurstLength')=traceData.(Master)(ii).('BurstLength');
            traceData.('Overal')(ii).('BurstsTransferred')=sumBurstsTransferred;
            traceData.('Overal')(ii).('BytesTransferred')=sumBytesTransferred;
        else
            traceData.('Overal')(ii).('BurstExecutionEvent')=BurstEvent(1);
            traceData.('Overal')(ii).('MasterID')=-1;
            traceData.('Overal')(ii).('DataWidth')=0;
            traceData.('Overal')(ii).('BurstLength')=0;
            traceData.('Overal')(ii).('BurstsTransferred')=sumBurstsTransferred;
            traceData.('Overal')(ii).('BytesTransferred')=sumBytesTransferred;
        end
        if numDmas>=1
            traceData.('Master1DMAFIFOUtilization')(ii)=FIFOState(traceDataStruct.DMA1Diag(ii-1));
        else
            traceData.('Master1DMAFIFOUtilization')(ii)=FIFOState(0);
        end
        if numDmas==2
            traceData.('Master2DMAFIFOUtilization')(ii)=FIFOState(traceDataStruct.DMA2Diag(ii-1));
        else
            traceData.('Master2DMAFIFOUtilization')(ii)=FIFOState(0);
        end
    end

    traceData.('timeInfo')(ii+1).OverFlow=false;
    traceData.('timeInfo')(ii+1).TimeDiff=1;
    for slotCtrl=1:8
        slot=sprintf('Master%d',slotCtrl);
        traceData.(slot)(ii+1).('BurstExecutionEvent')=traceData.(slot)(ii).('BurstExecutionEvent');
        traceData.(slot)(ii+1).('MasterID')=slotCtrl;
        traceData.(slot)(ii+1).('DataWidth')=traceData.(slot)(ii).('DataWidth');
        traceData.(slot)(ii+1).('BurstLength')=traceData.(slot)(ii).('BurstLength');
        traceData.(slot)(ii+1).('BurstsTransferred')=traceData.(slot)(ii).('BurstsTransferred');
        traceData.(slot)(ii+1).('BytesTransferred')=traceData.(slot)(ii).('BytesTransferred');
    end
    traceData.('Overal')(ii+1).('BurstExecutionEvent')=traceData.('Overal')(ii).('BurstExecutionEvent');
    traceData.('Overal')(ii+1).('MasterID')=traceData.('Overal')(ii).('MasterID');
    traceData.('Overal')(ii+1).('DataWidth')=traceData.('Overal')(ii).('DataWidth');
    traceData.('Overal')(ii+1).('BurstLength')=traceData.('Overal')(ii).('BurstLength');
    traceData.('Overal')(ii+1).('BurstsTransferred')=sumBurstsTransferred;
    traceData.('Overal')(ii+1).('BytesTransferred')=sumBytesTransferred;
    traceData.('Master1DMAFIFOUtilization')(ii+1)=traceData.('Master1DMAFIFOUtilization')(ii);
    traceData.('Master2DMAFIFOUtilization')(ii+1)=traceData.('Master2DMAFIFOUtilization')(ii);


    clear elems;
    elems.timeInfo(1)=Simulink.BusElement;
    elems.timeInfo(1).Name='OverFlow';
    elems.timeInfo(1).Dimensions=1;
    elems.timeInfo(1).DimensionsMode='Fixed';
    elems.timeInfo(1).DataType='boolean';
    elems.timeInfo(1).SampleTime=-1;
    elems.timeInfo(1).Complexity='real';

    elems.timeInfo(2)=Simulink.BusElement;
    elems.timeInfo(2).Name='TimeDiff';
    elems.timeInfo(2).Dimensions=1;
    elems.timeInfo(2).DimensionsMode='Fixed';
    elems.timeInfo(2).DataType='double';
    elems.timeInfo(2).SampleTime=-1;
    elems.timeInfo(2).Complexity='real';

    for srtCtrl=1:8
        slot=sprintf('Master%d',srtCtrl);

        elems.(slot)(1)=Simulink.BusElement;
        elems.(slot)(1).Name='BurstExecutionEvent';
        elems.(slot)(1).DataType='Enum:BurstEvent';

        elems.(slot)(2)=Simulink.BusElement;
        elems.(slot)(2).Name='MasterID';
        elems.(slot)(2).DataType='double';

        elems.(slot)(3)=Simulink.BusElement;
        elems.(slot)(3).Name='DataWidth';
        elems.(slot)(3).DataType='double';

        elems.(slot)(4)=Simulink.BusElement;
        elems.(slot)(4).Name='BurstLength';
        elems.(slot)(4).DataType='double';

        elems.(slot)(5)=Simulink.BusElement;
        elems.(slot)(5).Name='BurstsTransferred';
        elems.(slot)(5).DataType='double';

        elems.(slot)(6)=Simulink.BusElement;
        elems.(slot)(6).Name='BytesTransferred';
        elems.(slot)(6).DataType='double';

    end

    elems.('Overal')(1)=Simulink.BusElement;
    elems.('Overal')(1).Name='BurstExecutionEvent';
    elems.('Overal')(1).DataType='Enum:BurstEvent';

    elems.('Overal')(2)=Simulink.BusElement;
    elems.('Overal')(2).Name=('MasterID');
    elems.('Overal')(2).DataType='double';

    elems.('Overal')(3)=Simulink.BusElement;
    elems.('Overal')(3).Name='DataWidth';
    elems.('Overal')(3).DataType='double';

    elems.('Overal')(4)=Simulink.BusElement;
    elems.('Overal')(4).Name='BurstLength';
    elems.('Overal')(4).DataType='double';

    elems.('Overal')(5)=Simulink.BusElement;
    elems.('Overal')(5).Name='BurstsTransferred';
    elems.('Overal')(5).DataType='double';

    elems.('Overal')(6)=Simulink.BusElement;
    elems.('Overal')(6).Name='BytesTransferred';
    elems.('Overal')(6).DataType='double';


    DiagDataTimeInfo=Simulink.Bus;
    DiagDataTimeInfo.Elements=elems.timeInfo;

    DiagDataMaster1=Simulink.Bus;
    DiagDataMaster1.Elements=elems.Master1;

    DiagDataMaster2=Simulink.Bus;
    DiagDataMaster2.Elements=elems.Master2;

    DiagDataMaster3=Simulink.Bus;
    DiagDataMaster3.Elements=elems.Master3;

    DiagDataMaster4=Simulink.Bus;
    DiagDataMaster4.Elements=elems.Master4;

    DiagDataMaster5=Simulink.Bus;
    DiagDataMaster5.Elements=elems.Master5;

    DiagDataMaster6=Simulink.Bus;
    DiagDataMaster6.Elements=elems.Master6;

    DiagDataMaster7=Simulink.Bus;
    DiagDataMaster7.Elements=elems.Master7;

    DiagDataMaster8=Simulink.Bus;
    DiagDataMaster8.Elements=elems.Master8;

    DiagDataOveral=Simulink.Bus;
    DiagDataOveral.Elements=elems.Overal;

    Master1DMAFIFOUtilization=Simulink.Signal;
    Master1DMAFIFOUtilization.DataType='Enum:FIFOState';
    Master2DMAFIFOUtilization=Simulink.Signal;
    Master2DMAFIFOUtilization.DataType='Enum:FIFOState';


    assignin('base','traceData',traceData);
    assignin('base','DiagDataTimeInfo',DiagDataTimeInfo);
    assignin('base','DiagDataOveral',DiagDataOveral);
    assignin('base','DiagDataMaster1',DiagDataMaster1);
    assignin('base','DiagDataMaster2',DiagDataMaster2);
    assignin('base','DiagDataMaster3',DiagDataMaster3);
    assignin('base','DiagDataMaster4',DiagDataMaster4);
    assignin('base','DiagDataMaster5',DiagDataMaster5);
    assignin('base','DiagDataMaster6',DiagDataMaster6);
    assignin('base','DiagDataMaster7',DiagDataMaster7);
    assignin('base','DiagDataMaster8',DiagDataMaster8);
    assignin('base','Master1DMAFIFOUtilization',Master1DMAFIFOUtilization);
    assignin('base','Master2DMAFIFOUtilization',Master2DMAFIFOUtilization);
    assignin('base','traceDataStruct',traceDataStruct);
    assignin('base','PMInfo',PMInfo);


    TraceDiagPlot=('LogicAnalyzerPlot');
    bdclose(TraceDiagPlot);
    sim(TraceDiagPlot);
    load_system(TraceDiagPlot);

    tracelogInst=Simulink.scopes.LAScope.getLogicAnalyzer(TraceDiagPlot);

    tracelogInst.openVisual;



    srcblks=find_system(TraceDiagPlot,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Type','Block');
    ports=get_param(srcblks,'PortHandles');
    oports=cellfun(@(x)x.Outport,ports,'UniformOutput',false);
    oports=[oports{:}];

    signals=get_param(oports,'Line');

    set_param(signals{1},'Selected','on');

    for ii=1:12
        Simulink.sdi.markSignalForStreaming(signals{ii},'off');

        tracelogInst.connectSignals(TraceDiagPlot);
    end


    Simulink.sdi.markSignalForStreaming(signals{2},'on');

    tracelogInst.connectSignals(TraceDiagPlot);


    for ii=3:numslots+2
        Simulink.sdi.markSignalForStreaming(signals{ii},'on');

        tracelogInst.connectSignals(TraceDiagPlot);
    end
    for ii=1:numDmas
        set_param(signals{10+ii},'Name',strcat('Master',num2str(DmaIndex(ii)),...
        'DMAFIFOUtilization'));
        Simulink.sdi.markSignalForStreaming(signals{10+ii},'on');

        tracelogInst.connectSignals(TraceDiagPlot);
    end


    sim(TraceDiagPlot);
    pause(2);
    sim(TraceDiagPlot);

end
