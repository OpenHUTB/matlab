classdef Settings<matlab.mixin.SetGetExactNames&handle&dynamicprops

    properties
IgnoreSignalName

IgnoreBlockProperty

ExcludeModelReferences

ExcludeLibraryLinks

    end

    properties(Dependent)
ParamDifferenceThreshold


ReplaceExactClonesWithSubsystemReference

Libraries

Folders

DetectClonesAcrossModel


ExcludeInactiveRegions


    end

    properties(SetAccess='private',GetAccess='public',Hidden=true)
CloneDetectionMethod
ClonePatternType
    end

    properties(SetAccess='private',GetAccess='private',Hidden=true)
ParamDifferenceThresholdValue
ReplaceExactClonesWithSubsystemReferenceValue
LibrariesValue
FoldersValue
DetectClonesAcrossModelValue
ExcludeInactiveRegionsValue
    end

    methods
        function obj=Settings()

            if~license('test','sl_verification_validation')
                DAStudio.error('sl_pir_cpp:creator:CloneDetectionLicenseFail');
            end

            obj.IgnoreSignalName=false;
            obj.IgnoreBlockProperty=false;
            obj.ParamDifferenceThreshold=uint32(50);
            obj.ReplaceExactClonesWithSubsystemReference=false;
            obj.ExcludeModelReferences=false;
            obj.ExcludeLibraryLinks=false;
            obj.ExcludeInactiveRegionsValue=false;
            obj.Libraries={};
            obj.FoldersValue={};
            obj.CloneDetectionMethod='Graphical';
            obj.ClonePatternType='Similar';
            obj.DetectClonesAcrossModelValue=false;
        end

        function set.IgnoreSignalName(obj,ignoreSignalName)
            try
                if~isscalar(ignoreSignalName)
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end

                ignoreSignalName=logical(ignoreSignalName);
                if isa(ignoreSignalName,'logical')
                    obj.IgnoreSignalName=ignoreSignalName;
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end
            catch exception
                DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
            end
        end

        function set.IgnoreBlockProperty(obj,ignoreBlockProperty)
            try
                if~isscalar(ignoreBlockProperty)
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end

                ignoreBlockProperty=logical(ignoreBlockProperty);
                if isa(ignoreBlockProperty,'logical')
                    obj.IgnoreBlockProperty=ignoreBlockProperty;
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end
            catch exception
                DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
            end
        end

        function set.DetectClonesAcrossModel(obj,clonesAnywhere)
            try
                clonesAnywhere=logical(clonesAnywhere);
                if isa(clonesAnywhere,'logical')
                    minimumRegionSizeProp='MinimumRegionSize';
                    minimumCloneGroupSizeProp='MinimumCloneGroupSize';
                    if(clonesAnywhere)
                        if(~isempty(obj.Libraries))
                            DAStudio.warning('sl_pir_cpp:creator:SettingsConflictClonesAcrossModelAndLibries');
                        elseif(obj.ReplaceExactClonesWithSubsystemReference)
                            DAStudio.warning('sl_pir_cpp:creator:SettingsConflictClonesAcrossModelAndSubsystemRef');
                        elseif(obj.ExcludeInactiveRegions)
                            DAStudio.warning('sl_pir_cpp:creator:SettingsConflictClonesAcrossModelAndExcludeInactiveRegions');
                        end
                        obj.DetectClonesAcrossModelValue=clonesAnywhere;

                        if~isprop(obj,minimumRegionSizeProp)
                            regionProp=addprop(obj,minimumRegionSizeProp);
                            regionProp.SetAccess='public';
                            regionProp.GetAccess='public';
                            regionProp.SetMethod=@setMinimumRegionSize;
                            obj.MinimumRegionSize=uint32(2);

                        end
                        if~isprop(obj,minimumCloneGroupSizeProp)
                            groupProp=addprop(obj,minimumCloneGroupSizeProp);
                            groupProp.SetAccess='public';
                            groupProp.GetAccess='public';
                            groupProp.SetMethod=@setMinimumCloneGroupSize;
                            obj.MinimumCloneGroupSize=uint32(2);
                        end
                    else
                        try
                            delete(findprop(obj,minimumRegionSizeProp));
                            delete(findprop(obj,minimumCloneGroupSizeProp));
                        catch
                        end
                    end
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end
            catch exception
                exception.throwAsCaller();
                return;
            end
        end

        function set.ParamDifferenceThreshold(obj,...
            paramDifferenceThreshold)
            try
                if~isscalar(paramDifferenceThreshold)
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForUINT32');
                end

                if isnumeric(paramDifferenceThreshold)
                    paramDifferenceThreshold=uint32(paramDifferenceThreshold);
                    if paramDifferenceThreshold>0
                        if(obj.ReplaceExactClonesWithSubsystemReference)
                            DAStudio.warning('sl_pir_cpp:creator:SettingsConflictParamDifferenceAndSubsystemReference');
                        end

                        if~isempty(obj.Libraries)
                            DAStudio.warning('sl_pir_cpp:creator:SettingsConflictParamDifferenceAndLibraries');
                        end
                    end

                    obj.ParamDifferenceThresholdValue=paramDifferenceThreshold;
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForUINT32');
                end
            catch exception
                DAStudio.error('sl_pir_cpp:creator:IllegalInputForUINT32');
            end
        end

        function setMinimumRegionSize(obj,regionSize)
            try
                if~isscalar(regionSize)
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForUINT32');
                end

                if isnumeric(regionSize)
                    if regionSize<2
                        DAStudio.error('sl_pir_cpp:creator:InvalidRegionOrCloneGroupSize');
                    end
                    obj.MinimumRegionSize=uint32(regionSize);
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForUINT32');
                end
            catch exception
                exception.throwAsCaller();
                return;
            end
        end

        function setMinimumCloneGroupSize(obj,...
            cloneGroupSize)
            try
                if~isscalar(cloneGroupSize)
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForUINT32');
                end

                if isnumeric(cloneGroupSize)
                    if cloneGroupSize<2
                        DAStudio.error('sl_pir_cpp:creator:InvalidRegionOrCloneGroupSize');
                    end
                    obj.MinimumCloneGroupSize=uint32(cloneGroupSize);
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForUINT32');
                end
            catch exception
                exception.throwAsCaller();
                return;
            end
        end

        function paramDifferenceThreshold=get.ParamDifferenceThreshold(obj)
            paramDifferenceThreshold=obj.ParamDifferenceThresholdValue;
        end

        function set.ReplaceExactClonesWithSubsystemReference(obj,...
            replaceExactClonesWithSubsystemReference)
            try
                if~isscalar(replaceExactClonesWithSubsystemReference)
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end

                replaceExactClonesWithSubsystemReference=...
                logical(replaceExactClonesWithSubsystemReference);
                if isa(replaceExactClonesWithSubsystemReference,'logical')
                    if replaceExactClonesWithSubsystemReference

                        if~isempty(obj.Libraries)
                            DAStudio.warning('sl_pir_cpp:creator:SettingsConflictSubsystemReferenceAndLibraries');
                        end

                        if obj.DetectClonesAcrossModel
                            DAStudio.warning('sl_pir_cpp:creator:SettingsConflictClonesAcrossModelAndSubsystemRef');
                        end
                    end

                    obj.ReplaceExactClonesWithSubsystemReferenceValue=...
                    replaceExactClonesWithSubsystemReference;
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end
            catch exception
                DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
            end
        end

        function replaceExactClonesWithSubsystemReference=...
            get.ReplaceExactClonesWithSubsystemReference(obj)
            replaceExactClonesWithSubsystemReference=...
            obj.ReplaceExactClonesWithSubsystemReferenceValue;
        end

        function set.ExcludeModelReferences(obj,excludeModelReferences)
            try
                if~isscalar(excludeModelReferences)
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end

                excludeModelReferences=logical(excludeModelReferences);
                if isa(excludeModelReferences,'logical')
                    obj.ExcludeModelReferences=excludeModelReferences;
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end
            catch exception
                DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
            end
        end

        function set.ExcludeLibraryLinks(obj,excludeLibraryLinks)
            try
                if~isscalar(excludeLibraryLinks)
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end

                excludeLibraryLinks=logical(excludeLibraryLinks);
                if isa(excludeLibraryLinks,'logical')
                    obj.ExcludeLibraryLinks=excludeLibraryLinks;
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end
            catch exception
                DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
            end
        end

        function set.ExcludeInactiveRegions(obj,excludeInactiveRegions)
            try
                if~isscalar(excludeInactiveRegions)
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end

                excludeInactiveRegions=logical(excludeInactiveRegions);
                if isa(excludeInactiveRegions,'logical')
                    obj.ExcludeInactiveRegionsValue=excludeInactiveRegions;
                    if obj.ExcludeInactiveRegions&&obj.DetectClonesAcrossModel
                        DAStudio.warning('sl_pir_cpp:creator:SettingsConflictClonesAcrossModelAndSubsystemRef');
                    end
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end
            catch exception
                DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
            end
        end


        function set.Libraries(obj,librariesList)
            try
                [derivedLibraryList,invalidInputs]=Simulink.CloneDetection.internal.util.getCellArrayOfCharsFromMultipleLists(librariesList);

                if isempty(derivedLibraryList)
                    obj.LibrariesValue={};
                else
                    if obj.DetectClonesAcrossModel
                        DAStudio.warning('sl_pir_cpp:creator:SettingsConflictClonesAcrossModelAndSubsystemRef');
                    end
                    obj.LibrariesValue=cell(length(derivedLibraryList),1);
                    nextValidLibraryIndex=1;

                    for libIndex=1:length(derivedLibraryList)
                        if~isempty(derivedLibraryList(libIndex))
                            libFileName=char(derivedLibraryList(libIndex));
                            if isfolder(libFileName)
                                dirData=dir(libFileName);

                                for i=1:length(dirData)
                                    if strcmp(dirData(i).name,'.')||strcmp(dirData(i).name,'..')
                                        continue;
                                    end
                                    if isfile([libFileName,filesep,dirData(i).name])
                                        [~,~,ext]=fileparts(dirData(i).name);

                                        if((strcmp(ext,'.slx')||strcmp(ext,'.mdl'))&&...
                                            Simulink.MDLInfo([libFileName,filesep,dirData(i).name]).IsLibrary)
                                            obj.LibrariesValue{nextValidLibraryIndex,1}=[libFileName,filesep,dirData(i).name];
                                            nextValidLibraryIndex=nextValidLibraryIndex+1;
                                        end
                                    end
                                end
                            else
                                [isFileExist,libraryFilePathWithExtension]=...
                                Simulink.CloneDetection.internal.util.checkFileInAllPaths(libFileName);
                                if isFileExist
                                    obj.LibrariesValue{nextValidLibraryIndex,1}=libraryFilePathWithExtension;
                                    nextValidLibraryIndex=nextValidLibraryIndex+1;

                                    if obj.ReplaceExactClonesWithSubsystemReference
                                        DAStudio.warning('sl_pir_cpp:creator:SettingsConflictSubsystemReferenceAndLibraries');
                                    end

                                    if obj.ExcludeInactiveRegions
                                        DAStudio.warning('sl_pir_cpp:creator:SettingsConflictLibrariesAndExcludeInactiveRegions');
                                    end

                                    if~isempty(obj.FoldersValue)
                                        DAStudio.warning('sl_pir_cpp:creator:SettingsConflictFoldersAndLibraries');
                                    end
                                else
                                    invalidInputs=[invalidInputs;libFileName];
                                end
                            end
                        end
                        obj.LibrariesValue=obj.LibrariesValue(~cellfun(@isempty,...
                        obj.LibrariesValue));
                        obj.LibrariesValue=unique(obj.LibrariesValue,'stable');
                    end
                end
                Simulink.CloneDetection.internal.util.throwExceptionForListItems(invalidInputs,...
                'sl_pir_cpp:creator:FileNotFound');
            catch exception
                obj.LibrariesValue=obj.LibrariesValue(~cellfun(@isempty,...
                obj.LibrariesValue));
                obj.LibrariesValue=unique(obj.LibrariesValue,'stable');
                exception.throwAsCaller();
            end
        end

        function detectClonesAcrossModel=get.DetectClonesAcrossModel(obj)
            detectClonesAcrossModel=obj.DetectClonesAcrossModelValue;
        end

        function excludeInactiveRegions=get.ExcludeInactiveRegions(obj)
            excludeInactiveRegions=obj.ExcludeInactiveRegionsValue;
        end

        function libraries=get.Libraries(obj)
            libraries=obj.LibrariesValue;
        end


        function obj=addLibraries(obj,varargin)
            [varargin,~]=Simulink.CloneDetection.internal.util.getCellArrayOfCharsFromMultipleLists(varargin);
            obj.Libraries=[obj.LibrariesValue;varargin];
        end

        function obj=removeLibraries(obj,varargin)

            try
                [varargin,invalidInputs]=Simulink.CloneDetection.internal.util.getCellArrayOfCharsFromMultipleLists(varargin);
                for libIndex=1:length(varargin)
                    libFilenamesText=varargin{libIndex};
                    [isFileExist,libraryFilePathWithExtension]=...
                    Simulink.CloneDetection.internal.util.checkFileInAllPaths(libFilenamesText);
                    if isFileExist
                        obj.LibrariesValue=obj.LibrariesValue(~cellfun(@(libPath)isequal(libPath,libraryFilePathWithExtension),...
                        obj.LibrariesValue));
                    else
                        invalidInputs=[invalidInputs;libFilenamesText];
                    end
                end

                Simulink.CloneDetection.internal.util.throwExceptionForListItems(invalidInputs,...
                'sl_pir_cpp:creator:FileNotFound');
            catch exception
                exception.throwAsCaller();
                return;
            end
        end

        function set.Folders(obj,listOfFolders)
            [derivedFoldersList,invalidInputs]=...
            Simulink.CloneDetection.internal.util.getCellArrayOfCharsFromMultipleLists(listOfFolders);
            findClonesRecursivelyInFolders='FindClonesRecursivelyInFolders';

            if isempty(derivedFoldersList)
                if isprop(obj,findClonesRecursivelyInFolders)
                    delete(findprop(obj,findClonesRecursivelyInFolders));
                end
                obj.FoldersValue={};
            else
                obj.FoldersValue=cell(length(derivedFoldersList),1);
                validFoldersIndex=1;
                for folderIndex=1:length(derivedFoldersList)
                    if~isempty(derivedFoldersList(folderIndex))
                        folderPath=derivedFoldersList{folderIndex};
                        try
                            fullPathData=what(folderPath);
                            obj.FoldersValue{validFoldersIndex,1}=fullPathData.path;
                            validFoldersIndex=validFoldersIndex+1;
                        catch
                            invalidInputs=[invalidInputs;folderPath];
                            continue;
                        end
                    end
                end
                obj.FoldersValue=obj.FoldersValue(~cellfun(@isempty,obj.FoldersValue));
                obj.FoldersValue=unique(obj.FoldersValue,'stable');

                if~isprop(obj,findClonesRecursivelyInFolders)
                    findClonesRecursivelyInFoldersProp=addprop(obj,findClonesRecursivelyInFolders);
                    findClonesRecursivelyInFoldersProp.SetAccess='public';
                    findClonesRecursivelyInFoldersProp.GetAccess='public';
                    findClonesRecursivelyInFoldersProp.SetMethod=@setFindClonesRecursivelyInFolders;
                    obj.FindClonesRecursivelyInFolders=true;
                end
                if~isempty(obj.LibrariesValue)
                    DAStudio.warning('sl_pir_cpp:creator:SettingsConflictFoldersAndLibraries');
                end
            end

            Simulink.CloneDetection.internal.util.throwExceptionForListItems(invalidInputs,...
            'sl_pir_cpp:creator:InvalidFolderPath');
        end



        function folders=get.Folders(obj)
            folders=obj.FoldersValue;
        end


        function obj=addFolders(obj,varargin)
            [varargin,~]=Simulink.CloneDetection.internal.util.getCellArrayOfCharsFromMultipleLists(varargin);
            obj.Folders=[obj.FoldersValue;varargin];
        end

        function obj=removeFolders(obj,varargin)
            [varargin,invalidInputs]=Simulink.CloneDetection.internal.util.getCellArrayOfCharsFromMultipleLists(varargin);

            for folderIndex=1:length(varargin)
                folder=varargin{folderIndex};

                try
                    folderMatch=what(folder);
                    folderFullPath=folderMatch.path;
                    if any(strcmp(obj.FoldersValue,folderFullPath))
                        obj.FoldersValue=obj.FoldersValue(~cellfun(@(x)isequal(x,folderFullPath),...
                        obj.FoldersValue));
                    end
                catch
                    invalidInputs=[invalidInputs;folder];
                end
            end

            Simulink.CloneDetection.internal.util.throwExceptionForListItems(invalidInputs,...
            'sl_pir_cpp:creator:FolderNotFoundInList');
        end

        function setFindClonesRecursivelyInFolders(obj,findClonesRecursivelyInFolders)
            try
                if~isscalar(findClonesRecursivelyInFolders)
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end

                findClonesRecursivelyInFolders=logical(findClonesRecursivelyInFolders);
                if isa(findClonesRecursivelyInFolders,'logical')
                    obj.FindClonesRecursivelyInFolders=findClonesRecursivelyInFolders;
                else
                    DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
                end
            catch exception
                DAStudio.error('sl_pir_cpp:creator:IllegalInputForLogical');
            end
        end
    end
end


