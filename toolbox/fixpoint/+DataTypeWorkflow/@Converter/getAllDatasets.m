function allDatasets=getAllDatasets(this)







    allDatasets=cell(size(this.AllSystems));
    for i=1:length(this.AllSystems)
        appdata=SimulinkFixedPoint.getApplicationData(this.AllSystems{i});
        allDatasets{i}=appdata.dataset;
    end

end
