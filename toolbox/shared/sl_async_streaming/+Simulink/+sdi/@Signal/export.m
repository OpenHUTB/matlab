function value=export(this,varargin)





    if isempty(this)
        value=timeseries.empty();
        return
    end
    repo=this(1).Repo_;
    opts.sigID=zeros(size(this),'int32');
    runIDs=zeros(size(this),'int32');
    for idx=1:numel(this)
        opts.sigID(idx)=getIDForData(this(idx));
        runIDs(idx)=this(idx).RunID;
    end

    exportTo='variable';
    inputsToParse={};
    if nargin>2
        if isnumeric(varargin{1})&&isnumeric(varargin{2})
            opts.startTime=varargin{1};
            opts.endTime=varargin{2};
            inputsToParse=varargin(3:end);
        elseif strcmpi(varargin{1},'to')
            inputsToParse=varargin(:);
        end
    end
    if~isempty(inputsToParse)
        inputResults=Simulink.sdi.internal.parseExportOptions(varargin{:});
        exportTo=inputResults.to;
        inputResults.signalOpts=opts;
    end
    if strcmpi(exportTo,'variable')


        if numel(unique(runIDs))>1
            value=locExportMultipleRuns(this,opts,repo,runIDs);
        else
            value=locExportSingleRun(this,opts,repo,false);
        end
    else

        bCmdLine=true;
        fw=Simulink.sdi.internal.AppFramework.getSetFramework();
        try
            fw.exportToFile(inputResults,bCmdLine);
        catch me
            me.throwAsCaller();
        end
    end
end


function value=locExportMultipleRuns(this,opts,repo,runIDs)

    sigsByRun=containers.Map('KeyType','int32','ValueType','any');
    for idx=1:numel(runIDs)
        if sigsByRun.isKey(runIDs(idx))
            sigID=[sigsByRun(runIDs(idx)),opts.sigID(idx)];
        else
            sigID=opts.sigID(idx);
        end
        sigsByRun(runIDs(idx))=sigID;
    end


    uniqueRuns=sigsByRun.keys;
    vals=cell(1,numel(uniqueRuns));
    for idx=1:numel(uniqueRuns)
        opts.sigID=sigsByRun(uniqueRuns{idx});
        vals{idx}=locExportSingleRun(this,opts,repo,true);
    end


    value=vals{1};
    for idx=2:numel(vals)
        value=value.concat(vals{idx});
    end
    value.Name='';
end


function value=locExportSingleRun(this,opts,repo,bAlwaysDS)
    exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
    ds=exportRun(exporter,repo,opts,false);
    if numElements(ds)==1&&~bAlwaysDS
        el=getElement(ds,1);
        if isa(el,'Simulink.SimulationData.Dataset')


            childIDs=repo.getSignalChildren(opts.sigID);
            opts.sigID=childIDs(1);
            ds=exportRun(exporter,repo,opts,false);
            el=getElement(ds,1);
            value=el.Values;
            iData=repo.getSignalDataValues(childIDs(2));
            if length(value.Time)==length(iData.Time)
                value.Data=complex(value.Data,iData.Data);
            end
        else
            value=el.Values;
            if isempty(value)




                value=repmat(timeseries(),size(this));
                for idx=1:numel(this)
                    dv=this(idx).DataValues;
                    value(idx)=timeseries(dv.Data,dv.Time);
                end
            end
        end
    else
        assert(~isscalar(this));
        value=ds;
    end
end
