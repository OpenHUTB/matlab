function[filObj,boardSet]=loadBuildInfo(matfile)





    load(matfile);

    if exist('filStruct','var')~=1
        error(message('EDALink:loadBuildInfo:InvalidMATFile',matfile));
    end


    filObj=eda.internal.workflow.FILBuildInfo;



    curVersion=filObj.BuildInfoVersion.Major+...
    filObj.BuildInfoVersion.Minor/10;
    matVersion=filStruct.BuildInfoVersion.Major+...
    filStruct.BuildInfoVersion.Minor/10;

    if matVersion>curVersion
        warning(message('EDALink:loadBuildInfo:FutureObjVersion'));
    end

    try
        if~isempty(filStruct.Board)
            filObj.Board=filStruct.Board;
            boardSet=true;
        else
            boardSet=false;
        end
    catch me
        error(message('EDALink:loadBuildInfo:UndefinedBoardClass',filStruct.BoardClass,filStruct.Board,filStruct.BoardClass,filStruct.Board));
    end



    prop={'FPGASystemClockFrequency',...
    'BoardObj',...
    'IPAddress',...
    'MACAddress',...
    'DUTName',...
    'ResetAssertedLevel',...
    'ClockEnableAssertedLevel',...
    'AutoPortInfo',...
    'FPGAVendor'};
    for n=1:numel(prop)


        if strcmp(prop{n},'BoardObj')&&~isfield(filStruct,'BoardObj')
            continue;
        elseif strcmp(prop{n},'FPGASystemClockFrequency')&&~isfield(filStruct,'FPGASystemClockFrequency')
            filObj.(prop{n})=filStruct.SynthesisFrequency;
        else
            filObj.(prop{n})=filStruct.(prop{n});
        end
    end

    if isfield(filStruct,'Tool')
        filObj.Tool=filStruct.Tool;
    end



    for n=1:numel(filStruct.SourceFiles.FilePath)

        FilePath=filStruct.SourceFiles.FilePath{n};
        FileType=filStruct.SourceFiles.FileType{n};

        if filesep=='\'
            FilePath=strrep(FilePath,'/','\');
        else
            FilePath=strrep(FilePath,'\','/');
        end

        filObj.addSourceFile(FilePath,FileType);
    end

    if filStruct.TopLevelIndex~=-1
        filObj.setTopLevelSourceFile(filStruct.TopLevelIndex);
    end


    for n=1:numel(filStruct.DUTPorts.PortName)
        filObj.addDUTPort(filStruct.DUTPorts.PortName{n},...
        filStruct.DUTPorts.PortDirection{n},...
        filStruct.DUTPorts.PortWidth{n},...
        filStruct.DUTPorts.PortType{n});
    end


    if isfield(filStruct,'OutputDataTypes')
        for n=1:numel(filStruct.OutputDataTypes.Name)
            filObj.addOutputDataType(filStruct.OutputDataTypes.Name{n},...
            filStruct.OutputDataTypes.BitWidth{n},...
            filStruct.OutputDataTypes.DataType{n},...
            filStruct.OutputDataTypes.Sign{n},...
            filStruct.OutputDataTypes.FracLen{n});
        end
    end


    if isfield(filStruct,'OutputFolder')
        OutputFolder=filStruct.OutputFolder;

        if filesep=='\'
            OutputFolder=strrep(OutputFolder,'/','\');
        else
            OutputFolder=strrep(OutputFolder,'\','/');
        end
        filObj.setOutputFolder(OutputFolder);
    end



