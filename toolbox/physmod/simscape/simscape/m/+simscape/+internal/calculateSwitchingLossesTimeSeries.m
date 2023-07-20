function[switchingLossesCell]=calculateSwitchingLossesTimeSeries(switchingLossesTimeseriesCell)












    switchingLossesCell=cell(size(switchingLossesTimeseriesCell));



    switchingLossesCell(:,1)=switchingLossesTimeseriesCell(:,1);
    switchingLossesCell(:,3)=switchingLossesTimeseriesCell(:,3);

    for nodeNumber=1:size(switchingLossesTimeseriesCell,1)


        timeVec=switchingLossesTimeseriesCell{nodeNumber,2}(:,1);
        lastSwLossSeries=switchingLossesTimeseriesCell{nodeNumber,2}(:,2);


        indexesSwitchingLoss=find(diff(lastSwLossSeries)>0);
        indexesSwitchingLoss=indexesSwitchingLoss+1;


        if~isempty(indexesSwitchingLoss)
            timeLossEvents=timeVec(indexesSwitchingLoss);
            switchingLossValues=lastSwLossSeries(indexesSwitchingLoss);
        else
            timeLossEvents=[timeVec(1);timeVec(end)];
            switchingLossValues=[0;0];
        end

        switchingLossesCell{nodeNumber,2}=[timeLossEvents,switchingLossValues];

    end

end
