function writeSimulationInputCodeToFile(fileID,fileNameVar,varNameVar,inputStringVar,modelName,castingUsed)







    fprintf(fileID,'%% For each scenario \n');

    fprintf(fileID,'for kScenario = 1: length( cellOfInputStrings ) \n');



    fprintf(fileID,'\t try \n');


    fprintf(fileID,'\t \t%% Load Variable from file \n');

    if castingUsed
        fprintf(fileID,'\t \tloadScenarioToWorkspace( %s{kScenario},%s{kScenario}, spreadsheetDataTypeConfig(kScenario)); \n',fileNameVar,varNameVar);
    else
        fprintf(fileID,'\t \tloadScenarioToWorkspace( %s{kScenario},%s{kScenario}); \n',fileNameVar,varNameVar);
    end


    fprintf(fileID,'\t \t%% set up SimulationInput object \n');

    fprintf(fileID,'\t \tsimIn(kScenario) = Simulink.SimulationInput(''%s'');\n',modelName);
    fprintf(fileID,'\t \tsimIn(kScenario).ExternalInput = cellOfInputStrings{kScenario};\n');
    fprintf(fileID,'\t \tsimIn(kScenario) = simIn(kScenario).setVariable( cellOfVarNames{kScenario}, evalin(''base'',(cellOfVarNames{kScenario})) );\n');
    fprintf(fileID,'\t \tevalin(''base'',sprintf(''clear %%s'',cellOfVarNames{kScenario}));\n');

    fprintf(fileID,'\t catch ME \n');

    fprintf(fileID,'\t \tcellOfErrors{ length(cellOfErrors) + 1 } = ME.message; \n');

    fprintf(fileID,'\t end \n');

    fprintf(fileID,'end \n');
    fprintf(fileID,'%% End for each scenario \n\n');

    fprintf(fileID,'if ~isempty( simIn )\n');
    fprintf(fileID,'\tsimOut = parsim(simIn);\n');
    fprintf(fileID,'end \n');