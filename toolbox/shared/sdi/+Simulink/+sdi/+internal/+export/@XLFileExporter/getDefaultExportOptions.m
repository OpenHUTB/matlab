function ret=getDefaultExportOptions(~,opts)



    ret=opts;

    defaultOptions=struct();
    defaultOptions.overwrite='file';
    defaultOptions.shareTimeColumn='on';
    defaultMetaData=struct();
    defaultMetaData.dataType=false;
    defaultMetaData.units=false;
    defaultMetaData.interp=false;
    defaultMetaData.blockPath=false;
    defaultMetaData.portIndex=false;
    defaultOptions.metadata=defaultMetaData;

    if isempty(fieldnames(opts))
        ret=defaultOptions;
    elseif~isfield(opts,'shareTimeColumn')
        ret.shareTimeColumn='on';
    elseif~isfield(opts,'metadata')
        ret.metadata=defaultMetaData;
    else
        if~isfield(opts.metadata,'dataType')
            ret.metadata.dataType=false;
        end
        if~isfield(opts.metadata,'units')
            ret.metadata.units=false;
        end
        if~isfield(opts.metadata,'interp')
            ret.metadata.interp=false;
        end
        if~isfield(opts.metadata,'blockPath')
            ret.metadata.blockPath=false;
        end
        if~isfield(opts.metadata,'portIndex')
            ret.metadata.portIndex=false;
        end
    end
end
