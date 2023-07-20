function applySerialPartition(this,hF)



    fParams=this.filterImplParamNames;

    for n=1:length(fParams)
        if strcmpi('serialpartition',fParams{n})
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)
                hF.setHDLParameter('serialpartition',this.getImplParams(fParams{n}));
            end
        end
    end
    hF.updateHdlfilterINI;