function s=applyFilterImplParams(this,hF,hC)











    s.pcache={};
    s.hdlvalmsgs=hdlvalidatestruct;

    fParams=this.filterImplParamNames;
    CMspecified=0;
    DAspecified=0;
    SPSpecified=0;


    if hF.InputComplex
        hF.setHDLParameter('InputComplex','on');
    end

    for n=1:length(fParams)
        if strmatch('coeffmultiplier',lower(fParams{n}))
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)
                hF.setHDLParameter('coeffmultiplier',this.getImplParams(fParams{n}));
                CMspecified=1;
            end
        end
        if strmatch('dalutpartition',lower(fParams{n}))
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)
                hF.setHDLParameter('dalutpartition',this.getImplParams(fParams{n}));


                hF.setHDLParameter('AddOutputRegister','on');
                hF.setHDLParameter('AddInputRegister','on');
                hF.setHDLParameter('FIRAdderStyle','tree');

                applyFullPrecisionSettings(hF);
                DAspecified=1;
            end
        end
        if strmatch('daradix',lower(fParams{n}))
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)
                hF.setHDLParameter('daradix',this.getImplParams(fParams{n}));
            end
        end
        if strmatch('serialpartition',lower(fParams{n}))
            cfilePvalue=this.getImplParams(fParams{n});
            if(~isempty(cfilePvalue)&&~all(cfilePvalue==1))
                hF.setHDLParameter('serialpartition',this.getImplParams(fParams{n}));


                hF.setHDLParameter('AddOutputRegister','off');
                hF.setHDLParameter('AddInputRegister','off');

                hF.updateHdlfilterINI;
                applyFullPrecisionSettings(hF);
                SPSpecified=1;
            end
        end

        if strmatch('reuseaccum',lower(fParams{n}))
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)
                hF.setHDLParameter('reuseaccum',this.getImplParams(fParams{n}));
                if~SPSpecified
                    hF.setHDLParameter('AddOutputRegister','off');
                    hF.setHDLParameter('AddInputRegister','off');

                    applyFullPrecisionSettings(hF);
                end
            end
        end

        if strmatch('addpipelineregisters',lower(fParams{n}))
            cfilePvalue=this.getImplParams(fParams{n});
            if~isempty(cfilePvalue)
                hF.setHDLParameter('addpipelineregisters',this.getImplParams(fParams{n}));

                s.hdlvalmsgs=[s.hdlvalmsgs,applyFullPrecisionSettings(hF)];
            end
        end

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

        if strmatch('channelsharing',lower(fParams{n}))
            cfilePvalue=this.getImplParams(fParams{n});
            if strcmpi(cfilePvalue,'on')
                bfp=hC.SimulinkHandle;
                block=get_param(bfp,'Object');
                numChannel=block.CompiledPortWidths.Inport(1);
                hF.HDLParameters.INI.setProp('filter_generate_multichannel',numChannel);
            end
        end
    end
    hF.updateHdlfilterINI;

    if DAspecified
        inputsize=hdlgetsizesfromtype(hF.InputSltype);
        radix=hF.getHDLParameter('filter_daradix');
        baat=log2(radix);

        if isa(hF,'hdlfilter.dffir')
            foldingfactor=inputsize/baat;
        elseif isa(hF,'hdlfilter.firdecim')
            phases=hF.DecimationFactor;
            if inputsize==baat
                foldingfactor=1;
            else

                ffactor=inputsize/baat;
                if phases==ffactor
                    foldingfactor=1;
                else
                    if phases>ffactor
                        foldingfactor=1;
                    else

                        count_to=phases*ceil(ffactor/phases);
                        foldingfactor=count_to/phases;
                    end
                end
            end
        elseif isa(hF,'hdlfilter.dfsymfir')||isa(hF,'hdlfilter.dfasymfir')
            if inputsize==baat
                foldingfactor=1;
            else
                foldingfactor=inputsize/baat+1;
            end
        elseif isa(hF,'hdlfilter.firinterp')
            dalutpart=hF.getHDLParameter('filter_dalutpartition');
            [~,~,~,foldingfactor]=hF.getDALutPartition('dalutpartition',dalutpart,...
            'daradix',radix);
        else
            foldingfactor=1;
        end
        hF.HDLParameters.INI.setProp('foldingfactor',foldingfactor);

        if CMspecified
            hF.setHDLParameter('coeffmultipliers','multiplier');
        end
    end

    hF.updateHdlfilterINI;

