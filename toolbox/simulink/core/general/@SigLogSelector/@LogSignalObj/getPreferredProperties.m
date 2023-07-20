function props=getPreferredProperties(~)





    persistent vals;
    mlock;
    if isempty(vals)
        vals=properties(Simulink.SimulationData.LoggingInfo);
        vals=[{'Name';'SourcePath'};vals];
    end
    props=vals;
end
