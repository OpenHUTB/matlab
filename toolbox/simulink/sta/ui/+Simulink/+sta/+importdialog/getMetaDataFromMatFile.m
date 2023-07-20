function[jsonStruct,warnStr,datasourceMetrics]=getMetaDataFromMatFile(aFile)






    try
        [aList,warnStr]=import(aFile);
        datasourceMetrics=aFile.fileMetrics;
        jsonStruct={};
        [~,fileName,ext]=fileparts(aFile.FileName);

        for k=1:length(aList.Names)



            itemFactory=starepository.factory.createSignalItemFactory(aList.Names{k},aList.Data{k});

            if~isempty(itemFactory)
                item=itemFactory.createTopLevelSignalItem;
                jsonStruct=getItemStructure(item,jsonStruct,[fileName,ext]);
            end

        end


        for kStruct=1:length(jsonStruct)
            jsonStruct{kStruct}.TreeOrder=kStruct;
        end

    catch ME
        throw(ME);
    end

end

function str=getItemStructure(item,str,dataSource)
    itemCell=item.ioitem2Structure;
    aStr=itemCell{1};
    aStr.ID=item.getID;
    [~,aDataSourcefile,aDataSourceExt]=fileparts(dataSource);
    aStr.DataSource=[aDataSourcefile,aDataSourceExt];
    aStr.FullDataSource=dataSource;
    if(item.isBus)
        str{end+1}=aStr;


























    else
        if isfield(aStr,'MinTime')
            aStr=rmfield(aStr,'MinTime');
        end
        if isfield(aStr,'MaxTime')
            aStr=rmfield(aStr,'MaxTime');
        end
        if isfield(aStr,'MinData')
            aStr=rmfield(aStr,'MinData');
        end
        if isfield(aStr,'MaxData')
            aStr=rmfield(aStr,'MaxData');
        end
        str{end+1}=aStr;
    end
end
