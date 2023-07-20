function data=convertToFormat(data,fmt,varargin)




    if isempty(data)
        return;
    end
    dsNumEls=data.numElements();
    if numel(varargin)>0
        sigIds=varargin{1};




    else
        sigIds=zeros(1,dsNumEls);
    end







    doResampling=dsNumEls>1;
    switch lower(fmt)
    case 'timeseries'
        data=locConvertToTimeseries(data);
    case 'structwithtime'
        data=locConvertToStruct(data,true,sigIds,doResampling);
    case{'struct','struct2d'}
        data=locConvertToStruct(data,false,sigIds,doResampling);
    case{'array','array2d'}
        data=locConvertToArray(data,sigIds,doResampling);
    otherwise
        assert(isempty(fmt)||strcmpi(fmt,'dataset'));
    end
end


function ret=locConvertToTimeseries(ds)


    if ds.numElements()==1
        ret=get(ds,1);
        ret=ret.Values;
    else
        ret=ds;
    end
end


function ret=locConvertToStruct(ds,bIncTime,sigIds,doResampling)

    ret=struct('time',[],'signals',struct.empty());


    [flatList,elements]=locGetFlatTimeseries(ds,[],sigIds);
    tout=locGetCommonTimeVector(flatList);

    bIsStateElement=isa(flatList(1).element,'Simulink.SimulationData.State');


    if bIncTime
        ret.time=tout;
    end


    bSingleElement=(numel(elements)==1)&&~bIsStateElement;
    for idx=1:numel(flatList)
        ret.signals(idx).values=locGetSignalData(flatList(idx).ts,tout,doResampling,...
        bIsStateElement);
        if isfield(flatList(idx),'valueDimensions')
            ret.signals(idx).valueDimensions=flatList(idx).valueDimensions;
        end

        dims=size(flatList(idx).ts.Data);


        frameSize=locGetFrameSize(flatList(idx).sigID);

        if frameSize
            dims(1)=frameSize;
            ret.signals(idx).dimensions=dims;

        elseif locIsWideSignal(flatList(idx).sigID)
            ret.signals(idx).dimensions=dims(2:end);

        elseif length(tout)==1
            ret.signals(idx).dimensions=dims;
        else
            if flatList(idx).ts.isTimeFirst
                ret.signals(idx).dimensions=dims(2:end);
            else
                ret.signals(idx).dimensions=dims(1:end-1);
            end
        end

        ret.signals(idx).label=flatList(idx).ts.Name;

        if bIsStateElement
            switch flatList(idx).element.Label
            case Simulink.SimulationData.StateType.DSTATE
                stateLabel='DSTATE';
            case Simulink.SimulationData.StateType.CSTATE
                stateLabel='CSTATE';
            otherwise
                stateLabel='';
            end

            ret.signals(idx).label=stateLabel;
        end

        if~bSingleElement
            ret.signals(idx).blockName='';
            if~isempty(flatList(idx).element)
                bp=flatList(idx).element.BlockPath.convertToCell();
                ret.signals(idx).blockName=bp{end};
            end
        end

        if bIsStateElement
            ret.signals(idx).stateName=flatList(idx).element.Name;
            ret.signals(idx).inReferencedModel=getLength(flatList(idx).element.BlockPath)>1;
        end
    end


    if bSingleElement
        bp=elements{1}.BlockPath.convertToCell();
        ret.blockName=bp{end};
    end
end


function ret=locConvertToArray(ds,sigIds,doResampling)

    flatList=locGetFlatTimeseries(ds,[],sigIds);
    tout=locGetCommonTimeVector(flatList);


    ret=[];
    for idx=1:numel(flatList)
        data=locGetSignalData(flatList(idx).ts,tout,doResampling,...
        isa(flatList(idx).element,'Simulink.SimulationData.State'));
        if(isempty(ret))
            ret=data;
        else
            ret=cat(ndims(data),ret,data);
        end
    end
end


