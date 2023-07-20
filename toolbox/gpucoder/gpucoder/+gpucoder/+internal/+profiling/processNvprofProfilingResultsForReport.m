function[profileData,summaryData,completeTraceData,startUnit]=processNvprofProfilingResultsForReport(gpuTraceLogFile,numIterations,excludeFirst,thresholdParam)






    [gpuTraceTempTable,startUnit,durationUnit]=genTable(gpuTraceLogFile);

    if~isempty(gpuTraceTempTable)

        gpuTraceCompleteStruct=table2struct(gpuTraceTempTable);


        [~,relevant_apiCallNames_rangeStart]=getRelevantGPUapiCallNames(gpuTraceCompleteStruct,{'[Range start] _mw_'});
        relevant_apiCallNames_rangeStartNames={relevant_apiCallNames_rangeStart{1:numel(relevant_apiCallNames_rangeStart)/numIterations}};
        relevant_apiCallNames=getCallNamesFromRangeStart(relevant_apiCallNames_rangeStartNames);

        if excludeFirst
            gpuTraceCompleteStruct=removeFirstIteration(gpuTraceCompleteStruct,relevant_apiCallNames_rangeStartNames);
            numIterations=numIterations-1;
        end
        [startId,endId,~]=getMaxIterationBounds(gpuTraceCompleteStruct,relevant_apiCallNames_rangeStartNames);

        gpuTraceCompleteStruct=preprocessTraceStruct_nvtx(gpuTraceCompleteStruct);
        gpuTraceCompleteStruct=replaceNamesWithRelevantGPUCalls(gpuTraceCompleteStruct,relevant_apiCallNames);

        completeTraceData=computeCompleteTrace(gpuTraceCompleteStruct,startUnit,durationUnit,relevant_apiCallNames);

        gpuTraceSubStruct=gpuTraceCompleteStruct(startId:endId);

        gpuTraceSubStruct=removeElems_with_name(gpuTraceSubStruct,'nvtx_profilingOverhead');
        profileData=computeMaxProfileData_with_threshold(gpuTraceSubStruct,thresholdParam);
        summaryData=computeSummary_with_MaxProfileData(profileData,gpuTraceCompleteStruct,numIterations);

    else
        summaryData=struct.empty;
        profileData=struct.empty;
        completeTraceData=struct.empty;

    end

end

function[startId,endId,maxDuration]=getMaxIterationBounds(gpuStruct,apiCallNames)
    id_gpuStruct_end=1;id_gpuStruct_start=0;
    num_apiCalls=numel(apiCallNames);
    maxDuration=0;

    while id_gpuStruct_start<id_gpuStruct_end

        id_gpuStruct_start=id_gpuStruct_end;
        id_apiCalls=1;

        while((id_apiCalls<=num_apiCalls)&&(id_gpuStruct_end<=numel(gpuStruct)))
            if strcmp(apiCallNames{id_apiCalls},gpuStruct(id_gpuStruct_end).Name)
                id_apiCalls=id_apiCalls+1;
            end
            id_gpuStruct_end=id_gpuStruct_end+1;
        end

        while id_gpuStruct_end<=numel(gpuStruct)&&...
            ~contains(gpuStruct(id_gpuStruct_end).Name,'[Range end]')
            id_gpuStruct_end=id_gpuStruct_end+1;
        end

        if id_gpuStruct_end<=numel(gpuStruct)&&...
            maxDuration<(gpuStruct(id_gpuStruct_end).Start-gpuStruct(id_gpuStruct_start).Start)
            maxDuration=gpuStruct(id_gpuStruct_end).Start-gpuStruct(id_gpuStruct_start).Start;
            indices={id_gpuStruct_start,id_gpuStruct_end};
            id_gpuStruct_end=id_gpuStruct_end+1;
        end

    end
    startId=indices{1};endId=indices{2};

end


function profileData=computeMaxProfileData_with_threshold(gpuStruct,threshold)
    id=[];
    for i=1:numel(gpuStruct)
        gpuCallsBool=((gpuStruct(i).Duration<=threshold)||isnan(gpuStruct(i).Duration));
        if gpuCallsBool
            id=[id,i];
        end

    end
    gpuStruct(id)=[];

    if(~isempty(gpuStruct))
        gpuStruct=rmfield(gpuStruct,{'Start'});

        numGpuCalls=numel(gpuStruct);

        for i=1:numGpuCalls

            profileData(i).Duration=gpuStruct(i).Duration;
            profileData=addElem2NewStruct(gpuStruct,profileData,i);

        end

        profileData=imakeNameFirstField(profileData);
    else
        profileData=struct.empty;
        warning(message('gpucoder:profile:sil_high_threshold'));

    end
end

