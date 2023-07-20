function writeSimulateCodeToFile(fileID,fileNameVar,varNameVar,inputStringVar,modelName,castingUsed)






    fprintf(fileID,'\t try \n');


    fprintf(fileID,'\t \t%% Load Variable from file \n');

    if castingUsed
        fprintf(fileID,'\t \tloadScenarioToWorkspace( %s{kScenario},%s{kScenario}, spreadsheetDataTypeConfig(kScenario)); \n',fileNameVar,varNameVar);
    else
        fprintf(fileID,'\t \tloadScenarioToWorkspace( %s{kScenario},%s{kScenario}); \n',fileNameVar,varNameVar);
    end


    fprintf(fileID,'\t \t%% sim scenario \n');
    fprintf(fileID,'\t \tsimOut(kScenario) = sim( ''%s'', ''ExternalInput'', %s{kScenario}, ''LoadExternalInput'', ''on'');\n',modelName,inputStringVar);
    fprintf(fileID,'\t \tvarName = sprintf(''%%s'',%s{kScenario}); \n',varNameVar);
    fprintf(fileID,'\t \tevalin(''base'',sprintf(''clear %%s'',varName));\n');


    fprintf(fileID,'\t catch ME \n');

    fprintf(fileID,'\t \tcellOfErrors{ length(cellOfErrors) + 1 } = ME.message; \n');

    fprintf(fileID,'\t end \n');