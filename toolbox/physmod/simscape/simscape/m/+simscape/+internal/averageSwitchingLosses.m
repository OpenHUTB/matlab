function[switchingLossesCellAveraged]=averageSwitchingLosses(switchingLossesCell,tStart,tEnd)










    switchingLossesCellAveraged=cell(size(switchingLossesCell));



    switchingLossesCellAveraged(:,1)=switchingLossesCell(:,1);

    for nodeNumber=1:size(switchingLossesCell,1)

        tVec=switchingLossesCell{nodeNumber,2}(:,1);
        lossVec=switchingLossesCell{nodeNumber,2}(:,2);
        if~isempty(tStart)&&~isempty(tEnd)
            if tEnd<=tStart
                pm_error('physmod:simscape:simscape:internal:powerDissipated:InvalidTimeRange');
            end
        end
        if isempty(tStart)
            t0=tVec(1);
        else
            t0=tStart;
        end
        if isempty(tEnd)
            tf=tVec(end);
        else
            tf=tEnd;
        end
        switchingLossesCellAveraged{nodeNumber,2}=sum(lossVec(tVec>=t0&tVec<=tf))/(tf-t0);

    end

end
