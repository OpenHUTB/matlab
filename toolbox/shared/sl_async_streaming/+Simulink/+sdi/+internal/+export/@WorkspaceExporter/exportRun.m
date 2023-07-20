function[set,updatedDLO]=exportRun(this,~,id,bFlatten,varargin)
















    repo=sdi.Repository(1);

    if nargin>4
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    createPendingExporters(this);



    updatedDLO=[];








    sigIDs=int32.empty();
    chunkNums=int32.empty();
    timeRange=double.empty();
    bFlatSignals=false;
    if isstruct(id)
        if isfield(id,'sigIDs')
            sigIDs=int32(id.sigIDs);
            bFlatSignals=true;
        else
            sigIDs=int32(id.sigID);
        end
        if isfield(id,'chunk')
            chunkNums=int32(id.chunk);
        end
        if isfield(id,'startTime')&&isfield(id,'endTime')
            timeRange=double([id.startTime,id.endTime]);
        end
        if isfield(id,'runID')
            runID=id.runID;
        else

            runID=repo.getSignalRunID(sigIDs(1));
        end
    else
        runID=id;
    end


    if nargin>4
        bStreamedOnly=varargin{1};
    else
        bStreamedOnly=false;
    end
    if length(varargin)>2
        loggingIntervals=varargin{3};
        if isnan(loggingIntervals)
            loggingIntervals='[]';
        end
    else
        loggingIntervals=[];
    end
    if length(varargin)>4
        domain=varargin{5};
    else
        domain='';
    end


    if isempty(domain)&&~bStreamedOnly
        Simulink.sdi.internal.import.WorkspaceParser.performLazyImport();
    end


    Simulink.SimulationData.utValidSignalOrCompositeData([],true);
    tmp=onCleanup(@()Simulink.SimulationData.utValidSignalOrCompositeData([],false));


    if length(varargin)>7&&~isempty(varargin{8})
        bSortStatesForLegacyFormats=varargin{8};
    else
        bSortStatesForLegacyFormats=false;
    end


    out=Simulink.sdi.exportRunData(repo,...
    runID,...
    ~bFlatten,...
    bStreamedOnly,...
    domain,...
    sigIDs,...
    chunkNums,...
    timeRange,...
    bSortStatesForLegacyFormats);
    if out.ContainsVarDims
        out.Streamed=loc_applyVarDimsFormatting(out.Streamed);
        out.Logged=loc_applyVarDimsFormatting(out.Logged);
    end
    if~bFlatten&&out.ContainsForEach
        out.Streamed=loc_applyForEachFormatting(out.Streamed);
        out.Logged=loc_applyForEachFormatting(out.Logged);
    end


    if length(varargin)>3
        [out.Streamed,dlo,bUpdate]=loc_applyDataLoggingOverride(out.Streamed,varargin{4});
        if bUpdate
            updatedDLO=dlo;
        end
    end


    set=Simulink.SimulationData.Dataset();


    if~isempty(out.Logged)&&~bFlatten

        els=[loc_createElements(this,out.Streamed,bFlatSignals,loggingIntervals);...
        num2cell(loc_createSets(this,out.Logged,bFlatSignals,loggingIntervals))];
        set=utSetElements(set,els);
    else

        els=[loc_createElements(this,out.Streamed,bFlatSignals,loggingIntervals);...
        loc_createElements(this,out.Logged,bFlatSignals,loggingIntervals)];
        if~isempty(els)
            set=utSetElements(set,els);
        end
    end


    if length(varargin)>1
        set.Name=varargin{2};
    elseif runID~=0
        set.Name=repo.getRunDisplayName(runID);
    end


    if length(varargin)>6&&~isempty(varargin{7})
        set=loc_augmentLoggedData(set,varargin{7});
    end


    if length(varargin)>5&&~isempty(varargin{6})
        set=loc_addInactiveVariants(set,varargin{6});
    end


    if~getLength(set)
        set=[];
    end
end


function sigElems=loc_createElements(this,dataStruct,bFlatSignals,loggingIntervals)

    sig=Simulink.SimulationData.Signal;
    sig.PortType='outport';
    sigElems=repmat(sig,numel(dataStruct),1);
    sigElems=num2cell(sigElems);



    repo=sdi.Repository(1);
    fw=Simulink.sdi.internal.Framework.getFramework();


    for idx=1:length(sigElems)
        exporter=getDomainExporter(this,dataStruct(idx).DomainType);
        if~isempty(loggingIntervals)
            isRapidAccel=false;
            if ischar(loggingIntervals)


                intervals=evalin('base',loggingIntervals).';
                intervals=reshape(intervals,1,[]);
                isRapidAccel=true;
            else
                intervals=loggingIntervals;
            end
            dataStruct(idx).Values=...
            loc_applyLoggingIntervals(dataStruct(idx).Values,intervals,isRapidAccel);
        end
        dataStruct(idx).repo=repo;



        if bFlatSignals
            signalName=Simulink.sdi.getSignal(dataStruct(idx).ID).Name;
            dataStruct(idx).SignalName=signalName;
            dataStruct(idx).LoggedName=signalName;
        end

        if strcmpi(dataStruct(idx).LoggedName,'<placeholder>')&&...
            ~isempty(dataStruct(idx).SignalName)
            dataStruct(idx).LoggedName=dataStruct(idx).SignalName;
        end
        sigElems{idx}=exportElement(exporter,sigElems{idx},dataStruct(idx));
    end
