function s=applyFilterImplParams(this,hF,hC)











    s.pcache={};
    s.hdlvalmsgs=hdlvalidatestruct;

    fParams=this.filterImplParamNames;
    spff=strcmpi(this.getImplParams('ArchitectureSpecifiedBy'),'foldingfactor');

    if hF.InputComplex
        hF.setHDLParameter('InputComplex','on');
    end

    for n=1:length(fParams)
        if strcmpi('FoldingFactor',fParams{n})
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)&&spff
                hF.setHDLParameter('foldingfactor',this.getImplParams(fParams{n}));
                hF.updateHdlfilterINI;
                applyFullPrecisionSettings(hF);
            end
        end

        if strcmpi('NumMultipliers',fParams{n})
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)&&~spff
                hF.setHDLParameter('nummultipliers',this.getImplParams(fParams{n}));
                hF.updateHdlfilterINI;
                applyFullPrecisionSettings(hF);
            end
        end
    end


    hF.setHDLParameter('AddOutputRegister','on');
    hF.setHDLParameter('AddInputRegister','on');

    hF.updateHdlfilterINI;


