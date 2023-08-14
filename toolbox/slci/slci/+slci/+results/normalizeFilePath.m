






function outputPath=normalizeFilePath(inputPath)

    try

        outputPath=slci.internal.normalizeFilePath(inputPath,pwd);
    catch
        outputPath=inputPath;
    end

end