function summaryData=computeSummary_with_MaxProfileData(profileData,gpuTraceCompleteStruct,numIterations)

    if~isempty(profileData)
        nameArray={profileData.Name};
        [uniqueNames,I]=unique(nameArray);
        summaryData=profileData(I);

        fields_intended_to_be_Removed={'GridDims','BlockDims','StaticSharedMem','Throughput','Size','Duration'};
        summaryData=removeFields(summaryData,fields_intended_to_be_Removed);

        completeNameArray={gpuTraceCompleteStruct.Name};
        for i=uniqueNames
            boolArray=strcmp(completeNameArray,i);
            totalNumCalls=sum(boolArray);
            numCallsPerIteration=totalNumCalls/numIterations;
            Id=find(strcmp({summaryData.Name},i));
            summaryData(Id).TotalAvgTime=sum([gpuTraceCompleteStruct(boolArray).Duration])/totalNumCalls*numCallsPerIteration;%#ok<FNDSB>
            summaryData(Id).NumCalls=numCallsPerIteration;
        end

        [~,sortedIndex]=sort([summaryData(:).TotalAvgTime],'descend');
        summaryData=summaryData(sortedIndex);
    else
        summaryData=struct.empty;
    end
end


function gpuTraceCompleteStruct=replaceNamesWithRelevantGPUCalls(gpuTraceCompleteStruct,relevant_apiCallNames)

    for i=1:numel(gpuTraceCompleteStruct)
        for j=1:numel(relevant_apiCallNames)
            if contains(gpuTraceCompleteStruct(i).Name,relevant_apiCallNames{j})
                relevantName=regexp(gpuTraceCompleteStruct(i).Name,[relevant_apiCallNames{j},'\d*'],'match');
                if contains(gpuTraceCompleteStruct(i).Name,'cudaLaunch')
                    gpuTraceCompleteStruct(i).Name=['cudaLaunch(',relevantName{:},')'];
                else
                    gpuTraceCompleteStruct(i).Name=relevantName{:};
                end
                break;
            end
        end
    end

end


function[gpuStruct,apiCallNames]=getRelevantGPUapiCallNames(gpuStruct,varargin)
    if isempty(varargin)
        supportedGPUCalls={'kernel','CUDAmemcpy','cudaMalloc','cudaFree','cublas','cufft',...
        'cudnn','cusolver','cudaDeviceSynchronize','DeepLearningNetwork','[Range'};
    else
        supportedGPUCalls=varargin{1};
    end
    id=contains({gpuStruct.Name},supportedGPUCalls);
    gpuStruct=gpuStruct(id);
    apiCallNames={gpuStruct.Name};
end


function gpuTraceCompleteStruct=preprocessTraceStruct_nvtx(gpuTraceCompleteStruct)

    for i=1:numel(gpuTraceCompleteStruct)

        gpuTraceCompleteStruct(i).Name=remove_digits_within_squareBrackets(gpuTraceCompleteStruct(i).Name);
        if contains(gpuTraceCompleteStruct(i).Name,'[CUDA')||contains(gpuTraceCompleteStruct(i).Name,'[Unified')
            fieldName=gpuTraceCompleteStruct(i).Name;
            fieldName=fieldName(2:end-1);
            gpuTraceCompleteStruct(i).Name=fieldName;
        end
        gpuTraceCompleteStruct(i).Name=replace_modify_String(gpuTraceCompleteStruct(i).Name,'Range','nvtx_profilingOverhead');

    end
    gpuTraceCompleteStruct=removeElems_with_name(gpuTraceCompleteStruct,'');


    fields_intended_to_be_Removed={'RegistersPerThread','DynamicSMem','Device','Context','Stream',...
    'SrcMemType','DstMemType','UnifiedMemory','VirtualAddress'};
    gpuTraceCompleteStruct=removeFields(gpuTraceCompleteStruct,fields_intended_to_be_Removed);

end


