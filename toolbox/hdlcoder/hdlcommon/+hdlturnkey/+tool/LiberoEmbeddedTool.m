



classdef LiberoEmbeddedTool<hdlturnkey.tool.EmbeddedTool


    properties


        ConstraintFiles={};
        TclCmdStr='libero';

    end

    properties(Access=protected)


        ProjectFolder='';
    end

    properties(Constant)
        DisplayName='Microchip Libero SoC';

        CustomBlockDesignTcl='libero_custom_block_design.tcl';
        CreateProjectTcl='libero_create_prj.tcl';
        InsertIPTcl='libero_insert_ip.tcl';
        BuildProjTcl='libero_build_project.tcl';
        DownloadBit='libero_download.tcl';
        CustomMSSConfig='ICICLE_MSS.cfg';
        CustomMSSCxfFile='SF2_MSS_MSS.cxf';
        CustomMSSSdbFile='SF2_MSS_MSS.sdb';


        ProjectName='libero_prj';
        ProjectFileExt='prjx';


        LiberoFolder='libero_ip_prj';
        BitStreamFileExt='ppd';
        PhysicalConstraintExt='.pdc';
        BitstreamPathsubfolder='designer';
        TimingFailurePostfix='_timingfailure';
    end

    methods

        function obj=LiberoEmbeddedTool(hETool)

            obj=obj@hdlturnkey.tool.EmbeddedTool(hETool);
            obj.ProjectFolder=obj.LiberoFolder;
        end

    end


    methods

        function checkToolPath(obj)


            liberoToolPath=obj.hETool.hIP.hD.hToolDriver.getToolPath;


            obj.ToolPath=liberoToolPath;

        end

    end


    methods

        function liberoToolPath=getToolPath(obj)


            liberoToolPath=fullfile(obj.hETool.hIP.hD.hToolDriver.getToolPath,obj.TclCmdStr);
        end

        function[status,result]=runCreateProject(obj)

            result='';


            hRD=obj.hETool.getRDPlugin;


            methodStr=hRD.IPInsertionMethod;
            if~strcmpi(methodStr,'Insert')&&~strcmpi(methodStr,'Replace')
                error(message('hdlcommon:workflow:IPInsertMethodInvalid'));
            end


            copyRequiredFiles(obj,hRD);


            copyMSSConfigFiles(obj,hRD);


            tclFilePath=generateCreateProjTcl(obj,hRD);
            [status,result_tcl]=obj.runTclFile(tclFilePath,obj.getToolPath);
            result=sprintf('%s%s',result,result_tcl);
            if~status
                return;
            end


            copyIPCoreToProjFolder(obj);

            obj.ConstraintFiles={};
            obj.copyConstraintFiles(obj.PhysicalConstraintExt);


            tclFilePath=generateInsertIPTcl(obj);
            [status,~]=obj.runTclFile(tclFilePath,obj.getToolPath);
            if~status
                return;
            end
            removeHDLFolder(obj);
            isPolarFireSoC=strcmpi(obj.hETool.hIP.hD.get('Family'),'PolarFireSoC');
            if isPolarFireSoC
                removeComponentsFolder(obj);
            end
        end

        function[status,result]=runBuild(obj,runExtShell)


            if nargin<2
                runExtShell=false;
            end

            tclFilePath=generateBuildTcl(obj,runExtShell);
            [status,result]=obj.runTclFile(tclFilePath,obj.getToolPath,runExtShell);

        end

        function[status,result]=downloadBitstream(obj)


            chainPosition=obj.hETool.hIP.hD.hTurnkey.hBoard.JTAGChainPosition;

            [status,result]=obj.downloadBit(obj.getBitstreamPath,obj.getToolPath,chainPosition);
        end


        function setProjectFolder(obj,folder)
            obj.ProjectFolder=fullfile(folder,obj.LiberoFolder);
        end

        function name=getProjectName(obj)
            name=obj.ProjectName;
        end

        function removeHDLFolder(obj)
            hDI=obj.hETool.hIP.hD;
            hdlFolderDir=fullfile(pwd,hDI.getProjectPath,'hdl');


            if~isempty(hdlFolderDir)
                rmdir(hdlFolderDir,'s');
            end
        end

        function removeComponentsFolder(obj)
            hDI=obj.hETool.hIP.hD;
            compFolderDir=fullfile(pwd,hDI.getProjectPath,'components');


            if~isempty(compFolderDir)
                rmdir(compFolderDir,'s');
            end
        end

        function iprepo=getIpRepositoryFolder(obj)
            iprepo=obj.ipRepositoryFolder;
        end

        function name=getProjectFileName(obj)
            name=sprintf('%s.%s',obj.ProjectName,obj.ProjectFileExt);
        end

        function fpgaPartStr=getFPGADeviceStr(obj)

            deviceName=obj.hETool.hIP.hD.get('Device');
            fpgaPartStr=sprintf('%s',deviceName);
        end

        function path=getBitstreamPath(obj)

            path=fullfile(obj.getProjectFolder,obj.getBitstreamPathLocal);
        end

        function fpgaFamily=getFPGAFamily(obj)

            familyName=obj.hETool.hIP.hD.get('Family');
            fpgaFamily=sprintf('%s',familyName);
        end

        function ipRepositoryFolder=getLiberoIPRepositoryFolder(~,ipRepositoryPath)
            ipRepositoryFolder=downstream.tool.filterBackSlash(...
            downstream.tool.getAbsoluteFolderPath(ipRepositoryPath));
            ipRepositoryFolder=sprintf('"%s/**/*"',ipRepositoryFolder);
        end

    end

    methods(Access=protected)


        function tclFilePath=generateCreateProjTcl(obj,hRD)




            deviceSettings=obj.hETool.hIP.hD.hToolDriver.OptionList;
            hDI=obj.hETool.hIP.hD;
            topSmartDesign=obj.hETool.hIP.hIPEmitter.smartDesignName;


            hCodeGen=obj.hETool.getCodeGenObject;
            if hCodeGen.isVHDL
                targetL='VHDL';
            else
                targetL='Verilog';
            end


            tclFilePath=fullfile(obj.getProjectFolder,obj.CreateProjectTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);

            fprintf(fid,'set local_dir [pwd]\n\n');
            fprintf(fid,'if {[file isdirectory $local_dir/%s]} {\n',obj.ProjectName);
            fprintf(fid,'file delete -force $local_dir/%s\n',obj.ProjectName);
            fprintf(fid,'}\n\n');


            downstreamtools.Plugin_Tcl_Libero.getTclCreateNewProject(fid,obj.ProjectName,obj.ProjectName,...
            targetL,deviceSettings{1}.Value,deviceSettings{2}.Value,deviceSettings{3}.Value,deviceSettings{4}.Value);

            fprintf(fid,'source %s\n',obj.CustomBlockDesignTcl);

            isPolarFireSoC=strcmpi(hDI.get('Family'),'PolarFireSoC');
            hClockModule=hDI.getClockModule;

            hClockModule.generateLiberoTclSetClockFreq(hDI,fid,isPolarFireSoC,topSmartDesign);

            fprintf(fid,'save_project\n');
            fprintf(fid,'close_project\n');
            fprintf(fid,'exit\n');
            fclose(fid);
        end

        function tclFilePath=generateInsertIPTcl(obj)


            hDI=obj.hETool.hIP.hD;
            topSmartDesign=obj.hETool.hIP.hIPEmitter.smartDesignName;


            tclFilePath=fullfile(obj.getProjectFolder,obj.InsertIPTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);

            fprintf(fid,'#Open existing project\n');
            fprintf(fid,'set myTool "Microchip Libero SoC %s"\n',obj.hETool.hIP.hD.hToolDriver.hTool.ToolVersion);

            liberoProject=fullfile(hDI.getProjectPath,obj.ProjectName,...
            obj.getProjectFileName);
            liberoProject=strrep(liberoProject,'\','\\');
            fprintf(fid,'puts "### Open existing $myTool project <a href=\\"matlab:downstream.handle(''Model'',''%s'').openTargetTool;\\">%s</a>"\n',...
            obj.hETool.hIP.hD.hCodeGen.ModelName,liberoProject);

            projectDir=fullfile(pwd,hDI.getProjectPath);
            fprintf(fid,'set ProjectDir "%s"\n',strrep(projectDir,'\','\\'));

            fprintf(fid,'set myProject "%s"\n',obj.ProjectName);
            fprintf(fid,'set myProjectFile "%s"\n\n',obj.getProjectFileName);
            fprintf(fid,'%s\n',obj.hETool.hIP.hD.hToolDriver.hEmitter.tclOpenProject{:});

            fprintf(fid,'\n');
            fprintf(fid,'generate_component -component_name {%s} -recursive 0 \n',topSmartDesign);
            fprintf(fid,'save_smartdesign -sd_name {%s}\n\n',topSmartDesign);

            hIPLibero=obj.hETool.hIP.hIPEmitter.IPCoreHDLPath;
            [ipCoreTclFile,~,~]=fileparts(hIPLibero);
            source=fullfile(ipCoreTclFile,obj.hETool.hIP.hIPEmitter.getIPPackageTclFileName);

            Original_File=fopen(source,'r');
            currDir=pwd;

            originalString=fullfile(currDir,ipCoreTclFile,'prj');
            updateString=fullfile(currDir,obj.getProjectFolder,obj.ProjectName);

            createSmartDesignStr=['create_smartdesign -sd_name ',obj.hETool.hIP.hIPEmitter.smartDesignName];
            newProjectStr='new_project';

            while~feof(Original_File)
                str=fgets(Original_File);
                if contains(str,createSmartDesignStr)
                    fwrite(fid,strrep(str,createSmartDesignStr,''));
                elseif contains(str,newProjectStr)
                    newString=extractAfter(str,newProjectStr);
                    str=strrep(str,newString,'');
                    fwrite(fid,strrep(str,newProjectStr,''));
                else
                    fwrite(fid,strrep(str,originalString,updateString));
                end
            end

            fprintf(fid,'\n');
            fprintf(fid,'set_root -module {%s::work}\n',topSmartDesign);
            fprintf(fid,'open_smartdesign -sd_name {%s}\n',topSmartDesign);
            fprintf(fid,'save_smartdesign -sd_name {%s}\n',topSmartDesign);
            fprintf(fid,'build_design_hierarchy \n');
            fprintf(fid,'save_project \n');

            connectInterfaceAndPortsToIPCore(obj,fid,topSmartDesign);

            fprintf(fid,'save_smartdesign -sd_name {%s}\n',topSmartDesign);
            fprintf(fid,'build_design_hierarchy \n');
            fprintf(fid,'save_project \n');
            fprintf(fid,'generate_component -component_name {%s} -recursive 0 \n',topSmartDesign);


            if~isempty(obj.ConstraintFiles)
                constraintFullFilePath=fullfile(projectDir,obj.ConstraintFiles);
                constrainInLiberoProject=fullfile(projectDir,obj.ProjectName,'constraint','io',...
                obj.ConstraintFiles);
                fprintf(fid,'import_files -io_pdc {%s}\n',char(constraintFullFilePath));
                fprintf(fid,'run_tool -name {CONSTRAINT_MANAGEMENT}\n');
                fprintf(fid,['organize_tool_files -tool {PLACEROUTE} -file {%s} -module {%s::work} '...
                ,'-input_type {constraint}\n'],char(constrainInLiberoProject),topSmartDesign);
                fprintf(fid,'save_project\n');
            end

            fprintf(fid,'build_design_hierarchy \n');
            fprintf(fid,'save_project \n');
            fprintf(fid,'\n');
            fclose(fid);
            fclose(Original_File);
        end

        function tclFilePath=generateBuildTcl(obj,runExtShell)

            hDI=obj.hETool.hIP.hD;

            tclFilePath=fullfile(obj.getProjectFolder,obj.BuildProjTcl);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);

            fprintf(fid,'#Open existing project\n');
            fprintf(fid,'set myTool "Microchip Libero SoC %s"\n',obj.hETool.hIP.hD.hToolDriver.hTool.ToolVersion);

            projectDir=fullfile(pwd,hDI.getProjectPath);
            fprintf(fid,'set ProjectDir "%s"\n',strrep(projectDir,'\','\\'));

            fprintf(fid,'set myProject "%s"\n',obj.ProjectName);
            fprintf(fid,'set myProjectFile "%s"\n\n',obj.getProjectFileName);
            fprintf(fid,'%s\n',obj.hETool.hIP.hD.hToolDriver.hEmitter.tclOpenProject{:});

            fprintf(fid,'\n');









            fprintf(fid,'project_settings -abort_flow_on_pdc_errors 0 -block_mode 0\n');

            fprintf(fid,'run_tool -name {GENERATEPROGRAMMINGFILE} \n\n');

            if runExtShell
                fprintf(fid,'puts "------------------------------------"\n');
                fprintf(fid,'puts "Embedded system build completed."\n');
                fprintf(fid,'puts "You may close this shell."\n');
                fprintf(fid,'puts "------------------------------------"\n');
            end
            fclose(fid);
        end

        function connectInterfaceAndPortsToIPCore(obj,fid,topSmartDesign)
            topModuleInstance=[obj.hETool.hIP.hD.hCodeGen.EntityTop,'_0'];
            hDI=obj.hETool.hIP.hD;
            clockModule=hDI.getClockModule;

            clockPinConnection=strrep(clockModule.ClockConnection,'/',':');
            resetPinConnection=strrep(clockModule.ResetConnection,'/',':');

            fprintf(fid,'\n');
            fprintf(fid,'# Connections \n');

            [interfaceName]=generateIPInterfaceLiberoTcl(obj,fid,topSmartDesign,topModuleInstance);

            downstreamtools.Plugin_Tcl_Libero.getTclPortInterfaceConnection(fid,topSmartDesign,topModuleInstance,...
            clockModule.ResetPortName,clockPinConnection,resetPinConnection,clockModule.ClockPortName,interfaceName);

            fprintf(fid,'\n');
        end

        function[interfaceName]=generateIPInterfaceLiberoTcl(obj,fid,topSmartDesign,topModuleInstance)

            hTurnkey=obj.hETool.getTurnkeyObject;
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

                isInterfacePresent=(hInterface.isAXI4Interface||hInterface.isAXI4LiteInterface);
                if isInterfacePresent
                    interfaceName=strrep(hInterface.InterfaceID,'-','_');
                    downstreamtools.Plugin_Tcl_Libero.getTclHdlIPInterfaceConnection(fid,topSmartDesign,...
                    topModuleInstance,hInterface.MasterConnection,interfaceName);
                end
            end
        end

        function path=getBitstreamPathLocal(obj)

            topSmartDesign=obj.hETool.hIP.hIPEmitter.smartDesignName;
            bitstreamFileName=sprintf('%s.ppd',topSmartDesign);
            path=fullfile(sprintf('%s',obj.ProjectName),...
            obj.BitstreamPathsubfolder,topSmartDesign,bitstreamFileName);
        end



        function copyRequiredFiles(obj,hRD)




            requiredFileList={...
            {hRD.CustomBlockDesignTcl,obj.CustomBlockDesignTcl}...
            };
            obj.copyFileList(requiredFileList,hRD);

            optionalFileList={...
            {hRD.CustomMSSCxfFile,obj.CustomMSSCxfFile}...
            ,{hRD.CustomMSSSdbFile,obj.CustomMSSSdbFile}...
            };
            obj.copyFileListOptional(optionalFileList,hRD);


            obj.copyCustomFiles(hRD);


            obj.copyIPRepositories(hRD);
        end

        function copyIPCoreToProjFolder(obj)




            ipRepositoryPath=obj.hETool.hIP.getIPRepository;
            if~isempty(ipRepositoryPath)
                return;
            end

            sourcePath=fullfile(obj.hETool.hIP.getIPCoreFolder,obj.hETool.hIP.hIPEmitter.HDLFolder);
            targetPath=fullfile(obj.getProjectFolder,obj.hETool.hIP.hIPEmitter.HDLFolder);

            downstream.tool.createDir(targetPath);
            copyfile(sourcePath,targetPath,'f');
        end

        function copyMSSConfigFiles(obj,hRD)
            if~isempty(hRD.CustomMSSConfig)
                requiredFileList={...
                {hRD.CustomMSSConfig,obj.CustomMSSConfig}...
                };
                obj.copyFileList(requiredFileList,hRD);
            end
        end

        function[status,result]=downloadBit(obj,bitstreamPath,~,chainPosition)


            if nargin<3||isempty(chainPosition)
                chainPosition=2;
            end

            if~exist(bitstreamPath,'file')
                error(message('hdlcommon:workflow:NoBitFileWithName',bitstreamPath));
            end


            tclFilePath=fullfile(obj.getProjectFolder,obj.DownloadBit);
            fid=downstream.tool.createTclFile(tclFilePath,obj.hETool.hIP.getCurrentDir);


            hDI=obj.hETool.hIP.hD;
            fprintf(fid,'#Open existing project\n');
            fprintf(fid,'set myTool "Microchip Libero SoC %s"\n',obj.hETool.hIP.hD.hToolDriver.hTool.ToolVersion);

            projectDir=fullfile(pwd,hDI.getProjectPath);
            fprintf(fid,'set ProjectDir "%s"\n',strrep(projectDir,'\','\\'));
            fprintf(fid,'set chainPosition %d\n',chainPosition);
            fprintf(fid,'set myProject "%s"\n',obj.ProjectName);
            fprintf(fid,'set myProjectFile "%s"\n\n',obj.getProjectFileName);
            fprintf(fid,'open_project -file [subst -nobackslashes {$ProjectDir\\$myProject\\$myProjectFile} ]\n');

            fprintf(fid,'\n');
            fprintf(fid,'run_tool -name {PROGRAMDEVICE} \n\n');


            fclose(fid);


            [status,result]=obj.runTclFile(tclFilePath,obj.getToolPath);
            if~status
                return;
            end

        end


        function[status,result]=runTclFile(obj,tclFilePath,toolCmdStr,runExtShell)


            if nargin<4
                runExtShell=false;
            end

            [tclFileFolder,tname,text]=fileparts(tclFilePath);
            tclFileName=sprintf('%s%s',tname,text);
            currentDir=cd(tclFileFolder);
            if~exist(tclFileName,'file')
                error(message('hdlcommon:workflow:NoTclFileWithName',tclFileName));
            end

            if runExtShell

                cmdStr=sprintf('%s script:%s LOGFILE:workflow_task_runExtShell.log &',toolCmdStr,tclFileName);

                [status,result_tcl]=obj.run_cmd(cmdStr);

                result=sprintf(['%s\nRunning embedded system build outside MATLAB.Please Wait until '...
                ,'workflow_task_runExtShell.log file is generated.\n'],result_tcl);
            else
                cmdStr=sprintf('%s script:%s',toolCmdStr,tclFileName);

                hDI=obj.hETool.hIP.hD;

                tic;
                [status,resultSys]=obj.run_cmd(cmdStr,'',hDI.logDisplay);
                time=toc;
                result=sprintf('%s\nElapsed time is %s seconds.\n',resultSys,num2str(time));
            end

            cd(currentDir);
        end
    end

    methods(Static)

        function[status,result]=run_cmd(cmdStr,errstr,logDisplay)

            if nargin<2
                errstr='';
            end

            if nargin<3
                logDisplay=false;
            end


            if(logDisplay)
                [status,result]=system(cmdStr,'-echo');
            else
                [status,result]=system(cmdStr);
            end

            result=regexprep(result,[char(27),'.*?m'],'');

            if~isempty(errstr)
                if~status
                    search_result=regexp(result,errstr,'once');
                    if~isempty(search_result)
                        status=true;
                    end
                end
            end


            status=~status;
        end

    end

end

