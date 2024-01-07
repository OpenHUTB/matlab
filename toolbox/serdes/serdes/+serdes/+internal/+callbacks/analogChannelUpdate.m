function analogChannelUpdate(block,calledFrom)
    mws=get_param(bdroot(block),'ModelWorkspace');
    requiredMWSElements=["SampleInterval","ChannelImpulse","RowSize","Aggressors","ImpulseMatrix","SerdesIBIS"];
    switch(calledFrom)
    case "Open"
        simStatus=get_param(bdroot(block),'SimulationStatus');

        if strcmp(simStatus,'stopped')&&~isempty(mws)&&...
            all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
            maskObj=Simulink.Mask.get(block);
            maskNames={maskObj.Parameters.Name};
            serdesIBISObj=mws.getVariable('SerdesIBIS');
            engTxC=serdes.internal.callbacks.numberToEngString(serdesIBISObj.CapacitanceTx);
            engRxC=serdes.internal.callbacks.numberToEngString(serdesIBISObj.CapacitanceRx);
            engRiseTime=serdes.internal.callbacks.numberToEngString(serdesIBISObj.RiseTime);
            maskObj.Parameters(strcmp(maskNames,'TxR')).Value=num2str(serdesIBISObj.ResistanceTx);
            maskObj.Parameters(strcmp(maskNames,'TxC')).Value=engTxC;
            maskObj.Parameters(strcmp(maskNames,'RxR')).Value=num2str(serdesIBISObj.ResistanceRx);
            maskObj.Parameters(strcmp(maskNames,'RxC')).Value=engRxC;
            maskObj.Parameters(strcmp(maskNames,'RiseTime')).Value=engRiseTime;
            maskObj.Parameters(strcmp(maskNames,'VoltageSwingIdeal')).Value=num2str(serdesIBISObj.Voltage);
        end
        open_system(block,'mask');
    case "Initialization"
        if~isempty(mws)&&all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
            [maskNamesValues,maskObj]=serdes.internal.callbacks.getUtilitiesMaskValues(bdroot(block),'',block);
            serdesIBISObj=mws.getVariable('SerdesIBIS');
            channelType=maskNamesValues.ChannelType;
            wsSampleInterval=mws.getVariable('SampleInterval');
            wsSymbolTime=mws.getVariable('SymbolTime');
            wsModulation=mws.getVariable('Modulation');

            if strcmp(channelType,'Loss model')

                if serdesIBISObj.Differential
                    convertedZc=maskNamesValues.Zc;
                else
                    convertedZc=2*maskNamesValues.Zc;
                end

                fb=1/wsSymbolTime.Value/wsModulation.Value;

                if strcmp('off',maskNamesValues.IncludeCrosstalkCheckBox)
                    channel=serdes.ChannelLoss(...
                    'dt',wsSampleInterval.Value,...
                    'TargetFrequency',maskNamesValues.TargetFrequency,...
                    'Loss',maskNamesValues.Loss,...
                    'Zc',convertedZc,...
                    'TxR',maskNamesValues.TxR,...
                    'TxC',maskNamesValues.TxC,...
                    'RxR',maskNamesValues.RxR,...
                    'RxC',maskNamesValues.RxC,...
                    'RiseTime',maskNamesValues.RiseTime,...
                    'VoltageSwingIdeal',maskNamesValues.VoltageSwingIdeal);
                    variantControlLabel='0 Aggressor';
                elseif strcmp('Custom',maskNamesValues.CrosstalkSpecification)
                    channel=serdes.ChannelLoss(...
                    'dt',wsSampleInterval.Value,...
                    'TargetFrequency',maskNamesValues.TargetFrequency,...
                    'Loss',maskNamesValues.Loss,...
                    'Zc',convertedZc,...
                    'TxR',maskNamesValues.TxR,...
                    'TxC',maskNamesValues.TxC,...
                    'RxR',maskNamesValues.RxR,...
                    'RxC',maskNamesValues.RxC,...
                    'RiseTime',maskNamesValues.RiseTime,...
                    'VoltageSwingIdeal',maskNamesValues.VoltageSwingIdeal,...
                    'EnableCrosstalk',strcmp('on',maskNamesValues.IncludeCrosstalkCheckBox),...
                    'CrosstalkSpecification',maskNamesValues.CrosstalkSpecification,...
                    'fb',fb,...
                    'FEXTICN',maskNamesValues.FEXTICN,...
                    'NEXTICN',maskNamesValues.NEXTICN);
                    variantControlLabel='2 Aggressor';
                else
                    channel=serdes.ChannelLoss(...
                    'dt',wsSampleInterval.Value,...
                    'TargetFrequency',maskNamesValues.TargetFrequency,...
                    'Loss',maskNamesValues.Loss,...
                    'Zc',convertedZc,...
                    'TxR',maskNamesValues.TxR,...
                    'TxC',maskNamesValues.TxC,...
                    'RxR',maskNamesValues.RxR,...
                    'RxC',maskNamesValues.RxC,...
                    'RiseTime',maskNamesValues.RiseTime,...
                    'VoltageSwingIdeal',maskNamesValues.VoltageSwingIdeal,...
                    'EnableCrosstalk',strcmp('on',maskNamesValues.IncludeCrosstalkCheckBox),...
                    'fb',fb,...
                    'CrosstalkSpecification',maskNamesValues.CrosstalkSpecification);

                    variantControlLabel='2 Aggressor';
                end
                if~strcmp(get_param(block,'LabelModeActiveChoice'),variantControlLabel)
                    warning('off','Simulink:Commands:SetParamLinkChangeWarn')
                    aOldLinkData=get_param(block,'LinkData');
                    set_param(block,'LabelModeActiveChoice',variantControlLabel);
                    set_param(block,'LinkData',aOldLinkData);
                    warning('on','Simulink:Commands:SetParamLinkChangeWarn')
                end

                impulseRawInput=channel.impulse;
                impulseSampleIntervalRawInput=wsSampleInterval.Value;

                if maskNamesValues.ConvertedZc~=convertedZc
                    maskObj.Parameters(strcmp(fields(maskNamesValues),'ConvertedZc')).Value=num2str(convertedZc);
                end

            else
                maskImpulse=maskNamesValues.ImpulseResponse;
                [maskImpulseRows,maskImpulseColumns]=size(maskImpulse);
                includeXtalk=strcmp('on',maskNamesValues.IncludeCrosstalkCheckBox);

                if maskImpulseRows==1
                    impulseRawInput=maskImpulse';
                    tmp=maskImpulseRows;

                    maskImpulseColumns=tmp;
                elseif maskImpulseRows<maskImpulseColumns

                    error(message('serdes:callbacks:ImpulseMatrixMustBeTall'));
                elseif maskImpulseColumns>7

                    error(message('serdes:callbacks:ImpulseMax7Columns'));
                else
                    if includeXtalk
                        impulseRawInput=maskImpulse;
                    else
                        impulseRawInput=maskImpulse(:,1);
                    end
                end

                if includeXtalk
                    variantControlLabel=sprintf('%i Aggressor',maskImpulseColumns-1);
                else
                    variantControlLabel=sprintf('%i Aggressor',0);
                end
                if~strcmp(get_param(block,'LabelModeActiveChoice'),variantControlLabel)
                    warning('off','Simulink:Commands:SetParamLinkChangeWarn')
                    aOldLinkData=get_param(block,'LinkData');
                    set_param(block,'LabelModeActiveChoice',variantControlLabel);
                    set_param(block,'LinkData',aOldLinkData);
                    warning('on','Simulink:Commands:SetParamLinkChangeWarn')
                end
                impulseSampleIntervalRawInput=maskNamesValues.ImpulseSampleInterval;

            end

            if abs(impulseSampleIntervalRawInput-wsSampleInterval.Value)<eps
                impulseRawInputResampled=impulseRawInput;
            else

                impulseRawInputResampled=serdes.utilities.resampleImpulse(...
                impulseRawInput,...
                impulseSampleIntervalRawInput,...
                wsSampleInterval.Value,0);
            end

            requiredImpulseLength=8388608;
            [rawImpulseRows,rawImpulseColumns]=size(impulseRawInputResampled);
            if rawImpulseRows*rawImpulseColumns>requiredImpulseLength
                error(message('serdes:callbacks:ImpulseResponsesExceedsMaxSize'));
            end
            rawAggressorCount=rawImpulseColumns-1;
            impulseStacked=zeros(requiredImpulseLength,1);
            impulseStacked(1:rawImpulseRows*rawImpulseColumns,:)=impulseRawInputResampled(:);
            tempChannelImpulse=mws.getVariable('ChannelImpulse');
            if~isequal(tempChannelImpulse.Value,impulseStacked)
                tempChannelImpulse.Value=impulseStacked;
                tempRowSize=mws.getVariable('RowSize');
                tempAggressors=mws.getVariable('Aggressors');
                tempRowSize.Value=rawImpulseRows;
                tempAggressors.Value=rawAggressorCount;

                tempImpulseMatrix=mws.getVariable('ImpulseMatrix');
                tempImpulseMatrix.Dimensions=[requiredImpulseLength,1];
                try
                    mws.assignin('ChannelImpulse',tempChannelImpulse);
                    mws.assignin('RowSize',tempRowSize);
                    mws.assignin('Aggressors',tempAggressors);
                    mws.assignin('ImpulseMatrix',tempImpulseMatrix);
                catch ME
                    error(message('serdes:callbacks:ModelWorkspaceLocked',"Analog Channel"));
                end
            end

            if serdesIBISObj.ResistanceTx~=maskNamesValues.TxR||...
                serdesIBISObj.CapacitanceTx~=maskNamesValues.TxC||...
                serdesIBISObj.ResistanceRx~=maskNamesValues.RxR||...
                serdesIBISObj.CapacitanceRx~=maskNamesValues.RxC||...
                serdesIBISObj.RiseTime~=maskNamesValues.RiseTime||...
                serdesIBISObj.Voltage~=maskNamesValues.VoltageSwingIdeal

                serdesIBISObj.ResistanceTx=maskNamesValues.TxR;
                serdesIBISObj.CapacitanceTx=maskNamesValues.TxC;
                serdesIBISObj.ResistanceRx=maskNamesValues.RxR;
                serdesIBISObj.CapacitanceRx=maskNamesValues.RxC;
                serdesIBISObj.RiseTime=maskNamesValues.RiseTime;
                serdesIBISObj.Voltage=maskNamesValues.VoltageSwingIdeal;
                try
                    mws.assignin('SerdesIBIS',serdesIBISObj);
                catch ME
                    error(message('serdes:callbacks:ModelWorkspaceLocked',"Analog Channel"));
                end
            end

            if rawAggressorCount>0

                propSuffix={'FEXT','NEXT','1','2','3','4','5','6'};
                if strcmp(channelType,'Loss model')
                    propSelect=[1,1,0,0,0,0,0,0];
                else
                    propSelect=[0,0,(1:6)<=rawAggressorCount];
                end
                propIndex=find(propSelect);
                xtalkStimulus=cell(1,rawAggressorCount);

                assert(length(propIndex)==rawAggressorCount,'Inconsistent number of crosstalk aggressors.');

                for ii=1:length(propIndex)
                    ndx=propIndex(ii);

                    modval=serdes.internal.callbacks.convertModulation(maskNamesValues.("Modulation"+propSuffix{ndx}));
                    xtalkStimulus{ii}=serdes.Stimulus(...
                    'SampleInterval',wsSampleInterval.Value,...
                    'SymbolTime',maskNamesValues.("UI"+propSuffix{ndx}),...
                    'Modulation',modval,...
                    'Delay',maskNamesValues.("Delay"+propSuffix{ndx}),...
                    'Specification','PRBS',...
                    'Order',str2double(maskNamesValues.("Order"+propSuffix{ndx})));
                end
            end
            findStimulus=find_system(block,...
            'LookUnderMasks','all','FollowLinks','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'System','serdes.Stimulus');
            for ii=1:length(findStimulus)

                propNames=properties(xtalkStimulus{ii});
                for kk=1:length(propNames)
                    val=xtalkStimulus{ii}.(propNames{kk});
                    if isnumeric(val)&&isscalar(val)
                        val2=num2str(val,15);
                    elseif isnumeric(val)&&~isscalar(val)
                        val2=['[',num2str(val,15),']'];
                    elseif iscell(val)

                        vecstr='{ ';
                        for jj=1:length(val)
                            tmpstr=sprintf('%i ',val{jj});
                            tmpstr2=sprintf('[%s] ',tmpstr);
                            vecstr=[vecstr,tmpstr2];%#ok<AGROW>
                        end
                        val2=[vecstr,'}'];
                    else
                        val2=val;
                    end

                    xtalkMaskObj=Simulink.Mask.get(findStimulus{ii});
                    xtalkMaskNames={xtalkMaskObj.Parameters.Name};
                    old_val=get_param(findStimulus{ii},propNames{kk});

                    if strcmp(propNames{kk},'SampleInterval')
                        if~isequal(old_val,'SampleInterval')
                            xtalkMaskObj.Parameters(strcmp(xtalkMaskNames,'SampleInterval')).Value='SampleInterval';
                        end
                    else
                        if~isequal(old_val,val2)
                            xtalkMaskObj.Parameters(strcmp(xtalkMaskNames,propNames{kk})).Value=num2str(val2);
                        end
                    end
                end
            end
        end
    end
end
