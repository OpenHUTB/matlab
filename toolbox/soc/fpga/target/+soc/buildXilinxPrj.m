function buildXilinxPrj(hbuild,ExternalBuild)
    NumJobs=hbuild.NumJobs;
    fprintf('---------- Building Vivado project with %s parallel jobs ----------\n',num2str(NumJobs));
    restore.path=pwd;
    cd(hbuild.ProjectDir);
    vivadoToolExe=soc.util.getVivadoPath();
    [~,bitName,~]=fileparts(hbuild.BitName);
    if ExternalBuild
        if ispc
            [err,~]=system([vivadoToolExe,' -log vivado_build_prj.log -mode batch -source build_prj.tcl -tclargs ',bitName,' ',num2str(NumJobs),'&']);
        else
            [err,~]=system(['xterm -hold -sb -sl 256 -e bash -e -c ''',vivadoToolExe,' -log vivado_build_prj.log -mode batch -source build_prj.tcl -tclargs ',bitName,' ',num2str(NumJobs),''' &']);
        end
    else
        [err,~]=system([vivadoToolExe,' -log vivado_build_prj.log -mode batch -source build_prj.tcl -tclargs ',bitName,' ',num2str(NumJobs)]);
    end

    if err
        vivadoBuildLogDir=fullfile(pwd,'vivado_build_prj.log');
        vivadoBuildLogName='vivado_build_prj.log';
        vivadoBuildLink=sprintf('''<a href="matlab:open(''%s'')">%s</a>''',vivadoBuildLogDir,vivadoBuildLogName);
        error(message('soc:msgs:vivadoBuildError',vivadoBuildLink));
    end
    cd(restore.path);

end