function uniqueRunName=makeRunNameUnique(this,runName)






    uniqueRunName=runName;



    dataLayer=fxptds.DataLayerInterface.getInstance();
    [~,fptRunID]=dataLayer.getIdFromRunName(this.TopModel,uniqueRunName);
    runNameExists=~isempty(fptRunID);

    counter=1;
    while(runNameExists)

        counter=counter+1;

        uniqueRunName=[runName,'_',num2str(counter)];
        [~,fptRunID]=dataLayer.getIdFromRunName(this.TopModel,uniqueRunName);
        runNameExists=~isempty(fptRunID);
    end

end
