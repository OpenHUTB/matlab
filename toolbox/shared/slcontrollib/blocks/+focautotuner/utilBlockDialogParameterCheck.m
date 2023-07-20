function isValid=utilBlockDialogParameterCheck(blk)















    params={'Bandwidth';'TargetPM';'AmpSine';'Ts';'StartTime';'Duration'};


    blk=getfullname(blk);
    isExternal_wC=strcmp(get_param(blk,'UseExternalWC'),'on');
    isExternal_PM=strcmp(get_param(blk,'UseExternalPM'),'on');
    isExternal_ampSine=strcmp(get_param(blk,'UseExternalAmpSine'),'on');


    tmpisTuneAllInner=strcmp(get_param(blk,'UseSameSettingsInner'),'on');
    tmpisTuneAllOuter=strcmp(get_param(blk,'UseSameSettingsOuter'),'on');
    tmpisTuneDaxis=strcmp(get_param(blk,'TuneDaxisLoop'),'on');
    tmpisTuneQaxis=strcmp(get_param(blk,'TuneQaxisLoop'),'on');
    tmpisTuneSpeed=strcmp(get_param(blk,'TuneSpeedLoop'),'on');
    tmpisTuneFlux=strcmp(get_param(blk,'TuneFluxLoop'),'on');

    isTuneAllInner=tmpisTuneAllInner&&tmpisTuneDaxis&&tmpisTuneQaxis;
    isTuneAllOuter=tmpisTuneAllOuter&&tmpisTuneSpeed&&tmpisTuneFlux;
    isTuneDaxis=tmpisTuneDaxis&&~isTuneAllInner;
    isTuneQaxis=tmpisTuneQaxis&&~isTuneAllInner;
    isTuneSpeed=tmpisTuneSpeed&&~isTuneAllOuter;
    isTuneFlux=tmpisTuneFlux&&~isTuneAllOuter;


    loopNames={'AllInner';'Daxis';'Qaxis';'AllOuter';'Speed';'Flux'};
    idx=[isTuneAllInner,isTuneDaxis,isTuneQaxis,isTuneAllOuter,isTuneSpeed,isTuneFlux];
    loopNames=loopNames(idx);


    paramsAll=cellfun(@(x)strcat(x,loopNames),params,'UniformOutput',false);
    maskWSVars=get_param(blk,'MaskWSVariables');
    maskNames={maskWSVars.Name};

    isValid=true;


    paramCheck=paramsAll{1};
    maskParamIdx=ismember(maskNames,paramCheck);
    maskParamValues=[maskWSVars(maskParamIdx).Value];
    BWValues={maskWSVars(maskParamIdx).Value};

    if~isExternal_wC&&~isempty(maskParamValues)
        errMsg.identifier='SLControllib:focautotuner:errBlockParamPosScalarFiniteReal';
        errMsg.message=getString(message(errMsg.identifier,blk,getString(message('SLControllib:focautotuner:txtBandwidth'))));

        for ii=1:length(maskParamValues)

            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Positive',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Size',errMsg,1);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Finite',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Real',errMsg);
        end
    end


    paramCheck=paramsAll{2};
    maskParamIdx=ismember(maskNames,paramCheck);
    maskParamValues=[maskWSVars(maskParamIdx).Value];

    if~isExternal_PM&&~isempty(maskParamValues)
        errMsg.identifier='SLControllib:focautotuner:errBlockParamRangeScalarFiniteReal';
        errMsg.message=getString(message(errMsg.identifier,blk,getString(message('SLControllib:focautotuner:txtPhaseMargin')),'0','90'));

        for ii=1:length(maskParamValues)

            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Size',errMsg,1);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Finite',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Real',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Value',errMsg,[0,90]);
        end
    end


    paramCheck=paramsAll{3};
    maskParamIdx=ismember(maskNames,paramCheck);
    maskParamValues=[maskWSVars(maskParamIdx).Value];

    if~isExternal_ampSine&&~isempty(maskParamValues)
        errMsg.identifier='SLControllib:focautotuner:errBlockParamPosVectorFiniteReal';
        errMsg.message=getString(message(errMsg.identifier,blk,getString(message('SLControllib:focautotuner:txtSineAmp')),'4'));

        for ii=1:length(maskParamValues)

            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Positive',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Size',errMsg,[1,5]);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Finite',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Real',errMsg);
        end
    end




    paramCheck=paramsAll{4};
    maskParamIdx=ismember(maskNames,paramCheck);
    maskParamValues=[maskWSVars(maskParamIdx).Value];

    errMsg.identifier='SLControllib:focautotuner:errBlockParamNonNegScalarFiniteReal';
    errMsg.message=getString(message(errMsg.identifier,blk,getString(message('SLControllib:focautotuner:txtControllerSampleTime'))));

    if~isempty(maskParamValues)
        for ii=1:length(maskParamValues)

            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Sample Time',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Size',errMsg,1);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Finite',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Real',errMsg);
        end
    end


    paramCheck='TsExperiment';
    maskParamIdx=ismember(maskNames,paramCheck);
    Ts=maskWSVars(maskParamIdx).Value;

    errMsg.identifier='SLControllib:focautotuner:errBlockParamNonNegScalarFiniteReal';
    errMsg.message=getString(message(errMsg.identifier,blk,getString(message('SLControllib:focautotuner:txtExperimentSampleTime'))));

    if~isempty(Ts)

        isValid=isValid&&focautotuner.utilValidityCheck(Ts,'Sample Time',errMsg);


        isValid=isValid&&focautotuner.utilValidityCheck(Ts,'Size',errMsg,1);


        isValid=isValid&&focautotuner.utilValidityCheck(Ts,'Finite',errMsg);


        isValid=isValid&&focautotuner.utilValidityCheck(Ts,'Real',errMsg);
    end



    if~isempty(BWValues)
        for ii=1:length(BWValues)

            BW=BWValues{ii};
            if~isExternal_wC&&~isempty(BW)&&~isempty(Ts)&&Ts>0
                if BW>=(0.3/Ts)
                    ctrlMsgUtils.error('SLControllib:focautotuner:errBandwidth');
                end
            end
        end
    end


    paramCheck=paramsAll{5};
    maskParamIdx=ismember(maskNames,paramCheck);
    maskParamValues=[maskWSVars(maskParamIdx).Value];

    if~isExternal_ampSine&&~isempty(maskParamValues)
        errMsg.identifier='SLControllib:focautotuner:errBlockParamPosScalarFiniteReal';
        errMsg.message=getString(message(errMsg.identifier,blk,getString(message('SLControllib:focautotuner:txtStartTime'))));

        for ii=1:length(maskParamValues)

            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Positive',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Size',errMsg,1);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Finite',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Real',errMsg);
        end
    end


    paramCheck=paramsAll{6};
    maskParamIdx=ismember(maskNames,paramCheck);
    maskParamValues=[maskWSVars(maskParamIdx).Value];

    if~isExternal_ampSine&&~isempty(maskParamValues)
        errMsg.identifier='SLControllib:focautotuner:errBlockParamPosScalarFiniteReal';
        errMsg.message=getString(message(errMsg.identifier,blk,getString(message('SLControllib:focautotuner:txtDuration'))));

        for ii=1:length(maskParamValues)

            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Positive',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Size',errMsg,1);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Finite',errMsg);


            isValid=isValid&&focautotuner.utilValidityCheck(maskParamValues(ii),'Real',errMsg);
        end
    end

