function restoreTolerances(this,DataRunID,filename)



    temp=load(filename);


    try
        entry=temp.TolSave.Entry{1};
        if~strcmp(entry.Key,'global_tolerance')

            return;
        end
        if(isfield(entry,'Content'))
            entry=entry.Content;
        end

        setToleranceDetailsByRun(this,int32(DataRunID),entry);

        for i=2:length(temp.TolSave.Entry)
            entry=temp.TolSave.Entry{i};
            if(isfield(entry,'Content'))
                entry=entry.Content;
            end
            try
                dataObj=this.getSignal(entry.Key);
            catch %#ok
                if strcmp(entry.Key,'global_tolerance')
                    setToleranceDetailsByRun(this,int32(DataRunID),entry);
                end

                continue;
            end

            setToleranceDetails(this,dataObj.DataID,entry);
        end
    catch ME
        rethrow(ME);
    end
end


function setToleranceDetailsByRun(this,DataRunID,values)



    if isfield(values,'absolute')
        this.setAbsTolByRun(int32(DataRunID),...
        values.absolute);
    end
    if isfield(values,'relative')
        this.setRelTolByRun(int32(DataRunID),...
        values.relative);
    end
end

function setToleranceDetails(this,dataID,values)


    if isfield(values,'absolute')
        this.setSignalAbsTol(int32(dataID),...
        values.absolute);
    end
    if isfield(values,'relative')
        this.setSignalRelTol(int32(dataID),...
        values.relative);
    end
end