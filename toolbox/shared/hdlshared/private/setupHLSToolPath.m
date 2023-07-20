function setupHLSToolPath(varargin)





    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    validateInputArgs(varargin{:});

    inputArgs=parseInputArgs(varargin{:});
    toolName=inputArgs.ToolName;
    toolPath=inputArgs.ToolPath;
    simulationToolPath=inputArgs.SimulationToolPath;


    validateToolName(toolName);
    toolDirPath=validateToolPath(toolName,toolPath);


    if strcmpi(toolName,'Cadence Stratus')
        xceliumToolDirPath=validateToolPath('Xcelium',simulationToolPath);
        setupToolPathCadenceStratus(toolName,toolDirPath,xceliumToolDirPath);
    end

end



function setupToolPathCadenceStratus(toolName,toolDirPath,xceliumToolPath)


    absPathStr=getAbsoluteFolderPath(toolDirPath);
    stratusToolPath=absPathStr;
    prependToolPath(toolName,stratusToolPath);
    prependToolPath('Xcelium',getAbsoluteFolderPath(xceliumToolPath));

end


function prependToolPath(toolName,addPath)



    oldPath=getenv('PATH');
    fprintf('Prepending following %s path(s) to the system path:\n%s\n',toolName,addPath);
    newPath=[addPath,pathsep,oldPath];
    setenv('PATH',newPath);

end


function absolutePath=getAbsoluteFolderPath(folderPath)

    currentPath=pwd;
    if isfolder(folderPath)
        cd(folderPath);
        absolutePath=pwd;
        cd(currentPath);
    else
        error(message('HDLShared:setuptoolpath:InvalidDirectory',folderPath));
    end
end


function validateToolName(toolName)

    if strcmpi(toolName,'Cadence Stratus')
        return;
    end

    error(message('HDLShared:setuptoolpath:InvalidToolName',toolName,...
    sprintf('\n ''Cadence Stratus''')));
end


function toolDirPath=validateToolPath(toolName,toolPath)
    if strcmpi(toolName,'Cadence Stratus')
        toolExecutable='stratus_ide';
        toolExtension='';
        toolExample=sprintf([...
        'hdlsetuphlstoolpath(''ToolName'', ''Cadence Stratus'', ...\n',...
        '                    ''ToolPath'', ''/local/cadence/stratus/installs/bin'', ...\n',...
        '                    ''SimulationToolPath'', ''/local/incisive/tools/bin'');']);
    elseif strcmpi(toolName,'Xcelium')
        toolExecutable='xrun';
        toolExtension='';
        toolExample=sprintf([...
        'hdlsetuphlstoolpath(''ToolName'', ''Cadence Stratus'', ...\n',...
        '                    ''ToolPath'', ''/local/cadence/stratus/installs/bin'', ...\n',...
        '                    ''SimulationToolPath'', ''/local/incisive/tools/bin'');']);
    end


    if~exist(toolPath,'file')
        error(message('HDLShared:setuptoolpath:InvalidPath',toolPath));
    end

    if exist(toolPath,'dir')

        toolExecutableFile=sprintf('%s%s',toolExecutable,toolExtension);
        toolFilePath=fullfile(toolPath,toolExecutableFile);
        if~exist(toolFilePath,'file')
            error(message('HDLShared:setuptoolpath:InvalidToolPath',toolPath,toolName,toolExecutable,toolExtension,toolExample));
        end

        toolDirPath=toolPath;

    else

        [toolDirPath,nameStr,~]=fileparts(toolPath);


        if~strcmpi(nameStr,toolExecutable)
            error(message('HDLShared:setuptoolpath:InvalidToolPath',toolPath,toolName,toolExecutable,toolExtension,toolExample));
        end
    end

end


function validateInputArgs(varargin)

    if nargin~=6
        helpMsg=help('hdlsetuphlstoolpath');
        error(message('HDLShared:setuptoolpath:InvalidHLSToolInput',helpMsg));
    end

end


function inputArgs=parseInputArgs(varargin)

    persistent p;
    if isempty(p)
        p=inputParser;
        p.addParameter('ToolName','');
        p.addParameter('ToolPath','');
        p.addParameter('SimulationToolPath','');
    end

    p.parse(varargin{:});
    inputArgs=p.Results;

end
