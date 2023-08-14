




classdef Editor<Simulink.ModelReference.ProtectedModel.Creator
    properties
        waitBarHandle;
        originalInformation;
        protectedModelFile;
        unprotectedModelFile;
        rebuilt=false;
        removedIdx;
        protectCleanup;
        supportedTargets;

        simPasswords={};
        cgPasswords={};
        viewPasswords={};

        origWarnStatus;

    end

    methods
        function obj=Editor(input,varargin)
            import Simulink.ModelReference.ProtectedModel.*;



            obj=obj@Simulink.ModelReference.ProtectedModel.Creator(input,varargin{:});
            obj.supportedTargets=keys(obj.originalInformation.targetToTargetInfoMap);




            obj.ModelName=obj.originalInformation.modelName;



            if~obj.originalInformation.isModifyEncrypted
                DAStudio.error('Simulink:protectedModel:ProtectedModelNoModifySupport',obj.ModelName);
            end
            obj.isModifyEncrypted=true;
            hasCorrectModifyPassword=PasswordManager.doesEncryptionCategoryHaveTheRightPassword(obj.ModelName,'MODIFY');
            if obj.hasModifyPassword()&&~hasCorrectModifyPassword



                throwWrongPasswordExceptionWithHyperlink(obj.ModelName,'MODIFY');
            end
        end






        function getPropertiesFromModel(obj,name)
            import Simulink.ModelReference.ProtectedModel.*;

            if(isempty(strfind(name,'/')))
                obj.ModelName=name;
            else
                obj.parentModel=bdroot(name);
                obj.ModelName=get_param(name,'ModelName');
            end

            [isProtected,fullName]=slInternal('getReferencedModelFileInformation',obj.ModelName);
            if isempty(fullName)
                DAStudio.error('Simulink:protectedModel:ModelFileNotFound',obj.ModelName);
            elseif~isProtected
                DAStudio.error('Simulink:protectedModel:ModelIsNotProtected',obj.ModelName);
            end

            obj.protectedModelFile=fullName;
            obj.originalInformation=Simulink.ModelReference.ProtectedModel.getOptions(fullName);
            obj.SubModels=obj.originalInformation.subModels;
            obj.SubModelsWithFile={obj.ModelName};
            obj.IsERTTarget=obj.originalInformation.isERTTarget;
            obj.HasSILSupport=obj.originalInformation.hasSILSupport;
            obj.HasPILSupport=obj.originalInformation.hasPILSupport;
            obj.CodeInterface=obj.originalInformation.codeInterface;
            obj.IsCodeInterfaceFeatureAvailable=isCodeInterfaceFeatureAvailable(obj.ModelName,obj.IsERTTarget);
            obj.Target=getCurrentTarget(obj.ModelName);
            obj.wasLoaded=false;
        end






        function registerCodegenRelationships(obj)
            import Simulink.ModelReference.ProtectedModel.*;

            codegenTargets=obj.getCodeGenTargets();
            ct=obj.Target;
            oc=onCleanup(@()obj.setTarget(ct));
            for i=1:length(codegenTargets)
                obj.Target=codegenTargets{i};
                registerCodegenRelationships@Simulink.ModelReference.ProtectedModel.Creator(obj);
            end
        end

        function setTarget(obj,target)
            obj.Target=target;
        end





        function[harnessHandle]=doProtectSetup(obj)
            if obj.rebuilt
                doProtectSetup@Simulink.ModelReference.ProtectedModel.Creator(obj);
            else
                harnessHandle=0;


                obj.updateProgress(5,'ProtectedModelPhaseCheck');


                if~slfeature('ProtectedModelRemoveSimulinkCoderCheck')&&...
                    ~obj.getSupportsHDL()
                    obj.doLicenseCheckRTW();
                end

                slprivate('checkWritableDirectory',obj.ZipPath);



                slInternal('runConsistencyChecks',obj.protectedModelFile);
            end
        end






        function build(obj)


            [addedIdx,obj.removedIdx]=obj.detectChanges();


            if obj.rebuildRequired(addedIdx)

                obj.queryRebuild();


                obj.checkIfUnprotectedModelIsAvailable()


                obj.rebuilt=true;

                obj.doProtectSetup();


                obj.IsERTTarget=get_param(obj.ModelName,'IsERTTarget');

                obj.cacheCreatorInBlockDiagram();
                oc=onCleanup(@()obj.clearCreatorFromBlockDiagram());


                build@Simulink.ModelReference.ProtectedModel.Creator(obj);
            else

                obj.MapFromModelNameToBuildDir=obj.getModelNameAndBuildDirMap();
            end
        end


        function loadModel(obj)
            if isempty(obj.origWarnStatus)
                obj.origWarnStatus=warning('query','Simulink:Engine:MdlFileShadowedByFile');
                warning('off','Simulink:Engine:MdlFileShadowedByFile');
                obj.wasLoaded=bdIsLoaded(obj.ModelName);
                load_system(obj.unprotectedModelFile);
            end
        end




        function[protectedModelFile,neededVars]=doPostProcessAndPackage(obj)
            if obj.rebuilt
                [protectedModelFile,neededVars]=doPostProcessAndPackage@Simulink.ModelReference.ProtectedModel.Creator(obj);
                clear obj.protectCleanup;
            else
                originalRelationships=obj.originalInformation.relationships;
                if~rtw.report.ReportInfo.featureReportV2
                    try
                        obj.deleteOriginalRelationships(obj.removedIdx,originalRelationships);
                    catch
                    end
                end




                obj.updateInformationAfterDeletion(obj.getExtraInformation());





                obj.regenerateReports();

                protectedModelFile=obj.protectedModelFile;
                neededVars={};
            end
        end


        function regenerateReports(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            if obj.Report
                obj.regenerateSimReport();



                if obj.supportsCodeGen()
                    obj.regenerateRTWReports();
                end
            end
        end


        function regenerateRTWReports(obj)
            import Simulink.ModelReference.ProtectedModel.*;

            rootRTWDir=getRTWBuildDir();
            for i=1:length(obj.supportedTargets)
                currentTarget=obj.supportedTargets{i};
                if strcmp(currentTarget,'sim')
                    continue;
                end
                setCurrentTarget(obj.ModelName,currentTarget);


                buildDirs=RTW.getBuildDir(obj.ModelName);

                dstDir=fullfile(rootRTWDir,buildDirs.ModelRefRelativeBuildDir);
                unpackReportCodegenSummary(obj.protectedModelFile,dstDir,currentTarget);
                obj.updateProtectedModelReport(dstDir);
                obj.repackageReport(dstDir,'Simulink.ModelReference.common.RelationshipReportCodegenSummary');
            end
        end


        function regenerateSimReport(obj)
            import Simulink.ModelReference.ProtectedModel.*;



            currentM=obj.currentMode;
            cmRestore=onCleanup(@()obj.restoreCurrentMode(currentM));



            obj.currentMode='SIM';
            buildDirs=RTW.getBuildDir(obj.ModelName);


            if slsvTestingHook('ProtectedModelCleanupTest')
                rootSimDir=getSimBuildDir();
            else
                rootSimDir=tempname;
            end
            dstDir=fullfile(rootSimDir,buildDirs.ModelRefRelativeSimDir);
            unpackReportSummary(obj.protectedModelFile,dstDir);
            obj.updateProtectedModelReport(dstDir);
            obj.repackageReport(dstDir,'Simulink.ModelReference.common.RelationshipReportSummary');
        end


        function repackageReport(obj,dstDir,relName)
            import Simulink.ModelReference.ProtectedModel.*;


            srcDir=cd(fullfile(dstDir,'..','..','..'));
            oc=onCleanup(@()cd(srcDir));
            dstDir=rtwprivate('rtw_relativize',dstDir,pwd);

            relationships=obj.originalInformation.relationships;
            reportRelationshipSummary=[];
            for i=1:length(relationships)
                if isa(relationships{i},relName)
                    reportRelationshipSummary=relationships{i};
                    break;
                end
            end
            assert(~isempty(reportRelationshipSummary));


            relName=reportRelationshipSummary.RelationshipName;
            relYear=reportRelationshipSummary.getRelationshipYear();
            slInternal('deletePartsInRelationship',obj.protectedModelFile,relName,relYear,obj);


            obj.parts=[];
            obj.relationships=[];
            reportRelationshipSummary.populateFromBuildDir(obj,dstDir);
            reportRelationshipSummary.PartsMap=containers.Map;
            reportRelationshipSummary.addRelationship(obj);
            slInternal('addRelationshipsAndParts',obj.protectedModelFile,obj.parts,obj.relationships,obj);
        end


        function out=getBuildDir(~,modelName)
            out=RTW.getBuildDir(modelName);
        end


        function rpt=updateProtectedModelReport(obj,dstDir)

            rpt=rtw.report.getReportInfo(obj.ModelName,dstDir);


            rpt.setBuildDir(dstDir);
            rpt.ModelName=obj.ModelName;
            rpt.ProtectedMdl=obj;



            if~isempty(rpt)
                rpt.initProtectedModelReport(obj);
                pages=rpt.Pages;
                rpt.Pages={rpt.Summary};
                rpt.emitPages();
                rpt.Pages=pages;
            end
        end


        function out=getReportInfo(obj)
            if obj.rebuilt
                out=getReportInfo@Simulink.ModelReference.ProtectedModel.Creator(obj);
            else
                out=rtw.report.ReportInfo.loadMat(obj.ModelName);
            end
        end





        function[addedIdx,removedIdx]=detectChanges(obj)



            originalRelationships=obj.originalInformation.relationships;
            newRelationships=obj.relationshipClasses;

            originalRelationshipsName=cell(1,length(originalRelationships));
            for i=1:length(originalRelationships)
                originalRelationshipsName{i}=originalRelationships{i}.RelationshipName;
            end

            newRelationshipsName=cell(1,length(newRelationships));
            for i=1:length(newRelationships)
                newRelationshipsName{i}=newRelationships{i}.RelationshipName;
            end


            addedRelationshipsName=setdiff(newRelationshipsName,originalRelationshipsName);
            removedRelationshipsName=setdiff(originalRelationshipsName,newRelationshipsName);

            [~,addedIdx]=ismember(newRelationshipsName,addedRelationshipsName);
            [~,removedIdx]=ismember(originalRelationshipsName,removedRelationshipsName);
        end




        function gi=updateEncryptionStatus(obj,gi)
            import Simulink.ModelReference.ProtectedModel.*;


            gi.isSimEncrypted=false;
            gi.isRTWEncrypted=false;
            gi.isViewEncrypted=false;
            gi.isModifyEncrypted=obj.originalInformation.isModifyEncrypted;


            for i=1:length(obj.relationshipClasses)
                currentRelationship=obj.relationshipClasses{i};
                if currentRelationship.isEncrypted
                    cat=currentRelationship.getEncryptionCategory();
                    switch cat
                    case 'SIM'
                        gi.isSimEncrypted=true;
                    case 'RTW'
                        gi.isRTWEncrypted=true;
                    case 'VIEW'
                        gi.isViewEncrypted=true;
                    end
                end
            end


            eifile='extraInformation.mat';
            save(eifile,'gi');
        end






        function queryRebuild(obj)
            if obj.guiEntry
                choice=questdlg(DAStudio.message('Simulink:protectedModel:ProtectedModelEditQueryRebuildMsg',obj.ModelName),...
                DAStudio.message('Simulink:protectedModel:ProtectedModelEditQueryRebuildTitle'),...
                DAStudio.message('Simulink:protectedModel:ProtectedModelEditQueryRebuildOKButton'),...
                DAStudio.message('Simulink:protectedModel:ProtectedModelEditQueryRebuildCancelButton'),...
                DAStudio.message('Simulink:protectedModel:ProtectedModelEditQueryRebuildOKButton'));


                if strcmp(choice,DAStudio.message('Simulink:protectedModel:ProtectedModelEditQueryRebuildCancelButton'))
                    DAStudio.error('Simulink:protectedModel:ProtectedModelEditBuildCanceledError',obj.ModelName);
                end
            end
        end






        function checkIfUnprotectedModelIsAvailable(obj)

            modelName=obj.getDefaultUnprotectedFile(obj.ModelName);
            if~isempty(modelName)
                obj.unprotectedModelFile=modelName;
            else

                [~,fullName]=slInternal('getReferencedModelFileInformation',obj.ModelName);
                DAStudio.error('Simulink:protectedModel:ProtectedModelNoUnprotectedFileError',obj.ModelName,fullName);
            end
        end


        function checkExistingSLXP(obj)


            filesOnPath=which('-all',[obj.ModelName,'.slxp']);
            currentPath=pwd;



            if length(filesOnPath)>=1
                for i=1:length(filesOnPath)
                    [fpath,~,~]=fileparts(filesOnPath{i});
                    if strcmp(fpath,currentPath)
                        delete(filesOnPath{i});
                    end
                end
            end
        end




        function deleteOriginalRelationships(obj,removedIdx,originalRelationships)
            import Simulink.ModelReference.ProtectedModel.*;
            for i=1:length(removedIdx)
                if removedIdx(i)==0
                    continue;
                end
                relName=originalRelationships{i}.RelationshipName;
                relYear=originalRelationships{i}.getRelationshipYear();
                slInternal('deletePartsInRelationship',obj.protectedModelFile,relName,relYear,obj);
            end
        end




        function addNewRelationships(obj)
            assert(length(obj.parts)==length(obj.relationships));





            i=1;
            while i<=length(obj.parts)
                if strcmp(obj.relationships(i).name,'extraInformation')
                    obj.parts=[obj.parts(1:i-1),obj.parts(i+1:end)];
                    obj.relationships=[obj.relationships(1:i-1),obj.relationships(i+1:end)];
                end
                i=i+1;
            end


            slInternal('addRelationshipsAndParts',obj.protectedModelFile,obj.parts,obj.relationships,obj);
        end





        function setPasswordOrThrow(obj,isEncrypted,category,passwords)
            import Simulink.ModelReference.ProtectedModel.*;


            pwMan=PasswordManager.Utils('getManager');
            if isEncrypted


                pwMan.setPasswordForEncryptionCategory(obj.ModelName,category,passwords{1});
                if~PasswordManager.doesEncryptionCategoryHaveTheRightPassword(obj.ModelName,category)
                    myException=getWrongPasswordDetailedException(obj.ModelName,category);
                    myException.throw;
                end
            end
            pwMan.setPasswordForEncryptionCategory(obj.ModelName,category,passwords{2});
        end






        function changePasswordForEncryptionCategory(obj,encryptionCategory,passwords)
            import Simulink.ModelReference.ProtectedModel.*;



            PasswordManager.checkPassword(passwords{2},obj.ModelName);



            if strcmp(passwords{1},passwords{2})
                DAStudio.error('Simulink:protectedModel:cannotChangePasswordToSamePassword',...
                obj.ModelName,...
                getStringForEncryptionCategory(encryptionCategory));
            end

            opts=getOptions(obj.ModelName);
            switch encryptionCategory
            case 'SIM'
                obj.setPasswordOrThrow(opts.isSimEncrypted,'SIM',passwords);
                obj.simPasswords=passwords;
            case 'RTW'
                obj.setPasswordOrThrow(opts.isRTWEncrypted,'RTW',passwords);
                obj.cgPasswords=passwords;
            case 'VIEW'
                obj.setPasswordOrThrow(opts.isViewEncrypted,'VIEW',passwords);
                obj.viewPasswords=passwords;
            otherwise
                assert(false,'Unrecognized encryption category');
            end
        end






        function out=rebuildRequired(obj,addedIdx)
            import Simulink.ModelReference.ProtectedModel.*;

            encryptionChanged=false;






            if obj.Encrypt
                obj.isSimEncrypted=~isempty(PasswordManager.getPasswordForEncryptionCategory(obj.ModelName,'SIM'))&&...
                (obj.supportsNormal()||obj.supportsAccel);
                obj.isRTWEncrypted=~isempty(PasswordManager.getPasswordForEncryptionCategory(obj.ModelName,'RTW'))&&...
                obj.supportsCodeGen();
                obj.isViewEncrypted=~isempty(PasswordManager.getPasswordForEncryptionCategory(obj.ModelName,'VIEW'))&&...
                obj.supportsView();


                encryptionChanged=~isequal(obj.isSimEncrypted,obj.originalInformation.isSimEncrypted)||...
                ~isequal(obj.isRTWEncrypted,obj.originalInformation.isRTWEncrypted)||...
                ~isequal(obj.isViewEncrypted,obj.originalInformation.isViewEncrypted);


                encryptionChanged=encryptionChanged||...
                ~isempty(obj.simPasswords)||~isempty(obj.cgPasswords)||...
                ~isempty(obj.viewPasswords);

            else



                if obj.originalInformation.isSimEncrypted||...
                    obj.originalInformation.isRTWEncrypted||...
                    obj.originalInformation.isViewEncrypted
                    encryptionChanged=true;
                end
            end



            contentsChanged=~isequal(obj.BinariesAndHeadersOnly,obj.originalInformation.binariesAndHeadersOnly);
            contentsChanged=contentsChanged||...
            ~isequal(obj.AllFilesForStandaloneBuild,obj.originalInformation.allFilesForStandaloneBuild);
            contentsChanged=contentsChanged||...
            ~isequal(obj.ObfuscateCode,obj.originalInformation.obfuscateCode);
            contentsChanged=contentsChanged||...
            ~isequal(obj.CodeInterface,obj.originalInformation.codeInterface);


            itemsAdded=~isequal(addedIdx,zeros(1,length(addedIdx)));


            out=encryptionChanged||contentsChanged||itemsAdded;

            if out&&hasMultipleTargets(obj.protectedModelFile)






                DAStudio.error('Simulink:protectedModel:ModifyRebuildMultiTargetIncompatible');
            end
        end






        function updateInformationAfterDeletion(obj,gi)
            import Simulink.ModelReference.ProtectedModel.*;

            if~strcmp(obj.Modes,'ViewOnly')
                gi.setBuildDirMap(obj.originalInformation.getBuildDirMap());
            end


            if~isempty(gi.callbackMgr)
                gi.callbackMgr.update(obj);
            end



            obj.updateEncryptionStatus(gi);


            obj.replaceInformation();
        end

        function replaceInformation(obj)
            import Simulink.ModelReference.ProtectedModel.*;
            import Simulink.ModelReference.common.*;



            part(1).source='extraInformation.mat';
            part(1).dest='/info/extraInformation.mat';
            part(1).type='mat';
            part(1).purpose='extraInfo';
            part(1).properties='';

            rel(1).year=RelationshipInformation.getRelationshipYear();
            rel(1).name='extraInformation';
            rel(1).dest='/info/extraInformation.mat';
            rel(1).isEncrypted=false;
            rel(1).encryptionCategory=RelationshipInformation.getEncryptionCategory();

            slInternal('replaceInformation',obj.protectedModelFile,...
            part,...
            rel,...
            obj);
        end






        function out=getExtraInformation(obj)
            info=obj.originalInformation;
            out=info.updateImplOnlyInformation(obj);
        end




        function updateProgress(obj,pct,message)
            if obj.guiEntry&&desktop('-inuse')
                if isempty(obj.waitBarHandle)
                    obj.waitBarHandle=waitbar(pct/100,...
                    DAStudio.message(['Simulink:protectedModel:',message]),...
                    'Name',DAStudio.message('Simulink:protectedModel:ProtectedModelWaitBarTitle',obj.escapeChars(obj.ModelName)));
                else
                    waitbar(pct/100,...
                    obj.waitBarHandle,...
                    DAStudio.message(['Simulink:protectedModel:',message]));
                    if pct==100
                        delete(obj.waitBarHandle);
                    end
                end


                if slsvTestingHook('ProtectedModelTestProgressStatus')>0
                    obj.postUpdateHook();
                end
            end
        end





        function restoreLdStatus(obj)
            if obj.rebuilt
                restoreLdStatus@Simulink.ModelReference.ProtectedModel.Creator(obj);
            end
            if~isempty(obj.origWarnStatus)
                warning(obj.origWarnStatus);
            end
        end

    end

    methods(Access=protected)



        function cacheCreatorInBlockDiagram(obj)
            if obj.rebuilt
                cacheCreatorInBlockDiagram@Simulink.ModelReference.ProtectedModel.Creator(obj);
            end
        end

        function clearCreatorFromBlockDiagram(obj)
            if obj.rebuilt
                clearCreatorFromBlockDiagram@Simulink.ModelReference.ProtectedModel.Creator(obj);
            end
        end

        function validateReleaseForEdit(obj)
            isFromCurrentRelease=slInternal('isProtectedModelFromThisSimulinkVersion',obj.protectedModelFile);
            if~isFromCurrentRelease
                modelVersion=slInternal('getProtectedModelVersion',obj.protectedModelFile);
                DAStudio.error('Simulink:protectedModel:protectedModelSimulinkVersionMismatchForAddOrRemoveTarget',...
                obj.protectedModelFile,...
                modelVersion);
            end
        end
    end

    methods(Access=private)
        function out=escapeChars(~,in)
            out=strrep(in,'_','\_');
        end

        function codegenTargets=getCodeGenTargets(obj)
            import Simulink.ModelReference.ProtectedModel.*;

            targets=getSupportedTargets(obj.protectedModelFile);
            codegenTargets=setdiff(targets,{'viewonly','sim'});
        end


        function restoreCurrentMode(obj,cm)
            obj.currentMode=cm;
        end
    end

    methods(Static=true,Hidden=true)

        function throwWarning(errId,~,varargin)
            narginchk(2,inf);
            warnMsg=message(errId,varargin{:});
            ME=MException(errId,'%s',warnMsg.getString);
            MSLDiagnostic(ME).reportAsWarning;
        end




        function out=getDefaultUnprotectedFile(modelName)
            fileList=which('-all',modelName);
            for i=1:length(fileList)
                [isProtected,fullFileName]=slInternal('getReferencedModelFileInformation',fileList{i});
                if~isempty(fullFileName)&&~isProtected
                    out=fullFileName;
                    return;
                end
            end
            out='';
        end
    end
end


