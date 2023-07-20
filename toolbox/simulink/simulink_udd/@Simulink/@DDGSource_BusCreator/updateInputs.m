function updateInputs(source,dlg,tag)





    inputs=source.state.Inputs;
    block=dlg.getDialogSource.getBlock;
    num=floor(source.str2doubleNoComma(dlg.getWidgetValue(tag)));

    widgetName='MatchInputsString';
    customNames=dlg.getWidgetValue(widgetName);

    hierarchy=source.getCachedSignalHierarchy(block,false);
    hierarchy=source.oldFormat2NewFormat(hierarchy);
    if~isempty(num)&&isfinite(num)&&(num>0)

        source.unhilite(dlg,false);
        signalNames={};

        if~isnan(source.str2doubleNoComma(inputs))
            if~isempty(hierarchy)
                signalNames={hierarchy(:).SignalName};
            end
        else
            signalNames=source.str2CellArr(inputs);
        end


        newSignals=signalNames;
        currentNum=length(signalNames);
        if currentNum<num
            signalMap=containers.Map(signalNames,...
            ones(length(signalNames),1));
            inc=1;
            for i=1:num-currentNum
                continueSearch=true;
                while continueSearch
                    newName=['newsignal',num2str(inc)];
                    nameFound=signalMap.isKey(newName);
                    if nameFound
                        continueSearch=true;
                    else
                        continueSearch=false;
                    end
                    inc=inc+1;
                end
                newSignals=[newSignals,newName];%#ok
            end
        elseif currentNum>num
            newSignals(num+1:end)=[];
        end


        source.state.InputsString=source.cellArr2Str(newSignals);
        if customNames
            source.state.Inputs=source.cellArr2Str(newSignals);
        else
            source.state.Inputs=num2str(length(newSignals));
        end

        dlg.setUserData('signalsList',newSignals);
        source.refresh(dlg,false);
    else
        DAStudio.error('Simulink:blocks:invalidNumInputsSpecified');
    end


end


