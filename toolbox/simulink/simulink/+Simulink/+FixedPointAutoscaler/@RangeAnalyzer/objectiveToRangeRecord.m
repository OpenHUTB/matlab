function rangeRecord=objectiveToRangeRecord(obj,objective)




    if strcmpi(objective.type,'Range')
        rangeRecord=processRangeObjective(obj,objective);
    else
        rangeRecord=[];
    end


    function rangeRecord=processRangeObjective(obj,objective)

        if isempty(objective.range)
            if slsvTestingHook('RAviaRTWtesting')>1
                objectPath='DEFAULT VALUE';
                try
                    objectPath=obj.rangeData.ModelObjects(objective.modelObjectIdx).slPath;
                catch ME %#ok<NASGU>
                end
                fprintf('Empty {} range for objective associated with:\n%s\n\n',objectPath);
            end
            rangeRecord=[];
            return;
        end

        [url,isSFRecordFromURL,instanceHdl]=obj.objectiveToURL(objective);

        if isempty(url)
            if slsvTestingHook('RAviaRTWtesting')>1
                objectPath='DEFAULT VALUE';
                try
                    objectPath=obj.rangeData.ModelObjects(objective.modelObjectIdx).slPath;
                catch ME %#ok<NASGU>
                end
                fprintf('Error creating URL for objective associated with:\n%s\n\n',objectPath);
            end
            rangeRecord=[];
            return
        end

        rangeRecord=Simulink.FixedPointAutoscaler.RangeRecord(obj.model,url);


        rangeRecord.derivedRangeIntervals=cellfun(@double,objective.range);
        rangeRecord.derivedMin=min(rangeRecord.derivedRangeIntervals(:));
        if numel(objective.range)==1

            rangeRecord.derivedMax=rangeRecord.derivedMin;
        else
            rangeRecord.derivedMax=max(rangeRecord.derivedRangeIntervals(:));
        end
        rangeRecord.isEmptyRange=rangeRecord.derivedMin>rangeRecord.derivedMax;




        rangeRecord.isSFRecord=isSFRecordFromURL;
        rangeRecord.instanceHandle=instanceHdl;


        if slsvTestingHook('RAviaRTWtesting')==1
            rangeRecord.derivedRWVMin=rangeRecord.derivedMin;
            rangeRecord.derivedRWVMax=rangeRecord.derivedMax;
        end

        if~isempty(objective.emlVarId)
            rangeRecord.emlId=obj.rangeData.EmlIdInfo(objective.emlVarId);
        else
            rangeRecord.emlId=[];
        end





