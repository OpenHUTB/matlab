function shareAcrossModelReference(this,runObj)






    allResults=runObj.getResults;




    for i=1:length(allResults)



        this.shareAcrossDataset(runObj,allResults(i));
    end


end