end


function[dataStruct,dlo,bUpdateDLO]=loc_applyDataLoggingOverride(dataStruct,dlo)

    bUpdateDLO=false;
    if isempty(dlo)||strcmp(dlo.LoggingMode,'LogAllAsSpecifiedInModel')
        return
    end
    bLogTopAsSpecified=getLogAsSpecifiedInModel(dlo,dlo.Model);


    idxToRemove=[];
    for idx=1:numel(dataStruct)
        bIsRefSignal=length(dataStruct(idx).BlockPath)>1;
        if bIsRefSignal
            bLogAsSpecified=getLogAsSpecifiedInModel(dlo,dataStruct(idx).BlockPath{1},false);
        else
            bLogAsSpecified=bLogTopAsSpecified;
        end

        if~bLogAsSpecified
            [~,sigInfo,~,bNameChange,dlo]=getSettingsForSignal(...
            dlo,...
            dataStruct(idx).BlockPath,...
            dataStruct(idx).PortIndex,...
            dataStruct(idx).SubPath,...
            false,...
            dataStruct(idx).SignalName);
            if bNameChange
                bUpdateDLO=true;
            end
            if isempty(sigInfo)||~sigInfo.LoggingInfo.DataLogging
                idxToRemove(end+1)=idx;%#ok<AGROW>
            else
                if sigInfo.LoggingInfo.DecimateData
                    dataStruct(idx).Decimation=sigInfo.LoggingInfo.Decimation;
                else
                    dataStruct(idx).Decimation=1;
                end
                if sigInfo.LoggingInfo.LimitDataPoints
                    dataStruct(idx).MaxPoints=sigInfo.LoggingInfo.MaxPoints;
                else
                    dataStruct(idx).MaxPoints=0;
                end
                if sigInfo.LoggingInfo.NameMode
                    dataStruct(idx).LoggedName=sigInfo.LoggingInfo.LoggingName;
                end
            end
        end
    end


    dataStruct(idxToRemove)=[];
end


function dataVal=loc_applyLoggingIntervals(dataVal,intervals,isRapidAccel)
    if~isa(dataVal,'timetable')
        for idx=1:numel(dataVal)
            if isa(dataVal(idx),'timeseries')
                ts=dataVal(idx);
                valIdx=false(size(ts.Time));
                numIntervals=length(intervals)/2;
                for iIdx=1:numIntervals
                    idx1=iIdx*2-1;
                    idx2=iIdx*2;
                    if(isinf(intervals(idx1))||rem(intervals(idx1),1)==0||isRapidAccel)
                        lowTs=ts.Time>=intervals(idx1);
                    else
                        lowTs=ts.Time>=(intervals(idx1)+eps(intervals(idx1)));
                    end
                    if(isinf(intervals(idx2))||rem(intervals(idx2),1)==0)
                        highTs=ts.Time<=intervals(idx2);
                    else
                        highTs=ts.Time<=(intervals(idx2)+eps(intervals(idx2)));
                    end
                    valIdx=valIdx|(lowTs&highTs);
                end
                dataVal(idx)=delsample(ts,'Value',ts.Time(~valIdx));
            elseif isstruct(dataVal(idx))
                fnames=fieldnames(dataVal(idx));
                for fIdx=1:length(fnames)
                    curField=fnames{fIdx};
                    dataVal(idx).(curField)=loc_applyLoggingIntervals(...
                    dataVal(idx).(curField),intervals,isRapidAccel);
                end
            end
        end
    end
end


function subSets=loc_createSets(this,dataStruct,bFlatSignals,loggingIntervals)

    subSets=repmat(Simulink.SimulationData.Dataset,numel(dataStruct),1);
    for i=1:length(subSets)
        subSets(i).Name=dataStruct(i).Variable;
        els=[loc_createElements(this,dataStruct(i).Signals,bFlatSignals,loggingIntervals);...
        num2cell(loc_createSets(this,dataStruct(i).Subsets,bFlatSignals,loggingIntervals))];
        subSets(i)=utSetElements(subSets(i),els);
    end
end


function set=loc_augmentLoggedData(set,loggedDS)



    numEls=getLength(loggedDS);
    insertPos=1;
    for idx=1:numEls
        el=get(loggedDS,idx);
        [insertPos,bReplace]=loc_findInsertPos(set,el,insertPos);
        if bReplace
            set=setElement(set,insertPos,el);
        else
            set=addElement(set,insertPos,el);
        end
    end
