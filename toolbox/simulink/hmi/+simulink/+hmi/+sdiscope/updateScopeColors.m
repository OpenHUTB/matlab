function updateScopeColors(widgetId,modelName,dlgSignalInfo,isLibWidget)



    widget=utils.getWidget(modelName,widgetId,isLibWidget);
    for clientIdx=1:length(widget.ClientID)
        client=Simulink.sdi.WebClient(widget.ClientID{clientIdx});
        for axisIdx=1:length(client.Axes)
            sigIDs=client.Axes(axisIdx).DatabaseIDs;
            eng=Simulink.sdi.Instance.engine;
            for idx=1:length(sigIDs)
                curSigInfo=locFindSignalInfo(sigIDs(idx),modelName,dlgSignalInfo,eng);
                if~isempty(curSigInfo)&&~curSigInfo.DefaultColorAndStyle
                    eng.setSignalLineColor(sigIDs(idx),curSigInfo.Color);
                    eng.setSignalLineDashed(sigIDs(idx),curSigInfo.LineStyle);
                end
            end
            Simulink.sdi.sendUpdatedColorStyleToClient(...
            eng.sigRepository,...
            widget.ClientID{clientIdx},...
            client.Axes(axisIdx).AxisID);
        end
    end
end


function sinfo=locFindSignalInfo(sigID,modelName,dlgSignalInfo,eng)


    sinfo=[];
    bpath=eng.getSignalBlockSource(sigID);
    pIndex=eng.getSignalPortIndex(sigID);
    for idx=1:length(dlgSignalInfo)
        if dlgSignalInfo(idx).OutputPortIndex==pIndex
            curPath=[modelName,'/',dlgSignalInfo(idx).BlockPath];
            if strcmp(bpath,curPath)
                sinfo=dlgSignalInfo(idx);
                return
            end
        end
    end
end
