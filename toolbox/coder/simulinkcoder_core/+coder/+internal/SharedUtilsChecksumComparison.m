classdef SharedUtilsChecksumComparison<handle






    properties


        DifferencesExist=false;




        SharedUtilsFolderConflict=false;
    end

    properties(Access=private)
        ModelName;
        BaselineName;

        ModelUtils;
        BaselineUtils;

        Differences;

        Messages=message.empty;
    end

    methods





        function this=SharedUtilsChecksumComparison(modelName,baselineName,modelUtils,baselineUtils)

            this.ModelName=modelName;
            this.BaselineName=baselineName;

            this.ModelUtils=modelUtils;
            this.BaselineUtils=baselineUtils;

            this.Compare();
        end




        function addSolutionMessege(this,messageID,varargin)
            this.Messages(end+1)=message(messageID,varargin{:});
        end



        function throwError(this,messageID,varargin)

            err=coder.internal.SharedUtilsException(messageID,...
            this.ModelName,...
            this.BaselineName,...
            this.ModelUtils.targetInfoStruct,...
            this.BaselineUtils.targetInfoStruct,...
            this.Differences,...
            this.Messages,...
            varargin{:});
            throwAsCaller(err);
        end
    end

    methods(Access=private)



        function Compare(this)


            differentFields=coder.internal.compareStructures(this.ModelUtils.targetInfoStruct,this.BaselineUtils.targetInfoStruct);
            differentSharedUtilFolders=false;

            if~isempty(differentFields)


                if any(strcmp('CodeCoverageChecksum',differentFields))
                    differentFields=setdiff(differentFields,{'CodeCoverageChecksum'});
                end

                if Simulink.filegen.CodeGenFolderStructure.isSelected('TargetEnvironmentSubfolder')&&...
                    any(strcmp('TargetHWDeviceType',differentFields))
                    differentSharedUtilFolders=true;
                end
            end


            this.DifferencesExist=~isempty(differentFields);
            this.SharedUtilsFolderConflict=this.DifferencesExist&&~differentSharedUtilFolders;
            this.Differences=differentFields;
        end
    end
end

