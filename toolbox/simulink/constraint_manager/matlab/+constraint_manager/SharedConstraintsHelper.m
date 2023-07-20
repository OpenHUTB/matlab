classdef SharedConstraintsHelper

    properties(Constant)
        SupportedSharedConstraints=['Simulink.Mask.Constraints'];
    end

    methods(Static)

        function[sharedConstraintList,matFileName]=loadMATFileConstraints(matFileName)
            sharedConstraintList={};
            if~contains(matFileName,'.mat')
                matFileName=strcat(matFileName,'.mat');
            end
            if exist(matFileName,'file')
                constraintList=load(matFileName);
                fields=fieldnames(constraintList);
                absMatFileName=which(matFileName);
                matFileName=erase(matFileName,'.mat');
                for ii=1:numel(fields)
                    constraintObj=constraintList.(fields{ii});
                    if(constraint_manager.SharedConstraintsHelper.isSharedConstraintSupported(constraintObj))
                        sharedConstraintList{end+1}=constraintObj;
                    end
                end
                clear constraintList;
            else
                warningMsg=DAStudio.message('Simulink:Masking:CannotLoadMATFileWhichIsNotInMatLABPath',matFileName);
                warndlg(warningMsg);
            end
        end

        function isSupported=isSharedConstraintSupported(constraintObj)
            isSupported=false;
            if any(constraint_manager.SharedConstraintsHelper.SupportedSharedConstraints==class(constraintObj))
                isSupported=true;
            end
        end


        function deleteAllConstraintFromMATFile(constraintListFromMatFile)
            constraintFieldNames=fieldnames(constraintListFromMatFile);
            for index=1:numel(constraintFieldNames)
                fieldname=constraintFieldNames{index};
                constraintListFromMatFile=rmfield(constraintListFromMatFile,fieldname);
            end
        end


        function[warnings]=saveAllSharedConstraintsToMATFile(MATFilesModelObjects)
            warnings={};
            for i=1:MATFilesModelObjects.Size
                MATFileObject=MATFilesModelObjects(i);
                context=MATFileObject.context;
                matFileName=context.matfilename;
                matFilePath=context.matfilepath;

                constraintListStruct=struct;
                if~contains(matFilePath,'.mat')
                    matFilePath=strcat(matFilePath,'.mat');
                end







                errorMsg=constraint_manager.SharedConstraintsHelper.showErrorIfMATFilePathNotPresentInMatlabPath(matFilePath);
                if~isempty(errorMsg)
                    matFileParts=string(matFilePath).split(filesep);
                    matFilePathWithoutFileName=join(matFileParts(1:end-1),filesep);
                    warningMsg=DAStudio.message('Simulink:Masking:MatFileLocationIsNotPresentInMatLABPath',matFilePathWithoutFileName,matFileName);
                    warnings{end+1}=warningMsg;
                end

                bMATFileExist=exist(matFilePath,'file');
                if(bMATFileExist)
                    constraintListFromMatFile=load(matFilePath);
                    constraint_manager.SharedConstraintsHelper.deleteAllConstraintFromMATFile(constraintListFromMatFile);
                end

                constraintListFromModel=MATFileObject.matFileConstraints;
                for index=1:constraintListFromModel.Size
                    constraintModelObj=constraintListFromModel(index);
                    constraintName=constraintModelObj.name;
                    hConstraintObj=constraint_manager.ModelUtils.createParameterConstraintObject(constraintModelObj);


                    constraintListStruct.(constraintName)=hConstraintObj;
                end


                try
                    save(matFilePath,'-struct','constraintListStruct');
                catch errorMsg
                    errordlg(errorMsg.message)
                end
            end
        end

        function deleteMATFile(matFilePath)
            delete(matFilePath);
        end


        function absMatFileName=GetAbsMatFileName(matFileName)
            absMatFileName=which(matFileName);
            matFileLocation=fileparts(matFileName);
            if isempty(absMatFileName)&&~isempty(matFileLocation)
                absMatFileName=matFileName;
            end

            if isempty(absMatFileName)
                absMatFileName=strcat(pwd,filesep,matFileName);
            end
        end

        function errorMsg=showErrorIfMATFilePathNotPresentInMatlabPath(matFileName)
            errorMsg='';
            if strcmp(fileparts(matFileName),pwd)
                return;
            end


            pathCell=regexp(path,pathsep,'split');
            [constraintPath,tempMatFielName,extension]=fileparts(matFileName);
            if~isempty(constraintPath)
                if ispc
                    isPresentOnPath=any(strcmpi(constraintPath,pathCell));
                else
                    isPresentOnPath=any(strcmp(constraintPath,pathCell));
                end

                if~isPresentOnPath
                    errorMsg=DAStudio.message('Simulink:Masking:MatFileLocationIsNotPresentInMatLABPath',...
                    constraintPath,strcat(tempMatFielName,extension));
                    return;
                end
            end
        end
    end
end

