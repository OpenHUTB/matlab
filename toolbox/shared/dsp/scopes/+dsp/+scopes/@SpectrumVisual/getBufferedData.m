function data=getBufferedData(this)






    allData=getData(this.Application.DataSource,0,0,1);

    d=struct;
    for indx=1:numel(allData)
        d=allData(indx);
    end
    data=d.values;
end
