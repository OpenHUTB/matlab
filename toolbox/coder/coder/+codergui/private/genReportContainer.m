function outputFile=genReportContainer(contribContext,varargin)



    reportFolder=contribContext.ReportContext.ReportDirectory;

    assert(isAbsolute(reportFolder),'reportFolder should be absolute: "%s"',reportFolder);

    manifestFile=fullfile(reportFolder,coder.report.ContributionContext.MANIFEST_FILENAME);
    assert(isfile(manifestFile),'Requires a manifest file in the root of the folder');

    options=processInputs(varargin);
    outputFile=normalizeOutputPath(options.OutputFile,reportFolder);
    partitions=options.PartitionDefinitions;
    deleteFiles=options.DeletePackagedFiles;

    category=contribContext.ReportType.FileCategory;
    description=contribContext.ReportType.getFileDescription(contribContext);

    fileList={};
    findFiles(reportFolder);
    if~isempty(partitions)
        partitionFiles=fullfile(reportFolder,{partitions.File});
        fileList=[fileList;partitionFiles(~ismember(partitionFiles,fileList))];
    end

    buildReportContainer();

    if deleteFiles
        deleteFolderContents(reportFolder,{outputFile});
    end


    function findFiles(folder)
        [children,isDir]=listFiles(folder);
        leafs=children(~isDir);
        fileList(end+1:end+numel(leafs))=fullfile(folder,{leafs.name});

        subFolders=children(isDir);
        for ii=1:numel(subFolders)
            findFiles(fullfile(folder,subFolders(ii).name));
        end
    end

    function buildReportContainer()
        model=mf.zero.Model();
        package=coderapp.internal.file.archive.Package(model,...
        struct('FilePath',outputFile,'Category',category,'Description',description));
        relativeFileNames=erase(fileList,reportFolder);
        relativeFileNames=regexprep(relativeFileNames,"\\","/");
        for f=1:numel(relativeFileNames)
            package.addFile(relativeFileNames{f},fileList{f});
        end
        package.save();
    end
end

function options=processInputs(inputs)
    ip=inputParser();
    ip.addParameter('OutputFile','',@ischar);
    ip.addParameter('PartitionDefinitions',[],@(v)isa(v,'coder.report.PartitionDefinition'));
    ip.addParameter('DeletePackagedFiles',true,@islogical);
    ip.parse(inputs{:});
    options=ip.Results;
end

function deleteFolderContents(folder,excludes)
    [children,isDir]=listFiles(folder);

    files=children(~isDir);
    fileNames=fullfile({files.folder},{files.name});
    fileNames=fileNames(~ismember(fileNames,excludes));
    for i=1:numel(fileNames)
        delete(fileNames{i});
    end

    subFolders=children(isDir);
    subFolderNames=fullfile({subFolders.folder},{subFolders.name});
    subFolderNames=subFolderNames(~ismember(subFolderNames,excludes));
    for i=1:numel(subFolderNames)
        rmdir(subFolderNames{i},'s');
    end
end

function[children,isDir]=listFiles(folder)
    children=dir(folder);
    children=children(~ismember({children.name},{'.','..'}));
    isDir=[children.isdir];
end

function outputFile=normalizeOutputPath(outputFile,reportFolder)
    if isempty(outputFile)

        outputFile='report.mldatx';
    else

        [parentFile,filename]=fileparts(outputFile);
        outputFile=fullfile(parentFile,[filename,'.mldatx']);
    end
    if~isAbsolute(outputFile)

        outputFile=fullfile(reportFolder,outputFile);
    end
end

function absolute=isAbsolute(file)
    absolute=codergui.internal.util.isAbsolute(file);
end
