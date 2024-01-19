function[signalData,lastTimeStamp]=getStreamedRunData(this,blkSigIds,portIndices,saveformat,lastLoggedTime)

    runIDs=Simulink.sdi.getAllRunIDs();
    dsr=Simulink.sdi.DatasetRef(runIDs(end));
    dsrSigIds=dsr.getSortedSignalIDs();
    [~,dsrIndices]=intersect(dsrSigIds,blkSigIds);
    [ds,lastTimeStamp]=createDataset(this,dsrIndices,portIndices,dsr,lastLoggedTime);
    switch lower(saveformat)
    case 'dataset'
        ds=updateDataTypeForDataset(ds);
        signalData=ds;
    case 'array'
        signalData=createArray(ds);
    case{'struct','structwithtime'}
        signalData=createStructure(this,ds,saveformat);
    end

end


function ds=updateDataTypeForDataset(ds)
    numElements=ds.numElements;
    for idx=1:numElements
        if isa(ds.getElement(idx).Values,'timeseries')
            scopedata=ds.getElement(idx).Values.Data;
            if isa(scopedata,'half')
                ds.getElement(idx).Values.Data=double(scopedata);
            elseif isa(scopedata,'int64')||isa(scopedata,'uint64')
                ds.getElement(idx).Values.Data=fi(scopedata);
            end
        elseif isa(ds.getElement(idx).Values,'struct')


            for structidx=1:length(ds.getElement(idx).Values)
                dsfields=fieldnames(ds.getElement(idx).Values(structidx));
                for fieldidx=1:length(dsfields)
                    scopedata=ds.getElement(idx).Values(structidx).(dsfields{fieldidx}).Data;
                    if isa(scopedata,'half')
                        ds.getElement(idx).Values(structidx).(dsfields{fieldidx}).Data=double(scopedata);
                    elseif isa(scopedata,'int64')||isa(scopedata,'uint64')
                        ds.getElement(idx).Values(structidx).(dsfields{fieldidx}).Data=fi(scopedata);
                    end
                end
            end
        end
    end
end


function[ds,lastTimeStamp]=createDataset(this,dsrIndices,portIndices,dsr,lastLoggedTime)

    ds=Simulink.SimulationData.Dataset;
    lastTimeStamp=0;
    for idx=1:numel(dsrIndices)
        dsrIndex=dsrIndices(idx);
        sdisig=dsr.getSignal(dsrIndex);


        doWhile=true;
        while(doWhile&&sdisig.NumPoints>0)
            valueIsTimeSeries=isa(sdisig.Values,'timeseries');
            if valueIsTimeSeries
                doWhile=isempty(sdisig.Values.Time);
            elseif~isempty(sdisig.Children)&&isstruct(sdisig.Children(1).Values)
                doWhile=simDataIsEmpty(sdisig.Children(1).Values);
            else
                doWhile=false;
            end
        end
        slsig=Simulink.SimulationData.Signal;
        slsig.Name=sdisig.Name;

        if~isequal(lastLoggedTime,0)
            origValues=sdisig.Values;
            newValues=reduceData(origValues,lastLoggedTime);
            slsig.Values=newValues;
        else
            slsig.Values=sdisig.Values;
        end
        slsig.BlockPath=this.FullPath;
        slsig.PortIndex=portIndices(idx)+1;
        lastTimeStamp=getLastTimeStamp(slsig.Values);
        ds=ds.addElement(slsig);
    end
end


function lastTS=getLastTimeStamp(sigValues)
    if isa(sigValues,'timeseries')&&~isempty(sigValues.Time)
        lastTS=sigValues.Time(end);
    elseif isstruct(sigValues)
        flds=fields(sigValues);

        childSigValue=sigValues.(flds{1});
        lastTS=getLastTimeStamp(childSigValue);
    else
        lastTS=0;
    end
end


function emptyData=simDataIsEmpty(sdiSigValues)
    if isfield(sdiSigValues,'Time')
        emptyData=isempty(sdiSigValues.Time);
    else
        fieldNames=fields(sdiSigValues);
        firstVal=sdiSigValues.(fieldNames{1});
        emptyData=isa(firstVal,'timeseries')&&isempty(firstVal.Time);
    end
end


function newData=reduceData(origData,lastLoggedTime)
    if isa(origData,'timeseries')
        newData=reduceDataInTimeSeries(origData,lastLoggedTime);
    elseif isstruct(origData)
        newData=origData;
        flds=fieldnames(origData);
        for idx=1:length(flds)
            origVal=origData.(flds{idx});
            newVal=reduceData(origVal,lastLoggedTime);
            newData.(flds{idx})=newVal;
        end
    else
        newData=origData;
    end
end


function newData=reduceDataInTimeSeries(origData,lastLoggedTime)
    tsevent=tsdata.event('',lastLoggedTime);
    newData=origData.gettsafterevent(tsevent);
end


function retarray=createArray(ds)
    retarray=Simulink.sdi.internal.convertToFormat(ds,'array');
    if~isa(retarray,'double')
        retarray=double(retarray);
    end
    time=ds{1}.Values.Time;
    retarray=[time,retarray];
end


function retstruct=createStructure(block,ds,structFormat)
    retstruct=Simulink.sdi.internal.convertToFormat(ds,structFormat);
    multipleDisplayCache=jsondecode(get_param(block.FullPath,'MultipleDisplayCache'));
    if~isfield(retstruct,'blockName')&&numel(retstruct.signals)>0

        if isfield(retstruct.signals(1),'blockName')
            retstruct.blockName=retstruct.signals(1).blockName;
        end
        if numel(retstruct.signals)>1
            retstruct.signals=arrayfun(@(x)rmfield(x,'blockName'),retstruct.signals);
        end
    end
    for idx=1:numElements(ds)

        if isempty(multipleDisplayCache)
            retstruct.signals(idx).label=ds.getElement(idx).Values.Name;
            retstruct.signals(idx).title='';
            if~isempty(retstruct.signals(idx).label)
                retstruct.signals(idx).title=retstruct.signals(idx).label;
            end
        else
            retstruct.signals(idx).label=Simulink.scopes.WebTimeScopeBlockUtils.getInputSignalName(block.FullPath,idx);
            if strcmp(multipleDisplayCache(1).Title,'%<SignalLabel>')
                title=retstruct.signals(idx).label;
            else
                title=multipleDisplayCache(1).Title;
            end
            retstruct.signals(idx).title=title;
        end

        if isequal(prod(retstruct.signals(idx).dimensions),1)
            retstruct.signals(idx).dimensions=1;
        end
        plotStyleDims=retstruct.signals(idx).dimensions;
        if isscalar(plotStyleDims)
            plotStyleDims=[1,plotStyleDims];%#ok
        end
        retstruct.signals(idx).('plotStyle')=zeros(plotStyleDims);
        if~strcmpi(ds.getElement(idx).Values.DataInfo.Interpolation.Name,'linear')
            retstruct.signals(idx).plotStyle=ones(plotStyleDims);
        end

        if isfi(retstruct.signals(idx).values)||any(strcmp(class(retstruct.signals(idx).values),{'int64','uint64','half'}))
            retstruct.signals(idx).values=double(retstruct.signals(idx).values);
        end
    end
end
