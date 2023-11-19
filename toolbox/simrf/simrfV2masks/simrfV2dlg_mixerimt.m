function simrfV2dlg_mixerimt(block,swCase)

    top_sys=bdroot(block);
    if strcmpi(get_param(top_sys,'BlockDiagramType'),'library')&&...
        strcmpi(top_sys,'simrfV2elements1')
        return;
    end

    if any(strcmpi(get_param(top_sys,'SimulationStatus'),...
        {'running','paused'}))
        return
    end
    idxMaskNames=simrfV2getblockmaskparamsindex(block);
    Vis=get_param(block,'MaskVisibilities');

    switch(swCase)
    case 'UseDataFile'
        hMask=Simulink.Mask.get(block);
        buttonFileFld=hMask.getDialogControl('ButtonFileIMT');
        imtCommentFld=hMask.getDialogControl('InvalidIMTComment');
        noiseCommentFld=hMask.getDialogControl('NoiseFileComment');
        noiseCommentFld.Visible='off';
        Vis([...
        idxMaskNames.UserSpurValues...
        ,idxMaskNames.TableSpurs...
        ,idxMaskNames.TableFile...
        ,idxMaskNames.PowerRF,idxMaskNames.PowerLO...
        ,idxMaskNames.PowerRF_Data,idxMaskNames.PowerLO_Data...
        ,idxMaskNames.PowerRF_DataNoIMT,idxMaskNames.PowerLO_DataNoAC...
        ])={'off'};

        useDataFile=strcmp(get_param(block,'UseDataFile'),'on');
        cacheData=get_param(block,'UserData');
        if isempty(cacheData)||~cacheData.hasFileIMT||~useDataFile

            goodSpurValues=true;

            try
                slResolve(get_param(block,'UserSpurValues'),block);
            catch
                goodSpurValues=false;
            end
            if goodSpurValues
                imtCommentFld.Visible='off';
                Vis(idxMaskNames.TableSpurs)={'on'};
            else
                imtCommentFld.Visible='on';
            end
        end

        if useDataFile

            Vis(idxMaskNames.FileName)={'on'};
            buttonFileFld.Visible='on';
            if isempty(cacheData)
                imtCommentFld.Visible='on';
                Vis(idxMaskNames.TableSpurs)={'on'};
                Vis([idxMaskNames.PowerRF,idxMaskNames.PowerLO])={'on'};
            elseif cacheData.hasFileIMT
                Vis(idxMaskNames.PowerRF_Data)={'on'};
                if cacheData.hasFileSpars
                    Vis(idxMaskNames.PowerLO_Data)={'on'};
                else
                    Vis(idxMaskNames.PowerLO_DataNoAC)={'on'};
                end
                Vis(idxMaskNames.TableFile)={'on'};
            elseif cacheData.hasFileSpars
                Vis(idxMaskNames.PowerRF_DataNoIMT)={'on'};
                Vis(idxMaskNames.PowerLO_Data)={'on'};
                Vis(idxMaskNames.UserSpurValues)={'on'};
                Vis(idxMaskNames.TableSpurs)={'on'};
            else
                Vis([idxMaskNames.PowerRF_DataNoIMT...
                ,idxMaskNames.PowerLO_DataNoAC])={'on'};
                Vis(idxMaskNames.TableSpurs)={'on'};
            end
            if~isempty(cacheData)&&cacheData.hasFileNoise
                [~,filename,ext]=fileparts(cacheData.filename);
                noiseCommentFld.Prompt=...
                ['Noise specified in Data file: ',filename,ext];
                noiseCommentFld.Visible='on';
            end
        else

            Vis(idxMaskNames.FileName)={'off'};
            buttonFileFld.Visible='off';
            Vis(idxMaskNames.UserSpurValues)={'on'};
            Vis(idxMaskNames.TableSpurs)={'on'};
            Vis([idxMaskNames.PowerRF,idxMaskNames.PowerLO])={'on'};
        end
noiseSetup

    case 'ValidFile'
        filename=get_param(block,'FileName');
        if isempty(which(filename))
            fileInfo=dir(filename);
        else
            fileInfo=dir(which(filename));
        end
        if isempty(fileInfo)
            error(message('simrf:simrfV2errors:CannotOpenFile',filename))
        end

        hMask=Simulink.Mask.get(block);
        imtCommentFld=hMask.getDialogControl('InvalidIMTComment');
        noiseCommentFld=hMask.getDialogControl('NoiseFileComment');
        noiseCommentFld.Visible='off';
        Vis([...
        idxMaskNames.UserSpurValues...
        ,idxMaskNames.TableSpurs...
        ,idxMaskNames.TableFile...
        ,idxMaskNames.PowerRF,idxMaskNames.PowerLO...
        ,idxMaskNames.PowerRF_Data,idxMaskNames.PowerLO_Data...
        ,idxMaskNames.PowerRF_DataNoIMT,idxMaskNames.PowerLO_DataNoAC...
        ])={'off'};

        useDataFile=strcmp(get_param(block,'UseDataFile'),'on');
        if useDataFile

            simrfV2_cachefit_imt(block,filename)
            cacheData=get_param(block,'UserData');
            if isempty(cacheData)
                imtCommentFld.Visible='on';
                Vis(idxMaskNames.TableSpurs)={'on'};
                Vis([idxMaskNames.PowerRF,idxMaskNames.PowerLO])={'on'};
            elseif cacheData.hasFileIMT
                Vis(idxMaskNames.PowerRF_Data)={'on'};
                if cacheData.hasFileSpars
                    Vis(idxMaskNames.PowerLO_Data)={'on'};
                else
                    Vis(idxMaskNames.PowerLO_DataNoAC)={'on'};
                end
                Vis(idxMaskNames.TableFile)={'on'};
            elseif cacheData.hasFileSpars
                Vis(idxMaskNames.PowerRF_DataNoIMT)={'on'};
                Vis(idxMaskNames.PowerLO_Data)={'on'};
                Vis(idxMaskNames.UserSpurValues)={'on'};
                Vis(idxMaskNames.TableSpurs)={'on'};
            else
                Vis([idxMaskNames.PowerRF_DataNoIMT...
                ,idxMaskNames.PowerLO_DataNoAC])={'on'};
                Vis(idxMaskNames.TableSpurs)={'on'};
            end
        else

            Vis(idxMaskNames.FileName)={'off'};
            Vis(idxMaskNames.UserSpurValues)={'on'};
            Vis(idxMaskNames.TableSpurs)={'on'};
            Vis([idxMaskNames.PowerRF,idxMaskNames.PowerLO])={'on'};
        end

        cacheData=get_param(block,'UserData');
        if~isempty(cacheData)&&cacheData.hasFileNoise
            [~,filename,ext]=fileparts(cacheData.filename);
            noiseCommentFld.Prompt=...
            ['Noise specified in Data file: ',filename,ext];
            noiseCommentFld.Visible='on';
        end
