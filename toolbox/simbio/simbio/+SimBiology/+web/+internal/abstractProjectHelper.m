classdef abstractProjectHelper<handle











    properties
        errors={};
        warnings={};
        infos={};
    end

    methods
        function addError(obj,errorMsg,varargin)
            if nargin>2
                ex=varargin{1};
                errorMsg=sprintf('%s: %s',errorMsg,SimBiology.web.internal.errortranslator(ex));
            end

            obj.errors{end+1}=errorMsg;
        end

        function addWarning(obj,warningMsg)
            obj.warnings{end+1}=warningMsg;
        end

        function addInfo(obj,infoMsg)
            obj.infos{end+1}=infoMsg;
        end
    end

    methods(Access=protected)
        function backupProject(obj,projectPath,matlabRelease)
            try

                [path,projectName,ext]=fileparts(projectPath);


                backupProjectName=sprintf('%s_%s%s.backup',projectName,matlabRelease,ext);
                backupFilePath=[path,filesep,backupProjectName];







                [fid,errmsg]=fopen(backupFilePath,'w');
                if~isempty(errmsg)&&fid==-1
                    obj.addWarning(sprintf('Unable to back up the project in %s because the folder is read-only. Create a backup of the project file manually before saving the project in the app.',path));
                else
                    success=copyfile(projectPath,backupFilePath,'f');
                    if~success
                        obj.addWarning(sprintf('Unable to back up the project in %s because the folder is read-only. Create a backup of the project file manually before saving the project in the app.',path));
                    elseif~isempty(obj.warnings)||~isempty(obj.errors)
                        obj.addInfo(sprintf('SimBiology converted the project into the new project format for R%s and saved a backup of the original project in %s.',version('-release'),backupFilePath));
                    end
                    fclose(fid);
                end
            catch
                obj.addWarning('Unable to back up the project due to an exception\n. Create a backup of the project file manually before saving the project in the app.');
            end
        end
    end
end