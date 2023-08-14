
classdef TargetModelHelper<handle

    properties(SetAccess='private',GetAccess='public')
targetModelName
targetModelFile
targetModelLoadedInitially
targetModelInitialFileName
targetVersion
    end

    properties(Access='private')
backupFile
targetFileWritten
replacementModelName
initialDirty
initialLock
    end

    methods(Access='public')

        function obj=TargetModelHelper(targetFile,targetVersion)

            if isempty(targetFile)
                DAStudio.error('Simulink:ExportPrevious:NoTargetFileName');
            elseif~ischar(targetFile)&&~isstring(targetFile)
                DAStudio.error('Simulink:ExportPrevious:TargetFileNameMustBeString');
            end

            resolve_type=['save',targetVersion.format];
            obj.targetModelFile=sls_resolvename(targetFile,resolve_type);
            [~,obj.targetModelName,targetFileExtension]=slfileparts(obj.targetModelFile);


            targetVersion.checkFileExtension(targetFileExtension);
            obj.targetVersion=targetVersion;

            obj.targetModelLoadedInitially=bdIsLoaded(obj.targetModelName);
            if obj.targetModelLoadedInitially
                obj.targetModelInitialFileName=get_param(obj.targetModelName,'FileName');
            end




            [exists,attrib]=fileattrib(char(obj.targetModelFile));
            if exists&&attrib.UserWrite
                obj.backupFile=[char(obj.targetModelFile),'.bak'];
                movefile(char(obj.targetModelFile),obj.backupFile);
            end

            obj.targetFileWritten=false;
        end

        function createSnapshot(obj,sourceModelName)






            pd=Simulink.PreserveDirtyFlag(sourceModelName,'blockDiagram');%#ok<NASGU>
            if obj.targetModelLoadedInitially
                same_name_as_orig_model=strcmp(obj.targetModelName,sourceModelName);
                if same_name_as_orig_model

                    pCreateSnapshot(obj,sourceModelName);
                end
                obj.doRename;
                if~same_name_as_orig_model
                    pCreateSnapshot(obj,sourceModelName);
                end
            else
                pCreateSnapshot(obj,sourceModelName);
            end
        end

        function restoreName(obj)
            if isempty(obj.replacementModelName)
                return;
            end
            if~bdIsLoaded(obj.replacementModelName)
                return;
            end
            close_system(obj.targetModelName,0);
            w=warning('off','Simulink:Engine:MdlFileShadowing');
            restore_warning=onCleanup(@()warning(w));
            set_param(obj.replacementModelName,'Name',obj.targetModelName);
            if~isempty(obj.targetModelInitialFileName)
                slInternal('associate_with_file',obj.targetModelName,obj.targetModelInitialFileName);
            end
            set_param(obj.targetModelName,'Dirty',obj.initialDirty);
            set_param(obj.targetModelName,'Lock',obj.initialLock);
            obj.replacementModelName=[];
        end

        function restoreBackup(obj)
            if obj.targetFileWritten
                if exist(obj.targetModelFile,'file')~=0
                    delete(char(obj.targetModelFile));
                end
                obj.targetFileWritten=false;
            end
            if~isempty(obj.backupFile)&&exist(obj.backupFile,'file')~=0
                movefile(obj.backupFile,char(obj.targetModelFile));
            end
        end

        function deleteBackup(obj)
            obj.targetFileWritten=false;
            if isempty(obj.backupFile)
                return;
            end
            if exist(obj.backupFile,'file')~=0
                delete(obj.backupFile);
            end
            obj.backupFile=[];
        end

        function delete(obj)
            obj.restoreName;
            obj.restoreBackup;
        end

    end

    methods(Access='private')

        function doRename(obj)
            assert(bdIsLoaded(obj.targetModelName));



            obj.initialLock=get_param(obj.targetModelName,'Lock');
            set_param(obj.targetModelName,'Lock','off');
            [~,obj.replacementModelName]=fileparts(tempname);
            obj.replacementModelName=matlab.lang.makeValidName(...
            strcat(obj.targetModelName,'_renamed_during_export_',obj.replacementModelName));
            obj.initialDirty=get_param(obj.targetModelName,'Dirty');
            set_param(obj.targetModelName,'Name',obj.replacementModelName);
        end


        function pCreateSnapshot(obj,sourceModelName)

            [~,~,ext]=slfileparts(obj.targetModelFile);
            if strcmpi(ext,'.mdl')
                if obj.targetVersion.isR2021aOrEarlier
                    snapshot_type='snapshot_legacy_mdl';
                else
                    snapshot_type='snapshot_mdl';
                end
            else
                assert(strcmpi(ext,'.slx'));
                snapshot_type='snapshot_slx';
            end

            w=warning('off','Simulink:Engine:MdlFileShadowedByFile');
            restorewarn=onCleanup(@()warning(w));



            enc=get_param(sourceModelName,'SavedCharacterEncoding');
            if(isempty(enc)&&snapshot_type=="snapshot_mdl")||~strcmp(enc,slCharacterEncoding)
                restore_enc=onCleanup(@()set_param(sourceModelName,'SavedCharacterEncoding',enc));
                set_param(sourceModelName,'Lock','off');
                set_param(sourceModelName,'SavedCharacterEncoding',slCharacterEncoding);
            end
            slInternal(snapshot_type,sourceModelName,char(obj.targetModelFile));
            obj.targetFileWritten=true;
        end

    end





end
