function status=setup()










    status=0;
    if~ispc
        disp('DOORS integration is only supported on Windows machines.');
        return;
    end

    doors_welcome();

    [names,dirs]=find_in_registry();

    [doorsDir]=doors_select(names,dirs);

    if~isempty(doorsDir)
        try
            status=doors_install(doorsDir);
            if status
                enableDoorsIntegration();
            end
        catch Mex
            disp(['Installation failed:  ',Mex.message]);
            status=0;
        end
    else
        disp('Target DOORS installation not specified. Exit.');
        status=0;
    end
end

function enableDoorsIntegration()
    rmi.settings_mgr('set','isDoorsSetup',true);
    rmipref('SelectionLinkDoors',true);

    rmi.menus_selection_links([]);
    rmiml.selectionLink([]);
end

function doors_welcome()
    disp(' ')
    disp('Welcome to the DOORS-MATLAB Interface setup utility.')
    disp('This will perform all the steps necessary so that you')
    disp('can start using Simulink and Stateflow with DOORS.')
    disp(' ')
    disp('NOTE: You should close DOORS before continuing with')
    disp('this installation.')
end

function[names,dirs]=find_in_registry()
    names={};
    dirs={};

    disp(' ')
    disp('Checking Windows Registry to locate DOORS installation(s)...');

    masterKeys={...
    'HKEY_LOCAL_MACHINE',...
    'HKEY_CURRENT_USER'};

    productKeys={...
    'SOFTWARE\Telelogic\DOORS',...
    'SOFTWARE\Wow6432Node\Telelogic\DOORS',...
    'SOFTWARE\IBM\DOORS',...
    'SOFTWARE\Wow6432Node\IBM\DOORS'};

    for i=1:length(masterKeys)
        for j=1:length(productKeys)
            [names,dirs]=rmiut.reg_install_dirs(masterKeys{i},productKeys{j},names,dirs);
        end
    end
end

function[doorsDir]=doors_select(names,dirs)
    i=0;
    if~isempty(dirs)
        disp(' ');
        disp('Please select DOORS installation to configure for MATLAB:')
        while i<length(names)
            i=i+1;
            disp(['    [',num2str(i),']  ',names{i},'  ',dirs{i}]);
        end
        disp(' ');
        disp('If your target DOORS Client installation is not listed above,');
        disp('select one of the following options:');
    else
        disp(' ');
        disp('Unable to locate DOORS Client installation.');
        disp('Please select one of the following options:');
    end
    i=i+1;
    disp(['    [',num2str(i),']  Manually enter DOORS installation directory']);
    i=i+1;
    disp(['    [',num2str(i),']  Exit, making no changes']);
    i=i+1;
    disp(['    [',num2str(i),']  Make no changes in DOORS directory but ensure DOORS integration is enabled in MATLAB']);

    disp(' ')
    index=input('Selection: ');
    while isempty(index)||ischar(index)||floor(index)~=index||index<1||index>i
        disp('Invalid Input.  Please select from the list above');
        index=input('Selection: ');
    end

    if index==length(names)+1
        doorsDir=get_from_user();
    elseif index==length(names)+2
        doorsDir='';
    elseif index==length(names)+3
        enableDoorsIntegration();
        doorsDir='';
    else
        doorsDir=dirs{index};
    end
end


