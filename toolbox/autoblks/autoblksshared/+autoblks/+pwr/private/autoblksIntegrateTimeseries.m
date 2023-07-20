function[IntSignal,FinalVal]=autoblksIntegrateTimeseries(Signal,InitVal)







    if nargin<2
        InitVal=0;
    end
    if all(size(Signal.Data)>1)
        Data=zeros(size(Signal.Data));
        for i=1:size(Data,2)
            Data(:,i)=cumtrapz(Signal.Time,Signal.Data(:,i))+InitVal;
        end

        FinalVal=Data(:,end);
    else
        if length(Signal.Data)>1
            Data=cumtrapz(Signal.Time,Signal.Data)+InitVal;
        else
            Data=InitVal;
        end
        FinalVal=Data(end);
    end
    IntSignal=timeseries(Data,Signal.Time);
end