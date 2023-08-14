classdef Export<handle

    methods(Static)

        [varNameIsAvailable,invalidNameError,errorMessage]=...
        exportToBaseWorkspace(baseWorkspace_VarName,valuesStruct,...
        forceOverwrite,activeApp,runIDs,signalIDs);


        [fileNameIsAvailable,invalidNameError,errorMessage]=...
        exportToMatFile(fileName,valuesStruct,forceOverwrite,...
        activeApp,runIDs,signalIDs);


        [fileNameIsAvailable,invalidNameError,errorMessage]=...
        exportToMFile(fileName,valuesStruct,forceOverwrite);


        [fileNameIsAvailable,invalidNameError,errorMessage]=...
        exportToFileHelper(fileType,fileName,valuesStruct,...
        forceOverwrite,activeApp,runIDs,signalIDs);


        [varNameIsAvailable,invalidNameError]=isVarNameAvailable(varName,forceOverwrite);


        exportPlotToFigure(clientID,axesID,copyType);


        fullFilePath=getFullFilePath(fileName,defaultExtension);

        function varArray=convertStructToVariableArray(valuesStruct)
            varArray=arrayfun(@(param)Simulink.Simulation.Variable(...
            param.Variable,param.RuntimeValue,'Workspace',param.Workspace),valuesStruct);
        end
    end
end
