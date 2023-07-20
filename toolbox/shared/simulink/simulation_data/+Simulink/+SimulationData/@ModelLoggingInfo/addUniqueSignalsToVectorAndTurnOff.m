function dest=addUniqueSignalsToVectorAndTurnOff(~,source,dest)







    for idx=1:length(source)


        loc=Simulink.SimulationData.ModelLoggingInfo.findSignals(...
        dest,...
        source(idx).blockPath_,...
        source(idx).outputPortIndex_);


        if isempty(loc)
            dest=[dest,source(idx)];%#ok<AGROW>
            dest(end).loggingInfo_.dataLogging_=false;
        end
    end

end
