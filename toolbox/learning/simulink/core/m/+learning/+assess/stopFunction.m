function stopFunction(modelName,selectedBlock)











    simlog=evalin('base','simlog');


    userStruct=struct('simlog',simlog,...
    'correctBlock',[]);
    userBlockValueFile=learning.assess.getAssessmentPlotLogFile();
    save(userBlockValueFile,'userStruct');

    assessmentWithPlot=learning.assess.getAssessmentWithPlot();
    showFigureWindow=false;
    assessmentWithPlot.writePlotFigure(selectedBlock,showFigureWindow);

    learning.assess.clearBlockEffects(modelName);

    learning.simulink.refreshSignalWindows();
end

