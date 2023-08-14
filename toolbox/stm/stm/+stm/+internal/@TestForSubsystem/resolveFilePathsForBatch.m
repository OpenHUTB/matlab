function resolveFilePathsForBatch(obj)

































    if~isempty(obj.dataLocation)&&isempty(obj.location1)&&isempty(obj.location2)
        if obj.isExcel
            obj.location1=obj.dataLocation;
            obj.location2='';
        else
            obj.location1=obj.dataLocation;
            obj.location2=obj.dataLocation;
        end
    end

    [parentPath1,partName1,~]=fileparts(obj.location1);
    if~(obj.location1==""||isfolder(obj.location1))
        error(message("stm:TestForSubsystem:NonExistingDataLocationDir"));
    end

    if isempty(parentPath1)
        parentPath1=pwd;
    end

    obj.location1=strings(obj.numOfComps,1);
    sheetNames=obj.location2;
    obj.location2=strings(obj.numOfComps,1);

    if obj.isExcel
        fullpath=fullfile(parentPath1,partName1);
        partName1=getString(message('stm:TestFromModelComponents:DataFileOptionsStep_DefaultLoc',obj.topModel));

        fullpath=helperCreateUniqueFolder(fullpath,partName1);
        for i=1:obj.numOfComps

            cutName=stm.internal.TestForSubsystem.getComponentName(obj.subsys(i));
            f=helperCreateUniqueFolder(fullpath,cutName);


            obj.location1(i)=helperCreateUniqueFileName(f,getExcelFileName(cutName),'.xlsx');
        end
        if isempty(sheetNames)
            sheetNames=getString(message('stm:TestForSubsystem:DefaultSheetName'));
        end
        obj.location2(:)=sheetNames;
    else
        assert(sheetNames==""||isfolder(sheetNames));
        [parentPath2,partName2,~]=fileparts(sheetNames);
        if isempty(parentPath2)
            parentPath2=pwd;
        end
        fullpath1=fullfile(parentPath1,partName1);
        earlierFullPath=fullpath1;
        partName1=getString(message('stm:TestFromModelComponents:DataFileOptionsStep_DefaultLoc',obj.topModel));

        fullpath1=helperCreateUniqueFolder(fullpath1,partName1);
        fullpath2=fullfile(parentPath2,partName2);


        createInputsNBaselineInSameDir=strcmp(fullpath2,earlierFullPath);
        if createInputsNBaselineInSameDir
            fullpath2=fullpath1;
        else
            partName2=getString(message('stm:TestFromModelComponents:DataFileOptionsStep_DefaultLoc',obj.topModel));
            fullpath2=helperCreateUniqueFolder(fullpath2,partName2);
        end
        for i=1:obj.numOfComps
            cutName=stm.internal.TestForSubsystem.getComponentName(obj.subsys(i));

            f=helperCreateUniqueFolder(fullpath1,cutName);

            obj.location1(i)=fullfile(f,getInputsFileName(cutName));
        end
        for i=1:obj.numOfComps


            cutName=stm.internal.TestForSubsystem.getComponentName(obj.subsys(i));
            if~createInputsNBaselineInSameDir
                f=helperCreateUniqueFolder(fullpath2,cutName);
            else
                [f,~,~]=fileparts(obj.location1(i));
            end


            obj.location2(i)=fullfile(f,getBaseLineFileName(cutName));
        end
    end
end

function baselineFileName=getBaseLineFileName(cut)
    baselineFileName=[cut,'_baseline','.mat'];
end

function inputsFileName=getInputsFileName(cut)
    inputsFileName=[cut,'_inputs','.mat'];
end


function excelFileName=getExcelFileName(cut)
    excelFileName=getString(message('stm:TestFromModelComponents:DataFileOptionsStep_DefaultLoc',cut));
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


