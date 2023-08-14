function[profileData,summaryData]=processNsysProfilingResultsForReport(gpuTraceLogFile,numIterations,excludeFirst,threshold)







    [labels,gpuTrace]=gpucoder.internal.profiling.parseNsysJson(gpuTraceLogFile);

    gpuTraceCompleteStruct=preprocessTraceStruct(gpuTrace,labels,numIterations);

    if~isempty(gpuTraceCompleteStruct)

        if excludeFirst
            gpuTraceCompleteStruct=removeFirstIteration(gpuTraceCompleteStruct);
            numIterations=numIterations-1;

            if numIterations<=0
                numIterations=1;
            end
        end

        profileData=generateAverageProfile(gpuTraceCompleteStruct);
        summaryData=computeSummaryData(gpuTraceCompleteStruct,numIterations);
        [profileData,summaryData]=enforceThreshold(profileData,summaryData,threshold*1e3);

    else
        summaryData=struct.empty;
        profileData=struct.empty;
    end
end

function[newProfileData,newSummaryData]=enforceThreshold(profileData,summaryData,thresholdParam)
    if isempty(profileData)
        newProfileData=struct.empty;
    else
        newProfileData=profileData([profileData.Duration]>thresholdParam);

    end
    if isempty(summaryData)
        newSummaryData=struct.empty;
    else
        newSummaryData=summaryData([summaryData.TotalAvgTime]>thresholdParam);
    end

end


function gpuTraceCompleteStruct=preprocessTraceStruct(gpuTrace,labels,numIterations)

    j=1;
    iterIdx=1;
    cudaEventFieldsToTrack=["kernel","memset"];
    gpuTraceCompleteStruct=cell(1,numIterations);
    startTracing=false;
    for i=1:numel(gpuTrace)

        if isfield(gpuTrace{i},'NvtxEvent')
            event=gpuTrace{i}.NvtxEvent;
            if isfield(event,'Text')
                if strcmp(event.Text,'_mw_#startPoint#')
                    startTracing=true;
                elseif strcmp(event.Text,'_mw_#exitPoint#')
                    j=1;
                    iterIdx=iterIdx+1;
                    startTracing=false;
                end
            end
        elseif isfield(gpuTrace{i},'CudaEvent')&&startTracing
            event=gpuTrace{i}.CudaEvent;

            if any(contains(fields(event),cudaEventFieldsToTrack))
                gpuTraceCompleteStruct{iterIdx}(j).Start=str2double(event.startNs);%#ok<*AGROW>
                gpuTraceCompleteStruct{iterIdx}(j).Duration=str2double(event.endNs)-str2double(event.startNs);
            end
            if isfield(event,'memcpy')&&contains('memcpy',cudaEventFieldsToTrack)
                memcpyStruct=event.memcpy;
                gpuTraceCompleteStruct{iterIdx}(j).Size=str2double(memcpyStruct.sizebytes);









                if memcpyStruct.copyKind=='1'
                    gpuTraceCompleteStruct{iterIdx}(j).Name='cudaMemcpy [HtoD]';
                elseif memcpyStruct.copyKind=='2'
                    gpuTraceCompleteStruct{iterIdx}(j).Name='cudaMemcpy [DtoH]';
                elseif memcpyStruct.copyKind=='8'
                    gpuTraceCompleteStruct{iterIdx}(j).Name='cudaMemcpy [DtoD]';
                elseif memcpyStruct.copyKind=='9'
                    gpuTraceCompleteStruct{iterIdx}(j).Name='cudaMemcpy [HtoH]';
                end
                j=j+1;
            elseif isfield(event,'memset')&&contains('memset',cudaEventFieldsToTrack)
                gpuTraceCompleteStruct{iterIdx}(j).Name='memset';
                j=j+1;
            elseif isfield(event,'sync')&&contains('sync',cudaEventFieldsToTrack)
                gpuTraceCompleteStruct{iterIdx}(j).Name='cudaDeviceSynchronize';
                j=j+1;
            elseif isfield(event,'kernel')&&contains('kernel',cudaEventFieldsToTrack)
                kernel=event.kernel;
                gpuTraceCompleteStruct{iterIdx}(j).Name=labels.data{str2double(kernel.shortName)+1};
                gpuTraceCompleteStruct{iterIdx}(j).Start=str2double(event.startNs);
                gpuTraceCompleteStruct{iterIdx}(j).Duration=str2double(event.endNs)-str2double(event.startNs);
                gpuTraceCompleteStruct{iterIdx}(j).gridX=kernel.gridX;
                gpuTraceCompleteStruct{iterIdx}(j).gridY=kernel.gridY;
                gpuTraceCompleteStruct{iterIdx}(j).gridZ=kernel.gridZ;
                gpuTraceCompleteStruct{iterIdx}(j).blockX=kernel.blockX;
                gpuTraceCompleteStruct{iterIdx}(j).blockY=kernel.blockY;
                gpuTraceCompleteStruct{iterIdx}(j).blockZ=kernel.blockZ;
                gpuTraceCompleteStruct{iterIdx}(j).localMemoryTotal=kernel.localMemoryTotal;
                gpuTraceCompleteStruct{iterIdx}(j).StaticSMem=kernel.staticSharedMemory;
                j=j+1;
            end


        elseif isfield(gpuTrace{i},'TraceProcessEvent')&&startTracing
            event=gpuTrace{i}.TraceProcessEvent;
            name=labels.data{str2double(event.name)+1};
            apisToCareAbout=["cudnn","cublas","fft","cudaMemcpy","cudaMalloc","cudaFree","cudaLaunchKernel","cudaDeviceSynchronize"];
            if any(contains(name,apisToCareAbout))
                gpuTraceCompleteStruct{iterIdx}(j).Name=name;
                gpuTraceCompleteStruct{iterIdx}(j).Duration=str2double(event.endNs)-str2double(event.startNs);
                gpuTraceCompleteStruct{iterIdx}(j).Start=str2double(event.startNs);
                j=j+1;
            end

        end
    end


    for i=1:numel(gpuTraceCompleteStruct)
        for j=1:numel(gpuTraceCompleteStruct{i})
            pattern='cuda[a-zA-Z0-9]+_v\d+';
            if~isempty(regexp(gpuTraceCompleteStruct{i}(j).Name,pattern,'once'))
                noVersionName=regexp(gpuTraceCompleteStruct{i}(j).Name,'_v\d+','split');
                gpuTraceCompleteStruct{i}(j).Name=noVersionName{1};
            end
        end
    end


    for i=1:numel(gpuTraceCompleteStruct)
        for j=1:numel(gpuTraceCompleteStruct{i})
            gpuTraceCompleteStruct{i}(j).Duration=gpuTraceCompleteStruct{i}(j).Duration/1e6;
            gpuTraceCompleteStruct{i}(j).Start=gpuTraceCompleteStruct{i}(j).Start/1e6;
        end
    end
