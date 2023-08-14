function saveNewFigures(resultID,sourceID,indx,newFigs)




    for cnt=1:length(newFigs)
        stm.internal.artifacts.savePlot(newFigs(cnt),sourceID,indx,resultID,cnt);
    end
end