


function this=convertToDataset(this,vars,varargin)


    [varargin{:}]=convertStringsToChars(varargin{:});



    if locIsModelDataLogs(vars)
        this=locModelDataLogs2Dataset(vars,varargin);
        return;
    end



    this=convertAndAdd(this,vars,varargin);
end




function ds=convertAndAdd(ds,vars,params)

    ds=locParseOptionalParams(ds,params);


    ds=convertAndAddOneVar(ds,vars{1});
end




function ds=locParseOptionalParams(ds,params)


    if mod(length(params),2)==1
        Simulink.SimulationData.utError(...
        'DatasetConstructorInvalidOptionalParameters',params{1});
    end


    for idx=1:2:length(params)
        if strcmpi(params{idx},'DatasetName')
            if ischar(params{idx+1})
                ds.Name=params{idx+1};
            else

                Simulink.SimulationData.utError(...
                'DatasetConstructorInvalidName');
            end
        else

            Simulink.SimulationData.utError(...
            'DatasetConstructorInvalidOptions');
        end
    end
end




function ds=convertAndAddOneVar(ds,var)


    if isstruct(var)&&isfield(var,'signals')&&...
        isfield(var.signals,'stateName')

        elems=locConvertToStateElement(var);
    else

        elems=locConvertToSignalElement(var);
    end
    for idx=1:length(elems)
        ds=ds.addElement(elems(idx));
    end
end



function areAnyVarsMDL=locIsModelDataLogs(vars)
    areAnyVarsMDL=any(...
    cellfun(@(x)isequal(class(x),'Simulink.ModelDataLogs'),vars)...
    );
end



function ds=locModelDataLogs2Dataset(vars,params)

    switch length(params)
    case 0
        dsName='';
    case 1
        Simulink.SimulationData.utError(...
        'DatasetConstructorInvalidOptionalParameters',params{1});
    case 2
        if isequal(params{1},'DatasetName')
            if ischar(params{2})
                dsName=params{2};
            else

                Simulink.SimulationData.utError(...
                'DatasetConstructorInvalidName');
            end
        else

            Simulink.SimulationData.utError(...
            'DatasetConstructorInvalidModelDataLogsOptions');
        end
    otherwise

        Simulink.SimulationData.utError(...
        'DatasetConstructorInvalidModelDataLogsOptions');
    end

    ds=vars{1}.convertToDataset(dsName);
end


function locCheckForCorrectStructFields(var)
    if isstruct(var)


        if~isfield(var,'time')||...
            ~isnumeric(var.time)||...
            ~isreal(var.time)||...
            ~(isvector(var.time)||isempty(var.time))||...
            ~all(diff(var.time)>=0)||...
            ~isa(var.time,'double')||...
            ~isfield(var,'signals')||...
            ~isfield(var.signals,'values')||...
            isequal(length(var.signals),0)
            Simulink.SimulationData.utError(...
            'DatasetConstructorStructFields');
        end
        for idx=1:length(var.signals)
            if~(isnumeric(var.signals(idx).values)||...
                islogical(var.signals(idx).values))
                Simulink.SimulationData.utError(...
                'DatasetConstructorStructFields');
            end
        end
    end
end




function elems=locConvertToStateElement(var)


    locCheckForCorrectStructFields(var);
    if~isfield(var.signals,'label')||...
        ~isfield(var.signals,'values')||...
        ~isfield(var.signals,'blockName')
        Simulink.SimulationData.utError('DatasetConstructorStateFields');
    end

    numElems=length(var.signals);
    elems(numElems)=Simulink.SimulationData.State;

    for idx=1:numElems
        if isequal(var.time,[])
            stTime=0:(...
            numel(var.signals(idx).values)/...
            prod(var.signals(idx).dimensions)-1);
        else
            stTime=var.time;
        end

        ts=timeseries(...
        var.signals(idx).values,stTime,'Name',...
        var.signals(idx).stateName);

        if isequal(var.signals(idx).label,'DSTATE')
            ts=setinterpmethod(ts,'zoh');
        else
            ts=setinterpmethod(ts,'linear');
        end

        elems(idx).Label=var.signals(idx).label;
        elems(idx).Values=ts;


        if isfield(var.signals(idx),'inReferencedModel')&&...
            isequal(var.signals(idx).inReferencedModel,1)
            bpCell=locGetBlockCellRecursion(...
            {},var.signals(idx).blockName);
            bp=Simulink.SimulationData.BlockPath(bpCell);
        else
            bp=Simulink.SimulationData.BlockPath(var.signals(idx).blockName);
        end

        elems(idx).BlockPath=bp;
        elems(idx).Name=var.signals(idx).stateName;
    end
