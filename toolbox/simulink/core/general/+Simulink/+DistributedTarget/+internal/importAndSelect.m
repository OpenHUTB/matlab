function importAndSelect(bd,archFile)







    [archH,mappingH]=Simulink.DistributedTarget.internal.getmappingmgr(bd);%#ok

    switch archFile
    case 'Multicore'
        mappingH.importArchitecture('Multicore');
    case 'Sample Architecture'
        mappingH.importArchitecture(Simulink.DistributedTarget.getSupportFilePath('sampleArchitecture.xml'));
    case 'Simulink Real-Time'
        mappingH.importArchitecture('archFromConnectedxPCTarget');
    case 'Xilinx Zynq ZC702 evaluation kit'
        if Simulink.DistributedTarget.isZynqSupportPackageInstalled()
            mappingH.importArchitecture(fullfile(zynq.util.getTargetRootFolder,'+zynq','+DistributedTarget','zynq.xml'));
        else
            DAStudio.error('Simulink:mds:ArchUnavailable',archFile);
        end
    case 'Xilinx Zynq Zedboard'
        if Simulink.DistributedTarget.isZynqSupportPackageInstalled()
            mappingH.importArchitecture(fullfile(zynq.util.getTargetRootFolder,'+zynq','+DistributedTarget','zedboard.xml'));
        else
            DAStudio.error('Simulink:mds:ArchUnavailable',archFile);
        end

    case 'Xilinx Zynq ZC706 evaluation kit'
        if Simulink.DistributedTarget.isZynqSupportPackageInstalled()
            mappingH.importArchitecture(fullfile(zynq.util.getTargetRootFolder,'+zynq','+DistributedTarget','zc706.xml'));
        else
            DAStudio.error('Simulink:mds:ArchUnavailable',archFile);
        end

    case 'Altera Cyclone V SoC development kit - Rev.C'
        if Simulink.DistributedTarget.isAlteraSupportPackageInstalled()
            mappingH.importArchitecture(fullfile(codertarget.alterasoc.internal.getSpPkgRootDir,'+codertarget','+alterasoc','+DistributedTarget','altera_cyclone_C.xml'));
        else
            DAStudio.error('Simulink:mds:ArchUnavailable',archFile);
        end

    case 'Altera Cyclone V SoC development kit - Rev.D'
        if Simulink.DistributedTarget.isAlteraSupportPackageInstalled()
            mappingH.importArchitecture(fullfile(codertarget.alterasoc.internal.getSpPkgRootDir,'+codertarget','+alterasoc','+DistributedTarget','altera_cyclone_D.xml'));
        else
            DAStudio.error('Simulink:mds:ArchUnavailable',archFile);
        end

    case 'Altera SoCKit development board'
        if Simulink.DistributedTarget.isAlteraSupportPackageInstalled()
            mappingH.importArchitecture(fullfile(codertarget.alterasoc.internal.getSpPkgRootDir,'+codertarget','+alterasoc','+DistributedTarget','altera_soc_kit.xml'));
        else
            DAStudio.error('Simulink:mds:ArchUnavailable',archFile);
        end

    otherwise
        if exist(archFile,'file')
            mappingH.importArchitecture(archFile);
        else
            DAStudio.error('Simulink:mds:ArchUnavailable',archFile);
        end
    end

end


