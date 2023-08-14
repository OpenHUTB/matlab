



classdef TargetAdder<Simulink.ModelReference.ProtectedModel.Editor

    methods
        function obj=TargetAdder(input,varargin)
            obj=obj@Simulink.ModelReference.ProtectedModel.Editor(input,varargin{:});



            obj.validateReleaseForEdit();


            obj.Webview=false;

            obj.createSimulationReport=false;

            obj.checkIfUnprotectedModelIsAvailable();


            obj.Modes='CodeGeneration';
            obj.Report=obj.originalInformation.report;
            obj.Webview=obj.originalInformation.webview;

            obj.CallbackMgr=obj.originalInformation.callbackMgr;
            obj.ObfuscateCode=obj.originalInformation.obfuscateCode;
            obj.BinariesAndHeadersOnly=obj.originalInformation.binariesAndHeadersOnly;
            obj.AllFilesForStandaloneBuild=obj.originalInformation.allFilesForStandaloneBuild;


            obj.HasCSupport=true;
            obj.HasHDLSupport=obj.originalInformation.hasHDLSupport;


            obj.isSimEncrypted=obj.originalInformation.isSimEncrypted;
            obj.isRTWEncrypted=obj.originalInformation.isRTWEncrypted;
            obj.isViewEncrypted=obj.originalInformation.isViewEncrypted;
            obj.isModifyEncrypted=obj.originalInformation.isModifyEncrypted;
            obj.isHDLEncrypted=obj.originalInformation.isHDLEncrypted;
            obj.Encrypt=obj.isSimEncrypted||obj.isRTWEncrypted||obj.isViewEncrypted||obj.isHDLEncrypted;
        end



        function out=rebuildRequired(~,~)
            out=true;
        end






        function registerRelationships(obj)
            obj.loadModel();


            stf=get_param(obj.ModelName,'SystemTargetFile');
            [~,obj.Target]=fileparts(stf);
            if~isempty(intersect(obj.supportedTargets,obj.Target))
                DAStudio.error('Simulink:protectedModel:TargetAlreadyExistsInPackage',obj.Target,obj.protectedModelFile);
            end
            Simulink.ModelReference.ProtectedModel.CurrentTarget.set(obj.ModelName,obj.Target);

            obj.registerCodegenRelationships();
        end




        function build(obj)
            build@Simulink.ModelReference.ProtectedModel.Editor(obj);
            origRelationships=obj.originalInformation.relationships;
            gi=obj.getExtraInformation();
            gi.relationships=[origRelationships,obj.relationshipClasses];
            save('extraInformation.mat','gi');
            obj.replaceInformation();
        end




        function addRelationships(obj)
            addRelationships@Simulink.ModelReference.ProtectedModel.Creator(obj);
            obj.relationshipClasses=[obj.originalInformation.relationships,obj.relationshipClasses];
        end


        function checkExistingSLXP(~)

        end




        function checkEncryptedContents(~)

        end




        function protectedModelFile=writeToSLXP(obj)
            assert(~isempty(obj.parts)&&~isempty(obj.relationships));
            obj.addNewRelationships();
            protectedModelFile=obj.protectedModelFile;
        end




        function registerCodegenRelationships(obj)
            registerCodegenRelationships@Simulink.ModelReference.ProtectedModel.Creator(obj);
        end


        function out=getSupportedTargets(obj)
            targets=unique([keys(obj.originalInformation.targetToTargetInfoMap),{obj.Target}]);


            if length(targets)>2
                out=targets;
            else
                out=setdiff(targets,{'sim'});
            end
        end





        function regenerateRTWReports(~)

        end



        function out=addCodegenCallback(~)
            out=false;
        end


        function[protectedModelFile,neededVars]=doPostProcessAndPackage(obj)

            [protectedModelFile,neededVars]=doPostProcessAndPackage@Simulink.ModelReference.ProtectedModel.Editor(obj);%#ok<ASGLU>

            obj.regenerateReports();

            protectedModelFile=obj.protectedModelFile;
            neededVars={};
        end
    end
    methods(Access=protected)



        function checkModelConfig(obj)
            import Simulink.ModelReference.ProtectedModel.*;


            checkModelConfig@Simulink.ModelReference.ProtectedModel.Creator(obj);


            obj.IsERTTarget=strcmp(get_param(obj.ModelName,'IsERTTarget'),'on');
            obj.IsCodeInterfaceFeatureAvailable=isCodeInterfaceFeatureAvailable(obj.ModelName,obj.IsERTTarget);
            obj.setCodeInterface(obj.originalInformation.codeInterface);
        end


        function shouldContinue=showBlockingPasswordDlg(obj,~)




            shouldContinue=showBlockingPasswordDlg@Simulink.ModelReference.ProtectedModel.Creator(obj,false);
        end




        function out=hasAnyContentPassword(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            out=false;
            if obj.supportsCodeGen()&&obj.isRTWEncrypted
                if PasswordManager.doesEncryptionCategoryHaveTheRightPassword(obj.ModelName,'RTW')

                    out=true;
                elseif~isempty(PasswordManager.getPasswordForEncryptionCategory(obj.ModelName,'RTW'))

                    throwWrongPasswordExceptionWithHyperlink(obj.ModelName,['\n',getStringForEncryptionCategory('RTW')]);
                else

                    out=false;
                end
            end
        end
    end
end


