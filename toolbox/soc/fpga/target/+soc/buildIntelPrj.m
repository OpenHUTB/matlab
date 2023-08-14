function buildIntelPrj(hbuild,ExternalBuild)
    restore.path=pwd;
    NumJobs=hbuild.NumJobs;
    prj_dir=hbuild.ProjectDir;
    cd(prj_dir);
    fprintf('---------- Compiling Quartus project with %s parallel jobs ----------\n',num2str(NumJobs));
    [~,bitName,~]=fileparts(hbuild.BitName);

    isArria10SoC=num2str(strcmpi(hbuild.Board.DeviceFamily,'Arria 10'));

    if ExternalBuild
        if ispc
            [err,log]=system(['quartus_sh -t compile_prj.tcl ',bitName,' ',isArria10SoC,' | tee quartus_compile.log',' &']);
        else
            [err,log]=system(['xterm -hold -sb -sl 256 -e bash -e -c ''quartus_sh -t compile_prj.tcl ',bitName,' ',isArria10SoC,' | tee quartus_compile.log',''' &']);
        end
    else
        [err,log]=system(['quartus_sh -t compile_prj.tcl ',bitName,' ',isArria10SoC,' | tee quartus_compile.log']);
    end

    fid=fopen(fullfile(prj_dir,'quartus_compile.log'),'w');
    fprintf(fid,'%s',log);
    fclose(fid);

    if err
        quartusCompileLogDir=fullfile(prj_dir,'quartus_compile.log');
        quartusCompileLogName='quartus_compile.log';
        quartusCompileLink=sprintf('''<a href="matlab:open(''%s'')">%s</a>''',quartusCompileLogDir,quartusCompileLogName);
        error(message('soc:msgs:quartusCompileError',quartusCompileLink));
    end
    cd(restore.path);

end