function ret=getElementByIndex(this,idx)


    ret=this.Repo.safeTransaction(@locGetElementByIndex,this,idx);
end


function ret=locGetElementByIndex(this,idx)
    ret=[];
    if~isscalar(this)
        Simulink.SimulationData.utError('InvalidDatasetArray');
    end
    validateattributes(idx,{'numeric'},{'scalar','integer','positive'},'getElementByIndex','idx',2);

    sigIDs=getSortedSignalIDs(this);
    if idx<=numel(sigIDs)
        exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
        opts.sigID=sigIDs(idx);
        ds=exportRun(...
        exporter,...
        this.Repo,...
        opts,...
        false,...
        false,...
        '',...
        this.LogIntervals,...
        this.LoggingOverride);
        assert(numElements(ds)==1);
        ret=getElement(ds,1);
    end
end

