classdef spreadSheetSource<handle


    properties
modelName
        mSourceFolderOptions=internal.packageConfig.utility.FMURootFolders
mData
        uID=0
packagePath
    end
    properties(Hidden)
utility
    end
    methods
        function this=spreadSheetSource(varargin)
            switch nargin
            case 1
                this.modelName=varargin{1};
                this.utility=internal.packageConfig.utility;
            case 2


                this.modelName=varargin{1};
                this.utility=varargin{2};
            end



            this.mData=[];
            cachedFileInfo=...
            this.utility.getPackageInfo(this.modelName);
            for Count=1:length(cachedFileInfo)
                childObj=...
                internal.packageConfig.spreadSheetRow(this,...
                cachedFileInfo(Count).FileName,...
                cachedFileInfo(Count).FileType,...
                cachedFileInfo(Count).SourceFolder,...
                this.utility.updateFileSep(cachedFileInfo(Count).DestinationFolder),...
                cachedFileInfo(Count).UID);
                this.mData=[this.mData,childObj];
                this.uID=cachedFileInfo(Count).UID;
            end
        end

        function children=getChildren(obj)
            children=obj.mData;
        end
    end
    methods(Static)
        function obj=updateSpreadSheet(obj,fileName,filePath)


            children=obj.mData;
            for Count=1:length(fileName)
                obj.uID=obj.uID+1;
                childObj=...
                internal.packageConfig.spreadSheetRow(obj,...
                fileName{Count},...
                filePath{1},...
                obj.uID);
                children=[children,childObj];
            end
            obj.mData=children;
        end
        function resourcesStruct=getResourcesToPackage(obj)


            resourcesStruct=[];
            if~isempty(obj)
                WarnId=warning('off','MATLAB:structOnObject');
                Cl1=onCleanup(@()warning(WarnId));
                resourcesStruct=arrayfun(@(x)rmfield(struct(x),{'DataSource','utility'}),obj.mData);
            end
        end
        function obj=removeSelection(obj,selectedRow)


            for Count=1:length(selectedRow)
                rowData=selectedRow{Count};
                matchedIndex=find((arrayfun(@(x)strcmp(x.FileName,rowData.FileName)&&...
                strcmp(x.SourceFolder,rowData.SourceFolder),...
                obj.mData)),1,'first');
                selectedIndexArray=true(size(obj.mData));
                selectedIndexArray(matchedIndex)=0;
                obj.mData=obj.mData(selectedIndexArray);
            end
        end
        function obj=updatePackageSpreadSheetInfo(obj,...
            SaveSourceCodeToFMU,...
            Generate32BitDLL,...
            PackagePath,...
            UIDArray)



            obj.packagePath=PackagePath;
            if~isempty(obj.mData)
                MatchingIndex=find(arrayfun(@(x)ismember(x.UID,UIDArray),obj.mData)>0);
                for Index=MatchingIndex
                    obj.mData(Index).DestinationConflict='';



                    if SaveSourceCodeToFMU&&obj.mData(Index).isIndexFile

                        obj.mData(Index).DestinationConflict=...
                        DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageDocumentConflict',...
                        fullfile(obj.mData(Index).SourceFolder,...
                        obj.mData(Index).FileName));
                        continue
                    end

                    if SaveSourceCodeToFMU&&obj.mData(Index).isSourceFile

                        obj.mData(Index).DestinationConflict=...
                        DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageSourcesConflict',...
                        fullfile(obj.mData(Index).SourceFolder,obj.mData(Index).FileName));
                        continue
                    end

                    if obj.mData(Index).isModelBinaryFile(Generate32BitDLL)

                        obj.mData(Index).DestinationConflict=...
                        DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageFileConflict',...
                        fullfile(obj.mData(Index).SourceFolder,...
                        obj.mData(Index).FileName),...
                        fullfile(obj.mData(Index).DestinationFolder,obj.mData(Index).FileName));
                        continue
                    end


                    if strcmp(obj.mData(Index).DestinationFolder,strcat('binaries',filesep))&&...
                        obj.mData(Index).hasFolderWithModelBinary(Generate32BitDLL)

                        ModelBinaryName=strcat(obj.modelName,internal.packageConfig.utility.getBinaryFileExtension);
                        obj.mData(Index).DestinationConflict=...
                        DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageFileConflict',...
                        fullfile(obj.mData(Index).SourceFolder,...
                        obj.mData(Index).FileName,ModelBinaryName),...
                        ModelBinaryName);
                        continue
                    end
                end
            end
        end
        function ifDestinationConflict=hasDestinationConflict(obj)


            ifDestinationConflict=any(arrayfun(@(x)~isempty(x.DestinationConflict),...
            obj.mData));
        end
    end
end