function[ret,elements]=locGetFlatTimeseries(in,el,sigId)

    ret=struct.empty();
    elements={};

    if isempty(in)
        if isa(in,'timetable')
            ret=locCreateEmptyVarDimsTimeSeries(in,el,sigId);
        end
        return;
    end

    if isa(in,'timeseries')
        data=reshape(in,1,numel(in));

        if(numel(data)>1)
            for idx=1:numel(data)
                ret=[ret,locGetFlatTimeseries(data(idx),el,sigId)];%#ok<AGROW>
            end
        else
            ret=struct;
            ret.sigID=sigId;
            ret.ts=in;
            ret.element=repmat(el,size(ret.ts));
        end
    elseif isa(in,'Simulink.SimulationData.Dataset')

        storage=getStorage(in);
        elements=utGetElements(storage);
        nEl=numel(elements);

        for idx=1:nEl
            ret=[ret,locGetFlatTimeseries(elements{idx},el,sigId(idx))];%#ok<AGROW>
        end
    elseif isobject(in)&&locHasProp(in,'Values')

        ret=locGetFlatTimeseries(in.Values,in,sigId);
    elseif iscell(in)

        nEl=numel(in);
        for idx=1:nEl
            ret=[ret,locGetFlatTimeseries(in{idx},el,sigId(idx))];%#ok<AGROW>
        end
    elseif isstruct(in)

        nEl=numel(in);
        fnames=fieldnames(in);
        for idx=1:nEl
            for idx2=1:numel(fnames)
                ret=[ret,locGetFlatTimeseries(in(idx).(fnames{idx2}),el,sigId(idx))];%#ok<AGROW>
            end
        end
    elseif isa(in,'timetable')&&isduration(in.Time)



        t=seconds(in.Time);
        varDims=[];
        if sigId
            repo=sdi.Repository(1);
            sigObj=Simulink.sdi.Signal(repo,sigId,true);
            varDims=sigObj.getSampleDimensions();
        end
        [d,valueDim]=locGetDataForVarDims(in{:,1},varDims,isscalar(varDims));
        ret=struct();
        ret.sigID=sigId;
        ret.ts=timeseries(d,t);
        ret.ts.Name=in.Properties.Description;
        ret.valueDimensions=valueDim;
        ret.element=el;
        interp=string(in.Properties.VariableContinuity);
        if interp=="continuous"
            ret.ts=ret.ts.setinterpmethod('linear');
        else
            ret.ts=ret.ts.setinterpmethod('zoh');
        end
    end
end


function tout=locGetCommonTimeVector(ts)
    tout=[];
    if numel(ts)==1
        tout=ts.ts.Time;
    else
        for idx=1:numel(ts)
            tout=union(tout,ts(idx).ts.Time);
        end
    end
end


function d=locGetSignalData(ts,tout,doResampling,areStatesLogged)

    if doResampling
        cls=class(ts.Data);
        ts.Data=double(ts.Data);




        if areStatesLogged&&strcmpi(ts.getinterpmethod(),'zoh')
            customStateInterpFun=@(newtime,oldtime,olddata)...
            interp1(oldtime,olddata,newtime,'next');
            ts=setinterpmethod(ts,customStateInterpFun);
        end

        ts=ts.resample(tout);
        ts.Data=eval(sprintf('%s(ts.Data)',cls));
    end
    d=ts.Data;
end





function[ret,vd]=locGetDataForVarDims(in,dims,is1D)

    if isempty(dims)||any(~isfinite(dims))
        dims=locCaculateDimsBasedOnTimetable(in);
    end
    if is1D
        dims=[dims,1];
    end

    numOfDims=length(dims);
    ret=cell(length(in),1);
    vd=[];

    for idx=1:length(in)

        placeholder=locCreateArrayBasedOnType(in{idx,1},dims);


        element=in{idx,1};
        for index=1:numel(element)
            elemDim=cell(1,numOfDims);
            [elemDim{:}]=ind2sub(size(element),index);
            placeholder(elemDim{:})=element(index);
        end
        ret{idx,1}=placeholder;


        valDim=size(element);
        if length(valDim)~=numOfDims
            valDim(length(valDim)+1:numOfDims)=1;
        end
        vd=[vd;valDim];%#ok<AGROW
    end
    if is1D
        ret=(horzcat(ret{:})).';
        vd=vd(:,1);
    else

        if~isempty(ret)&&isfi(ret{1})
            ret=locConcatFiObj(ret,dims,length(in));
        else
            ret=cat(length(dims)+1,ret{:});
        end
    end
