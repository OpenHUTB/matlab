function ts=phases(modelName,phaseNames)






    simscape.performance.timing.setup(phaseNames);


    eval([modelName,'([], [], [], ''compile'')']);
    eval([modelName,'([], [], [], ''term'')']);


    ts=containers.Map;
    for i=1:length(phaseNames)
        qt=simscape.performance.timing.query(phaseNames{i});


        ts(phaseNames{i})=sum([qt.user]);
    end


    simscape.performance.timing.reset;

end
