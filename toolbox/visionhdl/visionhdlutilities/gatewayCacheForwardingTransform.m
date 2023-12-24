function[outData]=gatewayCacheForwardingTransform(inData)

    outData.NewBlockPath='';
    outData.NewInstanceData=[];

    [ParameterNames{1:length(inData.InstanceData)}]=inData.InstanceData.Name;

    if(~ismember('VideoFormatCache',ParameterNames))
        ParameterNames={'VideoFormatCache','ActivePixelsPerLineCache','ActiveVideoLinesCache','TotalPixelsPerLineCache','TotalVideoLinesCache','StartingActiveLineCache','FrontPorchCache'};
        for ii=1:1:numel(ParameterNames)

            idx=find(strcmpi({inData.InstanceData.Name},ParameterNames{ii}(1:(end-5)))==1,1);
            if~isempty(idx)

                inData.InstanceData(end+1).Name=ParameterNames{ii};

                inData.InstanceData(end).Value=inData.InstanceData(idx).Value;
            end
        end
    end
    outData.NewInstanceData=inData.InstanceData;
end