end


function profileData=generateAverageProfile(gpuCompleteTrace,varargin)

    if isempty(gpuCompleteTrace{1})
        profileData=struct.empty;
    else
        profileData=gpuCompleteTrace{1};
        profileData=rmfield(profileData,{'Start'});
        profileData=imakeNameFirstField(profileData);
        if numel(profileData)>100
            warning(message('gpucoder:common:LargeProfilingTrace',100));
        end
    end
end


function summaryData=computeSummaryData(gpuCompleteTrace,numIterations)
    if isempty([gpuCompleteTrace{:}])
        summaryData=struct.empty;
    else
        summaryMap=containers.Map;
        for i=1:numel(gpuCompleteTrace)
            for j=1:numel(gpuCompleteTrace{i})
                if summaryMap.isKey(gpuCompleteTrace{i}(j).Name)
                    durationAndCounts=summaryMap(gpuCompleteTrace{i}(j).Name);
                    newDuration=durationAndCounts(1)+gpuCompleteTrace{i}(j).Duration;
                    newCounts=durationAndCounts(2)+1;
                    summaryMap(gpuCompleteTrace{i}(j).Name)=[newDuration,newCounts];
                else
                    duration=gpuCompleteTrace{i}(j).Duration;
                    summaryMap(gpuCompleteTrace{i}(j).Name)=[duration,1];
                end
            end
        end

        fcns=summaryMap.keys;
        for i=1:numel(fcns)
            summaryData(i).Name=fcns{i};
            durationAndCounts=summaryMap(fcns{i});
            summaryData(i).TotalAvgTime=durationAndCounts(1)/numIterations;
            summaryData(i).NumCalls=durationAndCounts(2)/numIterations;
        end


        [~,idx]=sort([summaryData.TotalAvgTime],'descend');
        summaryData=summaryData(idx);
    end
end


function struct=imakeNameFirstField(struct)

    fieldNames=fieldnames(struct);
    fieldNames(strcmp(fieldNames,'Name'))=[];
    fieldNames={'Name',fieldNames{:}};%#ok<CCAT>
    struct=orderfields(struct,fieldNames);
end

function sub_gpuStruct=removeFirstIteration(gpuStruct)
    if numel(gpuStruct)>1
        sub_gpuStruct=gpuStruct(2:end);
    else
        sub_gpuStruct=gpuStruct;
    end
end

