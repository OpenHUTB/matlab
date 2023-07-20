function[dirName,fileName]=getCovOutputFullDir(simInput,workingDir)
    dirName=simInput.get_param('CovOutputDir');
    dirName=cvi.CvhtmlSettings.getProcessedDirName(dirName,simInput.ModelName);
    if~MultiSim.internal.isAbsolutePath(dirName)
        dirName=fullfile(workingDir,dirName);
    end
    modelName=simInput.ModelName;
    fileName=simInput.get_param('CovDataFileName');
    fileName=strrep(fileName,'$ModelName$',modelName);

end