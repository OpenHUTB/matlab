function output=compareFiles(tree,evolution1Id,evolution2Id,fileName)







    evolution1=tree.EvolutionManager.getEvolutionFromId(evolution1Id);
    evolution2=tree.EvolutionManager.getEvolutionFromId(evolution2Id);


    bfi=tree.EvolutionManager.BaseFileManager.getBaseFileInfoForFile(fileName);


    serverCatalog=evolutions.internal.session.SessionManager.getServers;
    server=serverCatalog.getServer(tree.Id);


    compareArtifactDirectory=fullfile(tempdir,'evolutiontempdir');

    tempFileEvolution1=getCompareTempFile(...
    bfi,compareArtifactDirectory,evolution1,server);
    tempFileEvolution2=getCompareTempFile(...
    bfi,compareArtifactDirectory,evolution2,server);


    try
        visdiff(tempFileEvolution1,tempFileEvolution2);
    catch ME
        errorMessage=getString(message...
        ('evolutions:manage:CompareToolError',ME.message));
        errorMessage=strrep(errorMessage,filesep,[filesep,filesep]);
        exception=MException('evolutions:manage:CompareToolError',errorMessage);
        throw(exception)
    end

    output=true;

end


function tempFile=getCompareTempFile(bfi,compareArtifactDirectory,evolution,server)

    if~evolution.IsWorking
        evolutionFileId=evolution.BaseIdtoArtifactId.at(bfi.Id);
        tempDirForEvolution=fullfile(compareArtifactDirectory,evolution.Id);
        fileName=createSafeFileName(evolution,bfi);
        tempFile=fullfile(tempDirForEvolution,fileName);
        evolutions.internal.utils.createDirSafe(tempDirForEvolution);
        server.getVersion(tempFile,evolutionFileId);
    else
        tempFile=bfi.File;
    end

end


function fileName=createSafeFileName(ei,bfi)

    evolutionName=matlab.lang.makeValidName(ei.getName);
    lengthEvolutionName=length(evolutionName);
    [~,baseFileName,extension]=fileparts(bfi.FileName);


    baseFileName=matlab.lang.makeValidName(baseFileName);
    lengthBaseFileName=length(baseFileName);
    totalChars=lengthEvolutionName+lengthBaseFileName+1;

    if totalChars>namelengthmax
        truncatedBaseFileName=getTruncatedBaseName(evolutionName,lengthEvolutionName,baseFileName,lengthBaseFileName);
        fileName=sprintf('%s%s',truncatedBaseFileName,extension);
    else
        fileName=sprintf('%s_%s%s',evolutionName,baseFileName,extension);
    end

end


function truncatedBaseFileName=getTruncatedBaseName(evolutionName,lengthEvolutionName,baseFileName,lengthBaseFileName)

    totalCharsToUse=namelengthmax;


    baseFileNameCharMax=floor(totalCharsToUse/2);
    evolutionNameCharMax=baseFileNameCharMax;




    if lengthEvolutionName<evolutionNameCharMax
        baseFileNameCharMax=baseFileNameCharMax+evolutionNameCharMax-lengthEvolutionName;
        evolutionNameCharMax=lengthEvolutionName;
    elseif lengthBaseFileName<baseFileNameCharMax
        evolutionNameCharMax=evolutionNameCharMax+baseFileNameCharMax-lengthBaseFileName;
        baseFileNameCharMax=lengthBaseFileName;
    end

    evolutionNameTruncated=evolutionName(1:evolutionNameCharMax);
    fileNameTruncated=baseFileName(1:baseFileNameCharMax);
    truncatedBaseFileName=sprintf('%s_%s',evolutionNameTruncated,fileNameTruncated);

end


