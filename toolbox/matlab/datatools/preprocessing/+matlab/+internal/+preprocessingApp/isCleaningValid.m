function[isvalid,msg]=isCleaningValid(cleaningTask,data,~)















    msg=struct();
    isvalid=true;
    if contains(cleaningTask.Name,{'Outlier','Smooth','Missing'})&&isa(data,'timetable')
        time=data.Properties.RowTimes;
        errorText=[];


        if anymissing(time)
            errorText=getString(message('MATLAB:datatools:preprocessing:app:TIMESTAMP_HAS_MISSING'));
        elseif~allfinite(time)
            errorText=getString(message('MATLAB:datatools:preprocessing:app:TIMESTAMP_NON_FINITE'));
        elseif any(diff(time)<=0)

            errorText=getString(message('MATLAB:datatools:preprocessing:app:TIMESTAMP_NOT_SORTED'));
        end
        if~isempty(errorText)
            isvalid=false;
            msg.text=errorText;
            msg.title=getString(message('MATLAB:datatools:preprocessing:app:CLEAN_TIME_DIALOG_TITLE'));
        end
    end
end

