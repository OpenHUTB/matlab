function initExternalSources(signalCellStruct,scenarioID)





    for kStruct=1:length(signalCellStruct)


        if strcmp(signalCellStruct{kStruct}.ParentID,'input')

            exSource=sta.ExternalSource;
            exSource.ScenarioID=scenarioID;

            if isfield(signalCellStruct{kStruct},'ComplexID')
                exSource.SignalID=signalCellStruct{kStruct}.ComplexID;
            else
                exSource.SignalID=signalCellStruct{kStruct}.ID;
            end

        end

    end
