function ret=fullExport(this)


    try
        ret=this.Repo.safeTransaction(@locFullExport,this);
    catch me %#ok<NASGU>
        ret=[];
    end
end


function ret=locFullExport(this)
    if~isscalar(this)
        Simulink.SimulationData.utError('InvalidDatasetArray');
    end








    if ischar(this.Domain)
        bStreamedOnly=true;
        opts={this.Domain,[],[],this.SortStatesForLegacyFormats};
    else
        bStreamedOnly=false;
        opts={};
    end
    exporter=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
    ret=exportRun(...
    exporter,...
    this.Repo,...
    this.RunID,...
    false,...
    bStreamedOnly,...
    this.Repo.getRunDisplayName(this.RunID),...
    this.LogIntervals,...
    this.LoggingOverride,...
    opts{:});
end

