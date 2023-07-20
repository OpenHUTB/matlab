function validatedFullFileName=getValidatedTaskFile(inputFile)





    fileExtension='.m';


    validatedFileName=matlab.internal.task.metadata.getValidatedFile(inputFile,fileExtension);


    [success,fileInfo,~]=fileattrib(validatedFileName);
    if success
        validatedFullFileName=matlab.internal.task.metadata.normalizeFullFileName(fileInfo.Name,fileExtension);
    else
        error(message('rich_text_component:liveApps:InvalidFileName',validatedFileName));
    end


    if contains(validatedFullFileName,[filesep,'private',filesep])
        error(message('rich_text_component:liveApps:FileInPrivateFolder'));
    end


    try
        isCustomTask=isCustomTaskFile(validatedFullFileName);
    catch exception
        newException=MException(message('rich_text_component:liveApps:NotValidTaskClass',...
        validatedFullFileName));
        newException=addCause(newException,exception);
        throw(newException);
    end

    if~isCustomTask
        error(message('rich_text_component:liveApps:NotTaskClass',...
        validatedFullFileName,'matlab.task.LiveTask'));
    end
end

function isCustomTask=isCustomTaskFile(fullFilePath)


    [canidateFilePath,candidateClassName]=packageFileParts(fullFilePath);



    currentDir=pwd;
    cd(canidateFilePath);
    c=onCleanup(@()cd(currentDir));


    isCustomTask=isCustomTaskFromMetaClass(candidateClassName);
end

function[packageRoot,packageName]=packageFileParts(file)



    [filePath,name]=fileparts(file);

    if contains(filePath,'+')
        packageRoot=strip(strtok(filePath,'+'),'right',filesep);
        packageName=strsplit(filePath,'+');
        packageName=strtok(packageName(2:end),filesep);
        packageName=[packageName,name];
        packageName=strjoin(packageName,'.');
    else
        packageRoot=filePath;
        packageName=name;
    end

end

function isCustomTask=isCustomTaskFromMetaClass(className,parentSuperClasses)


    isCustomTask=false;



    if nargin<2
        parentSuperClasses={};
    end


    mc=meta.class.fromName(className);
    superClasses=mc.SuperclassList;
    usertaskBaseClasses={'matlab.task.LiveTask'};

    for k=1:numel(superClasses)
        if ismember(superClasses(k).Name,usertaskBaseClasses)
            isCustomTask=true;
            return;
        end
    end

    for k=1:numel(superClasses)
        superClassName=superClasses(k).Name;


        if ismember(superClassName,parentSuperClasses)||exist(superClassName,'builtin')
            continue;
        end


        isSuperUICompnent=isCustomTaskFromMetaClass(superClasses(k).Name,[parentSuperClasses,superClasses.Name]);
        if(isSuperUICompnent)
            isCustomTask=true;
            return;
        end
    end
end