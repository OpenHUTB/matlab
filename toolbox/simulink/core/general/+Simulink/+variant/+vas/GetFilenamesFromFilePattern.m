
function[mdlFileNames,ssFileNames,fileNameOrPatternsWithError]=GetFilenamesFromFilePattern(fileNameOrPattern,filePatternAbsPathWrtBd)




    mdlFileNames={};
    ssFileNames={};
    fileNameOrPatternsWithError={};
    filesNotInPath={};









    filePath=which(fileNameOrPattern);






    if(~isfile(filePath))
        filePath='';
    end










    if(~isempty(filePath))
        [mdlFileNames,ssFileNames,~,isFileNameOrPatternWithError]=...
        UpdateModelOrSubsystemFileNames(filePath,mdlFileNames,ssFileNames,filesNotInPath);
        if isFileNameOrPatternWithError
            fileNameOrPatternsWithError=[fileNameOrPatternsWithError,{fileNameOrPattern}];
        end
        return;
    end






    if(~isempty(filePatternAbsPathWrtBd))
        items=dir(filePatternAbsPathWrtBd);
    else


        items=dir(fileNameOrPattern);
    end






    if(isempty(items))
        fileNameOrPatternsWithError=[fileNameOrPatternsWithError,{fileNameOrPattern}];
        return;
    end

    for i=1:length(items)
        if items(i).isdir
            continue;
        end

        fileName=items(i).name;
        fileDir=items(i).folder;

        [mdlFileNames,ssFileNames,filesNotInPath,isFileNameOrPatternWithError]=...
        UpdateModelOrSubsystemFileNames(fullfile(fileDir,fileName),mdlFileNames,ssFileNames,filesNotInPath);
        if isFileNameOrPatternWithError
            continue;
        end
    end

    if~isempty(filesNotInPath)

        filesNotInPathStr=join(unique(filesNotInPath),', ');
        filesNotInPathStr=[newline,filesNotInPathStr{:}];
        DAStudio.error('Simulink:Variants:VASFilesMustBeInPath',fileNameOrPattern,filesNotInPathStr);
    end

end



function bdType=getBDType(filePath)
    mdlInfo=Simulink.MDLInfo(filePath);
    if strcmp(mdlInfo.BlockDiagramType,'Model')
        bdType='Model';
    elseif strcmp(mdlInfo.BlockDiagramType,'Subsystem')
        bdType='Subsystem';
    else
        bdType='';
    end
end

function retVal=isExtensionSLXOrMDL(ext)
    retVal=strcmp(ext,'.slx')||strcmp(ext,'.mdl');
end



function[mdlFileNames,ssFileNames,filesNotInPath,isFileNameOrPatternWithError]=...
    UpdateModelOrSubsystemFileNames(fileAbsPath,mdlFileNames,ssFileNames,filesNotInPath)

    isFileNameOrPatternWithError=false;







    [~,fileStem,ext]=fileparts(fileAbsPath);

    if(~isExtensionSLXOrMDL(ext))
        isFileNameOrPatternWithError=true;
        return;
    end

    bdType=getBDType(fileAbsPath);
    if~isempty(bdType)
        fileAbsPathToBeUsed=which(fileStem);
        if isempty(fileAbsPathToBeUsed)
            filesNotInPath=[filesNotInPath,{fileStem}];
            return;
        elseif(~strcmp(fileAbsPathToBeUsed,fileAbsPath))

            DAStudio.error('Simulink:Variants:VASShadowedfile',fileAbsPath,fileAbsPathToBeUsed);
        end
        if strcmp(bdType,'Model')
            mdlFileNames=[mdlFileNames,{fileStem}];
        elseif strcmp(bdType,'Subsystem')
            ssFileNames=[ssFileNames,{fileStem}];
        end
    else
        isFileNameOrPatternWithError=true;
    end
end