function completeTrace=computeCompleteTrace(gpuTraceCompleteStruct,startUnit,durationUnit,relevant_apiCallNames)


    completeTrace(1).Start=gpuTraceCompleteStruct(1).Start;
    completeTrace(1).End=[];
    completeTrace(1).Duration=[];
    completeTrace(1).numCalls=1;
    completeTrace=addElem2NewStruct(gpuTraceCompleteStruct,completeTrace,1);

    numGpuElems=numel(gpuTraceCompleteStruct);
    i=2;
    if~isnan(gpuTraceCompleteStruct(1).Duration)
        duration=gpuTraceCompleteStruct(1).Duration;
    else
        duration=0;
    end

    while(i<=numGpuElems)


        if~(strcmp(gpuTraceCompleteStruct(i).Name,completeTrace(i-1).Name))||any(strcmp(gpuTraceCompleteStruct(i).Name,relevant_apiCallNames))

            if~isnan(gpuTraceCompleteStruct(i).Duration)
                duration=gpuTraceCompleteStruct(i).Duration;
            else
                duration=0;
            end

            completeTrace(i).Start=gpuTraceCompleteStruct(i).Start;
            completeTrace(i-1).End=gpuTraceCompleteStruct(i).Start;
            completeTrace(i-1).Duration=completeTrace(i-1).End-completeTrace(i-1).Start;
            completeTrace(i).numCalls=1;
            completeTrace=addElem2NewStruct(gpuTraceCompleteStruct,completeTrace,i);
            i=i+1;
        else
            if~isnan(gpuTraceCompleteStruct(i).Duration)
                duration=duration+gpuTraceCompleteStruct(i).Duration;
            end

            tempVar=completeTrace(i-1).numCalls;
            completeTrace(i-1).numCalls=tempVar+1;
            gpuTraceCompleteStruct(i)=[];
            numGpuElems=numel(gpuTraceCompleteStruct);
        end

    end

    completeTrace(numGpuElems).Duration=duration;
    if strcmp(startUnit,'s')&&strcmp(durationUnit,'ms')
        completeTrace(numGpuElems).End=completeTrace(numGpuElems).Start+duration/1000;
    elseif strcmp(startUnit,'ms')&&strcmp(durationUnit,'s')
        completeTrace(numGpuElems).End=completeTrace(numGpuElems).Start+duration*1000;
    else
        completeTrace(numGpuElems).End=completeTrace(numGpuElems).Start+duration;
    end


    completeTrace=imakeNameFirstField(completeTrace);


    if strcmp(startUnit,'s')
        for i=1:numel(completeTrace)-1
            completeTrace(i).Duration=completeTrace(i).Duration*1000;
        end
    end

end


function[start_unit,duration_unit]=getUnits(text_in_csv,variableUnitsLine)
    units=text_in_csv{variableUnitsLine};


    if~contains(units,',')
        start_unit=units;
        duration_unit=text_in_csv{variableUnitsLine,2};
    else
        units=split(units,',');
        start_unit=units{1};
        duration_unit=units{2};
    end

    assert(any(strcmp(start_unit,{'s','ms'})),'Unit is neither "ms" nor "s".');
    assert(any(strcmp(duration_unit,{'s','ms'})),'Unit is neither "ms" nor "s".');
end


function[outTable,start_unit,duration_unit]=genTable(logFile)
    opts=detectImportOptions(logFile,'Delimiter',',');
    opts.VariableUnitsLine=opts.VariableNamesLine+1;
    opts.DataLines(1)=opts.VariableNamesLine+2;
    outTable=table.empty;
    start_unit='';
    duration_unit='';
    try
        text_in_csv=importdata(logFile);
        try

            if(isstruct(text_in_csv)&&isfield(text_in_csv,'textdata'))
                text_in_csv=text_in_csv.textdata;
            end
            [start_unit,duration_unit]=getUnits(text_in_csv,opts.VariableUnitsLine);

            warning('off','MATLAB:table:ModifiedAndSavedVarnames');
            outTable=readtable(logFile,opts);
            warning('on','MATLAB:table:ModifiedAndSavedVarnames');
        catch
            warning(message('gpucoder:profile:sil_log_empty_file'));
        end
    catch
        warning(message('gpucoder:profile:sil_log_file'));
    end


end


