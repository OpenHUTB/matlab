function limits=getLimits(data)





    if iscategorical(data)
        dataDouble=double(data);
        [~,iMin]=min(dataDouble,[],"all");
        [~,iMax]=max(dataDouble,[],"all");
        limits=[data(iMin),data(iMax)];
        return
    end

    data=data(isfinite(data));
    if isempty(data)
        if isdatetime(data)
            limits=[datetime(1970,1,1),datetime(1970,1,2)];
        else
            limits=[0,1];
        end
        return
    end
    if isnumeric(data)||islogical(data)
        [minVal,maxVal]=bounds(double(real(data)),"all");
    else
        [minVal,maxVal]=bounds(data,"all");
    end
    if isequal(minVal,maxVal)
        minVal=minVal-1;
        maxVal=maxVal+1;
    end
    limits=[minVal,maxVal];