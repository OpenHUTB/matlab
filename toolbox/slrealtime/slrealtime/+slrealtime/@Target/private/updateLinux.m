function updateLinux(this,~)




    out=this.executeCommand("echo $HOME");
    homeDir=convertCharsToStrings(out.Output);
    homeDir=char(homeDir.strip());

    archive=[homeDir,'/target.tar.xc'];
    archive_full=fullfile(matlabroot,'toolbox','slrealtime','target','linux_images','target.tar.xc');

    this.sendFile(archive_full,archive);

    buildType='debug';
    sshObj=this.sshDoNotUseDirectly;

    cmd=['cd ',homeDir...
    ,' && if [ -d "command_control/src" ]; then rm -Rf command_control/src; fi'...
    ,' && mkdir -p command_control/src'...
    ,' && tar xf ',archive,' -C command_control/src'...
    ,' && mkdir -p command_control/build'...
    ,' && echo "HOMEDIR=',homeDir,'" > command_control/src/logdEnv '...
    ,' && cd command_control/build'...
    ,' && export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH'...
    ,' && cmake -DBoost_NO_BOOST_CMAKE=ON -DCMAKE_BUILD_TYPE=',buildType,' ../src'...
    ,' && make -j$(eval nproc)'...
    ,' && rm -f ',homeDir,'/target.tar.xc '...
    ,' 2>&1'];

    sshObj.execute(cmd);
    while isempty(sshObj.getResult())
        fprintf('.');pause(2);
    end
    fprintf('\n');
    checkSSHResult(sshObj.getResult());


    rootSSHObj=this.getRootSSHObj;
    install_cmd=['make --directory=',homeDir,'/command_control/build install && /sbin/ldconfig'];
    rootSSHObj.execute(install_cmd);
    while isempty(rootSSHObj.getResult())
        fprintf('.');pause(2);
    end
    fprintf('\n');
    checkSSHResult(rootSSHObj.getResult());


    service_cmd=['cp ',homeDir,'/command_control/src/systemdServices/* /etc/systemd/system'...
    ,'&& cp ',homeDir,'/command_control/src/logdEnv /etc/systemd/system/.'...
    ,'&& systemctl daemon-reload'...
    ,'&& systemctl stop slrt'...
    ,'&& systemctl enable slrt'...
    ,'&& systemctl start slrt'];
    rootSSHObj.execute(service_cmd);
    while isempty(rootSSHObj.getResult())
        fprintf('.');pause(2);
    end
    fprintf('\n');
    checkSSHResult(rootSSHObj.getResult());

end

function checkSSHResult(res)
    disp(res.Output)
    if(res.ExitCode~=0)
        error('slrealtime:target:sshError',res.ErrorOutput);
    end
end


