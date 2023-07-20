function setupToolPath(varargin)






    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    validateInputArgs(varargin{:});
    inputArgs=parseInputArgs(varargin{:});
    toolName=inputArgs.ToolName;
    if strcmpi(toolName,'Microsemi Libero SoC')
        toolName='Microchip Libero SoC';
    end
    toolPath=inputArgs.ToolPath;


    validateToolName(toolName);
    toolDirPath=validateToolPath(toolName,toolPath);


    if strcmpi(toolName,'Xilinx ISE')
        setupToolPathXilinxISE(toolName,toolDirPath);
    elseif strcmpi(toolName,'Xilinx Vivado')
        setupToolPathXilinxVivado(toolName,toolDirPath);
    elseif strcmpi(toolName,'Altera Quartus II')
        setupToolPathAlteraQuartus(toolName,toolDirPath);
    elseif strcmpi(toolName,'Microchip Libero SoC')
        setupToolPathMicrosemiLiberoSoC(toolName,toolDirPath);
    elseif strcmpi(toolName,'Intel Quartus Pro')
        setupToolPathIntelQuartusPro(toolName,toolDirPath);
    end


    function setupToolPathXilinxVivado(toolName,toolDirPath)


        absPathStr=getAbsoluteFolderPath(toolDirPath);
        setenv('XILINX_VIVADO',absPathStr);

        prependToolPath(toolName,absPathStr);


        if ispc
            prependToolPath(toolName,fullfile(absPathStr,'..','lib','win64.o'));
        end

    end




    function setupToolPathXilinxISE(toolName,toolDirPath)


        absPathStr=getAbsoluteFolderPath(toolDirPath);


        [xilinxInstallPath,xilinxPlatformStr]=getXilinxInstalltionPath(absPathStr,toolDirPath);
        ISEInstallPath=fullfile(xilinxInstallPath,'ISE');
        EDKInstallPath=fullfile(xilinxInstallPath,'EDK');
        PAInstallPath=fullfile(xilinxInstallPath,'PlanAhead');


        fprintf('Setting XILINX environment variable to:\n%s\n',ISEInstallPath);
        setenv('XILINX',ISEInstallPath);


        ISEToolPath=fullfile(ISEInstallPath,'bin',xilinxPlatformStr);
        ISELibPath=fullfile(ISEInstallPath,'lib',xilinxPlatformStr);
        if ispc
            isePath=[ISEToolPath,pathsep,ISELibPath];
        else
            isePath=ISEToolPath;
        end


        fprintf('Setting XILINX_EDK environment variable to:\n%s\n',EDKInstallPath);
        setenv('XILINX_EDK',EDKInstallPath);


        EDKToolPath=fullfile(EDKInstallPath,'bin',xilinxPlatformStr);
        EDKLibPath=fullfile(EDKInstallPath,'lib',xilinxPlatformStr);
        EDKGnuwinPath=fullfile(EDKInstallPath,'gnuwin','bin');
        if ispc
            edkPath=[EDKToolPath,pathsep,EDKLibPath,pathsep,EDKGnuwinPath];
        else
            edkPath=EDKToolPath;
        end










        fprintf('Setting XILINX_PLANAHEAD environment variable to:\n%s\n',PAInstallPath);
        setenv('XILINX_PLANAHEAD',PAInstallPath);


        PAToolPath=fullfile(PAInstallPath,'bin');
        paPath=PAToolPath;


        addPath=[isePath,pathsep,edkPath,pathsep,paPath];
        prependToolPath(toolName,addPath);
    end


    function[xilinxInstallPath,xilinxPlatformStr]=getXilinxInstalltionPath(absPathStr,toolDirPath)


        regsepStr=filesep;
        if strcmp(regsepStr,'\')
            regsepStr='\\';
        end
        pathCell=regexp(absPathStr,regsepStr,'split');


        if length(pathCell)<3||~strcmpi(pathCell{end-1},'bin')
            error(message('HDLShared:setuptoolpath:InvalidXilinxPath',toolDirPath));
        end


        xilinxPlatformStr=pathCell{end};
        xilinxInstallPath=strrep(absPathStr,[filesep,'ISE',filesep,fullfile('bin',xilinxPlatformStr)],'');

    end


    function setupToolPathAlteraQuartus(toolName,toolDirPath)


        absPathStr=getAbsoluteFolderPath(toolDirPath);
        alteraToolPath=absPathStr;


        prependToolPath(toolName,alteraToolPath);


        if strcmpi(computer,'glnxa64')

            fprintf('Setting QUARTUS_64BIT environment variable to 1 to turn on 64-bit processing.\n');
            setenv('QUARTUS_64BIT','1');
        end

    end


    function setupToolPathMicrosemiLiberoSoC(toolName,toolDirPath)


        absPathStr=getAbsoluteFolderPath(toolDirPath);
        liberoToolPath=absPathStr;
        prependToolPath(toolName,liberoToolPath);

    end

    function setupToolPathIntelQuartusPro(toolName,toolDirPath)


        if ispc&&strcmp(toolDirPath(1:2),'\\')

            error(message('hdlcommon:workflow:UNCToolPath',toolName));
        end
        absPathStr=getAbsoluteFolderPath(toolDirPath);
        IntelToolPath=absPathStr;
        prependToolPath(toolName,IntelToolPath);

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


    function toolDirPath=validateToolPath(toolName,toolPath)

        if strcmpi(toolName,'Xilinx ISE')
            toolExecutable='ise';
            toolExecutableExclude='';
            toolExample=sprintf([...
            '  hdlsetuptoolpath(''ToolName'', ''Xilinx ISE'', ...\n',...
            '                   ''ToolPath'', ''C:\\Xilinx\\14.2\\ISE_DS\\ISE\\bin\\nt64\\ise.exe'');\n']);
        elseif strcmpi(toolName,'Xilinx Vivado')
            toolExecutable='vivado';
            toolExecutableExclude='';
            toolExample=sprintf([...
            '  hdlsetuptoolpath(''ToolName'', ''Xilinx Vivado'', ...\n',...
            '                   ''ToolPath'', ''C:\\Xilinx\\Vivado\\2013.4\\bin\\vivado.bat'');\n']);
            example1=sprintf([...
            '  hdlsetuptoolpath(''ToolName'', ''Xilinx Vivado'', ...\n',...
            '                   ''ToolPath'', ''C:\\Xilinx\\Vivado\\2013.4\\bin);\n']);
            str1='Directory specified for ''ToolPath'' should contain executable.';
            strNote=sprintf('\nNote: Please note that Xilinx Vivado launcher for Windows is a ''.bat'' file.\n If you are providing full path to the launcher to hdlsetuptoolpath, make sure to provide correct ''.bat'' file');

            toolExample=sprintf('%s\n             or \n\n%s\n\n%s\n%s',toolExample,example1,str1,strNote);

        elseif strcmpi(toolName,'Altera Quartus II')
            toolExecutable='quartus';
            toolExecutableExclude='qpro';
            toolExample=sprintf([...
            '  hdlsetuptoolpath(''ToolName'', ''Altera Quartus II'', ...\n',...
            '                   ''ToolPath'', ''C:\\Altera\\12.0\\quartus\\bin\\quartus.exe'');\n']);

        elseif strcmpi(toolName,'Microchip Libero SoC')
            toolExecutable='libero';
            toolExecutableExclude='';
            toolExample=sprintf([...
            '  hdlsetuptoolpath(''ToolName'', ''Microchip Libero SoC'', ...\n',...
            '                   ''ToolPath'', ''C:\\Microsemi\\Libero_SoC_v11.8\\Designer\\bin\\libero.exe'');\n']);

        elseif strcmpi(toolName,'Intel Quartus Pro')
            toolExecutable='qpro';
            toolExecutableExclude='';
            toolExample=sprintf([...
            '  hdlsetuptoolpath(''ToolName'', ''Intel Quartus Pro'', ...\n',...
            '                   ''ToolPath'', ''C:\\intelFPGA_pro\\18.0\\quartus\\bin64\\qpro.exe'');\n']);
        end

        if ispc
            if strcmpi(toolName,'Xilinx Vivado')
                toolExtension='.bat';
            else
                toolExtension='.exe';
            end
        else
            toolExtension='';
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


            if~isempty(toolExecutableExclude)
                toolExecutableExcludeFile=sprintf('%s%s',toolExecutableExclude,toolExtension);
                toolExecutableExcludePath=fullfile(toolPath,toolExecutableExcludeFile);
                if exist(toolExecutableExcludePath,'file')
                    error(message('HDLShared:setuptoolpath:InvalidQstdToolPath',toolName,toolPath,toolName,toolName));
                end
            end
            toolDirPath=toolPath;

        else

            [toolDirPath,nameStr,ext]=fileparts(toolPath);


            if~strcmpi(nameStr,toolExecutable)||...
                (ispc&&strcmpi(toolName,'Xilinx Vivado')&&...
                ~strcmpi('.bat',ext))
                error(message('HDLShared:setuptoolpath:InvalidToolPath',toolPath,toolName,toolExecutable,toolExtension,toolExample));
            end
        end

    end


    function validateToolName(toolName)

        if strcmpi(toolName,'Xilinx ISE')||...
            strcmpi(toolName,'Altera Quartus II')||...
            strcmpi(toolName,'Xilinx Vivado')||...
            strcmpi(toolName,'Microchip Libero SoC')||...
            strcmpi(toolName,'Intel Quartus Pro')
            return;
        end

        error(message('HDLShared:setuptoolpath:InvalidToolName',toolName,...
        sprintf('\n  ''Xilinx ISE'',\n  ''Xilinx Vivado'',\n  ''Altera Quartus II'',\n ''Microchip Libero SoC'', \n ''Intel Quartus Pro''')));
    end


    function validateInputArgs(varargin)

        if nargin~=4
            helpMsg=help('hdlsetuptoolpath');
            error(message('HDLShared:setuptoolpath:InvalidInput',helpMsg));
        end

    end


    function inputArgs=parseInputArgs(varargin)

        persistent p;
        if isempty(p)
            p=inputParser;
            p.addParameter('ToolName','');
            p.addParameter('ToolPath','');
        end

        p.parse(varargin{:});
        inputArgs=p.Results;

    end



end