end

function dims=locCaculateDimsBasedOnTimetable(in)

    numOfDims=max(cellfun(@(x)ndims(x),in));

    dims=[];
    for idx=1:numOfDims
        dims=[dims,max(cellfun(@(x)size(x,idx),in))];%#ok<AGROW>
    end
end


function ret=locCreateEmptyVarDimsTimeSeries(in,el,sigId)
    ret=struct.empty();
    if sigId
        repo=sdi.Repository(1);

        emptyData=repo.getSignalDataValues(sigId);

        sigObj=Simulink.sdi.Signal(repo,sigId,true);
        varDims=sigObj.getSampleDimensions();
        d=locCreateArrayBasedOnType(emptyData.Data,[varDims(:)',0]);

        info=repo.getSignalComplexityAndLeafPath(sigId);
        if info.IsComplex
            d=complex(d);
        end

        ret=struct();
        ret.sigID=sigId;
        ret.ts=timeseries(d,emptyData.Time);
        ret.ts.Name=in.Properties.Description;
        ret.valueDimensions=zeros([0,length(varDims)]);
        ret.element=el;
        ret.ts=ret.ts.setinterpmethod('zoh');
    end
end

function arr=locCreateArrayBasedOnType(element,dims)
    cl=class(element);
    basicIntTypes={'int8','uint8','int16','uint16','int32','uint32','int64','uint64'};
    basicDoubletype={'single','half','double'};
    if isenum(element)
        arr=nan(dims);
        arr=arrayfun(@(x)Simulink.data.getEnumTypeInfo(cl,'DefaultValue'),arr);
    elseif isfi(element)
        arr=zeros(dims(:)','like',element);
        if arr.Bias&&arr.Bias~=0
            bias=arr.Bias;
            F=fimath('SumMode','SpecifyPrecision','SumSlope',arr.Slope,'SumBias',arr.Bias,'SumWordLength',arr.WordLength);
            arr=setfimath(arr,F);
            arr=arr+bias;
            arr=removefimath(arr);
        end
    elseif islogical(element)
        arr=boolean(zeros(dims));
    elseif any(strcmp(basicIntTypes,cl))
        functionHandle=str2func(cl);
        arr=functionHandle(zeros(dims));
    elseif any(strcmp(basicDoubletype,cl))
        functionHandle=str2func(cl);
        arr=functionHandle(nan(dims));

    else
        arr=nan(dims);
    end
end

function ret=locConcatFiObj(in,dims,numPts)
    ret=zeros([dims(:)',numPts],'like',in{1});
    for idx=1:length(in)

        eval(['ret(',repmat(':,',1,length(dims)),num2str(idx),') = in{',num2str(idx),'}']);
    end
end

function ret=locIsWideSignal(sigId)
    ret=false;
    if isscalar(sigId)&&sigId
        repo=sdi.Repository(1);
        sigObj=Simulink.sdi.Signal(repo,sigId,true);
        ret=isscalar(sigObj.getSampleDimensions());
    end
end


function ret=locGetFrameSize(sigID)
    ret=0;
    if sigID
        repo=sdi.Repository(1);
        ret=repo.getSignalFrameSize(sigID);
    end
end

function ret=locHasProp(obj,pn)


    mc=metaclass(obj);
    ret=~isempty(findobj(mc.PropertyList,'-depth',0,'Name',pn));
end