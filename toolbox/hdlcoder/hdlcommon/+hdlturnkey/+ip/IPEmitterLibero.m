




classdef IPEmitterLibero<hdlturnkey.ip.IPEmitter


    properties

    end

    properties

        hReport=[];

    end

    properties(Access=protected)

        IPPackageTclFileName='';
    end

    properties(Constant)


        defaultIpCoreVer='1.0';
        smartDesignName='Libero_sd';
        busInterfacePortName='AXI4';
    end


    methods

        function obj=IPEmitterLibero(hIP)


            obj=obj@hdlturnkey.ip.IPEmitter(hIP);

            obj.hReport=hdlturnkey.ip.IPReportLibero(obj);

        end
        function IPEmitterStruct=getIPEmitterStruct(obj)

            IPEmitterStruct=getIPEmitterStruct@hdlturnkey.ip.IPEmitter(obj);
            IPEmitterStruct.IPPackageTclFileName=obj.IPPackageTclFileName;
        end

        function loadIPEmitterStruct(obj,IPEmitterStruct)

            loadIPEmitterStruct@hdlturnkey.ip.IPEmitter(obj,IPEmitterStruct);
            obj.IPPackageTclFileName=IPEmitterStruct.IPPackageTclFileName;
        end

        function generateIPCore(obj)


            obj.IPPackageTclFileName=sprintf('%s_hw.tcl',obj.hIP.getIPCoreName);


            collectIPFileList(obj);


            createIPCoreFolder(obj);


            createCHeaderFile(obj);


            copyIPCoreHDLCode(obj);


            copyAdditionalFiles(obj);


            if obj.hIP.getIPCoreReportStatus
                obj.hReport.generateReport;
            end


            packageLiberoIP(obj);


            copyToIPRepository(obj);

        end


        function folderName=getIPCoreFolderName(obj)


            ipVerStr=strrep(obj.hIP.getIPCoreVersion,'.','_');
            folderName=sprintf('%s_v%s',obj.hIP.getIPCoreName,ipVerStr);
        end

        function hdlFolder=getHDLSrcFolder(obj)


            hdlFolder=obj.HDLFolder;
        end

        function tclFileName=getIPPackageTclFileName(obj)

            tclFileName=obj.IPPackageTclFileName;
        end

        function tclFilePath=getIPPackageTclFilePath(obj)

            tclFilePath=fullfile(obj.hIP.getIPCoreFolder,obj.IPPackageTclFileName);
        end


        function validateIPCoreVer(~,ver)



            verCell=regexp(ver,'\.','split');
            if length(verCell)~=2
                error(message('hdlcommon:workflow:MicrochipIPVerLibero'));
            end
            majorRev=verCell{1};
            if isempty(regexp(majorRev,'\<\d{1,2}\>','once'))
                error(message('hdlcommon:workflow:MicrochipIPVerLibero'));
            end
            minorRev=verCell{2};
            if isempty(regexp(minorRev,'\<\d{1}\>','once'))
                error(message('hdlcommon:workflow:MicrochipIPVerLibero'));
            end
        end

    end

    methods(Access=protected)

        function packageLiberoIP(obj)




            tclFilePath=obj.getIPPackageTclFilePath;
            fid=downstream.tool.createTclFile(tclFilePath);

            if(obj.hIP.hD.hCodeGen.isVHDL)
                hdlLang='VHDL';
                fileExtension='.vhd';
            else
                hdlLang='VERILOG';
                fileExtension='.v';
            end

            deviceSettings=obj.hIP.hD.hToolDriver.OptionList;
            currentDir=pwd;
            projectDir=[currentDir,'/',obj.hIP.getIPCoreFolder];
            projectDirPath=fullfile(projectDir,'prj');


            fprintf(fid,'# TCL file to be Executed by Libero\n');
            fprintf(fid,'# module %s\n\n',obj.hIP.getIPCoreName);
            fprintf(fid,'set myTool "%s"\n',[obj.hIP.hD.hToolDriver.hTool.ToolName,' ',obj.hIP.hD.hToolDriver.hTool.ToolVersion]);
            fprintf(fid,'set myProject %s\n',obj.smartDesignName);
            fprintf(fid,'set myProjectDirectory ./prj\n');
            fprintf(fid,['new_project -name $myProject -location $myProjectDirectory -hdl %s -family "%s" -die "%s" '...
            ,'-package "%s" -speed "%s"\n \n'],hdlLang,deviceSettings{1}.Value,deviceSettings{2}.Value,deviceSettings{3}.Value,deviceSettings{4}.Value);


            fprintf(fid,'# Add HDL Source Files to Project\n');
            printLiberoFiles(obj,fid);
            fprintf(fid,'build_design_hierarchy');
            fprintf(fid,'\n\n');


            fprintf(fid,'# Smartdesign initializations\n');
            fprintf(fid,'create_smartdesign -sd_name %s',obj.smartDesignName);
            fprintf(fid,'\n');
            fprintf(fid,'sd_instantiate_hdl_module -sd_name %s -hdl_module_name %s -hdl_file %s\n',obj.smartDesignName,...
            obj.hIP.getIPCoreName,[obj.getHDLSrcFolder,'/',obj.hIP.hD.hCodeGen.EntityTop,fileExtension]);
            fprintf(fid,'save_smartdesign -sd_name %s\n',obj.smartDesignName);
            fprintf(fid,'save_project\n');
            fprintf(fid,'build_design_hierarchy\n\n');

            hDI=obj.hIP.hD;


            if(hDI.getClockModule.isIPCoreClockNeeded(hDI.hTurnkey.hElab))
                obj.generateIPClockModuleLiberoTcl(fid);
            end
            instanceIPCoreName=[obj.hIP.hD.hCodeGen.EntityTop,fileExtension];


            generateLiberoInterface(obj,fid);


            fprintf(fid,'sd_update_instance -sd_name %s -instance_name %s\n',obj.smartDesignName,[obj.hIP.hD.hCodeGen.EntityTop,'_0']);
            upComp=[obj.getHDLSrcFolder,'/',obj.hIP.hD.hCodeGen.EntityTop,fileExtension];
            newComp=[obj.hIP.hD.hCodeGen.EntityTop,'%',projectDirPath,'/',upComp];
            fprintf(fid,'sd_replace_component -sd_name %s -instance {%s} -new_component {%s}\n',obj.smartDesignName,[obj.hIP.hD.hCodeGen.EntityTop,'_0'],newComp);
            fprintf(fid,'save_smartdesign -sd_name %s \n',obj.smartDesignName);
            fprintf(fid,'save_project\n');
            fprintf(fid,'build_design_hierarchy\n');
            fclose(fid);
        end

        function printLiberoFiles(obj,fid)

            srcFileList=obj.IPCoreSrcFileList;
            hCodeGen=obj.hIP.hD.hCodeGen;
            for ii=1:length(srcFileList)
                srcFileStruct=srcFileList{ii};
                srcFile=srcFileStruct.FilePath;
                [~,fileName,extName]=fileparts(srcFile);
                fileStr=[fileName,extName];
                filePath=[obj.getHDLSrcFolder,'/',fileStr];


                if strcmpi(extName,hCodeGen.getVHDLExt)
                    hdlName='VHDL';
                elseif strcmpi(extName,hCodeGen.getVerilogExt)
                    hdlName='VERILOG';
                else

                    continue;
                end


                fprintf(fid,'import_files -hdl_source %s \n',filePath);
            end
        end

        function generateLiberoInterface(obj,fid)


            hasCoreBeenAddedToSmartDesign=false;
            hTurnkey=obj.hIP.hD.hTurnkey;
            interfaceIDList=hTurnkey.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hTurnkey.getInterface(interfaceID);


                if~hInterface.isIPInterface
                    continue;
                end


                if~hInterface.isInterfaceInUse(hTurnkey)
                    continue;
                end

                if(obj.hIP.hD.hCodeGen.isVHDL)
                    fileExtension='.vhd';
                else
                    fileExtension='.v';
                end


                hElab=obj.hIP.hD.hTurnkey.hElab;
                topModuleFile=[hElab.TopNetName,fileExtension];








                isInterfacePresent=(hInterface.isAXI4Interface||hInterface.isAXI4LiteInterface||hInterface.isAXI4MasterInterface);
                if isInterfacePresent
                    if~hasCoreBeenAddedToSmartDesign
                        hdlturnkey.tool.generateHdlCoreLibero(fid,topModuleFile);
                        hasCoreBeenAddedToSmartDesign=true;
                    end
                end

                hInterface.generatePCoreLiberoTCL(fid,hElab,topModuleFile);

            end

        end

        function generateIPClockModuleLiberoTcl(obj,fid)
            hDI=obj.hIP.hD;
            hClockModule=hDI.getClockModule;

            if hClockModule.ResetActiveLow
                rstType='reset_n';
            else
                rstType='reset';
            end
        end

        function copyToIPRepository(obj)



            ipRepositoryPath=obj.hIP.getIPRepository;
            if isempty(ipRepositoryPath)
                return;
            end


            sourcePath=obj.hIP.getIPCoreFolder;


            pcoreFolderName=obj.getIPCoreFolderName;
            targetPath=fullfile(ipRepositoryPath,...
            pcoreFolderName);


            downstream.tool.createDir(fileparts(targetPath));
            copyfile(sourcePath,targetPath,'f');
        end

        function copyAdditionalFiles(obj)
            hCodeGen=obj.hIP.hD.hCodeGen;
            if(targetcodegen.alteradspbadriver.getDSPBALibSynthesisScriptsNeededPostMakehdl(hCodeGen.cgInfoBackupCopy))
                libFiles=targetcodegen.alteradspbadriver.getDSPBALibFiles();
                for jj=1:length(libFiles)
                    [~,fName,fExt]=fileparts(libFiles{jj});
                    libFile=[fName,fExt];
                    copyfile(fullfile(hdlgetpathtoquartus,libFiles{jj}),...
                    fullfile(obj.IPCoreHDLPath,libFile),'f');
                end
                additionalFiles=targetcodegen.alteradspbadriver.getDSPBAAdditionalFilesPostMakehdl(hCodeGen.cgInfoBackupCopy);
                codeGenDir=hCodeGen.CodegenDir;
                for jj=1:length(additionalFiles)
                    sourcePath=fullfile(codeGenDir,additionalFiles{jj});
                    targetPath=fullfile(obj.IPCoreHDLPath,additionalFiles{jj});

                    copyfile(sourcePath,targetPath,'f');
                end
            end
        end

    end

end

