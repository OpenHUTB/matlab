



function codeTable=convertSubSystemData(datamgr,...
    verification_data,...
    codeTable)



    funcNameData=[];
    fileNameData=[];
    for k=1:numel(verification_data)
        cell_data=verification_data{k};
        switch(cell_data.name)
        case 'SUBSYSTEM_FUNCTION_NAME'
            funcNameData=cell_data.data;
        case 'SUBSYSTEM_FILE_NAME'
            fileNameData=cell_data.data;
        end
    end


    populateSubSystemReaderObject(datamgr,funcNameData,'FUNCTION_Name');


    populateSubSystemReaderObject(datamgr,fileNameData,'FILE_NAME');

end


function populateSubSystemReaderObject(datamgr,inputData,data_kind)

    if~isempty(inputData)

        subsystemReader=datamgr.getSubSystemReader();
        subsystemTable=containers.Map;

        nameMap=slci.internal.ReportUtil.categorize('ID',inputData);
        datakeys=keys(nameMap);

        try
            for k=1:numel(datakeys)

                key=datakeys{k};
                nameData=nameMap(key);
                if numel(nameData)>1
                    DAStudio.error('Slci:results:DuplicateSubSystemData');
                end

                objKey=slci.results.SubSystemObject.constructKey(key);


                hasObj=slci.results.cacheData(...
                'check',subsystemTable,subsystemReader,...
                'hasObject',objKey);
                if hasObj

                    [sObject,subsystemTable]=...
                    slci.results.cacheData('get',subsystemTable,...
                    subsystemReader,...
                    'getObject',objKey);
                else

                    sObject=slci.results.SubSystemObject(key);


                    subsystemReader.insertObject(...
                    sObject.getKey(),sObject);
                end


                if strcmpi(data_kind,'FUNCTION_Name')
                    sObject.setMFuncName(nameData.M_NAME);
                    sObject.setCFuncName(nameData.C_NAME);
                elseif strcmpi(data_kind,'FILE_Name')
                    sObject.setMFileName(nameData.M_NAME);
                    sObject.setCFileName(nameData.C_NAME);
                end


                subsystemTable=slci.results.cacheData('update',...
                subsystemTable,objKey,sObject);

            end
        catch ex
            throw(ex);
        end


        slci.results.cacheData('save',subsystemTable,datamgr,...
        subsystemReader,'replaceObject');
    end
end