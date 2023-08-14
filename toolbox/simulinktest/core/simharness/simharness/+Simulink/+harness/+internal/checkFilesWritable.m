function checkFilesWritable(systemModel,harnessList,operation,checkHarnessFile,newNameForExport)

    if~exist('newNameForExport','var')
        newNameForExport='';
    end

    if Simulink.harness.internal.isSavedIndependently(systemModel)

        hInfoFile=Simulink.harness.internal.getHarnessInfoFileName(systemModel);
        if exist(hInfoFile,'file')
            [path,~,~]=fileparts(hInfoFile);
            [~,message,~]=fileattrib(path);
            if~message.UserWrite
                DAStudio.error('Simulink:Harness:ExternalHarnessDirNotWritable',harnessList(1).name,path);
            end

            [~,message,~]=fileattrib(hInfoFile);
            if~message.UserWrite
                DAStudio.error('Simulink:Harness:IndependentHarnessOperationFailed',operation);
            end
        end


        for i=1:length(harnessList)
            harnessStruct=harnessList(i);
            harnessFile=Simulink.harness.internal.getExternalHarnessFilePath(systemModel,harnessStruct.name);
            if exist(harnessFile,'file')
                [path,~,~]=fileparts(harnessFile);
                [~,message,~]=fileattrib(path);
                if~message.UserWrite
                    DAStudio.error('Simulink:Harness:ExternalHarnessDirNotWritable',harnessStruct.name,path);
                end
                if checkHarnessFile
                    [~,message,~]=fileattrib(harnessFile);
                    if~message.UserWrite
                        DAStudio.error('Simulink:Harness:ExternalHarnessFileNotWritable',harnessStruct.name,harnessFile);
                    end
                end
            end
        end
    end

    if strcmp(operation,'export')&&slsvTestingHook('UnifiedHarnessBackendMode')==0


        if Simulink.harness.internal.isSavedIndependently(systemModel)&&...
            isempty(newNameForExport)
            return;
        elseif isempty(newNameForExport)
            newNameForExport=fullfile(pwd,[harnessList(1).name,'.slx']);
        end

        dstFile=newNameForExport;
        if exist(dstFile,'file')==4
            dstFile=which(dstFile);
            [~,message,~]=fileattrib(dstFile);
            if~message.UserWrite
                DAStudio.error('Simulink:LoadSave:FileNotWritable',dstFile);
            else
                return;
            end
        else
            [path,~,~]=fileparts(dstFile);
            if isempty(path)
                path=pwd;
            end
            [~,message,~]=fileattrib(path);
            if~message.UserWrite
                DAStudio.error('Simulink:LoadSave:FileNotWritable',dstFile);
            end
        end
    end
end
