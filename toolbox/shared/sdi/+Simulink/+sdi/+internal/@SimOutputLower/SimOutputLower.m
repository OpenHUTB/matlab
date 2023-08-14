classdef SimOutputLower



    methods(Static=true)











        function result=lower(soeOutput,sdi2featVal)

            result=[];


            if isScalarTimeseriesOutput(soeOutput)
                result=lowerScalarTimeseries(soeOutput,1,sdi2featVal);


            elseif isVectorTimeseriesOutput(soeOutput)
                result=lowerVectorTimeseries(soeOutput,sdi2featVal);


            else
                result=lowerNDTimeseries(soeOutput,sdi2featVal);
            end
        end

    end

end

function result=isScalarTimeseriesOutput(soeOutput)
    result=soeOutput.SampleDims==1;
end

function result=isVectorTimeseriesOutput(soeOutput)
    result=isscalar(soeOutput.SampleDims);
end

function result=lowerScalarTimeseries(soeOutput,channel,sdi2featVal,varargin)

    if isempty(soeOutput.TimeValues)
        result=[];
        return;
    end


    result.RootSource=soeOutput.RootSource;
    result.TimeSource=soeOutput.TimeSource;
    result.DataSource=soeOutput.DataSource;
    if isempty(soeOutput.rootDataSrc)
        result.rootDataSrc=soeOutput.RootSource;
    else
        result.rootDataSrc=soeOutput.rootDataSrc;
    end
    result.DataValues=soeOutput.DataValues;
    result.TimeValues=soeOutput.TimeValues;
    len=length(result.TimeValues);
    lenData=length(result.DataValues);


    if(len~=lenData)

        if lenData==1&&len>0
            result.TimeValues=result.TimeValues(end);
        else
            result=[];
            return;
        end
    end

    if~isequal(size(result.DataValues),[lenData,1])
        result.DataValues=reshape(result.DataValues,lenData,1);
    end
    if~isequal(size(result.TimeValues),[lenData,1])
        result.TimeValues=reshape(result.TimeValues,lenData,1);
    end
    result.BlockSource=soeOutput.BlockSource;
    result.ModelSource=soeOutput.ModelSource;
    result.SignalLabel=soeOutput.SignalLabel;
    result.TimeDim=soeOutput.TimeDim;
    result.SampleDims=soeOutput.SampleDims;
    result.PortIndex=soeOutput.PortIndex;
    result.metaData=soeOutput.metaData;


    if nargin>3&&~isempty(result.SignalLabel)&&sdi2featVal<=1
        result.SignalLabel=sprintf([result.SignalLabel,'[ %d ]'],channel);
    end
    result.Channel=channel;
    result.SID=soeOutput.SID;
    DataValues.Data=result.DataValues;
    DataValues.Time=result.TimeValues;
    result.DataValues=DataValues;
    if sdi2featVal>1
        enumInfo=enumeration(DataValues.Data);
        if~isempty(enumInfo)
            result.interpolation='zoh';
        else
            result.interpolation=soeOutput.interpolation;
        end
    else
        result.interpolation=soeOutput.interpolation;
    end
    result.Unit=soeOutput.Unit;
    result.HierarchyReference=soeOutput.HierarchyReference;
    result.AlwaysUseSignalLabel=soeOutput.AlwaysUseSignalLabel;
    result.busesPrefixForLabel=soeOutput.busesPrefixForLabel;
    result.SampleTimeString=soeOutput.SampleTimeString;
end

function result=lowerVectorTimeseries(soeOutput,sdi2featVal)


    originalDataSource=soeOutput.DataSource;
    originalDataValues=soeOutput.DataValues;


    vectorExtent=soeOutput.SampleDims;
    result=repmat(struct('RootSource',[],'TimeSource',[],'DataSource',[],'rootDataSrc',[],...
    'DataValues',[],'TimeValues',[],'BlockSource',[],'ModelSource',[],...
    'SignalLabel',[],'TimeDim',[],'SampleDims',[],'PortIndex',[],...
    'metaData',[],'Channel',[],'SID',[],'interpolation',[],'Unit',[],...
    'HierarchyReference',[],'AlwaysUseSignalLabel',false,'busesPrefixForLabel',[],'SampleTimeString',''),...
    vectorExtent,1);
    idxToRemove=[];
    for i=1:vectorExtent

        if soeOutput.TimeDim==1
            channelStr='%s(:,%d)';
            channelVals=originalDataValues(:,i);
        else
            channelStr='%s(%d,:)';
            channelVals=originalDataValues(i,:);
        end


        soeOutput.DataSource=sprintf(channelStr,originalDataSource,i);

        if isempty(soeOutput.rootDataSrc)
            soeOutput.rootDataSrc=soeOutput.RootSource;
        end
        soeOutput.DataValues=channelVals;


        resultTs=lowerScalarTimeseries(soeOutput,i,sdi2featVal,true);
        if~isempty(resultTs)
            result(i)=resultTs;
        else
            idxToRemove(end+1)=i;%#ok<AGROW>
        end
    end


    result(idxToRemove)=[];
end

function result=lowerNDTimeseries(soeOutput,sdi2featVal)
    originalDataValues=soeOutput.DataValues;
    numSigs=prod(soeOutput.SampleDims);
    dimIdx=cell(size(soeOutput.SampleDims));
    s.type='()';
    for idx=1:numSigs
        [dimIdx{:}]=ind2sub(soeOutput.SampleDims,idx);

        if soeOutput.TimeDim==1
            s.subs=[{':'},dimIdx];
        else
            s.subs=[dimIdx,{':'}];
        end
        channelVals=subsref(originalDataValues,s);
        soeOutput.DataValues=squeeze(channelVals);
        if isempty(soeOutput.rootDataSrc)
            soeOutput.rootDataSrc=soeOutput.RootSource;
        else
            soeOutput.rootDataSrc=soeOutput.rootDataSrc;
        end

        result(dimIdx{:})=lowerScalarTimeseries(soeOutput,[dimIdx{:}],sdi2featVal,true);%#ok<AGROW>

        idxStr=sprintf('%d,',cell2mat(dimIdx));
        result(dimIdx{:}).DataSource=sprintf('%s(%s:)',soeOutput.DataSource,idxStr);%#ok<AGROW>
    end

end