function struct=addElem2NewStruct(gpuTraceCompleteStruct,struct,id)
    struct(id).Name=gpuTraceCompleteStruct(id).Name;

    if isfield(gpuTraceCompleteStruct,'GridX')
        gpuTraceCompleteStruct(id).GridX=validate_and_convert2numeric(gpuTraceCompleteStruct(id).GridX);
        gpuTraceCompleteStruct(id).GridY=validate_and_convert2numeric(gpuTraceCompleteStruct(id).GridY);
        gpuTraceCompleteStruct(id).GridZ=validate_and_convert2numeric(gpuTraceCompleteStruct(id).GridZ);
        if(~isnan(gpuTraceCompleteStruct(id).GridX)&&~isnan(gpuTraceCompleteStruct(id).GridY)&&~isnan(gpuTraceCompleteStruct(id).GridZ))
            struct(id).GridDims=[gpuTraceCompleteStruct(id).GridX,gpuTraceCompleteStruct(id).GridY,gpuTraceCompleteStruct(id).GridZ];
        else
            struct(id).GridDims=[];
        end
    end

    if isfield(gpuTraceCompleteStruct,'BlockX')
        gpuTraceCompleteStruct(id).BlockX=validate_and_convert2numeric(gpuTraceCompleteStruct(id).BlockX);
        gpuTraceCompleteStruct(id).BlockY=validate_and_convert2numeric(gpuTraceCompleteStruct(id).BlockY);
        gpuTraceCompleteStruct(id).BlockZ=validate_and_convert2numeric(gpuTraceCompleteStruct(id).BlockZ);
        if(~isnan(gpuTraceCompleteStruct(id).BlockX)&&~isnan(gpuTraceCompleteStruct(id).BlockY)&&~isnan(gpuTraceCompleteStruct(id).BlockZ))
            struct(id).BlockDims=[gpuTraceCompleteStruct(id).BlockX,gpuTraceCompleteStruct(id).BlockY,gpuTraceCompleteStruct(id).BlockZ];
        else
            struct(id).BlockDims=[];
        end
    end


    if isfield(gpuTraceCompleteStruct,'StaticSMem')
        gpuTraceCompleteStruct(id).StaticSMem=validate_and_convert2numeric(gpuTraceCompleteStruct(id).StaticSMem);
        if~isnan(gpuTraceCompleteStruct(id).StaticSMem)
            struct(id).StaticSharedMem=gpuTraceCompleteStruct(id).StaticSMem/1000;
        else
            struct(id).StaticSharedMem=[];
        end
    end
    if isfield(gpuTraceCompleteStruct,'Size')
        gpuTraceCompleteStruct(id).Size=validate_and_convert2numeric(gpuTraceCompleteStruct(id).Size);
        if~isnan(gpuTraceCompleteStruct(id).Size)
            struct(id).Size=gpuTraceCompleteStruct(id).Size;
        else
            struct(id).Size=[];
        end
    end

    if isfield(gpuTraceCompleteStruct,'Throughput')
        gpuTraceCompleteStruct(id).Throughput=validate_and_convert2numeric(gpuTraceCompleteStruct(id).Throughput);
        if~isnan(gpuTraceCompleteStruct(id).Throughput)
            struct(id).Throughput=gpuTraceCompleteStruct(id).Throughput;
        else
            struct(id).Throughput=[];
        end
    end
end



function struct=imakeNameFirstField(struct)

    fieldNames=fieldnames(struct);
    fieldNames(strcmp(fieldNames,'Name'))=[];
    fieldNames={'Name',fieldNames{:}};%#ok<CCAT>
    struct=orderfields(struct,fieldNames);

end




function sub_gpuStruct=removeFirstIteration(gpuStruct,apiCallNames)

    id_apiCalls=1;id_gpuStruct=1;
    num_apiCalls=numel(apiCallNames);


    while(id_apiCalls<=num_apiCalls+1)
        if strcmp(apiCallNames{xor(mod(id_apiCalls,num_apiCalls),1)*num_apiCalls+mod(id_apiCalls,num_apiCalls)},gpuStruct(id_gpuStruct).Name)
            id_apiCalls=id_apiCalls+1;
        end
        id_gpuStruct=id_gpuStruct+1;

    end
    sub_gpuStruct=gpuStruct(id_gpuStruct-1:end);

end




function numeric_var=validate_and_convert2numeric(var)
    if ischar(var)
        numeric_var=str2double(var);
    else
        numeric_var=var;
    end
end



function fieldsToRemove=getfieldsToRemove(struct,fields_intended_to_be_Removed)
    fieldsToRemove={};
    for i=1:numel(fields_intended_to_be_Removed)
        fieldsToRemove=check_2_remove(struct,fieldsToRemove,fields_intended_to_be_Removed{i});
    end
end



function rmfieldsArray=check_2_remove(struct,rmfieldsArray,field)
    if isfield(struct,field)
        rmfieldsArray{end+1}=field;
    end

end


function names=getCallNamesFromRangeStart(rangeNames)
    for i=1:numel(rangeNames)
        ts=regexp(rangeNames{i},'\_+\d+\s+(Domain+.+\)','match');
        names{i}=erase(rangeNames{i},{'[Range start] ',ts{:}});

    end
    names=unique(names);
    names{end+1}='CUDA memcpy HtoD';names{end+1}='CUDA memcpy DtoH';
end

function gpuStruct=removeElems_with_name(gpuStruct,name)

    id=[];
    for i=1:numel(gpuStruct)
        gpuCallsBool=strcmp(gpuStruct(i).Name,name);
        if gpuCallsBool
            id=[id,i];
        end

    end
    gpuStruct(id)=[];

end

function str=remove_digits_within_squareBrackets(str)
    ts1=regexp(str,'\[\d+\]','match');
    if~isempty(ts1)
        str=erase(str,ts1{:});
    end

    ts2=regexp(str,'\[\d+','match');
    if~isempty(ts2)
        str=erase(str,ts2{:});
    end
end

function str=replace_modify_String(str,StringToCompare,modifiedStr)
    if contains(str,StringToCompare)
        str=modifiedStr;
    end
end

function gpuStruct=removeFields(gpuStruct,fields_intended_to_be_Removed)


    fieldsToRemove=getfieldsToRemove(gpuStruct,fields_intended_to_be_Removed);
    gpuStruct=rmfield(gpuStruct,fieldsToRemove);
end