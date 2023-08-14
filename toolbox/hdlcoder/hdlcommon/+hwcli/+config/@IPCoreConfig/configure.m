function configure(obj,hDI)





    configure@hwcli.base.IPCoreBase(obj,hDI);
    configure@hwcli.base.DeployBase(obj,hDI);

    if hDI.hIP.isGenericIPPlatform
        if obj.RunTaskCreateProject||obj.RunTaskGenerateSoftwareInterface||obj.RunTaskBuildFPGABitstream||obj.RunTaskProgramTargetDevice
            error(message('hdlcoder:workflow:TaskUnsupportedForGenericIP',join(["RunTaskCreateProject","RunTaskGenerateSoftwareInterface","RunTaskBuildFPGABitstream","RunTaskProgramTargetDevice"],", ")));
        end
    end

    if obj.RunTaskGenerateSoftwareInterface

        if obj.GenerateSoftwareInterfaceModel&&~hDI.hIP.getGenerateSoftwareInterfaceModelEnable


            modelGenLabel=message('hdlcommon:workflow:HDLWASWInterfaceModel').getString;
            error(message('hdlcoder:workflow:SoftwareModelGenNotValidForRD',modelGenLabel));
        else
            hDI.hIP.GenerateSoftwareInterfaceModel=obj.GenerateSoftwareInterfaceModel;
            hDI.hIP.setOperatingSystem(obj.OperatingSystem);
        end


        if~isempty(obj.HostTargetInterface)&&~any(strcmp(obj.HostTargetInterface,hDI.hIP.HostTargetInterfaceOptions))


            hostInterfaceLabel=message('hdlcommon:workflow:HDLWAHostTargetInterfaceType').getString;
            error(message('hdlcoder:workflow:HostTargetInterfaceNotValidForRD',hostInterfaceLabel,strjoin(hDI.hIP.HostTargetInterfaceOptions,', ')));
        else
            hDI.hIP.HostTargetInterface=obj.HostTargetInterface;
        end


        if obj.GenerateHostInterfaceScript&&~hDI.hIP.getGenerateHostInterfaceScriptEnable


            scriptGenLabel=message('hdlcommon:workflow:HDLWASWInterfaceScript').getString;
            error(message('hdlcoder:workflow:SoftwareScriptGenNotValidForRD',scriptGenLabel));
        else
            hDI.hIP.GenerateHostInterfaceScript=obj.GenerateHostInterfaceScript;
        end


        if obj.GenerateHostInterfaceModel&&~hDI.hIP.getGenerateHostInterfaceModelEnable


            modelGenLabel=message('hdlcommon:workflow:HDLWAHostInterfaceModel').getString;
            if~strcmp(hDI.hIP.HostTargetInterfaceOptions,'JTAG AXI Manager (HDL Verifier)')



                error(message('hdlcoder:workflow:HostModelGenNotValidForRD',modelGenLabel));
            else



                error(message('hdlcoder:workflow:HostModelInterfaceNotValid',modelGenLabel));
            end
        else
            hDI.hIP.GenerateHostInterfaceModel=obj.GenerateHostInterfaceModel;
        end
    end


    if obj.RunTaskProgramTargetDevice
        hDI.hIP.setProgrammingMethod(obj.ProgrammingMethod);


        if obj.ProgrammingMethod==hdlcoder.ProgrammingMethod.Download
            hDI.hIP.setIPAddress(obj.IPAddress);
            hDI.hIP.setSSHUsername(obj.SSHUsername);
            hDI.hIP.setSSHPassword(obj.SSHPassword);
        end
    end

end