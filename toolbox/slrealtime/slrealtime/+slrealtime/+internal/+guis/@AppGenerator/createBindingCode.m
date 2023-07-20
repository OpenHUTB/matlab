function bindingCode=createBindingCode(guiInstrument,bindingData,nSignals,uifigureName,appArgName,targetSelectorVarName)








    guiInstrumentText=guiInstrument.generateScript(true);
    guiInstrumentText=guiInstrumentText(3:end);
    guiInstrumentText=guiInstrumentText(~startsWith(guiInstrumentText,'%%'));
    guiInstrumentText=guiInstrumentText(~strcmp(guiInstrumentText,' '));
    guiInstrumentText=cellfun(@(x)['            ',x],guiInstrumentText,'UniformOutput',false);
    guiInstrumentText={guiInstrumentText{:}};%#ok % Return a row vector of cells.

    bindingCode=[{''},guiInstrumentText,{''}];



    nParams=0;
    if~isempty(bindingData)
        for nBinding=1:numel(bindingData)
            if isfield(bindingData{nBinding},'PortIndex')

                continue;
            end
            nParams=nParams+1;

            blockPath=strrep(bindingData{nBinding}.BlockPath,newline,' ');
            paramName=bindingData{nBinding}.ParamName;
            controlName=bindingData{nBinding}.ControlName;
            controlType=bindingData{nBinding}.ControlType;
            convToCompString=bindingData{nBinding}.ConvToComp;
            convToTargetString=bindingData{nBinding}.ConvToTarget;
            element=bindingData{nBinding}.Element;



            if strcmp(controlType,'Parameter Table')
                continue;
            end

            if isempty(convToCompString)
                switch controlType
                case 'Edit Field (numeric)'
                    convToCompString=['@',appArgName,'.convToDouble'];
                case 'Edit Field (text)'
                    convToCompString=['@',appArgName,'.convToString'];
                case 'Knob'
                    convToCompString=['@',appArgName,'.convToDouble'];
                case 'Slider'
                    convToCompString=['@',appArgName,'.convToDouble'];
                end
            end

            bindingCode{end+1}=['            slrtcomp = slrealtime.ui.tool.ParameterTuner(',appArgName,'.',uifigureName,', ''TargetSource'', ',targetSelectorVarName,');'];%#ok
            bindingCode{end+1}=['            slrtcomp.Component = ',appArgName,'.',controlName,';'];%#ok
            bindingCode{end+1}=['            slrtcomp.BlockPath = ',slrealtime.internal.guis.AppGenerator.convertToStrForMLAPPCode(blockPath),';'];%#ok
            bindingCode{end+1}=['            slrtcomp.ParameterName = ''',paramName,element,''';'];%#ok
            bindingCode{end+1}=['            slrtcomp.ConvertToComponent = ',convToCompString,';'];%#ok
            if~isempty(convToTargetString)
                bindingCode{end+1}=['            slrtcomp.ConvertToTarget = ',convToTargetString,';'];%#ok
            end
            bindingCode{end+1}='';%#ok
        end
    end



    if nParams>0
        controlTypeIdxs=cellfun(@(x)strcmp(x.ControlType,'Parameter Table'),bindingData);
        controlNames=unique(cellfun(@(x)x.ControlName,bindingData(controlTypeIdxs),'UniformOutput',false));

        for i=1:numel(controlNames)
            idxs=cellfun(@(x)strcmp(x.ControlName,controlNames{i}),bindingData);

            blockPaths=cellfun(@(x)strrep(x.BlockPath,newline,' '),bindingData(idxs),'UniformOutput',false);
            paramNames=cellfun(@(x)x.ParamName,bindingData(idxs),'UniformOutput',false);
            elements=cellfun(@(x)x.Element,bindingData(idxs),'UniformOutput',false);

            blockPaths=cellfun(@(x)regexprep(x,'[\n]+',' '),blockPaths,'UniformOutput',false);
            paramNames=regexprep(paramNames,'[\n]+',' ');

            blockPathsStr=slrealtime.internal.guis.AppGenerator.convertToStrForMLAPPCode(blockPaths{1});
            for j=2:length(blockPaths)
                blockPathsStr=[blockPathsStr,',',slrealtime.internal.guis.AppGenerator.convertToStrForMLAPPCode(blockPaths{j})];%#ok
            end
            paramNamesStr=['''',paramNames{1},elements{1},''''];
            for j=2:length(paramNames)
                paramNamesStr=[paramNamesStr,',''',paramNames{j},elements{j},''''];%#ok
            end

            bindingCode{end+1}=['            ',appArgName,'.',controlNames{i},'.Parameters = struct( ...'];%#ok
            bindingCode{end+1}=['            ''BlockPath'', {',blockPathsStr,'}, ...'];%#ok
            bindingCode{end+1}=['            ''ParameterName'', {',paramNamesStr,'});'];%#ok
            bindingCode{end+1}='';%#ok
        end
    end



    if nSignals>0
        controlTypeIdxs=cellfun(@(x)strcmp(x.ControlType,'Signal Table'),bindingData);
        controlNames=unique(cellfun(@(x)x.ControlName,bindingData(controlTypeIdxs),'UniformOutput',false));

        for i=1:numel(controlNames)
            idxs=cellfun(@(x)strcmp(x.ControlName,controlNames{i}),bindingData);

            signalNames=cellfun(@(x)regexprep(x.SignalName,'[\n]+',' '),bindingData(idxs),'UniformOutput',false);
            blockPaths=cellfun(@(x)regexprep(x.BlockPath,'[\n]+',' '),bindingData(idxs),'UniformOutput',false);
            portIdxs=cellfun(@(x)x.PortIndex,bindingData(idxs));
            useNames=cellfun(@(x)x.UseName,bindingData(idxs));

            if~useNames(1)||isempty(signalNames{1})
                blockPathsStr=slrealtime.internal.guis.AppGenerator.convertToStrForMLAPPCode(blockPaths{1});
                portIdxsStr=num2str(portIdxs(1));
            else
                blockPathsStr=slrealtime.internal.guis.AppGenerator.convertToStrForMLAPPCode(signalNames{1});
                portIdxsStr=num2str(-1);
            end
            for j=2:length(blockPaths)
                if~useNames(j)||isempty(signalNames{j})
                    blockPathsStr=[blockPathsStr,',',slrealtime.internal.guis.AppGenerator.convertToStrForMLAPPCode(blockPaths{j})];%#ok
                    portIdxsStr=[portIdxsStr,',',num2str(portIdxs(j))];%#ok
                else
                    blockPathsStr=[blockPathsStr,',',slrealtime.internal.guis.AppGenerator.convertToStrForMLAPPCode(signalNames{j})];%#ok
                    portIdxsStr=[portIdxsStr,',',num2str(-1)];%#ok
                end
            end

            bindingCode{end+1}=['            ',appArgName,'.',controlNames{i},'.Signals = struct( ...'];%#ok
            bindingCode{end+1}=['            ''BlockPath'', {',blockPathsStr,'}, ...'];%#ok
            bindingCode{end+1}=['            ''PortIndex'', {',portIdxsStr,'});'];%#ok
            bindingCode{end+1}='';%#ok
        end
    end
end