function buf=ec_data_user_dump(record)





    cr=sprintf('\n');
    buf=[];
    for i=1:length(record.DataObject)

        name=record.DataObject(i).Name;
        readIndex=record.DataObject(i).ReadFromFile;
        writeIndex=record.DataObject(i).WrittenInFile;
        buf=[buf,'Name: ',name,cr];

        for j=1:length(readIndex)
            buf=[buf,' Read:  ',record.File(readIndex(j)+1).Name,cr];
        end

        for j=1:length(writeIndex)
            buf=[buf,' Write: ',record.File(writeIndex(j)+1).Name,cr];
        end
    end