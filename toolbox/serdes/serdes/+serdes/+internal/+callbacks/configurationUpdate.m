




function configurationUpdate(block,calledFrom)
    mws=get_param(bdroot(block),'ModelWorkspace');
    requiredMWSElements=["SampleInterval","SymbolTime","TargetBER","Modulation","TxTree","RxTree","SerdesIBIS"];
    switch(calledFrom)
    case "Open"

        simStatus=get_param(bdroot(block),'SimulationStatus');

        if strcmp(simStatus,'stopped')&&~isempty(mws)&&...
            all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))

            maskObj=Simulink.Mask.get(block);
            maskNames={maskObj.Parameters.Name};
            serdesIBISObj=mws.getVariable('SerdesIBIS');
            tempSampleInterval=mws.getVariable('SampleInterval');
            tempSampleIntervalValue=tempSampleInterval.Value;
            tempSymbolTime=mws.getVariable('SymbolTime');
            tempSymbolTimeValue=tempSymbolTime.Value;
            tempSamplesPerSymbol=tempSymbolTimeValue/tempSampleIntervalValue;
            tempTargetBER=mws.getVariable('TargetBER');
            tempTargetBERValue=tempTargetBER.Value;
            tempModulation=mws.getVariable('Modulation');
            tempModulationValue=serdes.internal.callbacks.convertModulation(tempModulation.Value);

            engSymbolTime=serdes.internal.callbacks.numberToEngString(tempSymbolTimeValue);

            maskObj.Parameters(strcmp(maskNames,'SymbolTime')).Value=engSymbolTime;
            maskObj.Parameters(strcmp(maskNames,'SamplesPerSymbol')).Value=num2str(tempSamplesPerSymbol);
            maskObj.Parameters(strcmp(maskNames,'TargetBER')).Value=num2str(tempTargetBERValue);
            maskObj.Parameters(strcmp(maskNames,'Modulation')).Value=tempModulationValue;
            if serdesIBISObj.Differential==1
                maskObj.Parameters(strcmp(maskNames,'Signaling')).Value='Differential';
            else
                maskObj.Parameters(strcmp(maskNames,'Signaling')).Value='Single-ended';
            end

            ignoreBits=serdes.internal.callbacks.getIgnoreBits(mws);
            maskObj.Parameters(strcmp(maskNames,'IgnoreBitsDisplay')).Value=num2str(ignoreBits);

            dctrl=maskObj.getDialogControl('SILinkButton');
            if~isempty(dctrl)
                if builtin('license','test','signal_integrity_toolbox')...
                    &&~ismac...
                    &&~isempty(which('serialLinkDesigner'))...
                    &&~isempty(which('parallelLinkDesigner'))
                    dctrl.Enabled='on';
                else
                    dctrl.Enabled='off';
                end
            end
        end
        open_system(block,'mask');
    case "Initialization"

        if~isempty(mws)&&all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
            maskObj=Simulink.Mask.get(block);
            maskNames={maskObj.Parameters.Name};
            maskTypes={maskObj.Parameters.Type};
            maskEnables={maskObj.Parameters.Enabled};
            maskValues={maskObj.Parameters.Value};



            errorParameters={};
            for paramIdx=1:numel(maskNames)
                if(strcmp(maskTypes{paramIdx},'edit')&&strcmp(maskEnables{paramIdx},'on'))...
                    ||strcmp(maskTypes{paramIdx},'promote')
                    paramAsDouble=str2double(maskValues{paramIdx});
                    if isnan(paramAsDouble)
                        paramAsNum=str2num(maskValues{paramIdx});%#ok<ST2NM>
                        if isempty(paramAsNum)
                            errorParameters{end+1}=maskNames{paramIdx};%#ok<AGROW>
                        else
                            maskValues{paramIdx}=paramAsNum;
                        end
                    else
                        maskValues{paramIdx}=paramAsDouble;
                    end
                end
            end
            if~isempty(errorParameters)
                error(message('serdes:callbacks:VarNotResolved',strjoin(errorParameters,', ')));
            end
            maskNamesValues=cell2struct(maskValues,maskNames,2);
            serdesIBISObj=mws.getVariable('SerdesIBIS');
            tempSampleInterval=mws.getVariable('SampleInterval');
            tempSymbolTime=mws.getVariable('SymbolTime');
            tempTargetBER=mws.getVariable('TargetBER');
            tempModulation=mws.getVariable('Modulation');

            updateStimulus=false;
            if tempSymbolTime.Value~=maskNamesValues.SymbolTime
                tempSymbolTime.Value=maskNamesValues.SymbolTime;
                try
                    mws.assignin('SymbolTime',tempSymbolTime);
                    updateStimulus=true;
                catch ME
                    error(message('serdes:callbacks:ModelWorkspaceLocked',"Configuration"));
                end
            end
            calculatedSampleInterval=maskNamesValues.SymbolTime/str2double(maskNamesValues.SamplesPerSymbol);
            updateChannel=false;
            updateImpedance=false;
            if tempSampleInterval.Value~=calculatedSampleInterval
                tempSampleInterval.Value=calculatedSampleInterval;
                try
                    mws.assignin('SampleInterval',tempSampleInterval);
                catch ME
                    error(message('serdes:callbacks:ModelWorkspaceLocked',"Configuration"));
                end
                updateChannel=true;
            end
            if tempTargetBER.Value~=maskNamesValues.TargetBER
                tempTargetBER.Value=maskNamesValues.TargetBER;
                try
                    mws.assignin('TargetBER',tempTargetBER);
                catch ME
                    error(message('serdes:callbacks:ModelWorkspaceLocked',"Configuration"));
                end
            end


            maskModulation=string(maskNamesValues.Modulation);
            tempModulationValue=serdes.internal.callbacks.convertModulation(maskModulation);


            if tempModulationValue~=tempModulation.Value||...
                (tempModulation.Value==3&&~mws.hasVariable('PAM_Thresholds'))


                txTree=mws.getVariable('TxTree');
                rxTree=mws.getVariable('RxTree');
                if~isempty(rxTree.getReservedParameter("Modulation"))

                    if~(tempModulationValue==3||tempModulationValue>4)

                        checkAMIList(txTree,'Modulation',maskModulation,'ModulationNotInListLegacy');
                        checkAMIList(rxTree,'Modulation',maskModulation,'ModulationNotInListLegacy');
                        txTree.setReservedParameterCurrentValue('Modulation',maskModulation);
                        rxTree.setReservedParameterCurrentValue('Modulation',maskModulation);
                    else



                        h=warndlg(...
                        message('serdes:callbacks:LegacyPAM4ModelUsingPAMn',maskModulation).getString,...
                        message('serdes:callbacks:LegacyPAM4ModelUsingPAMnTitle').getString);
                        uiwait(h);

                        txTree.removeLegacyModulationParameters;
                        rxTree.removeLegacyModulationParameters;

                        txTree.addModulationParameters;
                        rxTree.addModulationParameters;

                        txTree.setReservedParameterCurrentValue('Modulation_Levels',tempModulationValue);
                        rxTree.setReservedParameterCurrentValue('Modulation_Levels',tempModulationValue);

                        if~mws.hasVariable('PAM_Thresholds')

                            simulinkSignal=Simulink.Signal;

                            simulinkSignal.InitialValue='zeros(31,1)';

                            simulinkSignal.DataType='double';
                            simulinkSignal.DimensionsMode='Fixed';
                            simulinkSignal.Dimensions=[31,1];
                            simulinkSignal.Complexity='real';

                            mws.assignin('PAM_Thresholds',simulinkSignal);
                        end
                    end
                elseif~isempty(rxTree.getReservedParameter("Modulation_Levels"))

                    checkAMIList(txTree,'Modulation_Levels',tempModulationValue,'ModulationNotInList');
                    checkAMIList(rxTree,'Modulation_Levels',tempModulationValue,'ModulationNotInList');
                    txTree.setReservedParameterCurrentValue('Modulation_Levels',tempModulationValue);
                    rxTree.setReservedParameterCurrentValue('Modulation_Levels',tempModulationValue);
                end

                tempModulation.Value=tempModulationValue;
                try
                    mws.assignin('Modulation',tempModulation);
                catch ME
                    error(message('serdes:callbacks:ModelWorkspaceLocked',"Configuration"));
                end
            end

            if strcmp(maskNamesValues.Signaling,'Differential')
                maskDifferential=true;
            else
                maskDifferential=false;
            end
            if serdesIBISObj.Differential~=maskDifferential

                serdesIBISObj.Differential=maskDifferential;
                try
                    mws.assignin('SerdesIBIS',serdesIBISObj);
                catch ME
                    error(message('serdes:callbacks:ModelWorkspaceLocked',"Configuration"));
                end
                updateChannel=true;
                updateImpedance=true;
            end



            if updateChannel||updateStimulus
                updatedStimulus=false;
                updatedChannel=false;

                currentTopLevelBlocks=find_system(extractBefore(block,'Configuration'),'SearchDepth',1,'BlockType','SubSystem');
                for idxBlocks=1:size(currentTopLevelBlocks,1)

                    blockOrigLibraryAndName=get_param(currentTopLevelBlocks{idxBlocks},'ReferenceBlock');
                    if strcmp(blockOrigLibraryAndName,'serdesUtilities/Analog Channel')&&updateChannel

                        if updateImpedance
                            analogChannelMaskObj=Simulink.Mask.get(currentTopLevelBlocks{idxBlocks});
                            analogChannelMaskNames={analogChannelMaskObj.Parameters.Name};
                            analogChannelMaskValues={analogChannelMaskObj.Parameters.Value};
                            analogChannelMaskNamesValues=cell2struct(analogChannelMaskValues,analogChannelMaskNames,2);
                            previousZc=str2double(analogChannelMaskNamesValues.Zc);


                            if maskDifferential
                                scaledZc=previousZc*2;
                            else
                                scaledZc=previousZc/2;
                            end
                            analogChannelMaskObj.Parameters(strcmp(analogChannelMaskNames,'Zc')).Value=num2str(scaledZc);
                        end

                        serdes.internal.callbacks.analogChannelUpdate(currentTopLevelBlocks{idxBlocks},"Initialization");
                        updatedChannel=true;
                    end
                    if strcmp(blockOrigLibraryAndName,'serdesUtilities/Stimulus')&&updateStimulus

                        serdes.internal.callbacks.stimulusUpdate(currentTopLevelBlocks{idxBlocks},"Initialization");
                        updatedStimulus=true;
                    end
                end
                if updateStimulus&&~updatedStimulus
                    error(message('serdes:callbacks:CannotFindBlock',"Stimulus"));
                end
                if updateChannel&&~updatedChannel
                    error(message('serdes:callbacks:CannotFindBlock',"Analog Channel"));
                end
            end
        end
    end
end

function checkAMIList(tree,paramName,paramValue,errorKey)
    if strcmp(tree.getReservedParameter(paramName).Format.Name,"List")
        listValues=tree.getReservedParameter(paramName).Format.Values;
        if~isa(paramValue,'string')
            paramValue=num2str(paramValue);
        end
        if~any(strcmp(listValues,paramValue))
            error(message(['serdes:callbacks:',errorKey],paramValue));
        end
    end
end


