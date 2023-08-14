


function dataValid=utilCheckData(spidata,isDataFromGUI)
    dataValid=false;
    tout=[];
    if spidata.isprop('tout')
        tout=get(spidata,'tout');
    end

    if length(tout)<2
        if isDataFromGUI
            msg=DAStudio.message('Simulink:solverProfiler:simulationShort');
            tag='simulationShort';
            hf=msgbox(msg);
            set(hf,'tag',tag);
            setappdata(hf,'DisplayMessage',msg);
            return;
        else
            id='failedToLoadData:notASessionData';
            msg=DAStudio.message('Simulink:solverProfiler:simulationShort');
            throw(MException(id,msg));
        end
    end
    dataValid=true;
end