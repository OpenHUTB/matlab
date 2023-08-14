classdef utilityAbstract<handle


    methods(Abstract,Static)
        package=getPackageInfo(model)
        out=ifDuplicateEntry(rowStructArray,rowStruct)
        out=FMURootFolders
        out=sourcePathExist(rowStruct)
        out=invalidSourcePath(rowStruct,FMUWorkingDir)
        out=BackgroundColor(Color)
        out=statusIconPath(Icon)
        out=getArch
        out=getBinaryFileExtension
        out=getModelBinaryFolder(is32BitDLL)
        out=isIndexFile(RowStruct)
        out=isSourceFile(RowStruct)
        out=isModelBinaryFile(RowStruct,ModelName,Generate32BitDLL)
        out=isInValidDestinationPath(RowStruct)
        FolderPath=updateFileSep(FolderPath)
    end
end