end


function[pos,bReplace]=loc_findInsertPos(set,el,startIdx)


    bReplace=false;
    numEls=getLength(set);
    for idx=startIdx:numEls
        curEl=getElement(set,idx);
        if loc_elementIsSameSignal(curEl,el)
            pos=idx;
            bReplace=true;
            return
        elseif loc_elementIsLessThan(el,curEl)
            pos=idx;
            return
        end
    end
    pos=numEls+1;
end


function ret=loc_elementIsSameSignal(streamedEl,loggedEl)





    tmpA=streamedEl;
    tmpB=loggedEl;
    tmpA.Values=[];
    tmpB.Values=[];
    ret=isequal(tmpA,tmpB);
end


function ret=loc_elementIsLessThan(el1,el2)



    ret=false;
    path1=el1.BlockPath.convertToCell();
    path2=el2.BlockPath.convertToCell();


    if length(path1)<length(path2)
        ret=true;
        return
    elseif length(path1)>length(path2)
        ret=false;
        return
    end


    hasSubPath1=~isempty(el1.BlockPath.SubPath);
    hasSubPath2=~isempty(el2.BlockPath.SubPath);
    if hasSubPath1~=hasSubPath2
        ret=~hasSubPath1;
        return
    end


    numPaths=length(path1);
    for idx=1:numPaths
        str1=string(path1{idx});
        str2=string(path2{idx});
        if str1<str2
            ret=true;
            return
        elseif str1>str2
            ret=false;
            return
        end
    end
end


function out=loc_applyForEachFormatting(out)
    bIsSignal=isfield(out,'ForEachDims');

    for idx=1:numel(out)

        if~bIsSignal
            out(idx).Signals=loc_applyForEachFormatting(out(idx).Signals);
            out(idx).Subsets=loc_applyForEachFormatting(out(idx).Subsets);
        elseif~isempty(out(idx).ForEachDims)

            if numel(out(idx).ForEachDims)<2
                tsArray=repmat(timeseries,out(idx).ForEachDims,1);
            else
                tsArray=repmat(timeseries,out(idx).ForEachDims);
            end


            fnames=fieldnames(out(idx).Values);
            sz=size(tsArray);
            for fIdx=1:length(fnames)
                pos=loc_getForEachIndexFromName(fnames{fIdx},sz);
                tsArray(pos)=out(idx).Values.(fnames{fIdx});
                tsArray(pos).Name=out(idx).SignalName;
            end


            out(idx).Values=tsArray;
        end
    end
end


function out=loc_applyVarDimsFormatting(out)



    for idx=1:numel(out)
        if isfield(out,'Values')
            out(idx).Values=loc_applyVarDimsElementFormatting(out(idx).Values,out(idx).SignalName);
        elseif isfield(out,'Signals')
            out(idx).Signals=loc_applyVarDimsFormatting(out(idx).Signals);
        end
    end
end


function out=loc_applyVarDimsElementFormatting(out,sigName)



    tsOut={};
    for idx=1:numel(out)
        if isstruct(out(idx))
            fnames=fieldnames(out(idx));
            for idx2=1:numel(fnames)
                fn=fnames{idx2};
                out(idx).(fn)=loc_applyVarDimsElementFormatting(out(idx).(fn),fn);
            end
        elseif isa(out(idx),'timeseries')
            if iscell(out(idx).Data)

                d=out(idx).Data;
                if~iscolumn(d)
                    d=d';
                end
                tt=timetable(...
                seconds(out(idx).Time),...
                d,...
                'VariableNames',{'Data'});


                tt.Properties.Description=sigName;


                if strcmpi(out(idx).DataInfo.Interpolation.Name,'zoh')
                    tt.Properties.VariableContinuity="step";
                else
                    tt.Properties.VariableContinuity="continuous";
                end


                unitsStr=out(idx).DataInfo.Units;
                if isa(unitsStr,'Simulink.SimulationData.Unit')
                    unitsStr=unitsStr.Name;
                end
                tt.Properties.VariableUnits={unitsStr};


                tsOut{idx}=tt;%#ok<AGROW>
            end
        end
    end


    numTT=numel(tsOut);
    if numTT==1
        out=tsOut{1};
    elseif numTT
        out=tsOut;
    end
end


function ret=loc_getForEachIndexFromName(fname,sz)
    tokens=textscan(fname(3:end),'%d','Delimiter','_');
    subScript=num2cell(tokens{1});
    ret=sub2ind(sz,subScript{:});
end


function set=loc_addInactiveVariants(set,vars)
    numVars=numel(vars);
    for idx=1:numVars
        sig=Simulink.SimulationData.Signal;
        sig.Name=vars(idx).SigName;
        sig.PropagatedName=vars(idx).PropName;
        sig.BlockPath=vars(idx).BlockPath;
        sig.Values=timeseries.empty();
        set=addElement(set,vars(idx).Index,sig);
    end
end
