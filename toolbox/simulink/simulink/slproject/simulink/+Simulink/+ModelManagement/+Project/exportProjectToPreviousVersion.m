classdef exportProjectToPreviousVersion<handle



    properties
Project
MetaDataFormat
        FixedPathMetaDataVersion=[];
        ExportPrjFile=false;
        PreventExportMissingFiles=false;
MetaDataFolder
TargetRelease
ExportLocation
ExportedProject
        ExportedModels={};
FilesToRemove
ModelFiles
Libraries
SubsystemRefs
DictionaryFiles
        IncludeReferences=false;
ProjectRootsMapping
    end

    methods
        function obj=exportProjectToPreviousVersion(project,zipfile,target,includeReferences)
            obj.Project=project;
            obj.ExportedProject=string(zipfile);
            obj.TargetRelease=string(target);
            obj.IncludeReferences=includeReferences;
        end

        function removeFilesFromExportedProject(obj)
            if isempty(obj.FilesToRemove)

                return
            end
            obj.FilesToRemove=unique(obj.FilesToRemove);
            thisRoot=obj.ProjectRootsMapping.get(obj.Project.RootFolder,obj.ExportLocation);
            exportProject=matlab.internal.project.api.makeProjectAvailable(thisRoot);
            for jj=1:numel(obj.FilesToRemove)
                toRemove=fullfile(thisRoot,obj.FilesToRemove{jj});
                if~isempty(exportProject.findFile(toRemove))
                    exportProject.removeFile(toRemove);
                    delete(toRemove)
                end
            end
            exportProject.close;
            obj.FilesToRemove=[];
        end

        function validateExportSettings(obj)

            if isa(obj.ExportedProject,'string')&&(obj.ExportedProject.strlength<1)
                error(message('SimulinkProject:util:exportZipFileIsempty'))
            end
            if exist(obj.ExportedProject,'dir')
                error(message('SimulinkProject:util:exportZipFileIsFolder',...
                obj.ExportedProject));
            end
            [zipPath,~,zipExt]=fileparts(obj.ExportedProject);
            if~strcmp(zipExt,'.zip')
                obj.ExportedProject=obj.ExportedProject+".zip";
            end
            if zipPath.strlength>0&&~exist(zipPath,'dir')
                error(message('SimulinkProject:util:exportZipFolderDoesNotExist',...
                obj.ExportedProject,zipPath));
            end

            targetRelease=simulink_version(obj.TargetRelease);
            if targetRelease.version==-1
                error(message('SimulinkProject:util:exportWrongVersionFormat',...
                obj.TargetRelease))
            end


            allSimulinkReleases=Simulink.loadsave.getKnownSimulinkVersions;
            sevenYearsAgo=simulink_version(allSimulinkReleases{end-14});
            if targetRelease<sevenYearsAgo
                error(message('SimulinkProject:util:exportVersionSevenYearCutOff',...
                obj.Project.RootFolder,obj.TargetRelease))
            end



            if targetRelease==simulink_version(allSimulinkReleases{end})
                error(message('SimulinkProject:util:exportVersionCurrentOrFuture',...
                obj.Project.RootFolder,obj.TargetRelease))
            end



            if targetRelease<simulink_version("R2019a")



                obj.MetaDataFolder='.SimulinkProject';
                obj.ExportPrjFile=true;
            else
                obj.MetaDataFolder='';
                obj.ExportPrjFile=false;
            end


            obj.FixedPathMetaDataVersion=[];
            obj.MetaDataFormat=obj.Project.DefinitionFilesType;
            if obj.Project.DefinitionFilesType==matlab.project.DefinitionFiles.FixedPathMultiFile
                if targetRelease<simulink_version("R2018a")
                    warning(message('SimulinkProject:util:exportFixedPathMMCutoffWarning'))
                    obj.MetaDataFormat=matlab.project.DefinitionFiles.MultiFile;
                end
                if targetRelease<simulink_version("R2020b")


                    obj.FixedPathMetaDataVersion=1;
                else
                    obj.FixedPathMetaDataVersion=2;
                end
            end
        end

        function validatePerProjectSettings(obj)

            if~isempty(obj.SubsystemRefs)
                targetRelease=simulink_version(obj.TargetRelease);
                if targetRelease<=simulink_version("R2019a")
                    error(message('SimulinkProject:util:exportVersionSSRCutoff',...
                    obj.Project.RootFolder,obj.TargetRelease))
                end
            end
        end

        function runCoreProjectExport(obj,exportFile)
            optionalInputs={};
            if~isempty(obj.MetaDataFormat)
                optionalInputs=[optionalInputs,'definitionType'];
                optionalInputs{end+1}=obj.MetaDataFormat;
            end
            if~isempty(obj.MetaDataFolder)
                optionalInputs=[optionalInputs,...
                'definitionFolder',obj.MetaDataFolder];
            end
            if~isempty(obj.FixedPathMetaDataVersion)
                optionalInputs=[optionalInputs,...
                'version',obj.FixedPathMetaDataVersion];
            end
            if~isempty(obj.PreventExportMissingFiles)
                optionalInputs=[optionalInputs,...
                'preventExportWithMissingFiles',obj.PreventExportMissingFiles];
            end

            obj.ProjectRootsMapping=matlab.internal.project.archive.exportProjectAndReturnRootMap(...
            obj.Project,exportFile,'archiveReferences',obj.IncludeReferences,optionalInputs{:});
        end

        function cloneProject(obj)

            obj.ExportLocation=tempname;
            mkdir(obj.ExportLocation)
            exportFile=fullfile(obj.ExportLocation,obj.Project.Name+'.zip');

            obj.runCoreProjectExport(exportFile);
            exportFileCleanUp=onCleanup(@()delete(exportFile));

            unzip(exportFile,obj.ExportLocation)
        end

        function checkForMissingSimulinkFiles(obj)

            projectFiles=obj.Project.Files;
            if~isempty(projectFiles)

                foundFilePaths=[projectFiles(:).Path];

                foundFilePaths=foundFilePaths(~isfolder(foundFilePaths));
                existance=isfile(foundFilePaths);
                if any(existance==0)

                    missing=foundFilePaths(~existance);
                    missingSimulinkFilesInd=cellfun(@(x)isSimulinkFile(x),missing);
                    if any(missingSimulinkFilesInd)
                        missingSimulinkFiles=missing(missingSimulinkFilesInd);
                        missingFilesStr=strjoin(missingSimulinkFiles);

                        error(message('SimulinkProject:util:exportProjectHasMissingSimulinkFiles',...
                        obj.Project.Name,missingFilesStr))
                    else



                        warning(message('SimulinkProject:util:exportProjectHasMissingFiles',obj.Project.Name))
                    end
                end
            end
        end

        function runDependencyAnalysis(obj)

            obj.Project.updateDependencies;
        end

        function categorizeFiles(obj)

            files=obj.Project.Files;
            filePaths={files.Path};
            modelPathInds=cellfun(@(f)isModelFile(f),filePaths);
            obj.ModelFiles=filePaths(modelPathInds);
            isLibrary=false(size(obj.ModelFiles));
            isSubsystemReference=isLibrary;
            for jj=1:numel(obj.ModelFiles)
                info=Simulink.MDLInfo(obj.ModelFiles{jj});
                isLibrary(jj)=strcmp(info.BlockDiagramType,'Library');
                isSubsystemReference(jj)=strcmp(info.BlockDiagramType,'Subsystem');
            end
            obj.SubsystemRefs=obj.ModelFiles(isSubsystemReference);
            obj.Libraries=obj.ModelFiles(isLibrary);

            dictionaryPathInds=cellfun(@(f)isDataDictionaryFile(f),filePaths);
            obj.DictionaryFiles=filePaths(dictionaryPathInds);
        end

        function exportModelFiles(obj)
            if isempty(obj.ModelFiles)
                return
            end
            oldWarningState=warning('off','Simulink:Harness:WarnABoutNameShadowingOnActivation');
            c0=onCleanup(@()warning(oldWarningState));
            oldModelWarningValue=get_param(0,'NotifyIfLoadOldModel');
            c1=onCleanup(@()set_param(0,'NotifyIfLoadOldModel',oldModelWarningValue));
            set_param(0,'NotifyIfLoadOldModel','off');
            for jj=1:numel(obj.Libraries)
                thisLibrary=obj.Libraries{jj};
                obj.exportSimulinkFile(thisLibrary)
            end

            for jj=1:numel(obj.SubsystemRefs)
                thisSSRef=obj.SubsystemRefs{jj};
                obj.exportSimulinkFile(thisSSRef)
            end




            depGraphModelsInd=cellfun(@(f)isModelFile(f),obj.Project.Dependencies.Nodes.Name);
            sg=subgraph(obj.Project.Dependencies,obj.Project.Dependencies.Nodes.Name(depGraphModelsInd));
            topModelsIndex=indegree(sg)==0;
            topModels=sg.Nodes.Name(topModelsIndex);

            jj=1;
            while jj<=numel(topModels)
                thisTop=topModels{jj};

                load_system(thisTop)



                [~,modelName,~]=fileparts(thisTop);
                if Simulink.harness.isHarnessBD(modelName)
                    try
                        thisHarnessOwner=Simulink.harness.internal.getHarnessOwnerBD(modelName);

                        thisHarnessOwnerFile=which(thisHarnessOwner);

                        if~ismember(thisHarnessOwnerFile,topModels)
                            topModels{end+1}=thisHarnessOwnerFile;%#ok<AGROW>
                        end
                        relativePath=strrep(thisTop,obj.Project.RootFolder+filesep,'');
                        obj.FilesToRemove=[obj.FilesToRemove;relativePath];

                        harnessInfoFile=...
                        Simulink.harness.internal.getHarnessInfoFileName(thisHarnessOwner);
                        relativePath=strrep(harnessInfoFile,obj.Project.RootFolder+filesep,'');
                        obj.FilesToRemove=[obj.FilesToRemove;relativePath];
                        jj=jj+1;
                        close_system(obj.ModelFiles,0);
                        continue
                    catch E
                        warning(E.identifier,'%s',E.message)
                    end
                end



                referenceModels=find_mdlrefs(modelName,...
                'WarnForInvalidModelRefs',true,...
                'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
                for kk=1:numel(referenceModels)
                    thisRef=which(referenceModels{kk});

                    if~isempty(obj.Project.findFile(thisRef))
                        load_system(thisRef)
                        obj.exportSimulinkFile(thisRef)
                    end
                end


                close_system(obj.ModelFiles,0);
                jj=jj+1;
            end
            delete(c1);
            delete(c0);
        end

        function loc=getExportLocation(obj)


            loc=obj.ProjectRootsMapping.get(obj.Project.RootFolder,obj.ExportLocation);
        end

        function exportDataDictionaryFiles(obj)
            if isempty(obj.DictionaryFiles)
                return
            end

            dictionaries=cellfun(@(f)isDataDictionaryFile(f),obj.Project.Dependencies.Nodes.Name);
            sg_dd=subgraph(obj.Project.Dependencies,obj.Project.Dependencies.Nodes.Name(dictionaries));


            topDictionariesIndex=indegree(sg_dd)==0;
            topDictionaries=sg_dd.Nodes.Name(topDictionariesIndex);

            for jj=1:numel(topDictionaries)
                openDictionariesBefore=Simulink.data.dictionary.getOpenDictionaryPaths;

                thisTopFile=topDictionaries{jj};

                thisTopDict=Simulink.data.dictionary.open(thisTopFile);
                tempDDExportLocation=tempname;
                mkdir(tempDDExportLocation);
                tempFolderCleanup=onCleanup(@()rmdir(tempDDExportLocation,'s'));

                childDictionaries=thisTopDict.DataSources;
                dictionariesToCopy={thisTopFile};
                for kk=1:numel(childDictionaries)
                    dictionariesToCopy{end+1,1}=which(childDictionaries{kk});%#ok<AGROW>
                end

                thisTopDict.exportToVersion(tempDDExportLocation,obj.TargetRelease);
                for kk=1:numel(dictionariesToCopy)
                    thisOriginal=dictionariesToCopy{kk};
                    if~isempty(obj.Project.findFile(thisOriginal))
                        [~,currentRoot,~]=fileparts(thisOriginal);
                        tempLocationDictionary=fullfile(tempDDExportLocation,[currentRoot,'.sldd']);
                        relativePath=strrep(thisOriginal,obj.Project.RootFolder,'');
                        newLocation=fullfile(obj.getExportLocation,relativePath);
                        delete(newLocation)
                        movefile(tempLocationDictionary,newLocation,'f');
                    end
                end

                delete(tempFolderCleanup);
                obj.closeOpenedDataDictionaries(openDictionariesBefore);
            end
        end

        function closeOpenedDataDictionaries(~,openDictionariesBefore)
            openDictionariesAfter=Simulink.data.dictionary.getOpenDictionaryPaths;
            dictionariesToClose=setdiff(openDictionariesAfter,openDictionariesBefore);
            for jj=1:numel(dictionariesToClose)
                try
                    [~,dictionaryName,dictionaryExt]=fileparts(dictionariesToClose{jj});
                    Simulink.data.dictionary.closeAll([dictionaryName,dictionaryExt],'-discard');
                catch E
                    warning(E.identifier,'%s',E.message)
                end
            end
        end

        function exportSignPostFile(obj)
            if~obj.ExportPrjFile
                return
            end



            allPrjs=dir(fullfile(obj.getExportLocation,'*.prj'));
            for jj=1:numel(allPrjs)
                thisPrj=fullfile(allPrjs(jj).folder,allPrjs(jj).name);
                try
                    textContent=readlines(thisPrj);


                    ind=contains(textContent,"http://www.mathworks.com/MATLABProjectFile");
                    if any(ind)
                        updatedText=textContent;


                        updatedText(ind)=strrep(updatedText(ind),...
                        "MATLABProject",...
                        "SimulinkProject");
                        fid=fopen(thisPrj,'w');
                        c1=onCleanup(@()fclose(fid));
                        for kk=1:size(updatedText,1)
                            fprintf(fid,'%s\n',updatedText(kk));
                        end
                        delete(c1);
                    end
                catch E
                    warning(E.identifier,'%s',E.message)
                end
            end
        end

        function export(obj)
            obj.validateExportSettings;
            obj.cloneProject;
            obj.exportOneProject;
            if obj.IncludeReferences
                allRefs=obj.Project.listAllProjectReferences;
                for jj=1:numel(allRefs)
                    try
                        obj.Project=allRefs(jj).Project;
                    catch me
                        if strcmp(me.identifier,'MATLAB:project:api:StaleProjectHandle')
                            matlabException=MException(message('SimulinkProject:util:exportVersionMissingProject',allRefs(jj).File));
                            throw(matlabException);
                        else
                            rethrow(me);
                        end
                    end
                    obj.exportOneProject;
                end
            end




            zip(obj.ExportedProject,[obj.ExportLocation,filesep,'*'],obj.ExportLocation);
            resolvedFile=Simulink.loadsave.resolveFile(obj.ExportedProject);
            if~isempty(resolvedFile)
                obj.ExportedProject=resolvedFile;
            end
            obj.ExportedProject=string(obj.ExportedProject);
        end

        function exportOneProject(obj)
            obj.checkForMissingSimulinkFiles;
            obj.categorizeFiles;
            obj.validatePerProjectSettings;
            obj.checkForAndCloseDirtyFiles;
            obj.runDependencyAnalysis;
            obj.exportDataDictionaryFiles;
            obj.exportModelFiles;
            obj.exportSignPostFile;
            obj.removeFilesFromExportedProject;
        end

        function checkForAndCloseDirtyFiles(obj)



            provider=matlab.internal.project.unsavedchanges.TrackingLoadedFileProvider(...
            [matlab.internal.project.unsavedchanges.providers.SimulinkProvider,...
            matlab.internal.project.unsavedchanges.providers.DataDictionaryProvider]);
            loadedFiles=provider.getLoadedFiles();
            if isempty(loadedFiles)
                return;
            end

            [~,~,idx]=intersect(string([obj.ModelFiles,obj.DictionaryFiles]),[loadedFiles.Path]);
            loadedProjectFiles=loadedFiles(idx);
            if isempty(loadedProjectFiles)
                return;
            end

            import matlab.internal.project.unsavedchanges.Property;
            dirtyFiles=loadedProjectFiles(arrayfun(@(file)ismember(Property.Unsaved,file.Properties),loadedProjectFiles));

            if~isempty(dirtyFiles)
                dirtyFilesStr=strjoin([dirtyFiles.Path],newline);
                error(message('SimulinkProject:util:exportFilesWithUnsavedChanges',dirtyFilesStr))
            end

            provider.discard([loadedProjectFiles.Path]);
        end

        function exportSimulinkFile(obj,file)
            if ismember(file,obj.ExportedModels)
                return
            end
            try
                load_system(file)
            catch E

                if strcmp(E.identifier,'Simulink:Commands:LoadModelFullNameConflict')
                    [~,modelName,~]=fileparts(file);
                    close_system(modelName)



                    load_system(file)
                else
                    rethrow(E)
                end
            end
            [~,currentRoot,currentExt]=fileparts(file);
            relativePath=strrep(file,obj.Project.RootFolder,'');
            newLocation=fullfile(obj.getExportLocation,relativePath);
            delete(newLocation)
            exportString=char(obj.TargetRelease+strrep(upper(currentExt),'.','_'));
            try
                Simulink.exportToVersion(currentRoot,newLocation,exportString);
            catch E


                warning(E.identifier,'%s',E.message)
                save_system(currentRoot,[],'SaveDirtyReferencedModels','on')
                Simulink.exportToVersion(currentRoot,newLocation,exportString);
            end
            obj.ExportedModels=[obj.ExportedModels;file];
        end

        function isInProject=isFileInProject(obj,file)
            isInProject=obj.Project.findFile(file);
        end
    end

end

function isDataDictionary=isDataDictionaryFile(filename)


    [~,~,this_ext]=fileparts(filename);
    isDataDictionary=strcmp(this_ext,'.sldd');
end

function isModel=isModelFile(filename)


    [~,~,this_ext]=fileparts(filename);
    isModel=ismember(this_ext,{'.slx','.mdl'});
end

function b=isSimulinkFile(filename)

    b=isModelFile(filename)||isDataDictionaryFile(filename);
end
