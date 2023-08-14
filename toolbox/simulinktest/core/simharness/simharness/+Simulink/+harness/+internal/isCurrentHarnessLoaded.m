function res=isCurrentHarnessLoaded(harnessName,harnessList)


    res=false;
    for i=1:length(harnessList)
        if isequal(harnessName,harnessList(i).name)
            res=true;
            break;
        end
    end
end