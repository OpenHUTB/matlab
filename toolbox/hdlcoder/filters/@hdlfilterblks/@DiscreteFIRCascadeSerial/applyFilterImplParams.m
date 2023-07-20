function s=applyFilterImplParams(this,hF,hC)











    s.pcache={};
    s.hdlvalmsgs=hdlvalidatestruct;


    if hF.InputComplex
        hF.setHDLParameter('InputComplex','on');
    end

    fParams=this.filterImplParamNames;

    for n=1:length(fParams)
        if strmatch('multiplierinputpipeline',lower(fParams{n}))
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)
                hF.setHDLParameter('multiplierinputpipeline',this.getImplParams(fParams{n}));
            end
        end

        if strmatch('multiplieroutputpipeline',lower(fParams{n}))
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)
                hF.setHDLParameter('multiplieroutputpipeline',this.getImplParams(fParams{n}));
            end
        end

        if strmatch('serialpartition',lower(fParams{n}))
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)
                hF.setHDLParameter('serialpartition',this.getImplParams(fParams{n}));
            end
        end

    end



    hF.setHDLParameter('reuseaccum','on');


    hF.setHDLParameter('AddOutputRegister','off');
    hF.setHDLParameter('AddInputRegister','off');

    applyFullPrecisionSettings(hF);

    hF.updateHdlfilterINI;


