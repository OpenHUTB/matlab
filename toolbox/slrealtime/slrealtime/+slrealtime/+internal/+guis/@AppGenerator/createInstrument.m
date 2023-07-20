function[guiInstrument,nSignals,tooltipCode,callbackCode]=createInstrument(bindingData,compMap,appArgName)







    tooltipCode={};
    callbackCode={};
    nSignals=0;

    guiInstrument=slrealtime.Instrument();
    if~isempty(bindingData)
        for nBinding=1:numel(bindingData)
            if~isfield(bindingData{nBinding},'PortIndex')

                continue;
            end
            nSignals=nSignals+1;

            blockPath=strrep(bindingData{nBinding}.BlockPath,newline,' ');
            portIndex=bindingData{nBinding}.PortIndex;
            signalName=bindingData{nBinding}.SignalName;
            busElement=bindingData{nBinding}.BusElement;
            controlName=bindingData{nBinding}.ControlName;
            controlType=bindingData{nBinding}.ControlType;
            propertyName=bindingData{nBinding}.PropertyName;
            decimation=bindingData{nBinding}.Decimation;
            arrayIndex=bindingData{nBinding}.ArrayIndex;
            callback=bindingData{nBinding}.Callback;
            lineWidth=str2num(bindingData{nBinding}.LineWidth);%#ok
            lineStyle=bindingData{nBinding}.LineStyle;
            lineColor=str2num(bindingData{nBinding}.LineColor);%#ok
            lineMarker=bindingData{nBinding}.LineMarker;
            lineMarkerSize=str2num(bindingData{nBinding}.LineMarkerSize);%#ok

            useName=bindingData{nBinding}.UseName&&~isempty(signalName);



            if~useName
                callbackCode{end+1}=['    [t',num2str(nSignals),', d',num2str(nSignals),'] = instrument.getCallbackDataForSignal(evnt, ''',blockPath,''', ',num2str(portIndex),');'];%#ok
            else
                callbackCode{end+1}=['    [t',num2str(nSignals),', d',num2str(nSignals),'] = instrument.getCallbackDataForSignal(evnt, ''',signalName,''');'];%#ok
            end



            if strcmp(controlType,'Signal Table')
                continue;
            end

            args={};
            if~isempty(decimation)
                args{end+1}='Decimation';%#ok
                args{end+1}=str2num(decimation);%#ok
            end
            if~isempty(arrayIndex)
                args{end+1}='ArrayIndex';%#ok
                args{end+1}=str2num(arrayIndex);%#ok
            end
            if~isempty(busElement)
                args{end+1}='BusElement';%#ok
                args{end+1}=busElement;%#ok
            end
            if~isempty(callback)
                args{end+1}='Callback';%#ok
                args{end+1}=eval(callback);%#ok
            end

            args{end+1}='MetaData';%#ok
            args{end+1}=struct(...
            'ControlName',controlName,...
            'ControlType',controlType);%#ok

            switch controlType
            case 'Axes'
                addLineWidth=lineWidth~=slrealtime.instrument.LineStyle.WidthDefault;
                addLineStyle=~strcmp(lineStyle,slrealtime.instrument.LineStyle.StyleDefault);
                addLineColor=all(lineColor~=slrealtime.instrument.LineStyle.ColorDefault);
                addLineMarker=~strcmp(lineMarker,slrealtime.instrument.LineStyle.MarkerDefault);
                addLineMarkerSize=lineMarkerSize~=slrealtime.instrument.LineStyle.MarkerSizeDefault;
                addLine=addLineWidth||addLineStyle||addLineColor||addLineMarker||addLineMarkerSize;

                if addLine
                    ls=slrealtime.instrument.LineStyle();

                    if addLineWidth
                        ls.Width=lineWidth;
                    end
                    if addLineStyle
                        ls.Style=lineStyle;
                    end
                    if addLineColor
                        ls.Color=lineColor;
                    end
                    if addLineMarker
                        ls.Marker=lineMarker;
                    end
                    if addLineMarkerSize
                        ls.MarkerSize=lineMarkerSize;
                    end

                    args{end+1}='LineStyle';%#ok
                    args{end+1}=ls;%#ok
                end

                if~useName
                    guiInstrument.connectLine(...
                    compMap(controlName),...
                    blockPath,portIndex,args{:});
                else
                    guiInstrument.connectLine(...
                    compMap(controlName),...
                    signalName,args{:});
                end

            case 'NONE'
                if~useName
                    guiInstrument.addSignal(...
                    blockPath,portIndex,args{:});
                else
                    guiInstrument.addSignal(...
                    signalName,args{:});
                end

            otherwise


                if strcmp(controlType,'Lamp')&&isempty(propertyName)
                    propertyName='Color';
                end

                if~isempty(propertyName)
                    args{end+1}='PropertyName';%#ok
                    args{end+1}=propertyName;%#ok
                end

                if~useName
                    guiInstrument.connectScalar(...
                    compMap(controlName),...
                    blockPath,portIndex,args{:});
                else
                    guiInstrument.connectScalar(...
                    compMap(controlName),...
                    signalName,args{:});
                end





                if~useName
                    tooltipCode{end+1}=['            ',appArgName,'.',controlName,'.Tooltip = ''',slrealtime.internal.displayBlockPath(blockPath),':',num2str(portIndex),''';'];%#ok
                else
                    tooltipCode{end+1}=['            ',appArgName,'.',controlName,'.Tooltip = ''',signalName,''';'];%#ok
                end
            end
        end
    end
end
