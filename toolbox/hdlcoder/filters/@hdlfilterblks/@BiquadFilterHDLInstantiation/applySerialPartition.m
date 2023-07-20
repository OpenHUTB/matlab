function applySerialPartition(this,hF)




    fParams=this.filterImplParamNames;
    if strcmpi(this.class,'hdlfilterblks.BiquadFilterFullySerial')
        hF.setHDLParameter('nummultipliers',1);
    elseif strcmpi(this.class,'hdlfilterblks.BiquadFilterPartlySerial')
        spff=strcmpi(this.getImplParams('ArchitectureSpecifiedBy'),'foldingfactor');
        for n=1:length(fParams)
            if strcmpi('FoldingFactor',fParams{n})
                cfilePvalue=this.getImplParams(fParams{n});
                if~isempty(cfilePvalue)&&spff
                    hF.setHDLParameter('foldingfactor',this.getImplParams(fParams{n}));
                end
            end
            if strcmpi('NumMultipliers',fParams{n})
                cfilePvalue=this.getImplParams(fParams{n});
                if~isempty(cfilePvalue)&&~spff
                    hF.setHDLParameter('nummultipliers',this.getImplParams(fParams{n}));
                end
            end
        end
    end
    hF.updateHdlfilterINI;