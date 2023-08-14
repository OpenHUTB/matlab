function loadRangeData(obj)











    if isempty(obj.rangeFileLoc)
        return;
    end

    result_file_full_path=fullfile(obj.rangeFileLoc.DataFile);


    load(result_file_full_path,'sldvData');
    obj.rangeData=sldvData;
    clear sldvData

