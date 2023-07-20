function resolveFilePaths(obj,testfileFolder,createFolderForExcel)%#ok<INUSD> 
















    if~exist(obj.testfileLocation,'file')
        error(message('stm:general:InvalidTestFileLocation'));
    end

    if obj.testType~=sltest.testmanager.TestCaseTypes.Baseline&&~obj.isExcel&&obj.location2~=""
        warning(message('stm:general:BaselineFileForNonBaselineTest'));
    end

    if isstring(obj.location1)
        obj.location1=obj.location1.char;
    end

    if isstring(obj.location2)
        obj.location2=obj.location2.char;
    end

    if isstring(obj.dataLocation)
        obj.dataLocation=obj.dataLocation.char;
    end






    if obj.isInBatchMode
        obj.resolveFilePathsForBatch();
        return;
    end








    pathToUse='';
    if obj.isUIMode
        pathToUse=obj.dataLocation;
    else
        pathToUse=obj.location1;
    end


    if isempty(pathToUse)
        partName=getString(message('stm:TestFromModelComponents:DataFileOptionsStep_DefaultLoc',...
        stm.internal.TestForSubsystem.getComponentName(obj.subsys)));
        parentPath=pwd;

        if obj.isExcel

            obj.location1=helperCreateUniqueFileName(parentPath,partName,'.xlsx');
        else

            partName=getString(message('stm:TestFromModelComponents:DataFileOptionsStep_DefaultLoc',...
            obj.topModel));
            fullFilePath=helperCreateUniqueFolder(parentPath,partName);
        end
    else

        fullFilePath=pathToUse;
        [parentPath,partName,ext]=fileparts(fullFilePath);
        if isempty(parentPath)
            parentPath=pwd;
        end
        if obj.isExcel
            obj.location1=fullfile(parentPath,[partName,ext]);


        else
            fullFilePath=fullfile(parentPath,partName);
            if exist(fullFilePath,'dir')==0
                fullFilePath=helperCreateUniqueFolder(parentPath,partName);
            end
        end
    end


    if obj.isExcel
        if isempty(obj.location1)

            obj.location1=helperCreateUniqueFileName(fullFilePath,getExcelFileName(stm.internal.TestForSubsystem.getComponentName(obj.subsys)),'.xlsx');
        else

            [~,obj.location1]=stm.internal.resolveFilePath(obj.location1,...
            getString(message('stm:CriteriaView:ExcelFormat')));
        end


        if isempty(obj.location2)
            obj.location2=getString(message('stm:TestForSubsystem:DefaultSheetName'));
        end
    else
        if isempty(obj.location1)

            obj.location1=fullfile(fullFilePath,getInputsFileName(stm.internal.TestForSubsystem.getComponentName(obj.subsys)));
        else

            [bExist,obj.location1]=stm.internal.resolveFilePath(obj.location1,...
            getString(message('stm:CriteriaView:MatFormat')));


            if bExist
                error(message('stm:general:InputsFileAlreadyExists',obj.location1));
            end
        end


        if isempty(obj.location2)

            obj.location2=fullfile(fullFilePath,getBaseLineFileName(stm.internal.TestForSubsystem.getComponentName(obj.subsys)));
        else

            [bExist,obj.location2]=stm.internal.resolveFilePath(obj.location2,...
            getString(message('stm:CriteriaView:MatFormat')));


            if bExist
                error(message('stm:general:BaselineFileAlreadyExists',obj.location2));
            end
        end
    end
    obj.location1=string(obj.location1);
    obj.location2=string(obj.location2);
end

function baselineFileName=getBaseLineFileName(cutName)
    baselineFileName=[cutName,'_baseline','.mat'];
end

function inputsFileName=getInputsFileName(cutName)
    inputsFileName=[cutName,'_inputs','.mat'];
end


function excelFileName=getExcelFileName(model)
    excelFileName=getString(message('stm:TestFromModelComponents:DataFileOptionsStep_DefaultLoc',model));
end

function fullFilePath=helperCreateUniqueFolder(parentDir,folderName)

    folderName=regexprep(folderName,'\n+','');
    [bSuccess,fullFilePath]=stm.internal.util.createAnUniqueFolder(parentDir,folderName);
    if~bSuccess
        error(message('stm:general:FailedToCreateDirectory',fullFilePath));
    end
end

function uniqueFilePath=helperCreateUniqueFileName(parentPath,fileName,ext)
    idx=1;
    tmpFileName=fileName;
    while(1)
        uniqueFilePath=fullfile(parentPath,[tmpFileName,ext]);
        if(exist(uniqueFilePath,'file')>0)
            tmpFileName=[fileName,num2str(idx)];
            idx=idx+1;
        else
            break;
        end
    end
end