function doorsDir=get_from_user()
    doorsDir=input('Please enter the location of DOORS installation: ','s');
    attempt=1;
    while isempty(doorsDir)||exist(doorsDir,'dir')~=7||~validate_dir(doorsDir)
        attempt=attempt+1;
        if attempt>3
            disp(['Invalid input: ''',doorsDir,'''. Please try again or (q)uit']);
        else
            disp(['Invalid input: ''',doorsDir,'''. Please try again.']);
        end
        disp(' ');
        doorsDir=input('Please enter the location of DOORS installation: ','s');
        if strcmp(doorsDir,'q')
            doorsDir='';
            break;
        end
    end
end

function result=validate_dir(doorsRoot)
    if exist(fullfile(doorsRoot,'lib','dxl','startup.dxl'),'file')==2
        result=true;
    else
        disp(' ');
        disp([doorsRoot,' is not a DOORS Client directory.']);
        result=false;
    end
end


function status=doors_install(doorsRoot)

    mlRoot=matlabroot;

    dxlDir=fullfile(doorsRoot,'lib','dxl');
    addinsDir=fullfile(dxlDir,'addins');
    dmiDir=fullfile(addinsDir,'dmi');
    backupDir=fullfile(dmiDir,'originals');


    disp(' ')
    if~exist(dmiDir,'dir')
        dmiExisted=0;
        disp(['Creating installation directory: ',dmiDir]);
        [status,msg]=mkdir(dmiDir);
        if status==0
            throwError('Slvnv:reqmgt:setup_doors:CouldNotMakeDir',[dmiDir,': ',msg]);
        end
    else
        dmiExisted=1;
    end
    if~exist(backupDir,'dir')
        backupExisted=0;
        disp(['Creating backup directory: ',backupDir]);
        [status,msg]=mkdir(backupDir);
        if status==0
            throwError('Slvnv:reqmgt:setup_doors:CouldNotMakeDir',[backupDir,': ',msg]);
        end
    else
        backupExisted=1;
    end


    rmiDir=fullfile(mlRoot,'toolbox','shared','reqmgt','dxl');


    if dmiExisted&&backupExisted
        installedFileInfo=dir(fullfile(dmiDir,'dmi.inc'));
        matlabFileInfo=dir(fullfile(rmiDir,'dmi.inc'));
        if installedFileInfo.datenum>=matlabFileInfo.datenum
            disp([fullfile(rmiDir,'dmi.inc'),' is already the latest version.']);
            status=1;
            return;
        end
    end



    uninstallFile=fullfile(dxlDir,'addins','uninstall_dmi.bat');
    uninstallFid=fopen(uninstallFile,'w');
    if uninstallFid==-1
        throwError('Slvnv:reqmgt:setup_doors:CouldNotCreateFile',uninstallFile);
    end
    uninstall_head(uninstallFid,uninstallFile);


    disp('Backing up existing file versions');
    backup_file(fullfile(dmiDir,'dmi.hlp'),backupDir,uninstallFid);
    backup_file(fullfile(dmiDir,'dmi.idx'),backupDir,uninstallFid);
    backup_file(fullfile(dmiDir,'dmi.inc'),backupDir,uninstallFid);
    backup_file(fullfile(dmiDir,'runsim.dxl'),backupDir,uninstallFid);
    backup_file(fullfile(dmiDir,'selblk.dxl'),backupDir,uninstallFid);
    backup_file(fullfile(addinsDir,'addins.idx'),backupDir,uninstallFid);
    backup_file(fullfile(addinsDir,'addins.hlp'),backupDir,uninstallFid);
    backup_file(fullfile(dxlDir,'startup.dxl'),backupDir,uninstallFid);
    backup_file(fullfile(dmiDir,'install_log.txt'),backupDir,uninstallFid);


    if~backupExisted
        fprintf(uninstallFid,'rmdir /s /q "%s"\n',backupDir);
    end
    if~dmiExisted
        fprintf(uninstallFid,'rmdir /s /q "%s"\n',dmiDir);
    end
    fclose(uninstallFid);

    logFilePath=fullfile(dmiDir,'install_log.txt');
    installLogFile=fopen(logFilePath,'w');
    if installLogFile==-1
        throwError('Slvnv:reqmgt:setup_doors:CouldNotCreateFile',logFilePath);
    end


    log_head(installLogFile,backupDir);

    install_msg('Copying DMI files',installLogFile);
    copy_single_file(fullfile(rmiDir,'dmi.hlp'),fullfile(dmiDir,'dmi.hlp'),installLogFile);
    copy_single_file(fullfile(rmiDir,'dmi.idx'),fullfile(dmiDir,'dmi.idx'),installLogFile);
    copy_single_file(fullfile(rmiDir,'dmi.inc'),fullfile(dmiDir,'dmi.inc'),installLogFile);
    copy_single_file(fullfile(rmiDir,'runsim.dxl'),fullfile(dmiDir,'runsim.dxl'),installLogFile);
    copy_single_file(fullfile(rmiDir,'selblk.dxl'),fullfile(dmiDir,'selblk.dxl'),installLogFile);
    copy_single_file(fullfile(rmiDir,'cleanmod.dxl'),fullfile(dmiDir,'cleanmod.dxl'),installLogFile);

    install_msg('Updating Addins',installLogFile);
    if exist(fullfile(addinsDir,'addins.idx'),'file')
        add_line_if_needed(fullfile(addinsDir,'addins.idx'),...
        'user    U _ User',...
        'dmi     M _ MATLAB',...
        installLogFile);
    else
        install_msg('Copying Registration file addins.idx',installLogFile);
        copy_single_file(fullfile(rmiDir,'addins.idx'),fullfile(addinsDir,'addins.idx'),installLogFile);
    end

    if exist(fullfile(addinsDir,'addins.hlp'),'file')
        add_line_if_needed(fullfile(addinsDir,'addins.hlp'),...
        'nonsense',...
        'place to start new pull downs',...
        installLogFile);
    else
        install_msg('Copying Registration file addins.hlp',installLogFile);
        copy_single_file(fullfile(rmiDir,'addins.hlp'),fullfile(addinsDir,'addins.hlp'),installLogFile);
    end

    install_msg('Updating Startup registration',installLogFile);
    startupFile=fullfile(dxlDir,'startup.dxl');


    if~exist(startupFile,'file')
        install_msg(['Error: could not locate startup file: ',startupFile],installLogFile);
    else
        add_line_if_needed(startupFile,...
        '// Include all user defined files below this comment',...
        '#include <addins/dmi/dmi.inc>',...
        installLogFile);
    end

    log_tail(installLogFile,uninstallFile);
    fclose(installLogFile);
    disp(' ');
    disp('Installation succeeded');
    disp(['See log "',fullfile(dmiDir,'install_log.txt'),'" for details']);
    status=1;

    if rmidoors.isAppRunning('nodialog')
        disp('    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
        disp('    !!    Please restart IBM Rational DOORS    !!');
        disp('    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    end

end


function log_head(logFile,backupDir)
    str=evalc('ver(''slvnv'')');
    fprintf(logFile,'MATLAB-DOORS Installation Log File\n');
    fprintf(logFile,'Installation started: %s\n',datestr(now));
    fprintf(logFile,'MATLAB Root Directory: %s\n',matlabroot);
    fprintf(logFile,'\n%s\n',str);
    fprintf(logFile,'Backup versions of original files saved in %s\n',backupDir);
end

function log_tail(logFile,uninstallFile)
    fprintf(logFile,'\n');
    fprintf(logFile,'Installation succeeded\n');
    fprintf(logFile,'\n');
    fprintf(logFile,'You can revert the changes and use the original file versions\n');
    fprintf(logFile,'prior to this installation by executing the batch script:\n');
    fprintf(logFile,'%s\n\n',uninstallFile);
end

function install_msg(str,logFile)
    disp(str);
    fprintf(logFile,'\n%s\n',str);
end

function copy_single_file(srcPath,destPath,logFile)
    [status,msg]=copyfile(srcPath,destPath,'f');
    if status==0
        install_msg(['Could not copy ',srcPath,' to ',destPath,': ',msg],logFile);
        fclose(logFile);
        throwError('Slvnv:reqmgt:setup_doors:CouldNotCopy',destPath);
    end
    fprintf(logFile,'%s ==> %s\n',srcPath,destPath);
end

function add_line_if_needed(filePath,precedingLine,line2add,logFile)


    fprintf(logFile,'Checking %s for required contents.\n',filePath);
    fid=fopen(filePath,'r');
    contents=fread(fid);
    contents=char(contents');
    fclose(fid);

    if~contains(contents,line2add)
        precedePos=strfind(contents,precedingLine);

        if isempty(precedePos)

            contents=[contents,line2add,newline,newline];
            fprintf(logFile,'Adding "%s" to the end of the file.\n',line2add);
        else

            insertPos=precedePos+length(precedingLine)-1;
            if insertPos==length(contents)
                contents=[contents(1:insertPos),newline,line2add,newline];
            else
                contents=[contents(1:insertPos),newline,line2add,newline,contents((insertPos+1):end)];
            end
            fprintf(logFile,'Adding "%s" after line "%s".\n',line2add,precedingLine);
        end

        tempFile=tempname;
        newFid=fopen(tempFile,'w');
        if newFid==-1
            install_msg(['Error: Could not create writable file ',tempFile],logFile);
            fclose(logFile);
            throwError('Slvnv:reqmgt:setup_doors:CouldNotWrite',tempFile);
        end

        fprintf(newFid,'%s',contents);
        fclose(newFid);

        [status,msg]=movefile(tempFile,filePath,'f');
        if status==0
            install_msg(['Could not move ',tempFile,' to ',filePath,': ',msg],logFile);
            fclose(logFile);
            throwError('Slvnv:reqmgt:setup_doors:CouldNotMove',filePath);
        end
    else
        fprintf(logFile,'Contents verified. No changes are needed.\n');
    end
end

function uninstall_head(uninstallId,location)
    fprintf(uninstallId,'rem MATLAB-DOORS Interface Uninstall script\n');
    fprintf(uninstallId,'rem This batch file restore the DXL folder to\n');
    fprintf(uninstallId,'rem its condition prior to the MATLAB-DOORS Interface\n');
    fprintf(uninstallId,'rem installation\n');
    fprintf(uninstallId,'rem \n');
    fprintf(uninstallId,'rem Script location: %s\n',location);
    fprintf(uninstallId,'rem Generated: %s \n',datestr(now));
end

function backup_file(filePath,backupDir,uninstallFile)
    [~,name,ext]=fileparts(filePath);
    backupFile=fullfile(backupDir,[name,ext]);

    if exist(filePath,'file')


        [status,msg,id]=copyfile(filePath,backupFile,'f');%#ok
        fprintf(uninstallFile,'copy "%s" "%s"\n',backupFile,filePath);
    else


        fprintf(uninstallFile,'del "%s"\n',filePath);
    end
end

function throwError(ID,offendingPath)
    messageString=getString(message(ID,offendingPath));
    advice='Try running MATLAB as Administrator to perform DOORS setup.';
    ME=MException('Slvnv:reqmgt:DoorsSetup',...
    strrep([messageString,newline,advice],'\','\\'));
    throw(ME);
end