noiseSetup

    case 'ButtonFile'
        try
            [filename,pathname]=uigetfile({...
            '*.*2p;*.*2P;*.*2d;*.*2D',...
            'Touchstone files (*.s2p,*.y2p,*.z2p,*.s2d,*.y2d,*.z2d)';...
            '*.*','All Files (*.*)'},'Select a Touchstone data file');
        catch browseException
            errordlg(browseException.message);
            return
        end
        if isequal(filename,0)
            return
        end
        fullFileName=fullfile(pathname,filename);
        set_param(block,'FileName',fullFileName)

    case 'AddNoise'
noiseSetup

    case 'AutoImpulse'
        if strcmp(get_param(block,'AutoImpulseLength'),'off')
            Vis(idxMaskNames.ImpulseLength)={'on'};
        else
            Vis(idxMaskNames.ImpulseLength)={'off'};
        end

    case 'AutoImpulseNoise'
        if strcmp(get_param(block,'AutoImpulseLengthNoise'),'off')
            Vis(idxMaskNames.ImpulseLengthNoise)={'on'};
        else
            Vis(idxMaskNames.ImpulseLengthNoise)={'off'};
        end
    end


    set_param(block,'MaskVisibilities',Vis)



    function noiseSetup
        visNoise_idx=[idxMaskNames.NoiseType,idxMaskNames.NoiseDistribution];
        Vis([...
        idxMaskNames.NF...
        ,idxMaskNames.MinNF...
        ,idxMaskNames.Gopt...
        ,idxMaskNames.RN...
        ,idxMaskNames.NoiseFreqs...
        ,idxMaskNames.AddPhaseNoise...
        ,idxMaskNames.PhaseNoiseOffset...
        ,idxMaskNames.PhaseNoiseLevel...
        ,idxMaskNames.AutoImpulseLengthNoise...
        ,idxMaskNames.ImpulseLengthNoise...
        ,visNoise_idx,visNoise_idx+1])={'off'};

        if strcmp(get_param(block,'AddNoise'),'on')

            Vis(idxMaskNames.AddPhaseNoise)={'on'};
            set_param(block,'MaskVisibilities',Vis)
            if strcmp(get_param(block,'AddPhaseNoise'),'on')
                Vis([...
                idxMaskNames.PhaseNoiseOffset...
                ,idxMaskNames.PhaseNoiseLevel...
                ,idxMaskNames.AutoImpulseLengthNoise])={'on'};
noiseImpulseSetup
            end


            cacheData=get_param(block,'UserData');
            if cacheData.hasFileNoise&&...
                strcmp(get_param(block,'UseDataFile'),'on')&&...
                ~isempty(cacheData)
                Vis([...
                idxMaskNames.AutoImpulseLengthNoise...
                ,visNoise_idx+1])={'on'};
noiseImpulseSetup
                return
            end

            Vis(idxMaskNames.NoiseType)={'on'};
            set_param(block,'MaskVisibilities',Vis)
            switch get_param(block,'NoiseType')
            case 'Noise figure'
                Vis([idxMaskNames.NF,visNoise_idx])={'on'};
noiseDistributionSetup
            case 'Spot noise data'
                Vis([...
                idxMaskNames.MinNF...
                ,idxMaskNames.Gopt...
                ,idxMaskNames.RN...
                ,visNoise_idx])={'on'};
noiseDistributionSetup
            end
        end
    end

    function noiseDistributionSetup
        set_param(block,'MaskVisibilities',Vis)

        switch get_param(block,'NoiseDistribution')
        case 'Piece-wise linear'
            Vis(idxMaskNames.NoiseFreqs)={'on'};
        case 'Colored'
            Vis([...
            idxMaskNames.NoiseFreqs...
            ,idxMaskNames.AutoImpulseLengthNoise])={'on'};
noiseImpulseSetup
        end
    end

    function noiseImpulseSetup
        set_param(block,'MaskVisibilities',Vis)
        if strcmp(get_param(block,'AutoImpulseLengthNoise'),'off')
            Vis(idxMaskNames.ImpulseLengthNoise)={'on'};
        end
    end

end



