end




function bpCell=locGetBlockCellRecursion(bpCell,pathWithPipes)



    [blk,submodel,rest,~]=slprivate('decpath',...
    pathWithPipes);



    if~isempty(strfind(rest,'|'))
        bpCell{end+1}=blk;
        bpCell=locGetBlockCellRecursion(bpCell,[submodel,'/',rest]);
    else
        bpCell{end+1}=blk;
        bpCell{end+1}=[submodel,'/',rest];
    end



    if isequal(bpCell{end},'/')
        bpCell(end)=[];
    end
end





function elem=locConvertToSignalElement(var)
    if isnumeric(var)||islogical(var)




        timeVec=[];
        if isequal(size(var,1),1)
            timeVec=0;
        end
        ts=timeseries(var,timeVec);
        elem=Simulink.SimulationData.Signal;
        elem.Values=ts;
    elseif isequal(class(var),'struct')
        if~isequal(length(var),1)

            Simulink.SimulationData.utError('DatasetConstructorNonScalarStruct');
        end
        if locIsStructOfTimeseries(var)
            elem=Simulink.SimulationData.Signal;
            elem.Values=var;
        else
            locCheckForCorrectStructFields(var);
            numElems=length(var.signals);
            elem(numElems)=Simulink.SimulationData.Signal;
            for idx=1:numElems
                ts=locStruct2Timeseries(var,idx);



                if isfield(var.signals,'plotStyle')&&...
                    isequal(var.signals.plotStyle,1)
                    ts=setinterpmethod(ts,'zoh');
                end

                elem(idx).Values=ts;
                if isfield(var,'blockName')
                    bp=Simulink.SimulationData.BlockPath(var.blockName);
                    elem(idx).BlockPath=bp;
                elseif isfield(var.signals(idx),'blockName')
                    bp=Simulink.SimulationData.BlockPath(var.signals(idx).blockName);
                    elem(idx).BlockPath=bp;
                end
                if isfield(var.signals(idx),'label')
                    elem(idx).Name=var.signals(idx).label;
                end
            end
        end
    elseif isequal(class(var),'timeseries')
        if~isequal(length(var),1)

            Simulink.SimulationData.utError('DatasetConstructorNonScalarTimeseries');
        end
        elem=Simulink.SimulationData.Signal;
        elem.Values=var;
        elem.Name=var.Name;
    else


        Simulink.SimulationData.utError('DatasetConstructorInvalidArg');
    end
end




function isTsStruct=locIsStructOfTimeseries(st)
    fn=fieldnames(st);
    if isequal(length(fn),0)
        isTsStruct=false;
        return
    end
    for idx=1:length(fn)
        if~isa(st.(fn{idx}),'struct')
            isTsStruct=(isa(st.(fn{idx}),'timeseries'));
            if~isTsStruct
                return;
            end
        else
            isTsStruct=locIsStructOfTimeseries(st.(fn{idx}));
        end
    end
end



function ts=locStruct2Timeseries(st,idx)
    interpretSingleRowAs3d=false;
    vals=st.signals(idx).values;
    if isfield(st.signals(idx),'dimensions')

        [stTime,interpretSingleRowAs3d,needsReshape]=...
        locGetInferredPropsFromSt(...
        vals,st.signals(idx).dimensions);
        if needsReshape




























            vals=reshape((vals).',...
            st.signals(idx).dimensions(2),...
            st.signals(idx).dimensions(1),...
            length(stTime));














            vals=permute(vals,[2,1,3]);
        end
        if~isequal(st.time,[])
            stTime=st.time;
        end
    else
        stTime=st.time;
    end
    if isfield(st.signals(idx),'label')
        ts=timeseries(vals,stTime,...
        'Name',st.signals(idx).label);
    else
        ts=timeseries(vals,stTime);
    end

    if interpretSingleRowAs3d
        ts.DataInfo.InterpretSingleRowDataAs3D=true;
    end
end




function[stTime,interpretSingleRowAs3D,needsReshape]=...
    locGetInferredPropsFromSt(vals,dims)
    assert(~isempty(dims))

    stTime=0:(numel(vals)/prod(dims)-1);




    needsReshape=~isscalar(dims)&&ismatrix(dims)&&...
    ismatrix(vals)&&length(stTime)>1;

    interpretSingleRowAs3D=~isscalar(dims)&&isrow(vals)&&...
    isscalar(stTime);
end


