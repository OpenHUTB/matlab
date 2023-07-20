function flag=autoblksIsEnrgyBalanced(PwrSignalInOut,PwrSignalStored,EnrgyBalanceRelTol,EnrgyBalanceAbsTol)





    EnrgyIn=sumSignals(PwrSignalInOut,'Positive');
    EnrgyOut=sumSignals(PwrSignalInOut,'Negative');
    StoredEnrgyIn=sumSignals(PwrSignalStored,'Positive');
    StoredEnrgyOut=sumSignals(PwrSignalStored,'Negative');

    [EnrgyIn,EnrgyOut,StoredEnrgyIn,StoredEnrgyOut]=autoblksMatchTimeseriesTime(EnrgyIn,EnrgyOut,StoredEnrgyIn,StoredEnrgyOut);
    EnrgyBalance=EnrgyIn-EnrgyOut-StoredEnrgyIn+StoredEnrgyOut;
    TotalEnrgy=EnrgyIn+EnrgyOut+StoredEnrgyIn+StoredEnrgyOut;


    flag=true;
    if~isempty(TotalEnrgy.Data)
        FinalTotalEnrgyFlow=TotalEnrgy.Data(end)/2;
        if FinalTotalEnrgyFlow>EnrgyBalanceAbsTol
            EnrgyFrac=EnrgyBalance/FinalTotalEnrgyFlow;
            if~all(abs(EnrgyFrac.Data)<=EnrgyBalanceRelTol)
                flag=false;
            end
        end
    end

end


function Enrgy=sumSignals(Val,FlowDir)
    if isempty(Val)
        Enrgy=0;
    else
        switch FlowDir
        case 'Positive'
            DirSignal=Val(1).PwrPositive;
            for i=2:length(Val)
                DirSignal=DirSignal+Val(i).PwrPositive;
            end
        case 'Negative'
            DirSignal=-Val(1).PwrNegative;
            for i=2:length(Val)
                DirSignal=DirSignal-Val(i).PwrNegative;
            end
        end
        DirSignal=sum(DirSignal);
        Enrgy=DirSignal.Enrgy;
    end
end
