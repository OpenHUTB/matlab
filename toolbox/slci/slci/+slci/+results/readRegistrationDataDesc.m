

function dataTable=readRegistrationDataDesc(verification_data,...
    dataTable,...
    datamgr)


    inputData=[];
    for k=1:numel(verification_data)
        cell_data=verification_data{k};
        switch(cell_data.name)
        case 'REGISTRATION_DATA'
            inputData=cell_data.data;
        end
    end

    if~isempty(inputData)

        reader=datamgr.getReader('BLOCK');
        dataMap=slci.internal.ReportUtil.categorize('ID',inputData);
        dataKeys=keys(dataMap);
        for k=1:numel(dataKeys)

            keyVal=dataKeys{k};
            dataValues=dataMap(keyVal);
            if numel(dataValues)>1
                DAStudio.error('Slci:results:DuplicateRegDescData');
            end

            if strcmpi(dataValues.ISDEFINED,'TRUE')
                type=dataValues.TYPE;
                dataObject=slci.results.RegistrationDataObject(keyVal,type);

                reader.insertObject(dataObject.getKey(),dataObject);
            end
        end
    end

end
