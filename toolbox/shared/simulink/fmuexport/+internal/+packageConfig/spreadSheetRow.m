classdef spreadSheetRow<handle


    properties
        FileName='';
        FileType='';
        SourceFolder='';
        DestinationFolder=...
        getString(message('FMUExport:FMU:FMU2ExpCSPackageDestinationText'));
DataSource
        DestinationConflict='';
        UID=-1;
    end
    properties(Hidden)
        utility=internal.packageConfig.utility;
    end
    methods
        function this=spreadSheetRow(varargin)
            switch nargin
            case 4


                this.DataSource=varargin{1};
                if isempty(varargin{2})


                    [this.SourceFolder,this.FileName,Ext]=fileparts(varargin{3});

                    this.FileName=strcat(this.FileName,Ext);
                    this.FileType='folder';
                else
                    this.FileName=varargin{2};
                    this.SourceFolder=varargin{3};
                    [~,~,this.FileType]=fileparts(this.FileName);
                end


                this.UID=varargin{4};
            case 6
                this.DataSource=varargin{1};
                this.FileName=varargin{2};
                this.FileType=varargin{3};
                this.SourceFolder=varargin{4};
                this.DestinationFolder=varargin{5};
                this.UID=varargin{6};
            end
        end

        function label=getDisplayLabel(obj)
            label=obj.FileName;
        end

        function propType=getPropDataType(~,~)
            propType='string';
        end

        function iconFile=getDisplayIcon(obj)

            switch obj.FileType
            case 'folder'
                iconFileName='Folder.png';
            case '.m'
                iconFileName='filetype_m.gif';
            case '.mat'
                iconFileName='filetype_mat.gif';
            case{'.slx','.mdl'}
                iconFileName='SimulinkModelIcon.png';
            case '.html'
                iconFileName='filetype_web.png';
            case{'cpp','h','dll','so'}
                iconFileName='filetype_generic.gif';
            case{'.jpeg','.jpg','.png'}
                iconFileName='image.png';
            otherwise
                iconFileName='filetype_txt.png';
            end
            iconFile=fullfile(matlabroot,'toolbox','shared','dastudio','resources',iconFileName);
        end

        function propValue=getPropValue(obj,propName)
            switch propName
            case getString(message('FMUExport:FMU:FMU2ExpCSPackageEntityName'))
                propValue=obj.FileName;
            case getString(message('FMUExport:FMU:FMU2ExpCSPackageSourceFolder'))
                propValue=obj.SourceFolder;
            case getString(message('FMUExport:FMU:FMU2ExpCSPackageDestinationFolder'))
                propValue=obj.DestinationFolder;
            otherwise
                propValue='';
            end
        end

        function setPropValue(obj,propName,propValue)
            switch propName

            case getString(message('FMUExport:FMU:FMU2ExpCSPackageEntityName'))
                obj.FileName=propValue;

            case getString(message('FMUExport:FMU:FMU2ExpCSPackageSourceFolder'))
                obj.SourceFolder=propValue;

            case getString(message('FMUExport:FMU:FMU2ExpCSPackageDestinationFolder'))
                obj.DestinationFolder=internal.packageConfig.utility.updateFileSep(propValue);
            otherwise

            end
        end

        function isReadOnly=isReadonlyProperty(~,propName)
            switch propName

            case{getString(message('FMUExport:FMU:FMU2ExpCSPackageEntityName')),...
                getString(message('FMUExport:FMU:FMU2ExpCSPackageSourceFolder'))}
                isReadOnly=true;
            otherwise
                isReadOnly=false;
            end
        end

        function isValid=isValidProperty(~,propName)
            switch propName

            case{getString(message('FMUExport:FMU:FMU2ExpCSPackageEntityName')),...
                getString(message('FMUExport:FMU:FMU2ExpCSPackageSourceFolder')),...
                getString(message('FMUExport:FMU:FMU2ExpCSPackageDestinationFolder'))}
                isValid=true;
            otherwise
                isValid=false;

            end
        end


        function getPropertyStyle(obj,propName,propertyStyle)
            switch propName

            case{getString(message('FMUExport:FMU:FMU2ExpCSPackageEntityName')),...
                getString(message('FMUExport:FMU:FMU2ExpCSPackageSourceFolder'))}
                if obj.utility.invalidSourcePath(obj)


                    propertyStyle.BackgroundColor=...
                    obj.utility.BackgroundColor('Red');
                    propertyStyle.Tooltip=...
                    DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageInvalidSourcePath',...
                    fullfile(obj.SourceFolder,obj.FileName));
                    propertyStyle.Icon=...
                    obj.utility.statusIconPath('error');
                    propertyStyle.IconAlignment='left';
                end

            case getString(message('FMUExport:FMU:FMU2ExpCSPackageDestinationFolder'))
                if inValidDestinationPath(obj)



                    propertyStyle.BackgroundColor=...
                    obj.utility.BackgroundColor('Red');
                    propertyStyle.Tooltip=...
                    DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageInvalidDestinationFolder',...
                    obj.DestinationFolder);
                    propertyStyle.Icon=...
                    obj.utility.statusIconPath('error');
                    propertyStyle.IconAlignment='left';
                elseif obj.utility.ifDuplicateEntry(obj.DataSource.mData,obj)


                    propertyStyle.BackgroundColor=...
                    obj.utility.BackgroundColor('Red');
                    propertyStyle.Tooltip=...
                    DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageIdenticalDestinationPath');
                    propertyStyle.Icon=...
                    obj.utility.statusIconPath('error');
                    propertyStyle.IconAlignment='left';
                elseif~isempty(obj.DestinationConflict)


                    propertyStyle.Tooltip=...
                    obj.DestinationConflict;
                    modelBinaryFileName=strcat(obj.DataSource.modelName,...
                    internal.packageConfig.utility.getBinaryFileExtension);
                    if ismember(obj.DestinationConflict,{DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageFileConflict',...
                        fullfile(obj.SourceFolder,obj.FileName),...
                        fullfile(obj.DestinationFolder,obj.FileName)),...
                        DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageFileConflict',...
                        fullfile(obj.SourceFolder,...
                        obj.FileName,modelBinaryFileName),...
                        modelBinaryFileName)})


                        propertyStyle.BackgroundColor=...
                        obj.utility.BackgroundColor('Red');
                        propertyStyle.Icon=...
                        obj.utility.statusIconPath('error');
                    else



                        propertyStyle.BackgroundColor=...
                        obj.utility.BackgroundColor('Yellow');
                        propertyStyle.Icon=...
                        obj.utility.statusIconPath('caution');
                    end
                    propertyStyle.IconAlignment='left';
                else
                    propertyStyle.Tooltip=...
                    DAStudio.message('FMUExport:FMU:FMU2ExpCSPackageDocumentTooltip',...
                    fullfile(obj.SourceFolder,obj.FileName),obj.DestinationFolder);
                end
            otherwise

            end
        end



        function out=isIndexFile(obj)


            out=obj.utility.isIndexFile(obj);
        end
        function out=isSourceFile(obj)


            out=obj.utility.isSourceFile(obj);
        end
        function out=isModelBinaryFile(obj,Generate32BitDLL)

            out=obj.utility.isModelBinaryFile(obj,...
            obj.DataSource.modelName,...
            Generate32BitDLL);
        end
        function out=hasFolderWithModelBinary(obj,Generate32BitDLL)

            out=obj.utility.hasFolderWithModelBinary(obj,...
            obj.DataSource.modelName,...
            Generate32BitDLL);
        end
        function out=inValidDestinationPath(obj)


            out=obj.utility.isInValidDestinationPath(obj);
        end
    end
end