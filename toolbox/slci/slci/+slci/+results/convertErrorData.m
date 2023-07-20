function convertErrorData(datamgr,verification_data)



    errorData=[];
    for k=1:numel(verification_data)
        cell_data=verification_data{k};
        switch(cell_data.name)
        case 'ERRORS'
            errorData=cell_data.data;
        end
    end

    errorReader=datamgr.getErrorReader();
    datamgr.beginTransaction();
    try
        for k=1:numel(errorData)
            eObject=slci.results.ErrorObject(errorData.ERROR_MESSAGE);
            errorReader.insertObject(eObject.getKey(),eObject);
        end
    catch ex
        datamgr.rollbackTransaction();
        throw(ex);
    end

    datamgr.commitTransaction();


end
