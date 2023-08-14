function highestAlert=getHighestAlertLevel(allAlerts)









    if any(strcmp(allAlerts,'red'))
        highestAlert='red';
        return;
    end



    if any(strcmp(allAlerts,'yellow'))
        highestAlert='yellow';
        return;
    end



    highestAlert='green';
end