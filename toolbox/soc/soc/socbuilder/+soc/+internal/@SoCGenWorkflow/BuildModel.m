function BuildModel(obj)

    try
        if strcmpi(obj.ModelType,obj.ProcessorOnly)
            if~obj.isModelMultiCPU(obj.sys)
                generateESWSLModel(obj);
                if obj.BuildAction~=3
                    buildESWSLModel(obj);
                end
                close_system(obj.SWModel,0)
            else

                generateESWSLModel(obj);
                UnusedSwCpuMdls=generateModelsForUnusedCPUs(obj);
                buildESWSLModel(obj);
                buildModelsForUnusedCPUs(obj,UnusedSwCpuMdls);
            end

        else
            hbuild=obj.hbuild;
            duts=hbuild.DUTName;

            if strcmpi(obj.ModelType,obj.SocFpga)&&obj.EnableSWMdlGen
                generateESWSLModel(obj);
                if obj.BuildAction~=3
                    buildESWSLModel(obj);
                end
            end
            if~obj.HasReferenceDesign

                for i=1:numel(duts)
                    soc.setIOInterface(hbuild.SystemName,duts{i},hbuild.IntfInfo,0);
                    if obj.EnablePrjGen
                        soc.internal.genIPCore(hbuild,duts{i});
                    end
                end

                soc.internal.genDesignTcl(hbuild);
                soc.internal.genDesignConstraint(hbuild);
                if obj.EnablePrjGen

                    soc.internal.createProject(hbuild,'ADIHDLDir',obj.ADIHDLDir);
                end
                if obj.ExportRD
                    fprintf('---------- Exporting Reference Design ----------\n');
                    restore=pwd;
                    cd(fullfile(obj.exportDirectory));
                    [pluginrdInfo]=soc.internal.createPluginrdInfo(hbuild,obj);
                    pluginrdInfo.exportDirectory=obj.exportDirectory;
                    pluginrdInfo.exportBoardDir=obj.exportBoardDir;
                    pluginrdInfo.Vendor=hbuild.Vendor;
                    pluginrdInfo.ToolVersion=soc.internal.getSupportedToolVersion(hbuild.Vendor);
                    cd(hbuild.ProjectDir);
                    if(strcmp(hbuild.Vendor,'Xilinx'))
                        pluginrdInfo=soc.internal.readPluginrd(pluginrdInfo);
                        copyfile('constr.xdc',fullfile(obj.exportDirectory),'f');
                        copyfile('hsb_xil.tcl',fullfile(obj.exportDirectory),'f');
                        copyfile('ipcore',fullfile(obj.exportDirectory,'ipcore'),'f');
                        ipDir=fullfile(obj.exportDirectory,'ipcore');

                        vivadoToolExe=soc.util.getVivadoPath();
                        [err,~]=system([vivadoToolExe,' -log vivado_rde_info.log -mode batch -source createpluginInfo_hw.tcl']);
                        if err
                            vivadoCreatePrjLogDir=fullfile(pwd,'vivado_rde_info.log');
                            vivadoCreatePrjLogName='vivado_rde_info.log';
                            vivadoCreatePrjLink=sprintf('''<a href="matlab:open(''%s'')">%s</a>''',vivadoCreatePrjLogDir,vivadoCreatePrjLogName);
                            error(message('soc:msgs:createVivadoPrjError',vivadoCreatePrjLink));
                        end
                        pluginrdInfo=XilinxPluginInfoHW(pluginrdInfo);
                    else
                        [~,quartusPath]=soc.util.which('quartus');
                        qsysScriptPath=fullfile(quartusPath,'..','sopc_builder','bin','qsys-script');
                        [err,log]=system([qsysScriptPath,' --script=','createpluginInfo_hw.tcl']);
                        fid=fopen(fullfile(hbuild.ProjectDir,'qsys_rde_info.log'),'w');
                        fprintf(fid,'%s',log);
                        fclose(fid);
                        if err
                            qsysCreateLocation=fullfile(hbuild.ProjectDir,'qsys_rde_info.log');
                            qsysCreateName='qsys_rde_info.log';
                            qsysCreateLink=sprintf('''<a href="matlab:open(''%s'')">%s</a>''',qsysCreateLocation,qsysCreateName);
                            error(message('soc:msgs:executingQsysError','qsys-script',qsysCreateLink));
                        end
                        pluginrdInfo=IntelPluginInfoHW(pluginrdInfo);
                        copyfile('timing_constr.sdc',fullfile(obj.exportDirectory),'f');
                        copyfile('pin_constr.tcl',fullfile(obj.exportDirectory),'f');
                        copyfile('ipcore',fullfile(obj.exportDirectory,'ip'),'f');
                        ipDir=fullfile(obj.exportDirectory,'ip');
                    end


                    cd(fullfile(obj.exportBoardDir));
                    soc.internal.genPluginboard(pluginrdInfo,hbuild);

                    cd(fullfile(obj.exportDirectory));
                    soc.internal.genPluginrd(pluginrdInfo,hbuild);
                    if(strcmp(hbuild.Vendor,'Xilinx'))
                        if any(cellfun(@(x)isa(x,'soc.xilcomp.HDMIRx'),hbuild.FMCIO))||...
                            any(cellfun(@(x)isa(x,'hsb.xilcomp.HDMITx'),hbuild.FMCIO))||...
                            any(cellfun(@(x)isa(x,'soc.xilcomp.AD9361'),hbuild.FMCIO))
                            soc.internal.genList3pFiles(hbuild);
                            soc.internal.gencopy3pFiles(pluginrdInfo);
                        end
                    end
                    dutIdx=cellfun(@(x)~isempty(x.BlkName)&&contains(x.BlkName,obj.dutName),hbuild.ComponentList);
                    cd(ipDir);
                    rmdir([hbuild.ComponentList{dutIdx}.Name,'*'],'s');
                    cd(restore);
                end
                if(obj.EnableBitGen&&obj.EnablePrjGen)

                    soc.internal.buildProject(hbuild,obj.ExternalBuild);
                end
            else
                generateSWMdlsInHDLWA=obj.EnableSWMdlGen;
                if obj.HasESW
                    generateSWMdlsInHDLWA=false;
                end
                soc.setIOInterface(bdroot(duts{1}),get_param(duts{1},'name'),hbuild.IntfInfo,0,false);
                soc.internal.runHDLWACLI(duts{1},obj.ProjectDir,...
                generateSWMdlsInHDLWA,obj.EnablePrjGen,...
                obj.EnableBitGen,obj.ExternalBuild);
            end
        end
        savesocsysinfo(obj);
    catch ME
        if obj.Debug
            rethrow(ME);
        end
    end
end




