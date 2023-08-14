




classdef IPEmitterQsys<hdlturnkey.ip.IPEmitter


    properties

    end

    properties

        hReport=[];
        IPCoreConstraintList={};
        IPCoreConstraintPath='';
    end

    properties(Access=protected)

        IPPackageTclFileName='';
    end

    properties(Constant)


        defaultIpCoreVer='1.0';

    end


    methods

        function obj=IPEmitterQsys(hIP)


            obj=obj@hdlturnkey.ip.IPEmitter(hIP);

            obj.hReport=hdlturnkey.ip.IPReportQsys(obj);

        end
        function IPEmitterStruct=getIPEmitterStruct(obj)

            IPEmitterStruct=getIPEmitterStruct@hdlturnkey.ip.IPEmitter(obj);
            IPEmitterStruct.IPCoreConstraintList=obj.IPCoreConstraintList;
            IPEmitterStruct.IPPackageTclFileName=obj.IPPackageTclFileName;
        end

        function loadIPEmitterStruct(obj,IPEmitterStruct)

            loadIPEmitterStruct@hdlturnkey.ip.IPEmitter(obj,IPEmitterStruct);
            obj.IPCoreConstraintList=IPEmitterStruct.IPCoreConstraintList;
            obj.IPPackageTclFileName=IPEmitterStruct.IPPackageTclFileName;
        end

        function generateIPCore(obj)


            obj.IPPackageTclFileName=sprintf('%s_hw.tcl',obj.hIP.getIPCoreName);


            collectIPFileList(obj);


            createIPCoreFolder(obj);


            createCHeaderFile(obj);


            copyIPCoreHDLCode(obj);


            if(hdlgetparameter('multicyclepathconstraints'))
                copyIPCoreConstraint(obj);
            end

            copyAdditionalFiles(obj);


            copyFPGADataCaptureCode(obj);


            if obj.hIP.getIPCoreReportStatus
                obj.hReport.generateReport;
            end


            packageQsysIP(obj);


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
                error(message('hdlcommon:workflow:AlteraIPVerQsys'));
            end
            majorRev=verCell{1};
            if isempty(regexp(majorRev,'\<\d{1,2}\>','once'))
                error(message('hdlcommon:workflow:AlteraIPVerQsys'));
            end
            minorRev=verCell{2};
            if isempty(regexp(minorRev,'\<\d{1}\>','once'))
                error(message('hdlcommon:workflow:AlteraIPVerQsys'));
            end
        end

        function copyIPCoreConstraint(obj)
            obj.IPCoreConstraintList=obj.IPCoreSrcFileList;
            ipFolder=obj.hIP.getIPCoreFolder;
            obj.IPCoreConstraintPath=fullfile(ipFolder,'constraint');

            for ii=1:length(obj.IPCoreConstraintList)
                srcFileStruct=obj.IPCoreConstraintList{ii};
                srcFile=srcFileStruct.FilePath;

                [~,fileName,extName]=fileparts(srcFile);
                if~(strcmpi(extName,'.sdc'))
                    continue;
                end

                txt=fileread(srcFile);
                s=regexp(txt,'^[^#\s].*','lineanchors');
                if(isempty(s))
                    continue;
                end

                if(contains(fileName,'_constraint'))
                    sourcePath=srcFile;
                    targetPath=fullfile(obj.IPCoreConstraintPath,[fileName,extName]);
                    downstream.tool.createDir(obj.IPCoreConstraintPath);


                    targetFolder=fileparts(targetPath);
                    downstream.tool.createDir(targetFolder);


                    copyfile(sourcePath,targetPath,'f');
                end


                obj.IPCoreConstraintList{end+1}=[fileName,extName];
            end
        end
    end

    methods(Access=protected)

        function packageQsysIP(obj)




            tclFilePath=obj.getIPPackageTclFilePath;
            fid=downstream.tool.createTclFile(tclFilePath);





            fprintf(fid,'# request TCL package from ACDS 13.1\n');
            fprintf(fid,'package require -exact qsys 13.1\n');
            fprintf(fid,'\n');

            fprintf(fid,'# module %s\n',obj.hIP.getIPCoreName);
            fprintf(fid,'set_module_property DESCRIPTION ""\n');
            fprintf(fid,'set_module_property NAME %s\n',obj.hIP.getIPCoreName);
            fprintf(fid,'set_module_property VERSION %s\n',obj.hIP.getIPCoreVersion);
            fprintf(fid,'set_module_property INTERNAL false\n');
            fprintf(fid,'set_module_property OPAQUE_ADDRESS_MAP true\n');
            fprintf(fid,'set_module_property GROUP "HDL Coder Generated IP"\n');
            fprintf(fid,'set_module_property AUTHOR ""\n');
            fprintf(fid,'set_module_property DISPLAY_NAME %s\n',obj.hIP.getIPCoreName);
            fprintf(fid,'set_module_property INSTANTIATE_IN_SYSTEM_MODULE true\n');
            fprintf(fid,'set_module_property EDITABLE true\n');
            fprintf(fid,'set_module_property ANALYZE_HDL AUTO\n');
            fprintf(fid,'set_module_property REPORT_TO_TALKBACK false\n');
            fprintf(fid,'set_module_property ALLOW_GREYBOX_GENERATION false\n');
            fprintf(fid,'\n');


            if obj.hIP.getIPCoreReportStatus
                fprintf(fid,'# documentation\n');
                fprintf(fid,'set docprefix file:///\n');
                fprintf(fid,'add_documentation_link "DATASHEET" [append docprefix [get_module_property MODULE_DIRECTORY] /%s/%s]\n',...
                obj.DocFolder,obj.hReport.getReportFileName);
                fprintf(fid,'\n');
            end

            fprintf(fid,'# file sets\n');

            fprintf(fid,'add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""\n');
            fprintf(fid,'set_fileset_property QUARTUS_SYNTH TOP_LEVEL %s\n',obj.hIP.getIPCoreName);
            fprintf(fid,'set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false\n');
            printQsysFiles(obj,fid);
            fprintf(fid,'\n');

            hDI=obj.hIP.hD;



            if(hDI.getClockModule.isIPCoreClockNeeded(hDI.hTurnkey.hElab))
                obj.generateIPClockModuleQsysTcl(fid);
            end

            generateQsysInterface(obj,fid);

            fclose(fid);
        end

        function printQsysFiles(obj,fid)

            srcFileList=obj.IPCoreSrcFileList;
            hCodeGen=obj.hIP.hD.hCodeGen;
            for ii=1:length(srcFileList)
                srcFileStruct=srcFileList{ii};
                srcFile=srcFileStruct.FilePath;
                [~,fileName,extName]=fileparts(srcFile);
                fileStr=[fileName,extName];
                filePath=[obj.getHDLSrcFolder,'/',fileStr];


                if strcmpi(fileName,obj.hIP.getIPCoreName)
                    topLevelStr='TOP_LEVEL_FILE';
                else
                    topLevelStr='';
                end

                txt=fileread(srcFile);
                s=regexp(txt,'^[^#\s].*','lineanchors');
                if(isempty(s))
                    continue;
                end


                if strcmpi(extName,hCodeGen.getVHDLExt)
                    hdlName='VHDL';
                elseif strcmpi(extName,hCodeGen.getVerilogExt)
                    hdlName='VERILOG';
                elseif(hdlgetparameter('multicyclepathconstraints')&&strcmpi(extName,'.sdc'))
                    hdlName='SDC';
                    filePath=['constraint/',fileStr];
                else

                    continue;
                end



                fprintf(fid,'add_fileset_file %s %s PATH %s %s\n',...
                fileStr,hdlName,filePath,topLevelStr);
            end

            str=targetcodegen.alteradspbadriver.getDSPBAAdditionalFilesSynthesisScripts(...
            obj.getHDLSrcFolder,hdlName,...
            targetcodegen.alteradspbadriver.getDSPBALibSynthesisScriptsNeededPostMakehdl(hCodeGen.cgInfoBackupCopy),...
            targetcodegen.alteradspbadriver.getDSPBAAdditionalFilesPostMakehdl(hCodeGen.cgInfoBackupCopy));
            fprintf(fid,str);
        end

        function generateQsysInterface(obj,fid)


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


                hElab=obj.hIP.hD.hTurnkey.hElab;
                hInterface.generatePCoreQsysTCL(fid,hElab);

            end
        end

        function generateIPClockModuleQsysTcl(obj,fid)
            hClockModule=obj.hIP.hD.getClockModule;

            proplist={...
            {'clockRate','0'},...
            {'ENABLED','true'},...
            {'EXPORT_OF','""'},...
            {'PORT_NAME_MAP','""'},...
            {'CMSIS_SVD_VARIABLES','""'},...
            {'SVD_ADDRESS_GROUP','""'},...
            };
            portlist={
            {hClockModule.ClockPortName,'clk','Input','1'},...
            };
            hdlturnkey.tool.generateQsysTclInterfaceDefinition(fid,'ip_clk',hdlturnkey.IOType.IN,'clock',proplist,portlist);


            if hClockModule.ResetActiveLow
                rstType='reset_n';
            else
                rstType='reset';
            end

            proplist={...
            {'associatedClock','ip_clk'},...
            {'synchronousEdges','DEASSERT'},...
            {'ENABLED','true'},...
            {'EXPORT_OF','""'},...
            {'PORT_NAME_MAP','""'},...
            {'CMSIS_SVD_VARIABLES','""'},...
            {'SVD_ADDRESS_GROUP','""'},...
            };
            portlist={
            {hClockModule.ResetPortName,rstType,'Input','1'},...
            };
            hdlturnkey.tool.generateQsysTclInterfaceDefinition(fid,'ip_rst',hdlturnkey.IOType.IN,'reset',proplist,portlist);
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




