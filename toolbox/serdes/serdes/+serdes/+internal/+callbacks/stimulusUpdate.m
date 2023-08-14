




function stimulusUpdate(block,calledFrom)
    mws=get_param(bdroot(block),'ModelWorkspace');
    requiredMWSElements=["StimulusPattern","SymbolTime"];
    switch(calledFrom)
    case "Open"

        open_system(block,'mask');
    case "Initialization"

        if~isempty(mws)&&all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
            maskObj=Simulink.Mask.get(block);
            maskNames={maskObj.Parameters.Name};
            maskValues={maskObj.Parameters.Value};
            maskNamesValues=cell2struct(maskValues,maskNames,2);

            prbsLength=str2double(maskNamesValues.NumberOfSymbols);
            if isnan(prbsLength)
                error(message('serdes:callbacks:VarNotResolved',"NumberOfSymbols"));
            end
            tempSymbolTime=mws.getVariable('SymbolTime');
            tempSymbolTimeValue=tempSymbolTime.Value;
            currentStopTime=str2double(get_param(bdroot(block),'StopTime'));
            calculatedStopTime=tempSymbolTimeValue*prbsLength;
            if strcmp(maskNamesValues.UseSimStopTime,'on')&&calculatedStopTime~=currentStopTime
                set_param(bdroot(block),'StopTime',sprintf('%.15g',calculatedStopTime));
            end

            blk=[block,'/MATLAB System'];


            if strcmp(maskNamesValues.CustomStimulusEnable,'off')

                prbsOrder=str2double(maskNamesValues.PRBS);
                tempStimulus=mws.getVariable('StimulusPattern');
                prbsPattern=prbs(prbsOrder,prbsLength);

                if~isequal(tempStimulus,prbsPattern)
                    try
                        mws.assignin('StimulusPattern',prbsPattern);

                    catch ME
                        error(message('serdes:callbacks:ModelWorkspaceLocked',"Stimulus"));
                    end
                end



                tmpModulation=mws.getVariable('Modulation');
                if tmpModulation.Value==4
                    maskObj.Parameters(strcmp(maskNames,'soSpecification')).Value='PRBS';
                    maskObj.Parameters(strcmp(maskNames,'soOrder')).Value=sprintf('[17 %i ]',prbsOrder);
                    maskObj.Parameters(strcmp(maskNames,'soSeed')).Value=...
                    sprintf('{[1 1 0 1 0 0 1 0 1 1 0 0 0 0 0 1 0], [ zeros(1,%i-1), 1 ]}',prbsOrder);
                elseif~ismember(tmpModulation.Value,[2,4,8,16,32])
                    maskObj.Parameters(strcmp(maskNames,'soSpecification')).Value='PAMn';
                else
                    maskObj.Parameters(strcmp(maskNames,'soSpecification')).Value='PRBS';
                    maskObj.Parameters(strcmp(maskNames,'soOrder')).Value=num2str(prbsOrder);
                    maskObj.Parameters(strcmp(maskNames,'soSeed')).Value=sprintf('{[ zeros(1,%i-1), 1 ]}',prbsOrder);
                end
            else

                maskObj.Parameters(strcmp(maskNames,'soSpecification')).Value='Sampled Voltage';
            end


            txTree=mws.getVariable('TxTree');
            TxDCD=txTree.getReservedParameter('Tx_DCD');
            TxDj=txTree.getReservedParameter('Tx_Dj');
            TxRj=txTree.getReservedParameter('Tx_Rj');
            TxSj=txTree.getReservedParameter('Tx_Sj');
            TxSjFrequency=txTree.getReservedParameter('Tx_Sj_Frequency');

            if~isempty(TxDCD)
                [numValue,unitValue]=serdes.internal.callbacks.getJitterValues(TxDCD);
                maskObj.Parameters(strcmp(maskNames,'soDCD')).Value=sprintf('%.15g',numValue);
                maskObj.Parameters(strcmp(maskNames,'soDCDUnit')).Value=unitValue;
            end
            if~isempty(TxDj)
                [numValue,unitValue]=serdes.internal.callbacks.getJitterValues(TxDj);
                maskObj.Parameters(strcmp(maskNames,'soDj')).Value=sprintf('%.15g',numValue);
                maskObj.Parameters(strcmp(maskNames,'soDjUnit')).Value=unitValue;
            end
            if~isempty(TxRj)
                [numValue,unitValue]=serdes.internal.callbacks.getJitterValues(TxRj);
                maskObj.Parameters(strcmp(maskNames,'soRj')).Value=sprintf('%.15g',numValue);
                maskObj.Parameters(strcmp(maskNames,'soRjUnit')).Value=unitValue;
            end
            if~isempty(TxSj)
                [numValue,unitValue]=serdes.internal.callbacks.getJitterValues(TxSj);
                maskObj.Parameters(strcmp(maskNames,'soSj')).Value=sprintf('%.15g',numValue);
                maskObj.Parameters(strcmp(maskNames,'soSjUnit')).Value=unitValue;
            end
            if~isempty(TxSjFrequency)
                numValue=serdes.internal.callbacks.getJitterValues(TxSjFrequency);
                maskObj.Parameters(strcmp(maskNames,'soSjFrequency')).Value=sprintf('%.15g',numValue);
            end
        end
    end
end