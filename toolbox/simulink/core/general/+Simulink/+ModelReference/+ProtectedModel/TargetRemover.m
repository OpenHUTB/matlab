



classdef TargetRemover<Simulink.ModelReference.ProtectedModel.Editor
    properties
        TargetToRemove='';
    end

    methods
        function obj=TargetRemover(input,targetToBeRemoved,varargin)
            import Simulink.ModelReference.ProtectedModel.*;

            obj=obj@Simulink.ModelReference.ProtectedModel.Editor(input,varargin{:});

            obj.Webview=obj.originalInformation.webview;

            obj.createSimulationReport=true;


            obj.TargetToRemove=targetToBeRemoved;
            if~ischar(targetToBeRemoved)
                DAStudio.error('Simulink:protectedModel:InvalidTargetName');
            elseif~supportsCodeGen(obj.originalInformation)
                DAStudio.error('Simulink:protectedModel:ModelDoesNotSupportCodeGeneration',targetToBeRemoved,obj.protectedModelFile);
            elseif strcmp(targetToBeRemoved,'sim')
                DAStudio.error('Simulink:protectedModel:ProtectedModelCannotRemoveNonCodegenTargets');
            elseif isempty(intersect(getSupportedTargets(obj.protectedModelFile),targetToBeRemoved))
                DAStudio.error('Simulink:protectedModel:TargetNotFoundInPackage',targetToBeRemoved,obj.protectedModelFile);
            elseif length(obj.originalInformation.targetToTargetInfoMap)==2&&...
                isKey(obj.originalInformation.targetToTargetInfoMap,obj.TargetToRemove)



                obj.Modes='Accelerator';
                obj.isRTWEncrypted=false;
            else
                obj.Modes=obj.originalInformation.modes;
                obj.isRTWEncrypted=obj.originalInformation.isRTWEncrypted;
            end



            obj.validateReleaseForEdit();

            obj.CallbackMgr=obj.originalInformation.callbackMgr;
            obj.Report=obj.originalInformation.report;
            obj.Webview=obj.originalInformation.webview;
            obj.ObfuscateCode=obj.originalInformation.obfuscateCode;
            obj.BinariesAndHeadersOnly=obj.originalInformation.binariesAndHeadersOnly;
            obj.AllFilesForStandaloneBuild=obj.originalInformation.allFilesForStandaloneBuild;


            obj.isSimEncrypted=obj.originalInformation.isSimEncrypted;
            obj.isViewEncrypted=obj.originalInformation.isViewEncrypted;
            obj.isModifyEncrypted=obj.originalInformation.isModifyEncrypted;

        end



        function out=rebuildRequired(~,~)
            out=false;
        end


        function[addedIdx,removedIdx]=detectChanges(obj)

            relationships={};
            remainder={};
            opts=obj.originalInformation;
            targetsuffix=['_',obj.TargetToRemove];
            for i=1:length(opts.relationships)
                currentRelName=opts.relationships{i}.RelationshipName;

                if strfind(currentRelName,targetsuffix)==(length(currentRelName)-length(targetsuffix)+1)


                    relationships{end+1}=opts.relationships{i};%#ok<AGROW>
                elseif strcmp(currentRelName,obj.TargetToRemove)
                    relationships{end+1}=opts.relationships{i};%#ok<AGROW>
                elseif strcmp(currentRelName,'codegenCallback')&&~obj.supportsCodeGen()


                    relationships{end+1}=opts.relationships{i};%#ok<AGROW>
                else
                    remainder{end+1}=opts.relationships{i};%#ok<AGROW>
                end
            end
            obj.relationshipClasses=remainder;

            originalRelationshipsName=cell(1,length(opts.relationships));
            for i=1:length(opts.relationships)
                originalRelationshipsName{i}=opts.relationships{i}.RelationshipName;
            end

            removedRelationshipsName=cell(1,length(relationships));
            for i=1:length(relationships)
                removedRelationshipsName{i}=relationships{i}.RelationshipName;
            end

            addedIdx=0;
            [~,removedIdx]=ismember(originalRelationshipsName,removedRelationshipsName);
        end


        function out=getExtraInformation(obj)
            import Simulink.ModelReference.ProtectedModel.*;

            info=obj.originalInformation;
            if strcmp(obj.Modes,'Accelerator')


                assert(length(info.targetToTargetInfoMap)==2,...
                'Property "Modes" is set incorrectly');

                if isKey(info.targetToTargetInfoMap,obj.TargetToRemove)
                    info.targetToTargetInfoMap.remove(obj.TargetToRemove);
                    info.updateImplOnlyInformation(obj);
                end
                obj.Target='sim';
            else
                info.targetToTargetInfoMap.remove(obj.TargetToRemove);
                info.updateImplOnlyInformation(obj);



                if strcmp(getCurrentTarget(obj.ModelName),obj.TargetToRemove)

                    assert(length(info.targetToTargetInfoMap)>=1,...
                    'Not enough targets remaining');

                    allKeys=keys(info.targetToTargetInfoMap);
                    obj.Target=allKeys{1};
                    setCurrentTarget(obj.ModelName,obj.Target);
                end
            end
            out=info;
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


        function[protectedModelFile,neededVars]=doPostProcessAndPackage(obj)

            [protectedModelFile,neededVars]=doPostProcessAndPackage@Simulink.ModelReference.ProtectedModel.Editor(obj);%#ok<ASGLU>

            obj.regenerateReports();

            protectedModelFile=obj.protectedModelFile;
            neededVars={};
        end

    end
    methods(Access=protected)


        function shouldContinue=showBlockingPasswordDlg(obj,~)




            shouldContinue=showBlockingPasswordDlg@Simulink.ModelReference.ProtectedModel.Creator(obj,false);
        end
    end
end


