function assignVarToWorkspace(Signals,dataName)









    if~isempty(dataName)||(isempty(dataName)&&ischar(dataName))




        if length(Signals.Data)==1&&isa(Signals.Data{1},'Simulink.SimulationData.Dataset')


            assignin('base',Signals.Names{1},Signals.Data{1})

        else


            idxMapped=strcmp(Signals.Names,dataName);
            assignin('base',Signals.Names{idxMapped},Signals.Data{idxMapped});

        end

    end