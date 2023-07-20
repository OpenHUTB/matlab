function elem=addDelay(hdl,numSteps)









    elem=Sldv.ObjectiveSelection.sldvPickObjectives(hdl,...
    'covtype','addDelay',...
    'outcome',numSteps);
end
