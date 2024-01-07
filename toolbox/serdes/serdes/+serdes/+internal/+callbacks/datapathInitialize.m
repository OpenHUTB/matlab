function datapathInitialize(block)
    tree=serdes.internal.callbacks.getSerDesTree(block);
    if~isempty(tree)
        blockInstanceName=get_param(block,'Name');

        maskObj=Simulink.Mask.get(block);
        parameterNames={maskObj.Parameters.Name};
        parameterValues={maskObj.Parameters.Value};
        valuesMap=containers.Map(parameterNames,parameterValues);
        parameterTypes={maskObj.Parameters.Type};
        typesMap=containers.Map(parameterNames,parameterTypes);
        parameterControls={maskObj.Parameters.DialogControl};
        controlsMap=containers.Map(parameterNames,parameterControls);






        invalidParameters=zeros(1,size(parameterNames,2));
        nonAMIParameters=zeros(1,size(parameterNames,2));
        nonAMIValuesMap=[];



        broadcastSetOff=false;
        for idx=1:size(parameterNames,2)
            parameterName=char(cellstr(parameterNames{idx}));
            if endsWith(parameterName,'AMI')





                baseParameterName=parameterName(1:size(parameterName,2)-3);
                amiEnabled=strcmp(get_param(block,parameterName),'on');
                if strcmp(baseParameterName,'TapWeights')
                    taps=tree.getTapsOfBlock(blockInstanceName);
                    alreadyEnabled=~any(cellfun(@(a)a.Hidden,taps));
                    if alreadyEnabled~=amiEnabled
                        if tree.Broadcast
                            tree.Broadcast=false;
                            broadcastSetOff=true;
                        end
                        tree.hideTapsOfBlock(blockInstanceName,~amiEnabled);
                    end
                else
                    node=tree.getParameterFromBlock(blockInstanceName,baseParameterName);
                    alreadyEnabled=~node.Hidden;
                    if alreadyEnabled~=amiEnabled
                        if tree.Broadcast
                            tree.Broadcast=false;
                            broadcastSetOff=true;
                        end
                        tree.hideParameterOfBlock(blockInstanceName,baseParameterName,~amiEnabled);
                    end
                end
            end
        end
        if broadcastSetOff
            tree.Broadcast=true;
        end
        for idx=1:size(parameterNames,2)
            parameterName=char(cellstr(parameterNames{idx}));
            if strcmp(parameterName,'SavedName')
                continue
            elseif endsWith(parameterName,'AMI')

                continue
            else

                newValueStr=valuesMap(parameterName);
                newValue=decodeParameterString(parameterName,newValueStr,controlsMap,block);
                if isempty(newValue)


                    invalidParameters(idx)=1;
                else

                    if strcmp(parameterName,'TapWeights')
                        amiParameter=tree.getTapsOfBlock(blockInstanceName);
                    else
                        amiParameter=tree.getParameterFromBlock(blockInstanceName,parameterName);
                    end
                    if isempty(amiParameter)






                        if isempty(nonAMIValuesMap)
                            nonAMIValuesMap=initializeFunctionParse(block);
                        end
                        if~isempty(nonAMIValuesMap)
                            curValueStr=nonAMIValuesMap(parameterName);
                            if~strcmp(curValueStr,[blockInstanceName,'Parameter.',parameterName])
                                curValue=decodeParameterString(parameterName,curValueStr,controlsMap,block);
                                if isempty(curValue)||~isequal(newValue,curValue)
                                    nonAMIParameters(idx)=1;
                                end
                            end
                        end
                    elseif~strcmp(typesMap(parameterName),'promote')
                        if strcmp(parameterName,'TapWeights')
                            curValue=tree.getTapWeightsFromBlock(blockInstanceName);
                        else
                            curValue=tree.getCurrentValue(blockInstanceName,parameterName);
                        end




                        if strcmp(parameterName,'ConfigSelect')
                            configs=str2double(transpose(maskObj.getParameter(parameterName).TypeOptions));
                            if~isequal(configs,amiParameter.Format.Values)
                                amiParameter.Format.Values=configs;





                                if isequal(curValue,newValue)
                                    matches=find(configs~=curValue);
                                    if~isempty(matches)
                                        curValue=configs(matches(1));
                                        tree.setCurrentValue(blockInstanceName,parameterName,curValue);
                                    end
                                end
                            end
                        end

                        if isempty(curValue)||~isequal(newValue,curValue)


                            if strcmp(parameterName,'TapWeights')
                                tree.addOrUpdateTapsOfBlock(blockInstanceName,newValue);
                            else
                                tree.setCurrentValue(blockInstanceName,parameterName,newValue);
                            end
                        end
                    end
                end
            end
        end

        if any(invalidParameters)
            invalidNames=parameterNames(1,logical(invalidParameters));
            error(message('serdes:callbacks:VarNotResolved',strjoin(invalidNames,', ')));
        end

        if any(nonAMIParameters)
            initBlock=[get_param(block,'Parent'),'/Init'];
            serdes.internal.callbacks.deliverInfoNotification(block,'serdes:callbacks:RefreshInitRequired',...
            initBlock,block);
        end
    else
        serdes.internal.callbacks.deliverInfoNotification(block,...
        'serdes:callbacks:ModelWorkspaceMissingTree','SerDesTree');
    end
end

function valuesMap=initializeFunctionParse(block)
    valuesMap=[];
    mlfcnBlock=[get_param(block,'Parent'),'/Init/Initialize Function/MATLAB Function'];
    emChart=find(slroot,'-isa','Stateflow.EMChart','Path',mlfcnBlock);
    if~isempty(mlfcnBlock)&&~isempty(emChart)
        initLines=splitlines(emChart.Script);
        blockName=get_param(block,'Name');
        blockLines=initLines(startsWith(initLines,[blockName,'Init.']));
        blockLines=strrep(blockLines,'''','');
        blockLines=regexprep(blockLines,';$','');
        if~isempty(blockLines)
            fmt=[blockName,'Init.%s = %[^\n\r]'];
            scanned=cellfun(@(x)textscan(x,fmt),blockLines,'UniformOutput',false);
            names=cellfun(@(x)x{1},scanned);
            values=cellfun(@(x)x{2},scanned);
            valuesMap=containers.Map(names,values);
        end
    end
end

function value=decodeParameterString(parameterName,strValue,controlsMap,block)
    if isa(controlsMap(parameterName),'Simulink.dialog.parameter.Popup')

        switch parameterName
        case 'Mode'

            switch strValue
            case 'Off'
                value=0;
            case 'On'
                value=1;
            case 'Fixed'
                value=1;
            case 'Adapt'
                value=2;
            end
        case 'ConfigSelect'
            value=str2double(strValue);
        otherwise
            value=strValue;
        end
    elseif isa(controlsMap(parameterName),'Simulink.dialog.parameter.Edit')






        if strcmp(parameterName,'GPZ')
            value=slResolve(strValue,bdroot(block));
        else
            value=str2double(strValue);
            if isnan(value)
                value=str2num(strValue);%#ok<ST2NM>
            end
        end
    elseif isa(controlsMap(parameterName),'Simulink.dialog.parameter.CheckBox')
        switch strValue
        case 'on'
            value=true;
        case 'off'
            value=false;
        case 'true'
            value=true;
        case 'false'
            value=false;
        end
    else
        value=strValue;
    end
end