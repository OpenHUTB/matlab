function timestamp=getFileTimeStamp(file)




    timestamp='';
    if~isempty(file)&&exist(file,'file')
        record=dir(eval('file'));
        if~isempty(record)
            timestamp=datestr(record(1).datenum,'en_US');
        end
    end

