




classdef IPEmitterVivado<hdlturnkey.ip.IPEmitter


    properties

        IPPackageZipFileName='';


        hReport=[];



        IPCoreHDLFileList={};
        IPCoreConstraintList={};
        IPCoreConstraintPath='';

    end

    properties(Access=protected)


        SysGenSrcFileList={};
        SysGenCoeFileList={};
        SysGenTclFileList={};

    end

    properties(Constant)


        defaultIpCoreVer='1.0';


        IPPackageTclFileName='vivado_ip_package.tcl';
        IPPackageProjectName='prj_ip';


        getCoeXciFolder='ip';

    end


    methods

        function obj=IPEmitterVivado(hIP)


            obj=obj@hdlturnkey.ip.IPEmitter(hIP);

            obj.hReport=hdlturnkey.ip.IPReportVivado(obj);

        end

        function IPEmitterStruct=getIPEmitterStruct(obj)

            IPEmitterStruct=getIPEmitterStruct@hdlturnkey.ip.IPEmitter(obj);


            IPEmitterStruct.IPPackageZipFileName=obj.IPPackageZipFileName;
            IPEmitterStruct.IPCoreHDLFileList=obj.IPCoreHDLFileList;
            IPEmitterStruct.IPCoreConstraintList=obj.IPCoreConstraintList;
            IPEmitterStruct.SysGenSrcFileList=obj.SysGenSrcFileList;
            IPEmitterStruct.SysGenTclFileList=obj.SysGenTclFileList;

        end

        function loadIPEmitterStruct(obj,IPEmitterStruct)

            loadIPEmitterStruct@hdlturnkey.ip.IPEmitter(obj,IPEmitterStruct);


            obj.IPPackageZipFileName=IPEmitterStruct.IPPackageZipFileName;
            obj.IPCoreHDLFileList=IPEmitterStruct.IPCoreHDLFileList;
            obj.IPCoreConstraintList=IPEmitterStruct.IPCoreConstraintList;
            obj.SysGenSrcFileList=IPEmitterStruct.SysGenSrcFileList;
            obj.SysGenTclFileList=IPEmitterStruct.SysGenTclFileList;

        end

        function generateIPCore(obj)


            obj.IPPackageZipFileName=sprintf('%s.zip',obj.getIPCoreFolderName);


            collectIPFileList(obj);


            createIPCoreFolder(obj);


            createCHeaderFile(obj);


            copyIPCoreHDLCode(obj);


            if(hdlgetparameter('multicyclepathconstraints'))
                copyIPCoreConstraint(obj);
            end


            copyFPGADataCaptureCode(obj);


            if obj.hIP.getIPCoreReportStatus

                obj.hReport.generateReport;

                obj.generateProductGuidePDF;
            end


            packageVivadoIP(obj);


            copyToIPRepository(obj);

        end


        function folderName=getIPCoreFolderName(obj)


            ipVerStr=strrep(obj.hIP.getIPCoreVersion,'.','_');
            folderName=sprintf('%s_v%s',obj.hIP.getIPCoreName,ipVerStr);
        end


        function validateIPCoreVer(~,ver)



            verCell=regexp(ver,'\.','split');
            if length(verCell)~=2
                error(message('hdlcommon:workflow:XilinxIPVerVivado'));
            end
            majorRev=verCell{1};
            if isempty(regexp(majorRev,'\<\d{1,2}\>','once'))
                error(message('hdlcommon:workflow:XilinxIPVerVivado'));
            end
            minorRev=verCell{2};
            if isempty(regexp(minorRev,'\<\d{1}\>','once'))
                error(message('hdlcommon:workflow:XilinxIPVerVivado'));
            end
        end

        function fpgaPartStr=getFPGAPartStr(obj)

            deviceName=obj.hIP.hD.get('Device');
            packageName=obj.hIP.hD.get('Package');
            speedName=obj.hIP.hD.get('Speed');
            fpgaPartStr=sprintf('%s%s%s',deviceName,packageName,speedName);
        end

    end

    methods(Access=protected)

        function toolSpecificSrcFileList=colllectToolSpecificSrcFileList(obj,hCodeGen)


            obj.SysGenSrcFileList={};
            obj.SysGenTclFileList={};


            sysGenVivadoResults=hCodeGen.SysGenVivadoResults;
            if~isempty(sysGenVivadoResults)
                codeGenDir=hCodeGen.CodegenDir;

                sysGenFiles=sysGenVivadoResults.Files;
                sysGenFileFields=fields(sysGenFiles);
                for ii=1:length(sysGenFileFields)
                    aSysGenFileField=sysGenFileFields{ii};








                    aSysGenFileSet=sysGenVivadoResults.Files.(aSysGenFileField);


                    sysGenFileList=aSysGenFileSet.hdl;
                    for jj=1:length(sysGenFileList)
                        sysGenFilePath=sysGenFileList{jj};
                        codeGenFilePath=fullfile(codeGenDir,aSysGenFileField,sysGenFilePath);
                        shortFilePath=fullfile(aSysGenFileField,sysGenFilePath);
                        srcFileStruct=obj.createSrcFileStruct(...
                        codeGenFilePath,shortFilePath,aSysGenFileField);
                        obj.SysGenSrcFileList{end+1}=srcFileStruct;
                    end


                    sysGenCoeFileList=aSysGenFileSet.coe;
                    for jj=1:length(sysGenCoeFileList)
                        sysGenCoeFile=sysGenCoeFileList{jj};
                        sysGenCoeFilePath=fullfile(codeGenDir,aSysGenFileField,sysGenCoeFile);
                        obj.SysGenCoeFileList{end+1}=sysGenCoeFilePath;
                    end


                    sysGenTclFileList=aSysGenFileSet.tcl;
                    for jj=1:length(sysGenTclFileList)
                        sysGenTclFile=sysGenTclFileList{jj};
                        sysGenTclFilePath=fullfile(codeGenDir,aSysGenFileField,sysGenTclFile);
                        obj.SysGenTclFileList{end+1}=sysGenTclFilePath;
                    end
                end
            end

            if~isempty(obj.SysGenSrcFileList)
                obj.SysGenSrcFileList=obj.SysGenSrcFileList';
            end
            toolSpecificSrcFileList=obj.SysGenSrcFileList;
        end

        function copyIPCoreConstraint(obj)
            obj.IPCoreConstraintList=obj.IPCoreSrcFileList;
            ipFolder=obj.hIP.getIPCoreFolder;
            obj.IPCoreConstraintPath=fullfile(ipFolder,'constraint');

            for ii=1:length(obj.IPCoreConstraintList)
                srcFileStruct=obj.IPCoreConstraintList{ii};
                srcFile=srcFileStruct.FilePath;
                [~,fileName,extName]=fileparts(srcFile);

                if~(strcmpi(extName,'.xdc'))
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

        function copyIPCoreHDLCode(obj)







            obj.IPCoreHDLFileList={};
            hCodeGen=obj.hIP.hD.hCodeGen;


            for ii=1:length(obj.IPCoreSrcFileList)
                srcFileStruct=obj.IPCoreSrcFileList{ii};
                srcFile=srcFileStruct.FilePath;
                [~,~,extName]=fileparts(srcFile);

                if~strcmpi(extName,hCodeGen.getVHDLExt)&&~strcmpi(extName,hCodeGen.getVerilogExt)
                    continue;
                end

                sourcePath=srcFile;
                targetPath=fullfile(obj.IPCoreHDLPath,srcFileStruct.ShortFilePath);


                targetFolder=fileparts(targetPath);
                downstream.tool.createDir(targetFolder);


                copyfile(sourcePath,targetPath,'f');


                obj.IPCoreHDLFileList{end+1}=srcFileStruct;
            end


            if~isempty(obj.SysGenCoeFileList)

                ipFolder=obj.hIP.getIPCoreFolder;
                coeFolder=fullfile(ipFolder,obj.getCoeXciFolder);
                downstream.tool.createDir(coeFolder);


                for ii=1:length(obj.SysGenCoeFileList)
                    coeFilePath=obj.SysGenCoeFileList{ii};
                    [~,fileName,extName]=fileparts(coeFilePath);

                    sourcePath=coeFilePath;
                    targetPath=fullfile(coeFolder,sprintf('%s%s',fileName,extName));


                    copyfile(sourcePath,targetPath,'f');
                end
            end

        end

        function packageVivadoIP(obj)



            tclFilePath=obj.generateIPPackageTcl;


            toolTclCmdStr=obj.hIP.hD.hToolDriver.hTool.getToolTclCmdStrfull;
            [status,result]=downstream.tool.runTclFile(tclFilePath,...
            toolTclCmdStr,false,obj.hIP.hD.logDisplay);


            taskName=message('hdlcommon:workflow:IPPackager').getString;
            fileName=message('hdlcommon:workflow:IPPackagerENGLISH').getString;

            linkOnlyMsg=true;
            resultLog=obj.hIP.hD.logDisplayToolResult(status,result,taskName,fileName,linkOnlyMsg);



            if(~obj.hIP.hD.cmdDisplay)
                msg=message('hdlcommon:workflow:WorkflowStageResult',resultLog);
                if status
                    hdldisp(msg);
                else
                    error(msg);
                end
            else
                hdldisp(result);
            end

        end

        function tclFilePath=generateIPPackageTcl(obj)


            hDI=obj.getDIObject;


            ipcoreFolder=obj.hIP.getIPCoreFolder;
            packagePrjFolder=fullfile(ipcoreFolder,obj.IPPackageProjectName);
            tclFilePath=fullfile(packagePrjFolder,obj.IPPackageTclFileName);
            fid=downstream.tool.createTclFile(tclFilePath);


            fpgaPartStr=obj.getFPGAPartStr;


            ipcoreRelativePath='../';


            reportHTMLFileRelPath=downstream.tool.filterBackSlash(...
            obj.hReport.getReportFileRelativePath);
            docFolder=obj.hReport.getPCoreDocFolder;


            headerFileRelPath=downstream.tool.filterBackSlash(...
            obj.hCHEmitter.getHeaderFileRelativePath);


            packageZipFileRelPath=downstream.tool.filterBackSlash(...
            fullfile(ipcoreRelativePath,obj.IPPackageZipFileName));



            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclIPPackageInit',...
            fid,obj.IPPackageProjectName,fpgaPartStr);


            fprintf(fid,'\n# Add HDL source files to project\n');
            hCodeGen=obj.hIP.hD.hCodeGen;
            for ii=1:length(obj.IPCoreHDLFileList)
                srcFileStruct=obj.IPCoreHDLFileList{ii};
                srcFile=srcFileStruct.ShortFilePath;
                libName=srcFileStruct.LibName;


                [~,~,extName]=fileparts(srcFile);
                if strcmpi(extName,hCodeGen.getVerilogExt)
                    libName='';
                end

                hdlSrcFolder=obj.getHDLSrcFolder;
                srcFileRelPath=downstream.tool.filterBackSlash(...
                fullfile(ipcoreRelativePath,hdlSrcFolder,srcFile));


                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclAddFileToProject',...
                fid,srcFileRelPath,libName);
            end

            if(hdlgetparameter('multicyclepathconstraints'))

                fprintf(fid,'\n# Add Constraint files to project\n');
                obj.IPCoreConstraintList=obj.IPCoreSrcFileList;
                for ii=1:length(obj.IPCoreConstraintList)
                    srcFileStruct=obj.IPCoreConstraintList{ii};
                    srcFile=srcFileStruct.ShortFilePath;
                    srcFiles=srcFileStruct.FilePath;
                    libName=srcFileStruct.LibName;

                    [~,fileName,extName]=fileparts(srcFile);
                    if~(strcmpi(extName,'.xdc'))
                        continue;
                    end

                    txt=fileread(srcFiles);
                    s=regexp(txt,'^[^#\s].*','lineanchors');
                    if(isempty(s))
                        continue;
                    end

                    if(contains(fileName,'_constraint'))
                        srcFileRelPath=downstream.tool.filterBackSlash(...
                        fullfile(ipcoreRelativePath,'constraint',srcFile));

                        downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclAddFileToProject',...
                        fid,srcFileRelPath,libName);
                    end
                end
            end


            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclSetTopLevelEntity',...
            fid,obj.hIP.getIPCoreName);


            fprintf(fid,'\n# Package IP from project\n');
            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclPackageIPFromProject',...
            fid);


            fprintf(fid,'\n# Set IP properties\n');






































            ts=datetime(obj.hIP.getTimestamp,'ConvertFrom','datenum');

            y2k22=datetime(2021,12,31,23,59,0);
            if ts>y2k22

                elapsedMinutes=floor(minutes(ts-y2k22));





                revNum=2112312359+elapsedMinutes;
                revNumStr=num2str(revNum);
            else


                revNumStr=obj.hIP.getTimestampStr;
            end
            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclSetIPProperty',...
            fid,obj.hIP.getIPCoreName,obj.hIP.getIPCoreVersion,revNumStr);



            if~isempty(obj.SysGenTclFileList)
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclSysGenIPPackage',...
                fid,obj.SysGenTclFileList);
            end


            for ii=1:length(obj.SysGenCoeFileList)
                coeFilePath=obj.SysGenCoeFileList{ii};
                [~,fileName,extName]=fileparts(coeFilePath);
                coeFileName=sprintf('%s%s',fileName,extName);
                coeIPListPath=sprintf('%s/%s',obj.getCoeXciFolder,coeFileName);
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclSysGenAddCoeFile',...
                fid,coeIPListPath);
            end


            fprintf(fid,'\n# Add HDL source files to IP\n');
            for ii=1:length(obj.IPCoreHDLFileList)
                srcFileStruct=obj.IPCoreHDLFileList{ii};
                srcFile=srcFileStruct.ShortFilePath;
                libName=srcFileStruct.LibName;
                [~,~,extName]=fileparts(srcFile);


                if strcmpi(extName,hCodeGen.getVerilogExt)
                    libName='';
                end

                hdlSrcFolder=obj.getHDLSrcFolder;
                srcFileIPPath=downstream.tool.filterBackSlash(...
                fullfile(hdlSrcFolder,srcFile));


                isVHDL=strcmpi(extName,hCodeGen.getVHDLExt);
                isVerilog=strcmpi(extName,hCodeGen.getVerilogExt);
                if isVHDL||isVerilog
                    downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclAddFilesToIP',...
                    fid,srcFileIPPath,libName,isVHDL);
                else

                    continue;
                end
            end


            if(hdlgetparameter('multicyclepathconstraints'))
                fprintf(fid,'\n# Add MCP constraint file(s) to IP\n');

                for ii=1:length(obj.IPCoreConstraintList)
                    srcFileStruct=obj.IPCoreConstraintList{ii};
                    srcFile=srcFileStruct.ShortFilePath;
                    libName=srcFileStruct.LibName;
                    [~,fileName,extName]=fileparts(srcFile);

                    if~(strcmpi(extName,'.xdc'))
                        continue;
                    end

                    isXDC=strcmpi(extName,'.xdc');
                    if(contains(fileName,'_constraint'))
                        srcFileIPPath=downstream.tool.filterBackSlash(...
                        fullfile('constraint',srcFile));

                        downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclAddConstraintFilesToIP',...
                        fid,srcFileIPPath,libName,isXDC);
                    end
                end
            end


            fprintf(fid,'\n# Add bus interfaces\n');
            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclRemoveInterface',fid);

            obj.generateIPInterfaceVivadoTcl(fid);



            if(hDI.getClockModule.isIPCoreClockNeeded(hDI.hTurnkey.hElab))

                fprintf(fid,'\n# Add IP clock and reset definition\n');

                obj.generateIPClockModuleVivadoTcl(fid);
            end


            if obj.hIP.getIPCoreReportStatus
                fprintf(fid,'\n# Add report files\n');
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclAddIPReport',...
                fid,reportHTMLFileRelPath,docFolder);
            end

            fdcFolder=fullfile(obj.hIP.getIPCoreFolder,'fpga_data_capture');
            if exist(fdcFolder,'dir')
                fprintf(fid,'\n# Add FPGA Data Capture files\n');
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclAddIPGroup',...
                fid,'xilinx_examples');
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclAddIPGroup',...
                fid,'xilinx_implementation');

                allFiles=dir(fdcFolder);
                for ii=1:numel(allFiles)
                    if allFiles(ii).isdir
                        continue;
                    end
                    if strcmpi(allFiles(ii).name,'FPGADataCapture.xdc')
                        downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclAddFileToIPGroup',...
                        fid,['fpga_data_capture/',allFiles(ii).name],'xilinx_implementation','matlab');
                    else
                        downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclAddFileToIPGroup',...
                        fid,['fpga_data_capture/',allFiles(ii).name],'xilinx_examples','matlab');
                    end
                end
            end



            hT=obj.getTurnkeyObject;
            hBus=hT.hElab.getDefaultBusInterface;
            if~hBus.isEmptyAXI4SlaveInterface
                fprintf(fid,'\n# Add C files\n');
                downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclAddSWDriver',...
                fid,headerFileRelPath);
            end

            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.getTclIPPackageEnd',...
            fid,packageZipFileRelPath);
            fclose(fid);
        end

        function generateIPInterfaceVivadoTcl(obj,fid)


            hTurnkey=obj.getTurnkeyObject;
            interfaceIDList=hTurnkey.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hTurnkey.getInterface(interfaceID);


                if~hInterface.isIPInterface||...
                    ~hInterface.isInterfaceInUse(hTurnkey)
                    continue;
                end


                hElab=obj.hIP.hD.hTurnkey.hElab;

                hInterface.generateIPInterfaceVivadoTcl(fid,hElab);
            end
        end

        function generateIPClockModuleVivadoTcl(obj,fid)


            hDI=obj.getDIObject;
            hTurnkey=obj.getTurnkeyObject;
            hClockModule=hDI.getClockModule;


            clockInterfaceName=hClockModule.ClockPortName;
            clockPortName=hClockModule.ClockPortName;
            clockXilinxPortName='CLK';
            hdlturnkey.tool.generateVivadoTclInterfaceDefinition(hDI,fid,clockInterfaceName,...
            'xilinx.com:signal:clock_rtl:1.0','xilinx.com:signal:clock:1.0');
            hdlturnkey.tool.generateVivadoTclPortMap(hDI,fid,clockInterfaceName,...
            clockXilinxPortName,clockPortName);


            resetInterfaceName=hClockModule.ResetPortName;
            resetPortName=hClockModule.ResetPortName;
            resetXilinxPortName='RST';
            hdlturnkey.tool.generateVivadoTclInterfaceDefinition(hDI,fid,resetInterfaceName,...
            'xilinx.com:signal:reset_rtl:1.0','xilinx.com:signal:reset:1.0');
            hdlturnkey.tool.generateVivadoTclPortMap(hDI,fid,resetInterfaceName,...
            resetXilinxPortName,resetPortName)


            hdlturnkey.tool.generateVivadoTclParameter(hDI,fid,clockInterfaceName,'ASSOCIATED_RESET',resetPortName);
            hdlturnkey.tool.generateVivadoTclParameter(hDI,fid,resetInterfaceName,'POLARITY','ACTIVE_LOW');


            interfaceStr='';
            interfaceIDList=hTurnkey.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=hTurnkey.getInterface(interfaceID);


                if~hInterface.isIPInterface||...
                    ~hInterface.isInterfaceInUse(hTurnkey)
                    continue;
                end


                interfaceStr=hInterface.generateIPClockVivadoTcl(interfaceStr);
            end
            if~isempty(interfaceStr)
                hdlturnkey.tool.generateVivadoTclParameter(hDI,fid,clockInterfaceName,'ASSOCIATED_BUSIF',interfaceStr);
            end

            fprintf(fid,'\n');
        end

        function generateProductGuidePDF(obj)





            ipCoreName=obj.hIP.getIPCoreName;
            docFolder=obj.hReport.getPCoreDocFolder;
            reportFileName=obj.hReport.getReportFileName;
            hDI=obj.getDIObject;
            downstream.tool.runInPlugin(hDI,'Plugin_Tcl_Vivado.generateProductGuidePDF',...
            ipCoreName,docFolder,reportFileName);
        end

        function copyToIPRepository(obj)



            ipRepositoryPath=obj.hIP.getIPRepository;
            if isempty(ipRepositoryPath)
                return;
            end


            ipcoreFolder=obj.hIP.getIPCoreFolder;
            sourcePath=fullfile(ipcoreFolder,obj.IPPackageZipFileName);


            targetPath=ipRepositoryPath;


            downstream.tool.createDir(targetPath);
            copyfile(sourcePath,targetPath,'f');
        end

    end

end






